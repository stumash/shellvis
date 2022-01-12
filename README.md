# shellvis

Transform the current `vis`ual selection with `shell` commands

## Install

* vim-plug: `Plug 'stumash/shellvis'`
* pathogen: `git clone git@github.com:stumash/shellvis.git ~/.vim/bundle/shellvis`
* manual: copy the files to your .vim directory

## Usage

```viml
" base64
vnoremap <leader>esf :<c-u>call shellvis#do("base64")<cr>
vnoremap <leader>efs :<c-u>call shellvis#do("base64 -d")<cr>
```
