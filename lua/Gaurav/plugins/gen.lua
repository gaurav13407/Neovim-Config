return {
  "David-Kunz/gen.nvim",
  opts = {
    -- Default model: Qwen2.5-Coder for reasoning and design
    model = "qwen2.5-coder:14b",
    host = "localhost",
    port = "11434",

    -- Vertical split for terminal workflow
    display_mode = "vertical-split",

    show_prompt = true,
    show_model = true,
    no_auto_close = true,  -- Keep chat window open!

    -- System prompt: compiler-style reasoning
    system_prompt = [[
You are a compiler and code reviewer for production code.

STRICT RULES:
- Do NOT invent functions, types, files, or APIs that don't exist.
- Only reason using the provided context.
- If context is insufficient, respond: "Insufficient context".
- Prefer correctness over verbosity.
- Avoid rewriting code unless explicitly asked.

OUTPUT STRUCTURE:
1. Bugs: Concrete issues with exact reasoning
2. Risks: Assumptions, edge cases, undefined behavior
3. Suggestions: Optional improvements, clearly marked, non-breaking
]],

    init = function()
      pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
    end,

    command = function(options)
      return "curl --silent --no-buffer -X POST http://"
        .. options.host .. ":"
        .. options.port
        .. "/api/chat -d $body"
    end,
  },

  config = function(_, opts)
    local gen = require("gen")
    gen.setup(opts)

    -- Store opts for later use
    local gen_opts = opts

    -- Initialize Coplito RAG system
    local coplito = require("Gaurav.coplito")
    coplito.setup({
      include_errors = true,
      include_symbols = true,
      include_full_file = false,
      window_size = 50,
    })

    -- Helper: Build RAG-enhanced prompt with error handling and chat history
    local function build_rag_prompt(user_input)
      if not user_input or user_input == "" then
        return ""
      end
      
      local success, result = pcall(function()
        return coplito.build_context_prompt(user_input, {
          include_errors = true,
          include_symbols = true,
          include_full_file = false,
          include_chat_history = true,  -- Enable chat history in RAG
          max_recent_chats = 3,          -- Last 3 conversations
          window_size = 50,
        })
      end)
      
      if not success then
        vim.notify("RAG Error: " .. tostring(result), vim.log.levels.ERROR)
        return user_input  -- Fallback to just the query
      end
      
      return result
    end

    -- Helper: Save chat exchange to history
    local current_chat_file = nil
    local function save_chat_exchange(user_query, ai_response)
      local chat_dir = vim.fn.expand("~/.config/nvim/chat_history")
      
      -- Create new chat file if needed
      if not current_chat_file then
        local timestamp = os.date("%Y-%m-%d_%H%M%S")
        current_chat_file = chat_dir .. "/chat_" .. timestamp .. ".txt"
        
        -- Write header
        local header = string.format("=== Chat Session: %s ===\n\n", os.date("%Y-%m-%d %H:%M:%S"))
        vim.fn.writefile({header}, current_chat_file)
      end
      
      -- Append exchange
      local exchange = {
        string.format("You: %s", user_query),
        "",
        string.format("AI: %s", ai_response or "[Response in progress...]"),
        "",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
        "",
      }
      
      vim.fn.writefile(exchange, current_chat_file, "a")
    end
    
    -- Helper: Reset chat session (start new file)
    local function reset_chat_session()
      current_chat_file = nil
    end

    -- Helper: Interactive chat with continuation support and persistent window
    local function start_interactive_chat(model_name, model_display)
      vim.notify("Gen → " .. model_display, vim.log.levels.INFO)
      coplito.show_context_summary()
      
      -- Track chat buffer for appending
      local chat_bufnr = nil
      
      -- Prompt for initial query
      vim.ui.input({ prompt = "💬 Query: " }, function(initial_query)
        if not initial_query or initial_query == "" then
          vim.notify("Chat cancelled", vim.log.levels.WARN)
          return
        end
        
        -- Build RAG prompt and execute directly
        local full_prompt = build_rag_prompt(initial_query)
        
        -- Save initial query
        save_chat_exchange(initial_query, nil)
        
        -- Use gen.nvim's prompt system with explicit model
        local opts = vim.tbl_extend("force", gen_opts, {
          model = model_name,
          prompt = full_prompt,
          replace = false,
        })
        
        -- Execute without model selection
        gen.exec(opts)
        
        -- After response, offer to continue with visible history
        vim.defer_fn(function()
          -- Get the gen output buffer
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname:match("Gen:") then
              chat_bufnr = buf
              break
            end
          end
          
          local function continue_conversation()
            -- Add separator to chat window
            if chat_bufnr and vim.api.nvim_buf_is_valid(chat_bufnr) then
              local lines = vim.api.nvim_buf_get_lines(chat_bufnr, 0, -1, false)
              vim.api.nvim_buf_set_lines(chat_bufnr, -1, -1, false, {
                "",
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                "💬 Continue conversation (or Esc to exit)",
                "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                "",
              })
              
              -- Scroll to bottom
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == chat_bufnr then
                  vim.api.nvim_win_set_cursor(win, {vim.api.nvim_buf_line_count(chat_bufnr), 0})
                  break
                end
              end
            end
            
            vim.ui.input({ 
              prompt = "💬 You: ",
              default = ""
            }, function(continue_query)
              if not continue_query or continue_query == "" then
                vim.notify("Chat ended. Chat history preserved in window.", vim.log.levels.INFO)
                return
              end
              
              -- Add user query to chat window
              if chat_bufnr and vim.api.nvim_buf_is_valid(chat_bufnr) then
                vim.api.nvim_buf_set_lines(chat_bufnr, -1, -1, false, {
                  "You: " .. continue_query,
                  "",
                  "AI: ",
                })
              end
              
              -- Save this exchange to history
              save_chat_exchange(continue_query, nil)
              
              -- Send follow-up with same model
              local continue_opts = vim.tbl_extend("force", gen_opts, {
                model = model_name,
                prompt = continue_query,
                replace = false,
              })
              gen.exec(continue_opts)
              
              -- Recursively continue
              vim.defer_fn(continue_conversation, 1000)
            end)
          end
          
          continue_conversation()
        end, 1000)
      end)
    end

    -- EXPLICIT MODEL COMMANDS (no menu, direct execution with RAG + continuation)
    vim.api.nvim_create_user_command("GenQwen", function()
      start_interactive_chat("qwen2.5-coder:14b", "Qwen 2.5 Coder 14B (Reasoning/Design)")
    end, { desc = "Gen: Qwen reasoning model with RAG" })

    vim.api.nvim_create_user_command("GenDeepSeek", function()
      start_interactive_chat("deepseek-coder-v2:16b", "DeepSeek Coder V2 16B (Bug Fix/Code)")
    end, { desc = "Gen: DeepSeek code model with RAG" })

    vim.api.nvim_create_user_command("GenPhi", function()
      start_interactive_chat("phi3.5:3.8b-mini-instruct-q4_K_M", "Phi 3.5 Mini (Fast/Sanity)")
    end, { desc = "Gen: Phi fast model with RAG" })

    -- MODEL-AWARE MENU (select model + run prompt with RAG + continuation)
    local function gen_model_menu(prompt_type, use_range)
      coplito.show_context_summary()
      vim.ui.select(
        {
          { name = "Qwen 2.5 Coder 14B (Reasoning/Design)", model = "qwen2.5-coder:14b" },
          { name = "DeepSeek Coder V2 16B (Bug Fix/Code)", model = "deepseek-coder-v2:16b" },
          { name = "Phi 3.5 Mini (Fast/Sanity)", model = "phi3.5:3.8b-mini-instruct-q4_K_M" },
        },
        {
          prompt = "Select model for Gen (RAG enabled):",
          format_item = function(item)
            return item.name
          end,
        },
        function(choice)
          if not choice then return end
          vim.notify("Gen → " .. choice.model, vim.log.levels.INFO)
          
          vim.schedule(function()
            if prompt_type == "chat" then
              -- Interactive chat with continuation + RAG
              vim.ui.input({ prompt = "Query: " }, function(query)
                if not query or query == "" then return end
                
                local full_prompt = build_rag_prompt(query)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = false,
                })
                gen.exec(opts)
                
                -- Continuation support
                vim.defer_fn(function()
                  local function continue_conv()
                    vim.ui.input({ prompt = "Continue? (Enter to continue, Esc to exit): " }, function(cont)
                      if not cont or cont == "" then return end
                      local continue_opts = vim.tbl_extend("force", gen_opts, {
                        model = choice.model,
                        prompt = cont,
                        replace = false,
                      })
                      gen.exec(continue_opts)
                      vim.defer_fn(continue_conv, 500)
                    end)
                  end
                  continue_conv()
                end, 500)
              end)
            elseif prompt_type == "explain" then
              -- Explain with RAG
              vim.ui.input({ prompt = "Optional query (or press Enter): " }, function(query)
                local prompt = query and query ~= "" and query or "Explain this code in detail."
                local full_prompt = build_rag_prompt(prompt)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = false,
                })
                gen.exec(opts)
              end)
            elseif prompt_type == "fix" then
              -- Fix with RAG
              vim.ui.input({ prompt = "Optional query (or press Enter to auto-fix): " }, function(query)
                local prompt = query and query ~= "" and query or "Fix all issues in this code."
                local full_prompt = build_rag_prompt(prompt)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = true, -- Replace code with fixed version
                })
                gen.exec(opts)
              end)
            elseif prompt_type == "review" then
              -- Review with RAG
              vim.ui.input({ prompt = "Optional query (or press Enter for full review): " }, function(query)
                local prompt = query and query ~= "" and query or "Provide a comprehensive code review covering bugs, security, performance, and best practices."
                local full_prompt = build_rag_prompt(prompt)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = false,
                })
                gen.exec(opts)
              end)
            elseif prompt_type == "enhance" then
              -- Enhance with RAG
              vim.ui.input({ prompt = "Optional query (or press Enter to auto-enhance): " }, function(query)
                local prompt = query and query ~= "" and query or "Enhance this code with better naming, error handling, documentation, and modern best practices."
                local full_prompt = build_rag_prompt(prompt)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = true, -- Replace with enhanced version
                })
                gen.exec(opts)
              end)
            elseif prompt_type == "summarize" then
              -- Summarize with RAG
              vim.ui.input({ prompt = "Optional query (or press Enter): " }, function(query)
                local prompt = query and query ~= "" and query or "Provide a concise summary of this code including its purpose, key functions, and dependencies."
                local full_prompt = build_rag_prompt(prompt)
                local opts = vim.tbl_extend("force", gen_opts, {
                  model = choice.model,
                  prompt = full_prompt,
                  replace = false,
                })
                gen.exec(opts)
              end)
            end
          end)
        end
      )
    end

    -- MENU COMMANDS with prompts and RAG
    vim.api.nvim_create_user_command("GenChat", function()
      gen_model_menu("chat")
    end, { desc = "Gen: Model menu → Chat with RAG" })

    vim.api.nvim_create_user_command("GenExplain", function()
      gen_model_menu("explain")
    end, { range = true, desc = "Gen: Model menu → Explain with RAG" })

    vim.api.nvim_create_user_command("GenFix", function()
      gen_model_menu("fix")
    end, { range = true, desc = "Gen: Model menu → Fix code with RAG" })

    vim.api.nvim_create_user_command("GenReview", function()
      gen_model_menu("review")
    end, { range = true, desc = "Gen: Model menu → Review code with RAG" })

    -- SIMPLE MODEL SELECTOR (no prompt)
    vim.api.nvim_create_user_command("GenModel", function()
      gen_model_menu(nil)
    end, { desc = "Gen: Select model only" })

    -- CHAT HISTORY MANAGEMENT COMMANDS
    vim.api.nvim_create_user_command("GenChatHistory", function()
      local chat_dir = vim.fn.expand("~/.config/nvim/chat_history")
      local files = vim.fn.systemlist("ls -t " .. chat_dir .. "/chat_*.txt 2>/dev/null")
      
      if #files == 0 then
        vim.notify("No chat history found", vim.log.levels.WARN)
        return
      end
      
      -- Format file list for selection
      local formatted = {}
      for i, file in ipairs(files) do
        local basename = vim.fn.fnamemodify(file, ":t")
        local timestamp = basename:match("chat_(%d%d%d%d%-%d%d%-%d%d_%d+)")
        table.insert(formatted, {
          display = string.format("%d. %s", i, timestamp or basename),
          path = chat_dir .. "/" .. basename
        })
      end
      
      vim.ui.select(formatted, {
        prompt = "Select chat to view:",
        format_item = function(item)
          return item.display
        end,
      }, function(choice)
        if not choice then return end
        
        -- Open chat file in new buffer
        vim.cmd("vnew " .. choice.path)
        vim.bo.buftype = "nofile"
        vim.bo.filetype = "markdown"
      end)
    end, { desc = "Gen: View chat history" })
    
    vim.api.nvim_create_user_command("GenChatClear", function()
      vim.ui.input({
        prompt = "Delete ALL chat history? Type 'yes' to confirm: "
      }, function(input)
        if input == "yes" then
          local chat_dir = vim.fn.expand("~/.config/nvim/chat_history")
          vim.fn.system("rm -f " .. chat_dir .. "/chat_*.txt")
          vim.notify("✅ Chat history cleared", vim.log.levels.INFO)
          reset_chat_session()
        else
          vim.notify("Cancelled", vim.log.levels.INFO)
        end
      end)
    end, { desc = "Gen: Clear all chat history" })
    
    vim.api.nvim_create_user_command("GenChatNew", function()
      reset_chat_session()
      vim.notify("✅ New chat session started", vim.log.levels.INFO)
    end, { desc = "Gen: Start new chat session" })

    -- COMPREHENSIVE PROMPT MENU (all 13 gen.nvim prompts + RAG + model selection)
    vim.api.nvim_create_user_command("GenMenu", function(opts)
      -- Show context summary first
      coplito.show_context_summary()
      
      -- All 13 prompts from gen.nvim + custom ones
      local prompts = {
        { name = "💬 Chat - Interactive conversation", action = "chat", replace = false },
        { name = "🔧 Fix Code - Fix bugs and errors", action = "fix", replace = true, needs_visual = true },
        { name = "🔍 Review Code - Comprehensive review", action = "review", replace = false, needs_visual = true },
        { name = "📝 Explain Code - Detailed explanation", action = "explain", replace = false, needs_visual = true },
        { name = "✨ Enhance Code - Improve quality", action = "enhance", replace = true, needs_visual = true },
        { name = "📋 Summarize - Concise summary", action = "summarize", replace = false, needs_visual = true },
        { name = "❓ Ask - Ask about code", action = "ask", replace = false },
        { name = "🔄 Change - Modify text/code", action = "change", replace = true, needs_visual = true },
        { name = "📊 Generate - Generate new code", action = "generate", replace = false },
        { name = "✏️ Enhance Wording - Better phrasing", action = "enhance_wording", replace = true, needs_visual = true },
        { name = "📖 Enhance Grammar - Fix grammar/spelling", action = "enhance_grammar", replace = true, needs_visual = true },
        { name = "🎯 Make Concise - Shorten text", action = "make_concise", replace = true, needs_visual = true },
        { name = "📝 Make List - Convert to list", action = "make_list", replace = true, needs_visual = true },
        { name = "📊 Make Table - Convert to table", action = "make_table", replace = true, needs_visual = true },
      }
      
      -- Step 1: Select prompt (show all prompts regardless of mode)
      vim.ui.select(prompts, {
        prompt = "Select prompt type:",
        format_item = function(item)
          return item.name
        end,
      }, function(prompt_choice)
        if not prompt_choice then return end
        
        -- Step 2: Select model
        vim.ui.select(
          {
            { name = "🧠 Qwen 2.5 Coder 14B - Reasoning/Design", model = "qwen2.5-coder:14b" },
            { name = "🐛 DeepSeek Coder V2 16B - Bug Fix/Review", model = "deepseek-coder-v2:16b" },
            { name = "⚡ Phi 3.5 Mini - Fast/Quick checks", model = "phi3.5:3.8b-mini-instruct-q4_K_M" },
          },
          {
            prompt = "Select model:",
            format_item = function(item)
              return item.name
            end,
          },
          function(model_choice)
            if not model_choice then return end
            
            vim.notify("Gen → " .. model_choice.model .. " (" .. prompt_choice.name .. ")", vim.log.levels.INFO)
            
            -- Step 3: Get user query
            vim.ui.input({ 
              prompt = "Query (or Enter for default): ",
              default = ""
            }, function(user_query)
              if user_query == nil then return end -- User cancelled
              
              vim.schedule(function()
                -- Build query based on prompt type
                local query = user_query
                if query == "" then
                  -- Default queries for each type
                  if prompt_choice.action == "chat" or prompt_choice.action == "ask" then
                    query = "Help me with this code."
                  elseif prompt_choice.action == "fix" then
                    query = "Fix all bugs and errors in this code."
                  elseif prompt_choice.action == "review" then
                    query = "Provide comprehensive code review covering bugs, security, performance, and best practices."
                  elseif prompt_choice.action == "explain" then
                    query = "Explain this code in detail."
                  elseif prompt_choice.action == "enhance" then
                    query = "Enhance this code with better naming, documentation, error handling, and best practices."
                  elseif prompt_choice.action == "summarize" then
                    query = "Provide a concise summary of this code."
                  elseif prompt_choice.action == "change" then
                    query = "Modify this code as needed."
                  elseif prompt_choice.action == "generate" then
                    query = "Generate code for this."
                  elseif prompt_choice.action == "enhance_wording" then
                    query = "Improve the wording of this text."
                  elseif prompt_choice.action == "enhance_grammar" then
                    query = "Fix grammar and spelling in this text."
                  elseif prompt_choice.action == "make_concise" then
                    query = "Make this text more concise."
                  elseif prompt_choice.action == "make_list" then
                    query = "Convert this to a bullet point list."
                  elseif prompt_choice.action == "make_table" then
                    query = "Convert this to a table format."
                  end
                end
                
                -- Build RAG prompt
                local full_prompt = build_rag_prompt(query)
                
                -- Execute with gen.nvim
                local exec_opts = vim.tbl_extend("force", gen_opts, {
                  model = model_choice.model,
                  prompt = full_prompt,
                  replace = prompt_choice.replace,
                })
                
                gen.exec(exec_opts)
                
                -- Add continuation for chat mode with persistent window
                if prompt_choice.action == "chat" or prompt_choice.action == "ask" then
                  vim.defer_fn(function()
                    -- Find chat buffer
                    local chat_bufnr = nil
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                      local buf = vim.api.nvim_win_get_buf(win)
                      local bufname = vim.api.nvim_buf_get_name(buf)
                      if bufname:match("Gen:") then
                        chat_bufnr = buf
                        break
                      end
                    end
                    
                    local function continue_conv()
                      -- Add separator
                      if chat_bufnr and vim.api.nvim_buf_is_valid(chat_bufnr) then
                        vim.api.nvim_buf_set_lines(chat_bufnr, -1, -1, false, {
                          "",
                          "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                          "💬 Continue conversation (or Esc to exit)",
                          "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
                          "",
                        })
                        
                        -- Scroll to bottom
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                          if vim.api.nvim_win_get_buf(win) == chat_bufnr then
                            vim.api.nvim_win_set_cursor(win, {vim.api.nvim_buf_line_count(chat_bufnr), 0})
                            break
                          end
                        end
                      end
                      
                      vim.ui.input({ prompt = "💬 You: " }, function(cont)
                        if not cont or cont == "" then 
                          vim.notify("Chat ended. History preserved in window.", vim.log.levels.INFO)
                          return 
                        end
                        
                        -- Add user message to chat
                        if chat_bufnr and vim.api.nvim_buf_is_valid(chat_bufnr) then
                          vim.api.nvim_buf_set_lines(chat_bufnr, -1, -1, false, {
                            "You: " .. cont,
                            "",
                            "AI: ",
                          })
                        end
                        
                        local continue_opts = vim.tbl_extend("force", gen_opts, {
                          model = model_choice.model,
                          prompt = cont,
                          replace = false,
                        })
                        gen.exec(continue_opts)
                        vim.defer_fn(continue_conv, 1000)
                      end)
                    end
                    continue_conv()
                  end, 1000)
                end
              end)
            end)
          end
        )
      end)
    end, { range = true, desc = "Gen: Comprehensive prompt menu with RAG" })

    -- RAG-SPECIFIC COMMANDS
    vim.api.nvim_create_user_command("CopiloContext", function()
      coplito.show_context_summary()
    end, { desc = "Coplito: Show context summary" })

    vim.api.nvim_create_user_command("CopiloPreview", function()
      vim.ui.input({ prompt = "Query to preview: " }, function(query)
        if query then
          coplito.preview_prompt(query)
        end
      end)
    end, { desc = "Coplito: Preview RAG prompt" })

    vim.api.nvim_create_user_command("CopiloErrors", function()
      local errors = require("Gaurav.coplito.errors")
      local error_ctx = errors.get_error_context()
      if #error_ctx == 0 then
        vim.notify("No errors found in current buffer", vim.log.levels.INFO)
      else
        vim.notify(string.format("Found %d error(s) in buffer", #error_ctx), vim.log.levels.INFO)
      end
    end, { desc = "Coplito: Check error context" })

    vim.api.nvim_create_user_command("CopiloSymbols", function()
      local symbols = require("Gaurav.coplito.symbols")
      local symbol_list = symbols.extract_symbols(0)
      if #symbol_list == 0 then
        vim.notify("No symbols found (Tree-sitter may not be available)", vim.log.levels.INFO)
      else
        vim.notify(string.format("Found %d symbols in buffer", #symbol_list), vim.log.levels.INFO)
      end
    end, { desc = "Coplito: Show symbols" })
  end,
}

