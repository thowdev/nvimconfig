local themes = {
    "gruvbox",
    "gruvbox-material",
    "catppuccin-latte",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "tokyonight-night",
    "tokyonight-storm",
    "tokyonight-day",
    "tokyonight-moon",
    "habamax", -- <<< vim default
}

local active_theme = "catppuccin-macchiato"

local function get_current_theme_index()
    local current = vim.g.colors_name or ""
    for i, name in ipairs(themes) do
        if name == current then
            return i
        end
    end
    return 0
end

local function cycle_themes()
    local index = get_current_theme_index()
    --- #themes = number of elements in themes
    index = (index % #themes) + 1

    local next_theme = themes[index]

    --- Clear colors and re-read/reset all rules
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    local ok, err = pcall(vim.cmd.colorscheme, next_theme)

    if ok then
        vim.schedule(function()
            vim.cmd("redraw")
            vim.notify("Active theme: " .. next_theme, vim.log.levels.INFO, {
                title = "Theme Switcher",
                render = "compact",
            })
        end)
    else
        vim.notify("Error switching to " .. next_theme .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
end

--- Load default theme here
local ok = pcall(vim.cmd.colorscheme, active_theme)
if not ok then
    vim.cmd.colorscheme("habamax")
end

-----------------------------------------------------------------------------------------------------------------------
--- Keymaps
-----------------------------------------------------------------------------------------------------------------------
--- Load default theme
vim.keymap.set("n", "<leader>td", function()
    --- Clear colors and re-read/reset all rules
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    vim.opt.background = "dark"
    vim.cmd.colorscheme("gruvbox")
    vim.notify("Active theme: " .. active_theme, vim.log.levels.INFO)
end, { desc = "Switch to gruvbox (clean)" })

--- Load go through theme list
vim.keymap.set("n", "<leader>tn", cycle_themes, { desc = "Next theme" })
