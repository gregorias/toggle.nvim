--- A module with utilities for manipulating keymaps.
---
---@module "toggle.keymap"
local M = {}

--- Keymap registry is an interface for registering keymaps.
---@class KeymapRegistry
---@field register_keymap_group fun(mode: string, keymap: string, description: string): nil
---@field register_keymap fun(mode: string, keymap: string, action: function|string, opts: table): nil

--- A plain keymap registry that uses vim.keymap.set.
---@type KeymapRegistry
M.plain_keymap_registry = {
  register_keymap_group = function()
    return nil
  end,
  register_keymap = function(mode, keymap, action, opts)
    vim.keymap.set(mode, keymap, action, opts)
  end,
}

--- The WhichKey keymap registry.
---@type KeymapRegistry
M.which_key_keymap_registry = {
  register_keymap_group = function(mode, keymap, description)
    require("which-key").register({
      [keymap] = { name = description },
    }, { mode = mode })
    -- Fixes a bug, where:
    --
    -- - The WhichKey window doesn’t show up in the visual mode ("v" or "x")
    --   The open bug in question: https://github.com/folke/which-key.nvim/issues/458.
    -- - The WhichKey window doesn’t show up in when there’s a conflicting prefix, e.g., `gcr` is used for Coerce, but
    --   `gc` is used for commenting.
    vim.keymap.set(mode, keymap, "<cmd>WhichKey " .. keymap .. " " .. mode .. "<cr>")
  end,
  register_keymap = function(mode, keymap, action, opts)
    require("which-key").register({
      [keymap] = {
        action,
        opts.desc,
      },
    }, { mode = mode, buffer = opts.buffer })
  end,
}

--- Returns a suitable keymap registry.
---
---@return KeymapRegistry
M.keymap_registry = function()
  local which_key_status, _ = pcall(require, "which-key")
  if which_key_status then
    return M.which_key_keymap_registry
  else
    return M.plain_keymap_registry
  end
end

return M
