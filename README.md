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

### Default options

All default options use `vim.notify` for state changes.

| Option       | Keymap | Description                            |
| :--          | :--:   | :--                                    |
| conceallevel | `cl`   | 0–3 slider with 0-sticky toggle        |
| diff         | `d`    | on-off switch for `diffthis`/`diffoff` |
| diff all     | `D`    | option for diffing all visible windows |
| wrap         | `w`    | on-off switch for `wrap`               |

## 🙏 Acknowledgments

The idea of quickly toggling options using `yo`, `[o` `]o` came from
[unimpaired.vim][unimpaired].

The toggle SVG is a modified icon from [Arthur Shlain](https://usefulicons.com/).

[unimpaired]: https://github.com/tpope/vim-unimpaired
[which-key]: https://github.com/folke/which-key.nvim
