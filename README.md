# shellvis

Transform the current **vis**ual selection with **shell** commands

## Install

* vim-plug: `Plug 'stumash/shellvis'`

## Usage

```viml
" base64
vnoremap <leader>esf :<c-u>call shellvis#do("base64")<cr>
vnoremap <leader>efs :<c-u>call shellvis#do("base64 -d")<cr>
```
