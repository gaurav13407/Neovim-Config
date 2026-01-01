# 🤖 Coplito AI System - Complete Guide

## What is Coplito?

Coplito is your **local AI coding assistant** with **RAG (Retrieval Augmented Generation)**. It automatically collects context from your code and feeds it to the AI model, so you get accurate, context-aware responses.

---

## 🎯 RAG Context Collection (Automatic)

When you use any Coplito command, it **automatically collects**:

### Priority 1: Visual Selection (if any)
- The exact code you selected
- Line numbers and file path
- Highest priority in the prompt

### Priority 2: Active File Context
- 50 lines around your cursor (configurable)
- Current function/class you're in
- File name and path

### Priority 3: LSP Errors (if any)
- Error messages from language server
- Line numbers with errors
- Error severity (Error/Warning/Info)
- **This is the ground truth for bug fixing**

### Priority 4: Tree-sitter Symbols
- Function definitions
- Class structures
- Variable declarations
- **Only if Tree-sitter is available for the language**

### Priority 5: Related Code
- Other files you have open
- Recently edited files

### Priority 6: Project Metadata
- package.json, Cargo.toml, pyproject.toml, etc.
- Helps understand dependencies

---

## 📋 Menu Options Explained

### 💬 **Chat** (Normal Mode)
**What it does:** Open-ended conversation with the AI about your code.

**RAG provides:**
- Current file context
- LSP errors if any
- Symbols from current file

**Best for:**
- General questions: "How can I optimize this?"
- Design discussions: "What's the best way to structure this?"
- Learning: "Explain this pattern to me"

**Best model:** Qwen (reasoning)

**Example:**
```
Query: "How do I make this function thread-safe?"
RAG adds: Current function code + LSP warnings
Result: Detailed explanation with context-aware suggestions
```

---

### 🔧 **Fix Code** (Visual Mode Only)
**What it does:** Analyzes selected code and fixes bugs/issues.

**RAG provides:**
- **Your selected code** (highest priority)
- **LSP errors at that location** (ground truth!)
- Surrounding context
- Related symbols

**Best for:**
- Fixing compilation errors
- Resolving runtime errors
- Fixing linter warnings
- Type mismatches

**Best model:** DeepSeek (bug fixing specialist)

**Example:**
```
Selected code:
    def calculate(x, y)
        return x + z  # z is undefined!

LSP Error: "undefined name 'z'"

Query: "fix this"
Result: Changes 'z' to 'y' with explanation
```

**Visual workflow:**
1. See LSP error in your code
2. Select the problematic code (visual mode)
3. Press `Ctrl+Shift+i` → "Fix Code"
4. Choose DeepSeek
5. Type "fix this" or just press Enter
6. Get fixed code!

---

### 🔍 **Review Code** (Visual Mode Only)
**What it does:** Comprehensive code review of selected code.

**RAG provides:**
- Selected code
- LSP diagnostics
- Symbols and structure
- File context

**Best for:**
- Pre-commit reviews
- Finding potential bugs
- Code quality checks
- Security review
- Performance analysis

**Best model:** DeepSeek (code analysis)

**Review includes:**
- ✅ What's good
- 🐛 Bugs found
- ⚠️ Potential issues
- 🚀 Performance suggestions
- 🔒 Security concerns
- 📚 Best practices

**Example:**
```
Selected: User authentication function

Review output:
✅ Input validation looks good
🐛 Password comparison is timing-attack vulnerable
⚠️ No rate limiting on login attempts
🚀 Consider caching user lookups
🔒 Use constant-time comparison for passwords
```

---

### 📝 **Explain Code** (Visual Mode Only)
**What it does:** Explains what the selected code does in detail.

**RAG provides:**
- Selected code
- Surrounding context
- Symbol definitions
- Related functions

**Best for:**
- Understanding unfamiliar code
- Learning new patterns
- Documentation
- Onboarding new team members
- Debugging complex logic

**Best model:** Qwen (reasoning and explanation)

**Explanation includes:**
- Line-by-line breakdown
- Purpose and intent
- How it fits in larger system
- Edge cases and assumptions
- Related concepts

**Example:**
```
Selected: Complex regex pattern

Query: "explain this"

Output:
"This regex pattern does the following:
- ^ asserts start of string
- [a-zA-Z0-9] matches alphanumeric characters
- {3,20} requires 3-20 characters
- $ asserts end of string

Purpose: Validates usernames between 3-20 alphanumeric characters.

Edge cases:
- Does not allow special characters
- Does not allow spaces
- Case insensitive
..."
```

