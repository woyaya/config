"""""""""""""""""""""""""""""""
"""=>插件Plugin<="""
"""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

 Plug 'majutsushi/tagbar'
 Plug 'preservim/nerdtree'
 Plug 'Yggdroot/LeaderF'
 Plug 'vim-airline/vim-airline'
 Plug 'vim-airline/vim-airline-themes'
 Plug 'Yggdroot/indentLine'
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
let g:indentLine_enabled = 1
let g:indent_guides_guide_size = 1  " 指定对齐线的尺寸
let g:indent_guides_start_level = 2  " 从第二层开始可视化显示缩进

"autobackup
let g:autobackup_backup_dir = "~/.backup/vim"
let g:autobackup_backup_limit = 128

"git-blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>
