"$B4pK\E*$J@_Dj(B"
set number
set title 
set showmatch
set tabstop=2
set smartindent
set ignorecase
set smartcase
set autoindent
set expandtab
set shiftwidth=2
set wrapscan
set noswapfile
set nobackup
set noundofile
set mouse=a
set laststatus=2
imap [ []<LEFT>
imap ( ()<LEFT>
imap { {}<LEFT>
set backspace=start,eol,indent

"insert mode move comannd"
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <silent> <C-a> <Esc>^<Insert>
inoremap <silent> <C-s> <Esc>$<Insert><Right>
inoremap <silent> <C-d> <Esc>$<Insert><Right> ;<Left><BS><Right>

"auto indent command"
map <Space>i gg=<S-g><C-o><C-o>zz

"$BJ8;z%3!<%I4XO"$N@_Dj(B"
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac


"=============================================================="
"plugin"
"=============================================================="
if has('vim_starting')
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

"------------------------------------------------------------"
"$B$3$l0J2<$K%W%i%0%$%s$rF3F~(B"
"------------------------------------------------------------"

"ruby end $BJ]4I(B"
NeoBundle 'tpope/vim-endwise'

" $B%U%!%$%k%*!<%W%sMQ(B how ro = C-p=>$B%P%C%U%!0lMw(B C-n=> CD$B%U%!%$%k(B"
NeoBundle 'Shougo/unite.vim'

"$B%+%i!<%9%-!<%^@_Dj(B"
NeoBundle 'tomasr/molokai'

"$B%W%m%0%i%_%s%08@8l$N3HD%$G%7%s%?%C%/%9$H$+%5%`%7%s%0(B"
NeoBundle 'sheerun/vim-polyglot'

"$B%D%j!<>e$GI=<((B"
NeoBundle 'scrooloose/nerdtree'
nnoremap :tree :NERDTreeToggle
NeoBundle 'jistr/vim-nerdtree-tabs'
NeoBundle 'Xuyuanp/nerdtree-git-plugin'

"$BJQ99:9J,$rI=<((B"
NeoBundle 'airblade/vim-gitgutter'

"vim$B>e$G%=!<%9$r<B9T$9$k(B"
NeoBundle 'thinca/vim-quickrun'

"$BJd40$r$7$F$/$l$k$O$:(B"
NeoBundle 'Shougo/neocomplete'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'Shougo/vimproc', {
      \'build' : {
      \    'windows' : 'make -f make_mingw32.mak',
      \    'cygwin'  : 'make -f make_cygwin.mak',
      \    'mac'     : 'make -f make_mac.mak',
      \    'unix'    : 'make -f make_unix.mak',
      \}
      \}


"$B3g8L$rJd40(B"
NeoBundle 'tpope/vim-surround'

"$B%9%F!<%?%96/2=(B"
NeoBundle 'itchyny/lightline.vim'

"-----------------------------------------------------------"
"$B$3$l0J>e$K%W%i%0%$%s$r=q$/(B"
"-----------------------------------------------------------"
call neobundle#end()
filetype plugin indent on
NeoBundleCheck
"==========================================================="


"==========================================================="
"$B%W%i%0%$%s$r<u$1$F$N@_Dj(B
"==========================================================="

"$B%+%i!<%9%-!<%^$N@_Dj(B"
syntax on
set t_Co=256
colorscheme molokai

"$B%9%F!<%?%9@_Dj(B"
let g:lightline = {
      \ 'colorscheme': 'landscape',
      \}
if has('lua')
  NeoBundleLazy 'Shougo/neocomplete.vim', {
        \ 'depends' : 'Shougo/vimproc',
        \ 'autoload' : {'insert' : 1,} 
        \ }
endif

"neocomplete$B$N@_Dj$r0J2<$K<($9(B"
let g:neocomplete#enable_at_startup =1
let g:neocomplete#auto_completion_start_lenghth=3
let g:neocomplete#enable_ignore_case =1
let g:neocomplete#enable_smart_case =1
let g:neocomplete#enable_camel_case =1
let g:neocomplete#use_vimproc =1
let g:neocomplete#sources#buffer#cache_limit_size =1000000
let g:neocomplete#sources#tags#cache_limit_size =30000000
let g:neocomplete#enable_fuzy_completion =1
let g:neocomplete#lock_buffer_name_pattern ='\ku\'

"unite.vim$B$N@_Dj$r0J2<$K<($9(B"
let g:unite_enable_start_insert=1
nmap <silent> <C-u><C-b> :<C-u>Unite buffer<CR>
nmap <silent> <C-u><C-f> :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nmap <silent> <C-u><C-r> :<C-u>Unite -buffer-name=register register<CR>
nmap <silent> <C-u><C-m> :<C-u>Unite file_mru<CR>
nmap <silent> <C-u><C-u> :<C-u>Unite buffer file_mru<CR>
nmap <silent> <C-u><C-a> :<C-u>UniteWidthBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
au FileType unite nmap <silent> <buffer> <expr> <C-j> unite#do_action('splet')
au FileType unite imap <silent> <buffer> <expr> <C-j> unite#do_action('splet')
au FileType unite nmap <silent> <buffer> <expr> <C-l> unite#do_action('vsplet')
au FileType unite imap <silent> <buffer> <expr> <C-l> unite#do_action('vsplet')
au FileType unite nmap <silent> <buffer> <Esc><Esc> q
au FileType unite imap <silent> <buffer> <Esc><Esc> <Esc>q

"$B%D%j!<4X78$N%5%`%7%s%0(B"
if argc() == 0
  let g:nerdtree_tabs_open_on_console_startup = 1
end

"vim$B>e$G$N%3!<%I<B9T(B"
set splitbelow
set splitright
let g:quickrun_config = {'*': {'hook/time/enable': '1'}, }
