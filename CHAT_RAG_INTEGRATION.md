# 🧠 Chat History + RAG Integration

## 🎉 What's New

Your AI chat system now has **memory**! Old conversations are automatically:
- ✅ **Saved to disk** - Never lose a conversation
- ✅ **Added to RAG context** - AI remembers past discussions
- ✅ **Searchable** - View and load old chats
- ✅ **Priority 7 context** - Recent chats inform new responses

---

## 🔄 How It Works

### 1. **Auto-Save Every Exchange**
```
~/.config/nvim/chat_history/
  chat_2026-01-01_143022.txt
  chat_2026-01-01_151445.txt
  chat_2026-01-01_163310.txt
```

Every time you chat:
- Initial query → saved with timestamp
- Each continuation → appended to same file
- Session tracked until you start new chat

### 2. **RAG Pulls Recent Chats (Priority 7)**
When building context for new queries, RAG now includes:
```
[CODE CONTEXT]
## Recent Chat History (RAG Memory)
Last 3 conversations:
--- Chat from 2026-01-01_143022 ---
You: explain the calculate_sum function
AI: The function takes x and y but references undefined 'z'...
```

The AI sees your last **3 conversations** automatically!

### 3. **Context Priority Order**
```
Priority 1: Visual selection
Priority 2: Active file
Priority 3: Symbols
Priority 4: Errors  
Priority 5: Related symbols
Priority 6: Metadata
Priority 7: Chat history ⭐ NEW!
```

---

## 📝 Example Session

### Start Chat
```vim
:GenQwen
Query: "explain the calculate_sum function"
```

**Behind the scenes:**
1. RAG collects: errors, symbols, active file, **last 3 chats**
2. Saves: `~/.config/nvim/chat_history/chat_2026-01-01_143022.txt`
3. AI gets full context including past conversations!

### Continue Chat
```
💬 You: "how do I fix the bug?"
```

**Behind the scenes:**
1. Appends to same file: `chat_2026-01-01_143022.txt`
2. Next query will see this exchange in RAG context

### Close and Reopen
```vim
:q  " Close chat window
:GenQwen
Query: "are there other issues?"
```

**Behind the scenes:**
1. RAG loads: `chat_2026-01-01_143022.txt` (your previous chat!)
2. AI remembers: "We already discussed calculate_sum bug..."
3. Continues conversation context across sessions! 🎉

---

## 🎮 Commands

### View Chat History
```vim
:GenChatHistory
```
- Shows list of all past chats
- Select one to view in vertical split
- Sorted by newest first

### Start New Session
```vim
:GenChatNew
```
- Resets session (next chat creates new file)
- Previous chats still available in RAG
- Useful when switching topics

### Clear All History
```vim
:GenChatClear
```
- Type `yes` to confirm
- Deletes all chat files
- Resets RAG memory
- ⚠️ Cannot be undone!

---

## 📊 File Format

Each chat file:
```
=== Chat Session: 2026-01-01 14:30:22 ===

You: explain the calculate_sum function

AI: The function takes two parameters x and y...
    However, line 5 references undefined variable 'z'...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You: how do I fix it?

AI: Change line 5 from 'return x + y + z' to 'return x + y'...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🧪 Testing

### Test 1: Multi-Session Memory
```bash
# Session 1
nvim test.py
:GenQwen
Query: "what does this do?"

# Close Neovim
:qa

# Session 2 (NEW Neovim instance!)
nvim test.py
:GenQwen
Query: "continue from before"

# ✅ AI should reference previous conversation!
```

### Test 2: View History
```vim
:GenChatHistory
" Select a chat from list
" See full conversation in vertical split
```

### Test 3: Topic Switching
```vim
" Working on function A
:GenQwen
Query: "explain function A"

" Switch topics
:GenChatNew

" Working on function B
:GenQwen
Query: "explain function B"
" ✅ New file created, function A chat still in RAG context
```

---

## ⚙️ Configuration

### Adjust Chat History in RAG

Edit [lua/Gaurav/plugins/gen.lua](lua/Gaurav/plugins/gen.lua#L62):
```lua
return coplito.build_context_prompt(user_input, {
  include_errors = true,
  include_symbols = true,
  include_full_file = false,
  include_chat_history = true,
  max_recent_chats = 3,  -- Change this (1-10 recommended)
  window_size = 50,
})
```

**Options:**
- `max_recent_chats = 1` - Only most recent chat
- `max_recent_chats = 5` - Last 5 conversations (more context, slower)
- `max_recent_chats = 10` - Maximum history (may hit token limits)

### Disable Chat History in RAG
```lua
include_chat_history = false,  -- AI won't see old chats
```
- Files still saved
- Just not included in RAG context
- Use `:GenChatHistory` to view manually

---

## 🎯 Use Cases

### 1. **Long Debugging Sessions**
```
Session 1: "what's wrong with this function?"
Session 2: "did that fix work?"  ← AI remembers previous attempt!
Session 3: "any other issues?"   ← AI knows full history
```

### 2. **Project Onboarding**
```
Day 1: "explain the main.py architecture"
Day 2: "how does auth work?"     ← AI remembers main.py discussion
Day 3: "connect auth to main"    ← AI has both contexts!
```

### 3. **Iterative Refactoring**
```
Chat 1: "review this code"
Chat 2: "implement suggestion #2"
Chat 3: "test the refactor"      ← AI tracks entire refactor journey
```

### 4. **Knowledge Building**
```
Week 1: Learn API patterns
Week 2: Learn error handling
Week 3: Combine both           ← AI references week 1 + 2 chats!
```

---

## 🔍 How RAG Uses Chat History

When you ask: **"are there any other bugs?"**

RAG builds this context:
```
[ERROR CONTEXT]
Line 5: undefined variable 'z' (severity: Error)
[END ERROR CONTEXT]

