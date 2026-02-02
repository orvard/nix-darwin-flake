require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim",                import = "lazyvim.plugins" },
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "mason-org/mason.nvim",           enabled = false },
    { "mrcjkb/rustaceanvim",            enabled = true },
    { "ibhagwan/fzf-lua",               enabled = true },
    { "maxmx03/solarized.nvim",         enabled = true },
  }
})

require("lspconfig").nixd.setup({
  cmd = { "nixd" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> {}",
      },
      formatting = {
        command = { "alejandra" },
      },
    },
  },
})

vim.lsp.enable("nixd")
