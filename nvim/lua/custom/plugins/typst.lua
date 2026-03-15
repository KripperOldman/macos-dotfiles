return {
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "tinymist",
      },
    },
    init = function ()
      vim.lsp.config["tinymist"] = {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        settings = {
          formatterMode = "typstyle", -- or "typstfmt"
          formatterProseWrap = true, -- wrap lines in content mode
          formatterPrintWidth = 80,  -- limit line length to 80 if possible
          formatterIndentSize = 2,   -- indentation width
        }
      }
    end
  },
}
