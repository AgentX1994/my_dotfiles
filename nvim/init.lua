vim.g.mapleader = ","
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Ensure lazy is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "neovim/nvim-lspconfig",
    {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup()
        end
    },
    -- Autocompletion framework
    {"hrsh7th/nvim-cmp", dependencies= {"hrsh7th/nvim-cmp"}},
    {"hrsh7th/nvim-cmp", dependencies= {"hrsh7th/cmp-nvim-lsp"}},
    {"hrsh7th/nvim-cmp", dependencies= {"hrsh7th/cmp-vsnip"}},
    {"hrsh7th/nvim-cmp", dependencies= {"hrsh7th/cmp-path"}},
    {"hrsh7th/nvim-cmp", dependencies= {"hrsh7th/cmp-buffer"}},
    "hrsh7th/vim-vsnip",
    {"mrcjkb/rustaceanvim", ft= {"rust"}},
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",

    "rafamadriz/friendly-snippets",
    {"catppuccin/nvim", name = "catppuccin"},
    "vim-airline/vim-airline",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit", -- Lazy load neogit
        config=true
    },
    "sindrets/diffview.nvim",
    "voldikss/vim-floaterm",
    {"nvim-treesitter/nvim-treesitter", build=":TSUpdate"},
    {"folke/trouble.nvim", dependecies="nvim-tree/nvim-web-devicons"},
    -- Debugger integration
    { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
    "ionide/Ionide-vim",
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
            opts = {},
    },
    "terrortylor/nvim-comment",
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    }
})

require("catppuccin").setup({
    integrations = {
        neogit = true,
        nvimtree = true,
        treesitter = true,
        dap_ui = true,
        cmp = true,
        native_lsp = {
            enabled = true
        },
        telescope = {
            enabled = true
        },
        lsp_trouble = true
    }
})

vim.o.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess = vim.opt.shortmess + "c"

local function on_attach(client, buffer)
    -- Key mappings
    local keymap_opts = { buffer = buffer }
    vim.wo.signcolumn = "yes"
    -- Code navigation and shortcuts
    vim.keymap.set("n", "<c-]>", vim.lsp.buf.definition, keymap_opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.implementation, keymap_opts)
    vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, keymap_opts)
    vim.keymap.set("n", "1gD", vim.lsp.buf.type_definition, keymap_opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, keymap_opts)
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, keymap_opts)
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, keymap_opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
    vim.keymap.set("n", "gn", vim.lsp.buf.rename, keymap_opts)

    -- Set updatetime for CursorHold
    -- 300ms of no cursor movement to trigger CursorHold
    vim.opt.updatetime = 100

    -- Show diagnostic popup on cursor hover
    local diag_float_grp = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      callback = function()
       vim.diagnostic.open_float(nil, { focusable = false })
      end,
      group = diag_float_grp,
    })

    -- Goto previous/next diagnostic warning/error
    vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, keymap_opts)
    vim.keymap.set("n", "g]", vim.diagnostic.goto_next, keymap_opts)
    local format_sync_grp = vim.api.nvim_create_augroup("Format", {})

    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
            vim.lsp.buf.format({ timeout_ms = 200 })
          end,
          group = format_sync_grp,
        })
    end

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, {bufnr=buffer})
    end
end

vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
        -- Hover actions
        vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, {buffer=buffer})
        -- Code action groups
        local code_action = function()
            vim.cmd.RustLsp('codeAction')
        end
        vim.keymap.set("n", "<Leader>a", code_action, {buffer=buffer})
        on_attach(client, buffer)
    end,
  },
  default_settings = {
     -- rust-analyzer language server configuration
     ["rust-analyzer"] = {
         check = {
             command = "clippy"
         },
         cargo = {
           buildScripts = {
             enable = true,
           },
         },
         procMacro = {
           enable = true,
         }
     },
  },
  -- DAP configuration
  dap = {
  },
}

-- setup other LSPs
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})
lspconfig.ts_ls.setup({})
lspconfig.clangd.setup({
    on_attach=on_attach
})
lspconfig.standardrb.setup({})

-- Setup treesitter for parsing/highlighting
vim.filetype.add({extension = {wgsl = "wgsl"}})
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
require('nvim-treesitter.configs').setup {
    ensure_installed = {"lua", "c", "cpp", "python", "rust", "wgsl", "fsharp", "markdown", "markdown_inline"},
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
}

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart = 99 -- do not close folds when a buffer is opened

if vim.fn.executable("wgsl_analyzer") == 1 then
    lspconfig.wgsl_analyzer.setup({})
end

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require("cmp")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    -- Add tab support
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },

  -- Installed sources
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
})
-- Insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-- Normal vim configuration
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = 'catppuccin'
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"
vim.opt.clipboard = "unnamedplus"

-- Setup telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})


-- Setup diffview
require("diffview").setup({})

-- Setup neogit
require("neogit").setup({})

require("nvim-tree").setup()
api = require("nvim-tree.api")
vim.keymap.set("n", "<C-n>", api.tree.toggle, {})

-- Setup dap ui
require("dapui").setup()
local dap, dapui = require("dap"), require("dapui")
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
dap.adapters.lldb = {
  type = 'executable',
  command = '/opt/homebrew/Cellar/llvm/18.1.8/bin/lldb-dap', -- adjust as needed, must be absolute path
  name = 'lldb'
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

-- Setup vim-floaterm
vim.keymap.set("n", "<leader>ft", ":FloatermToggle<cr>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Style floating window border by grabbing the colors from
-- the existing highlight group
local colors = vim.api.nvim_get_hl(0, {name="Normal"})
vim.api.nvim_set_hl(0, "FloatermBorder", {
    bg=colors.bg,
    fg=colors.fg
})

-- Setup a mapping for TroubleToggle
vim.keymap.set("n", "<leader>x", function() require("trouble").toggle() end)
require('nvim_comment').setup()
