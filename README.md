# dotfiles (a.k.a. profile)

This is the dotfiles I use as my profile on the desktop, server (both openSUSE Leap), and laptop (macOS).

Need more inspiration? Check out [Awesome dotfiles](), [dotfiles]() and the [dotfiles topic]() on GitHub.

[Awesome dotfiles]: https://github.com/webpro/awesome-dotfiles

[dotfiles]: https://dotfiles.github.io/

[dotfiles topic]: https://github.com/topics/dotfiles

## Install

[chezmoi]() manages this repository. Installation of single binary files, a.k.a. packages, is done by [get-packages]()
in the [justfile]() repository. Follow the installation instructions in the justfile repo.



[chezmoi]: https://github.com/twpayne/chezmoi

[get-packages]: https://github.com/NiceGuyIT/justfiles/tree/main/packages

[justfile]: https://github.com/NiceGuyIT/justfiles/

## Alacritty

This PR adds "bracketed paste (BD, BE, PE, PS)". The `PS` capability breaks pasting pasting
multi-line text into vim that is indented.

https://github.com/alacritty/alacritty/commit/d40198da53f4c1c882901e364aca59e9b2ef2367

```bash
sudo zypper install ncurses5-devel
http get https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -e alacritty,alacritty-direct -o ~/.terminfo -
```

## TODO

The vim plugins are not pulled automatically. They are submodules in `vim/pack/plugins/start/`. Need to add these
to chezmoi.

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

Export all variables in `.env` into the current environment. Unfortunately, this has problems
when the values have spaces.

```bash
export $(grep -vE "^(#.*|\s*)$" .env)
```

Instead, use 'set -a' or 'set -o allexport': <https://stackoverflow.com/a/30969768>.
See [man set][] for details. See also [load_dotenv.sh][] gist.

```bash
set -a
source .env
set +a

# Alternatively, use the 'allexport' option
set -o allexport
source .env
set +o allexport
```

[man set]: https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

[load_dotenv.sh]: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572

### Certs

Check a PEM certificate for expiration. The server cert is the first cert in the PEM file with the intermediary and root
certs afterwards.

```bash
sed -e '/^-----END CERTIFICATE-----$/q' /etc/letsencrypt/live/example.com/fullchain.pem | \
    cfssl-certinfo -cert - | \
    gojq '{subject: .subject, sans: .sans, expired: .not_after}'
```
