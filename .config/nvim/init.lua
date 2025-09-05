-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { 
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
        },
        { 
            "ellisonleao/gruvbox.nvim",
            priority = 1000,
        },
        'kdheepak/lazygit.nvim',
        'tpope/vim-dispatch',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        {   'rluba/jai.vim',
            lazy = false,
        },
        'ziglang/zig.vim',
        'rust-lang/rust.vim',
        'tikhomirov/vim-glsl',
        'rmagatti/auto-session',
        'sheerun/vim-polyglot',
        {
            "VonHeikemen/lsp-zero.nvim",
            branch = "v2.x",
            config = false,
            init = function()
                -- Disable automatic setup, we are doing it manually
                vim.g.lsp_zero_extend_cmp = 0
                vim.g.lsp_zero_extend_lspconfig = 0
            end,
        },
        { 
            'neovim/nvim-lspconfig',
            config = function () 
                local lsp = require("lsp-zero")
                local lspconfig = require("lspconfig")
                lsp.extend_lspconfig()

                local configs = require("lspconfig.configs")
                if not configs.jails then
                    configs.jails = {
                        default_config = {
                            cmd = { "jails" },
                            root_dir = lspconfig.util.root_pattern("jails.json", "build.jai", "main.jai"),
                            filetypes = { "jai" },
                            name = "Jails",
                        },
                    }
                end
                lspconfig.jails.setup({})

            end
        },
        'echasnovski/mini.nvim',
        'rmagatti/auto-session',
        "karb94/neoscroll.nvim",
    },
})

if vim.g.neovide then
    vim.o.guifont = "ProggyCleanTT:h12"
    vim.g.neovide_scroll_animation_length = 0.1
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_cursor_trail_size = 0.5
    vim.g.neovide_confirm_quit = false
end

vim.opt.signcolumn="number"

-- Tabs
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab=true
vim.opt.softtabstop=0

-- Indent
vim.opt.cindent=true
vim.opt.cinoptions="l1,b1" -- switch indentation
vim.opt.autoindent=true
vim.opt.breakindent=true -- indent word wraps
vim.opt.breakindentopt="shift:2,sbr"

-- Misc
vim.opt.autoread=true
vim.opt.autowrite=true
vim.opt.number=true
vim.opt.hlsearch=false


vim.api.nvim_set_option("clipboard", "unnamedplus")

require('editorconfig').properties.makeprg = function(bufnr, val, opts)
    vim.opt.makeprg=val
end


require("catppuccin").setup({
    flavour = "macchiato",
    no_bold = true,
    no_italic = true,
    dim_inactive = {
        enabled = true,
    },
})

require("gruvbox").setup({
    bold = false,
    italic = {
        strings = false,
        emphasis = false,
        comments = false,
        folds = false,
    },

})

require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-b>', '<C-f>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 0.1,   -- Global duration multiplier
  easing = 'cubic',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
      'WinScrolled', 'CursorMoved'
  },
})

vim.cmd.colorscheme("gruvbox")

-- Resize windows
vim.keymap.set('n', '<C-Up>', '<C-w>+')
vim.keymap.set('n', '<C-Down>', '<C-w>-')
vim.keymap.set('n', '<C-Left>', '<C-w><')
vim.keymap.set('n', '<C-Right>', '<C-w>>')

-- Looping cnext/cprev
vim.keymap.set('n', '<Leader>n', function(args) 
    if not pcall(vim.cmd, 'cnext') then 
        vim.cmd("cfirst") 
    end 
end , {})
vim.keymap.set('n', '<Leader>p', function(args)
    if not pcall(vim.cmd, "cprev") then
        vim.cmd("clast")
    end
end , {})

-- C
vim.api.nvim_create_autocmd("FileType", {
    pattern = "c,cpp",
    callback = function (args) 
        vim.opt.makeprg="cmake --build build"
        vim.opt.efm="%f:%l:%c:%m"
        vim.opt.commentstring="// %s"
    end
})

-- JAI
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = "*.jai",
    callback = function(e) 
        vim.opt.filetype="jai"
        vim.opt.efm = [[%f:%l\,%c: %m]]
            -- "%f:%l,%c: Error: %m",
            -- "%f:%l,%c: %m",
            -- "%m (%f:%l)"
        vim.opt.commentstring="// %s"
    end
});

local jai_location = "/opt/jai/modules/"

function jai_search(args)
    for k, v in ipairs(args) do
        print(k.." = "..v)
    end
    vim.cmd.vimgrep({ args = { "/"..args.args.."/", jai_location.."**/*.jai"}})
end
vim.api.nvim_create_user_command("JaiFind", jai_search, { nargs = 1 })


-- Telescope
local telescope = require('telescope.builtin')

function jai_grep()
    telescope.live_grep({ cwd = jai_location })
end

vim.keymap.set('n', '<F1>', telescope.git_files, { desc = "Telescope find files" })
vim.keymap.set('n', '<F2>', telescope.live_grep, { desc = "Telescope live grep" })
vim.keymap.set('n', '<F3>', telescope.grep_string, { desc = "Telescope grep string" })
vim.keymap.set('n', '<F4>', jai_grep, { desc = "Grep jai" })

-- LSP
local lspconfig = require('lspconfig')
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- run : `dotnet tool install --global csharp-ls`
-- https://github.com/razzmatazz/csharp-language-server
lspconfig['csharp_ls'].setup {
    cmd = {"csharp-ls"},
    on_attach = on_attach,
}
lspconfig['clangd'].setup{
    on_attach = on_attach,
}
lspconfig['jails'].setup {
    on_attach = on_attach,
    cmd = { "jails" },

}

-- require('telescope').setup{ file_ignore_patterns = { "Library" } }
require('mini.completion').setup({
    delay = { completion = 10^7 }
})
require('auto-session').setup()
