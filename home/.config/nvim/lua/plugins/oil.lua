return {
  "stevearc/oil.nvim",
  dependencies = {
    { "nvim-mini/mini.icons", opts = {} },
    { "jvgrootveld/telescope-zoxide" },
  },
  lazy = false,
  config = function()
    -- 1. Initialize oil with clean default actions
    require("oil").setup({
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
    })

    -- 2. Bind <leader>t seamlessly using an Autocmd to avoid internal oil keymap hijacking
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        vim.keymap.set("n", "<leader>tt", function()
          local dir = require("oil").get_current_dir()
          if not dir then
            vim.notify("Not a valid directory context!", vim.log.levels.WARN)
            return
          end

          -- Prompt for the shell command
          vim.ui.input({ prompt = "Execute shell command: " }, function(input)
            if not input or input == "" then
              return
            end

            -- SAFETY GUARD: schedule safely breaks away from the blocking command-line prompt UI cycle
            vim.schedule(function()
              local cmd = string.format("cd %s && %s", vim.fn.shellescape(dir), input)

              -- Calculate dimensions for a centered floating window
              local width = math.floor(vim.o.columns * 0.8)
              local height = math.floor(vim.o.lines * 0.6)
              local row = math.floor((vim.o.lines - height) / 2)
              local col = math.floor((vim.o.columns - width) / 2)

              -- Create an empty scratch buffer for the output text
              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

              -- Open the floating window framework
              local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                row = row,
                col = col,
                width = width,
                height = height,
                style = "minimal",
                border = "rounded",
                title = " Command Output: " .. input .. " ",
                title_pos = "center",
              })

              -- Helper function to auto-scroll to the bottom of the window
              local function scroll_to_bottom()
                if vim.api.nvim_win_is_valid(win) then
                  local line_count = vim.api.nvim_buf_line_count(buf)
                  if line_count > 0 then
                    vim.api.nvim_win_set_cursor(win, { line_count, 0 })
                  end
                end
              end

              -- Keymaps inside the popup window to close it cleanly
              vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
              vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })

              -- Set initial text state
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running command...", "" })

              -- Execute command asynchronously and pipe logs
              local output_lines = {}
              vim.fn.jobstart(cmd, {
                stdout_buffered = false,
                stderr_buffered = false,
                on_stdout = function(_, data)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then
                        table.insert(output_lines, line)
                      end
                    end
                    vim.api.nvim_buf_set_lines(buf, 1, -1, false, output_lines)
                    scroll_to_bottom()
                  end
                end,
                on_stderr = function(_, data)
                  if data then
                    for _, line in ipairs(data) do
                      if line ~= "" then
                        table.insert(output_lines, "[ERROR] " .. line)
                      end
                    end
                    vim.api.nvim_buf_set_lines(buf, 1, -1, false, output_lines)
                    scroll_to_bottom()
                  end
                end,
                on_exit = function(_, exit_code)
                  local status = exit_code == 0 and "✓ Success" or "✗ Failed (Exit code " .. exit_code .. ")"
                  vim.api.nvim_buf_set_lines(
                    buf,
                    0,
                    1,
                    false,
                    { "Status: " .. status, "Press 'q' or <Esc> to close window.", "" }
                  )
                  scroll_to_bottom()
                end,
              })
            end)
          end)
        end, { buffer = true, desc = "Run shell command here in a floating window" })
      end,
    })

    -- 3. Automatically add every folder you navigate to in Oil into zoxide
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(args)
        if args.data and args.data.actions and args.data.actions.type == "change_dir" then
          local current_dir = require("oil").get_current_dir()
          if current_dir then
            vim.fn.jobstart({ "zoxide", "add", current_dir })
          end
        end
      end,
    })

    -- 4. Navigation Keymap: Query Zoxide -> Open in Oil
    vim.keymap.set("n", "<leader>zo", function()
      local ok, telescope = pcall(require, "telescope")
      if not ok then
        vim.notify("Telescope is required for this zoxide shortcut!", vim.log.levels.ERROR)
        return
      end

      pcall(telescope.load_extension, "zoxide")

      local ext = telescope.extensions.zoxide
      local picker = ext and (ext.zoxide or ext.list)

      if not picker then
        vim.notify("Could not find telescope-zoxide picker function!", vim.log.levels.ERROR)
        return
      end

      picker({
        prompt_title = "Zoxide -> Oil",
        attach_mappings = function(_, map)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          local launch_oil = function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            if selection then
              local target_path = selection.path or selection.value
              if target_path then
                require("oil").open(target_path)
              end
            end
          end

          map("i", "<CR>", launch_oil)
          map("n", "<CR>", launch_oil)

          return true
        end,
      })
    end, { desc = "Zoxide open in Oil" })
  end,
}
