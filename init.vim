" ---------------------------------------------
" dpp + denops 設定（Neovim 向け）
" ---------------------------------------------

" denops のバージョンチェックを無効化（Neovim 0.10 未満の対応）
let g:denops_disable_version_check = v:true

" runtimepath に dpp と denops を追加
let s:dpp = expand('~/.config/nvim/dpp/repos/github.com/Shougo/dpp.vim')
let s:denops = expand('~/.config/nvim/dpp/repos/github.com/vim-denops/denops.vim')
execute 'set runtimepath^=' . s:dpp
execute 'set runtimepath^=' . s:denops

" dpp.ts の設定を読み込む
try
  call dpp#make_state(expand('~/.config/nvim/dpp.ts'))
  call dpp#check_plugins()

  if dpp#has_not_installed_plugins()
    call dpp#install()
  endif
catch
  echohl ErrorMsg
  echom "dpp setup failed. Check ~/.config/nvim/dpp.ts"
  echohl None
endtry

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
