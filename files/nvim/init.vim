set nocompatible
filetype plugin on
syntax on

autocmd FileType vimwiki setlocal conceallevel=2 concealcursor=nvc
autocmd FileType make setlocal noexpandtab tabstop=4 shiftwidth=4

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'vimwiki/vimwiki'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'   " optional, for extra themes

" Example dark themes
Plug 'AlexvZyl/nordic.nvim'
Plug 'navarasu/onedark.nvim'
Plug 'sainnhe/everforest'
Plug 'EdenEast/nightfox.nvim'
Plug 'dasupradyumna/midnight.nvim'

" Core dependencies
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-tree/nvim-web-devicons' " optional, for file icons

" Neo-tree itself
Plug 'nvim-neo-tree/neo-tree.nvim'

" Vim-iPython and dependencies
Plug 'jpalardy/vim-slime'
Plug 'hanschen/vim-ipython-cell'

" Learn Vim with vim-be-better
Plug 'szymonwilczek/vim-be-better'

call plug#end()

" Optional settings
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]


colorscheme onedark

" Neo-tree setup
lua << EOF
require("neo-tree").setup({
  close_if_last_window = true,
  enable_git_status = true,
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = "open_default",
  },
})
EOF

" Key bindings 
nnoremap <leader>e :Neotree toggle<CR>
nnoremap <leader>b :Neotree buffers toggle<CR>
nnoremap <leader>g :Neotree git_status toggle<CR>

"------------------------------------------------------------------------------
" slime configuration 
"------------------------------------------------------------------------------
" always use tmux
let g:slime_target = 'tmux'

" fix paste issues in ipython
let g:slime_python_ipython = 1
let g:slime_bracketed_paste = 1
let g:ipython_cell_send_ctrl_c = 0

let g:slime_default_config = {
            \ 'socket_name': 'default',
            \ 'target_pane': 'python:0.0' }

let g:slime_dont_ask_default = 1


"------------------------------------------------------------------------------
" ipython-cell configuration
"------------------------------------------------------------------------------
" Keyboard mappings. <Leader> is \ (backslash) by default

" map <Leader>s to start IPython
nnoremap <Leader>s :SlimeSend1 ipython --matplotlib<CR>

" map <Leader>r to run script
nnoremap <Leader>r :IPythonCellRun<CR>

" map <Leader>R to run script and time the execution
nnoremap <Leader>R :IPythonCellRunTime<CR>

" map <Leader>c to execute the current cell
nnoremap <Leader>c :IPythonCellExecuteCell<CR>

" map <Leader>C to execute the current cell and jump to the next cell
nnoremap <Leader>C :IPythonCellExecuteCellJump<CR>

" map <Leader>l to clear IPython screen
nnoremap <Leader>l :IPythonCellClear<CR>

" map <Leader>x to close all Matplotlib figure windows
nnoremap <Leader>x :IPythonCellClose<CR>

" map [c and ]c to jump to the previous and next cell header
nnoremap [c :IPythonCellPrevCell<CR>
nnoremap ]c :IPythonCellNextCell<CR>

" map <Leader>h to send the current line or current selection to IPython
nmap <Leader>h <Plug>SlimeLineSend
xmap <Leader>h <Plug>SlimeRegionSend

" map <Leader>p to run the previous command
nnoremap <Leader>p :IPythonCellPrevCommand<CR>

" map <Leader>Q to restart ipython
nnoremap <Leader>Q :IPythonCellRestart<CR>

" map <Leader>d to start debug mode
nnoremap <Leader>d :SlimeSend1 %debug<CR>

" map <Leader>q to exit debug mode or IPython
nnoremap <Leader>q :SlimeSend1 exit<CR>

" map <F9> and <F10> to insert a cell header tag above/below and enter insert mode
nmap <F9> :IPythonCellInsertAbove<CR>a
nmap <F10> :IPythonCellInsertBelow<CR>a

" also make <F9> and <F10> work in insert mode
imap <F9> <C-o>:IPythonCellInsertAbove<CR>
imap <F10> <C-o>:IPythonCellInsertBelow<CR>

" added loader for VimBeBetter
nnoremap <leader>vbb :VimBeBetter<CR>

" Load additional Lua config file
lua require('myconfig')

