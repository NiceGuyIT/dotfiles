" http://www.vim.org/scripts/script.php?script_id=1886
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif

" https://unix.stackexchange.com/questions/582787/how-can-i-get-vim-to-open-with-syntax-highlighting-for-systemd-unit-files
au BufRead,BufNewFile *.service,*.nspawn setfiletype systemd

" TypeScript is detected as xml
autocmd BufNewFile,BufRead *.ts setlocal filetype=javascript
"autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
