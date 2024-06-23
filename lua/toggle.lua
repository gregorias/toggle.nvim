---@class ToggleModule
local M = {}

local option_m = require("toggle.option")

---@class Config
---@field register_keymaps fun(table)?: Which-key compatible function for registering keymaps.
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
  cl = option_m.NotifyOnSetOption(option_m.SliderOption({
    name = "conceallevel",
    values = { 0, 1, 2, 3 },
    get_state = function()
      return vim.o.conceallevel
    end,
    set_state = function(state)
      vim.o.conceallevel = state
    end,
    toggle_behavior = "min",
  })),
  d = option_m.NotifyOnSetOption(option_m.OnOffOption({
    name = "diff",
    get_state = function()
      return vim.o.diff
    end,
    set_state = function(state)
      vim.o.diff = state
    end,
  })),
  w = option_m.NotifyOnSetOption(option_m.OnOffOption({
    name = "wrap",
    keymap = "w",
    get_state = function()
      return vim.o.wrap
    end,
    set_state = function(state)
      vim.o.wrap = state
    end,
  })),
}

local TOGGLE_OPTION_PREFIX = "yo"
local ENABLE_OPTION_PREFIX = "[o"
local DISABLE_OPTION_PREFIX = "]o"

M.option = option_m

---Registers a new option.
---
---@param keymap string
---@param option Option
function M.register(keymap, option)
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
  })
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
