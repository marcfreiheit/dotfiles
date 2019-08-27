" | Pathogen 
" |------------------------
execute pathogen#infect()

" | basic stuff
" |------------------------
syntax on
filetype plugin indent on
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set encoding=utf-8

set number
set relativenumber
set showcmd
set cursorline
set lazyredraw
set showmatch

set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k

nnoremap gV `[v`]

" | Zooming vim windows
" |-----------------------
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

inoremap jk <esc>

set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" | Custom functions
" |-----------------------
set tabline=%!MyTabLine()
function MyTabLine()
  let s = '' " complete tabline goes here
  " loop through each tab page
  for t in range(tabpagenr('$'))
    " select the highlighting for the buffer names
    if t + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " empty space
    let s .= ' '
    " set the tab page number (for mouse clicks)
    let s .= '%' . (t + 1) . 'T'
    " set page number string
    let s .= t + 1 . ' '
    " get buffer names and statuses
    let n = ''  "temp string for buffer names while we loop and check buftype
    let m = 0 " &modified counter
    let bc = len(tabpagebuflist(t + 1))  "counter to avoid last ' '
    " loop through each buffer in a tab
    for b in tabpagebuflist(t + 1)
      " buffer types: quickfix gets a [Q], help gets [H]{base fname}
      " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
      if getbufvar( b, "&buftype" ) == 'help'
        let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
      elseif getbufvar( b, "&buftype" ) == 'quickfix'
        let n .= '[Q]'
      else
        let n .= pathshorten(bufname(b))
        "let n .= bufname(b)
      endif
      " check and ++ tab's &modified count
      if getbufvar( b, "&modified" )
        let m += 1
      endif
      " no final ' ' added...formatting looks better done later
      if bc > 1
        let n .= ' '
      endif
      let bc -= 1
    endfor
    " add modified label [n+] where n pages in tab are modified
    if m > 0
      "let s .= '[' . m . '+]'
      let s.= '+ '
    endif
    " add buffer names
    if n == ''
      let s .= '[No Name]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space to buffer list
    "let s .= '%#TabLineSel#' . ' '
    let s .= ' '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999XX'
  endif
  return s
endfunction

" | CtrlP
" |------------------------
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist|tmp)|(\.(swp|ico|git|svn))$'
let g:ctrlp_extensions = ['tag']

" | CTags
" |-----------------------
let g:auto_ctags_directory_list = ['.git'] " store tags in .git root dir
let g:auto_ctags = 1 " create tags while writing a file
let g:auto_ctags_tags_args = ['--tag-relative=yes', '--recurse=yes', '--sort=yes']

" | Syntastic - syntax checking
" |------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" disable warnings for html to work with angular
let syntastic_mode_map = { 'passive_filetypes': ['html'] }

" additional settings to use with tsuquyomi
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi'] " You shouldn't use 'tsc' checker.

let g:syntastic_python_checkers = ['flake8']

" disable angular related warnings in html
let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute " ,"trimming empty <", "unescaped &" , "lacks \"action", "is not recognized!", "discarding unexpected"]

" | Tsuquyomi
" |------------------------

" | Angular CLI
" |------------------------
autocmd VimEnter * if globpath('.,..','node_modules/@angular') != '' | call angular_cli#init() | endif
let g:angular_cli_stylesheet_format = 'scss'
let g:tsuquyomi_single_quote_import=1

" | Ayu Color Scheme
" |------------------------
set termguicolors     " enable true colors support
let ayucolor="light"  " for light version of theme
colorscheme ayu

" | Airline
" | ----------------------
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 1
set guifont=Roboto\ Mono\ for\ Powerline

" | Rainbow brackets
let g:rainbow_active = 1

set diffopt+=vertical

let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8

let g:vdebug_options = {
      \ 'port' : 9090,
      \ 'server' : '',
      \ 'path_maps': {
        \ '/usr/local/apache2/htdocs/aidorando/': '/Users/marcfreiheit/github/AidorandoWeb/'
      \ }
      \}

set t_ut=

" | Python
" | ------------------------
autocmd FileType python set sw=4
autocmd FileType python set ts=4
autocmd FileType python set sts=4
let g:python_highlight_all = 1
let g:syntastic_python_python_exec = '/usr/local/bin/flake8'

" | YouCompleteMe
" | ----------------------
let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string

" | UltiSnips
" | ----------------------
" | Configured to be used with YouCompleteMe
let g:UltiSnipsExpandTrigger       = "<c-j>"
let g:UltiSnipsJumpForwardTrigger  = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-p>"
let g:UltiSnipsListSnippets        = "<c-k>" "List possible snippets based on current file

" | Django Surround Settings
" | ----------------------
let b:surround_{char2nr("v")} = "{{ \r }}"
let b:surround_{char2nr("{")} = "{{ \r }}"
let b:surround_{char2nr("%")} = "{% \r %}"
let b:surround_{char2nr("b")} = "{% block \1block name: \1 %}\r{% endblock \1\1 %}"
let b:surround_{char2nr("i")} = "{% if \1condition: \1 %}\r{% endif %}"
let b:surround_{char2nr("w")} = "{% with \1with: \1 %}\r{% endwith %}"
let b:surround_{char2nr("f")} = "{% for \1for loop: \1 %}\r{% endfor %}"
let b:surround_{char2nr("c")} = "{% comment %}\r{% endcomment %}"
