local config_path = vim.fn.expand '~/.config/cursortab/cursortab_choice.cfg'

local run_model = {
  'llama',
  'serve',
  '-hf',
  'sweepai/sweep-next-edit-1.5b',
  '--port',
  '8000',
  '--ctx-size',
  '2048',
  '--parallel',
  '1',
  '--cache-reuse',
  '64',
  '--spec-type',
  'ngram-mod',
  '--spec-ngram-mod-n-match',
  '24',
  '--spec-ngram-mod-n-min',
  '12',
  '--spec-ngram-mod-n-max',
  '64',
}

local function start_local_tab_model()
  -- check if the tab model is running by pinging the server
  local _, ok = pcall(function()
    local obj = vim.system({ 'curl', '-I', 'http://localhost:8000/health' }):wait()
    return obj.code == 0
  end)

  if not ok then
    -- run the local model in a tmux window titled 'tab-model-runner'
    vim.notify('Starting local tab server...', vim.log.levels.INFO)
    vim.system({ 'tmux', 'new', '-d', '-s', 'tab-model-runner', table.concat(run_model, ' ') }, { text = true }):wait()
    vim.defer_fn(function()
      local _, ok_new = pcall(function()
        local obj = vim.system({ 'curl', '-I', 'http://localhost:8000/health' }):wait()
        return obj.code == 0
      end)
      if not ok_new then
        vim.notify('Tab server failed to start!', vim.log.levels.ERROR)
      end
    end, 3000)
  end
end

local function get_cursortab_setup(model_using)
  local setup = {
    enabled = true,
    log_level = 'info',
    state_dir = vim.fn.stdpath 'state' .. '/cursortab',

    keymaps = {
      accept = '<Tab>',
      partial_accept = '<S-Tab>',
      trigger = false,
    },

    ui = {
      completions = {
        addition_style = 'dimmed',
        fg_opacity = 0.6,
      },
      jump = {
        symbol = '',
        text = ' TAB ',
        show_distance = true,
      },
    },

    behavior = {
      idle_completion_delay = 100,
      text_change_debounce = 100,
      max_visible_lines = 4,
      enabled_modes = { 'insert' },
      cursor_prediction = {
        enabled = true,
        auto_advance = true,
        proximity_threshold = 2,
      },
      ignore_paths = {
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
      ignore_gitignored = true,
    },
    blink = {
      enabled = false,
      ghost_text = true,
    },
  }

  if model_using == 'hosted' then
    setup.provider = {
      type = 'mercuryapi',
      api_key_env = 'MERCURY_AI_TOKEN',
      privacy_mode = true,
      context_size = 2048,
      max_tokens = 64,
      completion_timeout = 1000,
    }
    setup.behavior.idle_completion_delay = 400
    setup.behavior.text_change_debounce = 500
  elseif model_using == 'local' then
    setup.provider = {
      type = 'sweep',
      url = 'http://localhost:8000',
      context_size = 192,
      max_tokens = 96,
      completion_timeout = 6000,
    }

    setup.behavior.idle_completion_delay = 10
    setup.behavior.text_change_debounce = 1
  end

  return setup
end

local function choose_local_or_hosted(opts)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  opts = opts or {}

  -- make the directory if not exist
  vim.fn.mkdir(vim.fn.fnamemodify(config_path, ':h'), 'p')
  local function apply_choice(choice)
    vim.fn.writefile({ choice }, config_path)

    local ok_config, ct_config = pcall(require, 'cursortab.config')
    local ok_daemon, daemon = pcall(require, 'cursortab.daemon')
    local ok_cursortab, cursortab = pcall(require, 'cursortab')
    if ok_config and ok_daemon and ok_cursortab then
      local setup = get_cursortab_setup(choice)
      ct_config.setup(setup)
      daemon.set_enabled(setup.enabled)
      cursortab.restart()
      vim.notify('Cursortab switched to ' .. choice, vim.log.levels.INFO)
      if choice == 'local' then
        start_local_tab_model()
      end
    else
      require('lazy.core.loader').reload 'cursortab.nvim'
    end
  end

  local model_using = 'hosted'
  if vim.fn.filereadable(config_path) == 1 then
    model_using = vim.fn.readfile(config_path)[1] or 'hosted'
  end -- either hosted or local

  pickers
    .new(opts, {
      prompt_title = 'Which Cursortab Model?',
      finder = finders.new_table {
        results = {
          {
            'Use Hosted Tab' .. (model_using == 'hosted' and ' (*)' or ''),
            function()
              -- write a file in the config that says using hosted Tab. have the file called cursortab_choice.cfg
              --
              apply_choice 'hosted'
            end,
          },
          {
            (model_using == 'local' and 'Kill' or 'Use') .. ' Local Tab' .. (model_using == 'local' and ' (*)' or ''),
            function()
              if model_using == 'local' then
                -- kill the tmux session
                local kill_obj = vim.system({ 'tmux', 'kill-session', '-t', 'tab-model-server' }):wait()
                if kill_obj.code == 0 then
                  vim.notify('Killed tmux session', vim.log.levels.INFO)
                else
                  vim.notify('Failed to kill tmux session', vim.log.levels.ERROR)
                end

                -- switch to hosted
                apply_choice 'hosted'
              else
                apply_choice 'local'
              end
            end,
          },
        },
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry[1],
            ordinal = entry[1],
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          selection.value[2]() -- Executes the command mapped to the name
        end)
        return true
      end,
    })
    :find()
end

-- Map it to a key
vim.keymap.set('n', '<leader><Tab>', choose_local_or_hosted, { desc = 'cursortab: choose local or hosted model' })

return {
  {
    'cursortab/cursortab.nvim',
    lazy = false,
    build = 'cd server && go build',
    config = function()
      local model_using = 'hosted'
      if vim.fn.filereadable(config_path) == 1 then
        model_using = vim.fn.readfile(config_path)[1] or 'hosted'
      end -- either hosted or local

      if model_using == 'local' then
        start_local_tab_model()
      end

      require('cursortab').setup(get_cursortab_setup(model_using))
    end,
  },
}
