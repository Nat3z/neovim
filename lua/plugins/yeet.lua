return {
  'nat3z/yeet.nvim',
  dir = require('nixCatsUtils').lazyAdd '~/Code/yeet.nvim',
  name = 'yeet.nvim',
  config = function()
    local yeet = require 'yeet'
    yeet.setup {
      -- this model is the provider/slug identified by your harness.
      model = 'openai-codex/gpt-5.4-mini', -- e.g., openai-codex/gpt-5.4-mini.

      -- use a skill, command, or prompt to tell the agent how to yeet
      prompt = '/yeet',

      -- the model provider used to yeet your changes
      provider = yeet.providers.PiProvider, -- available options: PiProvider

      -- tmux pane configuration
      tmux_pane = {
        size = 25, -- height of the tmux pane in lines
        direction = 'v', -- direction of split: h (horizontal), v (vertical)
      },

      -- timings for tmux when your harness is launching and when to send keys
      -- all numbers are in (ms)
      timings = {
        launch_delay = 300, -- time to wait before sending keys for your prompt
        send_delay = 1500, -- time to wait after launch_delay before submitting the prompt
        git_check_delay = 1000, -- loop time to poll git to see if changes were committed
        timeout = 180000, -- maximum time to wait for the model to push changes
      },
    }

    vim.keymap.set('n', '<leader>gy', function()
      if vim.env.TMUX == nil or vim.env.TMUX == '' then
        yeet.yeet_with_headless() -- runs without tmux, will just provide vim notification
      else
        yeet.yeet_with_tmux() -- runs using tmux, will open a split pane to see output
      end
    end)
  end,
}
