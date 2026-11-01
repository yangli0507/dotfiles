-- save by pressing Escape
vim.keymap.set("n", "<Esc>", ":w<CR>", { desc = "Save" })
-- select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })
-- Select all and paste over from normal mode without losing your position
vim.keymap.set("n", "<C-p>", "ggVGp", { desc = "Paste over all text" })

-- go back to parent level
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open Parent Directory in Oil" })
-- format the file
vim.keymap.set("n", "<leader>cf", function()
  require("conform").format({
    lsp_format = "fallback",
  })
end, { desc = "Format current file" })

-- Delete without copying to clipboard / register
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete into black hole register" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete char into black hole register" })
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change into black hole register" })

vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
