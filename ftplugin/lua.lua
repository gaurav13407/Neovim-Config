-- %USERPROFILE%\AppData\Local\nvim\ftplugin\lua.lua
-- safe wrapper: only start treesitter if parser exists
pcall(function()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok and parsers and parsers.has_parser and parsers.has_parser("lua") then
    if vim.treesitter and vim.treesitter.start then
      vim.treesitter.start(0, "lua")
    end
  end
end)
