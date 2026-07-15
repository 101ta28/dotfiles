" =============================================================================
" Vim/Neovim Configuration
" =============================================================================

if &compatible
  set nocompatible
endif

" =============================================================================
" dpp.vim Configuration
" =============================================================================

const s:dpp_base = expand('~/.cache/dpp')
const s:dpp_repos = s:dpp_base . '/repos/github.com'
const s:dpp_src = s:dpp_repos . '/Shougo/dpp.vim'
const s:denops_src = s:dpp_repos . '/vim-denops/denops.vim'
const s:dpp_installer_src = s:dpp_repos . '/Shougo/dpp-ext-installer'
const s:dpp_git_src = s:dpp_repos . '/Shougo/dpp-protocol-git'
const s:config_home = expand('~/.config/nvim')
const s:dpp_config = s:config_home . '/dpp.ts'

function! s:make_dpp_state() abort
  echohl WarningMsg
  echom 'dppのstateを生成します。初回は完了までお待ちください。'
  echohl None
  call dpp#make_state(s:dpp_base, s:dpp_config)
endfunction

function! s:on_dpp_state_ready() abort
  echom 'dppのstate生成が完了しました。プラグインをインストールします。'
  call dpp#async_ext_action('installer', 'install')
endfunction

if isdirectory(s:dpp_src) && filereadable(s:dpp_config)
  execute 'set runtimepath^=' . fnameescape(s:dpp_src)

  if dpp#min#load_state(s:dpp_base)
    for s:bootstrap_src in [s:denops_src, s:dpp_installer_src, s:dpp_git_src]
      if isdirectory(s:bootstrap_src)
        execute 'set runtimepath^=' . fnameescape(s:bootstrap_src)
      endif
    endfor

    augroup dpp_bootstrap
      autocmd!
      autocmd User DenopsReady call <SID>make_dpp_state()
      autocmd User Dpp:makeStatePost call <SID>on_dpp_state_ready()
    augroup END
  endif

  command! DppInstall call dpp#async_ext_action('installer', 'install')
  command! DppUpdate call dpp#async_ext_action('installer', 'update')
else
  echohl WarningMsg
  echom 'dpp.vimまたはdpp.tsが見つかりません。installer.shを実行してください。'
  echohl None
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
