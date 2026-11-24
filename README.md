# TurtleGuides

Leveling guide addon for Turtle WoW 1.12.1.

## Guide syntax

The parser supports the common RXP-style guide syntax: `.goto`, `.accept`, `.complete`, `.turnin`, `>>` notes, and color tokens. TurtleGuides does not include any RXP guides; the bundled routes are written for this addon. You can use your own guide files, or licensed guides you already have locally, with the same syntax.

## Install

Copy the `TurtleGuides` folder into your `Interface\AddOns` directory.

## Development

Tool versions are pinned in `mise.toml`.

```sh
mise install
mise run check
```

See `docs/ARCHITECTURE.md` for the runtime model and package layout, and `CONTRIBUTING.md` for conventions.

## License

GPL-3.0-only. Copyright (C) 2026 NickW16 and Vittv. See `LICENSE`, `NOTICE`, and `THIRD_PARTY_LICENSES.txt`.
