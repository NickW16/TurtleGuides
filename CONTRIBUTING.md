# Contributing

## Setup

Tool versions are pinned in `mise.toml`. Install them once with:

```sh
mise install
```

Tasks put the tools on PATH, so no shell activation is needed.

## Writing style

- Never use em dashes in code, comments, docs, or commit messages. Use commas instead.
- Comments start lowercased.
- Keep comments concise but informative, and trim padding.
- Comments describe current behavior and intent, never past mistakes or fixes.
- Avoid multiple comment lines unless the reason genuinely needs explaining.
- Never reference other apps, projects, or sources of inspiration in comments.

## Code organization

- Prefer small, focused modules with a single responsibility.
- Separate logic, UI, data, and helpers by concern.
- Favor incremental extraction over growing large files, and keep APIs stable.
- Generated, vendor, and data-heavy files are exceptions when splitting would harm correctness or tooling.

## Commits

Use conventional commit subjects only, with no description or body. For example:

```text
fix: stop auto-using unrequested quest items
refactor: split guide parsing from step tracking
```

## Validation

Run this before committing:

```sh
mise run check
```

It checks formatting, lints, and runs the tests without modifying anything. Use `mise run test` for tests alone and `mise run fix` to format the sources and then lint. Every new module needs tests, and a change is only ready to commit when validation passes.
