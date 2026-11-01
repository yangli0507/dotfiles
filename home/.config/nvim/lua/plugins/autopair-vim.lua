return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- Use Treesitter to check for context (e.g., don't pair inside strings/comments)
      })
    end,
  },
}
