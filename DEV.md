# 🛠️ Developer documentation

This is a documentation file for developers.

## Dev environment setup

This project requires the following tools:

- [Commitlint]
- [Lefthook]

Install lefthook:

```shell
lefthook install
```

## ADR

### Keymap hints

The icons in keymap hints represent the intended state after pressing the
keymap, e.g., a turned on toggle for `]o`. This is done so to make the icon
congruent with the text in Which Key. The text says “Turn on foo,” so the icon
should be congruent to avoid
[the Stroop effect](https://en.wikipedia.org/wiki/Stroop_effect).

## Log

### 2025 December

I am pausing this plugin as I move to Snacks.toggle, which has the exact feature
set that I need: Which-Key integration and notifications. All that, and I don’t
have to support a thing.

If I ever feel the need to return to my custom plugin, I should consider
importing the following ideas:

- WK icons should represent the state not the action.
- The configuration interface of Snacks is more streamlined than Toggle’s.

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
