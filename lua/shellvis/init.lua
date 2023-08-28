M = {}

local function execute(cmd, text)
  -- wrap the text in a HEREDOC and read it into a variable
  local s = "IFS='' read -d '' -r TEMPVAR <<'HEREDOC' \n" .. text .. "\nHEREDOC\n"
  -- then echo that variable into the cmd
  s = s .. 'echo "$TEMPVAR" | ' .. cmd

  local ok, result = pcall(function() return io.popen(s) end)
  if ok then
    return result:read("*all")
  else
    vim.print { shErr=result }
    return nil
  end
end

function M.getVisPos()
  local _, startLine, startCol  = unpack(vim.fn.getpos("'<"))
  local _, endLine, endCol = unpack(vim.fn.getpos("'>"))
  return startLine, startCol, endLine, endCol
end

local function getText(startLine, startCol, endLine, endCol)
  local lines = vim.fn.getline(startLine, endLine)
  local replaceEndCol = nil

  if #lines == 0 then
    return ""
  else
    local lastLineLen = #(lines[#lines])
    local nCharsToStripFromLastLine

    if endCol == vim.v.maxcol then
      -- visual line mode
      nCharsToStripFromLastLine = 0
      replaceEndCol = lastLineLen
    else
      nCharsToStripFromLastLine = lastLineLen - endCol
    end

    lines[1] = string.sub(lines[1], startCol)
    lines[#lines] = string.sub(lines[#lines], 1, -(nCharsToStripFromLastLine+1))
  end

  return lines, replaceEndCol
end

local function setText(lines, startLine, startCol, endLine, endCol)
  -- wrapped call to nvim_buf_set_text, but with 1-indexed values
  -- just like we get from getpos()
  local l1, c1 = startLine-1, startCol-1
  local l2, c2 = endLine-1, endCol
  vim.api.nvim_buf_set_text(0, l1, c1, l2, c2, lines)
end

local function joinWithNewline(lines)
  local s = ""
  for i, line in ipairs(lines) do
    if i ~= 1 then
      s = s .. "\n"
    end
    s = s .. line
  end
  return s
end

local function splitOnNewline(s)
  local retval = {}
  local i = 1
  for line in (s .. "\n"):gmatch("([^\n]*)\n") do
    retval[i] = line
    i = i + 1
  end
  return retval
end

local function removeSpuriousTrailingNewline(lines)
  -- seems like I gotta do this because the bourne shell adds an extra one in
  if lines[#lines] == "" then
    lines[#lines] = nil
  end
end

function M.replaceWith(replacer)
  local startLine, startCol, endLine, endCol = M.getVisPos()
  local lines, replaceEndCol = getText(startLine, startCol, endLine, endCol)
  if replaceEndCol ~= nil then
    endCol = replaceEndCol
  end

  local linesAsStr = joinWithNewline(lines)

  local replaceWith
  local rt = type(replacer)
  if rt == "function" then
    replaceWith = replacer(linesAsStr)
  elseif rt == "string" then
    replaceWith = execute(replacer, linesAsStr)
  else
    error([[must pass replacer of type "string|function", instead got ]] .. rt)
  end
  replaceWithLines = splitOnNewline(replaceWith)

  removeSpuriousTrailingNewline(replaceWithLines, startLine, endLine)
  setText(replaceWithLines, startLine, startCol, endLine, endCol)
end

return M
