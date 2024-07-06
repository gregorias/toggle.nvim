local test_helpers = require("tests.helpers")
local OnOffOption = require("toggle.option").OnOffOption
local option_registry = require("toggle.option-registry")

describe("toggle.option-registry", function()
  it("returns registered options", function()
    option_registry.register_option(OnOffOption({
      name = "test_option",
      get_state = function()
        return false
      end,
      set_state = function()
        return nil
      end,
    }))

    local options = option_registry.get_options()

    assert.is.True(options["test_option"] ~= nil)

    option_registry.unregister_option("test_option")
  end)

  it("returns buffer-specific options", function()
    local hi_bufnr = test_helpers.create_buf({ "hi" })
    local world_bufnr = test_helpers.create_buf({ "world" })
    option_registry.register_option(
      OnOffOption({
        name = "test_option_hi",
        get_state = function()
          return false
        end,
        set_state = function()
          return nil
        end,
      }),
      { bufnr = hi_bufnr }
    )

    local hi_options = option_registry.get_options(hi_bufnr)
    local world_options = option_registry.get_options(world_bufnr)

    assert.is.True(hi_options["test_option_hi"] ~= nil)
    assert.is.True(world_options["test_option_hi"] == nil)

    option_registry.unregister_option("test_option_hi", { buffer = hi_bufnr })

    vim.api.nvim_buf_delete(world_bufnr, {})
    vim.api.nvim_buf_delete(hi_bufnr, {})
  end)
end)
