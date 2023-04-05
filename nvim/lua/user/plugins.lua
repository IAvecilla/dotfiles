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
    use { 
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            }
        end
    }
    use "wbthomason/packer.nvim" -- Have packer manage itself
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
    
    use "alaviss/nim.nvim"
    use 'voldikss/vim-floaterm'
    use "nvim-treesitter/nvim-treesitter"
    use ("jose-elias-alvarez/null-ls.nvim")
    
    -- Tree (file explorer)
    use {"nvim-tree/nvim-tree.lua", requires = { "nvim-tree/nvim-web-devicons"}}

    -- colorschemes
    use "savq/melange"
    use ({"catppuccin/nvim", as = "catpuccin"}) 
   
    -- Install without configuration
    use ('projekt0n/github-nvim-theme')

    use {
     'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "neovim/nvim-lspconfig"
    
    use "simrat39/rust-tools.nvim"
    use {'iamcco/markdown-preview.nvim',run = function() vim.fn['mkdp#util#install']() end, ft = {'markdown'}}
    
    -- LSP completion source
    use "hrsh7th/cmp-nvim-lsp"

    use 'rescript-lang/vim-rescript'

    -- Completion framework
    use "hrsh7th/nvim-cmp"
    
    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
