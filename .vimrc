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
set incsearch
set hlsearch

"normal mode move baffer"
nnoremap <silent> <C-h> :bprev<CR>
nnoremap <silent> <C-l> :bnext<CR>
nnoremap <silent> <C-k> :bfirst<CR>
nnoremap <silent> <C-j> :blast<CR>

"insert mode move comannd"
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <silent> <C-a> <Esc>^<Insert>
inoremap <silent> <C-s> <Esc>$<Insert><Right>
inoremap <silent> <C-d> <Esc>$<Insert><Right> ;<Left><BS><Right>
nnoremap <ESC><ESC> :nohl<CR>

"auto indent command"
map <Space>i gg=<S-g><C-o><C-o>zz

"文字コード関連の設定"
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
set fileformats=unix,dos,mac

"fzf setting"
set rtp+=/usr/local/opt/fzf


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
NeoBundle 'lambdalisue/unite-grep-vcs'

NeoBundleLazy 'lambdalisue/unite-grep-vcs', {
    \ 'autoload': {
    \    'unite_sources': ['grep/git', 'grep/hg'],
    \}}

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

"quickfixに対して置換を行う"
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'thinca/vim-qfhl'

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

"UMLを書くためのプラグイン"
NeoBundle "aklt/plantuml-syntax"

"code check"
NeoBundle 'w0rp/ale'

"rspec"
NeoBundle 'thoughtbot/vim-rspec'
NeoBundleLazy 'thoughtbot/vim-rspec', {
                \ 'depends'  : 'tpope/vim-dispatch',
                \ 'autoload' : { 'filetypes' : ['ruby'] }
              \ }
NeoBundle 'itmammoth/run-rspec.vim'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'rking/ag.vim'
NeoBundle 'markonm/traces.vim'
NeoBundle 'nathanaelkane/vim-indent-guides'

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
hi Comment ctermfg=244
hi SpellCap ctermbg=10 ctermfg=9

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
"Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()
" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1
" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"unite.vimの設定を以下に示す"
"unite prefix key.
nnoremap [unite] <Nop>
nmap <C-j> [unite]
"unite general settings
"インサートモードで開始
let g:unite_enable_start_insert = 1
"最近開いたファイル履歴の保存数
let g:unite_source_file_mru_limit = 50
"file_mruの表示フォーマットを指定。空にすると表示スピードが高速化される
let g:unite_source_file_mru_filename_format = ''

"現在開いているファイルのディレクトリ下のファイル一覧。
"gitmodeで開く"
nnoremap <silent> [unite]j :<C-u>Unite file_rec/git<CR>
"バッファ一覧
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
"レジスタ一覧
nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
"最近使用したファイル一覧
nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
"ブックマーク一覧
nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
"ブックマークに追加
nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>
"find"
nnoremap <silent> [unite]f :<C-u>Unite find<CR>
"select word grep"
nnoremap <silent> [unite]g :<C-u>Unite grep/git:. -buffer-name=search-buffer<CR><C-R><C-W>
"grep"
nnoremap <silent> [unite]s :<C-u>Unite grep/git:. -buffer-name=search-buffer<CR>
"uniteを開いている間のキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()"{{{
	"ESCでuniteを終了
	nmap <buffer> <ESC> <Plug>(unite_exit)
	"入力モードのときjjでノーマルモードに移動
	imap <buffer> jj <Plug>(unite_insert_leave)
	"入力モードのときctrl+wでバックスラッシュも削除
	imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
	"ctrl+hで縦に分割して開く
	nnoremap <silent> <buffer> <expr> <C-h> unite#do_action('left')
	inoremap <silent> <buffer> <expr> <C-h> unite#do_action('left')
	"ctrl+jで横に分割して開く
	nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('below')
	inoremap <silent> <buffer> <expr> <C-j> unite#do_action('below')
    "ctrl+kで縦に分割して開く
	nnoremap <silent> <buffer> <expr> <C-k> unite#do_action('above')
	inoremap <silent> <buffer> <expr> <C-k> unite#do_action('above')
	"ctrl+lで横に分割して開く
	nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('right')
	inoremap <silent> <buffer> <expr> <C-l> unite#do_action('right')
	"ctrl+rでqfreplace
    nnoremap <silent> <buffer> <expr> <C-r> unite#do_action('replace')
    inoremap <silent> <buffer> <expr> <C-r> unite#do_action('replace')
	"ctrl+tでタブに開く
	nnoremap <silent> <buffer> <expr> <C-t> unite#do_action('tabopen')
	inoremap <silent> <buffer> <expr> <C-t> unite#do_action('tabopen')
    "ctrl-g"
    nnoremap <silent> <buffer> <expr> <C-g> unite#do_action('grep')
	inoremap <silent> <buffer> <expr> <C-g> unite#do_action('grep')
endfunction"}}}

"ツリー関係のサムシング"
if argc() == 0
  let g:nerdtree_tabs_open_on_console_startup = 1
end

"vim上でのコード実行"
set splitbelow
set splitright

" LaTeX Quickrun
let g:quickrun_config = {
\   "*" : {
\     'hook/time/enable': '1'
\   },
\ }

let g:quickrun_config._ = {'runner' : 'vimproc'}
let g:quickrun_config['rspec/bundle'] = {
  \ 'type': 'rspec/bundle',
  \ 'command': 'rspec',
  \ 'exec': 'bundle exec %c %s'
  \}
let g:quickrun_config['rspec/normal'] = {
  \ 'type': 'rspec/normal',
  \ 'command': 'rspec',
  \ 'exec': '%c %s'
  \}
function! RSpecQuickrun()
  let b:quickrun_config = {'type' : 'rspec/bundle'}
endfunction
autocmd BufReadPost *_spec.rb call RSpecQuickrun()

"plantuml"
let g:plantuml_executable_script = "~/dotfiles/plantuml"

"ale"
let g:ale_sign_column_always = 1
let g:ale_sign_error = '-E'
let g:ale_sign_warning = '-W'
"nmap <silent> <C-k> <Plug>(ale_previous_wrap)"
"nmap <silent> <C-j> <Plug>(ale_next_wrap)"
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_open_list = 1

let g:run_rspec_bin = 'bundle exec rspec'
nnoremap <Space>r :RunSpec<CR>
nnoremap <Space>s :RunSpecLine<CR>
nnoremap <Space>l :RunSpecLastRun<CR>
nnoremap <Space>c :RunSpecCloseResult<CR>
let g:ackprg = 'ag --vimgrep'
cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>

if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_start_level=2
let g:indent_guides_auto_colors=0
" 奇数番目のインデントの色
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#444433 ctermbg=black
" 偶数番目のインデントの色
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#333344 ctermbg=darkgray
let g:indent_guides_guide_size = 1

let g:qfhl_startup = 'enable'
let g:qfhl#multi_loclist = 'flush'
nnoremap [q :cprevious<CR>   " 前へ
nnoremap ]q :cnext<CR>       " 次へ
nnoremap [Q :<C-u>cfirst<CR> " 最初へ
nnoremap ]Q :<C-u>clast<CR>  " 最後へ
autocmd QuickFixCmdPost *grep* cwindow
