M = {}

M.CHARWISE = "v"
M.LINEWISE = "V"
M.BLOCKWISE = "\22"

function M.execute(cmd, text)
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
  local _, startLine, startCol  = unpack(vim.fn.getpos("."))
  local _, endLine, endCol = unpack(vim.fn.getpos("v"))

  if endLine < startLine then
    startLine, startCol, endLine, endCol = endLine, endCol, startLine, startCol
  elseif endLine == startLine and endCol < startCol then
    startCol, endCol = endCol, startCol
  end

  local mode = vim.fn.mode("fullmode")
  if mode:sub(1, 1) == M.CHARWISE then -- visual character-wise mode
    mode = M.CHARWISE
  elseif mode:sub(1, 1) == M.LINEWISE then -- visual line-wise mode
    mode = M.LINEWISE
  elseif mode:sub(1, 1) == M.BLOCKWISE then -- visual block-wise mode
    mode = M.BLOCKWISE
  else
    error(
      'current mode ' .. mode .. " does not start with one of [" .. 
        M.CHARWISE .. ", " .. M.LINEWISE .. ", " .. M.BLOCKWISE ..
      "]"
    )
  end

  return {
    mode = mode,
    positions = {
      startLine = startLine,
      startCol = startCol,
      endLine = endLine,
      endCol = endCol,
    },
  }
end

function M.getText(positions, mode)
  local startLine, startCol = positions["startLine"], positions["startCol"]
  local endLine, endCol = positions["endLine"], positions["endCol"]

  local lines = vim.fn.getline(startLine, endLine)

  if #lines == 0 then
    return ""
  end

  if mode == M.CHARWISE then
    local lastLineLen = #(lines[#lines])
    local nCharsToStripFromLastLine = lastLineLen - endCol
    lines[1] = string.sub(lines[1], startCol)
    lines[#lines] = (lines[#lines]):sub(1, -(nCharsToStripFromLastLine+1))
  elseif mode == M.LINEWISE then
    startCol, endCol = 1, #(lines[#lines])
  elseif mode == M.BLOCKWISE then
    for i = 1,#lines do
      lines[i] = (lines[i]):sub(startCol, endCol)
    end
  end

  return lines, {startLine=startLine, startCol=startCol, endLine=endLine, endCol=endCol}
end

function M.setText(positions, mode, lines)
  vim.print {
    positions=positions,
    mode=mode,
    lines=lines,
  }
  local startLine, startCol = positions["startLine"], positions["startCol"]
  local endLine, endCol = positions["endLine"], positions["endCol"]
  -- wrapped call to nvim_buf_set_text, but with 1-indexed values
  -- just like we get from getpos()
  if mode == M.CHARWISE or mode == M.LINEWISE then
    local l1, c1 = startLine-1, startCol-1
    local l2, c2 = endLine-1, endCol
    vim.api.nvim_buf_set_text(0, l1, c1, l2, c2, lines)
  elseif mode == M.BLOCKWISE then
    local l = startLine-1
    for i = 1,#lines do
      vim.api.nvim_buf_set_text(0, l, startCol-1, l, endCol, { lines[i] })
      l = l + 1
    end
  end
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
  -- seems like I gotta do this because the bourne shell adds a trailing newline
  if lines[#lines] == "" then lines[#lines] = nil end
  return lines
end

function M.replaceWith(replacer)
  local visPos = M.getVisPos()
  local positions, mode = visPos["positions"], visPos["mode"]
  local lines, positions = M.getText(positions, mode)

  local linesAsStr = joinWithNewline(lines)

  local replaceWith
  local rt = type(replacer)
  if rt == "function" then
    replaceWith = replacer(linesAsStr)
  elseif rt == "string" then
    replaceWith = M.execute(replacer, linesAsStr)
  else
    error([[must pass replacer of type "string|function", instead got ]] .. rt)
  end
  replaceWithLines = removeSpuriousTrailingNewline(splitOnNewline(replaceWith))

  M.setText(positions, mode, replaceWithLines)

  esckey = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esckey, 'n', false)
end

return M
