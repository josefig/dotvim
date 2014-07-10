" Behave in a more useful way
set nocompatible

" Needed for some Linux distros (like Ubuntu)
filetype off

" Package bundling using pathogen
call pathogen#helptags()

" Specify a color scheme
set background=dark
colorscheme molokai

" Turn on highlighting
syntax on

" Deal with tabs and indentation nicely
filetype plugin indent on
"set tabstop=2       " spaces a tab takes up
"set smarttab        " smart tabbing for autoindent
"set shiftwidth=2    " spaces to use when using spaces for tabs
"set expandtab       " expand tabs into spaces
"set autoindent      " autoindenting on

" Search
set hlsearch        " highlight matches
set incsearch       " search while typing
set ignorecase      " case insensitive search
set smartcase       " case insensitive when lower case, else case sensitive

" Line numbers
if version >= 703
  set rnu
else
  set nu
endif

" Formatting
set textwidth=78    " wrap using text width
set wrapmargin=0    " don't wrap using distance from right margin

" Invisible characters
set list
set listchars=tab:→\ ,trail:·

" Ignore files
set wildignore+=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.gif,*.xpm

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Miscellaneous
set ruler           " add a ruler to the bottom
set showcmd         " show (partial) command in status line
set showmatch       " show matching brackets
set autoread        " automatically read file changes outside of vim
set wildmenu        " show menu when auto completing
set nostartofline   " don't jump to first character when paging
set cursorline      " highlight the current line
set laststatus=2    " always show the statusline

" Disable backup files
set nobackup
set noswapfile

if has("autocmd")
  " au is short for autocmd

  " Restore cursor position
  autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

  " Set warning of over column 80
  if exists('+colorcolumn')
    set colorcolumn=81
  else
    autocmd BufWinEnter * let w:m1=matchadd('Error', '\%>80v.\+', -1)
  endif

  " If files have changed outside of Vim, update NERDTree and CommandT when
  " Vim gains focus.
  " NOTE: FocusGained only works for GUI versions of Vim, like gvim. Should
  " probably move this to gvimrc.
  " NOTE: CommandT is no longer used. Leaving for historical purposes.
  autocmd FocusGained * call s:UpdateNERDTree()
  "autocmd FocusGained * call s:UpdateCommandT()

  " Set Filetypes
  autocmd BufNewFile,BufRead *.less setfiletype css
  autocmd BufNewFile,BufRead *.liquid setfiletype liquid

  " Filetypes
  autocmd FileType javascript setlocal ts=2 sts=2 sw=2
  autocmd FileType html,slim setlocal tw=0
  autocmd FileType helpfile setlocal nonumber      " no line numbers when viewing help
  autocmd FileType helpfile nnoremap <buffer><cr> <c-]>   " Enter selects subject
  autocmd FileType helpfile nnoremap <buffer><bs> <c-T>   " Backspace to go back
endif

" Set the mapleader
let mapleader = ","

" DelimitMate
let delimitMate_expand_cr = 1
let delimitMate_balance_matchpairs = 1
" DelimitMate override of SnipMate's S-Tab
imap <S-Tab> <Plug>delimitMateS-Tab

" Enable the matchit plugin for selecting blocks.
" This is required by textobj-rubyblock.
runtime macros/matchit.vim

"
" MAPPINGS
"

" .vimrc
map <leader>v :vsp ~/.vimrc<cr>    " edit my .vimrc file in a vertical split
map <leader>u :source ~/.vimrc<cr> " update the system settings from my .vimrc file

" Toggle paste mode
set pastetoggle=<F2>

" Ctrl-N to disable search match highlight
" Note: C-N was the same as k (move to next line ) 
nmap <silent> <C-N> :silent noh<CR>

" Ctrl-P to Display the file browser tree
" Note: C-P was the same as j (move to previous line)
nmap <C-P> :NERDTreeToggle<CR>
" ,p to show current file in the tree
nmap <leader>p :NERDTreeFind<CR>

" ,/ to invert comment on the current line/selection
nmap <leader>/ :call NERDComment(0, "invert")<cr>
vmap <leader>/ :call NERDComment(0, "invert")<cr>

" Navigate splits without having to prepend with C-w
map <C-h> <C-w>h
map <C-k> <C-w>k
map <C-j> <C-w>j
map <C-l> <C-w>l

" Center search results
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz

" Force saving files that require root permission
cmap w!! %!sudo tee > /dev/null %

" Bubble single lines (uses unimpaired)
nmap <C-Up> [e
nmap <C-Down> ]e
" Bubble multiple lines (uses unimpaired)
vmap <C-Up> [egv
vmap <C-Down> ]egv

" Sessions
nmap <leader>s :SessionList<CR>
nmap <leader>ss :SessionSave<CR>
nmap <leader>sa :SessionSaveAs<CR>

" Gundo
nnoremap <F5> :GundoToggle<CR>

" CtrlP
let g:ctrlp_map = '<leader>t'
" Don't dynamically change the working path. Set it to where Vim started.
let g:ctrlp_working_path_mode = 0
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
let g:ctrlp_user_command = ['.hg/', 'hg --cwd %s locate -I .']

" TagBar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_type_coffee = {
      \'ctagstype': 'coffee',
      \'kinds': [
      \ 'c:class',
      \ 'f:functions',
      \ 'v:variables'
      \]
      \}

" NOTE: After upgrading node.js to 0.6.2, the following is not needed. Leaving
" in for now in case Mac needs it.
" Use Node.js for JavaScript Interpretation 
" Please refer https://github.com/hallettj/jslint.vim/issues/13 
let $JS_CMD='node'

"
" Functions
"

" Update NERDTree.
if !exists("*s:UpdateNERDTree")
  function s:UpdateNERDTree(...)
    let stay = 0

    if(exists("a:1"))
      let stay = a:1
    end

    if exists("t:NERDTreeBufName")
      let nr = bufwinnr(t:NERDTreeBufName)
      if nr != -1
        exe nr . "wincmd w"
        exe substitute(mapcheck("R"), "<CR>", "", "")
        if !stay
          wincmd p
        end
      endif
    endif
  endfunction
endif

" NOTE: CommandT is no longer used. Leaving for historical purposes.
" Update CommandT.
"function s:UpdateCommandT(...)
  "if exists(":CommandTFlush") == 2
    "CommandTFlush
  "endif
"endfunction

" Use Node.js for JavaScript Interpretation 
" Please refer https://github.com/hallettj/jslint.vim/issues/13 
let $JS_CMD='node'

" Console color change for Mac OS X
if has("unix")
  let s:uname = system("uname")
    if s:uname == "Darwin\n"
    set t_Co=256 
          " Do Mac stuff here
    endif
endif
