local toggle = require("toggle")

describe("setup", function()
  it("works", function()
    toggle.setup({ register_keymaps = function() end })
  end)
end)
