# dotfiles (a.k.a. profile)

This is the dotfiles I use as my profile on the desktop, server (both openSUSE Leap), and laptop (macOS).

Need more inspiration? Check out [Awesome dotfiles](), [dotfiles]() and the [dotfiles topic]() on GitHub.

[Awesome dotfiles]: https://github.com/webpro/awesome-dotfiles

[dotfiles]: https://dotfiles.github.io/

[dotfiles topic]: https://github.com/topics/dotfiles

## Install

This is meant to reside in `~/projects/dotfiles`. The installer makes symlinks to this repo so that updates are applied
via `git pull`.

```bash
git clone https://github.com/NiceGuyIT/dotfiles
cd dotfiles
./install.sh
```

The vim plugins are not pulled automatically. They are submodules in `vim/pack/plugins/start/`.

## Useful utilities

- [Vim-Go](https://github.com/fatih/vim-go.git)
- [Awesome Alternatives in Rust](https://github.com/TaKO8Ki/awesome-alternatives-in-rust) (Originally Awesome Rewrite It
  In Rust)
    - [dog](https://github.com/ogham/dog)
    - [fd](https://github.com/sharkdp/fd)
    - [starship](https://github.com/starship/starship)
    - [xh](https://github.com/ducaale/xh)
- [Awesome Rust](https://github.com/awesome-rust-com/awesome-rust)
    - [ripgrep](https://github.com/BurntSushi/ripgrep)
- [Awesome Go](https://github.com/avelino/awesome-go)
    - [fzf](https://github.com/junegunn/fzf)

## Caveat

Things may be broken as I move from a private repo with another name.
