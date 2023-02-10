#!/usr/bin/env bash

GIT="git submodule add --depth 1 --branch"

# Vim syntax for TOML
repo="vim-toml"
repoUrl="https://github.com/cespare/vim-toml"
branch="main"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# Surround.vim is all about "surroundings": parentheses, brackets, quotes,
# XML tags, and more.  The plugin provides mappings to easily delete,
# change and add such surroundings in pairs.
repo="vim-surround"
repoUrl="https://github.com/tpope/vim-surround"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# Think of sensible.vim as one step above `'nocompatible'` mode: a universal
# set of defaults that (hopefully) everyone can agree on.
repo="vim-sensible"
repoUrl="https://github.com/tpope/vim-sensible"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# Better JSON for VIM
repo="vim-json"
repoUrl="https://github.com/elzr/vim-json"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# vim-go: This plugin adds Go language support for Vim
repo="vim-go"
repoUrl="https://github.com/fatih/vim-go"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# Syntastic is a syntax checking plugin for Vim
repo="syntastic"
repoUrl="https://github.com/vim-syntastic/syntastic"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# nginx.vim: The plugin is based on the recent vim-plugin distributed with 'nginx-1.12.0' and
# additionally features the following syntax improvements
repo="nginx.vim"
repoUrl="https://github.com/chr4/nginx.vim"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# The NERDTree is a file system explorer for the Vim editor.
repo="nerdtree"
repoUrl="https://github.com/preservim/nerdtree"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# fzf in itself is not a Vim plugin, and the official repository only
# provides the basic wrapper function for Vim and it's up to the users to
# write their own Vim commands with it. However, I've learned that many users of
# fzf are not familiar with Vimscript and are looking for the "default"
# implementation of the features they can find in the alternative Vim plugins.
#
# This repository is a bundle of fzf-based commands and mappings extracted from
# my .vimrc to address such needs.
repo="fzf.vim"
repoUrl="https://github.com/junegunn/fzf.vim"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# This repository only enables basic integration with Vim. If you're looking for
# more, check out fzf.vim project.
#repo="fzf"
#repoUrl="https://github.com/junegunn/fzf"
#echo "===== $repo ====="
#[[ -d "${repo}/" ]] && rm -r "${repo}"
#$GIT "${branch}" "${repoUrl}" "${repo}"
#[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# The NERDTree is a file system explorer for the Vim editor.
repo="unicode"
repoUrl="https://github.com/chrisbra/unicode.vim"
branch="master"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"


# Syntax highlighting for HashiCorp Configuration Language (HCL) used by Consul, Nomad, Packer, Terraform, and Vault.
repo="vim-hcl"
repoUrl="https://github.com/jvirtanen/vim-hcl"
branch="main"
echo "===== $repo ====="
[[ -d "${repo}/" ]] && rm -r "${repo}"
$GIT "${branch}" "${repoUrl}" "${repo}"
[[ -d "${repo}/.github/" ]] && rm -rf "${repo}/.github"
