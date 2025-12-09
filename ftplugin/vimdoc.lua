-- %USERPROFILE%\AppData\Local\nvim\ftplugin\vimdoc.lua
-- safe wrapper: only start treesitter if parser exists
pcall(function()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok and parsers and parsers.has_parser and parsers.has_parser("vimdoc") then
    if vim.treesitter and vim.treesitter.start then
      vim.treesitter.start(0, "vimdoc")
    end
  end
end)
