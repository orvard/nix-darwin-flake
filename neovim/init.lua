require("lazy").setup({
        spec = {
                { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                { "mason-org/mason-lspconfig.nvim", enabled = false },
                { "mason-org/mason.nvim", enabled = false },
	}
})

