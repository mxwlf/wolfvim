--vim.api.nvim_create_autocmd('LspAttach', {
--  callback = function(ev)
--    local client = vim.lsp.get_client_by_id(ev.data.client_id)
--    if client:supports_method('textDocument/completion') then
--      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--    end
--  end,
--})
-- vim.cmd[[set completeopt+=menuone,noselect,popup]]
-- vim.opt.completeopt:append({ "menuone", "noselect", "popup" })
if vim.version().api_level >=11 then vim.opt.completeopt = { "menuone", "noselect", "popup" } end

-- Autocompletions from LSP
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/implementation') then
	    -- Define keymaps here
	    local opts = { buffer = args.buf }
	    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
	    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
	    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
	    vim.keymap.set('n', '<space>wl', function()
	      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	    end, opts)
	    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
	    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
	    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
	    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	    vim.keymap.set('n', '<space>f', function()
	      vim.lsp.buf.format { async = true }
	    end, opts)
    end
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      -- client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
--      vim.keymap.set('i', '<c-space>', function()
--	  vim.lsp.completion
--	end)
    end
    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    -- These 'supports_methods' are checks for LSP's capabilities.
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
