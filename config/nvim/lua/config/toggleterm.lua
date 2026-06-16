require("toggleterm").setup({
  open_mapping = [[<c-\>]],
  direction = "vertical",
  size = function(term)
    if term.direction == "horizontal" then
      return math.floor(vim.o.lines * 0.35)
    end
    return math.floor(vim.o.columns * 0.45)
  end,
  shade_terminals = false,
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
  close_on_exit = true,
})
