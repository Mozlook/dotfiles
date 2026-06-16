require("conform").setup({
  format_on_save = function(bufnr)
    local disabled = { sql = true, txt = true }
    if disabled[vim.bo[bufnr].filetype] then
      return
    end
    return { timeout_ms = 2000, lsp_fallback = true }
  end,
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    python = { "black" },
    go = { "gofumpt", "goimports" },
    cs = { "csharpier" },
    lua = { "stylua" },
  },
})
