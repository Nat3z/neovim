return {
  -- 'christoomey/vim-tmux-navigator',
  -- event = 'VeryLazy',
  -- cmd = {
  --   'TmuxNavigateLeft',
  --   'TmuxNavigateDown',
  --   'TmuxNavigateUp',
  --   'TmuxNavigateRight',
  --   'TmuxNavigatePrevious',
  -- },
  --
  -- -- now add the keybinds for tmux for the augroup above
  -- config = function()
  --   vim.cmd [[
  --     augroup tmux_navigator_is_vim
  --     au!
  --     autocmd VimEnter * lua vim.fn.system 'tmux set-option -p @is_vim yes'
  --     autocmd VimLeave * lua vim.fn.system 'tmux set-option -p -u @is_vim'
  --     if exists('##VimSuspend')
  --       autocmd VimSuspend * lua vim.fn.system 'tmux set-option -p -u @is_vim'
  --       autocmd VimResume * vim.fn.system 'tmux set-option -p @is_vim yes'
  --     endif
  --     augroup END
  --   ]]
  -- end,
}