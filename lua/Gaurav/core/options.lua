-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0
-- vim.cmd("let g:netrw_liststyle = 3")
-- Disable netrw banner
vim.cmd("let g:netrw_banner = 0")

-- line numbers
vim.opt.guicursor="n-v-c:block,i-ci:ver25,r-cr:hor20"
vim.opt.nu = true
vim.opt.relativenumber = true

-- indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- search
vim.opt.incsearch=true
vim.opt.inccommand = "split"
vim.opt.ignorecase=true
vim.opt.smartcase=true

-- UI
vim.opt.termguicolors=true
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.backspace={"start","eol","indent"}
-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""
vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = "a"
