-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Packs de linguagem: LSP + formatter + linter + treesitter (instalados pelo Mason)
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.typescript" }, -- NestJS / Expo
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cpp" }, -- ROS 2 (clangd)
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.yaml" }, -- launch files, params
  { import = "astrocommunity.pack.json" },
  -- Plugins
  { import = "astrocommunity.git.diffview-nvim" }, -- diffs, histórico e conflitos
  { import = "astrocommunity.motion.flash-nvim" }, -- s/S: saltos
  { import = "astrocommunity.search.grug-far-nvim" }, -- <Leader>s: buscar e substituir
  { import = "astrocommunity.diagnostics.trouble-nvim" }, -- <Leader>x: lista de erros
  { import = "astrocommunity.code-runner.overseer-nvim" }, -- <Leader>M: tasks
  { import = "astrocommunity.file-explorer.oil-nvim" }, -- <Leader>O: pastas como buffer
  -- import/override with your plugins folder
}
