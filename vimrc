" plugins
""""""""""""""""
if empty(glob('~/.vim/autoload/plug.vim'))  " auto install
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'psf/black'
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tomtom/tcomment_vim'
Plug 'dhruvasagar/vim-table-mode'
call plug#end()

" behavior
""""""""""""""""
set clipboard=unnamedplus              " use system clipboard
set wildmenu                           " enhanced cli completion
set wildmode=longest:full,full         " complete longest on tab, full on 2nd

" appearance
""""""""""""""""
set number                             " show line numbers

set display=lastline                   " show truncated line instead of @
set display+=uhex                      " show unprintable ascii as hex

" history
""""""""""""""""
set viminfo='25,\"100,:20,%,n~/.vim/.viminfo
" remember last position in file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
set undofile
set undodir=~/.vim/undodir

" file types
""""""""""""""""
" markdown
let g:markdown_fenced_languages = ['python', 'bash=sh']
au FileType markdown setlocal textwidth=80
