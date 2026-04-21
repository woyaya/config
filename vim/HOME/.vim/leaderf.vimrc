"See https://github.com/Yggdroot/LeaderF#configuration-examples for more info
" don't show the help in normal mode
let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
let g:Lf_StlColorscheme = 'powerline'
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_PopupColorscheme = 'gruvbox_default'
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 1, 'BufTag': 0 }

let g:Lf_ShortcutF = "<leader>ff"

" ================= LeaderF 隐藏文件配置 =================
" 1. 在搜文件名时 (:LeaderfFile)，显示隐藏文件
let g:Lf_ShowHidden = 1
" 2. 哪怕显示了隐藏文件，也要死死屏蔽掉 .git 目录，防止污染结果
let g:Lf_WildIgnore = {
  \ 'dir': ['.svn','.git','.hg','.vscode','.idea'],
  \ 'file': ['*.sw?','~$*','*.bak','*.o','*.py[co]','*.DS_Store']
  \}
" 3. 在搜代码内容时 (:LeaderfRg)，也开启搜索隐藏文件
let g:Lf_RgConfig = ["--hidden"]

noremap <leader>fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap <leader>fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
noremap <leader>ft :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>

noremap <C-B> :<C-U><C-R>=printf("Leaderf! --auto-preview rg --current-buffer -e %s ", expand("<cword>"))<CR>
"noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
" search visually selected text literally
xnoremap gf :<C-U><C-R>=printf("Leaderf! --auto-preview rg -F -e %s ", leaderf#Rg#visual())<CR>
noremap go :<C-U>Leaderf! --auto-preview rg --recall<CR>

" should use `Leaderf gtags --update` first
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_Gtagslabel = 'native-pygments'
noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>

"See https://learnku.com/articles/22388 for more info
" search word under cursor, the pattern is treated as regex, and enter normal mode directly
noremap <C-F> :<C-U><C-R>=printf("Leaderf! --auto-preview rg -s -g '!tags' -g '!*.d' --iglob '!build' -e '\\b%s\\b'", expand("<cword>"))<CR><CR>
" search visually selected text literally
xnoremap <C-F> :<C-U><C-R>=printf("Leaderf! --auto-preview rg -s -g '!tags' -g '!*.d' --iglob '!build' -e %s ", leaderf#Rg#visual())<CR><CR>
" prepare search command and waiting for text
nnoremap <leader>f :Leaderf! --auto-preview rg -s -g '!tags' -g '!*.d' --iglob '!build' -e 
