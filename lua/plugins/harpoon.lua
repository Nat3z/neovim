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

    vim.keymap.set('n', '<leader>e', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon Quick Menu' })

    local function map_harpoon_slot(lhs, idx, desc)
      vim.keymap.set('n', lhs, function()
        harpoon:list():select(idx)
      end, { desc = desc })
    end

    for i = 1, 4 do
      map_harpoon_slot(('<A-%d>'):format(i), i, ('Harpoon %d (Alt)'):format(i))
    end
  end,
}
