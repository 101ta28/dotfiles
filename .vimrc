"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/home/tatsuya/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
call dein#begin('/home/tatsuya/.cache/dein')

" Let dein manage dein
" Required:
call dein#add('/home/tatsuya/.cache/dein/repos/github.com/Shougo/dein.vim')

" Add or remove your plugins here like this:
"call dein#add('Shougo/neosnippet.vim')
"call dein#add('Shougo/neosnippet-snippets')
"call dein#add("42Paris/42header")
call dein#add("itchyny/lightline.vim")
call dein#add("cohama/lexima.vim")

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------


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

"undo settings"
if has('persistent_undo')
	let undo_path = expand('~/.vim/undo')
	exe 'set undodir=' .. undo_path
	set undofile
endif

"42Header"
"let g:user42 = 'timai'
"let g:mail42 = 'timai@student.42tokyo.jp'

"Lightline settings"
let g:lightline = {'colorscheme': 'wombat'}
