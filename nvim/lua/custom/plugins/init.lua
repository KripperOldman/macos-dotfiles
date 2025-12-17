-- You can add your own plugins here or in other files in this directory!
-- I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'folke/todo-comments.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    opts = { open_cmd = 'noswapfile vnew' },
    keys = {
      {
        '<leader>ss',
        function()
          require('spectre').open()
        end,
        desc = 'Replace in files (Spectre)',
      },
    },
  },
  { 'nvim-treesitter/nvim-treesitter-context' },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'nvim-telescope/telescope.nvim', -- optional
      'sindrets/diffview.nvim', -- optional
      'ibhagwan/fzf-lua', -- optional
    },
    config = function()
      local neogit = require 'neogit'
      neogit.setup {}
      vim.keymap.set('n', '<leader>g', neogit.open, { desc = 'Neo[G]it' })
    end,
  },
  -- {
  --   'kylechui/nvim-surround',
  --   version = '*', -- Use for stability; omit to use `main` branch for the latest features
  --   event = 'VeryLazy',
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('nvim-surround').setup {}
  --   end,
  -- },
  {
    'nvim-mini/mini.surround',
    version = '*',
    config = function()
      require('mini.surround').setup()
    end,
  },

  {
    'nvim-mini/mini.align',
    version = '*',
    config = function()
      require('mini.align').setup()
    end,
  },
  -- {
  --   'nvim-mini/mini.animate',
  --   version = '*',
  --   config = function()
  --     require('mini.animate').setup()
  --   end,
  -- },
  {
    'nvim-mini/mini.comment',
    version = '*',

    config = function()
      require('mini.comment').setup()
    end,
  },
  {
    'nvim-mini/mini.cursorword',
    version = '*',
    config = function()
      require('mini.cursorword').setup()
    end,
  },
  {
    'Eandrju/cellular-automaton.nvim',
    config = function()
      require('which-key').add {
        { '<leader>f', group = '[F]***' },
        { '<leader>fm', group = '[M]y' },
        { '<leader>fml', '<cmd>CellularAutomaton game_of_life<CR>', desc = 'Game of [L]ife' },
        { '<leader>fmr', '<cmd>CellularAutomaton make_it_rain<CR>', desc = 'Make it [R]ain' },
      }
    end,
  },
  {
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = {
      'csv',
      'tsv',
      'csv_semicolon',
      'csv_whitespace',
      'csv_pipe',
      'rfc_csv',
      'rfc_semicolon',
    },
    cmd = {
      'RainbowDelim',
      'RainbowDelimSimple',
      'RainbowDelimQuoted',
      'RainbowMultiDelim',
    },
  },
  -- {
  --   'github/copilot.vim',
  --   config = function()
  --     vim.keymap.set('i', '<C-L>', 'copilot#Accept("")', {
  --       expr = true,
  --       replace_keycodes = false,
  --     })
  --     vim.g.copilot_assume_mapped = true
  --     vim.g.copilot_no_tab_map = true
  --     vim.cmd 'Copilot disable'
  --   end,
  -- },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    config = function()
      vim.api.nvim_set_keymap('n', '<localleader>p', '<Cmd>MarkdownPreview<CR>', { desc = '[P]review' })
    end,
  },
  { 'fidian/hexmode' },
  -- {
  --   'jsongerber/thanks.nvim',
  --   opts = {
  --     plugin_manager = 'lazy',
  --   },
  -- },
  {
    'skosulor/nibbler',
    config = function()
      require('nibbler').setup {
        display_enabled = true, -- Set to false to disable real-time display (default: true)
      }
    end,
  },
}
