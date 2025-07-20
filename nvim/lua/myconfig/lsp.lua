local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  })
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "html", "csharp_ls", "sqlls" }
})

local lspconfig = require("lspconfig")
local servers = { "ts_ls", "html", "csharp_ls", "sqlls" }

for _, server in ipairs(servers) do
  lspconfig[server].setup({
    capabilities = require("cmp_nvim_lsp").default_capabilities()
  })
end
