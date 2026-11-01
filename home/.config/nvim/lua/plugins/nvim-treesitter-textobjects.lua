return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main", -- Ensure you are tracking the main branch explicitly
    dependencies = {
        "nvim-treesitter/nvim-treesitter"
    },
    init = function()
        -- Disable built-in ftplugin mappings to avoid keymap conflicts
        vim.g.no_plugin_maps = true
    end,
    config = function()
        local ts_select = require("nvim-treesitter-textobjects.select")
        local ts_swap = require("nvim-treesitter-textobjects.swap")

        -- =====================================================================
        -- 1. TEXT OBJECTS: SELECT (Visual/Operator-pending modes)
        -- =====================================================================
        local keymaps = {
            ["af"] = { query = "@function.outer", mode = "V" }, -- linewise
            ["if"] = { query = "@function.inner", mode = "v" }, -- charwise
            ["ac"] = { query = "@class.outer", mode = "<c-v>" }, -- blockwise
            ["ao"] = { query = "@comment.outer", mode = "v" },
            ["ic"] = { query = "@class.inner", mode = "v", desc = "Select inner part of a class region" },
            ["as"] = { query = "@local.scope", query_group = "locals", mode = "v", desc = "Select language scope" },
        }

        for lhs, map in pairs(keymaps) do
            vim.keymap.set({ "x", "o" }, lhs, function()
                ts_select.select_textobject(map.query, map.query_group or "textobjects", {
                    lookahead = true, -- Replaces global lookahead
                    include_surrounding_whitespace = true, -- Replaces global whitespace extension
                    selection_mode = map.mode, -- Applies custom selection modes directly
                })
            end, { desc = map.desc })
        end

        -- =====================================================================
        -- 2. TEXT OBJECTS: SWAP (Normal mode parameter manipulation)
        -- =====================================================================
        vim.keymap.set("n", "<leader>a", function()
            ts_swap.swap_next("@parameter.inner", "textobjects")
        end, { desc = "Swap with next parameter" })

        vim.keymap.set("n", "<leader>A", function()
            ts_swap.swap_previous("@parameter.inner", "textobjects")
        end, { desc = "Swap with previous parameter" })
    end
}