---

### ✨ **Enhance Code** (Visual Mode Only)
**What it does:** Improves code quality while keeping functionality.

**RAG provides:**
- Selected code
- Current language/framework context
- Project style from other files

**Best for:**
- Refactoring
- Improving readability
- Applying best practices
- Performance optimization
- Adding error handling

**Best model:** Qwen (design) or DeepSeek (code quality)

**Enhancements include:**
- Better naming
- Error handling
- Type annotations
- Documentation
- Performance improvements
- Modern language features

**Example:**
```
Before:
    def calc(a, b):
        return a + b

After enhancement:
    def calculate_sum(first_number: int, second_number: int) -> int:
        """
        Calculate the sum of two integers.
        
        Args:
            first_number: The first integer to add
            second_number: The second integer to add
            
        Returns:
            The sum of the two numbers
        """
        if not isinstance(first_number, int) or not isinstance(second_number, int):
            raise TypeError("Both arguments must be integers")
        return first_number + second_number
```

---

### 📋 **Summarize** (Visual Mode Only)
**What it does:** Creates a concise summary of selected code.

**RAG provides:**
- Selected code
- Symbol structure
- File context

**Best for:**
- Documentation
- PR descriptions
- Code comments
- Understanding large functions
- Quick overview of files

**Best model:** Phi (fast) or Qwen (detailed)

**Summary includes:**
- Main purpose
- Key functions/methods
- Important variables
- Dependencies
- Complexity notes

**Example:**
```
Selected: 200 lines of API handler

Summary:
"UserAuthenticationHandler - Manages user login/logout
- validateCredentials(): Checks username/password against DB
- generateToken(): Creates JWT with 24h expiry
- refreshToken(): Renews existing valid tokens
- revokeToken(): Blacklists tokens on logout
Dependencies: bcrypt, jwt, redis
Complexity: O(1) for most operations, O(n) for token validation"
```

---

### 🎯 **Ask Question** (Normal Mode)
**What it does:** Same as Chat - general questions about current context.

**RAG provides:**
- Current file
- Cursor position context
- LSP information
- Project metadata

**Best for:**
- Quick questions
- Context-specific queries
- "What does this do?"
- "Why is this here?"

**Best model:** Qwen (reasoning) or Phi (quick answers)

---

## 🤔 Which Model For Which Task?

### 🧠 Qwen 2.5 Coder 14B (9 GB VRAM)
**Best for:**
- ✅ Complex reasoning
- ✅ Design discussions
- ✅ Architecture decisions
- ✅ Explaining concepts
- ✅ Refactoring suggestions
- ⚡ Speed: Slower but thorough

**Use when:** You need deep understanding and thoughtful responses.

### 🐛 DeepSeek Coder V2 16B (8.9 GB VRAM)
**Best for:**
- ✅ Bug fixing
- ✅ Code review
- ✅ Finding edge cases
- ✅ Security analysis
- ✅ Error diagnosis
- ⚡ Speed: Moderate

**Use when:** You have errors or need code quality checks.

### ⚡ Phi 3.5 Mini (2.4 GB VRAM)
**Best for:**
- ✅ Quick checks
- ✅ Simple questions
- ✅ Fast summaries
- ✅ Sanity checks
- ⚡ Speed: Very fast

**Use when:** You need a quick answer and context is simple.

---

## 🎮 Quick Workflows

### Workflow 1: Fix LSP Error
```
1. See red squiggly line in code
2. Place cursor on error OR select error code
3. Press <leader>gd (DeepSeek)
4. Type: "fix this error"
5. RAG automatically includes:
   - Error message from LSP
   - Surrounding code
   - Related symbols
6. Get fix!
```

### Workflow 2: Understand Function
```
1. Select function (visual mode)
2. Press Ctrl+Shift+i
3. Choose "📝 Explain Code"
4. Choose Qwen
5. Just press Enter (no query needed)
6. Get detailed explanation!
```

### Workflow 3: Code Review Before Commit
```
1. Select changed function (visual mode)
2. Press Ctrl+Shift+i
3. Choose "🔍 Review Code"
4. Choose DeepSeek
5. Type: "check for bugs and issues"
6. Get comprehensive review!
```

