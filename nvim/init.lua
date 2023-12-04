vim.g.mapleader = ","
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Ensure packer is installed
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "git@github.com:wbthomason/packer.nvim.git", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
    use("wbthomason/packer.nvim")
    use("neovim/nvim-lspconfig")
    use({
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup()
    end
    })

    -- Autocompletion framework
    use("hrsh7th/nvim-cmp")
    use({
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        after = { "hrsh7th/nvim-cmp" },
        requires = { "hrsh7th/nvim-cmp" },
    })
    use("hrsh7th/vim-vsnip")
    use("simrat39/rust-tools.nvim")
    use("nvim-lua/popup.nvim")
    use("nvim-lua/plenary.nvim")
    use("nvim-telescope/telescope.nvim")

    use("rafamadriz/friendly-snippets")
    use("catppuccin/vim")
    use("vim-airline/vim-airline")
    use("nvim-tree/nvim-web-devicons")
    use({
      "nvim-tree/nvim-tree.lua",
      requires = {
        "nvim-tree/nvim-web-devicons",
      },
    })
    use("NeogitOrg/neogit")
    use("sindrets/diffview.nvim")
end)

if packer_bootstrap then
    require("packer").sync()
    return
end

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
    -- Code Actions
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, keymap_opts)

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
end

local rust_tools_opts = {
    runnables = {
        use_telescope = true,
    },
    inlay_hints = {
        auto = true,
        show_parameter_hints = true,
        parameter_hints_prefix = "",
        other_hints_prefix = "",
    },
    server = {
        on_attach = on_attach,
        settings = {
            ["rust_analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
}

require("rust-tools").setup(rust_tools_opts)

-- setup other LSPs
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})
lspconfig.tsserver.setup({})
lspconfig.clangd.setup({})

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
      select = true,
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

-- Normal vim configuration
vim.g.airline_powerline_fonts = 1
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.termguicolors = true
vim.cmd("colorscheme catppuccin_frappe")

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
