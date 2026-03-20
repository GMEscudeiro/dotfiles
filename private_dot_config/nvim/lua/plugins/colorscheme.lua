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
}
