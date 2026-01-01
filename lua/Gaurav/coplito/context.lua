--------------------------------------------------
-- Coplito Context Collection Module
--------------------------------------------------
-- Collects context from multiple sources in priority order:
-- 1. Visual selection
-- 2. Active file window
-- 3. Symbol-aware chunks
-- 4. Error context (LSP diagnostics)
-- 5. Related symbols
-- 6. Project metadata

local M = {}

---@class ContextChunk
---@field type string "selection"|"active_file"|"symbol"|"error"|"related"|"metadata"
---@field priority number 1-6 (lower = higher priority)
---@field content string The actual content
---@field metadata table Additional info (file, lines, symbol_name, etc.)

-- Get visual selection (highest priority)
---@return ContextChunk|nil
function M.get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then
    return nil
  end

  local content = table.concat(lines, "\n")
  local filepath = vim.api.nvim_buf_get_name(0)

  return {
    type = "selection",
    priority = 1,
    content = content,
    metadata = {
      file = filepath,
      start_line = start_line,
      end_line = end_line,
      mode = mode,
    },
  }
end

-- Get active file context
---@param window_size number Number of lines around cursor (default 50)
---@return ContextChunk
function M.get_active_file(window_size)
  window_size = window_size or 50

  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1]
  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Get window around cursor
  local start_line = math.max(1, cursor_line - window_size)
  local end_line = math.min(total_lines, cursor_line + window_size)

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  local content = table.concat(lines, "\n")

  -- Get filetype
  local filetype = vim.bo[bufnr].filetype

  return {
    type = "active_file",
    priority = 2,
    content = content,
    metadata = {
      file = filepath,
      start_line = start_line,
      end_line = end_line,
      cursor_line = cursor_line,
      total_lines = total_lines,
      filetype = filetype,
    },
  }
end

-- Get full file content (for smaller files)
---@return ContextChunk
function M.get_full_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  local filetype = vim.bo[bufnr].filetype

  return {
    type = "active_file",
    priority = 2,
    content = content,
    metadata = {
      file = filepath,
      start_line = 1,
      end_line = #lines,
      filetype = filetype,
      full_file = true,
    },
  }
end

-- Get project metadata
---@return ContextChunk|nil
function M.get_project_metadata()
  local cwd = vim.fn.getcwd()
  local metadata = {
    workspace = cwd,
    files = {},
  }

  -- Check for common project files
  local project_files = {
    "Cargo.toml",
    "package.json",
    "go.mod",
    "requirements.txt",
    "setup.py",
    "CMakeLists.txt",
    "Makefile",
  }

  for _, filename in ipairs(project_files) do
    local path = cwd .. "/" .. filename
    if vim.fn.filereadable(path) == 1 then
      table.insert(metadata.files, filename)
    end
  end

  if #metadata.files == 0 then
    return nil
  end

  local content = "Project: " .. cwd .. "\n"
  content = content .. "Config files: " .. table.concat(metadata.files, ", ")

  return {
    type = "metadata",
    priority = 6,
    content = content,
    metadata = metadata,
  }
end

-- Collect all available context
---@param opts table Options: include_full_file, window_size
---@return ContextChunk[]
function M.collect_all(opts)
  opts = opts or {}
  local chunks = {}

  -- 1. Visual selection (highest priority)
  local selection = M.get_visual_selection()
  if selection then
    table.insert(chunks, selection)
  end

  -- 2. Active file
  if opts.include_full_file then
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count < 500 then -- Only full file if < 500 lines
      table.insert(chunks, M.get_full_file())
    else
      table.insert(chunks, M.get_active_file(opts.window_size))
    end
  else
    table.insert(chunks, M.get_active_file(opts.window_size))
  end

  -- 6. Project metadata
  local metadata = M.get_project_metadata()
  if metadata then
    table.insert(chunks, metadata)
  end

  return chunks
end

-- Deduplicate chunks
---@param chunks ContextChunk[]
---@return ContextChunk[]
function M.deduplicate(chunks)
  local seen = {}
  local result = {}

  for _, chunk in ipairs(chunks) do
    local key = chunk.type .. ":" .. chunk.content
    if not seen[key] then
      seen[key] = true
      table.insert(result, chunk)
    end
  end

  return result
end

-- Get recent chat history (Priority 7: RAG memory)
---@param max_chats number Maximum number of recent chats to include (default 3)
---@return ContextChunk|nil
function M.get_chat_history(max_chats)
  max_chats = max_chats or 3
  
  local chat_dir = vim.fn.expand("~/.config/nvim/chat_history")
  
  -- Check if directory exists
  if vim.fn.isdirectory(chat_dir) == 0 then
    return nil
  end
  
  -- Get all chat files sorted by modification time (newest first)
  local files = vim.fn.systemlist("ls -t " .. chat_dir .. "/chat_*.txt 2>/dev/null")
  
  if #files == 0 then
    return nil
  end
  
  -- Read recent chats
  local chat_contents = {}
  local count = 0
  
  for _, filepath in ipairs(files) do
    if count >= max_chats then break end
    
    local full_path = chat_dir .. "/" .. vim.fn.fnamemodify(filepath, ":t")
    local content = vim.fn.readfile(full_path)
    
    if #content > 0 then
      -- Extract timestamp from filename (chat_YYYY-MM-DD_HHMMSS.txt)
      local timestamp = filepath:match("chat_(%d%d%d%d%-%d%d%-%d%d_%d+)")
      
      table.insert(chat_contents, "--- Chat from " .. (timestamp or "unknown") .. " ---")
      table.insert(chat_contents, table.concat(content, "\n"))
      table.insert(chat_contents, "")
      count = count + 1
    end
  end
  
  if #chat_contents == 0 then
    return nil
  end
  
  return {
    type = "chat_history",
    priority = 7,
    content = table.concat(chat_contents, "\n"),
    metadata = {
      chat_count = count,
      source = "recent_conversations",
    },
  }
end

-- Sort chunks by priority
---@param chunks ContextChunk[]
---@return ContextChunk[]
function M.sort_by_priority(chunks)
  table.sort(chunks, function(a, b)
    return a.priority < b.priority
  end)
  return chunks
end

return M
