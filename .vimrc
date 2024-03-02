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

"カラースキーマの設定"
syntax on
set t_Co=256
"colorscheme molokai
hi Comment ctermfg=244
hi SpellCap ctermbg=10 ctermfg=9


"=============================================================="
"plugin"
"=============================================================="
"plugin manager"
set nocompatible
const s:dpp_base = '~/.cache/dpp/'
const s:dpp_src = '~/.cache/dpp/repos/github.com/Shougo/dpp.vim'
const s:denops_src = '~/.cache/dpp/repos/github.com/denops/denops.vim'
const s:ext_toml = '~/.cache/dpp/repos/github.com/Shougo/dpp-ext-toml'
const s:ext_lazy = '~/.cache/dpp/repos/github.com/Shougo/dpp-ext-lazy'
const s:ext_installer = '~/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer'
const s:ext_git = '~/.cache/dpp/repos/github.com/Shougo/dpp-protocol-git'

execute 'set runtimepath^=' .. s:dpp_src
execute 'set runtimepath^=' .. s:ext_toml
execute 'set runtimepath^=' .. s:ext_lazy
execute 'set runtimepath^=' .. s:ext_installer
execute 'set runtimepath^=' .. s:ext_git

if s:dpp_base->dpp#min#load_state()
  execute 'set runtimepath^=' .. s:denops_src
  autocmd User DenopsReady
  \ call dpp#make_state(s:dpp_base, '~/dotfiles/dpp.ts')
endif

filetype indent plugin on

if has('syntax')
  syntax on
endif
" Install plugins
autocmd User DenopsReady call dpp#async_ext_action('installer', 'install')

" Update plugins
autocmd User DenopsReady call dpp#async_ext_action('installer', 'update')

" Update dpp.vim
autocmd User DenopsReady call dpp#async_ext_action('installer', 'update',
\ #{ names: ['dpp.vim'] })

" Check not updated plugins
autocmd User DenopsReady call dpp#async_ext_action('installer', 'checkNotUpdated')

" Get not installed plugins
" echo dpp#ext_action('installer', 'getNotInstalled')
