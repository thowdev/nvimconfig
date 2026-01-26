-- Check for < 0.11.x
if vim.version().minor < 11 then
    vim.notify("This config only supports Neovim 0.11+", vim.log.levels.ERROR)
    return
end

--- Load my options first
require("config.000-options")

--- Load lazy.nvim
require("config.001-lazy")

--- Load my colortheme-switcher
require("config.002-colortheme-switcher")

--- Load general keymappings
require("config.003-general_keymaps_and_autocmds")

--- Load language specific settings
require("config.004-language-settings")

--- Load my zettel system
require("config.005-zettelkasten")

----------------------------------------------------------------------------------------------------
---require("plugins")

---local config_path = vim.fn.stdpath("config") .. "/lua/config"
---local handle = vim.uv.fs_scandir(config_path)

---if handle then
    ---while true do
        ---local name, type = vim.uv.fs_scandir_next(handle)
        ---if not name then break end
---
        ---if type == "file" and name:match("%.lua$") then
            ---local module_name = name:gsub("%.lua$", "")
            ---if module_name ~= "plugins" then
                ---local ok, err = pcall(require, "config." .. module_name)
                ---if not ok then
                    ---if not err:match("module '.*' not found") then
                        ---vim.api.nvim_err_writeln("Error in " .. module_name .. ": " .. err)
                    ---end
                ---end
            ---end
        ---end
    ---end
---end

-- Fix for missing site path in Neovim 0.11
--local site_path = vim.fn.stdpath("data") .. "/site"
--if not vim.tbl_contains(vim.opt.rtp:get(), site_path) then
    --vim.opt.rtp:prepend(site_path)
--end

-- Load settings, must be before plugin loading because some of the plugins
-- could rely on these options (like colorschemes, ...)
--require("config.options")

-- Load Plugins
--require("config.lazy")

-- Load keymaps
--require("config.keymaps")
