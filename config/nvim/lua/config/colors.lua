local M = {}

-- Default palette (cafe). The dotfiles theme switcher (`theme-set`) writes
-- lua/config/palette.lua from the active wallpaper's palette; it is loaded here
-- and merged over these defaults. Falling back to defaults means nvim always has
-- valid colors, even on a fresh clone before any theme has been applied.
local defaults = {
  bg = "#141816",
  fg = "#F4EDE0",

  comment = "#6C737A",
  keyword = "#C97D63",
  func = "#F2C96D",
  type = "#8FB4D8",
  string = "#D8A15D",
  number = "#C89DB2",
  special = "#98B8AA",
  namespace = "#7FA6C9",

  operator = "#C7BEAF",
  delimiter = "#827B71",

  warn = "#E6C16A",
  error = "#DE6E73",
  info = "#7FA6C9",
  hint = "#98B8AA",

  ui0 = "#1A1E1C",
  ui1 = "#242825",
  ui2 = "#343834",
  ui3 = "#434743",
}

local function load_palette()
  package.loaded["config.palette"] = nil -- always pick up the latest on reload
  local ok, generated = pcall(require, "config.palette")
  return vim.tbl_extend("force", defaults, (ok and type(generated) == "table") and generated or {})
end

local P = load_palette()

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.apply()
  P = load_palette() -- refresh so live theme switches recolor a running nvim
  vim.opt.termguicolors = true
  vim.g.colors_name = "cafe_wal_manual"

  local BG = "NONE"

  hi("Normal", { fg = P.fg, bg = BG })
  hi("NormalNC", { fg = P.fg, bg = BG })
  hi("EndOfBuffer", { fg = P.bg, bg = BG })
  hi("NonText", { fg = P.ui2 })
  hi("Whitespace", { fg = P.ui1 })
  hi("Conceal", { fg = P.comment })

  hi("Cursor", { fg = P.bg, bg = P.fg })
  hi("TermCursor", { fg = P.bg, bg = P.fg })
  hi("TermCursorNC", { fg = P.bg, bg = P.comment })

  hi("ColorColumn", { bg = P.ui0 })
  hi("CursorLine", { bg = P.ui0 })
  hi("CursorColumn", { bg = P.ui0 })

  hi("LineNr", { fg = P.ui2, bg = BG })
  hi("CursorLineNr", { fg = P.func, bg = BG, bold = true })

  hi("SignColumn", { fg = P.fg, bg = BG })
  hi("FoldColumn", { fg = P.ui2, bg = BG })
  hi("Folded", { fg = P.comment, bg = P.ui0 })

  hi("WinSeparator", { fg = P.ui2 })
  hi("VertSplit", { fg = P.ui2 })

  hi("StatusLine", { fg = P.fg, bg = BG })
  hi("StatusLineNC", { fg = P.comment, bg = BG })

  hi("TabLine", { fg = P.comment, bg = BG })
  hi("TabLineFill", { fg = P.comment, bg = BG })
  hi("TabLineSel", { fg = P.fg, bg = P.ui2, bold = true })

  hi("NormalFloat", { fg = P.fg, bg = P.ui0 })
  hi("FloatBorder", { fg = P.ui2, bg = P.ui0 })
  hi("Pmenu", { fg = P.fg, bg = P.ui0 })
  hi("PmenuSel", { fg = P.fg, bg = P.ui2, bold = true })
  hi("PmenuSbar", { bg = P.ui0 })
  hi("PmenuThumb", { bg = P.ui2 })

  hi("Visual", { bg = P.ui3 })
  hi("VisualNOS", { bg = P.ui3 })
  hi("MatchParen", { fg = P.bg, bg = P.func, bold = true })

  hi("Search", { fg = P.bg, bg = P.type })
  hi("IncSearch", { fg = P.bg, bg = P.func, bold = true })
  hi("CurSearch", { fg = P.bg, bg = P.func, bold = true })
  hi("Substitute", { fg = P.bg, bg = P.keyword })

  hi("Title", { fg = P.func, bold = true })
  hi("Directory", { fg = P.func, bold = true })
  hi("ErrorMsg", { fg = P.error, bold = true })
  hi("WarningMsg", { fg = P.warn, bold = true })
  hi("MoreMsg", { fg = P.type })
  hi("ModeMsg", { fg = P.type, bold = true })
  hi("Question", { fg = P.string, bold = true })

  hi("DiffAdd", { fg = P.string, bg = P.ui0 })
  hi("DiffChange", { fg = P.type, bg = P.ui0 })
  hi("DiffDelete", { fg = P.error, bg = P.ui0 })
  hi("DiffText", { fg = P.func, bg = P.ui1, bold = true })

  hi("Comment", { fg = P.comment })
  hi("String", { fg = P.string })
  hi("Character", { fg = P.string })
  hi("Number", { fg = P.number })
  hi("Float", { fg = P.number })
  hi("Boolean", { fg = P.number })

  hi("Keyword", { fg = P.keyword })
  hi("Conditional", { fg = P.keyword })
  hi("Repeat", { fg = P.keyword })
  hi("Exception", { fg = P.keyword })
  hi("Label", { fg = P.keyword })

  hi("Function", { fg = P.func, bold = true })

  hi("Identifier", { fg = P.fg })
  hi("Constant", { fg = P.number })
  hi("Type", { fg = P.type, bold = true })
  hi("StorageClass", { fg = P.type, bold = true })
  hi("Structure", { fg = P.type, bold = true })
  hi("Typedef", { fg = P.type, bold = true })

  hi("Operator", { fg = P.operator })
  hi("Delimiter", { fg = P.delimiter })
  hi("Special", { fg = P.special })
  hi("SpecialChar", { fg = P.special })
  hi("SpecialKey", { fg = P.comment })

  hi("@comment", { fg = P.comment })
  hi("@string", { fg = P.string })
  hi("@string.escape", { fg = P.number, bold = true })
  hi("@character", { fg = P.string })

  hi("@number", { fg = P.number })
  hi("@boolean", { fg = P.number })
  hi("@constant", { fg = P.number })
  hi("@constant.builtin", { fg = P.number, bold = true })

  hi("@keyword", { fg = P.keyword })
  hi("@keyword.function", { fg = P.keyword })
  hi("@keyword.return", { fg = P.keyword })
  hi("@conditional", { fg = P.keyword })
  hi("@repeat", { fg = P.keyword })
  hi("@exception", { fg = P.keyword })

  hi("@operator", { fg = P.operator })
  hi("@punctuation.delimiter", { fg = P.delimiter })
  hi("@punctuation.bracket", { fg = P.delimiter })
  hi("@punctuation.special", { fg = P.special })

  hi("@type", { fg = P.type, bold = true })
  hi("@type.builtin", { fg = P.type })
  hi("@constructor", { fg = P.type, bold = true })

  hi("@function", { fg = P.func, bold = true })
  hi("@function.call", { fg = P.func })
  hi("@function.builtin", { fg = P.func, bold = true })
  hi("@method", { fg = P.func, bold = true })
  hi("@method.call", { fg = P.func })

  hi("@variable", { fg = P.fg })
  hi("@variable.builtin", { fg = P.fg })
  hi("@parameter", { fg = P.special })
  hi("@property", { fg = P.special })
  hi("@field", { fg = P.special })
  hi("@attribute", { fg = P.special })
  hi("@module", { fg = P.namespace })
  hi("@namespace", { fg = P.namespace })

  hi("@lsp.type.function", { fg = P.func })
  hi("@lsp.type.method", { fg = P.func })
  hi("@lsp.type.parameter", { fg = P.special })
  hi("@lsp.type.property", { fg = P.special })
  hi("@lsp.type.variable", { fg = P.fg })
  hi("@lsp.type.keyword", { fg = P.keyword })
  hi("@lsp.type.type", { fg = P.type, bold = true })
  hi("@lsp.type.class", { fg = P.type, bold = true })
  hi("@lsp.type.namespace", { fg = P.namespace })

  hi("DiagnosticError", { fg = P.error })
  hi("DiagnosticWarn", { fg = P.warn })
  hi("DiagnosticInfo", { fg = P.info })
  hi("DiagnosticHint", { fg = P.hint })

  hi("DiagnosticUnderlineError", { undercurl = true, sp = P.error })
  hi("DiagnosticUnderlineWarn", { undercurl = true, sp = P.warn })
  hi("DiagnosticUnderlineInfo", { undercurl = true, sp = P.info })
  hi("DiagnosticUnderlineHint", { undercurl = true, sp = P.hint })

  hi("DiagnosticVirtualTextError", { fg = P.error, bg = P.ui0 })
  hi("DiagnosticVirtualTextWarn", { fg = P.warn, bg = P.ui0 })
  hi("DiagnosticVirtualTextInfo", { fg = P.info, bg = P.ui0 })
  hi("DiagnosticVirtualTextHint", { fg = P.hint, bg = P.ui0 })

  hi("LspReferenceText", { bg = P.ui1 })
  hi("LspReferenceRead", { bg = P.ui1 })
  hi("LspReferenceWrite", { bg = P.ui2 })

  hi("SpellBad", { undercurl = true, sp = P.error })
  hi("SpellCap", { undercurl = true, sp = P.warn })
  hi("SpellLocal", { undercurl = true, sp = P.info })
  hi("SpellRare", { undercurl = true, sp = P.hint })
end

return M
