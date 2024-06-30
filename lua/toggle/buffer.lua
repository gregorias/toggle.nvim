--- Buffer-related utilities.
---
---@module "toggle.buffer"
local M = {}

-- An implementation of buffer-local variables.
-- Neovim doesn't have a built-in way to set buffer-local variables, so we have to
-- do it ourselves.

---@type table<number, table<string, any>>
local buffer_local_variables = {}

--- Whether the cleanup function is setup.
---@type boolean
local buffer_cleanup_ready = false

--- Sets up a buffer for buffer-local variable.
---
--- This function is idempotent.
---
---@param bufnr number
---@param key string
---@param value any
---@return nil
local setup_local_variables = function(bufnr)
  --- Check if the buffer exists.
  if not vim.api.nvim_buf_is_valid(bufnr) then
    error("Invalid buffer number: " .. bufnr)
    return
  end

  if not buffer_cleanup_ready then
    vim.api.nvim_create_autocmd("BufWipeout", {
      pattern = "*",
      callback = function(ev)
        buffer_local_variables[ev.buf] = nil
      end,
    })
    buffer_cleanup_ready = true
  end

  if buffer_local_variables[bufnr] == nil then
    buffer_local_variables[bufnr] = {}
  end
end

--- Sets a buffer-local variable.
---
---@param bufnr number
---@param key string
---@param value any
---@return nil
M.set_local_variable = function(bufnr, key, value)
  setup_local_variables(bufnr)
  buffer_local_variables[bufnr] = buffer_local_variables[bufnr] or {}
  buffer_local_variables[bufnr][key] = value
end

--- Returns a buffer-local variable.
---
---@param bufnr number
---@param key string
---@return any?
M.get_local_variable = function(bufnr, key)
  local vars = buffer_local_variables[bufnr]
  if vars == nil then
    return nil
  end
  return vars[key]
end

--- Like vim.b, but for buffer-local variables.
M.b = {}
setmetatable(M.b, {
  __index = function(_, bufnr)
    setup_local_variables(bufnr)
    return buffer_local_variables[bufnr]
  end,
})

return M
