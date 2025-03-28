-- Autocompletions plugin

if vim.g.vscode then
	return {}
end

return
{
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'onsails/lspkind.nvim', -- Icons!
  },
  config = function()
    local cmp = require'cmp'
    local lspkind = require'lspkind'

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = {
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<C-n>']  = cmp.mapping.select_next_item(),
        ['<Up>']   = cmp.mapping.select_prev_item(),
        ['<C-p>']  = cmp.mapping.select_prev_item(),
        ['<Tab>']  = cmp.mapping.confirm({ select = true }),
        ['<Esc>']  = cmp.mapping.abort(),
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' }
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',  -- show both symbol and text
          maxwidth = 50,
          ellipsis_char = '...',
        })
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      experimental = {
        ghost_text = true, -- like VSCode’s ghost suggestion
      }
    })

    -- Cmdline (:)
    cmp.setup.cmdline(':', {
      mapping = {
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<C-n>']  = cmp.mapping.select_next_item(),
        ['<Up>']   = cmp.mapping.select_prev_item(),
        ['<C-p>']  = cmp.mapping.select_prev_item(),
        ['<Tab>']  = cmp.mapping.confirm({ select = true }),
        ['<Esc>']  = cmp.mapping.abort(),
      },
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' }
      })
    })

    -- Search (/, ?)
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = {
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<C-n>']  = cmp.mapping.select_next_item(),
        ['<Up>']   = cmp.mapping.select_prev_item(),
        ['<C-p>']  = cmp.mapping.select_prev_item(),
        ['<Tab>']  = cmp.mapping.confirm({ select = true }),
        ['<Esc>']  = cmp.mapping.abort(),
      },
      sources = {
        { name = 'buffer' }
      }
    })
  end
}
