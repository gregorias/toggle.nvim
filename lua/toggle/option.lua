--- A module for Toggle options.
---
---@module "toggle.option"
local M = {}

---@alias OptionState string|number|boolean

--- A generic option.
---
---@class Option
---@field name string A human-readable identifier for the option.
---@field get_state fun(self: Option): OptionState Returns the current state.
---@field set_state fun(self: Option, state: OptionState) Sets the option’s state to the given value.

--- An option that can acts as a toggle.
---
--- A toggle has esentially three affordances: toggling, moving to the next or on state, and moving to the previous or
--- off state.
---
---@class ToggleOption: Option
---@field set_next_state fun(self: ToggleOption) Sets the next state.
---@field set_prev_state fun(self: ToggleOption) Sets the previous state.
---@field toggle_state fun(self: ToggleOption) Toggles the state.

--- An enum option is an option which states can be enumerated upon.
---
--- This is useful for UI controls that show available states.
---
---@class EnumOption: ToggleOption
---@field get_available_states fun(self: EnumOption): table<OptionState> Returns the available states.

--- Shows option state.
---
--- This function is meant to provide a uniform way of showing an option state.
---
---@param state number|boolean|string
---@return string
M.show_option_state = function(state)
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

---@class EnumOptionParams
---@field name string A human-readable identifier for the option.
---@field states table<OptionState> An ordered list of possible values.
---@field get_state fun(): OptionState Returns the option’s current state.
---@field set_state fun(state: OptionState) Sets the option’s state to the given value.
---@field toggle_behavior? "cycle" | "min" | "max" (default "cycle") The behavior when toggling.

--- Creates a new enum option.
---
---@param params EnumOptionParams
---@return ToggleOption
M.EnumOption = function(params)
  local toggle_behavior = params.toggle_behavior or "cycle"
  local state_to_idx = {}
  for pos, value in ipairs(params.states) do
    state_to_idx[value] = pos
  end

  local get_current_index = function()
    local current_state = params.get_state()
    local current_index = state_to_idx[current_state]
    return current_index
  end

  local get_current_index_or_warn = function()
    local current_index = get_current_index()
    if not current_index then
      local current_state = params.get_state()
      vim.notify(
        "Could not get current state’s (" .. current_state .. ") index for " .. params.name,
        vim.log.levels.ERROR,
        { title = "Toggle.nvim" }
      )
    end
    return current_index
  end

  local index_before_toggle = get_current_index()

  return {
    name = params.name,
    get_available_states = function(_)
      return params.states
    end,
    get_state = function(_)
      return params.get_state()
    end,
    set_state = function(_, state)
      params.set_state(state)
    end,
    set_next_state = function(self)
      local current_index = get_current_index_or_warn()
      if not current_index then
        return
      end

      if current_index == #params.states then
        return
      end

      local new_state = params.states[current_index + 1]
      self:set_state(new_state)
    end,
    set_prev_state = function(self)
      local current_index = get_current_index_or_warn()
      if not current_index then
        return
      end

      if current_index == 1 then
        return
      end

      local new_state = params.states[current_index - 1]
      self:set_state(new_state)
    end,
    toggle_state = function(self)
      local current_index = get_current_index_or_warn()
      if not current_index then
        return
      end

      local next_index
      if toggle_behavior == "cycle" then
        next_index = (current_index % #params.states) + 1
      elseif toggle_behavior == "min" then
        if current_index == 1 and index_before_toggle ~= nil and index_before_toggle ~= 1 then
          next_index = index_before_toggle
        elseif current_index > 1 then
          index_before_toggle = current_index
          next_index = 1
        end
      elseif toggle_behavior == "max" then
        if current_index == #params.states and index_before_toggle ~= nil and index_before_toggle ~= #params.states then
          next_index = index_before_toggle
        elseif current_index < #params.states then
          index_before_toggle = current_index
          next_index = #params.states
        end
      end

      if next_index == nil then
        return
      end

      local new_state = params.states[next_index]
      self:set_state(new_state)
    end,
  }
end

--- An option that can be toggled on and off.
---@class OnOffOption
---@field name string A human-readable identifier for the option.
---@field get_state fun(): boolean Returns the option’s current state.
---@field set_state fun(state: boolean) Sets the option’s state to the given value.

--- Creates a new on-off option.
---
---@param on_off_option OnOffOption
---@return ToggleOption
M.OnOffOption = function(on_off_option)
  return {
    name = on_off_option.name,
    get_state = function(_)
      return on_off_option.get_state()
    end,
    set_state = function(_, val)
      on_off_option.set_state(val)
    end,
    set_next_state = function(self)
      if not self:get_state() then
        local new_state = true
        self:set_state(new_state)
      end
    end,
    set_prev_state = function(self)
      if self:get_state() then
        local new_state = false
        self:set_state(new_state)
      end
    end,
    toggle_state = function(self)
      local new_state = not on_off_option.get_state()
      self:set_state(new_state)
    end,
  }
end

---@class NotifyOnSetParams
---@field notify? fun(message: string, level: number, opts: any?) A function that sends a notification. Defaults to vim.notify.

--- An option decorator that notifies on option toggle actions.
---
---@generic T : Option
---@param option T
---@param params? NotifyOnSetParams Optional parameters for the notification.
---@return T
M.NotifyOnSetOption = function(option, params)
  local notify = (params ~= nil and params.notify)
    or function(...)
      -- It’s important that we bind vim.notify dynamically, because it’s often monkey-patched.
      vim.notify(...)
    end

  local new_option = require("toggle.table-extra").shallow_copy(option)
  new_option.set_state = function(_, desired_state)
    ---@diagnostic disable-next-line: undefined-field
    local old_state = option:get_state()
    ---@diagnostic disable-next-line: undefined-field
    option:set_state(desired_state)
    ---@diagnostic disable-next-line: undefined-field
    local new_state = option:get_state()
    if new_state ~= old_state then
      notify(
        "Set " ---@diagnostic disable-next-line: undefined-field
          .. option.name
          .. " to "
          .. M.show_option_state(new_state),
        vim.log.levels.INFO,
        { title = "Toggle.nvim" }
      )
    end
  end
  return new_option
end

return M
