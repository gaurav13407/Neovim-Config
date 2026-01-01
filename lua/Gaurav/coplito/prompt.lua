--------------------------------------------------
-- Coplito Prompt Builder
--------------------------------------------------
-- Builds structured prompts following the strict format:
-- [ERROR CONTEXT] → [CODE CONTEXT] → [USER QUERY] → [RESPONSE RULES]

local M = {}

-- Base system prompt (response rules)
M.RESPONSE_RULES = [[
You are a compiler and code reviewer for production code.

STRICT RULES:
- Only reason using the provided context above
- If context is insufficient, respond: "Insufficient context" and explain what you need
- NEVER invent functions, types, files, or APIs that don't exist in the context
- Prefer correctness over verbosity
- Avoid rewriting code unless explicitly asked

OUTPUT STRUCTURE:
1. [BUGS]: Concrete issues with exact reasoning
2. [RISKS]: Assumptions, edge cases, undefined behavior
3. [SUGGESTIONS]: Optional improvements, clearly marked, non-breaking

ERRORS ARE GROUND TRUTH:
- If error context is provided, it is 100% correct
- Never contradict error messages
- Base all reasoning on errors first, then code context
]]

-- Format code context section
---@param chunks table[] ContextChunks
---@return string
local function format_code_context(chunks)
  if #chunks == 0 then
    return ""
  end

  local lines = {}
  table.insert(lines, "[CODE CONTEXT]")

  for i, chunk in ipairs(chunks) do
    if i > 1 then
      table.insert(lines, "")
    end

    -- Format based on chunk type
    if chunk.type == "symbol" then
      local meta = chunk.metadata
      table.insert(
        lines,
        string.format(
          "## Symbol: %s (%s)",
          meta.symbol_name or "unknown",
          meta.symbol_type or "unknown"
        )
      )
      table.insert(lines, string.format("File: %s:%d-%d", meta.file, meta.start_line, meta.end_line))
      table.insert(lines, "---")
      table.insert(lines, chunk.content)
      table.insert(lines, "---")
    elseif chunk.type == "selection" then
      local meta = chunk.metadata
      table.insert(lines, "## User Selection")
      table.insert(lines, string.format("File: %s:%d-%d", meta.file, meta.start_line, meta.end_line))
      table.insert(lines, "---")
      table.insert(lines, chunk.content)
      table.insert(lines, "---")
    elseif chunk.type == "active_file" then
      local meta = chunk.metadata
      if meta.full_file then
        table.insert(lines, "## Full File")
        table.insert(lines, string.format("File: %s", meta.file))
      else
        table.insert(lines, "## Active File Window")
        table.insert(lines, string.format("File: %s:%d-%d (cursor at line %d)", meta.file, meta.start_line, meta.end_line, meta.cursor_line))
      end
      table.insert(lines, "---")
      table.insert(lines, chunk.content)
      table.insert(lines, "---")
    elseif chunk.type == "chat_history" then
      -- Chat history from previous conversations
      table.insert(lines, "## Recent Chat History (RAG Memory)")
      table.insert(lines, string.format("Last %d conversations:", chunk.metadata.chat_count))
      table.insert(lines, "---")
      table.insert(lines, chunk.content)
      table.insert(lines, "---")
    else
      -- Generic format
      table.insert(lines, "## " .. chunk.type)
      table.insert(lines, chunk.content)
    end
  end

  table.insert(lines, "[END CODE CONTEXT]")

  return table.concat(lines, "\n")
end

-- Format error context section
---@param error_chunks table[] ErrorContext chunks
---@return string
local function format_error_context(error_chunks)
  if #error_chunks == 0 then
    return ""
  end

  local lines = {}
  table.insert(lines, "[ERROR CONTEXT]")

  for i, chunk in ipairs(error_chunks) do
    if i > 1 then
      table.insert(lines, "")
      table.insert(lines, "---")
      table.insert(lines, "")
    end
    table.insert(lines, chunk.content)
  end

  table.insert(lines, "[END ERROR CONTEXT]")

  return table.concat(lines, "\n")
end

-- Format user query section
---@param query string
---@return string
local function format_user_query(query)
  return "[USER QUERY]\n" .. query .. "\n[END USER QUERY]"
end

