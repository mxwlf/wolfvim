require("config.options") -- Load the config/options.lua module
require("config.lazy") -- Load the config/lazy.lua module with our plugins using Lazy.vim


require'lspconfig'.pyright.setup{}
require'lspconfig'.csharp_ls.setup{}
-- vim.lsp.config('*', {
--  capabilities = {
--    textDocument = {
--      semanticTokens = {
--        multilineTokenSupport = true,
--      }
--    }
--  },
--  root_markers = { '.git' },
--})
