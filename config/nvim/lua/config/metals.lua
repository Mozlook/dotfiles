local metals = require("metals")

local config = metals.bare_config()

config.capabilities = require("cmp_nvim_lsp").default_capabilities()
config.init_options.statusBarProvider = "off" -- progress goes through fidget
config.settings = {
  showImplicitArguments = true,
}

config.on_attach = function(_, bufnr)
  vim.keymap.set("n", "<leader>mc", function()
    require("telescope").extensions.metals.commands()
  end, { buffer = bufnr, desc = "Metals commands" })
end

local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  group = group,
  callback = function()
    metals.initialize_or_attach(config)
  end,
})

-- lazy loads this on the first scala/sbt/java FileType, after that event fired
metals.initialize_or_attach(config)
