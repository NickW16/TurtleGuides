# Architecture

## Runtime

TurtleGuides targets the 1.12.1 client and its Lua 5.1 sandbox. The game owns the runtime, so the code follows its loading rules.

- Only files listed in `TurtleGuides.toc` are loaded, in the order listed.
- Subfolders are allowed using backslash paths, for example `Core\Util.lua`.
- The client provides no `dofile`, `require`, `io`, or directory enumeration. There is no way to discover or load files at runtime.
- Adding, removing, or reordering entries in the `.toc` requires a full client restart. Editing an already listed `.lua` file only needs `/reload`.

## Shared state

- Every file is loaded as its own chunk, so `local` names stay private to that file.
- The 1.12 client does not pass a private addon table to files. Use `_G.TurtleGuides` as the single namespace shared by all files.
- Modules attach named sub-tables to that namespace, for example `TG.Util` and `TG.Parser.Applies`.
- A file may only use `TG.X` when the file that defines `X` appears earlier in the `.toc`. Keep this dependency order explicit.

## Pure logic and tests

- Logic that can run without the game takes its inputs as arguments. Applicability evaluation takes a player context instead of calling WoW API functions.
- Modules avoid reading WoW globals directly inside core functions. Keep API calls at the edges.
- Tests run under host Lua 5.1 with a stub `_G.TurtleGuides` and `dofile`. Test files are not listed in the `.toc`.
- Each new module needs tests registered in `tests/run.lua`.

## Explicit declarations

- Saved variables are declared in the `.toc` with `SavedVariables` and `SavedVariablesPerCharacter`.
- Slash commands and event handlers are declared in code using the globals the client expects.
- Every shipped `.lua` file appears in the `.toc` in dependency order.

## Adding a module

1. Create the file in the matching folder and attach its table to `TG`.
2. Keep game API calls at the edges and pass context into pure logic.
3. Add the file to `TurtleGuides.toc` after everything it depends on.
4. Add tests and register them in `tests/run.lua`.
5. Run `mise run check`.
6. Restart the client to pick up `.toc` changes before testing in game.
