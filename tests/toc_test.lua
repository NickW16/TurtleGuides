-- verifies every shipped lua file is registered in the toc
local function listedFiles()
  local file = assert(io.open("TurtleGuides.toc", "r"))
  local listed = {}
  for line in file:lines() do
    if line ~= "" and line:sub(1, 2) ~= "##" then
      listed[line:gsub("\\", "/")] = true
    end
  end
  file:close()
  return listed
end

local function sourceFiles()
  local files = {}
  local handle = assert(io.popen('find src -name "*.lua" -print'))
  for line in handle:lines() do
    table.insert(files, line)
  end
  handle:close()
  return files
end

return {
  test_toc_lists_every_shipped_source = function()
    local listed = listedFiles()
    for _, path in ipairs(sourceFiles()) do
      if not listed[path] then
        error(path .. " is missing from TurtleGuides.toc", 2)
      end
    end
  end,
}
