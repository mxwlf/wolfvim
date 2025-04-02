require("config.options") -- Load the config/options.lua module
require("config.lazy") -- Load the config/lazy.lua module with our plugins using Lazy.vim
require("config.autocompletion")

 vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
  root_markers = { '.git' },
})

-- enables LSP servers
vim.lsp.enable({'clangd', 'rust-analyzer', 'csharp-ls'})
