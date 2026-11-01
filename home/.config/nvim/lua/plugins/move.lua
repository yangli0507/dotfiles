return {
  "fedepujol/move.nvim",
  event = "VeryLazy", -- Loads the plugin lazily to save startup time
  config = function()
    -- 1. Setup options (Optional: change default settings here)
    require("move").setup({
      line = {
        enable = true,
        indent = true, -- Auto-indent the line when moved up/down
      },
      block = {
        enable = true,
        indent = true, -- Auto-indent blocks when moved up/down
      },
      word = {
        enable = true,
      },
      char = {
        enable = true,
      },
    })

    -- 2. Define standard keymaps using the Alt (Option) key
    local opts = { noremap = true, silent = true }

    -- Normal Mode mappings (Move individual lines / characters)
    vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts) -- Alt+j: Move line down
    vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts) -- Alt+k: Move line up
    vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts) -- Alt+h: Move character left
    vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts) -- Alt+l: Move character right
    vim.keymap.set("n", "<A-w>", ":MoveWord(1)<CR>", opts) -- Alt+w: Move word forward

    -- Visual Mode mappings (Move highlighted blocks)
    vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts) -- Alt+j: Move block down
    vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts) -- Alt+k: Move block up
    vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts) -- Alt+h: Move block left
    vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts) -- Alt+l: Move block right
  end,
}
