require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.colorscheme"

vim.cmd(":set guicursor=")

-- Treesitter Plugin Setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'lua', 'rust', 'toml', 'typst' },
  highlight = { enable = true },
}

require("nvim-tree").setup {}

-- Autoclosing
require("nvim-autopairs").setup {} 

-- Mason Setup
require ("mason").setup({
    ui = {
        icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
        },
    }
})
require("mason-lspconfig").setup()

-- Vimspector options
vim.cmd([[
let g:vimspector_sidebar_width = 85
let g:vimspector_bottombar_height = 15
let g:vimspector_terminal_maxwidth = 70
]])

-- Rust LSP (rust-analyzer)
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
})
vim.lsp.enable('rust_analyzer')

-- Typst LSP (tinymist)
vim.lsp.config('tinymist', {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  root_markers = { 'main.typ', '.git' },
  settings = {
    -- compila el documento completo aunque estes editando un capitulo suelto
    tinymist = {
      exportPdf = 'onSave',
      outputPath = '$root/apunte',
      formatterMode = 'typstyle',
    },
  },
})
vim.lsp.enable('tinymist')

-- Preview en vivo: <leader>tp lo abre, sigue el cursor en los dos sentidos.
-- El setup del plugin esta en plugins.lua (carga lazy, al abrir un .typ).
-- <Leader>t ya es FloatermToggle, asi que el preview va en <Leader>v (view).
vim.keymap.set('n', '<Leader>v', '<cmd>TypstPreviewToggle<CR>',
  { desc = 'Typst: preview' })

-- Al editar un capitulo suelto, tinymist compila ese archivo y sale sin estilo.
-- :TypstPinMain (parado en main.typ) fija ese archivo como el documento a compilar.
-- :TypstUnpin vuelve al comportamiento normal.
vim.api.nvim_create_user_command('TypstPinMain', function()
  vim.lsp.buf_request(0, 'workspace/executeCommand', {
    command = 'tinymist.pinMain', arguments = { vim.api.nvim_buf_get_name(0) },
  })
  vim.notify('typst: fijado ' .. vim.fn.expand('%:t'))
end, {})

vim.api.nvim_create_user_command('TypstUnpin', function()
  vim.lsp.buf_request(0, 'workspace/executeCommand', {
    command = 'tinymist.pinMain', arguments = { vim.NIL },
  })
  vim.notify('typst: liberado')
end, {})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<C-space>", vim.lsp.buf.hover, { buffer = bufnr })
    vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { buffer = bufnr })
  end,
})

-- LSP Diagnostics Options Setup
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = ''})
sign({name = 'DiagnosticSignWarn', text = ''})
sign({name = 'DiagnosticSignHint', text = ''})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})
