pcall(require, "lspconfig")

require("mason").setup({ PATH = "append" })

require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
    "tailwindcss",
    "emmet_ls",
    "basedpyright",
    "ruff",
    "gopls",
    "omnisharp",
    "lua_ls",
  },
  automatic_installation = true,
  automatic_enable = {
    exclude = { "ts_ls" },
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
  root_markers = { { ".luarc.json", ".stylua.toml" }, ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("tailwindcss", {
  root_markers = {
    { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts" },
    { "postcss.config.js", "postcss.config.cjs", "postcss.config.ts" },
    ".git",
  },
})

vim.lsp.config("emmet_ls", {
  filetypes = {
    "html",
    "css",
    "sass",
    "scss",
    "typescriptreact",
    "javascriptreact",
    "javascript",
    "typescript",
  },
})

vim.lsp.config("basedpyright", {
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})

vim.lsp.config("ruff", {
  root_markers = { "pyproject.toml", ".git" },
  init_options = { settings = { args = {} } },
})

vim.lsp.config("gopls", {
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
    },
  },
})

vim.lsp.config("omnisharp", {
  root_markers = { ".git" },
  enable_import_completion = true,
})

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded" },
})

pcall(function()
  require("typescript-tools").setup({
    capabilities = capabilities,
    settings = {
      separate_diagnostic_server = true,
      publish_diagnostic_on = "insert_leave",
      tsserver_max_memory = "auto",
    },
  })
end)
