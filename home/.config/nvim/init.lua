--require("keys")

--vim.api.nvim_create_user_command("O", function()
--require("oil").open()
--end, {})

---@diagnostic disable: undefined-global

-- 1. Load your existing configuration modules
require("vim_config")
require("plugin")
require("keys")

-- 2. Custom User Commands
vim.api.nvim_create_user_command("O", function()
  require("oil").open()
end, {})

-- 3. Global Filetype & Indentation Activation
vim.cmd("filetype plugin indent on")

-- Create an autocommand group to prevent duplicate event triggers
local indent_group = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })

-- 4. Rules for 2-Space Coding Languages (TypeScript, React, JavaScript, Lua)
vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "lua", "css", "html" },
  callback = function()
    -- Indentation behavior
    vim.opt_local.smartindent = true
    vim.opt_local.autoindent = true
    vim.opt_local.cindent = true

    -- Spacing rules
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- 5. Rules for 4-Space Coding Languages (Java, Python, C, C++)
vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "java", "python", "c", "cpp" },
  callback = function()
    -- Indentation behavior
    vim.opt_local.smartindent = true
    vim.opt_local.autoindent = true
    -- Python should not use strict c-braces indenting
    vim.opt_local.cindent = (vim.bo.filetype ~= "python")

    -- Spacing rules
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- 6. Rules for Text & Markdown (Manual Control, No Autocomplete/Guessing)
vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    -- Disable smart/auto engines completely
    vim.opt_local.smartindent = false
    vim.opt_local.autoindent = false
    vim.opt_local.cindent = false

    -- Baseline for manual tabs if you choose to use them
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true

    -- Let prose wrap cleanly on long lines
    vim.opt_local.wrap = true
  end,
})
