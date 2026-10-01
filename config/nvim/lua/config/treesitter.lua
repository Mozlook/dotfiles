local ts = require("nvim-treesitter")

-- Names must exist in nvim-treesitter's parsers.lua (main branch has no
-- separate jsonc parser; `json` covers it).
local languages = {
  "bash",
  "c_sharp",
  "css",
  "diff",
  "dockerfile",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "html",
  "javascript",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local function parser_installed(lang)
  return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", true) > 0
end

local missing = {}
for _, lang in ipairs(languages) do
  if not parser_installed(lang) then
    table.insert(missing, lang)
  end
end

if #missing > 0 then
  vim.schedule(function()
    pcall(function()
      ts.install(missing)
    end)
  end)
end

local function start_treesitter(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].buftype ~= "" then
    return
  end

  local ft = vim.bo[bufnr].filetype
  if ft == "" then
    return
  end

  local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
  if not ok or not lang or not parser_installed(lang) then
    return
  end

  pcall(vim.treesitter.start, bufnr, lang)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType" }, {
  callback = function(args)
    start_treesitter(args.buf)
  end,
})

for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
  start_treesitter(bufnr)
end
