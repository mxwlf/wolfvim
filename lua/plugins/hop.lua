-- Hop is a modern alternative to easymotion
-- use <leader><leader>w to highlight potential jump points.
return {
	"smoka7/hop.nvim",
	version = "*",
	lazy = true,
	cmd = "HopWord",
	keys = {
		{ "<leader><leader>w", "<cmd>HopWord<cr>", desc = "HopWord" },
	},
	opts = {
		keys = "etovxqpdygfblzhckisuran",
	},
}
