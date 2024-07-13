--- This module contains implementations for the default options.
--- It’s also a good example of how to define new options.
---
--- @module "toggle.default-options"
local M = {}

local option = require("toggle.option")

---@type EnumOption
M.background_option = option.EnumOption({
  name = "background",
  states = { "light", "dark" },
  get_state = function()
    return vim.o.background
  end,
  set_state = function(state)
    vim.o.background = state
  end,
})

---@type EnumOption
M.conceallevel_option = option.EnumOption({
  name = "conceallevel",
  states = { 0, 1, 2, 3 },
  get_state = function()
    return vim.o.conceallevel
  end,
  set_state = function(state)
    vim.o.conceallevel = state
  end,
  toggle_behavior = "min",
})

---@type EnumOption
M.cursorline_option = option.OnOffOption({
  name = "cursorline",
  get_state = function()
    return vim.wo.cursorline
  end,
  set_state = function(state)
    vim.wo.cursorline = state
  end,
})

---@type EnumOption
M.diff_option = option.OnOffOption({
  name = "diff",
  get_state = function()
    return vim.wo.diff
  end,
  set_state = function(state)
    if state then
      vim.cmd("diffthis")
    else
      vim.cmd("diffoff")
    end
  end,
})

--- Runs a function for each normal window.
local for_normal_windows = function(fn)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
      if vim.fn.win_gettype(winid) == "" then
        fn(winid)
      end
    end
  end
end

local diff_all_option_off = "OFF"
local diff_all_option_on = "ON"
local diff_all_option_none = "NONE"
local diff_all_option_mixed = "MIXED"

--- Gets the diff state of all normal windows.
local get_diff_all_state = function()
  local diff_count = {
    off = 0,
    on = 0,
  }
  -- Diff only applies to normal windows.
  for_normal_windows(function(winid)
    if vim.wo[winid].diff then
      diff_count.on = diff_count.on + 1
    else
      diff_count.off = diff_count.off + 1
    end
  end)
  if diff_count.off > 0 and diff_count.on > 0 then
    return diff_all_option_mixed
  elseif diff_count.on > 0 and diff_count.off == 0 then
    return diff_all_option_on
  elseif diff_count.off > 0 and diff_count.on == 0 then
    return diff_all_option_off
  elseif diff_count.off == 0 and diff_count.on == 0 then
    return diff_all_option_none
  end
end

---@type EnumOption
M.diff_all_option = {
  name = "diff all",
  get_available_states = function(_)
    return { diff_all_option_off, diff_all_option_on }
  end,
  get_state = function(_)
    return get_diff_all_state()
  end,
  set_state = function(_, state)
    if state == diff_all_option_off then
      vim.cmd("windo if win_gettype() == '' | diffoff | endif")
    elseif state == diff_all_option_on then
      vim.cmd("windo if win_gettype() == '' | diffthis | endif")
    end
  end,
  set_prev_state = function(self)
    self:set_state(diff_all_option_off)
  end,
  set_next_state = function(self)
    self:set_state(diff_all_option_on)
  end,
  toggle_state = function(self)
    local current_state = self:get_state()
    if current_state == diff_all_option_none then
      return
    end
    if current_state == diff_all_option_on then
      self:set_state(diff_all_option_off)
    else
      self:set_state(diff_all_option_on)
    end
  end,
}

---@type EnumOption
M.list_option = option.OnOffOption({
  name = "list",
  get_state = function()
    return vim.wo.list
  end,
  set_state = function(state)
    vim.wo.list = state
  end,
})

---@type EnumOption
M.number_option = option.OnOffOption({
  name = "number",
  get_state = function()
    return vim.wo.number
  end,
  set_state = function(state)
    vim.wo.number = state
  end,
})

---@type EnumOption
M.relativenumber_option = option.OnOffOption({
  name = "relativenumber",
  get_state = function()
    return vim.wo.relativenumber
  end,
  set_state = function(state)
    vim.wo.relativenumber = state
  end,
})

---@type EnumOption
M.wrap_option = option.OnOffOption({
  name = "wrap",
  get_state = function()
    return vim.o.wrap
  end,
  set_state = function(state)
    vim.o.wrap = state
  end,
})

return M
