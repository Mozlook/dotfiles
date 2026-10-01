require("conform").setup({
  format_on_save = function(bufnr)
    local disabled = { sql = true, txt = true }
    if disabled[vim.bo[bufnr].filetype] then
      return
    end
    return { timeout_ms = 2000, lsp_format = "fallback" }
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
    python = { "ruff_organize_imports", "ruff_format" },
    -- goimports first: it reformats with plain gofmt, gofumpt then applies its stricter rules
    go = { "goimports", "gofumpt" },
    cs = { "csharpier" },
    lua = { "stylua" },
  },
})
