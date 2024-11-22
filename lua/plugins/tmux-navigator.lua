return {
  'christoomey/vim-tmux-navigator',
  lazy = false,
  -- configure keymaps
  keys = {
    {'n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>'},
    {'n', '<C-j>', '<cmd>TmuxNavigateDown<CR>'},
    {'n', '<C-k>', '<cmd>TmuxNavigateUp<CR>'},
    {'n', '<C-l>', '<cmd>TmuxNavigateRight<CR>'},
  },
}