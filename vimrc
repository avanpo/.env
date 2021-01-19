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
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'bazelbuild/vim-bazel'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

" plugin behavior
""""""""""""""""
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

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

" google/vim-codefmt
augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json,template,vue AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

" markdown
let g:markdown_fenced_languages = ['python', 'bash=sh']
au FileType markdown setlocal textwidth=80

" yaml
au FileType yaml,yml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
