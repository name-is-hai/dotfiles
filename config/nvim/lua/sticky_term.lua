--- Sticky / Persistent Terminal Wrapper for Snacks.terminal
--- Remembers position and dimensions per terminal instance
local M = {}

vim.g.sticky_terms = vim.g.sticky_terms or {}
M._configs = {}

--- Detect actual split position in neovim
---@param win number
---@param default_pos? string
---@return string
local function detect_position(win, default_pos)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return default_pos or "right"
  end
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative and cfg.relative ~= "" then
    return "float"
  end
  local pos = vim.api.nvim_win_get_position(win)
  local row, col = pos[1], pos[2]
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)
  local total_cols = vim.o.columns
  local total_rows = vim.o.lines

  -- Check horizontal full-width split
  if width >= total_cols - 2 then
    if row == 0 and height < total_rows - 3 then
      return "top"
    elseif row > 0 then
      return "bottom"
    end
  end

  -- Check vertical split
  if col + width >= total_cols - 2 and col > 0 then
    return "right"
  elseif col == 0 and width < total_cols - 2 then
    return "left"
  end

  return default_pos or "right"
end

--- Save the current window size & position
---@param name string
---@param win snacks.win
local function save_size(name, win)
  if win and win.win and vim.api.nvim_win_is_valid(win.win) then
    local states = vim.g.sticky_terms
    local pos = detect_position(win.win, win.opts and win.opts.position)
    states[name] = {
      position = pos,
      width = vim.api.nvim_win_get_width(win.win),
      height = vim.api.nvim_win_get_height(win.win),
    }
    vim.g.sticky_terms = states
  end
end

--- Resolve terminal name from options
---@param opts? table | string
local function get_name(opts)
  if type(opts) == "string" then
    return opts
  end
  opts = opts or {}
  return opts.name or (opts.count and "term_" .. opts.count) or (type(opts.cmd) == "string" and opts.cmd) or "default"
end

--- Get terminal options merged with registered config
---@param opts? string | table
---@return table
local function resolve_opts(opts)
  if type(opts) == "string" then
    opts = { name = opts }
  end
  opts = opts or {}
  local name = get_name(opts)
  local config = M._configs[name] or {}
  return vim.tbl_deep_extend("force", {}, config, opts)
end

--- Find an existing terminal instance by name or options
---@param opts? string | table
---@return snacks.win? terminal
function M.get(opts)
  local full_opts = resolve_opts(opts)
  local name = get_name(full_opts)

  local term = Snacks.terminal.get(full_opts.cmd, vim.tbl_extend("force", full_opts, { create = false }))
  if term then
    return term
  end

  for _, t in ipairs(Snacks.terminal.list()) do
    local is_match = false
    if t.meta and t.meta.name == name then
      is_match = true
    elseif t.buf and vim.b[t.buf].sticky_name == name then
      is_match = true
    elseif full_opts.count and t.buf and vim.b[t.buf].snacks_terminal and vim.b[t.buf].snacks_terminal.id == full_opts.count then
      is_match = true
    end
    if is_match then
      return t
    end
  end

  return nil
end

--- Check if a terminal is currently visible/open
---@param opts? string | table
---@return boolean
function M.is_open(opts)
  local term = M.get(opts)
  return term ~= nil and term:valid()
end

--- Get the resolved/current position of a terminal ("right", "left", "bottom", "top", "float")
---@param opts? string | table
---@return string position
function M.get_position(opts)
  local full_opts = resolve_opts(opts)
  local name = get_name(full_opts)
  local term = M.get(full_opts)
  if term and term:valid() then
    return detect_position(term.win, term.opts and term.opts.position)
  end
  local state = vim.g.sticky_terms[name]
  if state and state.position then
    return state.position
  end
  if full_opts.win and full_opts.win.position then
    return full_opts.win.position
  end
  return "right"
end

--- Hide a specific terminal, saving its size
---@param opts? string | table
---@return boolean hidden whether terminal was hidden
function M.hide(opts)
  local full_opts = resolve_opts(opts)
  local name = get_name(full_opts)
  local term = M.get(full_opts)
  if term and term:valid() then
    save_size(name, term)
    term:hide()
    return true
  end
  return false
end

--- Hide a terminal only if it is open on the same split side (non-float)
---@param opts string | table
---@param target_pos string
---@return boolean hidden
function M.hide_if_same_side(opts, target_pos)
  if not target_pos or target_pos == "float" then
    return false
  end
  local term_pos = M.get_position(opts)
  if term_pos ~= "float" and term_pos == target_pos and M.is_open(opts) then
    return M.hide(opts)
  end
  return false
end

--- Hide all terminals that share the same split side as target_pos
---@param target_pos string
function M.hide_all_if_same_side(target_pos)
  if not target_pos or target_pos == "float" then
    return
  end
  for name, _ in pairs(M._configs) do
    M.hide_if_same_side(name, target_pos)
  end
end

--- Hide all terminals at a specific position (e.g. "right") or all sticky terminals
---@param position? string
function M.hide_all(position)
  for name, _ in pairs(M._configs) do
    local term = M.get(name)
    if term and term:valid() then
      if not position or (term.opts and term.opts.position == position) then
        save_size(name, term)
        term:hide()
      end
    end
  end
end

--- Toggle a terminal while remembering its size and position
---@param opts? snacks.terminal.Opts | { name?: string, before_open?: fun() }
function M.toggle(opts)
  opts = opts or {}
  local name = get_name(opts)
  M._configs[name] = opts

  local default_win = opts.win or { position = "right", width = 0.4 }
  local state = vim.g.sticky_terms[name] or default_win

  local term_opts = vim.tbl_deep_extend("force", {}, opts, {
    win = {
      position = state.position or default_win.position or "right",
      width = state.width or default_win.width or 0.4,
      height = state.height or default_win.height,
      on_buf = function(win)
        vim.b[win.buf].sticky_name = name
        if opts.win and opts.win.on_buf then
          opts.win.on_buf(win)
        end
      end,
      on_close = function(win)
        save_size(name, win)
        if opts.win and opts.win.on_close then
          opts.win.on_close(win)
        end
      end,
    },
  })

  local term = M.get(opts)
  if term and term:valid() then
    save_size(name, term)
    term:hide()
    return
  end

  if opts.before_open then
    opts.before_open()
  end

  if term then
    local s = vim.g.sticky_terms[name] or default_win
    term.opts.position = s.position or term.opts.position or default_win.position
    term.opts.width = s.width or term.opts.width or default_win.width
    term.opts.height = s.height or term.opts.height or default_win.height
  end

  return Snacks.terminal.toggle(opts.cmd, term_opts)
end

--- Create a dedicated toggle function for a specific terminal
---@param opts? snacks.terminal.Opts | { name?: string, before_open?: fun() }
function M.create(opts)
  opts = opts or {}
  local name = get_name(opts)
  M._configs[name] = opts
  return function()
    return M.toggle(opts)
  end
end

return M
