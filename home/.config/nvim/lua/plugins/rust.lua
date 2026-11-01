return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          -- Changed 'client' to '_client' to clear the unused warning
          on_attach = function(_client, bufnr)
            -- Removed the duplicate 'local bufnr =' line since it's already in the parameter above

            -- Open code actions specific to Rust
            vim.keymap.set("n", "<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
            end, { desc = "Rust Code Action", buffer = bufnr })

            -- Open the expand macro / explain error view
            vim.keymap.set("n", "<leader>ce", function()
              vim.cmd.RustLsp("explainError")
            end, { desc = "Rust Explain Error", buffer = bufnr })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
              check = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },
}
