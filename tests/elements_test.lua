local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "Core.lua",
    "Core/Util.lua",
    "Core/Output.lua",
    "Core/State.lua",
    "Parser/Applies.lua",
    "Parser/Context.lua",
    "Parser/Elements.lua"
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
