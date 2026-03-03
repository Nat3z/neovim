return {
  'stevearc/oil.nvim',
  lazy = false,
  ---@module 'oil'
  ---@type oil.SetupOpts
  dependencies = {
    { 'echasnovski/mini.icons', opts = {} },
    { 'refractalize/oil-git-status.nvim' }, -- no opts/config here
  },
  init = function()
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
  config = function(_)
    require('oil').setup {
      view_options = {
        show_hidden = true,
      },
      win_options = {
        signcolumn = 'yes:2',
      },
    }
    require('oil-git-status').setup {}
  end,
}
