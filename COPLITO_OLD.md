# Coplito - Local GenAI Neovim Assistant

**Status**: ✅ Fully configured and ready to use

---

## Architecture

- **Editor**: Neovim
- **Plugin**: gen.nvim (prompt runner + UI)
- **Models**: Ollama (local inference)
- **Logic**: Lua (deterministic routing)

---

## Available Models

| Model | Purpose | Size | Command |
|-------|---------|------|---------|
| Qwen 2.5 Coder 14B | Reasoning, Design, Complex Tasks | 9 GB | `:GenQwen` |
| DeepSeek Coder V2 16B | Bug Finding, Code Review | 8.9 GB | `:GenDeepSeek` |
| Phi 3.5 Mini | Fast Sanity Checks | 2.4 GB | `:GenPhi` |

---

## Commands

### Explicit Model Commands (Direct)
These commands skip the menu and launch directly with a specific model:

- `:GenQwen` - Use Qwen for reasoning/design tasks
- `:GenDeepSeek` - Use DeepSeek for bug fixes and code review
- `:GenPhi` - Use Phi for quick sanity checks

### Menu-Based Commands (Select Model)
These commands show a model selection menu first:

- `:GenChat` - Chat mode with model selection
- `:GenExplain` - Explain selected code (visual mode)
- `:GenFix` - Fix selected code (visual mode)
- `:GenReview` - Review selected code (visual mode)
- `:GenModel` - Select model only (no prompt)

---

## Keybindings

### Model Selection (Direct)
- `<leader>gq` - Qwen (Reasoning)
- `<leader>gd` - DeepSeek (Bug finding)
- `<leader>gp` - Phi (Fast checks)

### Prompt Commands (Menu)
- `<leader>gc` - Chat with model selection
- `<leader>ge` - Explain code (visual)
- `<leader>gf` - Fix code (visual)
- `<leader>gr` - Review code (visual)
- `<leader>gm` - Select model

### General
- `<C-S-i>` - Open Gen prompt menu

---

## System Prompt Philosophy

Coplito behaves like a **compiler + code reviewer**, NOT a chatbot.

**Rules enforced:**
- Never invent functions, types, or APIs
- Only reason from provided context
- Say "Insufficient context" when needed
- Prefer correctness over verbosity
- Avoid rewriting unless asked

**Output structure:**
1. **Bugs**: Concrete issues with reasoning
2. **Risks**: Assumptions and edge cases
3. **Suggestions**: Optional improvements

---

## UI Behavior

- Opens in **vertical split** (right side)
- Terminal-friendly, keyboard-only navigation
- No floating windows or auto-close
- Model name visible in UI

---

## Model Strategy

**One active model at a time.**
Models are NOT interchangeable.

- Default: Qwen 2.5 Coder 14B
- Switching: Explicit via commands or menu
- No silent background switching
- User always knows which model is active

---

## Workflow Examples

### 1. Quick Reasoning Task
```
:GenQwen
> Why does this function return nil?
```

### 2. Bug Fix with Code Review
Select buggy code in visual mode, then:
```
<leader>gf  (opens model menu)
Select: DeepSeek Coder V2 16B
```

### 3. Fast Sanity Check
```
<leader>gp
> Does this validate email correctly?
```

### 4. Code Review Session
Select code block, then:
```
<leader>gr
Select: DeepSeek Coder V2 16B
```

---

## Technical Details

### Configuration Files
- Plugin: `lua/Gaurav/plugins/gen.lua`
- Keymaps: `lua/Gaurav/core/keymaps.lua`
- Models: `lua/Gaurav/plugins/ollama.lua`

### Model Routing
All routing logic lives in `gen.lua`:
- Explicit commands for direct model access
- Menu function for prompted selection
- No modification of gen.nvim internals

### Context Discipline
System prompt enforces strict reasoning:
- No hallucinations
- Explicit about insufficient context
- Compiler-style output
- Separated concerns (bugs/risks/suggestions)

---

## Troubleshooting

### Check Ollama Status
```bash
pgrep -f "ollama serve"  # Should return PID
ollama list              # Should show all models
```

### Restart Ollama
```bash
pkill -f "ollama serve"
ollama serve > /dev/null 2>&1 &
```

### Pull Missing Models
```bash
ollama pull qwen2.5-coder:14b
ollama pull deepseek-coder-v2:16b
ollama pull phi3.5:3.8b-mini-instruct-q4_K_M
```

### Check Model Response
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:14b",
  "messages": [{"role": "user", "content": "hello"}]
}'
```

---

## Design Principles

✅ **DO:**
- Use explicit commands
- Keep one model active at a time
- Trust the system prompt
- Work in terminal workflow
- Prefer determinism

❌ **DON'T:**
- Auto-switch models
- Modify gen.nvim internals
- Use floating windows
- Guess user intent
- Compromise reliability for "cleverness"

---

**Built**: January 2026  
**Philosophy**: Determinism over magic. Correctness over speed.
