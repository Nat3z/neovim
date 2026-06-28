-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
--

local function neotree_reveal_or_refocus()
  if vim.bo.filetype == 'neo-tree' then
    -- When Neo-tree is already focused, jump back to the previously focused
    -- non-Neo-tree window (normally the main editor window).
    vim.cmd 'wincmd p'
    if vim.bo.filetype ~= 'neo-tree' then
      return
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype ~= 'neo-tree' then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  else
    vim.cmd 'Neotree reveal'
  end
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', neotree_reveal_or_refocus, desc = 'NeoTree reveal/refocus editor', silent = true },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      window = {
        mappings = {
          ['|'] = 'close_window',
        },
      },
    },
  },
}
