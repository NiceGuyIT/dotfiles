""
"" A future enhancement is to make use of ./vim/*.local
"" gvim settings are in gvimrc symlinked to ~/.gvimrc
""

""
"" The following plugins should be installed to provide a better experience
""   zypper install vim vim-data vim-data-common vim-plugin-gitdiff
"" These are extra packages
""   zypper install vim-plugin-colorschemes vim-fzf
"" This wasn't on 15.3
""   zypper install vim-plugin-nginx
""

" Do not expand tabs to spaces
set noexpandtab

" Size of hard tabstop
set tabstop=4

" Size of an "indent"
set shiftwidth=4

" Use tabs and spaces to make it "feel" like tab stops are 4
" A combination of spaces and tabs are used to simulate tab stops at a
" width other than the (hard)tabstop
set softtabstop=4

" Turn on folding by default
" This creates an error in vim. gvim is unknown
"set foldmethod=marker
set foldmethod=syntax

" Formatoptions
set formatoptions+=l

" Turn the modeline on
" Default: on
set modeline
set modelines=5

" Case insensitive matching
set ignorecase

" Smart case matching
set smartcase

" Incremental search
set incsearch

" Highlight search
set hlsearch

" Disable showing the matching brackets
set noshowmatch

" Textwidth for wraping
set textwidth=100

" Fix backspace
" https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
set backspace=indent,eol,start

" Show UTF-8 characters (a.k.a. multi-byte characters)
set encoding=utf-8  " The encoding displayed.
set fileencoding=utf-8  " The encoding written to file.

" https://stackoverflow.com/questions/4325682/vim-colorschemes-not-changing-background-color
" Make sure you’re using a console terminal capable of 256 colors; not all of them do (particularly
" on mac). You might need to explicitly force Vim to use that by doing “set t_Co=256″ on your .vimrc
" file.
set t_Co=256

" Tell vim we are using a dark background
" FIXME: background=dark does not set the colors correctly
" For some reason, setting background=dark does not appear the same on different computers.
" But setting background=light and then background=dark makes them all the same.
" Not sure why.
set background=light
set background=dark

" Colorscheme
" pablo is best when using vimdiff but doesn't show syntax highlighting color for .conf files
" industry is good for vimdiff
" See https://d.niceguyit.biz/en/internal/apps/vim
colorscheme industry
"colorscheme default
"colorscheme astronaut
"colorscheme bluegreen
"colorscheme desert
"colorscheme desert256
"colorscheme desertEx
" industry is ok
"colorscheme industry
" koehler is good all alround
" elflord or koehler are good for .conf files
"colorscheme koehler
"colorscheme manxome
"colorscheme matrix
"colorscheme metacosm
"colorscheme moria
"colorscheme neon
"colorscheme night
"colorscheme oceanblack
"colorscheme olive
"colorscheme slate
" This causes the trailing end of line to not be copied, resulting in middle-click pasting the line
" only, not pasting and enter.
"colorscheme torte
" These all look simillar
"colorscheme breeze
"colorscheme brookstream
"colorscheme camo
"colorscheme candy
"colorscheme colorscheme_template
"colorscheme darkblue2
"colorscheme darkocean
"colorscheme dusk
"colorscheme dw_blue
"colorscheme elflord
"colorscheme fnaqevan
"colorscheme freya
"colorscheme hhazure
"colorscheme lilac
"colorscheme psql
"colorscheme rdark
"colorscheme robinhood
"colorscheme softblue

highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE

" Save backup files to /tmp to prevent auto-reload for watched directories.
" Default: .,~/tmp,/var/tmp,/tmp
set directory=~/tmp,/var/tmp,/tmp

" Ignore whitespace in vimdiff but not regular vim
if &diff
	set diffopt+=iwhite
endif

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
vnoremap <S-Del> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

" CTRL-V and SHIFT-Insert are Paste
map <C-V>		"+gP
map <S-Insert>		"+gP

" Turn on plugins for filetypes
filetype plugin on

" Turn on filetype indention
filetype plugin indent on

" Turn on syntax highlighting
syntax on

" Equalize split windows automatically
autocmd VimResized * wincmd =

" Git commit messages
" https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message
autocmd Filetype gitcommit setlocal spell textwidth=72

" Indent HTML files 2 instead of 4
autocmd Filetype html setlocal shiftwidth=2 softtabstop=2 tabstop=2
"autocmd Filetype yml setlocal shiftwidth=2 softtabstop=2 tabstop=2

" https://github.com/mat813/dotvim/blob/master/vimrc
if has("autocmd") && exists("+omnifunc")
  augroup MyOmnifunc
    au!
    autocmd Filetype *
        \  if &omnifunc == "" |
        \    setlocal omnifunc=syntaxcomplete#Complete |
        \  endif
  augroup END
endif

" Highlight trailing spaces at the end of the line in red
highlight RedundantSpaces ctermbg=red guibg=red
"match RedundantSpaces /\s\+$\| \+\ze\t/
match RedundantSpaces /\s\+$/

" Add my own copy/paste/select all (Ctrl-Shift-C / Ctrl-Shift-V / Ctrl-Shift-A)
"noremap <C-kPlus> <C-A>
"map <C-C> "+y
"map <C-V> "+gP
"map <C-A> gggH<C-O>G

