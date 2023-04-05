local options = {
  clipboard = "unnamedplus",               
  completeopt = { "menuone", "noselect", "noinsert" }, 
  fileencoding = "utf-8",                  
  hlsearch = true,                         
  ignorecase = true,                       
  showtabline = 2,                         
  smartcase = true,                        
  smartindent = true,                      
  splitbelow = true,                       
  splitright = true,                       
  termguicolors = true,
  expandtab = true,                        
  shiftwidth = 4,                          
  tabstop = 4,                             
  number = true,                           
  relativenumber = true,                  
  numberwidth = 4,                         
  scrolloff = 8,                           
  sidescrolloff = 8,
}

vim.api.nvim_set_option("updatetime", 300)
vim.opt.shortmess:append "c"

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])
