# My Neovim Config

A personal Neovim setup focused on developer productivity, clean UX, and practical defaults.  

Built from scratch using `lazy.nvim` (Primeagen inspired and adapted), and structured for real-world coding.

![Neovim](https://img.shields.io/badge/Neovim-0.11+-green?logo=neovim)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Scope](https://img.shields.io/badge/Scope-Personal%20Use-blue)
![Plugin Manager](https://img.shields.io/badge/Plugin_Manager-Lazy.nvim-blueviolet)
![Platform](https://img.shields.io/badge/Platform-macOS_|_Linux-lightgrey)
![Languages](https://img.shields.io/badge/Languages-ts_|_py_|_html_|_lua_|_go_|_json_|_css-ff69b4)


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
  - `rust_analyzer`
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


### Tmux Integration (Optional)

- Includes mappings for tmux-sessionizer
- Press <C-f> or <M-h> to launch project-based tmux sessions
- Requires the tmux-sessionizer script

To install:

```bash
curl -Lo ~/.local/bin/tmux-sessionizer https://raw.githubusercontent.com/ThePrimeagen/.dotfiles/master/bin/.local/scripts/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
```

Modify the script to match your projects directory or fork it into your own dotfiles.


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
- lewis6991/gitsigns.nvim
- jiaoshijie/undotree


## Tagged Versions

- **v0-core-config** – Minimal pre-LSP Neovim config
- **v0.9.0** – Working LSP setup with core mappings
- **v1.0.0** – Full MVP: LSP + Node QoL commands + README
- **v1.0.1** – Feat: Rust LSP. Keymap collision fixes


## System prerequisites

| Tool | Min version | Ubuntu/Debian | macOS (Homebrew) | Notes |
|------|-------------|---------------|------------------|-------|
| **Neovim** | **0.11** | `sudo add-apt-repository ppa:neovim-ppa/stable && sudo apt install neovim` | `brew install neovim` | Tested on 0.11.3 |
| git, curl | — | `sudo apt install git curl ca-certificates` | built-in / `brew install git curl` | Needed by Lazy & Mason |
| **fzf** | latest | `sudo apt install fzf` | `brew install fzf` | Telescope fzf-native |
| **ripgrep** | latest | `sudo apt install ripgrep` | `brew install ripgrep` | Telescope live-grep |
| **fd** | — | `sudo apt install fd-find && sudo ln -s $(command -v fdfind) /usr/local/bin/fd` | `brew install fd` | Faster file picker |
| Build tools | — | `sudo apt install build-essential cmake` | Xcode CLI tools | Treesitter & fzf-native |
| **Node 18+** | 18 LTS | `sudo apt install nodejs npm` | `brew install node` | JS/TS/HTML/CSS language servers |
| **Python 3.11+** | 3.11 | `sudo apt install python3 python3-pip && pip3 install --break-system-packages pynvim` | `brew install python && pip3 install pynvim` | Pyright & provider |
| Clipboard (Linux) | — | `sudo apt install xclip` \| `wl-clipboard` | — | Enables `"+y`/`"+p` |
| **Optional runtimes** | — | `sudo apt install luarocks php composer default-jdk` (when needed) | `brew install luarocks php composer openjdk` | Only for LuaRocks, PHP, Java LSPs |
| **Optional utilities** | — | `sudo apt install bat universal-ctags lazygit tmux` | `brew install bat universal-ctags lazygit tmux` | Nice-to-haves |

<sub>_LuaSnip placeholder transforms:_ requires PCRE-2. On Ubuntu: `sudo apt install libpcre2-dev`; on macOS PCRE-2 ships with Homebrew.</sub>  
<sub>_tmux users:_ add `set -g focus-events on` in ~/.tmux.conf for auto-reload.</sub>

## License

MIT — use freely, fork if helpful, star if you’re into this kind of setup.


## About

I’m building this config to stay productive as a full-time engineer while keeping my tooling sharp.
You’re welcome to borrow from it, suggest improvements, or just watch it evolve.

