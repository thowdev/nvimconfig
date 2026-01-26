----------------------------------------------------------------------------------------------------
--- LEADER KEY (MUST BE AT THE TOP)
----------------------------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

----------------------------------------------------------------------------------------------------
--- NVIM OPTIONS
----------------------------------------------------------------------------------------------------
local opt = vim.opt

opt.termguicolors = true    -- Activate 24-bit RGB colors in terminal
opt.background = "dark"     -- Choose dark version of themes

opt.title = true            -- Show filename as title
--opt.titlestring = "%t %m (%{fnamemodify(getcwd(), ':t')}) - %{v:progname}"
opt.clipboard = "unnamedplus"   -- Use plus register, OSC52 required for SSH copy/paste

opt.number = true           -- Line numbers
opt.relativenumber = true   -- Relative line numbers
opt.mouse = "a"             -- Mouse support (scroll, click)
opt.cursorline = true       -- Mark current line
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bold = true })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true, fg = "#ff9e64" })
  end,
})
opt.scrolloff = 4           -- Cursor relative position before starting scrolling
opt.wrap = true            -- No automatic wrapping of lines

opt.ignorecase = true       -- Search case-insensitive
opt.smartcase = true        -- ...except upper cases were typed
opt.hlsearch = true         -- Mark search results

opt.tabstop = 4             -- Tab = 4 spaces
opt.shiftwidth = 4          -- Indent = 4 spaces
opt.softtabstop = 4         -- Indent = 4 spaces
opt.expandtab = true        -- Change tabs to spaces
opt.smarttab = true         -- Use shiftwidth instead of tabstop at the beginning of a line
-- smartident isn't required anymore when treesitter is in use
-- opt.smartindent = true      -- Automatic indentation
-- colorcolumn replaced by virt-column
--opt.colorcolumn = "81,121"  --
--opt.colorcolumn = table.concat(vim.fn.range(81, 200), ",")
--opt.colorcolumn = table.concat(vim.fn.range(121, 200), ",")

opt.undofile = true         -- Remember all changes even after closing file
opt.undodir = vim.fn.stdpath("cache") .. "/undo//"
opt.undolevels = 10000      -- Default number of "saves" is 1000
opt.undoreload = 10000      -- Saved levels after external changes from e.g. git checkout

opt.swapfile = false    -- not required any more, undo is enough
opt.backup = false      -- not required any more, undo is enough
opt.writebackup = false -- no backup during writing

opt.updatetime = 250        -- Default of 4000 (ms) is too slow


-- Use osc52 as clipboard provider
if vim.env.SSH_CONNECTION then
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste, -- Hier nutzen wir den Fake-Paste (nur internes Register)
      ["*"] = paste,
    },
  }

else
end
