-- Neovim 0.13 turned 'diffopt' into a map-like option, so AstroNvim's
-- `vim.list_extend(vim.opt.diffopt:get(), ...)` builds a mixed table that
-- fails to set. Override with a plain string until AstroNvim fixes it.
-- Só no 0.12+: `inline:char` não existe antes e dá E474 (o 22.04 pode estar no 0.11).
---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    if vim.fn.has "nvim-0.12" == 0 then return end
    opts.options.opt.diffopt = "internal,filler,closeoff,indent-heuristic,inline:char,algorithm:histogram,linematch:60"
  end,
}
