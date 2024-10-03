return {
  'numToStr/Comment.nvim',
  init = function()
    require('Comment').setup()
    vim.api.nvim_set_keymap('n', '<leader>/', 'gcc<ESC>', { desc = 'Line Comment', silent = true })
    vim.api.nvim_set_keymap('v', '<leader>/', 'gcc<ESC>', { desc = 'Line Comment', silent = true })
  end,
}
