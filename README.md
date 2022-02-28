# shellvis

Transform the current `vis`ual selection with `shell` commands

## Install

* vim-plug: `Plug 'stumash/shellvis'`
* pathogen: `git clone git@github.com:stumash/shellvis.git ~/.vim/bundle/shellvis`
* manual: copy the files to your .vim directory

## Example Usage

```viml
" base64 encode and decode the current visual selection
vnoremap <leader>esf :<c-u>call shellvis#do("base64")<cr>
vnoremap <leader>efs :<c-u>call shellvis#do("base64 -d")<cr>

" gzip then base64
vnoremap <leader>ezsf :<c-u>call shellvis#do("gzip \| base64")<cr>
vnoremap <leader>ezfs :<c-u>call shellvis#do("base64 -d \| gzip -d")<cr>

" json formatting
vnoremap <leader>json :<c-u>call shellvis#do("jq")<cr>
```
