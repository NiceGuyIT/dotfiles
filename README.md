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
    - [dog](https://github.com/ogham/dog) - A command-line DNS client.
    - [fd](https://github.com/sharkdp/fd) = A simple, fast and user-friendly alternative to 'find'
    - [starship](https://github.com/starship/starship) - The minimal, blazing-fast, and infinitely customizable prompt
      for any shell!
    - [xh](https://github.com/ducaale/xh) - friendly and fast tool for sending HTTP requests
- [uutils coreutils](https://github.com/uutils/coreutils) - Cross-platform Rust rewrite of the GNU coreutils
- [dua-cli](https://github.com/Byron/dua-cli) - View disk space usage and delete unwanted data, fast.
- [Awesome Rust](https://github.com/awesome-rust-com/awesome-rust)
    - [ripgrep](https://github.com/BurntSushi/ripgrep) - combines the usability of The Silver Searcher with the raw speed
      of grep
    - [alacritty](https://github.com/alacritty/alacritty) - A cross-platform, GPU enhanced terminal emulator
- [Awesome Go](https://github.com/avelino/awesome-go)
    - [fzf](https://github.com/junegunn/fzf) - A command-line fuzzy finder
    - [gojq](https://github.com/elgs/gojq) - JSON query in Golang
    - [gdu](https://github.com/dundee/gdu) - Fast disk usage analyzer with console interface written in Go
- [cfssl](https://github.com/cloudflare/cfssl) - Cloudflare's PKI and TLS toolkit
- [dnslookup](https://github.com/ameshkov/dnslookup) - Simple command line utility to make DNS lookups. Supports all
  known DNS protocols: plain DNS, DoH, DoT, DoQ, DNSCrypt.

## Caveat

Things may be broken as I move from a private repo with another name.

## Useful commands

### .env

Export all variables in `.env` into the current environment.

```bash
export $(grep -vE "^(#.*|\s*)$" .env)
```

### Certs

Check domain for certificate expiration.

```bash
cfssl-certinfo -domain github.com
```

Display only the important information with colors!

```bash
cfssl-certinfo -domain github.com | gojq '{subject: .subject, sans: .sans, expired: .not_after}'
```

Check a PEM certificate for expiration. The server cert is the first cert in the PEM file with the intermediary and root
certs afterwards.

```bash
sed -e '/^-----END CERTIFICATE-----$/q' /etc/letsencrypt/live/example.com/fullchain.pem | \
    cfssl-certinfo -cert - | \
    gojq '{subject: .subject, sans: .sans, expired: .not_after}'
```

### Searching through files

Recursively search for `findme` in the current directory.
```bash
rg findme
```

Search all files, including hidden and \[git]ignored files.
```bash
rg --no-ignore --hidden findme
```

Don't search `node_modules`.
```bash
rg --glob \!node_modules findme
```

Search all files, including hidden and \[git]ignored files _except_ `node_modules` and `.git`.
```bash
rg --no-ignore --hidden --glob \!node_modules --glob \!.git findme
```
