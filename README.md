# My Neovim Config

A personal Neovim setup focused on developer productivity, clean UX, and practical defaults.  

Built from scratch using `lazy.nvim` (no Kickstart), and structured for real-world coding.


## Highlights

### Color Scheme Switching
- Telescope-powered colorscheme picker with live previews
- Auto-persisted between sessions

### Telescope
- Enhanced file navigation with project-aware mappings
- `leader` mappings for quick file search, buffer jump, and recent files

### LSP & Dev Experience
- Powered by `lazydev` + `nvim-lspconfig`
- Preconfigured support for:
  - `lua_ls`
  - `pyright`
  - `tsserver`
  - `html`, `cssls`, `jsonls`
  - `clangd`, `gopls`
- Toggleable diagnostics and optional auto-formatting

### Treesitter
- Syntax highlighting and parsing for:
  ```lua
  {
    "lua", "vim", "markdown", "markdown_inline",
    "bash", "python", "html", "json", "css", "scss", "yaml", "toml",
    "javascript", "typescript", "go", "c", "rust",
  }
  ```

### Harpoon
- Home-row key mappings for ultra-fast file switching
- Great for bouncing between test/code/layout

### Yank & Delete Options
- Custom mappings for:
- Optional yank to clipboard
- Optional put over highlight without overwritting buffer
- Optional Delete to void

### Git Integration
- vim-fugitive for Git commands (:G, :Gdiffsplit, :Gstatus)
- Shortcut mappings for 2-way diff splits and quick commit staging


## Structure

This config is fully modular:
- lua/core/ for options, keymaps, autocmds
- lua/plugins/ for plugin declarations (one file per plugin where possible)
	- Declaration and plugin config are one file for simple removals
- Git-friendly, versioned, and self-contained


## Philosophy

Minimal where it can be. Powerful when it needs to be.

This is built to do work, not impress. It prioritizes:
- Fast startup
- Simple navigation
- Clear mental model
- Easy customization


## Tools Used
- lazy.nvim
- telescope.nvim
- nvim-treesitter
- nvim-lspconfig
- nvim-lua/plenary.nvim
- tpope/vim-fugitive
- ThePrimeagen/harpoon


## License

MIT — use freely, fork if helpful, star if you’re into this kind of setup.


## About

I’m building this config to stay productive as a full-time engineer while keeping my tooling sharp.
You’re welcome to borrow from it, suggest improvements, or just watch it evolve.
