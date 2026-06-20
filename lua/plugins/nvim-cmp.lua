return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = require('nixCatsUtils').lazyAdd((function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)()),
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        -- {
        --   'rafamadriz/friendly-snippets',
        --   config = function()
        --     require('luasnip.loaders.from_vscode').lazy_load()
        --   end,
        -- },
      },
    },
    'saadparwaiz1/cmp_luasnip',

    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    luasnip.config.setup {}

    local cmp_menu_was_navigated = false
    local function reset_cmp_menu_navigation()
      cmp_menu_was_navigated = false
    end

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert {
        -- We handle arrows ourselves below so we can remember when the menu
        -- was intentionally navigated. That is the only time <Tab> accepts cmp.
        ['<Down>'] = cmp.config.disable,
        ['<Up>'] = cmp.config.disable,

        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window [b]ack / [f]orward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm { select = true },

        -- If you prefer more traditional completion keymaps,
        -- you can uncomment the following lines
        --['<CR>'] = cmp.mapping.confirm { select = true },
        --['<Tab>'] = cmp.mapping.select_next_item(),
        --['<S-Tab>'] = cmp.mapping.select_prev_item(),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        -- ['<C-l>'] = cmp.mapping(function()
        --   if luasnip.expand_or_locally_jumpable() then
        --     luasnip.expand_or_jump()
        --   end
        -- end, { 'i', 's' }),
        -- ['<C-h>'] = cmp.mapping(function()
        --   if luasnip.locally_jumpable(-1) then
        --     luasnip.jump(-1)
        --   end
        -- end, { 'i', 's' }),
        -- If nothing is selected (including preselections) add a newline as usual.
        -- If something has explicitly been selected by the user, select it.
        ['<Enter>'] = function(fallback)
          -- Don't block <CR> if signature help is active
          -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/13
          if not cmp.visible() or not cmp.get_selected_entry() or cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help' then
            fallback()
          else
            cmp.confirm {
              -- Replace word if completing in the middle of a word
              -- https://github.com/hrsh7th/nvim-cmp/issues/664
              behavior = cmp.ConfirmBehavior.Replace,
              -- Don't select first item on CR if nothing was selected
              select = false,
            }
          end
        end,
        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      sources = {
        {
          name = 'lazydev',
          -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          group_index = 0,
        },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
      },
    }

    cmp.event:on('menu_opened', reset_cmp_menu_navigation)
    cmp.event:on('menu_closed', reset_cmp_menu_navigation)
    cmp.event:on('confirm_done', reset_cmp_menu_navigation)

    vim.keymap.set({ 'i', 's' }, '<Down>', function()
      if cmp.visible() then
        cmp_menu_was_navigated = true
        cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
        return ''
      end
      return '<Down>'
    end, { expr = true, silent = true, replace_keycodes = true, desc = 'Select next cmp item' })

    vim.keymap.set({ 'i', 's' }, '<Up>', function()
      if cmp.visible() then
        cmp_menu_was_navigated = true
        cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
        return ''
      end
      return '<Up>'
    end, { expr = true, silent = true, replace_keycodes = true, desc = 'Select previous cmp item' })

    vim.api.nvim_create_autocmd('TextChangedI', {
      group = vim.api.nvim_create_augroup('cmp-tab-menu-navigation', { clear = true }),
      callback = reset_cmp_menu_navigation,
    })

    local function accept_cursortab()
      local cursortab_ok, cursortab = pcall(require, 'cursortab')
      if not cursortab_ok then
        return false
      end

      local accept_ok, accepted = pcall(cursortab.accept)
      return accept_ok and accepted
    end

    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
      if cmp.visible() and cmp_menu_was_navigated then
        local entry = cmp.get_selected_entry()
        if entry and entry.source.name ~= 'nvim_lsp_signature_help' then
          reset_cmp_menu_navigation()
          vim.schedule(function()
            cmp.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            }
          end)
          return ''
        end
      end

      if accept_cursortab() then
        reset_cmp_menu_navigation()
        return ''
      end

      -- If the LSP menu popped up on its own, don't let it steal Tab from CursorTab.
      if cmp.visible() then
        vim.schedule(function()
          if cmp.visible() then
            cmp.abort()
          end
        end)
      end

      -- No CursorTab and no arrow-selected cmp item: behave like a real Tab.
      return '\t'
    end, { expr = true, silent = true, replace_keycodes = false, desc = 'Accept CursorTab or selected cmp item' })
  end,
}
