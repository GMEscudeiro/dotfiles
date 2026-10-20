-- O módulo do AstroCommunity não define atalhos para o diffview
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>gv"] = { "<Cmd>DiffviewOpen<CR>", desc = "Diffview: mudanças" },
        ["<Leader>gV"] = { "<Cmd>DiffviewClose<CR>", desc = "Diffview: fechar" },
        ["<Leader>gH"] = { "<Cmd>DiffviewFileHistory %<CR>", desc = "Diffview: histórico do arquivo" },
      },
    },
  },
}