### Workflow 4: Refactor for Quality
```
1. Select messy code (visual mode)
2. Press Ctrl+Shift+i
3. Choose "✨ Enhance Code"
4. Choose Qwen
5. Type: "improve this with best practices"
6. Get refactored code!
```

### Workflow 5: Quick Question
```
1. Place cursor in function
2. Press <leader>gq (Qwen)
3. Type: "how can I test this?"
4. RAG includes current function
5. Get testing suggestions!
```

---

## 🔍 How to Check RAG Context

### Before sending query:
```
:CopiloContext
```
Shows:
- How many errors found
- How many symbols found
- What file/selection is included

### Preview full prompt:
```
:CopiloPreview
```
Opens split showing exactly what the AI will see.

### Check errors only:
```
:CopiloErrors
```

### Check symbols only:
```
:CopiloSymbols
```

---

## 🚀 Pro Tips

### Tip 1: Visual Selection = Better Context
Always select code for Fix/Review/Explain - gives AI exact scope.

### Tip 2: LSP Errors Are Gold
RAG includes LSP errors automatically - AI sees exact compiler/linter messages!

### Tip 3: Use Right Model for Task
- Bugs/Errors → DeepSeek
- Design/Why/How → Qwen
- Quick checks → Phi

### Tip 4: Continue Conversations
After AI responds, you can keep asking follow-ups:
- "Can you explain that better?"
- "What about performance?"
- "Show me an example"

### Tip 5: Empty Query = Auto Context
For Fix/Review/Explain, you can just press Enter without typing - RAG provides everything!

### Tip 6: Check Context First
If answer seems off, check `:CopiloContext` - maybe RAG missed something.

### Tip 7: Preview Before Sending
Use `<leader>cp` to preview full prompt structure before sending expensive queries.

---

## 📊 RAG Context Limits

**What's included:**
- ✅ Visual selection (no limit)
- ✅ 50 lines around cursor (configurable)
- ✅ All LSP errors in file
- ✅ All symbols in file
- ✅ Project metadata files

**What's NOT included:**
- ❌ Full file if >1000 lines (uses window instead)
- ❌ Other files (unless explicitly opened)
- ❌ External libraries
- ❌ Previous conversation history (gen.nvim limitation)

**To change window size:**
Edit `lua/Gaurav/plugins/gen.lua`:
```lua
coplito.setup({
  window_size = 50,  -- Change to 100 for more context
})
```

---

## 🎯 Keybinding Summary

| Key | Mode | What It Does |
|-----|------|--------------|
| `<C-S-i>` | Normal/Visual | Open menu with all options |
| `<leader>gq` | Normal | Direct Qwen chat (no menu) |
| `<leader>gd` | Normal | Direct DeepSeek chat (no menu) |
| `<leader>gp` | Normal | Direct Phi chat (no menu) |
| `<leader>gc` | Normal | Chat with model selection |
| `<leader>ge` | Visual | Explain selected code |
| `<leader>gf` | Visual | Fix selected code |
| `<leader>gr` | Visual | Review selected code |
| `<leader>ci` | Normal | Show context summary |
| `<leader>cp` | Normal | Preview full prompt |
| `<leader>ce` | Normal | Check LSP errors |
| `<leader>cs` | Normal | Show symbols |

---

## 🛠️ Troubleshooting

### "No context found"
- Make sure you're in a code file
- Check if LSP is running (`:LspInfo`)
- Try selecting code manually

### "Tree-sitter not available"
- Install tree-sitter parser for your language
- Run: `:TSInstall <language>`

### "Model selection appears"
- Restart Neovim completely
- Run: `:Lazy sync`
- Check if using latest config

### "Response is irrelevant"
- Use `:CopiloPreview` to check what AI sees
- Make sure you selected the right code
- Try different model (Qwen for reasoning, DeepSeek for bugs)

---

## 📚 Learn More

- [KEYBINDINGS.md](KEYBINDINGS.md) - All keybindings
- [RAG_IMPLEMENTATION.md](RAG_IMPLEMENTATION.md) - Technical details
- [QUICKSTART.md](QUICKSTART.md) - Getting started
- [README.md](README.md) - Full documentation
- [CTRL_SHIFT_I_FIX.md](CTRL_SHIFT_I_FIX.md) - Menu system explained

---

**Remember:** RAG = **R**etrieval **A**ugmented **G**eneration = AI + Your Code Context = Better Answers! 🎯
