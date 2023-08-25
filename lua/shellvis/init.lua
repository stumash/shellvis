local M = {}

-- execute arbitrary bash command and retrun its output
function execute(cmd)
  return assert(io.popen(cmd)):read("*all")
end

-- get the (startLnum, startCnum, endLnum, endCnum) of the current visual selection
function getVisPos()
  local _, startLnum, startCnum  = vim.fn.getpos("<")
  local _, endLnum, endCnum = vim.fn.getpos(">")
  return startLnum, startCnum, endLnum, endCnum
end

return M

--
-- getline({lnum} [, {end}])
--     Without {end} the result is a String, which is line {lnum}
--     from the current buffer.  Example: >
--       getline(1)
--     When {lnum} is a String that doesn't start with a
--     digit, |line()| is called to translate the String into a Number.
--     To get the line under the cursor: >
--       getline(".")
--     When {lnum} is a number smaller than 1 or bigger than the
--     number of lines in the buffer, an empty string is returned.
-- 
--     When {end} is given the result is a |List| where each item is
--     a line from the current buffer in the range {lnum} to {end},
--     including line {end}.
--     {end} is used in the same way as {lnum}.
--     Non-existing lines are silently omitted.
--     When {end} is before {lnum} an empty |List| is returned.
--     Example: >
