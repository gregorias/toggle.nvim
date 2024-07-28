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

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
