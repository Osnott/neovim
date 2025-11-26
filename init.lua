-- opts

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"

-- keybinds

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<Up>', '<Nop>')
vim.keymap.set('n', '<Down>', '<Nop>')
vim.keymap.set('n', '<Left>', '<Nop>')
vim.keymap.set('n', '<Right>', '<Nop>')
vim.keymap.set('n', '<ESC>', ':noh<CR>')
vim.keymap.set('n', '<leader>th', ':split<CR><C-w>j | :terminal<CR>i')
vim.keymap.set('n', '<leader>tv', ':vsplit<CR><C-w>l | :terminal<CR>i')
vim.keymap.set('n', '<leader>h', ':split<CR><C-w>j')
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l')

-- plugs

vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range('*')
	},
	{ src = "https://github.com/tpope/vim-commentary" },
	{ src = "https://github.com/nvim-mini/mini.extra" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require "mini.pick".setup()
require "mini.extra".setup()
require "oil".setup()
require "blink.cmp".setup()
require "nvim-autopairs".setup()

-- plug keybinds

vim.keymap.set('n', '<leader>fm', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ff', ":Pick files<CR>")
vim.keymap.set('n', '<leader>fh', ":Pick help<CR>")
vim.keymap.set('n', '<leader>fz', ":Pick grep_live<CR>")
vim.keymap.set('n', '<leader>fw', ":Pick buf_lines<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set({ 'n', 'i' }, '<C-CR>', require('blink.cmp').accept)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
		vim.keymap.set('n', '<leader>fd', ":Pick diagnostic<CR>", opts)

		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end
})

-- lsp

vim.lsp.enable({ "lua_ls", "tinymist", "vtsls", "basedpyright", "nixd", "zls" })

-- etc

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "💡",
		}
	}
})
vim.cmd("colorscheme catppuccin-mocha")
vim.cmd("set completeopt+=noselect")
