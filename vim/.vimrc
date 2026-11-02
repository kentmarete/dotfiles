" ============================================================================
"  ~/.vimrc — Vim as a lightweight IDE (coc.nvim LSP, fzf, git, debugging)
"  Leader = <Space>. Press <Space> and wait to see all mappings (which-key).
" ============================================================================

" ---------------------------------------------------------------- general ---
set nocompatible
set encoding=utf-8
scriptencoding utf-8
set number relativenumber ruler cursorline showmatch
set hidden                       " switch buffers without saving
set mouse=a
set clipboard=unnamed            " macOS system clipboard (Homebrew vim has +clipboard)
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab autoindent smartindent
set ignorecase smartcase incsearch hlsearch
set splitbelow splitright
set scrolloff=8 sidescrolloff=8
set signcolumn=yes
set updatetime=300               " faster CursorHold (diagnostics, highlight)
set timeoutlen=500 ttimeoutlen=10
set shortmess+=c
set laststatus=2 noshowmode
set wildmenu wildmode=longest:full,full
set backspace=indent,eol,start
set nobackup nowritebackup noswapfile
set undofile undodir=~/.vim/undo//
set belloff=all
if !isdirectory(expand('~/.vim/undo')) | call mkdir(expand('~/.vim/undo'), 'p') | endif

" True colour, also inside tmux
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" Cursor shape: bar in insert, block in normal (works in Ghostty/iTerm2/tmux)
let &t_SI = "\e[6 q" | let &t_EI = "\e[2 q"

" MacVim loads Python at runtime. If its default library isn't found, point it
" at mise's (or Homebrew's) Python so vimspector works.
if has('python3_dynamic') && !has('python3')
  for s:lib in reverse(sort(glob('~/.local/share/mise/installs/python/*/lib/libpython3*.dylib', 0, 1)))
        \ + reverse(sort(glob('/opt/homebrew/Frameworks/Python.framework/Versions/3.*/Python', 0, 1)))
    let &pythonthreedll = s:lib
    if s:lib =~# 'mise' | let &pythonthreehome = fnamemodify(s:lib, ':h:h') | endif
    if has('python3') | break | endif
  endfor
endif

syntax on
filetype plugin indent on
silent! packadd! editorconfig     " honour .editorconfig (bundled with Vim 9)
silent! packadd! matchit

" -------------------------------------------------------------- vim-plug ---
let s:plug = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug))
  silent execute '!curl -fsLo ' . s:plug . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" IDE core
Plug 'neoclide/coc.nvim', {'branch': 'release'}   " LSP, completion, diagnostics, formatting
Plug 'puremourning/vimspector'                     " debugger (DAP)
Plug 'sheerun/vim-polyglot'                        " syntax for TS/TSX/SQL/Kotlin/…
" Navigation
Plug 'junegunn/fzf'                                " uses the Homebrew fzf binary
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'christoomey/vim-tmux-navigator'              " Ctrl-h/j/k/l across vim splits AND tmux panes
Plug 'liuchengxu/vim-which-key'
" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'RRethy/vim-illuminate'
Plug 'preservim/vim-indent-guides'
" UI
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'                      " must load last
call plug#end()

" LSP extensions — coc installs any missing ones automatically on startup.
let g:coc_global_extensions = [
  \ 'coc-json', 'coc-yaml', 'coc-toml', 'coc-sh', 'coc-snippets', 'coc-explorer',
  \ 'coc-tsserver', 'coc-eslint', 'coc-prettier', 'coc-html', 'coc-css', 'coc-angular',
  \ 'coc-java', 'coc-java-debug',
  \ 'coc-rust-analyzer',
  \ 'coc-pyright', '@yaegassy/coc-ruff',
  \ 'coc-sql', 'coc-docker',
  \ ]

" ----------------------------------------------------------------- theme ---
set background=dark
let g:gruvbox_contrast_dark = 'medium'
silent! colorscheme gruvbox       " silent: first launch runs before plugins exist
let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_exclude_filetypes = ['help', 'coc-explorer', 'fugitive']

