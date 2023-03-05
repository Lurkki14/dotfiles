inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Automatic symbol info on hover
" Has a small problem of calling doHover even if there is a diagnostic for symbol under cursor
function DoCocHover()
	if g:coc_service_initialized && CocHasProvider('hover')
		call CocActionAsync('doHover')
	endif
endfunction
autocmd CursorHold * call DoCocHover()
set updatetime=100

autocmd Filetype haskell setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd Filetype qml setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd Filetype json setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %{&filetype}\ %P
set mouse=a
colorscheme gruvbox-material
" Make cuts go to black hole since cutting is rarer than deletion
nnoremap d "_d
vnoremap d "_d
