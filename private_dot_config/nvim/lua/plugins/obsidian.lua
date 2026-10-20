return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = "Obsidian",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<Leader>on", "<Cmd>Obsidian new<CR>", desc = "Obsidian: nova nota" },
      { "<Leader>of", "<Cmd>Obsidian quick_switch<CR>", desc = "Obsidian: buscar nota" },
      { "<Leader>os", "<Cmd>Obsidian search<CR>", desc = "Obsidian: grep no vault" },
      { "<Leader>od", "<Cmd>Obsidian today<CR>", desc = "Obsidian: nota do dia" },
      { "<Leader>ob", "<Cmd>Obsidian backlinks<CR>", desc = "Obsidian: backlinks" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = "notes", path = "~/obsidian-notes" },
      },
      daily_notes = { folder = "Diario" },
      picker = { name = "telescope.nvim" },
      ui = { enable = false },
    },
  },
}
