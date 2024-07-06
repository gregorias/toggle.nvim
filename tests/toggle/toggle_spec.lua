local test_helpers = require("tests.helpers")
local toggle = require("toggle")

describe("toggle", function()
  describe("setup", function()
    it("works", function()
      toggle.setup({ register_keymaps = function() end })
    end)

    it("configures keymap_prefixes", function()
      toggle.setup({ keymaps = { toggle_option_prefix = "top" } })

      local test_var = 0
      toggle.register("t", {
        name = "test",
        get_state = function()
          return test_var
        end,
        toggle_state = function()
          test_var = 1 - test_var
          return test_var
        end,
      }, { buffer = true })

      -- Toggle test. Execute immediately and use remapping.
      test_helpers.execute_keys("topt", "xm")

      -- Check that the buffer-local option has been triggered.
      assert.are.same(1, test_var)
    end)
  end)

  describe("register", function()
    it("respects buffer-local options for keymaps", function()
      toggle.setup()
      local hi_bufnr = test_helpers.create_buf({ "hi" })

      local test_var = 0
      toggle.register("t", {
        name = "test",
        get_state = function()
          return test_var
        end,
        toggle_state = function()
          test_var = 1 - test_var
          return test_var
        end,
      }, { buffer = true })

      -- Toggle test. Execute immediately and use remapping.
      test_helpers.execute_keys("yot", "xm")
      -- Check that the buffer-local option has been triggered.
      assert.are.same(1, test_var)

      -- Change buffer.
      local world_bufnr = test_helpers.create_buf({ "world" })
      -- Toggle test.
      test_helpers.execute_keys("yot", "xm")
      -- Check that the buffer-local option has not been triggered.
      assert.are.same(1, test_var)

      vim.api.nvim_buf_delete(world_bufnr, {})
      vim.api.nvim_buf_delete(hi_bufnr, {})
    end)
    it("registers options in the registry", function()
      toggle.setup()
      local hi_bufnr = test_helpers.create_buf({ "hi" })
      toggle.register("t", {
        name = "test",
        get_state = function()
          return false
        end,
        toggle_state = function()
          return nil
        end,
      }, { buffer = hi_bufnr })

      local option_registry = require("toggle.option-registry")
      local hi_options = option_registry.get_options(hi_bufnr)

      assert.is.True(hi_options["test"] ~= nil)

      vim.api.nvim_buf_delete(hi_bufnr, {})
    end)
  end)
end)
