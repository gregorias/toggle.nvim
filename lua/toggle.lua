---@class Config
---@field register_keymaps fun(table)?: Which-key compatible function for registering keymaps.
local global_config = nil
local setup_done = false

---@class Option
---@field name string A human-readable identifier for this option.
---@field keymap string
---@field get_state fun(): boolean Returns whether the option is on (true) or off (false).
---@field set_state fun(state: boolean)

--- A repository of all to-be-registered options.
---@type table<string, Option>
local options_by_keymap_todo = {}

--- A repository of all registered options.
---@type table<string, Option>
local options_by_keymap = {}

local TOGGLE_OPTION_PREFIX = "yo"
local ENABLE_OPTION_PREFIX = "[o"
local DISABLE_OPTION_PREFIX = "]o"

---@class ToggleModule
local M = {}

---Registers a new option.
---
---@param option Option
function M.register(option)
  if not setup_done then
    options_by_keymap_todo[option.keymap] = option
    return nil
  end

  if options_by_keymap.keymap ~= nil then
    vim.notify("Option " .. option.name .. " already registered.", vim.log.levels.ERROR)
    return nil
  end
  options_by_keymap[option.keymap] = option

  global_config.register_keymaps({
    ["yo"] = {
      [option.keymap] = {
        function()
          option.set_state(not option.get_state())
        end,
        "Toggle " .. option.name,
      },
    },
    ["[o"] = {
      [option.keymap] = {
        function()
          option.set_state(true)
        end,
        "Enable " .. option.name,
      },
    },
    ["]o"] = {
      [option.keymap] = {
        function()
          option.set_state(false)
        end,
        "Disable " .. option.name,
      },
    },
  })
end

---@param config Config?
M.setup = function(config)
  setup_done = true

  global_config = config or {}
  global_config.register_keymaps = global_config.register_keymaps or require("which-key").register

  global_config.register_keymaps({
    [TOGGLE_OPTION_PREFIX] = {
      name = "+Toggle option",
    },
    [ENABLE_OPTION_PREFIX] = {
      name = "+Enable option",
    },
    [DISABLE_OPTION_PREFIX] = {
      name = "+Disable option",
    },
  })

  for _, option in pairs(options_by_keymap_todo) do
    M.register(option)
  end
  options_by_keymap_todo = {}
end

return M
