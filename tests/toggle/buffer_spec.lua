local test_helpers = require("tests.helpers")
local buffer = require("toggle.buffer")

describe("toggle.buffer", function()
  describe("set_local_variable", function()
    it("errors on non-existent buffers", function()
      assert.has_error(function()
        buffer.set_local_variable(1234, "key", "value")
      end, "Invalid buffer number: 1234")
    end)

    it("Registers a variable and cleans it up.", function()
      local hi_bufnr = test_helpers.create_buf({ "hi" })
      local world_bufnr = test_helpers.create_buf({ "world" })

      buffer.set_local_variable(hi_bufnr, "test_var", 1)
      assert.are.same(buffer.get_local_variable(hi_bufnr, "test_var"), 1)
      assert.are_nil(buffer.get_local_variable(world_bufnr, "test_var"))

      vim.api.nvim_buf_delete(world_bufnr, {})
      vim.api.nvim_buf_delete(hi_bufnr, {})

      assert.are_nil(buffer.get_local_variable(hi_bufnr, "test_var"))
    end)
  end)
	describe("b", function ()
      local hi_bufnr = test_helpers.create_buf({ "hi" })

			buffer.b[hi_bufnr].test_var = 1
      assert.are.same(buffer.b[hi_bufnr].test_var, 1)
      assert.are.same(buffer.get_local_variable(hi_bufnr, "test_var"), 1)

      vim.api.nvim_buf_delete(hi_bufnr, {})
	end)
end)
