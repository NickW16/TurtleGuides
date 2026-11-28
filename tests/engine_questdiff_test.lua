local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/engine/QuestDiff.lua")
end

return {
  test_diff_reports_accepted_and_removed_rows = function()
    local TG = fresh()
    local previous = {
      foo = { title = "Foo", ids = { 42 }, complete = true },
      bar = { title = "Bar", ids = { 7 }, complete = false },
    }
    local current = {
      foo = { title = "Foo", ids = { 42 }, complete = true },
      baz = { title = "Baz", ids = { 9 }, complete = false },
    }
    local diff = TG.Engine.QuestDiff.diff(previous, current)
    env.eq(table.getn(diff.accepted), 1)
    env.eq(diff.accepted[1].title, "Baz")
    env.eq(table.getn(diff.removed), 1)
    env.eq(diff.removed[1].title, "Bar")
    env.eq(diff.removed[1].complete, false)
  end,

  test_diff_ignores_first_snapshot = function()
    local TG = fresh()
    local current = { foo = { title = "Foo", ids = { 42 } } }
    local diff = TG.Engine.QuestDiff.diff(nil, current)
    env.eq(table.getn(diff.accepted), 1)
    env.eq(table.getn(diff.removed), 0)
  end,
}
