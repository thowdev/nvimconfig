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

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
	clangd = {
		cmd = { "clangd" },
		capabilities = capabilities,
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		capabilities = capabilities,
		settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
			},
		},
	},
	pyright = {
		cmd = { "pyright" },
		capabilities = capabilities,
	},
	tsserver = {
		cmd = { "tsserver" },
		capabilities = capabilities,
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		capabilities = capabilities,
	},
	bashls = {
		cmd = { "bash-language-server" },
		capabilities = capabilities,
		filetypes = { "sh", "bash", "zsh" },
	},
	gopls = {
		cmd = { "gopls" },
		capabilities = capabilities,
	},
}

for name, config in pairs(servers) do
	if Is_executable_in_path(config.cmd[1]) then
		vim.lsp.config[name] = config
		vim.lsp.enable(name)
	end
end

vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
})

-- nvim-cmp: completion engine plugin for neovim
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
		-- C-b (back) C-f (forward) for snippet placeholder navigation.
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["TAB"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		-- Shift + Tab
		["S-TAB"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
	},
})

