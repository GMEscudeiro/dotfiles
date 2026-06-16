return { 
  "shortcuts/no-neck-pain.nvim", 
  version = "*",
  opts = { 
    width = 120,
  }, -- Sets the width of the centered code block
  keys = {
    { "<leader>zn", "<cmd>NoNeckPain<cr>", desc = "Toggle Center Layout" },
    { "<leader>z+", "<cmd>NoNeckPainWidthUp<cr>", desc = "Increase width" },
    { "<leader>z-", "<cmd>NoNeckPainWidthDown<cr>", desc = "Decrease width" }
  },
}

