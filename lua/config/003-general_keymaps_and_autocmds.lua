--- Visualize trailing spaces at the end of a line
vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#af0000" })
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Position des Cursors speichern, damit er nicht springt
        local save_cursor = vim.fn.getpos(".")
        -- Löschen ausführen (silent und ohne Fehler, falls nichts da ist)
        vim.cmd([[%s/\s\+$//e]])
        -- Cursor zurücksetzen
        vim.fn.setpos(".", save_cursor)
    end,
})
