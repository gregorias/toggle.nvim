---@class ToggleModule
local M = {}

local option_m = require("toggle.option")
local default_options_m = require("toggle.default-options")

---@class Config
---@field register_keymaps fun(table, table?)?: Which-key compatible function for registering keymaps.
---@field options_by_keymap table<string, Option>?: A table of options to register keyed by their keymap.
---                                                 If nil, the default options will be used.
local global_config = nil
local setup_done = false

--- A repository of all to-be-registered options.
---@type table<string, Option>
local options_by_keymap_todo = {}

--- A repository of all registered options.
---@type table<string, Option>
local options_by_keymap = {}

--- A table of default options.
---@type table<string, Option>
M.default_options_by_keymap = {
  cl = option_m.NotifyOnSetOption(default_options_m.conceallevel_option),
  d = option_m.NotifyOnSetOption(default_options_m.diff_option),
  D = option_m.NotifyOnSetOption(default_options_m.diff_all_option),
  w = option_m.NotifyOnSetOption(default_options_m.wrap_option),
}

local TOGGLE_OPTION_PREFIX = "yo"
local ENABLE_OPTION_PREFIX = "[o"
local DISABLE_OPTION_PREFIX = "]o"

M.option = option_m

---@class RegisterOpts
---@field buffer? integer|boolean Creates a buffer-local option.

---Registers a new option.
---
---@param keymap string
---@param option Option
---@param opts RegisterOpts?
function M.register(keymap, option, opts)
  if not setup_done then
    options_by_keymap_todo[keymap] = option
    return nil
  end

  if options_by_keymap.keymap ~= nil then
    vim.notify("Option " .. option.name .. " already registered.", vim.log.levels.ERROR)
    return nil
  end
  options_by_keymap[keymap] = option

  global_config.register_keymaps({
    ["yo"] = {
      [keymap] = {
        function()
          option.toggle_state()
        end,
        "Toggle " .. option.name,
      },
    },
    ["[o"] = {
      [keymap] = {
        function()
          option.set_prev_state()
        end,
        "Go to previous (off) state of " .. option.name,
      },
    },
    ["]o"] = {
      [keymap] = {
        function()
          option.set_next_state()
        end,
        "Go to next (on) state of " .. option.name,
      },
    },
  }, { buffer = opts and opts.buffer })
end

---@param config Config?
M.setup = function(config)
  local default_options_by_keymap = M.default_options_by_keymap
  if config ~= nil and config.options_by_keymap ~= nil then
    default_options_by_keymap = config.options_by_keymap
  end

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

  ---@diagnostic disable-next-line: param-type-mismatch
  for keymap, option in pairs(default_options_by_keymap) do
    M.register(keymap, option)
  end
  for keymap, option in pairs(options_by_keymap_todo) do
    M.register(keymap, option)
  end
  options_by_keymap_todo = {}
end

return M
