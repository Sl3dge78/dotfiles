vim.pack.add({
        { 
            src = "https://github.com/catppuccin/nvim",
            name = "catppuccin",
        },
        { 
            src = "https://github.com/ellisonleao/gruvbox.nvim",
        },
        'https://github.com/kdheepak/lazygit.nvim',
        'https://github.com/tpope/vim-dispatch',
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/nvim-telescope/telescope.nvim',
        {   
            src = 'https://github.com/rluba/jai.vim',
        },
        'https://github.com/ziglang/zig.vim',
        'https://github.com/rust-lang/rust.vim',
        'https://github.com/tikhomirov/vim-glsl',
        'https://github.com/rmagatti/auto-session',
        'https://github.com/sheerun/vim-polyglot',
        'https://github.com/echasnovski/mini.nvim',
        'https://github.com/rmagatti/auto-session',
        "https://github.com/karb94/neoscroll.nvim",
        "https://github.com/teal-language/vim-teal",
})

if vim.g.neovide then
    vim.o.guifont = "Source Code Pro:h11"
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
vim.cmd('autocmd BufEnter * set formatoptions-=cro')
-- vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')


vim.api.nvim_set_option("clipboard", "unnamedplus")

require('editorconfig').properties.makeprg = function(bufnr, val, opts)
    vim.print('makeprg = ' .. val)
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
    transparent = true,
    bold = false,
    -- italic = {
    --     strings = false,
    --     emphasis = false,
    --     comments = false,
    --     folds = false,
    -- },
    contrast="",
})
vim.cmd.colorscheme("gruvbox")

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

local jai_location = "/home/sl3dge/Downloads/jai/modules/"

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

function live_grep_from_project_git_root()
	local function is_git_repo()
		vim.fn.system("git rev-parse --is-inside-work-tree")

		return vim.v.shell_error == 0
	end

	local function get_git_root()
		local dot_git_path = vim.fn.finddir(".git", ".;")
		return vim.fn.fnamemodify(dot_git_path, ":h")
	end

	local opts = {}

	if is_git_repo() then
		opts = {
			cwd = get_git_root(),
		}
	end

	require("telescope.builtin").live_grep(opts)
end

vim.keymap.set('n', '<F1>', telescope.git_files, { desc = "Telescope find files" })
vim.keymap.set('n', '<F2>', live_grep_from_project_git_root, { desc = "" })
vim.keymap.set('n', '<F3>', telescope.grep_string, { desc = "Telescope grep string" })
vim.keymap.set('n', '<F4>', jai_grep, { desc = "Grep jai" })

-- LSP
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
vim.lsp.config('csharp_ls', {
    cmd = {"csharp-ls"},
    on_attach = on_attach,
})
vim.lsp.config('clangd', {
    on_attach = on_attach,
})
-- lspconfig['jails'].setup {
--     on_attach = on_attach,
--     cmd = { "jails" },
-- }

-- require('telescope').setup{ file_ignore_patterns = { "Library" } }
require('mini.completion').setup({
    delay = { completion = 10^7 }
})
require('auto-session').setup()