" -------------------------------------------------------------- mappings ---
let mapleader = ' '
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <S-l> :bnext<CR>
nnoremap <S-h> :bprevious<CR>
nnoremap <leader>x :bdelete<CR>
" Keep selection when indenting; move lines
vnoremap < <gv
vnoremap > >gv
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Split navigation is handled by vim-tmux-navigator (Ctrl-h/j/k/l)

" Find (fzf.vim)
nnoremap <leader>e  :Files<CR>
nnoremap <leader>f  :Rg<CR>
nnoremap <leader>b  :Buffers<CR>
nnoremap <leader>/  :BLines<CR>
nnoremap <leader>:  :History:<CR>
nnoremap <leader>gf :GFiles?<CR>
" File explorer
nnoremap <leader>n  :CocCommand explorer<CR>
" Git
nnoremap <leader>gs :G<CR>
nnoremap <leader>gb :G blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gl :G log --oneline<CR>
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
" Easymotion: jump anywhere with <leader><leader>s{char}
nmap <leader><leader>s <Plug>(easymotion-overwin-f)
" Which-key
nnoremap <silent> <leader> :<C-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<C-u>WhichKeyVisual '<Space>'<CR>

" ------------------------------------------------- coc.nvim (IntelliSense) ---
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Tab / Shift-Tab cycle completion, Enter confirms, Ctrl-Space forces it
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <C-@> coc#refresh()
inoremap <silent><expr> <C-Space> coc#refresh()

" Navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Hover docs
function! ShowDocumentation() abort
  if CocAction('hasProvider', 'hover') | call CocActionAsync('doHover')
  else | call feedkeys('K', 'in') | endif
endfunction
nnoremap <silent> K :call ShowDocumentation()<CR>

" Refactoring & code actions (<Plug> mappings need nmap, not nnoremap)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction-cursor)
xmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader>qf <Plug>(coc-fix-current)
nmap <leader>rf <Plug>(coc-codeaction-refactor)
nmap <leader>cl <Plug>(coc-codelens-action)
" Format & imports
nmap <leader>F  <Plug>(coc-format)
xmap <leader>F  <Plug>(coc-format-selected)
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 OR     :call CocActionAsync('runCommand', 'editor.action.organizeImport')
nnoremap <leader>oi :OR<CR>
" Lists
nnoremap <silent> <leader>d  :<C-u>CocList diagnostics<CR>
nnoremap <silent> <leader>o  :<C-u>CocList outline<CR>
nnoremap <silent> <leader>s  :<C-u>CocList -I symbols<CR>
nnoremap <silent> <leader>cc :<C-u>CocList commands<CR>
" Snippets: Ctrl-j / Ctrl-k jump between placeholders
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

augroup coc_ide
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
  autocmd FileType typescript,json setlocal formatexpr=CocAction('formatSelected')
augroup END

" ---------------------------------------------------- debugging (vimspector) ---
" F5 continue · F3 stop · F4 restart · F9 breakpoint · F10 step over
" F11 step into · F12 step out. Install adapters once with :VimspectorInstall
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = ['debugpy', 'CodeLLDB', 'vscode-js-debug']
nmap <leader>di <Plug>VimspectorBalloonEval
xmap <leader>di <Plug>VimspectorBalloonEval
nnoremap <leader>dq :VimspectorReset<CR>
" Java: start a debug session through coc-java-debug (attach to jdt.ls)
nnoremap <leader>dj :CocCommand java.debug.vimspector.start<CR>

" ------------------------------------------------------------- filetypes ---
augroup ft_settings
  autocmd!
  autocmd FileType javascript,typescript,typescriptreact,javascriptreact,json,html,css,scss,yaml,vue,lua,sh,zsh,sql
        \ setlocal tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType java,rust,python,kotlin setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType gitcommit,markdown setlocal spell textwidth=72
  autocmd FileType make setlocal noexpandtab
augroup END

" Machine-local overrides
if filereadable(expand('~/.vimrc.local')) | source ~/.vimrc.local | endif
