" plugins
""""""""""""""""
if empty(glob('~/.vim/autoload/plug.vim'))  " auto install
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" sensible defaults
Plug 'tpope/vim-sensible'
" finder
Plug 'ctrlpvim/ctrlp.vim'
" commenting
Plug 'tomtom/tcomment_vim'
" easy tables (:TableModeToggle)
Plug 'dhruvasagar/vim-table-mode'

" theme
Plug 'dylanraps/wal.vim'

" code formatting
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'
" code autocomplete
Plug 'ycm-core/YouCompleteMe', { 'do': 'python install.py --all' }
" golang
Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoUpdateBinaries' }

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
  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json,template AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

" golang
let g:go_fmt_command = "goimports"

" markdown
let g:markdown_fenced_languages = ['python', 'bash=sh']
au FileType markdown setlocal textwidth=80

" yaml
au FileType yaml,yml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" load machine specific config
""""""""""""""""
try
  source '~/.config/vimrc'
catch
  " no problem
endtry
