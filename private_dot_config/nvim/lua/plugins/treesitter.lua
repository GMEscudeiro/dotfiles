return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "cpp",
      "javascript"
      -- add more arguments for adding more treesitter parsers
    },
  },
}
