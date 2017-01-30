"基本的な設定"
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

"文字コード関連の設定"
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
"これ以下にプラグインを導入"
"------------------------------------------------------------"

"ruby end 保管"
NeoBundle 'tpope/vim-endwise'

" ファイルオープン用 how ro = C-p=>バッファ一覧 C-n=> CDファイル"
NeoBundle 'Shougo/unite.vim'

"カラースキーマ設定"
NeoBundle 'tomasr/molokai'

"プログラミング言語の拡張でシンタックスとかサムシング"
NeoBundle 'sheerun/vim-polyglot'

"ツリー上で表示"
NeoBundle 'scrooloose/nerdtree'
nnoremap :tree :NERDTreeToggle
NeoBundle 'jistr/vim-nerdtree-tabs'
NeoBundle 'Xuyuanp/nerdtree-git-plugin'

"変更差分を表示"
NeoBundle 'airblade/vim-gitgutter'

"vim上でソースを実行する"
NeoBundle 'thinca/vim-quickrun'

"補完をしてくれるはず"
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
NeoBundle 'vim-scripts/javacomplete'


"括弧を補完"
NeoBundle 'tpope/vim-surround'

"ステータス強化"
NeoBundle 'itchyny/lightline.vim'

"-----------------------------------------------------------"
"これ以上にプラグインを書く"
"-----------------------------------------------------------"
call neobundle#end()
filetype plugin indent on
NeoBundleCheck
"==========================================================="


"==========================================================="
"プラグインを受けての設定
"==========================================================="

"カラースキーマの設定"
syntax on
set t_Co=256
colorscheme molokai

"ステータス設定"
let g:lightline = {
      \ 'colorscheme': 'landscape',
      \}
"complete"
if has('lua')
  NeoBundleLazy 'Shougo/neocomplete.vim', {
        \ 'depends' : 'Shougo/vimproc',
        \ 'autoload' : {'insert' : 1,} 
        \ }
endif

"java"
autocmd FileType java :setlocal omnifunc=javacomplete#Complete
autocmd FileType java :setlocal completefunc=javacomplete#CompleteParamsInfo

"neocompleteの設定を以下に示す"
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

"unite.vimの設定を以下に示す"
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

"ツリー関係のサムシング"
if argc() == 0
  let g:nerdtree_tabs_open_on_console_startup = 1
end

"vim上でのコード実行"
set splitbelow
set splitright
let g:quickrun_config = {'*': {'hook/time/enable': '1'}, }
