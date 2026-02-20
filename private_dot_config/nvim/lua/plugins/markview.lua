return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown", "mermaid" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ''
      vim.g.mkdp_browser = 'firefox'
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_browserfunc = ''
      vim.g.mkdp_preview_options = {
          mkit = {},
          katex = {},
          uml = {},
          maid = {
            useMaxWidth = false
          }, -- Isso habilita o Mermaid
          disable_sync_scroll = 0,
          sync_scroll_type = 'middle',
          hide_yaml_meta = 1,
          sequence_diagrams = {}, -- Isso habilita js-sequence-diagrams
          flowchart_diagrams = {},
          content_editable = false,
          disable_filename = 0,
      }
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/preview.css")
      vim.g.mkdp_highlight_css = ''
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_combine_preview = 0
      vim.g.mkdp_combine_preview_auto_refresh = 1
    end,
    config = function()
      vim.keymap.set("n", "<Leader>mp", "<Plug>MarkdownPreview", { desc = "Markdown Preview"})
    end,
    ft = { "markdown", "mermaid" },
  },
}
