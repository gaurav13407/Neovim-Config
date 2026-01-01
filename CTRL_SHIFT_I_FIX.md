# Ctrl+Shift+i Fix

## What Was The Problem?

When you pressed `<C-S-i>` (Ctrl+Shift+i), it opened gen.nvim's built-in prompt menu, which then triggered another model selection screen, making it confusing and requiring multiple steps.

## What Changed?

Created a **custom prompt menu** (`GenMenu`) that integrates directly with our RAG system and model selection workflow.

### Old Behavior:
```
<C-S-i> → gen.nvim prompts → model selection → prompt again → finally execute
```

### New Behavior:
```
<C-S-i> → custom prompt menu → model selection → query input → execute
```

## How To Use Now

### 1. Press `Ctrl+Shift+i`
You'll see a menu with **14 prompt options**:
- 💬 **Chat** - Interactive conversation
- 🔧 **Fix Code** - Fix bugs and errors (visual mode)
- 🔍 **Review Code** - Comprehensive review (visual mode)
- 📝 **Explain Code** - Detailed explanation (visual mode)
- ✨ **Enhance Code** - Improve quality (visual mode)
- 📋 **Summarize** - Concise summary (visual mode)
- ❓ **Ask** - Ask about code
- 🔄 **Change** - Modify text/code (visual mode)
- 📊 **Generate** - Generate new code
- ✏️ **Enhance Wording** - Better phrasing (visual mode)
- 📖 **Enhance Grammar** - Fix grammar/spelling (visual mode)
- 🎯 **Make Concise** - Shorten text (visual mode)
- 📝 **Make List** - Convert to list (visual mode)
- 📊 **Make Table** - Convert to table (visual mode)

### 2. Select a Prompt Type
Choose what you want to do with your code.

### 3. Select Model
- 🧠 Qwen 2.5 Coder 14B - Reasoning/Design
- 🐛 DeepSeek Coder V2 16B - Bug Fix/Code Review
- ⚡ Phi 3.5 Mini - Fast/Sanity

### 4. Enter Your Query (with input box!)
Type your specific question or instruction, or press Enter for smart defaults:
- **Fix Code**: "Fix all bugs and errors"
- **Review Code**: "Comprehensive review"
- **Explain Code**: "Explain in detail"
- **Chat**: "Help me with this code"

### 5. Continue Conversation (for Chat/Ask)
After the model responds, you can continue the conversation!

## Examples

### Example 1: Fix Code
1. **Select code** in visual mode (v/V)
2. Press `Ctrl+Shift+i`
3. Choose "🔧 Fix Code"
4. Choose "DeepSeek" (best for bugs)
5. Type your instruction (optional - it will auto-detect context)
6. Get fixed code with explanation

### Example 2: Chat
1. In normal mode, press `Ctrl+Shift+i`
2. Choose "💬 Chat"
3. Choose "Qwen" (best for reasoning)
4. Type: "How do I optimize this function?"
5. Continue conversation

### Example 3: Review Code
1. Select function in visual mode
2. Press `Ctrl+Shift+i`
3. Choose "🔍 Review Code"
4. Choose "DeepSeek"
5. Get detailed code review

## Quick Reference

| Keybinding | What It Does |
|------------|--------------|
| `<C-S-i>` | Custom prompt menu (normal or visual mode) |
| `<leader>gq` | Direct Qwen chat (no menus) |
| `<leader>gd` | Direct DeepSeek chat (no menus) |
| `<leader>gp` | Direct Phi chat (no menus) |
| `<leader>gc` | Model selection → chat |

## Testing

**Test the fix:**
```bash
# Open neovim
nvim test.lua

# Press Ctrl+Shift+i in normal mode
# You should see the custom menu with Chat and Ask Question

# Select some code (visual mode), press Ctrl+Shift+i
# You should see all prompt options including Fix, Review, Explain
```

## Files Changed

1. `lua/Gaurav/plugins/gen.lua` - Added `GenMenu` command
2. `lua/Gaurav/core/keymaps.lua` - Changed `<C-S-i>` to use `:GenMenu<CR>`
3. `KEYBINDINGS.md` - Updated documentation

---

**Note**: Restart Neovim (`:qa!` and reopen) to apply changes!
