-- terminal.lua - Smart Terminal Runner for Neovim (Linux/Unix)
local M = {}

-- Store terminal state
local term_state = {
  buf = nil,
  win = nil,
  job_id = nil,
  is_running = false,
}

-- Language templates (auto-cleanup for compiled languages)
local templates = {
  ["c"]    = {
    compile = 'gcc "%s" -o "%s"',
    run = '"%s"',
    cleanup = '"%s"',
  },
  ["cpp"]  = {
    compile = 'g++ "%s" -o "%s"',
    run = '"%s"',
    cleanup = '"%s"',
  },
  ["java"] = {
    compile = 'javac "%s"',
    run = 'java "%s"',
    cleanup = '"%s.class"',
  },
  ["rs"]   = {
    compile = 'rustc "%s" -o "%s_temp"',
    run = '"%s_temp"',
    cleanup = '"%s_temp"',
  },
  ["py"]   = {
    run = 'python3 "%s"',
  },
  ["js"]   = {
    run = 'node "%s"',
  },
  ["ts"]   = {
    run = 'npx ts-node "%s"',
  },
  ["sh"]   = {
    run = 'bash "%s"',
  },
  ["go"]   = {
    run = 'go run "%s"',
  },
  ["lua"]  = {
    run = 'lua "%s"',
  },
}

-- Send command to terminal safely
local function send_to_term(cmd)
  if term_state.job_id and term_state.buf and vim.api.nvim_buf_is_valid(term_state.buf) then
    pcall(vim.api.nvim_chan_send, term_state.job_id, cmd .. "\n")
  end
end

-- Check if terminal is valid and open
local function is_term_valid()
  return term_state.buf 
    and vim.api.nvim_buf_is_valid(term_state.buf)
    and term_state.win
    and vim.api.nvim_win_is_valid(term_state.win)
end

-- Check if terminal buffer exists but window is hidden
local function is_term_hidden()
  return term_state.buf 
    and vim.api.nvim_buf_is_valid(term_state.buf)
    and (not term_state.win or not vim.api.nvim_win_is_valid(term_state.win))
end

-- Create or show terminal
local function create_or_show_terminal()
  if is_term_valid() then
    vim.api.nvim_set_current_win(term_state.win)
    return true
  end
  
  if is_term_hidden() then
    vim.cmd("belowright vsplit")
    term_state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term_state.win, term_state.buf)
    vim.cmd("startinsert")
    return true
  end
  
  -- Create terminal with default shell (bash/zsh on Linux)
  vim.cmd("belowright vsplit | terminal")
  
  term_state.buf = vim.api.nvim_get_current_buf()
  term_state.win = vim.api.nvim_get_current_win()
  term_state.job_id = vim.b.terminal_job_id
  
  -- Set up exit handler
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_state.buf,
    callback = function()
      term_state.buf = nil
      term_state.win = nil
      term_state.job_id = nil
      term_state.is_running = false
    end,
    once = true,
  })
  
  return false
end

-- Hide terminal (don't close)
local function hide_terminal()
  if is_term_valid() then
    vim.api.nvim_win_close(term_state.win, true)
    term_state.win = nil
  end
end

-- Build and run file
local function run_file()
  if term_state.is_running then
    print("Already running...")
    return
  end
  
  local file = vim.fn.expand("%:p")
  if file == "" or file == nil then
    print("No file to run")
    return
  end
  
  local ext = vim.fn.expand("%:e"):lower()
  local name = vim.fn.expand("%:t:r")
  local dir = vim.fn.expand("%:p:h")
  
  local template = templates[ext]
  if not template then
    print("Unsupported file type: ." .. ext)
    return
  end
  
  term_state.is_running = true
  
  local is_existing = create_or_show_terminal()
  
  -- Build commands for Linux shell
  local cd_cmd = 'cd "' .. dir .. '"'
  local full_cmd
  
  if template.compile then
    local compile_cmd = string.format(template.compile, file, dir .. "/" .. name)
    local run_cmd = string.format(template.run, dir .. "/" .. name)
    local cleanup_file = string.format(template.cleanup, dir .. "/" .. name)
    
    if ext == "java" then
      run_cmd = 'java "' .. name .. '"'
      cleanup_file = name .. ".class"
    end
    
    -- Compile, run, then cleanup
    full_cmd = compile_cmd .. ' && ' .. run_cmd .. ' ; sleep 0.5 && rm -f "' .. cleanup_file .. '"'
  else
    full_cmd = string.format(template.run, file)
  end
  
  local delay = is_existing and 100 or 400
  
  vim.defer_fn(function()
    send_to_term(cd_cmd)
    vim.defer_fn(function()
      send_to_term(full_cmd)
      vim.defer_fn(function()
        term_state.is_running = false
        vim.cmd("startinsert")
      end, 100)
    end, 200)
  end, delay)
end

-- Toggle terminal visibility
local function toggle_terminal()
  if is_term_valid() then
    hide_terminal()
  else
    create_or_show_terminal()
    vim.cmd("startinsert")
  end
end

-- Setup keymaps
function M.setup()
  vim.keymap.set("n", "<leader>w", function()
    run_file()
  end, { desc = "Run current file in terminal", noremap = true, silent = true })
  
  vim.keymap.set({"n", "t"}, "<leader>q", function()
    hide_terminal()
  end, { desc = "Hide terminal", noremap = true, silent = true })
  
  vim.keymap.set({"n", "t"}, "<C-`>", function()
    toggle_terminal()
  end, { desc = "Toggle terminal", noremap = true, silent = true })
end

return M
