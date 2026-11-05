-- Catppuccin. Flavours: latte (claro), frappe, macchiato, mocha (el mas oscuro).
local flavour = "mocha"

local ok_setup, catppuccin = pcall(require, "catppuccin")
if ok_setup then
  catppuccin.setup {
    flavour = flavour,
    transparent_background = false,
    integrations = {
      treesitter = true,
      native_lsp = { enabled = true },
      cmp = true,
      telescope = { enabled = true },
      nvimtree = true,
      mason = true,
      markdown = true,
      which_key = false,
    },
  }
end

local colorscheme = "catppuccin-" .. flavour

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
    vim.notify("colorscheme " .. colorscheme .. " not found")
    return
end
