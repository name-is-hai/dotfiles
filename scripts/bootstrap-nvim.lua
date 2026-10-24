local function bootstrap()
  local config = assert(vim.env.DOTFILES_NVIM_CONFIG, "DOTFILES_NVIM_CONFIG is required")
  assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
  vim.opt.runtimepath:prepend(config)
  for _, executable in ipairs({ "git", "npm", "cc", "curl", "tar", "unzip", "tree-sitter", "rustfmt" }) do
    assert(vim.fn.executable(executable) == 1, "Missing executable: " .. executable)
  end

  -- Restore locked plugins before sourcing their configuration, without prompts.
  vim.pack.add({}, { confirm = false, load = false })
  dofile(config .. "/init.lua")
  for _, file in ipairs(vim.fn.glob(config .. "/plugin/*.lua", false, true)) do
    dofile(file)
  end

  local dependencies = require("dependencies")
  local registry = require("mason-registry")
  local refreshed, refresh_ok = false, false
  registry.refresh(function(success)
    refresh_ok, refreshed = success, true
  end)
  assert(vim.wait(120000, function() return refreshed end, 100), "Mason registry refresh timed out")
  assert(refresh_ok, "Mason registry refresh failed; see :MasonLog")

  for _, name in ipairs(vim.fn.sort(vim.tbl_keys(dependencies.tools))) do
    local version = dependencies.tools[name]
    local package = registry.get_package(name)
    if not package:is_installed() or package:get_installed_version() ~= version then
      print("Installing " .. name .. "@" .. version)
      local finished, succeeded, failure = false, false, nil
      package:install({ version = version }, function(success, result)
        succeeded, failure, finished = success, result, true
      end)
      assert(vim.wait(600000, function() return finished end, 100), "Installation timed out: " .. name)
      assert(succeeded, "Failed to install " .. name .. ": " .. vim.inspect(failure))
    end
  end

  local treesitter = require("nvim-treesitter")
  assert(treesitter.install(dependencies.parsers, { summary = true }):wait(600000),
    "Treesitter parser installation failed; rerun the bootstrap to retry")
  assert(treesitter.update(dependencies.parsers, { summary = true }):wait(600000),
    "Treesitter parser update failed; rerun the bootstrap to retry")
  print("All configured editor tools and parsers are installed.")
end

local ok, err = xpcall(bootstrap, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
