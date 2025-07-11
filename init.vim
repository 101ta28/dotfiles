" =============================================================================
" Vim/Neovim Configuration
" =============================================================================

if &compatible
  set nocompatible
endif

" =============================================================================
" dpp.vim Configuration
" =============================================================================

" Disable denops version check if needed
let g:denops_disable_version_check = 1

" Base paths
const s:dpp_base = expand('~/.cache/dpp')
const s:config_home = expand('~/.dfiles/.config/nvim')

" Repository paths
const s:repos = {
\   'dpp': s:dpp_base . '/repos/github.com/Shougo/dpp.vim',
\   'denops': s:dpp_base . '/repos/github.com/vim-denops/denops.vim',
\   'installer': s:dpp_base . '/repos/github.com/Shougo/dpp-ext-installer'
\ }

" Function to check if all required repositories exist
function! s:check_dpp_repos() abort
  for [name, path] in items(s:repos)
    if !isdirectory(path)
      return 0
    endif
  endfor
  return 1
endfunction

" Function to show clone instructions
function! s:show_clone_instructions() abort
  echohl WarningMsg
  echom 'dpp.vim is not fully installed. Please run:'
  echom '  git clone https://github.com/Shougo/dpp.vim ' . s:repos.dpp
  echom '  git clone https://github.com/vim-denops/denops.vim ' . s:repos.denops
  echom '  git clone https://github.com/Shougo/dpp-ext-installer ' . s:repos.installer
  echohl None
endfunction

" Setup dpp.vim if all repositories exist
if s:check_dpp_repos()
  " Add to runtimepath
  execute 'set runtimepath^=' . s:repos.dpp
  
  " Load dpp state
  if dpp#min#load_state(s:dpp_base)
    " Add denops and installer to runtimepath
    execute 'set runtimepath^=' . s:repos.denops
    execute 'set runtimepath^=' . s:repos.installer
    
    " TypeScript config file path
    let s:dpp_config = s:config_home . '/dpp.ts'
    
    " Create state when denops is ready
    autocmd User DenopsReady
    \ : echohl WarningMsg
    \ | echom 'dpp load_state() is failed'
    \ | echom 'running dpp#make_state()'
    \ | echohl None
    \ | call dpp#make_state(s:dpp_base, s:dpp_config)
  endif
else
  call s:show_clone_instructions()
endif

" =============================================================================
" Plugin Notes
" =============================================================================
" Currently managed plugins (configured in dpp.ts):
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