-- Format response rules section
---@return string
local function format_response_rules()
  return "[RESPONSE RULES]\n" .. M.RESPONSE_RULES .. "\n[END RESPONSE RULES]"
end

-- Build full structured prompt
---@param opts table { query: string, error_chunks: table[], code_chunks: table[] }
---@return string
function M.build_prompt(opts)
  local sections = {}

  -- 1. ERROR CONTEXT (highest priority)
  if opts.error_chunks and #opts.error_chunks > 0 then
    table.insert(sections, format_error_context(opts.error_chunks))
    table.insert(sections, "")
  end

  -- 2. CODE CONTEXT
  if opts.code_chunks and #opts.code_chunks > 0 then
    table.insert(sections, format_code_context(opts.code_chunks))
    table.insert(sections, "")
  end

  -- 3. USER QUERY
  if opts.query and opts.query ~= "" then
    table.insert(sections, format_user_query(opts.query))
    table.insert(sections, "")
  end

  -- 4. RESPONSE RULES
  table.insert(sections, format_response_rules())

  return table.concat(sections, "\n")
end

-- Build prompt with auto context detection
---@param query string User query
---@param opts table|nil Options: include_errors, include_symbols, window_size
---@return string
function M.build_auto_prompt(query, opts)
  opts = opts or {}

  local context = require("Gaurav.coplito.context")
  local errors = require("Gaurav.coplito.errors")
  local symbols = require("Gaurav.coplito.symbols")

  local error_chunks = {}
  local code_chunks = {}

  -- 1. Collect error context (if requested)
  if opts.include_errors ~= false then
    -- Get errors at cursor first
    local cursor_errors = errors.get_cursor_error_context()
    if #cursor_errors > 0 then
      for _, chunk in ipairs(cursor_errors) do
        table.insert(error_chunks, chunk)
      end
    else
      -- Get all buffer errors
      local buffer_errors = errors.get_error_context()
      for _, chunk in ipairs(buffer_errors) do
        table.insert(error_chunks, chunk)
      end
    end
  end

  -- 2. Collect code context
  local basic_chunks = context.collect_all({
    include_full_file = opts.include_full_file,
    window_size = opts.window_size,
  })

  for _, chunk in ipairs(basic_chunks) do
    table.insert(code_chunks, chunk)
  end

  -- 3. Add symbol context (if requested and available)
  if opts.include_symbols then
    local cursor_symbol = symbols.get_cursor_symbol_context()
    if cursor_symbol then
      table.insert(code_chunks, cursor_symbol)
    end
  end

  -- 4. Deduplicate and sort
  code_chunks = context.deduplicate(code_chunks)
  code_chunks = context.sort_by_priority(code_chunks)

  -- 5. Build final prompt
  return M.build_prompt({
    query = query,
    error_chunks = error_chunks,
    code_chunks = code_chunks,
  })
end

-- Check if context is sufficient
---@param code_chunks table[]
---@param error_chunks table[]
---@return boolean, string|nil
function M.check_context_sufficiency(code_chunks, error_chunks)
  -- If we have errors but no code context, insufficient
  if #error_chunks > 0 and #code_chunks == 0 then
    return false, "Errors found but no code context available"
  end

  -- If we have no context at all, insufficient
  if #code_chunks == 0 and #error_chunks == 0 then
    return false, "No context available - no errors, no code selection, no active file"
  end

  -- Context is sufficient
  return true, nil
end

-- Generate insufficient context response
---@param reason string
---@param available_context table
---@return string
function M.insufficient_context_response(reason, available_context)
  local lines = {}

  table.insert(lines, "Insufficient context.")
  table.insert(lines, "")
  table.insert(lines, "Reason: " .. reason)
  table.insert(lines, "")

  if available_context then
    table.insert(lines, "What I have:")
    if available_context.file then
      table.insert(lines, "- Active file: " .. available_context.file)
    end
    if available_context.selection then
      table.insert(lines, "- Selected code: " .. available_context.selection)
    end
    if available_context.errors then
      table.insert(lines, "- Errors: " .. available_context.errors)
    end
    table.insert(lines, "")
  end

  table.insert(lines, "Please provide:")
  table.insert(lines, "- Select relevant code regions (visual mode)")
  table.insert(lines, "- Open related files")
  table.insert(lines, "- Share error messages if any")

  return table.concat(lines, "\n")
end

return M
