# Architecture

## Runtime

TurtleGuides targets the 1.12.1 client and its Lua 5.0 based sandbox. The client lacks several Lua 5.1 functions, so `src/compat/Runtime.lua` installs the needed shims. The game owns the runtime, so the code follows its loading rules.

- Only files listed in `TurtleGuides.toc` are loaded, in the order listed.
- All Lua lives under `src/`, and subfolders are allowed using backslash paths, for example `src\core\Util.lua`.
- The client provides no `dofile`, `require`, `io`, or directory enumeration. There is no way to discover or load files at runtime.
- Adding, removing, or reordering entries in the `.toc` requires a full client restart. Editing an already listed `.lua` file only needs `/reload`.

## Shared state

- Every file is loaded as its own chunk, so `local` names stay private to that file.
- The 1.12 client does not pass a private addon table to files. Use `_G.TurtleGuides` as the single namespace shared by all files.
- Modules attach named sub-tables to that namespace, for example `TG.Util` and `TG.Parser.Applies`.
- A file may only use `TG.X` when the file that defines `X` appears earlier in the `.toc`. Keep this dependency order explicit.

## Packages

The root stays flat. Code lives in `src/`, tests in `tests/`, and documentation in `docs/`. Inside `src/`, each domain is a package with one folder and flat files named by concern, for example `src/waypoint/Geometry.lua`, `src/waypoint/State.lua`, and `src/ui/Arrow.lua`.

- Logic and backend packages are `core/`, `compat/`, `parser/`, `waypoint/`, `engine/`, `automation/`, `vendor/`, and `guides/`. They never create frames or touch widgets.
- Rendering lives in `ui/` for every feature. Rendering reads state and never makes decisions.
- The `.toc` order is the dependency graph. Packages must not depend on each other in a cycle.
- A `ui/components/` package gets created only when two or more features duplicate the same widget.

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

1. Create the file in the matching package under `src/` and attach its table to `TG`.
2. Keep game API calls at the edges and pass context into pure logic.
3. Add the file to `TurtleGuides.toc` after everything it depends on.
4. Add tests and register them in `tests/run.lua`.
5. Run `mise run check`.
6. Restart the client to pick up `.toc` changes before testing in game.
