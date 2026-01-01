# 🎹 Complete Keybindings Reference

**Leader Key**: `<Space>`

---

## 📑 Table of Contents

1. [General Editing](#-general-editing)
2. [Window & Navigation](#-window--navigation)
3. [File Navigation](#-file-navigation)
4. [Fuzzy Finding (Telescope)](#-fuzzy-finding-telescope)
5. [LSP & Diagnostics](#-lsp--diagnostics)
6. [Coplito AI System](#-coplito-ai-system)
7. [Terminal](#-terminal)
8. [Sessions](#-sessions)
9. [Editing Utilities](#-editing-utilities)
10. [Quick Reference Card](#-quick-reference-card)

---

## 🔤 General Editing

### Basic Operations
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>v` | Normal | Paste after cursor | Core |
| `<leader>V` | Normal | Paste before cursor | Core |
| `<leader>p` | Visual | Paste without replacing clipboard | Core |
| `p` | Visual | Paste over selection (no clipboard replace) | Core |
| `<leader>d` | Normal/Visual | Delete to void register (no clipboard) | Core |
| `X` | Normal | Delete character without yanking | Core |

### Movement
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `J` | Visual | Move selected lines down | Core |
| `K` | Visual | Move selected lines up | Core |
| `J` | Normal | Join lines (keep cursor position) | Core |
| `<C-d>` | Normal | Scroll down half page (cursor centered) | Core |
| `<C-u>` | Normal | Scroll up half page (cursor centered) | Core |
| `n` | Normal | Next search result (centered) | Core |
| `N` | Normal | Previous search result (centered) | Core |

### Insert Mode
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `jk` | Insert | Exit insert mode | Core |
| `kj` | Insert | Exit insert mode | Core |
| `<C-c>` | Insert | Exit insert mode (alternative) | Core |
| `<C-h>` | Insert | LSP signature help | LSP |

### Formatting & Manipulation
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>f` | Normal | Format buffer with LSP | LSP |
| `<leader>s` | Normal | Search & replace word under cursor globally | Core |
| `<leader>x` | Normal | Make current file executable | Core |
| `<` | Visual | Unindent (keep selection) | Core |
| `>` | Visual | Indent (keep selection) | Core |
| `<leader>cw` | Normal | Trim trailing whitespace | Mini.trailspace |
| `sj` | Normal/Visual | Join function arguments | Mini.splitjoin |
| `sk` | Normal/Visual | Split function arguments | Mini.splitjoin |

### Surround Operations
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `sa` | Normal/Visual | Surround add (e.g., `saW"` wraps word in quotes) | Mini.surround |
| `sd` | Normal | Surround delete (e.g., `sd"` removes quotes) | Mini.surround |
| `sr` | Normal | Surround replace (e.g., `sr"'` replaces quotes) | Mini.surround |

### Misc
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `Q` | Normal | Disabled (no-op) | Core |
| `<leader>fp` | Normal | Copy file path to clipboard | Core |

---

## 🪟 Window & Navigation

### Window Navigation
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<Tab>` | Normal | Cycle to next window | Core |
| `<S-Tab>` | Normal | Cycle to previous window | Core |
| `<C-h>` | Normal | Move to left window | Core |
| `<C-j>` | Normal | Move to down window | Core |
| `<C-k>` | Normal | Move to up window | Core |
| `<C-l>` | Normal | Move to right window | Core |

### Split Management
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>sd` | Normal | Split window vertically | Core |
| `<leader>sh` | Normal | Split window horizontally | Core |
| `<leader>se` | Normal | Make splits equal size | Core |
| `<leader>sf` | Normal | Close current split | Core |

### Tab Management
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>to` | Normal | Open new tab | Core |
| `<leader>tx` | Normal | Close current tab | Core |
| `<leader>tn` | Normal | Go to next tab | Core |
| `<leader>tp` | Normal | Go to previous tab | Core |
| `<leader>tf` | Normal | Open current file in new tab | Core |

---

## 📁 File Navigation

### Oil (File Manager)
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `f` | Normal | Open oil file manager | Oil.nvim |
| `<leader>fff` | Normal | Open oil in floating window | Oil.nvim |

**Oil Navigation** (inside oil buffer):
- `<CR>` - Open file/directory
- `-` - Go to parent directory
- `g?` - Show help

### Mini.files (File Explorer)
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>ee` | Normal | Toggle mini.files explorer | Mini.files |
| `<leader>ef` | Normal | Open mini.files at current file location | Mini.files |

### Harpoon (Quick Marks)
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>a` | Normal | Add current file to harpoon | Harpoon |
| `<C-e>` | Normal | Toggle harpoon quick menu | Harpoon |
| `<C-y>` | Normal | Jump to harpoon file 1 | Harpoon |
| `<C-i>` | Normal | Jump to harpoon file 2 | Harpoon |
| `<C-n>` | Normal | Jump to harpoon file 3 | Harpoon |
| `<C-s>` | Normal | Jump to harpoon file 4 | Harpoon |
| `<C-S-P>` | Normal | Go to previous harpoon file | Harpoon |
| `<C-S-N>` | Normal | Go to next harpoon file | Harpoon |

---

## 🔍 Fuzzy Finding (Telescope)

| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>pr` | Normal | Find recent files (oldfiles) | Telescope |
| `<leader>pWs` | Normal | Grep word under cursor in workspace | Telescope |
| `<leader>th` | Normal | Open theme switcher | Telescope |
| `<leader>/` | Normal | Fuzzy search in current buffer | Telescope |

**Telescope Mappings** (inside telescope):
- `<C-j>` / `<C-k>` - Move selection down/up
- `<CR>` - Select entry
- `<C-c>` / `<Esc>` - Close telescope
- `<C-x>` - Open in horizontal split
- `<C-v>` - Open in vertical split
- `<C-t>` - Open in new tab

---

## 🔧 LSP & Diagnostics

### Go To
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `gD` | Normal | Go to declaration | LSP |
| `gd` | Normal | Go to definition (telescope) | LSP |
| `gi` | Normal | Go to implementation (telescope) | LSP |
| `gt` | Normal | Go to type definition (telescope) | LSP |
| `gR` | Normal | Show references (telescope) | LSP |

### Documentation & Info
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `K` | Normal | Show hover documentation | LSP |
| `<C-h>` | Insert | Show signature help | LSP |

### Code Actions
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>vca` | Normal/Visual | Show code actions | LSP |
| `<leader>rn` | Normal | Rename symbol | LSP |
| `<leader>f` | Normal | Format buffer | LSP |

### Diagnostics
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>D` | Normal | Show buffer diagnostics (telescope) | LSP |
| `<leader>d` | Normal | Show diagnostic float for current line | LSP |
| `]d` | Normal | Next diagnostic | LSP (built-in) |
| `[d` | Normal | Previous diagnostic | LSP (built-in) |

### LSP Management
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>rs` | Normal | Restart LSP server | LSP |

---

## 🤖 Coplito AI System

### Direct Model Access (with RAG)
| Key | Mode | Action | What It Does |
|-----|------|--------|--------------|
| `<leader>gq` | Normal | **Qwen + RAG** | Opens Qwen 14B with automatic context (best for reasoning & design) |
| `<leader>gd` | Normal | **DeepSeek + RAG** | Opens DeepSeek 16B with context (best for bug finding & code review) |
| `<leader>gp` | Normal | **Phi + RAG** | Opens Phi 3.8B with context (fastest, good for quick checks) |

**What happens:**
1. Shows context summary notification
2. Automatically collects:
   - Visual selection (if any)
   - Active file content
   - LSP errors (if any)
   - Tree-sitter symbols
3. Prompts you to enter your query
4. Model responds with full RAG context
5. **After response, you can continue the conversation!**
   - Just enter your next question
   - Press Esc to end chat
6. All queries use structured RAG prompts

### Menu-Based Commands
| Key | Mode | Action | What It Does |
|-----|------|--------|--------------|
| `<leader>gc` | Normal | **Gen Chat (model menu)** | Opens model selection menu, then chat |
| `<C-S-i>` | Normal/Visual | **Gen Prompt Menu** | Custom prompt menu (Chat, Fix, Review, Explain) with RAG |
| `<leader>gm` | Normal | **Select Model** | Model selection only (no prompt) |

**Ctrl+Shift+i workflow:**
1. Press `<C-S-i>` (Ctrl+Shift+i)
2. Select prompt type:
   - 💬 Chat - Interactive conversation
   - 🔧 Fix Code - Fix selected code (visual mode)
   - 🔍 Review Code - Code review (visual mode)
   - 📝 Explain Code - Explain code (visual mode)
   - 🎯 Ask Question - Ask about current context
3. Select model (Qwen/DeepSeek/Phi)
4. Enter your query
5. Continue conversation after response

### Code-Specific AI (Visual Mode)
| Key | Mode | Action | What It Does |
|-----|------|--------|--------------|
| `<leader>ge` | Visual | **Explain + RAG** | Select model → explain selected code with full context |
| `<leader>gf` | Visual | **Fix + RAG** | Select model → fix selected code (includes LSP errors!) |
| `<leader>gr` | Visual | **Review + RAG** | Select model → comprehensive code review |

**Visual mode workflow:**
1. Select code in visual mode
2. Press keybinding
3. Choose model from menu
4. Model gets:
   - Your exact selection (highest priority)
   - LSP errors at that location
   - Surrounding context
   - Related symbols

### Context Inspection
| Key | Mode | Action | What It Shows |
|-----|------|--------|---------------|
| `<leader>ci` | Normal | **Show context** | Display: Errors count, Symbols count, Selection status, File name |
| `<leader>cp` | Normal | **Preview prompt** | Opens split with full RAG prompt structure before sending |
| `<leader>ce` | Normal | **Check errors** | Show LSP error count in current buffer |
| `<leader>cs` | Normal | **Show symbols** | Display Tree-sitter symbol count in buffer |

### AI Commands (Ex mode)
| Command | What It Does |
|---------|--------------|
| `:GenQwen` | Qwen model + RAG |
| `:GenDeepSeek` | DeepSeek model + RAG |
| `:GenPhi` | Phi model + RAG |
| `:GenChat` | Model menu → chat |
| `:GenExplain` | Model menu → explain (range) |
| `:GenFix` | Model menu → fix (range) |
| `:GenReview` | Model menu → review (range) |
| `:GenModel` | Model selection only |
| `:CopiloContext` | Context summary |
| `:CopiloPreview` | Preview prompt |
| `:CopiloErrors` | Error context |
| `:CopiloSymbols` | Symbol list |

---

## 🖥️ Terminal

| Key | Mode | Action | What It Does |
|-----|------|--------|--------------|
| `<leader>w` | Normal | **Run current file** | Smart runner - detects filetype, compiles if needed, runs |
| `<leader>q` | Normal/Terminal | **Kill terminal** | Stops running process, closes terminal |
| `<C-`>` | Normal/Terminal | **Toggle terminal** | Show/hide terminal window |

**Smart Terminal Features:**
- Auto-detects file type
- Compiles for C/C++/Java/Rust
- Auto-cleans compiled files
- Preserves terminal for multiple runs
- Works with: Python, Node.js, Lua, Shell, Go, and more

---

## 💾 Sessions

| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>wr` | Normal | Restore session for current directory | Auto-session |
| `<leader>ws` | Normal | Save session for current directory | Auto-session |

**Auto-session behavior:**
- Auto-saves on exit
- Auto-restores on startup (if session exists)
- Per-directory sessions

---

## ✏️ Editing Utilities

### TODO Comments
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `]t` | Normal | Jump to next TODO comment | Todo-comments |
| `[t` | Normal | Jump to previous TODO comment | Todo-comments |

**Recognized keywords:**
- `TODO:`, `HACK:`, `BUG:`, `FIXME:`, `WARNING:`, `NOTE:`

### Undo Tree
| Key | Mode | Action | Plugin/Source |
|-----|------|--------|---------------|
| `<leader>u` | Normal | Toggle undo tree visualizer | Undotree |

**Undo tree navigation:**
- `j`/`k` - Navigate undo history
- `<CR>` - Restore to selected state

---

## 🎯 Quick Reference Card

### Most Used Keybindings

#### Essential (Muscle Memory)
```
<Space>     Leader key
jk/kj       Exit insert mode
<C-h/j/k/l> Window navigation
f           File manager (Oil)
<leader>gq  AI with Qwen
<leader>ci  Check AI context
```

#### File Navigation
```
<leader>pr  Recent files
<leader>ee  File explorer
<leader>a   Harpoon add
<C-e>       Harpoon menu
```

#### Code Navigation
```
gd          Go to definition
gR          Show references
K           Hover docs
<leader>vca Code actions
```

#### AI Assistance
```
<leader>gq  Qwen (reasoning)
<leader>gd  DeepSeek (bugs)
<leader>gp  Phi (fast)
<leader>ge  Explain (visual)
<leader>gf  Fix (visual)
<leader>ci  Context info
```

#### Terminal
```
<leader>w   Run file
<leader>q   Kill terminal
<C-`>       Toggle terminal
```

---

## 💡 Pro Tips

### Tip 1: Context-Aware AI
When using AI commands (`<leader>gq/gd/gp`):
1. Place cursor in function you want to analyze
2. OR select code in visual mode
3. Press AI keybinding
4. Context is automatically collected!

### Tip 2: Error-First AI
When you see LSP errors:
1. Press `<leader>gd` (DeepSeek is best for bugs)
2. Ask: "Why is this failing?"
3. Model automatically gets error messages!

### Tip 3: Preview Before Sending
Not sure what context AI will see?
1. Press `<leader>cp`
2. Type your query
3. See full structured prompt before sending

### Tip 4: Harpoon Workflow
Fast file switching:
1. `<leader>a` to add files (up to 4)
2. `<C-y/i/n/s>` to jump instantly
3. No fuzzy finding needed!

### Tip 5: Visual Selection + AI
Most powerful AI workflow:
1. Select complex code (visual mode)
2. `<leader>gr` (Review)
3. Choose DeepSeek
4. Get detailed analysis of exact selection

---

## 🎨 Cheat Sheet (Print-Friendly)

```
╔══════════════════════════════════════════════════════════════╗
║                   NEOVIM KEYBINDINGS CHEAT SHEET            ║
╠══════════════════════════════════════════════════════════════╣
║ LEADER: <Space>                                             ║
╠══════════════════════════════════════════════════════════════╣
║ ESSENTIAL                                                    ║
║   jk/kj          Exit insert    │   <C-hjkl>   Window nav   ║
║   <Space>gc      AI Chat         │   f          File mgr     ║
║   <Space>gq      AI Qwen         │   <Space>pr  Recent files ║
║   <Space>ci      AI Context      │   <Space>u   Undo tree    ║
╠══════════════════════════════════════════════════════════════╣
║ LSP                                                          ║
║   gd             Definition       │   K          Hover       ║
║   gR             References       │   <Space>rn  Rename      ║
║   <Space>vca     Code action      │   <Space>d   Diagnostic  ║
╠══════════════════════════════════════════════════════════════╣
║ AI (RAG)                                                     ║
║   <Space>gq      Qwen (reason)    │   <Space>gd  DeepSeek    ║
║   <Space>gp      Phi (fast)       │   <Space>ge  Explain(v)  ║
║   <Space>gf      Fix(visual)      │   <Space>gr  Review(v)   ║
║   <Space>ci      Context          │   <Space>cp  Preview     ║
╠══════════════════════════════════════════════════════════════╣
║ TERMINAL                                                     ║
║   <Space>w       Run file         │   <C-`>      Toggle      ║
║   <Space>q       Kill terminal    │                          ║
╠══════════════════════════════════════════════════════════════╣
║ HARPOON                                                      ║
║   <Space>a       Add file         │   <C-e>      Menu        ║
║   <C-y/i/n/s>    Jump to 1/2/3/4  │                          ║
╚══════════════════════════════════════════════════════════════╝
```

---

**Last Updated**: January 2026  
**Total Keybindings**: 100+  
**Most Used**: 20-30  

**Remember**: You don't need to memorize all! Start with essentials, build muscle memory gradually.
