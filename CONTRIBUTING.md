# Contributing

## Setup

Tool versions are pinned in `mise.toml`. Install them once with:

```sh
mise install
```

Tasks put the tools on PATH, so no shell activation is needed.

## Architecture

See `docs/ARCHITECTURE.md` for the runtime model, module layout, and loading rules.

## Workflow

All changes land on `main` through a branch and a pull request. Start from an up to date `main`, work on a focused branch, and open a PR when ready:

```sh
git fetch origin
git switch main
git pull --rebase origin/main
git switch -c fix/short-description
git push -u origin fix/short-description
```

Keep branches short lived and pull or rebase regularly so they do not drift from `main`. Coordinate who owns a file when two people are working at the same time. The `check` workflow must pass on the PR before merge, and review by another person is encouraged.

Trivial follow ups, such as a typo or a one line correction to a commit you just made, may go directly to `main` as long as validation passes.

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

It checks formatting, lints, and runs the tests without modifying anything. Use `mise run test` for tests alone and `mise run fix` to format the sources and then lint. Every new module needs tests, and a change is only ready to commit when validation passes. The same command runs in CI on every push and pull request, so make sure it passes locally before pushing.
