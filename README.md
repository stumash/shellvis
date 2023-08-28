# Shellvis

Pass the current visual selection to shell commands or lua functions and replace it with their output.

## Installation

```vim
Plug 'stumash/shellvis.nvim'
```

## Usage

VimL:
```vim
vnoremap <leader>esf <cmd>lua require'shellvis'.replaceWith'base64'<cr>
vnoremap <leader>efs <cmd>lua require'shellvis'.replaceWith'base64 -d'<cr>
```

or Lua:
```lua
local sv = require'shellvis'

-- replace the entire visual selection with the base64 encoding of it
vim.keymap.set('v', '<leader>esf', function() sv.replaceWith("base64") end)
-- replace the entire visual selection with the base64 decoding of it
vim.keymap.set('v', '<leader>efs', function() sv.replaceWith("base64 -d") end)

local function justOneX(textToReplace) return "x" end
-- replace the entire visual selection with a single character "x"
vim.keymap.set('v', '<leader>eX', function() sv.replaceWith(justOneX) end)
```
