local M = {}

--- Formats an option into a menu item string.
---
--- The menu item includes the option’s name and its state.
---
---@param option Option
---@return string
local format_option = function(option)
  local state = option.get_state()
  local state_str = ""
  if type(state) == "string" then
    state_str = state
  elseif type(state) == "boolean" then
    if state then
      state_str = "ON"
    else
      state_str = "OFF"
    end
  else
    state_str = vim.inspect(state)
  end
  return option.name .. " [" .. state_str .. "]"
end

--- Shows a dashboard of options.
---
---@param options Option[]
M.show_dashboard = function(options)
  vim.ui.select(options, {
    prompt = "Option",
    kind = "toggle.nvim",
    format_item = function(option)
      return format_option(option)
    end,
  }, function() end)
end

--- Gets options suitable for the dashboard.
---
---@return Option[]
M.get_options_for_dashboard = function()
  local options = {}
  local option_registry = require("toggle.option-registry")
  local bufnr = vim.api.nvim_get_current_buf()
  for _, option in pairs(option_registry.get_options(bufnr)) do
    table.insert(options, option)
  end

  table.sort(options, function(a, b)
    return a.name < b.name
  end)
  return options
end

return M
