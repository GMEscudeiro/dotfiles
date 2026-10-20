-- AstroNvim's lazy snapshot pins aerial.nvim to `^2.2`, which still calls the
-- removed `TSNode:start()` and crashes on Neovim 0.12+. aerial 4.x fixes it.
---@type LazySpec
return {
  "stevearc/aerial.nvim",
  version = "^4",
}
