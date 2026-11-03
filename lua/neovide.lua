-- Neovide-only settings. Loaded from init.lua when `vim.g.neovide` is set.

-- Matches the JetBrains Mono Nerd Font installed by the nixos config
vim.o.guifont = 'JetBrainsMono Nerd Font:h14'

vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 8
vim.g.neovide_padding_left = 8
vim.g.neovide_padding_right = 8

-- Tone the animations down so it still feels like a terminal
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.3
vim.g.neovide_scroll_animation_length = 0.15
vim.g.neovide_position_animation_length = 0.1

vim.g.neovide_remember_window_size = true
vim.g.neovide_hide_mouse_when_typing = true

-- Left option acts as <M-…> like in a terminal, right option still types special characters
vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

-- Neovide doesn't map any cmd keys itself, so add the usual macOS ones
vim.keymap.set('n', '<D-s>', '<cmd>write<CR>', { desc = 'Save file' })
vim.keymap.set('x', '<D-c>', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'x' }, '<D-v>', '"+P', { desc = 'Paste from system clipboard' })
vim.keymap.set({ 'i', 'c' }, '<D-v>', '<C-r>+', { desc = 'Paste from system clipboard' })
vim.keymap.set('t', '<D-v>', '<C-\\><C-n>"+Pi', { desc = 'Paste from system clipboard' })

local function scale_by(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
end

vim.g.neovide_scale_factor = 1.0
vim.keymap.set('n', '<D-=>', function()
  scale_by(0.1)
end, { desc = 'Increase font size' })
vim.keymap.set('n', '<D-->', function()
  scale_by(-0.1)
end, { desc = 'Decrease font size' })
vim.keymap.set('n', '<D-0>', function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = 'Reset font size' })
