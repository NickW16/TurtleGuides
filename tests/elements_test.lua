local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/parser/Applies.lua",
    "src/parser/Context.lua",
    "src/parser/Elements.lua"
  )
end

return {
  test_command_line = function()
    local TG = fresh()
    local el = TG.Parser.parseElementLine(".accept 123 >>Accept Foo")
    env.eq(el.t, "cmd")
    env.eq(el.tag, "accept")
    env.eq(el.args[1], "123")
    env.eq(el.text, "Accept Foo")
  end,

  test_tag_aliases_and_objective = function()
    local TG = fresh()
    env.eq(TG.Parser.parseElementLine(".kill 5").tag, "mob")
    local el =
      TG.Parser.parseElementLine(".complete 317,2 --Collect Thick Bear Fur (x2)", "Collect Thick Bear Fur (x2)")
    env.eq(el.objectiveText, "Collect Thick Bear Fur (x2)")
  end,

  test_target_tag_keeps_source_tag = function()
    local TG = fresh()
    local target = TG.Parser.parseElementLine(".target Rejold Barleybrew")
    local kill = TG.Parser.parseElementLine(".kill Frostmane Seer")
    env.eq(target.tag, "mob")
    env.eq(target.sourceTag, "target")
    env.eq(kill.tag, "mob")
    env.eq(kill.sourceTag, "kill")
  end,

  test_text_tags = function()
    local TG = fresh()
    env.eq(TG.Parser.parseElementLine("#label Hello").value, "Hello")
    env.eq(TG.Parser.parseElementLine(">> Go north").text, "Go north")
    env.eq(TG.Parser.parseElementLine("+ a note").kind, "note")
    env.eq(TG.Parser.parseElementLine("* some info").kind, "info")
  end,

  test_condition_filters_line = function()
    local TG = fresh()
    env.eq(TG.Parser.parseElementLine(".accept 1 << Alliance"), false)
  end,
}
