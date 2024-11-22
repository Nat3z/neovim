-- implement this vim coded
-- function! s:set_is_vim()
--   call s:TmuxCommand("set-option -p @is_vim yes")
-- endfunction
--
-- function! s:unset_is_vim()
--   call s:TmuxCommand("set-option -p -u @is_vim")
-- endfunction
--
-- augroup tmux_navigator_is_vim
--   au!
--   autocmd VimEnter * call s:set_is_vim()
--   autocmd VimLeave * call s:unset_is_vim()
--   if exists('##VimSuspend')
--     autocmd VimSuspend * call s:unset_is_vim()
--     autocmd VimResume * call s:set_is_vim()
--   endif
-- augroup END
--

return {
  'christoomey/vim-tmux-navigator',
  event = 'VeryLazy',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
  },

  -- now add the keybinds for tmux for the augroup above
  config = function()
    vim.cmd [[
      augroup tmux_navigator_is_vim
      au!
      autocmd VimEnter * lua vim.fn.system 'tmux set-option -p @is_vim yes'
      autocmd VimLeave * lua vim.fn.system 'tmux set-option -p -u @is_vim'
      if exists('##VimSuspend')
        autocmd VimSuspend * lua vim.fn.system 'tmux set-option -p -u @is_vim'
        autocmd VimResume * vim.fn.system 'tmux set-option -p @is_vim yes'
      endif
      augroup END
    ]]
  end,
}
