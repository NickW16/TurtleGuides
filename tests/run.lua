-- loads test modules and exits nonzero if any fail
local testFiles = {
  "tests/applies_test.lua",
  "tests/commands_test.lua",
  "tests/events_test.lua",
  "tests/init_test.lua",
  "tests/output_test.lua",
  "tests/runtime_test.lua",
  "tests/state_test.lua",
  "tests/text_test.lua",
  "tests/toc_test.lua",
  "tests/util_test.lua",
  "tests/zone_test.lua",
}
local failures = 0
local total = 0

for _, file in ipairs(testFiles) do
  local tests = dofile(file)
  local names = {}
  for name in pairs(tests) do
    table.insert(names, name)
  end
  table.sort(names)
  for _, name in ipairs(names) do
    total = total + 1
    local ok, err = pcall(tests[name])
    if ok then
      print("ok   " .. name)
    else
      failures = failures + 1
      print("FAIL " .. name .. ": " .. tostring(err))
    end
  end
end

print(total .. " tests, " .. failures .. " failures")
if failures > 0 then
  os.exit(1)
end
