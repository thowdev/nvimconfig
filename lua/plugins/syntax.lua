return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      configs.setup({
        ensure_installed = {
          "bash",
          "c",
          "html",
          "java",
          "javascript",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<TAB>",
            node_decremental = "<BS>",
          },
        },
      })
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local markview = require("markview")

      vim.keymap.set("n", "<leader>mv", "<cmd>Markview toggle<cr>", {
        desc = "Toggle Markview (Render Markdown)"
      })

      --- Disable markview by default
      local markview_fix = vim.api.nvim_create_augroup("MarkviewFix", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = markview_fix,
        pattern = "markdown",
        callback = function()
          vim.schedule(function()
            if vim.fn.exists(":Markview") > 0 then
              vim.cmd("Markview disable")
            end
          end)
        end,
      })
    end,
  },
}
