return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  init = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon Add to List' })
    vim.keymap.set('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon Quick Menu' })

    vim.keymap.set('n', '<C-y>', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon 1st' })
    vim.keymap.set('n', '<C-u>', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon 2nd' })
    vim.keymap.set('n', '<C-i>', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon 3rd' })
    vim.keymap.set('n', '<C-o>', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon 4th' })
  end,
}
