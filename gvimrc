" Settings for the GUI vim
set guifont="FiraCode Nerd Font Mono Retina 10"

" Set the default colorscheme for graphical vim
colorscheme torte
"colorscheme koehler

" torte GUI
"highlight Search     guifg=Black       guibg=Yellow    gui=bold
highlight Search     guibg=Yellow       gui=bold

" torte Console
"highlight Search     ctermfg=Black     ctermbg=Red     cterm=NONE
highlight Search     ctermbg=Yellow     cterm=NONE

" Set the window size
set lines=40
set columns=120

" Disable the bell
set vb t_vb=

" Include local configurations
call SourceIfExists('~/.gvimrc-local')

