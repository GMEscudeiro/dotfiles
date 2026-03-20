return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "cpp",
      "javascript",
      "c_sharp",
      "tsx"
      -- add more arguments for adding more treesitter parsers
    },
  },
}
