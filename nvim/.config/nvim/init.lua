vim.g.mapleader = ','
vim.g.maplocalleader = ','

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'folke/which-key.nvim',
    'folke/todo-comments.nvim',
    'tpope/vim-sleuth',

    { 'jbyuki/nabla.nvim' },
    { 'synaptiko/xit.nvim' },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim', opts = {} },
            'folke/lazydev.nvim',
        },
    },

    { 'tpope/vim-fugitive' },
    { 'lewis6991/gitsigns.nvim', config = true },

    { 'catppuccin/nvim', name = 'catppuccin' },

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'rafamadriz/friendly-snippets',
        },
    },

    { 'numToStr/Comment.nvim', opts = {} },

    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
            { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
        },
    },

    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nvim-treesitter/nvim-treesitter-context',
        },
        build = ':TSUpdate',
    },

    { 'Darazaki/indent-o-matic', opts = { standard_widths = { 2, 4 }, skip_multiline = true } },
})

vim.cmd.colorscheme("catppuccin")

vim.o.hlsearch = true
vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.shiftwidth = 4
vim.o.fileencoding = 'utf-8'
vim.o.termguicolors = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = 'yes'

local utils = require("telescope.utils")
local builtin = require("telescope.builtin")
local live_grep_args = require("telescope").extensions.live_grep_args.live_grep_args

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sc', function()
    builtin.find_files({ cwd = utils.buffer_dir() })
end, { desc = '[S]earch [C]urrent Directory' })

vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sm', builtin.man_pages, { desc = '[S]earch [M]an pages' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', live_grep_args, { desc = '[S]earch by [G]rep' })

-- Journal access
function open_journal()
    local date_str = os.date("%Y-%m-%d")
    local file_path = string.format("~/projects/mka2/life/diary/%s.txt", date_str)
    file_path = vim.fn.expand(file_path)
    vim.cmd(string.format("edit %s", file_path))
end
vim.api.nvim_set_keymap("n", "<leader>nj", ":lua open_journal()<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local builtin = require('telescope.builtin')

    local function nmap(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', function()
      vim.lsp.buf.code_action {
        context = { only = { 'quickfix', 'refactor', 'source' } }
      }
    end, '[C]ode [A]ction')

    nmap('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', builtin.lsp_references, '[G]oto [R]eferences')
    nmap('gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>gl', vim.diagnostic.open_float, 'Diagnostics Float')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format buffer' })
  end,
})

require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = { 'lua_ls', 'rust_analyzer', 'clangd', 'zls', 'marksman', 'verible' },
    automatic_installation = true,
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require("lspconfig")

local servers = {
    lua_ls = {
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    },
    zls = {
        cmd = { '/Users/ofek/.zigup/current/zls' },
    },
    glsl_ls = {
        filetypes = { 'glsl', 'vert', 'frag', 'geom', 'comp', 'tesc', 'tese' },
    },
}

for name, config in pairs(servers) do
    config.capabilities = capabilities
    lspconfig[name].setup(config)
end

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  callback = function()
    vim.wo.cursorline = true
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  callback = function()
    vim.wo.cursorline = false
  end,
})
