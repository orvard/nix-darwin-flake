require("lazy").setup({
        spec = {
                { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                { "williamboman/mason-lspconfig.nvim", enabled = false },
                { "williamboman/mason.nvim", enabled = false },
	}
})
