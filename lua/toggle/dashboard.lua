local M = {}

local column_separator_char = "│"

local pad = function(value, length)
  local new_value = value
  for _ = 1, length - #value do
    new_value = new_value .. " "
  end
  return new_value
end

--- Formats an option into a menu item string.
---
--- The menu item includes the option’s name and its state.
---
---@param entry table
---@param column_widths number[]
---@return string
local format_option = function(entry, column_widths)
  return string.format("%s %s %s", pad(entry[1], column_widths[1]), column_separator_char, entry[2])
end

--- Shows a dashboard of options.
---
---@param options Option[]
M.show_dashboard = function(options)
  local entries = vim.tbl_map(function(option)
    return {
      [1] = M.show_option_state(option),
      [2] = option.name,
      option = option,
    }
  end, options)
  local column_widths = M.compute_column_widths(vim.tbl_map(function(entry)
    return { entry[1], entry[2] }
  end, entries))
  vim.ui.select(entries, {
    prompt = "Option",
    kind = "toggle.nvim",
    format_item = function(entry)
      return format_option(entry, column_widths)
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

--- Shows option state.
---
---@param option Option
---@return string
M.show_option_state = function(option)
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
  return state_str
end

--- Computes the column widths for a list of entries.
---
---@param entries string[][]
---@return number[]
M.compute_column_widths = function(entries)
  if #entries == 0 then
    return {}
  end

  local column_count = #entries[1]

  local widths = {}
  for i = 1, column_count do
    widths[i] = 0
  end

  for _, entry in ipairs(entries) do
    for i, value in ipairs(entry) do
      if #value > widths[i] then
        widths[i] = #value
      end
    end
  end

  return widths
end

return M
