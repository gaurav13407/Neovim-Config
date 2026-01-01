
return {
  "nomnivore/ollama.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("ollama").setup({
      model = "qwen2.5:14b-instruct-q5_K_M",
      ui = {
        position = "right",
        width = 0.4,
      },
    })
  end,
}
