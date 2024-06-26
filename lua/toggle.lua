---@class ToggleModule
local M = {}

local option_m = require("toggle.option")
local default_options_m = require("toggle.default-options")

---@class ToggleConfig
---@field keymaps table
---@field keymap_registry KeymapRegistry A keymap registry.
---@field options_by_keymap table<string, Option> A table of initial options to register keyed by their keymap.

--- Like ToggleConfig but with optional fields.
---@class UserToggleConfig
---@field keymaps table
---@field keymap_registry? KeymapRegistry? A keymap registry.
---@field options_by_keymap table<string, Option>? A table of options to register keyed by their keymap.
---                                                If nil, the default options will be used.

---@type ToggleConfig
local default_config = {
  keymaps = {
    toggle_option_prefix = "yo",
    previous_option_prefix = "[o",
    next_option_prefix = "]o",
    status_dashboard = "yos",
  },
  keymap_registry = require("toggle.keymap").keymap_registry(),
  options_by_keymap = {
    cl = option_m.NotifyOnSetOption(default_options_m.conceallevel_option),
    d = option_m.NotifyOnSetOption(default_options_m.diff_option),
    D = option_m.NotifyOnSetOption(default_options_m.diff_all_option),
    w = option_m.NotifyOnSetOption(default_options_m.wrap_option),
  },
}

---@type ToggleConfig
local global_config = default_config
local setup_done = false

--- A repository of all to-be-registered options.
---@type table<string, Option>
local options_by_keymap_todo = {}

--- A repository of all registered options.
---@type table<string, Option>
local options_by_keymap = {}

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

  local keymap_registry = global_config.keymap_registry
  local keymaps = global_config.keymaps
  keymap_registry.register_keymap("n", keymaps.toggle_option_prefix .. keymap, function()
    option.toggle_state()
  end, { desc = "Toggle " .. option.name, buffer = opts and opts.buffer })
  keymap_registry.register_keymap("n", keymaps.previous_option_prefix .. keymap, function()
    option.set_prev_state()
  end, { desc = "Set previous (off) state of " .. option.name, buffer = opts and opts.buffer })
  keymap_registry.register_keymap("n", keymaps.next_option_prefix .. keymap, function()
    option.set_next_state()
  end, { desc = "Set next (on) state of " .. option.name, buffer = opts and opts.buffer })
end

---@param config ToggleConfig?
M.setup = function(config)
  global_config = vim.tbl_deep_extend("keep", config or {}, default_config)

  setup_done = true

  global_config.keymap_registry = global_config.keymap_registry or require("toggle.keymap").keymap_registry()
  global_config.keymap_registry.register_keymap_group("n", global_config.keymaps.toggle_option_prefix, "+Toggle option")
  global_config.keymap_registry.register_keymap_group("n", global_config.keymaps.next_option_prefix, "+Next option")
  global_config.keymap_registry.register_keymap_group(
    "n",
    global_config.keymaps.previous_option_prefix,
    "+Previous option"
  )

  ---@diagnostic disable-next-line: param-type-mismatch
  for keymap, option in pairs(global_config.options_by_keymap) do
    M.register(keymap, option)
  end
  for keymap, option in pairs(options_by_keymap_todo) do
    M.register(keymap, option)
  end
  options_by_keymap_todo = {}

  if global_config.keymaps.status_dashboard then
    global_config.keymap_registry.register_keymap("n", global_config.keymaps.status_dashboard, function()
      local options = {}
      for _, option in pairs(options_by_keymap) do
        table.insert(options, option)
      end
      table.sort(options, function(a, b)
        return a.name < b.name
      end)
      require("toggle.dashboard").show_dashboard(options)
    end, { desc = "Show Toggle status dashboard" })
  end
end

return M
