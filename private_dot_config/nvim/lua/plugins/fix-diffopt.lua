-- Neovim 0.13 turned 'diffopt' into a map-like option, so AstroNvim's
-- `vim.list_extend(vim.opt.diffopt:get(), ...)` builds a mixed table that
-- fails to set. Override with a plain string until AstroNvim fixes it.
---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.options.opt.diffopt = "internal,filler,closeoff,indent-heuristic,inline:char,algorithm:histogram,linematch:60"
  end,
}
