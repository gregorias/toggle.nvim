--- A module for registering options.
---
--- An option registry is a singleton that works in a context of a Neovim session.
---
---@module "toggle.option-registry"
local M = {}

local global_options = {}

---@class OptionRegistryRegisterOptionOpts
---@field bufnr number?

--- Registers an option.
---
---@param option Option
---@param opts OptionRegistryRegisterOptionOpts?
---@return nil
M.register_option = function(option, opts)
  local buffer_m = require("toggle.buffer")
  local bufnr = opts and opts.bufnr
  if bufnr ~= nil then
    buffer_m.b[bufnr].toggle_options = buffer_m.b[bufnr].toggle_options or {}
    buffer_m.b[bufnr].toggle_options[option.name] = option
  else
    global_options[option.name] = option
  end
end

--- Unregisters an option.
---
---@param option_name string
---@param opts OptionRegistryRegisterOptionOpts?
---@return nil
M.unregister_option = function(option_name, opts)
  local buffer_m = require("toggle.buffer")
  local bufnr = opts and opts.bufnr
  if bufnr ~= nil then
    buffer_m.b[bufnr].toggle_options[option_name] = nil
  else
    global_options[option_name] = nil
  end
end

--- Returns all options.
---
---@param bufnr number?
---@return table<string, Option>
M.get_options = function(bufnr)
  local buffer_m = require("toggle.buffer")
  local options = {}
  options = vim.tbl_extend("force", options, global_options)
  if bufnr ~= nil then
    options = vim.tbl_extend("force", options, buffer_m.b[bufnr].toggle_options or {})
  end
  return options
end

return M
