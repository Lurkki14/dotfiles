function! s:check_back_space() abort
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<Tab>" :
\ coc#refresh()
autocmd Filetype haskell setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype qml setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %{&filetype}\ %P
set mouse=a
colorscheme gruvbox
" Make cuts go to black hole since cutting is rarer than deletion
nnoremap d "_d
vnoremap d "_d
