return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "macchiato",
    transparent_background = true,
    custom_highlights = function(colors)
      return {
        NeoTreeTabSeparatorInactive = { fg = colors.base },
        NeoTreeTabSeparatorActive = { fg = colors.base },
      }
    end,
  },
  -- astrocore can apply the colorscheme during startup before this plugin's
  -- setup() runs (loading defaults), so re-apply it once our opts are in.
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme "catppuccin"
  end,
}
