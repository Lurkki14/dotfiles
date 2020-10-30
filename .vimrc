call plug#begin('~/.vim/plugged')

"Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'igankevich/mesonic'
Plug 'jackguo380/vim-lsp-cxx-highlight'

call plug#end()

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

"2 space soft tabs for Haskell
autocmd Filetype haskell setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

set noexpandtab
set copyindent
set preserveindent
set softtabstop=0
set shiftwidth=4
set tabstop=4
