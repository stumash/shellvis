local M = {}

-- execute arbitrary bash command and retrun its output
function execute(cmd)
  return assert(io.popen(cmd)):read("*all")
end

return M
