-- --------------- Bootstrap: lazy.nvim ---------------
local lazypath = vim.fn.stdpath("data").."/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------------- Core options ---------------
local o, wo, bo, g = vim.opt, vim.wo, vim.bo, vim.g
o.termguicolors = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.mouse = "a"
o.clipboard = ""        -- we override with Wayland provider below
o.updatetime = 200
o.timeoutlen = 400
o.completeopt = "menu,menuone,noselect"

-- Indentation defaults (change to 2 if preferred)
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = false

-- Performance/UI niceties
o.scrolloff = 6
o.sidescrolloff = 6
o.splitbelow = true
o.splitright = true

-- Wayland clipboard for Hyprland (requires wl-clipboard)
g.clipboard = {
  name = "wl-clipboard",
  copy = { ["+"] = {"wl-copy","--foreground","--type","text/plain"},
           ["*"] = {"wl-copy","--foreground","--primary","--type","text/plain"} },
  paste = { ["+"] = {"wl-paste","--no-newline"},
            ["*"] = {"wl-paste","--no-newline","--primary"} },
  cache_enabled = 1,
}

-- Leader (AZERTY-friendly): Space
g.mapleader = " "
g.maplocalleader = " "

-- --------------- Keymaps (AZERTY-friendly) ---------------
local map = vim.keymap.set
-- Basic
map({"n","v"}, "<Space>", "<Nop>", {silent=true})
map("i", "jk", "<Esc>", {desc="Exit insert"})
map("n", "<C-s>", ":w<CR>", {desc="Save"})
map("i", "<C-s>", "<Esc>:w<CR>a", {desc="Save"})

-- Window navigation with Alt+H/J/K/L (avoids symbols awkward on AZERTY)
map("n", "<A-h>", "<C-w>h", {desc="Focus left"})
map("n", "<A-j>", "<C-w>j", {desc="Focus down"})
map("n", "<A-k>", "<C-w>k", {desc="Focus up"})
map("n", "<A-l>", "<C-w>l", {desc="Focus right"})

-- Window management
map("n", "<leader>sv", "<C-w>v", {desc="Split vertical"})
map("n", "<leader>sh", "<C-w>s", {desc="Split horizontal"})
map("n", "<leader>q",  "<C-w>q", {desc="Close window"})
map("n", "<A-Up>",    ":resize +2<CR>", {silent=true})
map("n", "<A-Down>",  ":resize -2<CR>", {silent=true})
map("n", "<A-Left>",  ":vertical resize -4<CR>", {silent=true})
map("n", "<A-Right>", ":vertical resize +4<CR>", {silent=true})

-- Buffers (no number-row dependence)
map("n", "<leader>bn", ":bnext<CR>", {desc="Next buffer"})
map("n", "<leader>bp", ":bprevious<CR>", {desc="Prev buffer"})
map("n", "<leader>bd", ":bdelete<CR>", {desc="Delete buffer"})

-- System clipboard yanks/pastes
map({"n","v"}, "<leader>y", [["+y]], {desc="Yank to system clipboard"})
map("n", "<leader>Y", [["+Y]], {desc="Yank line to system clipboard"})
map({"n","v"}, "<leader>p", [["+p]], {desc="Paste from system clipboard"})

-- Indent stay-in-visual
map("v", "<", "<gv", {silent=true})
map("v", ">", ">gv", {silent=true})

-- --------------- Plugins ---------------
require("lazy").setup({
  -- UI/theme
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = function()
      vim.o.background = "dark"; vim.cmd.colorscheme("gruvbox")
    end
  },
  { "nvim-lualine/lualine.nvim", dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function() require("lualine").setup({options={theme="gruvbox"}}) end },

  -- Core dependencies
  "nvim-lua/plenary.nvim",

  -- Telescope (fuzzy finder)
  { "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" } ,
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc="Files"})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,  {desc="Grep (ripgrep)"})
      vim.keymap.set("n", "<leader>fb", builtin.buffers,    {desc="Buffers"})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags,  {desc="Help"})
    end
  },

  -- Treesitter (better syntax/indent)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua","vim","vimdoc","bash","python","json","yaml","toml","markdown","markdown_inline","cpp","c","javascript","typescript","html","css" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP + completion
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
  { "williamboman/mason-lspconfig.nvim",
    dependencies = {"neovim/nvim-lspconfig"},
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "tsserver", "bashls", "clangd", "gopls" },
        handlers = {
          function(server) lspconfig[server].setup({capabilities = capabilities}) end,
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = {"vim"} },
                  workspace = { checkThirdParty = false },
                }
              }
            })
          end
        }
      })

      -- LSP keymaps (buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          map("n", "gd", vim.lsp.buf.definition,  opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)
          map("n", "gi", vim.lsp.buf.implementation, opts)
          map("n", "gr", vim.lsp.buf.references,  opts)
          map("n", "K",  vim.lsp.buf.hover,       opts)
          map("n", "<leader>rn", vim.lsp.buf.rename, opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          map("n", "<leader>fd", function() vim.diagnostic.open_float() end, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)
          map("n", "<leader>f", function() vim.lsp.buf.format({async=true}) end, opts)
        end
      })
    end
  },
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
                              if cmp.visible() then cmp.select_next_item()
                              elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                              else fallback() end
                           end, {"i","s"}),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
                              if cmp.visible() then cmp.select_prev_item()
                              elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                              else fallback() end
                           end, {"i","s"}),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" }, { name = "buffer" }
        })
      })
    end
  },

  -- Quality-of-life
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },
  { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup() end },
  { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },
  { "folke/which-key.nvim", opts = {} },
})

-- Optional: show which-key hints after leader
require("which-key").register({
  f = { name = "files" },
  b = { name = "buffers" },
}, { prefix = "<leader>" })

