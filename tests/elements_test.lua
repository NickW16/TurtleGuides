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

  test_multi_id_and_reverse_condition_args = function()
    local TG = fresh()
    local on = TG.Parser.parseElementLine(".isOnQuest 218,3364")
    env.eq(table.getn(on.questIds), 2)
    env.eq(on.questIds[1], 218)
    env.eq(on.questIds[2], 3364)
    env.eq(on.reverse, false)

    local notOn = TG.Parser.parseElementLine(".isNotOnQuest 218,3364")
    env.eq(notOn.tag, "isNotOnQuest")
    env.eq(table.getn(notOn.questIds), 2)

    local reversed = TG.Parser.parseElementLine(".isQuestComplete 414,reverse")
    env.eq(reversed.tag, "isQuestComplete")
    env.eq(reversed.reverse, true)

    local notComplete = TG.Parser.parseElementLine(".isQuestNotComplete 414")
    env.eq(notComplete.tag, "isQuestComplete")
    env.eq(notComplete.reverse, true)
  end,

  test_negative_id_and_skip_flags = function()
    local TG = fresh()
    local turnin = TG.Parser.parseElementLine(".turnin -414 >> Turn in Stout to Kadrell")
    env.eq(turnin.args[1], "-414")
    env.eq(turnin.questIds[1], 414)
    env.eq(turnin.skipIfMissing, true)

    local complete = TG.Parser.parseElementLine(".complete -386,1")
    env.eq(complete.questIds[1], 386)
    env.eq(complete.args[2], "1")
    env.eq(complete.skipIfMissing, true)

    local bang = TG.Parser.parseElementLine(".complete! 123,1")
    env.eq(bang.tag, "complete")
    env.eq(bang.sourceTag, "complete!")
    env.eq(bang.skipIfMissing, true)
  end,
}
