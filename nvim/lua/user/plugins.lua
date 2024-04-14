local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init { 
    display = {
        open_fn = function()
            return require("packer.util").float {border = "rounded"}
        end,
    },
}

return packer.startup(function(use)
    use "wbthomason/packer.nvim" -- Have packer manage itself
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
    
    -- FloatTerm
    use 'voldikss/vim-floaterm'
    
    -- TreeSitter 
    use "nvim-treesitter/nvim-treesitter"
    
    -- Tree (file explorer)
    use {"nvim-tree/nvim-tree.lua", requires = { "nvim-tree/nvim-web-devicons"}}
    
    -- Auto closing pairs
    use "windwp/nvim-autopairs"

    -- colorschemes
    use "savq/melange"
    use ({"catppuccin/nvim", as = "catpuccin"}) 
    use ('projekt0n/github-nvim-theme')

    -- Telescope
    use {
     'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    
    -- Mason package manager
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"

    -- Tmux config
    use "christoomey/vim-tmux-navigator"

    -- Rust config
    use "simrat39/rust-tools.nvim"
    
    -- Markdown Preview
    use {'iamcco/markdown-preview.nvim',run = function() vim.fn['mkdp#util#install']() end, ft = {'markdown'}}
    
    -- LSP completion source
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/nvim-cmp"
    use "neovim/nvim-lspconfig"
   
    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip'

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
