require("lazy").setup({
        spec = {
                { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                { "mason-org/mason-lspconfig.nvim", enabled = false },
                { "mason-org/mason.nvim", enabled = false },
		{ "mrcjkb/rustaceanvim", enabled = true },
		{ "ibhagwan/fzf-lua", enabled = true },
	}
})

