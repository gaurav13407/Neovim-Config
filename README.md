# Neovim Configuration with Coplito AI

<div align="center">

**A production-ready Neovim setup with local AI assistance (Coplito RAG system)**

![Neovim](https://img.shields.io/badge/Neovim-0.10+-green.svg)
![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)
![RAG](https://img.shields.io/badge/RAG-Enabled-purple.svg)
![Local](https://img.shields.io/badge/AI-Local%20Only-orange.svg)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Folder Structure](#-folder-structure)
- [Plugin Overview](#-plugin-overview)
- [Coplito AI System](#-coplito-ai-system)
- [Complete Keybindings](#-complete-keybindings)
- [Configuration](#-configuration)
- [Testing](#-testing)
- [Documentation](#-documentation)

---

## ✨ Features

### Core Features
- 🚀 **Lazy.nvim** - Fast plugin manager
- 🎨 **Multiple Colorschemes** - Customizable themes with live preview
- 📁 **File Navigation** - Oil.nvim, Telescope, Harpoon, Mini.files
- 💡 **LSP Support** - Full Language Server Protocol integration
- 🔄 **Auto-completion** - nvim-cmp with multiple sources
- 🌳 **Tree-sitter** - Advanced syntax highlighting & parsing
- 📝 **Session Management** - Auto-save/restore sessions
- ⚡ **Smart Terminal** - Integrated terminal runner

### 🤖 Coplito AI System (NEW)
- **RAG (Retrieval-Augmented Generation)** - Context-aware AI assistance
- **Local-First** - Runs entirely on your machine (Ollama)
- **Error-Aware** - LSP diagnostics integrated as ground truth
- **Symbol-Aware** - Tree-sitter based code understanding
- **Multi-Model** - Qwen 14B, DeepSeek 16B, Phi 3.8B
- **Structured Prompts** - Deterministic context injection
- **Zero Hallucinations** - Grounded in actual code context

---

## 📦 Requirements

### System Requirements
- **Neovim** >= 0.10.0
- **Git**
- **Node.js** (for some LSP servers)
- **GCC/Make** (for Telescope fzf native)
- **Ollama** (for AI features)
- **GPU** - 8GB+ VRAM recommended for AI models

### For AI Features
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull models
ollama pull qwen2.5-coder:14b
ollama pull deepseek-coder-v2:16b
ollama pull phi3.5:3.8b-mini-instruct-q4_K_M
```

---

## 🚀 Installation

1. **Backup existing config**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this repo**
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **Launch Neovim**
   ```bash
   nvim
   ```
   Plugins will auto-install via Lazy.nvim

4. **Start Ollama** (for AI features)
   ```bash
   ollama serve
   ```

5. **Test the setup**
   ```bash
   cd ~/.config/nvim
   ./test_coplito.sh  # Test models
   ./test_rag.sh      # Test RAG system
   ```

---

## 📁 Folder Structure

```
~/.config/nvim/
├── init.lua                      # Main entry point
├── lazy-lock.json               # Plugin versions lock file
│
├── lua/Gaurav/
│   ├── lazy.lua                 # Plugin manager setup
│   │
│   ├── core/                    # Core configuration
│   │   ├── init.lua            # Core module loader
│   │   ├── keymaps.lua         # Global keybindings
│   │   ├── options.lua         # Neovim options
│   │   └── terminal.lua        # Smart terminal runner
│   │
│   ├── plugins/                 # Plugin configurations
│   │   ├── init.lua            # Plugin loader
│   │   ├── auto-pairs.lua      # Auto bracket pairing
│   │   ├── auto-sessions.lua   # Session management
│   │   ├── colorscheme.lua     # Theme configuration
│   │   ├── gen.lua             # AI integration (Coplito)
│   │   ├── harpoon.lua         # Quick file navigation
│   │   ├── mini.lua            # Mini.nvim modules
│   │   ├── nvim-cmp.lua        # Autocompletion
│   │   ├── oil.lua             # File manager
│   │   ├── ollama.lua          # Ollama configuration
│   │   ├── snacks.lua          # Snacks.nvim utilities
│   │   ├── telescope.lua       # Fuzzy finder
│   │   ├── todo-comments.lua   # TODO highlighting
│   │   ├── undotree.lua        # Undo history visualizer
│   │   │
│   │   └── lsp/                # LSP configuration
│   │       ├── lspconfig.lua   # LSP server configs
│   │       └── mason.lua       # LSP installer
│   │
│   └── coplito/                 # RAG AI System (NEW)
│       ├── init.lua            # Main RAG orchestrator
│       ├── context.lua         # Context collection
│       ├── symbols.lua         # Symbol extraction (Tree-sitter)
│       ├── errors.lua          # Error handling (LSP)
│       └── prompt.lua          # Structured prompt builder
│
├── after/                       # After plugins load
├── ftplugin/                    # Filetype specific configs
│
├── COPLITO.md                   # Coplito system docs
├── QUICKSTART.md                # Quick start guide
├── RAG_IMPLEMENTATION.md        # RAG implementation details
├── STATUS.md                    # Implementation status
├── instruction.md               # Full specification
├── test_coplito.sh              # Model tests
└── test_rag.sh                  # RAG system tests
```

---

## 🔌 Plugin Overview

### Navigation & Files
| Plugin | Purpose | Key Bindings |
|--------|---------|--------------|
| **Telescope** | Fuzzy finder | `<leader>pr` recent files, `<leader>th` themes |
| **Oil.nvim** | File manager | `f` open oil, `<leader>fff` float |
| **Harpoon** | Quick navigation | `<leader>a` add, `<C-e>` menu |
| **Mini.files** | File explorer | `<leader>ee` toggle, `<leader>ef` open at file |

### Editing
| Plugin | Purpose | Key Bindings |
|--------|---------|--------------|
| **nvim-cmp** | Autocompletion | `<C-Space>` trigger, `<CR>` confirm |
| **Auto-pairs** | Bracket pairing | Automatic |
| **Mini.surround** | Surround text | `sa` add, `sd` delete, `sr` replace |
| **Mini.splitjoin** | Split/join args | `sj` join, `sk` split |
| **Undotree** | Undo history | `<leader>u` toggle |

### LSP & Diagnostics
| Plugin | Purpose | Key Bindings |
|--------|---------|--------------|
| **lspconfig** | LSP servers | `gd` def, `gr` refs, `K` hover |
| **Mason** | LSP installer | Auto-managed |
| **Todo-comments** | TODO tracking | `]t` next, `[t` prev |

### AI & Code Assistance
| Plugin | Purpose | Key Bindings |
|--------|---------|--------------|
| **Coplito RAG** | Local AI assistant | `<leader>gq` Qwen, `<leader>ci` context |
| **gen.nvim** | Ollama integration | `<leader>gc` chat, `<leader>gf` fix |

### UI & Utilities
| Plugin | Purpose | Key Bindings |
|--------|---------|--------------|
| **Colorscheme** | Themes | `<leader>th` switcher |
| **Snacks.nvim** | UI components | Various notifications |
| **Auto-sessions** | Session mgmt | `<leader>wr` restore, `<leader>ws` save |

---

## 🤖 Coplito AI System

### Architecture
Coplito is a **RAG-enabled local AI coding assistant** that:

1. **Collects Context** (Priority-based)
   - Visual selection (highest)
   - Active file window
   - Tree-sitter symbols
   - LSP errors
   - Project metadata

2. **Builds Structured Prompts**
   ```
   [ERROR CONTEXT]   ← LSP diagnostics
   [CODE CONTEXT]    ← Code + symbols
   [USER QUERY]      ← Your question
   [RESPONSE RULES]  ← Constraints
   ```

3. **Sends to Local Model** (Ollama)
   - Qwen 2.5 Coder 14B (reasoning)
   - DeepSeek Coder V2 16B (bugs)
   - Phi 3.5 Mini (fast)

### Models
| Model | VRAM | Best For | Speed |
|-------|------|----------|-------|
| Qwen 14B | 9 GB | Complex reasoning, design | Medium |
| DeepSeek 16B | 9 GB | Bug finding, code review | Medium |
| Phi 3.8B | 2.4 GB | Quick checks, sanity tests | Fast |

### Commands
- `:GenQwen` - Qwen + automatic context
- `:GenDeepSeek` - DeepSeek + context
- `:GenPhi` - Phi + context
- `:GenChat` - Model selection menu
- `:CopiloContext` - Show context summary
- `:CopiloPreview` - Preview full prompt
- `:CopiloErrors` - Check LSP errors
- `:CopiloSymbols` - List symbols

### Features
- ✅ **Zero hallucinations** - Grounded in actual code
- ✅ **Error-first** - LSP diagnostics as ground truth
- ✅ **Symbol-aware** - Understands code structure
- ✅ **Transparent** - Inspect context anytime
- ✅ **Local** - No cloud, no data leaks
- ✅ **Deterministic** - Same input → same output

---

## ⌨️ Complete Keybindings

### Leader Key
**Leader** = `<Space>`

### 🔤 General Editing
| Key | Mode | Action |
|-----|------|--------|
| `<leader>v` | Normal | Paste |
| `<leader>V` | Normal | Paste before |
| `J` | Visual | Move lines down |
| `K` | Visual | Move lines up |
| `<C-d>` | Normal | Page down (centered) |
| `<C-u>` | Normal | Page up (centered) |
| `jk` / `kj` | Insert | Exit insert mode |
| `<leader>d` | Normal/Visual | Delete to void register |
| `<leader>p` | Visual | Paste without replacing clipboard |
| `<leader>f` | Normal | Format buffer (LSP) |
| `<leader>s` | Normal | Search & replace word under cursor |
| `<leader>x` | Normal | Make file executable |
| `X` | Normal | Delete char without yanking |
| `Q` | Normal | Disabled (no-op) |

### 🪟 Window Navigation
| Key | Mode | Action |
|-----|------|--------|
| `<Tab>` | Normal | Next window |
| `<S-Tab>` | Normal | Previous window |
| `<C-h>` | Normal | Left window |
| `<C-j>` | Normal | Down window |
| `<C-k>` | Normal | Up window |
| `<C-l>` | Normal | Right window |

### 📑 Splits & Tabs
| Key | Mode | Action |
|-----|------|--------|
| `<leader>sd` | Normal | Split vertically |
| `<leader>sh` | Normal | Split horizontally |
| `<leader>se` | Normal | Equal split sizes |
| `<leader>sf` | Normal | Close current split |
| `<leader>to` | Normal | New tab |
| `<leader>tx` | Normal | Close tab |
| `<leader>tn` | Normal | Next tab |
| `<leader>tp` | Normal | Previous tab |
| `<leader>tf` | Normal | Open file in new tab |

### 🔍 Telescope (Fuzzy Finder)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>pr` | Normal | Recent files |
| `<leader>pWs` | Normal | Grep word under cursor |
| `<leader>th` | Normal | Theme switcher |
| `<leader>/` | Normal | Search in current buffer |

### 📁 File Navigation
| Key | Mode | Action |
|-----|------|--------|
| `f` | Normal | Oil file manager |
| `<leader>fff` | Normal | Oil floating window |
| `<leader>ee` | Normal | Mini.files toggle |
| `<leader>ef` | Normal | Mini.files at current file |

### 🎯 Harpoon (Quick Navigation)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>a` | Normal | Add file to harpoon |
| `<C-e>` | Normal | Toggle harpoon menu |
| `<C-y>` | Normal | Jump to file 1 |
| `<C-i>` | Normal | Jump to file 2 |
| `<C-n>` | Normal | Jump to file 3 |
| `<C-s>` | Normal | Jump to file 4 |
| `<C-S-P>` | Normal | Previous harpoon file |
| `<C-S-N>` | Normal | Next harpoon file |

### 🔧 LSP
| Key | Mode | Action |
|-----|------|--------|
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition |
| `gi` | Normal | Go to implementation |
| `gt` | Normal | Go to type definition |
| `gR` | Normal | Show references |
| `K` | Normal | Hover documentation |
| `<leader>vca` | Normal/Visual | Code actions |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>D` | Normal | Buffer diagnostics |
| `<leader>d` | Normal | Show diagnostic float |
| `<leader>rs` | Normal | Restart LSP |
| `<C-h>` | Insert | Signature help |

### ✏️ Editing Utilities
| Key | Mode | Action |
|-----|------|--------|
| `<` | Visual | Unindent (keep selection) |
| `>` | Visual | Indent (keep selection) |
| `sj` | Normal/Visual | Join arguments |
| `sk` | Normal/Visual | Split arguments |
| `sa` | Normal/Visual | Surround add |
| `sd` | Normal/Visual | Surround delete |
| `sr` | Normal/Visual | Surround replace |
| `<leader>cw` | Normal | Trim trailing whitespace |
| `<leader>u` | Normal | Toggle undotree |

### 📝 TODO Comments
| Key | Mode | Action |
|-----|------|--------|
| `]t` | Normal | Next TODO |
| `[t` | Normal | Previous TODO |

### 💾 Sessions
| Key | Mode | Action |
|-----|------|--------|
| `<leader>wr` | Normal | Restore session |
| `<leader>ws` | Normal | Save session |

### 🖥️ Terminal
| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | Normal | Run current file |
| `<leader>q` | Normal/Terminal | Kill terminal |
| `<C-`>` | Normal/Terminal | Toggle terminal |

### 🤖 Coplito AI (RAG-Enabled)
| Key | Mode | Action |
|-----|------|--------|
| `<C-S-i>` | Normal/Visual | Gen AI menu |
| `<leader>gc` | Normal | Gen chat (model menu) |
| `<leader>gq` | Normal | Qwen + RAG |
| `<leader>gd` | Normal | DeepSeek + RAG |
| `<leader>gp` | Normal | Phi + RAG |
| `<leader>ge` | Visual | Explain code + RAG |
| `<leader>gf` | Visual | Fix code + RAG |
| `<leader>gr` | Visual | Review code + RAG |
| `<leader>gm` | Normal | Model selection menu |

### 🔍 Coplito Context
| Key | Mode | Action |
|-----|------|--------|
| `<leader>ci` | Normal | Show context summary |
| `<leader>cp` | Normal | Preview RAG prompt |
| `<leader>ce` | Normal | Check LSP errors |
| `<leader>cs` | Normal | Show symbols |

### 📋 Misc
| Key | Mode | Action |
|-----|------|--------|
| `<leader>fp` | Normal | Copy file path to clipboard |

---

## ⚙️ Configuration

### Options
See [lua/Gaurav/core/options.lua](lua/Gaurav/core/options.lua) for editor options.

Key settings:
- Line numbers: relative + absolute
- Tab width: 4 spaces
- Auto-save on focus lost
- Smart search (ignorecase + smartcase)
- Auto-indent enabled

### Colorscheme
Current theme stored in `lua/current-theme.lua`. Change with:
```vim
:Telescope themes
```

### LSP Servers
Managed by Mason. Install servers:
```vim
:Mason
```

### AI Models
Configure in `lua/Gaurav/plugins/gen.lua`:
```lua
model = "qwen2.5-coder:14b"  -- Default model
```

### RAG Settings
Configure in `lua/Gaurav/coplito/init.lua`:
```lua
coplito.setup({
  include_errors = true,      -- Include LSP diagnostics
  include_symbols = true,     -- Include Tree-sitter symbols
  window_size = 50,           -- Lines around cursor
})
```

---

## 🧪 Testing

### Test Scripts

**Test Ollama & Models:**
```bash
./test_coplito.sh
```

**Test RAG System:**
```bash
./test_rag.sh
```

Both scripts verify:
- ✅ Module loading
- ✅ Commands registered
- ✅ Context collection
- ✅ Model availability

---

## 📚 Documentation

Comprehensive docs in root:

- **[COPLITO.md](COPLITO.md)** - Complete Coplito system documentation
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide with examples
- **[RAG_IMPLEMENTATION.md](RAG_IMPLEMENTATION.md)** - RAG implementation details
- **[STATUS.md](STATUS.md)** - Implementation status & checklist
- **[instruction.md](instruction.md)** - Full system specification

---

## 🎯 Quick Start Examples

### AI-Assisted Coding
```vim
" 1. Open a file
nvim mycode.rs

" 2. Get AI help with Qwen (best for reasoning)
<leader>gq
> How can I optimize this?

" 3. Check what context was used
<leader>ci
" Shows: Errors: 0, Symbols: 5, Selection: No

" 4. Fix bugs with DeepSeek
<leader>gd
> Why is this failing?
" Context automatically includes LSP errors!
```

### Visual Selection + AI
```vim
" 1. Select code in visual mode
V5j  " Select 5 lines

" 2. Get explanation
<leader>ge
" Choose model from menu

" 3. Or fix directly
<leader>gf
" Model gets exact selection + context
```

### Preview RAG Prompt
```vim
:CopiloPreview
> Explain this function

" Opens split showing:
" [ERROR CONTEXT]
" [CODE CONTEXT]  
" [USER QUERY]
" [RESPONSE RULES]
```

---

## 🚀 Performance

### Startup Time
- **Cold start**: ~100-200ms
- **With plugins**: ~300-500ms

### AI Performance
- **Context collection**: <10ms
- **Symbol extraction**: <50ms (Tree-sitter)
- **Model inference**: Depends on GPU

### Recommended Hardware
- **CPU**: Modern multi-core
- **RAM**: 8GB+ system RAM
- **GPU**: 8GB+ VRAM (16GB ideal for all models)

---

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest features
- Submit PRs

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Credits

### Core Plugins
- [Neovim](https://neovim.io)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### AI & Utilities
- [gen.nvim](https://github.com/David-Kunz/gen.nvim)
- [Ollama](https://ollama.com)
- [oil.nvim](https://github.com/stevearc/oil.nvim)
- [harpoon](https://github.com/ThePrimeagen/harpoon)
- [mini.nvim](https://github.com/echasnovski/mini.nvim)

### Models
- Qwen 2.5 Coder by Alibaba
- DeepSeek Coder by DeepSeek
- Phi by Microsoft

---

<div align="center">

**Built with ❤️ for serious developers**

*Determinism over magic • Context over guessing • Local over cloud*

**Date**: January 2026

</div>




