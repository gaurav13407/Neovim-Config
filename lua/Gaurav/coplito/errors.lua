--------------------------------------------------
-- Coplito Error Context Handler
--------------------------------------------------
-- Collects and formats error context from LSP diagnostics,
-- terminal output, and other sources
-- ERRORS ARE GROUND TRUTH - never contradict them

local M = {}

---@class ErrorContext
---@field type string "compiler"|"runtime"|"stack_trace"|"test"
---@field priority number Always 4 (errors have high priority)
---@field file string|nil
---@field line number|nil
---@field col number|nil
---@field severity string "ERROR"|"WARNING"|"INFO"
---@field message string Full error message
---@field code string|nil Error code (e.g., E0308)
---@field source string|nil LSP source (rust-analyzer, pyright, etc.)
---@field related table[]|nil Related diagnostics

-- Get LSP diagnostics for current buffer
---@param bufnr number
---@return ErrorContext[]
function M.get_lsp_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)
  local errors = {}

  for _, diag in ipairs(diagnostics) do
    -- Map severity
    local severity_map = {
      [vim.diagnostic.severity.ERROR] = "ERROR",
      [vim.diagnostic.severity.WARN] = "WARNING",
      [vim.diagnostic.severity.INFO] = "INFO",
      [vim.diagnostic.severity.HINT] = "HINT",
    }

    local filepath = vim.api.nvim_buf_get_name(bufnr)

    table.insert(errors, {
      type = "compiler",
      priority = 4,
      file = filepath,
      line = diag.lnum + 1, -- LSP uses 0-indexed
      col = diag.col + 1,
      severity = severity_map[diag.severity] or "ERROR",
      message = diag.message,
      code = diag.code,
      source = diag.source,
      related = diag.relatedInformation,
    })
  end

  return errors
end

-- Get all diagnostics in workspace
---@return ErrorContext[]
function M.get_all_diagnostics()
  local all_errors = {}
  local buffers = vim.api.nvim_list_bufs()

  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local errors = M.get_lsp_diagnostics(bufnr)
      for _, err in ipairs(errors) do
        table.insert(all_errors, err)
      end
    end
  end

  return all_errors
end

-- Get diagnostics at cursor position
---@return ErrorContext[]
function M.get_diagnostics_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- 0-indexed

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
  local errors = {}

  for _, diag in ipairs(diagnostics) do
    local severity_map = {
      [vim.diagnostic.severity.ERROR] = "ERROR",
      [vim.diagnostic.severity.WARN] = "WARNING",
      [vim.diagnostic.severity.INFO] = "INFO",
      [vim.diagnostic.severity.HINT] = "HINT",
    }

    local filepath = vim.api.nvim_buf_get_name(bufnr)

    table.insert(errors, {
      type = "compiler",
      priority = 4,
      file = filepath,
      line = diag.lnum + 1,
      col = diag.col + 1,
      severity = severity_map[diag.severity] or "ERROR",
      message = diag.message,
      code = diag.code,
      source = diag.source,
      related = diag.relatedInformation,
    })
  end

  return errors
end

-- Format error for prompt injection
---@param error ErrorContext
---@return string
function M.format_error(error)
  local lines = {}

  -- File location
  if error.file then
    local location = error.file
    if error.line then
      location = location .. ":" .. error.line
      if error.col then
        location = location .. ":" .. error.col
      end
    end
    table.insert(lines, "File: " .. location)
  end

  -- Error type and severity
  table.insert(lines, "Type: " .. error.type .. " [" .. error.severity .. "]")

  -- Error code
  if error.code then
    table.insert(lines, "Code: " .. error.code)
  end

  -- Source
  if error.source then
    table.insert(lines, "Source: " .. error.source)
  end

  -- Message (most important)
  table.insert(lines, "")
  table.insert(lines, "Error: " .. error.message)

  -- Related information
  if error.related and #error.related > 0 then
    table.insert(lines, "")
    table.insert(lines, "Related:")
    for _, rel in ipairs(error.related) do
      if rel.message then
        table.insert(lines, "  - " .. rel.message)
      end
    end
  end

  return table.concat(lines, "\n")
end

-- Format all errors for prompt
---@param errors ErrorContext[]
---@return string
function M.format_errors(errors)
  if #errors == 0 then
    return ""
  end

  local lines = {}
  table.insert(lines, "[ERROR CONTEXT]")

  for i, error in ipairs(errors) do
    if i > 1 then
      table.insert(lines, "")
      table.insert(lines, "---")
      table.insert(lines, "")
    end
    table.insert(lines, M.format_error(error))
  end

  table.insert(lines, "[END ERROR CONTEXT]")

  return table.concat(lines, "\n")
end

-- Convert ErrorContext to ContextChunk format
---@param error ErrorContext
---@return table ContextChunk
function M.to_context_chunk(error)
  return {
    type = "error",
    priority = 4,
    content = M.format_error(error),
    metadata = {
      error_type = error.type,
      severity = error.severity,
      file = error.file,
      line = error.line,
      col = error.col,
      code = error.code,
      source = error.source,
    },
  }
end

-- Get error context for current buffer as context chunks
---@return table[] ContextChunks
function M.get_error_context()
  local errors = M.get_lsp_diagnostics()
  local chunks = {}

  -- Only include errors and warnings, skip hints/info
  for _, error in ipairs(errors) do
    if error.severity == "ERROR" or error.severity == "WARNING" then
      table.insert(chunks, M.to_context_chunk(error))
    end
  end

  return chunks
end

-- Get error context at cursor
---@return table[] ContextChunks
function M.get_cursor_error_context()
  local errors = M.get_diagnostics_at_cursor()
  local chunks = {}

  for _, error in ipairs(errors) do
    if error.severity == "ERROR" or error.severity == "WARNING" then
      table.insert(chunks, M.to_context_chunk(error))
    end
  end

  return chunks
end

-- Check if there are any errors in buffer
---@param bufnr number
---@return boolean
function M.has_errors(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  return #diagnostics > 0
end

-- Parse stack trace from text (simple implementation)
---@param text string
---@return ErrorContext|nil
function M.parse_stack_trace(text)
  -- Look for common stack trace patterns
  -- Rust: "at <path>:<line>:<col>"
  -- Python: "File \"<path>\", line <line>"
  -- Go: "<path>:<line>"

  local patterns = {
    -- Rust panic
    "at ([^:]+):(%d+):(%d+)",
    -- Python traceback
    'File "([^"]+)", line (%d+)',
    -- Go/generic
    "([^:]+):(%d+):?(%d*)",
  }

  for _, pattern in ipairs(patterns) do
    local file, line, col = text:match(pattern)
    if file then
      return {
        type = "stack_trace",
        priority = 4,
        file = file,
        line = tonumber(line),
        col = tonumber(col) or nil,
        severity = "ERROR",
        message = text,
      }
    end
  end

  return nil
end

return M
