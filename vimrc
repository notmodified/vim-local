" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Jul 02
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

set expandtab
set ts=2 sw=2
set nohlsearch

colorscheme lucius

" drupal stupidness
au BufRead,BufNewFile *.inc,*.info,*.module,*.theme,*.install,*.test set filetype=php

" ruby complete
au BufRead,BufNewFile *.rb,Gemfile,Guardfile, set filetype=ruby

" clojurescript
au BufNewFile,BufRead *.cljs set filetype=clojure

autocmd BufEnter * :syntax sync fromstart

"no backups or swaps please
set nobackup
set noswapfile
set nowb

"Persistent undo
try
  if version >= 703
    set undodir=~/.vim_runtime/undodir
    set undofile
  endif
catch
endtry

highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/

call pathogen#infect()

nnoremap ; :
map <leader><Right> :bn<cr>
map <leader><Left> :bp<cr>
map <leader>l :LustyJuggler<cr>

inoremap <leader>yes ✔
inoremap <leader>no ✖
inoremap <leader>hellip …
inoremap <leader>star ☆

set laststatus=2   " Always show the statusline
let g:Powerline_symbols = 'fancy'

"let g:Powerline_symbols = 'unicode'

"allow buffer navigation without saving
set hid

let g:LustyJugglerSuppressRubyWarning = 1

map <C-n> :NERDTreeToggle<CR>

let g:syntastic_php_checkers = ['php']
" let g:syntastic_php_phpcs_args = "--standard=Drupal"

autocmd CompleteDone * pclose

set clipboard=unnamed

if !exists("g:vdebug_options")
  let g:vdebug_options = {}
endif

let g:vdebug_options['server'] = '0.0.0.0'
let g:vdebug_options['path_maps'] = {'/var/www/vhosts/drupal7.dev/docroot':'/Users/jameswilson/Sites/drupal7.dev/docroot','/var/www/vhosts/aoc.dev/docroot':'/Users/jameswilson/Sites/aoc.dev/docroot','/var/www/vhosts/euromoney.dev/docroot':'/Users/jameswilson/Sites/euromoney.dev/docroot','/var/www/vhosts/ii-conferences.dev/docroot':'/Users/jameswilson/Sites/ii-conferences.dev/docroot'}

set rtp+=~/.fzf

nnoremap <C-P> :FZF -x -m<CR>

" List of buffers
function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

nnoremap <silent> <Leader><Enter> :call fzf#run({
\   'source':  reverse(<sid>buflist()),
\   'sink':    function('<sid>bufopen'),
\   'options': '+m -x',
\   'down':    len(<sid>buflist()) + 2
\ })<CR>

function! s:tagvisit(e)
  execute 'tag' matchstr(a:e, '[^ ]*')
endfunction

command! -bar FZFTag call fzf#run({
\ 'source': "awk '{print $1 \" \\033[38;5;131m⇰\\033[38;5;59m \" $2 \"\\033[0;0m\"}' " . join(tagfiles()) . ' | grep -v "^!" | uniq',
\ 'sink': function('<sid>tagvisit'), 'options': '-m -x --ansi', 'down': '40%' })

nnoremap <C-M> :FZFTag<CR>

command! -bar FZFTagFile call fzf#run({
\   'source': "cat " . tagfiles()[0] . " | grep '" . expand('%:@') .
\     "' | grep '[fc]$' | awk 'BEGIN {FS=\"\t\"}; {print $1 \" \\033[38;5;131m⇰\\033[38;5;59m \" $3 \"\\033[0;0m\"}'" .
\     " | sed 's/[\/\^]//g' | sed 's/\$;\"//g' ",
\   'sink': function('<sid>tagvisit'), 'options':  '+m -x --ansi', 'down': '40%' })

nnoremap <BS> :FZFTagFile<CR>

let g:syntastic_javascript_checkers = ['eslint']
