-- ハイブリッド行番号 (カレント行は絶対行番号、それ以外は相対行番号)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "v" -- ビジュアルモード以外ではマウスのポップアップは無し

-- スペースとタブの区別
vim.opt.list = true
vim.opt.listchars = {
    tab = '>>-',
    trail = '∙', -- 行末スペースはU+2219
    space = '⋅' -- 半角スペースはU+22C5
}

-- インデントとタブ
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.api.nvim_create_autocmd("FileType", {
    pattern = "make",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.preserveindent = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- クリップボードの共有
vim.opt.clipboard = "unnamedplus"

-- その他
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.updatetime = 300


local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- インサートモード中に @@ でノーマルモードに戻る
keymap('i', '@@', '<Esc>', opts)

-- ノーマルモード時に Esc 2回でハイライトを消す
keymap('n', '<Esc><Esc>', ':<C-u>nohlsearch<CR>', opts)


-- 見た目の設定
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"


-- ターミナルモードからノーマルモードへの復帰
keymap('t', '<Esc>', '<C-\\><C-n>', opts)


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "Mofiqul/vscode.nvim",
        lazy = false, 
        priority = 1000,
        config = function()
            require("vscode").setup({
                style="dark",
                transparent = false,
                italic_comments = false,
                disable_nvim_tree_bg = true,
            })
            vim.lsp.handlers["textDocument/semanticTokens/full"] = vim.lsp.handlers["textDocument/semanticTokens/full"]
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {"cpp", "c", "cuda", "lua", "vim", "vimdoc", "query" },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter").setup(opts)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies={
            "hrsh7th/cmp-nvim-lsp",
        },
        --event = { "BufReadPre", "BufNewFile" },
        config = function()
            local server_config = vim.lsp.config["clangd"] or {}
            server_config.cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "--header-insertion=never",
                "-j=2",
            }
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            server_config.capabilities = capabilities
            vim.lsp.config["clangd"] = server_config
            vim.lsp.enable("clangd")

            vim.api.nvim_create_autocmd('LspAttach',{
                callback = function(args)
                    local opts = { buffer = args.buf }
                    vim.keymap.set('n', 'gd',        vim.lsp.buf.definition,  opts)
                    vim.keymap.set('n', '<F12>',     vim.lsp.buf.definition,  opts)
                    vim.keymap.set('n', '<C-t>',     '<C-t>',                 opts)
                    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename,      opts)
                    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'K',         function()
                        local current_buf = vim.api.nvim_get_current_buf()
                        local current_line = vim.fn.line('.')-1
                        local diagnostics = vim.diagnostic.get(current_buf, { lnum = current_line })
                        if #diagnostics > 0 then
                            vim.diagnostic.open_float()
                        else
                            vim.lsp.buf.hover()
                        end
                    end, opts)
                end
            })
        end
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            if cmp.get_selected_entry() then
                                cmp.confirm({select=false})
                            else
                                cmp.select_next_item()
                            end
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end,{"i","s"}),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim-lsp' },
                }, {
                    { name = 'buffer' },
                })
            })
        end
    },
    {
       'nvim-telescope/telescope.nvim',
       branch = '0.1.x',
       dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
           local builtin = require('telescope.builtin')
           vim.keymap.set('n', '<C-p>', builtin.find_files, {})
           vim.keymap.set('n', '<space>o', builtin.lsp_document_symbols, {})
           vim.keymap.set('n', '<space>s', builtin.lsp_dynamic_workspace_symbols, {})
       end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                window = {
                    position = "left",
                    width = 30,
                },
                filesystem = {
                    filtered_items = {
                        visible = true, -- 非表示も表示
                        show_hidden_count = true, -- フィルターされた項目の数を表示
                        hide_dotfiles = false, -- .から始まるファイルを非表示にしない
                        hide_gitignored = false, -- .gitignoreにあるファイルを非表示にしない
                        hide_by_name ={ -- 特定のファイル名だけを非表示にしたいならここに記述
                        },
                    },
                },
            })
            vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true})
        end
    },
})

vim.cmd.colorscheme("vscode")
