--- A module for table utilities.
---
---@module "toggle.table-extra"
local M = {}

--- Shallow-copies a table.
---
---@param tbl table
---@return table
M.shallow_copy = function(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    copy[k] = v
  end
  return copy
end

return M
