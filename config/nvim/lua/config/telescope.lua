local telescope = require("telescope")

telescope.setup({
  defaults = {
    path_display = { "smart" },
    file_ignore_patterns = { "node_modules", "%.git/" },
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
})

pcall(telescope.load_extension, "fzf")
