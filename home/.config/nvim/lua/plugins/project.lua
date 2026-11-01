return {
    "coffebar/neovim-project",
    dependencies = {
        { "nvim-telescope/telescope.nvim" },
        { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
    init = function()
        -- Setup the new plugin (it uses the same configuration structure)
        require("neovim-project").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
        }

        -- Your minimal implementation of fzf-lua based project finder
        local history = require("neovim-project.utils.history")
        local project = require("neovim-project.project")

        vim.api.nvim_create_user_command("FzfProjects", function()
            local projects = history.get_recent_projects()

            require("fzf-lua").fzf_exec(projects, {
                prompt = "Projects> ",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            local project_path = selected[1]
                            if project.set_pwd(project_path, "fzf-lua") then
                                require("fzf-lua").files()
                            end
                        end
                    end
                }
            })
        end, {})
    end,
    keys = {
        {
            "<leader>fp", "<cmd>FzfProjects<CR>", desc="Find Recent Projects"
        }
    }
}

