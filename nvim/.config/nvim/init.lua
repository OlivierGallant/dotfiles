-- ======================
-- Minimal Neovim config
-- ======================

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basics
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 6

-- Wayland provider (no blocking)
if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 and vim.env.WAYLAND_DISPLAY then
	vim.g.clipboard = {
		name = "wl-clipboard (safe)",
		copy = {
			["+"] = { "wl-copy", "--type", "text/plain" }, -- CLIPBOARD
			["*"] = { "wl-copy", "--primary", "--type", "text/plain" }, -- PRIMARY
		},
		paste = {
			["+"] = { "wl-paste", "--no-newline" },
			["*"] = { "wl-paste", "--primary", "--no-newline" },
		},
		cache_enabled = 1,
	}
	-- Use the + register (CLIPBOARD) for all yanks/deletes/puts by default:
	vim.opt.clipboard = "unnamedplus"
end

-- Keymaps
local map = vim.keymap.set
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlights" })

-- Navigate between splits (tmux-style)
map("n", "<C-h>", "<C-w>h", { desc = "Focus split ←" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus split ↓" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus split ↑" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus split →" })

-- (Alt/HJKL as secondary option – matches what you used earlier)
map("n", "<A-h>", "<C-w>h", { desc = "Focus split ←" })
map("n", "<A-j>", "<C-w>j", { desc = "Focus split ↓" })
map("n", "<A-k>", "<C-w>k", { desc = "Focus split ↑" })
map("n", "<A-l>", "<C-w>l", { desc = "Focus split →" })

-- Create / close / equalize
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>q", { desc = "Close split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })

-- Resize with arrows
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height", silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height", silent = true })
map("n", "<C-Left>", ":vertical resize -4<CR>", { desc = "Narrower", silent = true })
map("n", "<C-Right>", ":vertical resize +4<CR>", { desc = "Wider", silent = true })

-- Rotate/Move splits (handy when you want to reshuffle)
map("n", "<leader>sR", "<C-w>r", { desc = "Rotate splits" })
map("n", "<leader>sx", "<C-w>x", { desc = "Swap with next split" })

-- ========== Fast line jumps (+/- 5) ==========
-- Normal/visual: jump 5 lines and keep cursor column; center after move
map({ "n", "v" }, "<leader>j", "5jzz", { desc = "Jump +5 lines" })
map({ "n", "v" }, "<leader>k", "5kzz", { desc = "Jump -5 lines" })

-- Bonus: half-page moves that keep cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (center)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (center)" })
-- ======================
-- Plugins: lazy.nvim
-- ======================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({
	-- Theme
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("gruvbox")
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({ options = { theme = "gruvbox" } })
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "vim", "bash", "python" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Telescope (finder)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			map("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
			map("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
			map("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
			map("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
		end,
	},

	-- Comments
	{ "numToStr/Comment.nvim", config = true },

	-- Git signs
	{ "lewis6991/gitsigns.nvim", config = true },

	-- which-key
	{ "folke/which-key.nvim", opts = { delay = 100 } },
})

-- =========================
-- which-key config
-- =========================

-- which-key v3+ flat spec
pcall(function()
	local wk = require("which-key")
	wk.add({
		-- Groups (prefix-only)
		{ "<leader>b", group = "Buffers" },
		{ "<leader>f", group = "Find" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>s", group = "Splits" },

		-- Buffers
		{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
		{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next Buffer" },
		{ "<leader>bp", "<cmd>bprevious<cr>", desc = "Prev Buffer" },

		-- Find (Telescope)
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },

		-- Splits
		{ "<leader>sv", desc = "Split vertical" },
		{ "<leader>sh", desc = "Split horizontal" },
		{ "<leader>sc", desc = "Close split" },
		{ "<leader>se", desc = "Equalize splits" },
		{ "<leader>sR", desc = "Rotate splits" },
		{ "<leader>sx", desc = "Swap with next split" },

		-- Jumps (show under leader even though not a 'group')
		{ "<leader>j", desc = "Jump +5 lines" },
		{ "<leader>k", desc = "Jump -5 lines" },
	})
end)
