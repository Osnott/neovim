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

-- helpers

local function open_floating_window(bufnr)
	local width = math.floor(vim.o.columns * 0.80)
	local height = math.floor(vim.o.lines * 0.80)

	vim.api.nvim_open_win(bufnr, true,
		{
			relative = 'editor',
			width = width,
			height = height,
			col = (vim.o.columns - width) / 2,
			row = (vim.o.lines - height) / 2
		})
end

-- keybinds

vim.keymap.set('n', '<leader>o', ':update<CR>:source<CR>', { silent = true })
vim.keymap.set('n', '<Up>', '<Nop>')
vim.keymap.set('n', '<Down>', '<Nop>')
vim.keymap.set('n', '<Left>', '<Nop>')
vim.keymap.set('n', '<Right>', '<Nop>')
vim.keymap.set('n', '<ESC>', ':noh<CR>', { silent = true })
vim.keymap.set('n', '<leader>th', ':split | term<CR>i', { silent = true })
vim.keymap.set('n', '<leader>tv', ':vsplit | :term<CR>i', { silent = true })
vim.keymap.set('n', '<leader>h', ':split<CR><C-w>j', { silent = true })
vim.keymap.set('n', '<leader>v', ':vsplit<CR><C-w>l', { silent = true })
vim.keymap.set('n', '<leader>ns', function()
	vim.ui.input({ prompt = "Enter filetype for new scratch buffer: " }, function(input)
		if input then
			local bufnr = vim.api.nvim_create_buf(true, true)
			vim.api.nvim_win_set_buf(0, bufnr)
			-- vim.treesitter.start(bufnr, input)
			vim.api.nvim_buf_set_option(bufnr, 'filetype', input)
		end
	end)
end)

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
	{ src = "https://github.com/nvim-mini/mini.statusline" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = 'main',
	},
})

require "mini.pick".setup()
require "mini.extra".setup()
require "oil".setup()
require "blink.cmp".setup()
require "nvim-autopairs".setup()

-- plug keybinds

vim.keymap.set('n', '<leader>fm', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ff', ":Pick files<CR>", { silent = true })
vim.keymap.set('n', '<leader>fh', ":Pick help<CR>", { silent = true })
vim.keymap.set('n', '<leader>fz', ":Pick grep_live<CR>", { silent = true })
vim.keymap.set('n', '<leader>fw', ":Pick buf_lines<CR>", { silent = true })
-- vim.keymap.set('n', '<leader>fb', ":Pick buffers<CR>", { silent = true })
vim.keymap.set('n', '<leader>e', ":Oil<CR>", { silent = true })
vim.keymap.set({ 'n', 'i' }, '<C-CR>', require('blink.cmp').accept)
vim.keymap.set('n', '<leader>fb', function()
	local open_float_cur = function()
		open_floating_window(MiniPick.get_picker_matches().current.bufnr)
	end

	local buffer_mappings = { open_float = { char = '<S-CR>', func = open_float_cur } }

	require("mini.pick").builtin.buffers({ include_current = false }, { mappings = buffer_mappings })
end)

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

vim.lsp.config('tinymist', {
	settings = {
		formatterMode = "typstyle",
		formatterProseWrap = true,
		formatterPrintWidth = 80,
		formatterIndentSize = 2,
	}
})

vim.lsp.enable({ "lua_ls", "tinymist", "vtsls", "basedpyright", "nixd", "zls", "cssls", "rust_analyzer", "marksman" })

-- treesitter

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		-- highlights
		local hasStarted = pcall(vim.treesitter.start)

		-- indent
		local noIndent = {}
		if hasStarted and not vim.list_contains(noIndent, ctx.match) then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- statusline

require "mini.statusline".setup({
	content = {
		active = function()
			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
			local git           = MiniStatusline.section_git({ trunc_width = 40 })
			local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
			local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75, signs = { ERROR = ' ', WARN = ' ', INFO = ' ', HINT = ' ' } })
			local lsp           = MiniStatusline.section_lsp({ trunc_width = 120 })
			local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
			local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
			local location      = MiniStatusline.section_location({ trunc_width = 75 })
			local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

			return MiniStatusline.combine_groups({
				{ hl = mode_hl,                 strings = { mode } },
				{ hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
				'%<', -- Mark general truncate point
				{ hl = 'MiniStatuslineFilename', strings = { filename } },
				'%=', -- End left alignment
				{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
				{ hl = mode_hl,                  strings = { search, location } },
			})
		end
	},
})

-- etc

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		}
	}
})
vim.cmd("colorscheme catppuccin-mocha")
vim.cmd("set completeopt+=noselect")
