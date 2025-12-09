vim.opt.shell = "pwsh.exe"
--vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
--vim.opt.shellquote = ""
--vim.opt.shellxquote = ""

-- SAFETY WRAPPER: prevent runtime ftplugins from crashing when a parser is missing
if vim and vim.treesitter and type(vim.treesitter.start) == "function" then
    local _orig_treesitter_start = vim.treesitter.start
    vim.treesitter.start = function(bufnr, lang)
        local ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if not ok or type(parsers) ~= "table" or type(parsers.has_parser) ~= "function" then
            return
        end
        if not parsers.has_parser(lang) then
            return
        end
        return _orig_treesitter_start(bufnr, lang)
    end
end

-- your config starts here
require("Gaurav.core")
require("Gaurav.lazy")
require("current-theme")
-- Terminal runner
local ok, terminal = pcall(require, 'Gaurav.core.terminal')
if ok and terminal and type(terminal.setup) == "function" then
  terminal.setup()
else
  print("Failed to load terminal.lua")
end






