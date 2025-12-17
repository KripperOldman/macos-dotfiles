-- All the plugins and config related to clojure.
return {
  { 'Olical/nfnl' },
  {
    -- 'Olical/conjure',
    dir = '~/Workspace/personal/conjure',
    ft = {
      'clojure',
      'fennel',
      'python',
      'racket',
      'haskell',
    }, -- etc
    dependencies = {
      'benknoble/vim-racket',
      {
        'gpanders/nvim-parinfer',
        version = false,
        config = function ()
          vim.g.parinfer_force_balance = true
        end
      },
      {
        'Grazfather/sexp.nvim',
        dependencies = { 'tpope/vim-repeat' },
        config = {
          filetypes = 'clojure,scheme,lisp,timl,fennel,racket',
          enable_insert_mode_mappings = false,
          mappings = {
            sexp_splice_list = 'dsf',
            sexp_move_to_prev_element_head = 'B',
            sexp_move_to_next_element_head = 'W',
            sexp_move_to_prev_element_tail = 'gE',
            sexp_move_to_next_element_tail = 'E',
            sexp_insert_at_list_head = '<I',
            sexp_insert_at_list_tail = '>I',
            sexp_swap_list_backward = '<f',
            sexp_swap_list_forward = '>f',
            sexp_swap_element_backward = '<e',
            sexp_swap_element_forward = '>e',
            sexp_emit_head_element = '>(',
            sexp_emit_tail_element = '<)',
            sexp_capture_prev_element = '<(',
            sexp_capture_next_element = '>)',
            sexp_raise_element = '<re',
            sexp_raise_list = '<rf',
          },
        },
      },
    },
    config = function(_, opts)
      require('conjure.main').main()
      require('conjure.mapping')['on-filetype']()

      -- require('which-key').add {
      --   ['<localleader>c'] = { name = '[C]onnection', _ = 'which_key_ignore' },
      --   ['<localleader>e'] = { name = '[E]valuate', _ = 'which_key_ignore' },
      --   ['<localleader>ec'] = { name = 'Evaluate to [C]omment', _ = 'which_key_ignore' },
      --   ['<localleader>g'] = { name = '[G]et', _ = 'which_key_ignore' },
      --   ['<localleader>r'] = { name = '[R]efresh', _ = 'which_key_ignore' },
      --   ['<localleader>l'] = { name = '[L]og', _ = 'which_key_ignore' },
      --   ['<localleader>s'] = { name = '[S]ession', _ = 'which_key_ignore' },
      --   ['<localleader>t'] = { name = '[T]est', _ = 'which_key_ignore' },
      --   ['<localleader>v'] = { name = '[V]iew', _ = 'which_key_ignore' },
      -- }

      local ls = require 'luasnip'
      local s = ls.snippet

      -- vim.lsp.enable 'racket_langserver'
    end,
    init = function()
      -- Set configuration options here
      -- vim.g['conjure#debug'] = true
    end,
  },
}
