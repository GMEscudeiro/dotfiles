local ROOT = vim.fn.expand "~/new_robot_architecture"

local roots = {
  { key = "s", label = "server",      path = ROOT .. "/server/sd_server" },
  { key = "m", label = "robot-mod",   path = ROOT .. "/robot_ws/modules" },
  { key = "r", label = "ros2",        path = ROOT .. "/robot_ws/ros2_ws/src/socialdroids" },
  { key = "c", label = "contracts",   path = ROOT .. "/robot_ws/contracts" },
}

local function switch_root()
  local labels = vim.tbl_map(function(r) return r.label end, roots)
  vim.ui.select(labels, { prompt = "Project root:" }, function(choice)
    if not choice then return end
    for _, r in ipairs(roots) do
      if r.label == choice then
        vim.cmd("tcd " .. r.path)
        vim.notify("→ " .. r.label, vim.log.levels.INFO)
        return
      end
    end
  end)
end

return {
  -- session persistence per directory
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- project root switching + scoped telescope
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          -- switch tab cwd via picker
          ["<leader>pp"] = { switch_root, desc = "Switch project root" },

          -- scoped telescope searches
          ["<leader>pf"] = {
            function()
              require("telescope.builtin").find_files { cwd = vim.fn.getcwd() }
            end,
            desc = "Find files (project root)",
          },
          ["<leader>pg"] = {
            function()
              require("telescope.builtin").live_grep { cwd = vim.fn.getcwd() }
            end,
            desc = "Grep (project root)",
          },

          -- session restore
          ["<leader>Sr"] = {
            function() require("persistence").load() end,
            desc = "Restore session",
          },
          ["<leader>Sl"] = {
            function() require("persistence").load { last = true } end,
            desc = "Restore last session",
          },
        },
      },
    },
  },
}
