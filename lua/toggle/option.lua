--- A module for Toggle options.
---
---@module "toggle.option"
local M = {}

---@alias OptionState string|number|boolean

--- A generic option.
---
---@class Option
---@field name string A human-readable identifier for the option.
---@field get_state fun(self: Option): any Returns the current state.
---@field set_state fun(self: Option, state: any) Sets the option’s state to the given value.

---@class KeymapUI
---@field desc     string        A description of the keymap.
---@field desc_fn? fun(): string A dynamic description of the keymap.
---@field icon     any           A static icon for the keymap.
---@field icon_fn? fun(): any    A dynamic icon for the keymap.

M.icon_off = {
  icon = "",
  color = "red",
}

M.icon_on = {
  icon = "",
  color = "green",
}

---@class ToggleOptionUI
---@field set_next_state_ui KeymapUI UI metadata for the set next state action.
---@field set_prev_state_ui KeymapUI UI metadata for the set prev state action.
---@field toggle_state_ui   KeymapUI UI metadata for the toggle state action.

M.empty_toggle_option_ui = {
  set_next_state_ui = {
    desc = "",
    icon = "",
  },
  set_prev_state_ui = {
    desc = "",
    icon = "",
  },
  toggle_state_ui = {
    desc = "",
    icon = "",
  },
}

--- An option that can act as a toggle.
---
--- A toggle has esentially three affordances: toggling, moving to the next or on state, and moving to the previous or
--- off state.
---
---@class ToggleOption: Option
---@field set_next_state fun(self: ToggleOption) Sets the next state.
---@field set_prev_state fun(self: ToggleOption) Sets the previous state.
---@field toggle_state fun(self: ToggleOption) Toggles the state.
---@field toggle_ui ToggleOptionUI UI metadata for the toggle.

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
---@param state OptionState
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
---@field states table<any> An ordered list of possible values.
---@field get_state fun(): any Returns the option’s current state.
---@field set_state fun(state: any) Sets the option’s state to the given value.
---@field toggle_behavior? "cycle" | "min" | "max" (default "cycle") The behavior when toggling.
---@field toggle_ui? ToggleOptionUI UI metadata for the toggle.

--- Creates a new enum option.
---
---@param params EnumOptionParams
---@return EnumOption
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

  local default_toggle_ui = {
    set_next_state_ui = {
      desc = "Set next state of " .. params.name,
      icon = "",
    },
    set_prev_state_ui = {
      desc = "Set previous state of " .. params.name,
      icon = "",
    },
    toggle_state_ui = {
      desc = "Toggle " .. params.name,
      icon = "",
    },
  }

  local toggle_ui = vim.tbl_deep_extend("force", default_toggle_ui, params.toggle_ui or {})

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
    toggle_ui = toggle_ui,
  }
end

--- An option that can be toggled on and off.
---
---@class OnOffOptionParams
---@field name string A human-readable identifier for the option.
---@field get_state fun(): boolean Returns the option’s current state.
---@field set_state fun(state: boolean) Sets the option’s state to the given value.

--- Creates a new on-off option.
---
---@param on_off_option OnOffOptionParams
---@return EnumOption
M.OnOffOption = function(on_off_option)
  local icon_fn = function()
    if on_off_option.get_state() then
      return M.icon_off
    else
      return M.icon_on
    end
  end

  return M.EnumOption({
    name = on_off_option.name,
    states = { false, true },
    get_state = function()
      return on_off_option.get_state()
    end,
    set_state = function(val)
      on_off_option.set_state(val)
    end,
    toggle_ui = {
      set_next_state_ui = {
        desc = "Turn on " .. on_off_option.name,
        icon = M.icon_on,
      },
      set_prev_state_ui = {
        desc = "Turn off " .. on_off_option.name,
        icon = M.icon_off,
      },
      toggle_state_ui = {
        desc = "Toggle " .. on_off_option.name,
        desc_fn = function()
          if on_off_option.get_state() then
            return "Turn off " .. on_off_option.name
          else
            return "Turn on " .. on_off_option.name
          end
        end,
        icon = M.icon_on,
        icon_fn = icon_fn,
      },
    },
  })
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
