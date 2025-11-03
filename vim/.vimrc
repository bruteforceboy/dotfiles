filetype detect

set nocompatible
set exrc
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

set smarttab
set autoindent
set smartindent
set cindent

set showcmd
set number
set autowrite
set autoread

set nowrap

set clipboard=unnamedplus

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'rhysd/vim-clang-format'
Plug 'instant-markdown/vim-instant-markdown'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
call plug#end()

" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

syntax enable
set background=dark
let g:material_theme_style = 'palenight'
colorscheme material

" For Neovim > 0.1.5 and Vim > patch 7.4.1799 - https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162
" Based on Vim patch 7.4.1770 (`guicolors` option) - https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd
" https://github.com/neovim/neovim/wiki/Following-HEAD#20160511
if (has('termguicolors'))
  set termguicolors
endif

inoremap {<CR> {<CR>}<Esc>ko
inoremap ( ()<Esc>ha
inoremap [ []<Esc>ha
inoremap " ""<Esc>ha
inoremap ' ''<Esc>ha
inoremap ` ``<Esc>ha

" Clang-format options
let g:clang_format#style_options = {
            \ "BasedOnStyle" : "Google",
            \ "ColumnLimit" : 80,
            \ "SpacesInContainerLiterals" : "true",
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "c++23",
            \ "BreakBeforeBraces" : "Stroustrup",
            \ "SpaceBeforeCpp11BracedList" : "true",
            \ "SpaceBeforeParens" : "ControlStatements"}

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

autocmd BufWritePre *.cpp,*.h,*.c,*.hpp ClangFormat
autocmd filetype cpp nnoremap <C-S-B> :w <bar> !g++ -std=c++23 -DLOCAL % -o %:r<CR>
