return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    init = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
        server_opts_overrides = {
          trace = 'verbose',
          settings = {
            advanced = {
              listCount = 10, -- #completions for panel
              inlineSuggestCount = 3, -- #completions for getCompletions
            },
          },
        },
      }
      vim.keymap.set('n', '<leader>?', '<cmd>lua require("copilot.panel").open()<CR>', { silent = true, desc = 'Open Copilot' })
      -- add support for inline suggestions
      -- vim.keymap.set('i', '<c-space>', '<cmd>lua require("copilot").getCompletions()<CR>', { silent = true, expr = true, desc = 'Get Copilot completions' })
      -- h
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
