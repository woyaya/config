"设置编码"
set encoding=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936

"设置文件编码"
set fileencodings=utf-8

"设置终端编码"
set termencoding=utf-8

"设置语言编码"
"set langmenu=zh_CN.UTF-8
"set helplang=cn

"显示tab分隔符.
"注意：
"    <<<下面这行命令的最后有一个空格>>>
set list lcs=tab:\|\ 

"自动开启语法高亮"
syntax on

"设置颜色"
"colorscheme desert

"There are three types of terminals for highlighting:
"term    a normal terminal (vt100, xterm)
"cterm   a color terminal (MS-Windows console, color-xterm, these have the "Co"
"        termcap entry)
"gui     the GUI
"
"Xterm256 color names for console Vim
"     http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
"     https://github.com/guns/xterm-color-table.vim

"高亮显示当前行"
" Enable CursorLine
set cursorline
" Default Colors for CursorLine
highlight CursorLine term=bold cterm=bold ctermbg=237 ctermfg=None
" Change Color when entering Insert Mode
"autocmd InsertEnter * highlight  CursorLine ctermbg=black ctermfg=Red
" Revert Color to default when leaving Insert Mode
"autocmd InsertLeave * highlight  CursorLine ctermbg=darkgray ctermfg=None

" Visual模式下的颜色
"highlight Visual cterm=bold ctermbg=Blue ctermfg=NONE
highlight Visual cterm=bold ctermbg=grey ctermfg=None

" 不要选择光标下的字
"set selection=exclusive

"光标设置(CursorShape): 很大程度上取决于终端
"如果终端支持自动设置，可以参考如下链接配置光标
"       https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
"       https://vim.fandom.com/wiki/Configuring_the_cursor
" for more info: :help guicursor
"       :help guicursor
"       :help cursorline
" 定义n-v-c模式默认的光标颜色
"highlight Cursor guifg=white guibg=red
highlight Cursor ctermfg=white ctermbg=red
" 定义插入模式下的颜色
"highlight iCursor guifg=white guibg=blue
highlight iCursor ctermfg=white ctermbg=blue
" 定义n-v-c模式下光标外观 
set guicursor=n-v-c:block-Cursor
" 定义插入模式下光标外观
set guicursor+=i:ver100-iCursor
" 禁用n-v-c模式下光标的闪烁
set guicursor+=n-v-c:blinkon0
" 设置插入模式下光标闪烁频率
set guicursor+=i:blinkwait10
"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
let &t_SI.="\e[5 q" "SI = INSERT mode
"let &t_SR.="\e[1 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

"高亮显示匹配的括号([{和}])"
set showmatch

"搜索逐字符高亮"
set hlsearch
set incsearch
"搜索结果颜色"
highlight Search ctermfg=black ctermbg=yellow

"搜索时不区分大小写"
"还可以使用简写（“:set ic”和“:set noic”）"
"set ignorecase

"设置历史记录步数"
set history=1000

"侦测文件类型"
filetype on
"载入文件类型插件"
filetype plugin on

"激活鼠标的使用"
"set mouse=a"
"禁止使用鼠标"
set mouse-=a
set selectmode=mouse,key

"""""""""""""""""""""""""""""""
"""=>代码折叠功能<="""
"""""""""""""""""""""""""""""""
"激活折叠功能"
set foldenable
"set nofen（这个是关闭折叠功能）"

"设置按照语法方式折叠（可简写set fdm=XX）"
"有6种折叠方法：
"manual   手工定义折叠"
"indent   更多的缩进表示更高级别的折叠"
"expr     用表达式来定义折叠"
"syntax   用语法高亮来定义折叠"
"diff     对没有更改的文本进行折叠"
"marker   对文中的标志进行折叠"
set foldmethod=indent
"set fdl=0（这个是不选用任何折叠方法）"

"设置折叠区域的宽度"
"如果不为0，则在屏幕左侧显示一个折叠标识列
"分别用“-”和“+”来表示打开和关闭的折叠
set foldcolumn=0

"用空格键来代替zo和zc快捷键实现开关折叠"
"za When on a closed fold: open it recursively
"   When on an open fold: close it recursively
nnoremap <space> za
vnoremap <space> za

"折叠颜色"
highlight Folded term=bold cterm=bold ctermbg=grey ctermfg=None
highlight FoldColumn term=bold cterm=bold ctermbg=black ctermfg=None

"默认打开所有折叠
set foldlevel=100
"""""""""""""""""""""""""""""""
"""=>缓冲区buffer快捷键<="""
"""""""""""""""""""""""""""""""
noremap <C-K> :bnext<CR><CR>
noremap <C-J> :bprev<CR><CR>

"""""""""""""""""""""""""""""""""""
"=>搜索路径：当前目录及其子目录<="
"""""""""""""""""""""""""""""""""""
"set path-=/usr/include
set path=.,**

"""""""""""""""""""""""""""""""""""
"=>自动补全：不要搜索ta及源码<="
"""""""""""""""""""""""""""""""""""
set complete-=t,i

"""""""""""""""""""""""""""""""""""
" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" In insert or command mode, move normally by using Ctrl
" Attention:
" |     On SSH client setting, set key "Backspace" as "^?" but NOT "^H"
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

"""""""""""""""""""""""""""""""
"""=>插件Plugin<="""
"""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

 Plug 'majutsushi/tagbar'
 Plug 'preservim/nerdtree'
 Plug 'Yggdroot/LeaderF'
 Plug 'vim-airline/vim-airline'
 Plug 'vim-airline/vim-airline-themes'
" Plug 'Yggdroot/indentLine'
 Plug 'mhinz/vim-startify'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'majutsushi/tagbar'
 Plug 'zivyangll/git-blame.vim'
 Plug 'tpope/vim-fugitive'
 Plug 'yegappan/taglist'
 Plug 'LeafCage/autobackup.vim'

call plug#end()

let g:coc_disable_startup_warning = 1
"nerdtree
"将Ctrl+n映射成显示目录结构
map <C-n> :NERDTreeToggle<CR>
"默认显示隐藏文件及文件夹
let NERDTreeShowHidden=1

"LeaderF
source ~/.vim/leaderf.vimrc

"vim-airline
source ~/.vim/airline.vimrc

"coc.nvim
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-yaml', 'coc-clangd']
"source ~/.vim/coc_nvim.vimrc

"indentLine
"let g:indentLine_enabled = 1
"let g:indent_guides_guide_size = 1  " 指定对齐线的尺寸
"let g:indent_guides_start_level = 2  " 从第二层开始可视化显示缩进

"autobackup
let g:autobackup_backup_dir = "~/.backup/vim"
let g:autobackup_backup_limit = 128

"git-blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>
