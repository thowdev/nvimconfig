return {
  -- File browser
  { "stevearc/oil.nvim", opts = {} },

  -- Search tool (files, grep/ripgrep)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({
        files = {
          formatter = "path.filename_first",
          git_icons = true,
          file_icons = true,
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>zz", fzf.files, { desc = "FZF: Search files" })
      vim.keymap.set("n", "<leader>zg", fzf.live_grep, { desc = "FZF: Grep in files" })

      -- Insert link (search file and writes [name](name) at cursor)
      -- Insert-Mode: Ctrg-x + Ctrg-f
      vim.keymap.set("i", "<C-x><C-f>", function()
        fzf.files({
          actions = {
            ["default"] = function(selected)

              local first_line = true

              --- Save full_path without icons etc.
              local entry = fzf.path.entry_to_file(selected[1])
              local full_path = entry.path

              --- Extract ID without .md suffix or path
              local id = vim.fn.fnamemodify(full_path, ":t:r")

              --- Extract title
              local title = ""
              local f = io.open(full_path, "r")

              if not f then return nil end

              for line in f:lines() do
                local match = line:match("^%s*title:%s*[\"']?(.-)[\"']?%s*$")
                if match then
                  title = match
                  break
                end
                --- Break at end of frontmatter
                if line:match("^%s*---%s*$") then
                  if first_line then
                    first_line = false -- Wir "entschärfen" die Falle für Zeile 1
                  else
                    break -- Jetzt darf es abbrechen
                  end
                end
              end
              f:close()

              local link
              if title ~= "" and title ~= id then
                link = "[[" .. id .. "|" .. title .. "]]"
              else
                link = "[[" .. id .. "]]"
              end

              vim.api.nvim_put({ link }, "c", true, true)
            end,
          },
        })
      end, { desc = "FZF: Insert markdown link" })
    end,
  },

  -- Useful
  {
    "https://codeberg.org/andyg/leap.nvim",
    config = function()
      local leap = require("leap")

      leap.setup({})

      -- Bidirectional for Normal and Visual mode
      vim.keymap.set({ "n", "x" }, "s", "<Plug>(leap)")
      -- Forward and Backward for Operator mode (e.g. "d" for deletion)
      vim.keymap.set("o", "s", "<Plug>(leap-forward)")
      vim.keymap.set("o", "S", "<Plug>(leap-backward)")

      -- Autocmd for theme-switch (reset)
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, 'LeapMatch', { fg = '#fabd2f', bold = true, underline = true })
          vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = '#fe8019', bold = true })
        end
      })

      -- Colorize matches and the labels
      vim.api.nvim_set_hl(0, 'LeapMatch', { fg = '#fabd2f', bold = true, underline = true })
      vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = '#fe8019', bold = true })
    end,
  },

  -- Automatisches Schließen von Klammern
  { "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Undo history browser
  { "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
        { "<leader>u", function() require('undotree').toggle() end, desc = "Undo Tree" },
    },
    opts = {
        float_diff = true, -- extra window
        layout = "left",   -- ... on the left
        ignore_filetypes = { 'undotree', 'diff', 'fugitive', 'fugitiveblame' },
    },
  },

  -- Better bullet handling
  {
  "dkarter/bullets.vim",
  ft = { "markdown", "text", "gitcommit" },
  init = function()
    vim.g.bullets_set_mappings = 0
    vim.g.bullets_enabled_file_types = { 'markdown', 'text', 'gitcommit' }
  end,
  config = function()
    vim.keymap.set("i", "<CR>", "<Plug>(bullets-newline)", { remap = true, buffer = true })
    vim.keymap.set("n", "o", "<Plug>(bullets-newline)", { remap = true, buffer = true })
  end,
}
}
