" ---------------------------------------------
" dpp + denops 設定（Neovim 向け、~/.cache/dpp 構成）
" ---------------------------------------------

" Denops のバージョンチェックを無効化（Neovim 0.10 未満の対応）
let g:denops_disable_version_check = v:true

" パス定義
const s:dpp_base = expand('~/.cache/dpp')
const s:dpp_src = s:dpp_base .. '/repos/github.com/Shougo/dpp.vim'
const s:denops_src = s:dpp_base .. '/repos/github.com/vim-denops/denops.vim'
const s:dpp_ts = expand('~/.config/nvim/dpp.ts')

" runtimepath に dpp.vim を先に追加
execute 'set runtimepath^=' .. fnameescape(s:dpp_src)

" 状態復元または初回初期化
if dpp#min#load_state(s:dpp_base)
  " denops.vim の runtimepath を追加
  execute 'set runtimepath^=' .. fnameescape(s:denops_src)

  " Denops の初期化完了後に make_state 実行
  autocmd User DenopsReady
    \ call dpp#make_state(s:dpp_base, s:dpp_ts)
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

" undo settings（Neovim 向け）
if has('persistent_undo')
  let undo_path = expand('~/.local/share/nvim/undo')
  call mkdir(undo_path, 'p')
  exe 'set undodir=' .. undo_path
  set undofile
endif

" Lightline settings
let g:lightline = {'colorscheme': 'wombat'}
colorscheme wombat
