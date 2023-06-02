" VUNDLE SECTION
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" plugins for my setup
" fugitive adds git support with :Git or :G
" e.g. :G commit -a -m commit_message_string
Plugin 'tpope/vim-fugitive'

" NERD tree adds tree exploration
Plugin 'scrooloose/nerdtree'
" The github page has a bunch of documentation
" toggling command :NERDTreeToggle
Plugin 'xuyuanp/nerdtree-git-plugin'

" This one just updates php syntax highlighting to be more modern
Plugin 'stanangeloff/php.vim'

" I decided that I didn't really like xdebug, might try it again later tho
" Support a DBGP debugger
" Plugin 'joonty/vdebug'

" ALE is a potential alternative to YouCompleteMe
" Syntastic is depreciated, so I'll try this one
" Plugin 'dense-analysis/ale'
" 
" I ended up deciding against ALE because when compared to YouCompleteMe, it
" isn't even close. The experience in YouCompleteMe is downright awesome as
" far as I can tell

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" END OF VUNDLE SECTION

" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

" From Shell Scripting by Steve Parker -- not sure I want it because
" of the debian.vim call below

" This must be first, because it changes other options as a side effect.
" set nocompatible

runtime! debian.vim

" Vim will load $VIMRUNTIME/defaults.vim if the user does not have a vimrc.
" This happens after /etc/vim/vimrc(.local) are loaded, so it will override
" any settings in these files.
" If you don't want that to happen, uncomment the below line to prevent
" defaults.vim from being loaded.
" let g:skip_defaults_vim = 1

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
filetype plugin indent on

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

" Set the dracula colorscheme located in /.vim/pack/themes/start/dracula
packadd! dracula
syntax enable
colorscheme dracula

" Add the termdebug plug-in
packadd! termdebug

" More stuff from Shell Scripting by Steve Parker:
" show line numbers
set number

" display "-- INSERT -- when entering insert mode
set showmode

" highlight matching search terms
set hlsearch
" allow backspacing anything in insert mode
set backspace=indent,eol,start
" do not wrap lines
set nowrap

" set the mouse to work in the console
set mouse=a
" keep 50 lines of command line history
set history=100
" show the cursor position
set ruler
" do incremental searching
set incsearch

" - cindent automatically indents braces
" - autoindent (ai) copies current indent to next line when starting a new line
"     with the o or O command
" - smartindent (si) mutually exclusive with cindent, but should be used with ai
"     indent after braces, cinwords, before braces
" - expandtab (et) noexpandtab (noet) uses spaces to insert a tab in insert mode
"     a real tab can be inserted with CTRL-V<Tab>
" - shiftwifth (sw) number of spaces to use for each (auto)indent
" - textwidth (tw) maximum width of text
" - softtabstop (sts) number of spaces that a tab counts for
au FileType c set cindent et tw=79 sw=4 sts=4
au FileType sh set ai et sw=4 sts=4 noexpandtab
au FileType vim set ai et sw=2 sts=2 noexpandtab
au FileType html set ai et sw=4 sts=4 noexpandtab encoding=utf-8 fileencoding=utf-8
au FileType php set ai et sw=4 sts=4 noexpandtab encoding=utf-8 fileencoding=utf-8

" indent new lines to match the current indentation
set autoindent
" don't replace tabs with spaces
set noexpandtab
" use tabs at the start of a line, spaces elsewhere
set smarttab

" show whitespace at the end of a line
" highlight WhitespaceEOL ctermbg=blue guibg=blue
" match WhitespaceEOL /\s\+$/

" Auto generate tags file on file write of *.c and *.h files
autocmd BufWritePost *.c,*.h,*.php silent! !ctags . &
