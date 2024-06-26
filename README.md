<!-- markdownlint-disable MD013 MD033 MD041 -->

<div align="center">
  <p>
    <img src="assets/toggle-switch.png" align="center" alt="Toggle Logo"
         width="400" />
  </p>
  <p>
    An extensible Neovim plugin for quickly toggling options.
  </p>
</div>

Toggle is a modern, extensible Neovim Lua plugin for toggling options ala
[unimpaired.vim][unimpaired].

Do you have togglable options that you ocassionally want to change during your
Neovim session? For example:

- You usually have `nowrap` on, but sometimes you need to turn on wrapping for
  those long lines to see what’s going on.
- You want to quickly diff two buffers by setting `diffthis` on them.
- Completion turns out to be useless for the current buffer, so you want to
  quickly disable it.
- You usually work with `conceallevel`, but you need to decrease it from time
  to time to double check your Markdown.

Then Toggle is a plugin for you!

## ⚡️ Requirements

- Neovim 0.10+
- Optional plugin dependencies:
  - [Which Key][which-key]

## 📦 Installation

Install the plugin with your preferred package manager, such as [Lazy]:

```lua
{
  "gregorias/toggle.nvim",
  config = true,
}
```

## 🚀 Usage

## 🛠️ Configuration

### Setup

The default configuration setup looks like so:

```lua
require"toggle".setup{
  keymaps = {
    toggle_option_prefix = "yo",
    previous_option_prefix = "[o",
    next_option_prefix = "]o",
    status_dashboard = "yos"
  },
  -- The interface for registering keymaps.
  keymap_registry = require("toggle.keymap").keymap_registry(),
  -- See the default options section below.
  options_by_keymap = …,
}
```

### Default options

All default options use `vim.notify` for state changes.

| Option       | Keymap | Description                            |
| :--          | :--:   | :--                                    |
| conceallevel | `cl`   | 0–3 slider with 0-sticky toggle        |
| diff         | `d`    | on-off switch for `diffthis`/`diffoff` |
| diff all     | `D`    | option for diffing all visible windows |
| wrap         | `w`    | on-off switch for `wrap`               |

## ✅ Comparison to Unimpaired

[Unimpaired][unimpaired] has more scope than Toggle, but it’s less extensible.

| Feature                            | Toggle | [Unimpaired][unimpaired] |
| :--                                | :--:   | :--:                     |
| [Which Key][which-key] integration | ✅     | ❌                       |
| [nvim-notify] integration          | ✅     | ❌                       |
| Extensible options                 | ✅     | ❌                       |
| Configurable keybindings           | ✅     | ❌                       |
| Slider (non-binary) option support | ✅     | ❌                       |

## 🙏 Acknowledgments

The idea of quickly toggling options using `yo`, `[o` `]o` came from
[unimpaired.vim][unimpaired].

The toggle SVG is a modified icon from [Arthur Shlain](https://usefulicons.com/).

[Lazy]: https://github.com/folke/lazy.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify
[unimpaired]: https://github.com/tpope/vim-unimpaired
[which-key]: https://github.com/folke/which-key.nvim
