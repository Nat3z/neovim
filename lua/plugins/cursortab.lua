return {
  {
    'cursortab/cursortab.nvim',
    lazy = false,
    build = 'cd server && go build',
    config = function()
      require('cursortab').setup {
        enabled = true,
        log_level = 'info', -- "trace", "debug", "info", "warn", "error"
        state_dir = vim.fn.stdpath 'state' .. '/cursortab', -- Directory for runtime files (log, socket, pid)

        keymaps = {
          accept = '<Tab>', -- Keymap to accept completion, or false to disable
          partial_accept = '<S-Tab>', -- Keymap to partially accept, or false to disable
          trigger = false, -- Keymap to manually trigger completion, or false to disable
        },

        ui = {
          completions = {
            addition_style = 'dimmed', -- "dimmed" or "highlight"
            fg_opacity = 0.6, -- opacity for completion overlays (0=invisible, 1=fully visible)
          },
          jump = {
            symbol = '', -- Symbol shown for jump points
            text = ' TAB ', -- Text displayed after jump symbol
            show_distance = true, -- Show line distance for off-screen jumps
          },
        },

        behavior = {
          idle_completion_delay = 400, -- Wait longer before automatic completions to save hosted tokens
          text_change_debounce = 1000, -- Debounce text changes longer to save hosted tokens
          max_visible_lines = 12, -- Max visible lines per completion (0 to disable)
          enabled_modes = { 'insert' }, -- Modes where completions are active
          cursor_prediction = {
            enabled = true, -- Show jump indicators after completions
            auto_advance = true, -- When no changes, show cursor jump to last line
            proximity_threshold = 2, -- Min lines apart to show cursor jump (0 to disable)
          },
          ignore_paths = { -- Glob patterns for files to skip completions
            '*.min.js',
            '*.min.css',
            '*.map',
            '*-lock.json',
            '*.lock',
            '*.sum',
            '*.csv',
            '*.tsv',
            '*.parquet',
            '*.zip',
            '*.tar',
            '*.gz',
            '*.pem',
            '*.key',
            '.env',
            '.env.*',
            '*.log',
          },
          ignore_gitignored = true, -- Skip files matched by .gitignore
        },
        blink = {
          enabled = false, -- Enable blink source
          ghost_text = true, -- Show native ghost text alongside blink menu
        },

        -- Hosted Mercury API option:
        provider = {
          type = 'mercuryapi',
          api_key_env = 'MERCURY_AI_TOKEN',
          privacy_mode = true,
          context_size = 2048,
          max_tokens = 64,
          completion_timeout = 10000,
        },

        -- Local fastest single-line option:
        -- provider = {
        --   type = 'inline',
        --   url = 'http://localhost:8000',
        --   context_size = 512,
        --   max_tokens = 8,
        --   completion_timeout = 3000,
        -- },

        -- Local multi-line / multi-edit provider:
        -- provider = {
        --   type = 'sweep',
        --   url = 'http://localhost:8000',
        --   context_size = 768,
        --   max_tokens = 16,
        --   completion_timeout = 6000,
        -- },
      }
    end,
  },
}
