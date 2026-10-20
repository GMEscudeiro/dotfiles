-- O pack.docker instala o docker-language-server, mas o nvim-lspconfig fixado pelo
-- AstroNvim ainda não traz config para ele; sem isso o servidor nunca é ativado.
-- Pode remover quando o lspconfig tiver lsp/docker_language_server.lua.
return {
  "AstroNvim/astrolsp",
  opts = {
    servers = { "docker_language_server" },
    config = {
      docker_language_server = {
        cmd = { "docker-language-server", "start", "--stdio" },
        filetypes = { "dockerfile", "yaml.docker-compose" },
        -- formato do lspconfig legado (o AstroNvim aqui roda com native_lsp_config = false)
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Dockerfile", "docker-compose.yaml", "docker-compose.yml", "compose.yaml", ".git"
          )(fname)
        end,
        single_file_support = true,
      },
    },
  },
}
