" ---------------------------------------------
" dein.vim 設定
" ---------------------------------------------

if &compatible
  set nocompatible
endif

" dein のベースディレクトリとリポジトリパス
let s:dein_base = expand('~/.cache/dein')
let s:dein_repo = s:dein_base . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ自動クローン
if !isdirectory(s:dein_repo)
  execute '!git clone https://github.com/Shougo/dein.vim ' . s:dein_repo
endif

" runtimepath に追加
execute 'set runtimepath^=' . s:dein_repo

" dein.vim のプラグイン定義開始
call dein#begin(s:dein_base)

" dein 自身を管理対象に
call dein#add('Shougo/dein.vim')

" プラグイン一覧（必要に応じて追加）
call dein#add('itchyny/lightline.vim')
call dein#add('cohama/lexima.vim')

" プラグイン定義終了
call dein#end()
call dein#save_state()

" プラグイン未インストール時は自動インストール
if dein#check_install()
  call dein#install()
endif

" ---------------------------------------------
" 基本設定
" ---------------------------------------------

filetype plugin indent on
syntax on

set nowrap
set hlsearch
set incsearch
set ignorecase
set smartcase
set ruler
set number
set list
set listchars=tab:>.,space:_,
set wildmenu
set showcmd
set noshowmode
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smarttab
set laststatus=2
set cursorline
set clipboard+=unnamed

" undo settings（Neovim/Vim 両対応）
if has('persistent_undo')
  let undo_path = expand('~/.local/share/nvim/undo')
  call mkdir(undo_path, 'p')
  exe 'set undodir=' .. undo_path
  set undofile
endif

" Lightline settings
let g:lightline = {'colorscheme': 'wombat'}
colorscheme wombat
