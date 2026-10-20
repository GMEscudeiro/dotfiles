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
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.cmake" }, -- CMakeLists do ROS 2
  { import = "astrocommunity.pack.markdown" },
  -- Ferramentas
  { import = "astrocommunity.git.diffview-nvim" }, -- :DiffviewOpen, histórico de arquivo
  { import = "astrocommunity.motion.flash-nvim" }, -- s / S: pula pra qualquer lugar visível
  { import = "astrocommunity.code-runner.overseer-nvim" }, -- tasks (colcon, testes) → quickfix
  -- import/override with your plugins folder
}
