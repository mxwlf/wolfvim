if vim.g.vscode then
	return {}
end

return {
	"rmehri01/onenord.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd("colorscheme onenord")
	end,
}
