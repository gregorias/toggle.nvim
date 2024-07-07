local option_m = require("toggle.option")
describe("toggle.option", function()
  describe("show_option_state", function()
    it("shows the state of an option", function()
      assert.are.same("1", option_m.show_option_state(1))
      assert.are.same("ON", option_m.show_option_state(true))
      assert.are.same("OFF", option_m.show_option_state(false))
      assert.are.same("foo", option_m.show_option_state("foo"))
    end)
  end)
  describe("OnOffOption", function()
    it("behaves like an on-off option", function()
      local state = false
      local on_off_option = option_m.OnOffOption({
        name = "test",
        get_state = function()
          return state
        end,
        set_state = function(new_state)
          state = new_state
        end,
      })

      assert.is.False(on_off_option.get_state())
      assert.is.True(on_off_option.set_next_state())
      assert.are.same(true, state)
      assert.are.same(nil, on_off_option.set_next_state())
      assert.are.same(true, state)
      assert.are.same(false, on_off_option.set_prev_state())
      assert.are.same(false, state)
      assert.are.same(nil, on_off_option.set_prev_state())
      assert.are.same(false, state)
      assert.are.same(true, on_off_option.toggle_state())
      assert.are.same(true, state)
      assert.are.same(false, on_off_option.toggle_state())
      assert.are.same(false, state)
    end)
  end)
  describe("SliderOption", function()
    it("behaves like a cycle slider option", function()
      local state = 1
      local slider_option = option_m.SliderOption({
        name = "test",
        values = { 1, 2, 3 },
        get_state = function()
          return state
        end,
        set_state = function(new_state)
          state = new_state
        end,
        toggle_behavior = "cycle",
      })

      assert.are.same(1, slider_option.get_state())
      assert.are.same(2, slider_option.set_next_state())
      assert.are.same(2, state)
      assert.are.same(3, slider_option.set_next_state())
      assert.are.same(3, state)
      assert.are.same(nil, slider_option.set_next_state())
      assert.are.same(3, state)
      assert.are.same(2, slider_option.set_prev_state())
      assert.are.same(2, state)
      assert.are.same(1, slider_option.set_prev_state())
      assert.are.same(1, state)
      assert.are.same(nil, slider_option.set_prev_state())
      assert.are.same(1, state)
      assert.are.same(2, slider_option.toggle_state())
      assert.are.same(2, state)
      assert.are.same(3, slider_option.toggle_state())
      assert.are.same(3, state)
      assert.are.same(1, slider_option.toggle_state())
      assert.are.same(1, state)
    end)

    it("behaves like a min slider option", function()
      local state = 3
      local slider_option = option_m.SliderOption({
        name = "test",
        values = { 1, 2, 3, 4 },
        get_state = function()
          return state
        end,
        set_state = function(new_state)
          state = new_state
        end,
        toggle_behavior = "min",
      })

      assert.are.same(1, slider_option.toggle_state())
      assert.are.same(1, state)
      assert.are.same(3, slider_option.toggle_state())
      assert.are.same(3, state)
      assert.are.same(1, slider_option.toggle_state())
      assert.are.same(1, state)
      assert.are.same(3, slider_option.toggle_state())
      assert.are.same(3, state)
    end)

    it("behaves like a max slider option", function()
      local state = 3
      local slider_option = option_m.SliderOption({
        name = "test",
        values = { 1, 2, 3, 4 },
        get_state = function()
          return state
        end,
        set_state = function(new_state)
          state = new_state
        end,
        toggle_behavior = "max",
      })

      assert.are.same(4, slider_option.toggle_state())
      assert.are.same(4, state)
      assert.are.same(3, slider_option.toggle_state())
      assert.are.same(3, state)
      assert.are.same(4, slider_option.toggle_state())
      assert.are.same(4, state)
      assert.are.same(3, slider_option.toggle_state())
      assert.are.same(3, state)
    end)
  end)

  describe("NotifyOnSetOption", function()
    it("notifies on changes", function()
      local state = 1
      local option = {
        name = "test",
        get_state = function()
          return 1
        end,
        set_next_state = function()
          return 2
        end,
        set_prev_state = function()
          return 1
        end,
        toggle_state = function()
          return (2 - state) + 1
        end,
      }
      local message = ""
      local notify_on_set_option = option_m.NotifyOnSetOption(option, {
        notify = function(msg)
          message = msg
        end,
      })

      notify_on_set_option.set_next_state()
      assert.are.same(message, "Set test to 2")
      notify_on_set_option.set_prev_state()
      assert.are.same(message, "Set test to 1")
      notify_on_set_option.toggle_state()
      assert.are.same(message, "Set test to 2")
    end)
    it("stays silent on no changes", function()
      local option = {
        name = "test",
        get_state = function()
          return 1
        end,
        set_next_state = function()
          return nil
        end,
        set_prev_state = function()
          return nil
        end,
        toggle_state = function()
          return nil
        end,
      }
      local message = ""
      local notify_on_set_option = option_m.NotifyOnSetOption(option, {
        notify = function(msg)
          message = msg
        end,
      })
      notify_on_set_option.set_next_state()
      assert.are.same(message, "")
      notify_on_set_option.set_prev_state()
      assert.are.same(message, "")
      notify_on_set_option.toggle_state()
      assert.are.same(message, "")
    end)
  end)
end)
