return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" }, -- Required for main branch
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- 1. Initialize treesitter
    require("nvim-treesitter").setup()

    -- 2. Pass your required languages directly into the install function
    local ensure_installed = {
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "javascript",
      "html",
      "python",
    }
    require("nvim-treesitter").install(ensure_installed)

    -- 3. Enable the built-in highlighting module automatically on file open
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
        if lang then
          pcall(vim.treesitter.start)
        end
      end,
    })
  end,
}
