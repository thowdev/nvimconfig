return {
  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}
  },

  -- Notify
  { "rcarriga/nvim-notify",
    opts = {
      timeout = 5000,
      stages = "static",
      render = "default",
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Column marker
  { "lukas-reineke/virt-column.nvim", opts = {} },
}
