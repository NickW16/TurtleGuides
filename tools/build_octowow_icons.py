"""Generate src/guides/OctoWowIcons.lua from tools/octowow-icons.csv."""

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV = ROOT / "tools" / "octowow-icons.csv"
OUT = ROOT / "src" / "guides" / "OctoWowIcons.lua"


def lua_string(value):
    return json.dumps(value, ensure_ascii=False)


def icon_path(name):
    return "Interface\\ICONS\\" + name if name else ""


def write_table(lines, key, values, indent="  "):
    lines.append(f"{indent}{key} = {{")
    for id_value in sorted(values):
        lines.append(f"{indent}  [{id_value}] = {lua_string(values[id_value])},")
    lines.append(f"{indent}}},")


def main():
    items, spells, names = {}, {}, {}
    with CSV.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle, delimiter=";"):
            path = icon_path(row["icon"])
            table = items if row["kind"] == "item" else spells
            table[int(row["id"])] = path
            if row["name"] and row["name"] not in names:
                names[row["name"]] = path

    lines = [
        "-- generated from tools/octowow-icons.csv by tools/build_octowow_icons.py",
        "local TG = _G.TurtleGuides",
        "",
        "TG.OctoWowIcons = {",
        '  source = "octowow",',
    ]
    write_table(lines, "items", items)
    write_table(lines, "spells", spells)
    lines.append("  names = {")
    for name in sorted(names):
        lines.append(f"    [{lua_string(name)}] = {lua_string(names[name])},")
    lines.extend(["  },", "}", ""])
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT} with {len(items)} items, {len(spells)} spells, {len(names)} names")


if __name__ == "__main__":
    main()