[CODE CONTEXT]
## Active File
File: test.py:1-50 (cursor at line 5)
---
def calculate_sum(x, y):
    return x + y + z  # Bug: 'z' undefined
---

## Recent Chat History (RAG Memory)
Last 3 conversations:
--- Chat from 2026-01-01_143022 ---
You: explain the calculate_sum function
AI: The function has a bug on line 5: references undefined 'z'
You: how do I fix it?
AI: Change 'z' to just return x + y
---
[END CODE CONTEXT]

[USER QUERY]
are there any other bugs?
[END USER QUERY]

[RESPONSE RULES]
...
```

The AI sees:
1. Current error (Priority 4)
2. Code context (Priority 2)
3. **Past conversation** (Priority 7) ← Knows we already discussed 'z' bug!
4. Your new question

Result: **"The 'z' bug we discussed is the main issue. No other bugs found."**

---

## 📁 Files Changed

### New Files
- `~/.config/nvim/chat_history/` - Auto-created directory
- `chat_YYYY-MM-DD_HHMMSS.txt` - Individual chat sessions

### Modified Files
1. [lua/Gaurav/coplito/context.lua](lua/Gaurav/coplito/context.lua)
   - Added `get_chat_history()` function (Priority 7)
   - Reads last N chat files
   - Formats for RAG context

2. [lua/Gaurav/coplito/init.lua](lua/Gaurav/coplito/init.lua)
   - Updated `collect_context()` to include chat history
   - Added `include_chat_history` option
   - Added `max_recent_chats` option

3. [lua/Gaurav/coplito/prompt.lua](lua/Gaurav/coplito/prompt.lua)
   - Added `chat_history` chunk type formatting
   - Displays as "Recent Chat History (RAG Memory)"

4. [lua/Gaurav/plugins/gen.lua](lua/Gaurav/plugins/gen.lua)
   - Added `save_chat_exchange()` function
   - Auto-saves after each query
   - Tracks current session file
   - Added 3 new commands

---

## 🚀 New Commands Summary

| Command | Description |
|---------|-------------|
| `:GenChatHistory` | View list of all past chats |
| `:GenChatNew` | Start new chat session (new file) |
| `:GenChatClear` | Delete all chat history (confirm with 'yes') |

All existing commands still work:
- `:GenQwen`, `:GenDeepSeek`, `:GenPhi` - Direct model chat
- `<Ctrl+Shift+i>` - Full menu with 14 prompts
- `<leader>gq`, `<leader>gd`, `<leader>gp` - Quick chat
- `:GenMenu` - Comprehensive prompt menu

---

## 💡 Pro Tips

### 1. **Review Before Asking**
```vim
:GenChatHistory
" See what you already asked
" Avoid duplicate questions
```

### 2. **Clean Start for New Topics**
```vim
:GenChatNew
" Prevents context pollution
" Old chats still in RAG but new file created
```

### 3. **Reference Old Solutions**
```
You: "use the same fix we discussed for function A"
AI: [sees chat history] "Applying the x + y pattern..."
```

### 4. **Debugging Loops**
```
Session 1: Identify bug
Session 2: Try fix
Session 3: "did it work?" ← AI remembers the fix attempt!
```

### 5. **Knowledge Retrieval**
```
Week 1: "how do I use the logger?"
Week 2: (forgot)
Week 2: "show me logger usage again"
AI: [from chat history] "As we discussed last week..."
```

---

## ⚠️ Limitations

### 1. **Token Limits**
- More chat history = larger context
- May hit Ollama's token limit (usually 4096-8192)
- Reduce `max_recent_chats` if you see truncation

### 2. **Relevance**
- AI sees last N chats regardless of topic
- Use `:GenChatNew` when switching projects
- Or manually edit chat files to remove irrelevant parts

### 3. **Storage**
- Each chat file ~1-10 KB
- 100 chats ≈ 1 MB
- Use `:GenChatClear` periodically

### 4. **Privacy**
- Chats stored as plain text
- Contains code snippets and questions
- Clear history if sharing config: `:GenChatClear`

---

## 🎉 Summary

**Before:** Chat window persisted, but closed = lost forever

**Now:**
- ✅ Every chat saved automatically
- ✅ Last 3 chats included in RAG context
- ✅ AI remembers past conversations
- ✅ Commands to view/manage history
- ✅ Works across Neovim sessions
- ✅ Searchable and reviewable

**Result:** Your AI assistant has **memory** now! 🧠

It's like having a coworker who:
- Never forgets your previous discussions
- References past solutions
- Tracks your debugging journey
- Learns your codebase over time

---

**Test it:**
```bash
nvim test.py
:GenQwen
Query: "explain this file"
# ... AI responds ...
:qa

# Later...
nvim test.py
:GenQwen
Query: "based on our earlier discussion, what next?"
# ✅ AI references the previous chat!
```

🎊 **Your Neovim AI setup is now production-grade!**
