--- This module contains implementations for the default options.
--- It’s also a good example of how to define new options.
---
--- @module "toggle.default-options"
local M = {}

local option = require("toggle.option")

M.conceallevel_option = option.SliderOption({
  name = "conceallevel",
  values = { 0, 1, 2, 3 },
  get_state = function()
    return vim.o.conceallevel
  end,
  set_state = function(state)
    vim.o.conceallevel = state
  end,
  toggle_behavior = "min",
})

M.diff_option = option.OnOffOption({
  name = "diff",
  get_state = function()
    return vim.wo.diff
  end,
  set_state = function(state)
    vim.wo.diff = state
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
    return "on"
  elseif diff_count.on > 0 and diff_count.off == 0 then
    return "on"
  elseif diff_count.off > 0 and diff_count.on == 0 then
    return "off"
  elseif diff_count.off == 0 and diff_count.on == 0 then
    return "none"
  end
end

M.diff_all_option = {
  name = "diff all",
  get_state = get_diff_all_state,
  set_prev_state = function()
    for_normal_windows(function(winid)
      vim.wo[winid].diff = false
    end)
    return "off"
  end,
  set_next_state = function()
    for_normal_windows(function(winid)
      vim.wo[winid].diff = true
    end)
    return "on"
  end,
  toggle_state = function()
    local current_state = get_diff_all_state()
    if current_state == "none" then
      return nil
    end
    for_normal_windows(function(winid)
      if current_state == "on" then
        vim.wo[winid].diff = false
      else
        vim.wo[winid].diff = true
      end
    end)
    if current_state == "on" then
      return "off"
    else
      return "on"
    end
  end,
}

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
