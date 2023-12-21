-- All the plugins and config related to clojure.
return {
  'Olical/conjure',
  ft = { 'clojure', 'fennel', 'python' }, -- etc
  -- [Optional] cmp-conjure for cmp
  dependencies = {
    {
      'PaterJason/cmp-conjure',
      config = function()
        local cmp = require 'cmp'
        local config = cmp.get_config()
        table.insert(config.sources, {
          name = 'buffer',
          option = {
            sources = {
              { name = 'conjure' },
            },
          },
        })
        cmp.setup(config)
      end,
    },
    'gpanders/nvim-parinfer'
    -- {
    --   'tpope/vim-sexp-mappings-for-regular-people',
    --   dependencies = {
    --     'guns/vim-sexp',
    --   },
    -- },
  },
  config = function(_, opts)
    require('conjure.main').main()
    require('conjure.mapping')['on-filetype']()

    require('which-key').register {
      ['<localleader>c'] = { name = '[C]onnection', _ = 'which_key_ignore' },
      ['<localleader>e'] = { name = '[E]valuate', _ = 'which_key_ignore' },
      ['<localleader>ec'] = { name = 'Evaluate to [C]omment', _ = 'which_key_ignore' },
      ['<localleader>g'] = { name = '[G]et', _ = 'which_key_ignore' },
      ['<localleader>r'] = { name = '[R]efresh', _ = 'which_key_ignore' },
      ['<localleader>l'] = { name = '[L]og', _ = 'which_key_ignore' },
      ['<localleader>s'] = { name = '[S]ession', _ = 'which_key_ignore' },
      ['<localleader>t'] = { name = '[T]est', _ = 'which_key_ignore' },
      ['<localleader>v'] = { name = '[V]iew', _ = 'which_key_ignore' },
    }
  end,
  init = function()
    -- Set configuration options here
    vim.g['conjure#debug'] = true
  end,
}
