--------------------------------------------------
-- Coplito RAG Pipeline
--------------------------------------------------
-- Main RAG orchestration module
-- Coordinates context collection, prompt building, and model interaction

local M = {}

-- Import modules
local context = require("Gaurav.coplito.context")
local errors = require("Gaurav.coplito.errors")
local symbols = require("Gaurav.coplito.symbols")
local prompt = require("Gaurav.coplito.prompt")

-- Default configuration
M.config = {
  -- Context collection
  include_errors = true, -- Always include LSP diagnostics
  include_symbols = true, -- Include Tree-sitter symbols
  include_full_file = false, -- Include full file for small files
  window_size = 50, -- Lines around cursor

  -- Prompt building
  auto_detect_context = true, -- Automatically detect best context

  -- Failure modes
  fail_on_insufficient_context = false, -- Show error instead of sending to model
}

-- Setup configuration
---@param opts table|nil
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Collect all context for current buffer
---@param opts table|nil Override config options
---@return table { error_chunks: table[], code_chunks: table[] }
function M.collect_context(opts)
  opts = vim.tbl_deep_extend("force", M.config, opts or {})

  local error_chunks = {}
  local code_chunks = {}

  -- 1. Collect error context
  if opts.include_errors then
    local cursor_errors = errors.get_cursor_error_context()
    if #cursor_errors > 0 then
      vim.list_extend(error_chunks, cursor_errors)
    else
      local buffer_errors = errors.get_error_context()
      vim.list_extend(error_chunks, buffer_errors)
    end
  end

  -- 2. Collect basic context (selection, active file, metadata)
  local basic_chunks = context.collect_all({
    include_full_file = opts.include_full_file,
    window_size = opts.window_size,
  })
  vim.list_extend(code_chunks, basic_chunks)

  -- 3. Collect symbol context
  if opts.include_symbols then
    -- First try to get symbol at cursor
    local cursor_symbol = symbols.get_cursor_symbol_context()
    if cursor_symbol then
      table.insert(code_chunks, cursor_symbol)
    end
  end

  -- 4. Collect chat history (Priority 7: RAG memory)
  if opts.include_chat_history then
    local chat_history = context.get_chat_history(opts.max_recent_chats or 3)
    if chat_history then
      table.insert(code_chunks, chat_history)
    end
  end

  -- 5. Deduplicate and sort
  code_chunks = context.deduplicate(code_chunks)
  code_chunks = context.sort_by_priority(code_chunks)

  return {
    error_chunks = error_chunks,
    code_chunks = code_chunks,
  }
end

-- Build prompt with collected context
---@param query string User query
---@param opts table|nil Options
---@return string prompt
function M.build_context_prompt(query, opts)
  opts = opts or {}

  -- Collect context
  local collected = M.collect_context(opts)

  -- Check if context is sufficient
  if M.config.fail_on_insufficient_context then
    local sufficient, reason = prompt.check_context_sufficiency(
      collected.code_chunks,
      collected.error_chunks
    )

    if not sufficient then
      return prompt.insufficient_context_response(reason, {
        file = vim.api.nvim_buf_get_name(0),
        errors = #collected.error_chunks > 0 and tostring(#collected.error_chunks) or nil,
      })
    end
  end

  -- Build structured prompt
  return prompt.build_prompt({
    query = query,
    error_chunks = collected.error_chunks,
    code_chunks = collected.code_chunks,
  })
end

-- Get context summary for display
---@return table { errors: number, symbols: number, selection: boolean, file: string }
function M.get_context_summary()
  local collected = M.collect_context()

  local has_selection = false
  local symbol_count = 0

  for _, chunk in ipairs(collected.code_chunks) do
    if chunk.type == "selection" then
      has_selection = true
    elseif chunk.type == "symbol" then
      symbol_count = symbol_count + 1
    end
  end

  return {
    errors = #collected.error_chunks,
    symbols = symbol_count,
    selection = has_selection,
    file = vim.api.nvim_buf_get_name(0),
  }
end

-- Show context summary notification
function M.show_context_summary()
  local summary = M.get_context_summary()
  local lines = {}

  table.insert(lines, "Coplito Context:")
  table.insert(lines, string.format("  Errors: %d", summary.errors))
  table.insert(lines, string.format("  Symbols: %d", summary.symbols))
  table.insert(lines, string.format("  Selection: %s", summary.selection and "Yes" or "No"))
  table.insert(lines, string.format("  File: %s", vim.fn.fnamemodify(summary.file, ":t")))

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Interactive prompt builder (for debugging)
---@param query string
function M.preview_prompt(query)
  local full_prompt = M.build_context_prompt(query)

  -- Create new buffer with prompt preview
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(full_prompt, "\n"))
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"

  -- Open in split
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

return M
