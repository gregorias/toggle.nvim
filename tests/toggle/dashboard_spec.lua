local dashboard_m = require("toggle.dashboard")
local test_helpers = require("tests.helpers")
local OnOffOption = require("toggle.option").OnOffOption
local option_registry = require("toggle.option-registry")

describe("toggle.dashboard", function()
  describe("get_options_for_dashboard", function()
    it("returns sorted buffer-specific options", function()
      local world_bufnr = test_helpers.create_buf({ "world" })
      local hi_bufnr = test_helpers.create_buf({ "hi" })
      option_registry.register_option(
        OnOffOption({
          name = "btest_option_hi_local",
          get_state = function()
            return false
          end,
          set_state = function()
            return nil
          end,
        }),
        { bufnr = hi_bufnr }
      )
      option_registry.register_option(OnOffOption({
        name = "atest_option_hi",
        get_state = function()
          return false
        end,
        set_state = function()
          return nil
        end,
      }))

      local options = dashboard_m.get_options_for_dashboard()
      local option_names = vim.tbl_map(function(option)
        return option.name
      end, options)

			assert.are.same({ "atest_option_hi", "btest_option_hi_local" }, option_names)


      option_registry.unregister_option("test_option_hi", { buffer = hi_bufnr })
      vim.api.nvim_buf_delete(hi_bufnr, {})
      vim.api.nvim_buf_delete(world_bufnr, {})
    end)
  end)
end)
