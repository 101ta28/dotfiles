" =============================================================================
" Vim/Neovim Configuration
" =============================================================================

if &compatible
  set nocompatible
endif

" =============================================================================
" dein.vim Configuration
" =============================================================================

let g:dein#auto_recache = 1

const s:dein_base = expand('~/.cache/dein')
const s:dein_repo = s:dein_base . '/repos/github.com/Shougo/dein.vim'
const s:config_home = expand('~/.config/nvim')
const s:dein_toml = s:config_home . '/dein.toml'
const s:dein_lazy_toml = s:config_home . '/dein_lazy.toml'

if !isdirectory(s:dein_repo)
  if executable('git')
    echo 'Installing dein.vim...'
    call system(['git', 'clone', 'https://github.com/Shougo/dein.vim', s:dein_repo])
  else
    echohl ErrorMsg
    echom 'git が見つかりません。dein.vim を手動でインストールしてください。'
    echohl None
  endif
endif

if filereadable(s:dein_toml)
  execute 'set runtimepath^=' . fnameescape(s:dein_repo)

  if dein#load_state(s:dein_base)
    call dein#begin(s:dein_base)
    call dein#load_toml(s:dein_toml, {'lazy': 0})
    if filereadable(s:dein_lazy_toml)
      call dein#load_toml(s:dein_lazy_toml, {'lazy': 1})
    endif
    call dein#end()
    call dein#save_state()
  endif

  if dein#check_install()
    call dein#install()
  endif
else
  echohl WarningMsg
  echom 'dein.toml が見つかりません。プラグイン設定を確認してください。'
  echohl None
endif

" =============================================================================
" Plugin Notes
" =============================================================================
" Currently managed plugins (configured in dein.toml):
" - itchyny/lightline.vim - statusline
" - cohama/lexima.vim - auto close brackets

" =============================================================================
" Basic Settings
" =============================================================================

filetype plugin indent on
syntax enable

" =============================================================================
" Display Settings
" =============================================================================
set nowrap                     " Don't wrap lines
set ruler                      " Show cursor position
set number                     " Show line numbers
set cursorline                 " Highlight current line
set laststatus=2               " Always show status line
set noshowmode                 " Don't show mode (lightline handles this)
set showcmd                    " Show command in status line
set wildmenu                   " Enhanced command completion

" Show whitespace characters
set list
set listchars=tab:>.,space:_,

" =============================================================================
" Search Settings
" =============================================================================
set hlsearch                   " Highlight search results
set incsearch                  " Incremental search
set ignorecase                 " Case insensitive search
set smartcase                  " Case sensitive if uppercase used

" =============================================================================
" Indentation Settings
" =============================================================================
set shiftwidth=4               " Indent width
set softtabstop=4              " Soft tab width
set tabstop=4                  " Tab width
set smarttab                   " Smart tab handling
set expandtab                  " Use spaces instead of tabs
set autoindent                 " Auto indent new lines
set smartindent                " Smart indenting

" =============================================================================
" System Integration
" =============================================================================
set clipboard+=unnamed         " Use system clipboard

" =============================================================================
" Persistent Undo
" =============================================================================
if has('persistent_undo')
  let s:undo_dir = expand('~/.local/share/nvim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  execute 'set undodir=' . s:undo_dir
  set undofile
endif

" =============================================================================
" Plugin Settings
" =============================================================================

" Lightline colorscheme
let g:lightline = {'colorscheme': 'wombat'}
