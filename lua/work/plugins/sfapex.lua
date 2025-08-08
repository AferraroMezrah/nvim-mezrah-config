-- lua/work/plugins/sfapex.lua

return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {},
  opts = function(_, opts)
    opts = opts or {}
    opts.ensure_installed = opts.ensure_installed or {}

    -- Try to install via TS if it recognizes "apex"; otherwise, register a custom parser:
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.apex = {
      install_info = {
        -- Choose a maintained grammar. These two are commonly used; try one:
        -- url = "https://github.com/MrMufflon/tree-sitter-sfapex",
        url = "https://github.com/austinjones/tree-sitter-apex",
        files = { "src/parser.c" },
        -- some grammars need "src/scanner.c" too; if you get build errors, add it:
        -- files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
      },
      filetype = "apex",
    }

    table.insert(opts.ensure_installed, "apex")
    opts.highlight = opts.highlight or {}
    opts.highlight.enable = true
    opts.highlight.additional_vim_regex_highlighting = false

    return opts
  end,
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}

