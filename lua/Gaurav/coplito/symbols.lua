--------------------------------------------------
-- Coplito Symbol Extraction Module
--------------------------------------------------
-- Extracts semantic symbols using Tree-sitter
-- Chunks code by functions, structs, impls, etc.

local M = {}

---@class SymbolChunk
---@field symbol_name string
---@field symbol_type string "function"|"struct"|"enum"|"impl"|"class"|"method"
---@field file_path string
---@field start_line number
---@field end_line number
---@field body string Full symbol body
---@field signature string|nil Function/method signature
---@field dependencies string[]|nil Referenced symbols

-- Check if Tree-sitter is available
local function has_treesitter()
  return pcall(require, "nvim-treesitter")
end

-- Get Tree-sitter parser for buffer
---@param bufnr number
---@return table|nil parser
local function get_parser(bufnr)
  if not has_treesitter() then
    return nil
  end

  local ok, ts = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return nil
  end

  local ok2, parser = pcall(ts.get_parser, bufnr)
  if not ok2 then
    return nil
  end

  return parser
end

-- Extract symbol name from node
---@param node table Tree-sitter node
---@param source string Buffer source text
---@return string|nil
local function get_symbol_name(node, source)
  -- Try to find name node
  local name_node = node:field("name")[1]
  if name_node then
    return vim.treesitter.get_node_text(name_node, source)
  end

  -- Fallback: get text of node itself
  local text = vim.treesitter.get_node_text(node, source)
  if text and #text < 100 then
    return text:match("^[%w_]+")
  end

  return nil
end

-- Get symbol type mapping for different languages
local symbol_queries = {
  rust = {
    function_item = "function",
    struct_item = "struct",
    enum_item = "enum",
    impl_item = "impl",
    mod_item = "module",
  },
  python = {
    function_definition = "function",
    class_definition = "class",
  },
  lua = {
    function_declaration = "function",
    function_definition = "function",
  },
  javascript = {
    function_declaration = "function",
    function_expression = "function",
    class_declaration = "class",
    method_definition = "method",
  },
  typescript = {
    function_declaration = "function",
    function_expression = "function",
    class_declaration = "class",
    method_definition = "method",
    interface_declaration = "interface",
  },
  go = {
    function_declaration = "function",
    method_declaration = "method",
    type_declaration = "type",
  },
  c = {
    function_definition = "function",
    struct_specifier = "struct",
  },
  cpp = {
    function_definition = "function",
    struct_specifier = "struct",
    class_specifier = "class",
  },
}

-- Extract symbols from buffer using Tree-sitter
---@param bufnr number
---@return SymbolChunk[]
function M.extract_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local symbols = {}

  local parser = get_parser(bufnr)
  if not parser then
    return symbols
  end

  local tree = parser:parse()[1]
  if not tree then
    return symbols
  end

  local root = tree:root()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local source = bufnr

  -- Get symbol type mapping for this language
  local type_map = symbol_queries[filetype] or {}

  -- Query all nodes
  local query_string = ""
  for node_type, _ in pairs(type_map) do
    if query_string ~= "" then
      query_string = query_string .. "\n"
    end
    query_string = query_string .. string.format("(%s) @symbol", node_type)
  end

  if query_string == "" then
    -- Fallback: no specific queries for this language
    return symbols
  end

  local ok, query = pcall(vim.treesitter.query.parse, filetype, query_string)
  if not ok then
    return symbols
  end

  -- Iterate through matches
  for id, node in query:iter_captures(root, source, 0, -1) do
    local node_type = node:type()
    local symbol_type = type_map[node_type]

    if symbol_type then
      local start_row, start_col, end_row, end_col = node:range()
      local symbol_name = get_symbol_name(node, source)

      if symbol_name then
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
        local body = table.concat(lines, "\n")

        table.insert(symbols, {
          symbol_name = symbol_name,
          symbol_type = symbol_type,
          file_path = filepath,
          start_line = start_row + 1,
          end_line = end_row + 1,
          body = body,
          signature = nil, -- TODO: extract signature
          dependencies = nil, -- TODO: extract dependencies
        })
      end
    end
  end

  return symbols
end

-- Find symbol at cursor position
---@param bufnr number
---@return SymbolChunk|nil
function M.get_symbol_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1]

  local symbols = M.extract_symbols(bufnr)

  for _, symbol in ipairs(symbols) do
    if cursor_line >= symbol.start_line and cursor_line <= symbol.end_line then
      return symbol
    end
  end

  return nil
end

-- Convert SymbolChunk to ContextChunk format
---@param symbol SymbolChunk
---@return table ContextChunk
function M.to_context_chunk(symbol)
  return {
    type = "symbol",
    priority = 3,
    content = symbol.body,
    metadata = {
      symbol_name = symbol.symbol_name,
      symbol_type = symbol.symbol_type,
      file = symbol.file_path,
      start_line = symbol.start_line,
      end_line = symbol.end_line,
    },
  }
end

-- Get all symbols in buffer as context chunks
---@param bufnr number
---@return table[] ContextChunks
function M.get_symbol_context(bufnr)
  local symbols = M.extract_symbols(bufnr)
  local chunks = {}

  for _, symbol in ipairs(symbols) do
    table.insert(chunks, M.to_context_chunk(symbol))
  end

  return chunks
end

-- Get symbol at cursor as context chunk
---@param bufnr number
---@return table|nil ContextChunk
function M.get_cursor_symbol_context(bufnr)
  local symbol = M.get_symbol_at_cursor(bufnr)
  if symbol then
    return M.to_context_chunk(symbol)
  end
  return nil
end

return M
