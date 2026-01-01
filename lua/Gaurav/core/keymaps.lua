local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>v", "p", { noremap = true })
vim.keymap.set("n", "<leader>V", "P", { noremap = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

vim.keymap.set("n", "J", "mzJz")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Cycle windows
vim.keymap.set("n", "<Tab>", "<C-w>w")
vim.keymap.set("n", "<S-Tab>", "<C-w>W")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- delete default paste bindings
vim.keymap.del("n", "p")
vim.keymap.del("n", "P")

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- paste without replacing clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "p", '"_dP', opts)

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "X", '"_x', opts)

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
	desc = "Replace word cursor is on globally",
})

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", {
	silent = true,
	desc = "makes file executable",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>")
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>")
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>")
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>")
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>")

vim.keymap.set("n", "<leader>sd", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sf", "<cmd>close<CR>", { desc = "Close current split" })

vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~")
	vim.fn.setreg("+", filePath)
	print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set("i", "kj", "<Esc>", opts)

-- RUN FILE (<leader>w) -- handled by terminal.lua

-- Search within current buffer only (space + pp)
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Search in current file" })




--------------------------------------------------
-- Gen.nvim keybindings (RAG-enabled)
--------------------------------------------------

-- Open Gen custom menu (normal + visual) - bypasses gen.nvim model selection
vim.keymap.set({ "n", "v" }, "<C-S-i>", ":GenMenu<CR>", { desc = "Gen Prompt Menu (RAG)" })

-- Open Gen chat with model selection (RAG)
vim.keymap.set("n", "<leader>gc", ":GenChat<CR>", { desc = "Gen Chat (RAG)" })

-- Explicit model commands (direct, no menu, RAG-enabled)
vim.keymap.set("n", "<leader>gq", ":GenQwen<CR>", { desc = "Gen: Qwen + RAG" })
vim.keymap.set("n", "<leader>gd", ":GenDeepSeek<CR>", { desc = "Gen: DeepSeek + RAG" })
vim.keymap.set("n", "<leader>gp", ":GenPhi<CR>", { desc = "Gen: Phi + RAG" })

-- Prompt-based commands with model selection (RAG)
vim.keymap.set("v", "<leader>ge", ":GenExplain<CR>", { desc = "Gen: Explain + RAG" })
vim.keymap.set("v", "<leader>gf", ":GenFix<CR>", { desc = "Gen: Fix + RAG" })
vim.keymap.set("v", "<leader>gr", ":GenReview<CR>", { desc = "Gen: Review + RAG" })

-- Model selection menu
vim.keymap.set("n", "<leader>gm", ":GenModel<CR>", { desc = "Gen: Select model" })

--------------------------------------------------
-- Coplito RAG commands
--------------------------------------------------

-- Context inspection
vim.keymap.set("n", "<leader>ci", ":CopiloContext<CR>", { desc = "Coplito: Show context" })
vim.keymap.set("n", "<leader>cp", ":CopiloPreview<CR>", { desc = "Coplito: Preview prompt" })
vim.keymap.set("n", "<leader>ce", ":CopiloErrors<CR>", { desc = "Coplito: Check errors" })
vim.keymap.set("n", "<leader>cs", ":CopiloSymbols<CR>", { desc = "Coplito: Show symbols" })


