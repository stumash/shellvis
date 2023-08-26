M = {}

-- TODO: make this work on values that are more than one line
-- so far this whole thing chokes on multiline stuff

-- execute arbitrary bash command and retrun its output
local function execute(cmd)
  return assert(io.popen(cmd)):read("*all")
end

local function getVisPos()
  local _, startLine, startCol  = unpack(vim.fn.getpos("'<"))
  local _, endLine, endCol = unpack(vim.fn.getpos("'>"))
  return startLine, startCol, endLine, endCol
end

local function getText(startLine, startCol, endLine, endCol)
  lines = vim.fn.getline(startLine, endLine)

  if #lines == 0 then
    return ""
  else
    lastLineLen = #(lines[#lines])
    nCharsToStripFromLastLine = lastLineLen - endCol

    lines[1] = string.sub(lines[1], startCol)
    lines[#lines] = string.sub(lines[#lines], 1, -(nCharsToStripFromLastLine+1))
  end

  return lines
end

local function setText(lines, startLine, startCol, endLine, endCol)
  -- wrapped call to nvim_buf_set_text, but with 1-indexed values
  -- just like we get from getpos()
  vim.api.nvim_buf_set_text(0, startLine - 1, startCol - 1, endLine - 1, endCol, lines)
end

local function linesToText(lines)
  local s = ""
  for i, line in ipairs(lines) do
    if i ~= 1 then
      s = s .. "\n"
    end
    s = s .. line
  end
  return s
end

local function noNewlines(s)
  return string.gsub(s, "\n", "")
end

function M.replaceWith(cmd)
  startLine, startCol, endLine, endCol = getVisPos()
  linesToReplace = getText(startLine, startCol, endLine, endCol)
  linesAsStr = linesToText(lines)
  replaceWith = noNewlines(execute('echo "' .. linesAsStr .. '" | ' .. cmd))
  setText({ replaceWith }, startLine, startCol, endLine, endCol)
end

return M
