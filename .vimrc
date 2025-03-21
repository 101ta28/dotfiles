" ---------------------------------------------
" dpp + denops 設定
" ---------------------------------------------

" denops のバージョンチェックを無効化（Vim 9.1 未満の環境向け）
let g:denops_disable_version_check = v:true

" runtimepath に dpp と denops を追加
set runtimepath^=~/.vim/dpp/repos/github.com/Shougo/dpp.vim
set runtimepath^=~/.vim/dpp/repos/github.com/vim-denops/denops.vim

" TypeScript 設定ファイルのパス（expand でチルダ展開）
call dpp#make_state(expand('~/.vim/dpp.ts'))
call dpp#check_plugins()

" 起動時に未インストールならインストール
if dpp#has_not_installed_plugins()
  call dpp#install()
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

" undo settings
if has('persistent_undo')
  let undo_path = expand('~/.vim/undo')
  exe 'set undodir=' .. undo_path
  set undofile
endif

" Lightline settings
let g:lightline = {'colorscheme': 'wombat'}
