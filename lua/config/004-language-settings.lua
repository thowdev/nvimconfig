----------------------------------------------------------------------------------------------------
--- Settings depending on filetype
----------------------------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup("LanguagSpecificSettings", { clear = true })

local settings = {
  c          = { margin = "81",  indent = 8, expand = false, conceallevel=0 },
  gitcommit  = { margin = "73",  indent = 4, expand = true, conceallevel=0 },
  go         = { margin = "101", indent = 4, expand = false, conceallevel=0 },
  lua        = { margin = "101", indent = 2, expand = true, conceallevel=0 },
  markdown   = { margin = "101",  indent = 2, expand = true, conceallevel=2 },
  python     = { margin = "81",  indent = 4, expand = true, conceallevel=0 },
  yaml       = { margin = "81",  indent = 2, expand = true, conceallevel=0 },
}

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    local ft = vim.bo.filetype
    local config = settings[ft] or { margin = "121", indent = 4, expand = true }

    local ok, virt_column = pcall(require, "virt-column")
    if ok then
      virt_column.setup({ virtcolumn = config.margin })
    end

    -- Vim Einrückungen setzen
    vim.opt_local.shiftwidth  = config.indent
    vim.opt_local.tabstop     = config.indent
    vim.opt_local.softtabstop = config.indent
    vim.opt_local.expandtab   = config.expand
    --- [[lua-202601271446[Lua config]]] >>
    vim.opt_local.conceallevel   = config.conceallevel

    if ft == "gitcommit" then
      vim.opt_local.textwidth = 72
    end
  end,
})

