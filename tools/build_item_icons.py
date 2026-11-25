"""Generate src/guides/ItemIcons.lua from tools/item-icons.csv and guide text."""

import csv
import glob
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV = ROOT / "tools" / "item-icons.csv"
OUT = ROOT / "src" / "guides" / "ItemIcons.lua"

MANUAL_NAMES = {
    "Tough Wolf Meat": "Interface\\ICONS\\INV_Misc_Food_16",
}


def lua_string(value):
    return json.dumps(value, ensure_ascii=False)


def icon_path(path):
    path = re.sub(r"\.blp$", "", path, flags=re.I)
    return path.replace("/", "\\")


def main():
    paths = {}
    with CSV.open(newline="") as handle:
        for row in csv.DictReader(handle, delimiter=";"):
            paths[row["id"]] = icon_path(row["path"])

    names = {}
    for file in glob.glob(str(ROOT / "src" / "guides" / "*.lua")):
        text = Path(file).read_text(encoding="utf-8", errors="replace")
        for token, name in re.findall(r"\|T(\d+):[^|]*\|t\[([^\[\]\n]+)\]", text):
            name = re.sub(r"\|c%x%x%x%x%x%x%x%x|\|r", "", name).strip()
            if not name or len(name) > 80 or "\n" in name:
                continue
            if token in paths and name not in names:
                names[name] = paths[token]

    lines = [
        "-- generated from tools/item-icons.csv by tools/build_item_icons.py",
        "local TG = _G.TurtleGuides",
        "TG.ItemIcons = {",
    ]
    for token in sorted(paths, key=int):
        lines.append(f"  [{token}] = {lua_string(paths[token])},")
    lines.extend(["}", "", "TG.ItemIconNames = {"])
    names.update(MANUAL_NAMES)
    for name in sorted(names):
        lines.append(f"  [{lua_string(name)}] = {lua_string(names[name])},")
    lines.extend(["}", ""])
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT} with {len(paths)} tokens and {len(names)} names")


if __name__ == "__main__":
    main()
