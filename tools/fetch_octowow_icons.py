"""Fetch octowow icon names for the item and spell ids used by the guides."""

import concurrent.futures
import csv
import glob
import html
import re
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GUIDE_DIR = ROOT / "src" / "guides"
OUT = ROOT / "tools" / "octowow-icons.csv"
GAPS = ROOT / "tools" / "octowow-gaps.txt"
BASE = "https://octowow.st/db/?{kind}={entry}"

ITEM_ARGS = {
    "collect": 0,
    "itemcount": 0,
    "use": 0,
    "destroy": 0,
    "equip": 1,
    "addquestitem": 1,
    "cooldown": 1,
    "bankdeposit": "all",
    "bankwithdraw": "all",
}
SPELL_TAGS = {"train", "cast", "usespell", "istrained"}


def command_args(text):
    text = text.split("<<", 1)[0].split(">>", 1)[0].split(" --", 1)[0]
    return [part.strip() for part in text.split(",")]


def guide_ids():
    items, spells = set(), set()
    for file in glob.glob(str(GUIDE_DIR / "*.lua")):
        text = Path(file).read_text(encoding="utf-8", errors="replace")
        for line in text.splitlines():
            match = re.match(r"\s*\.(\S+)\s+(.*)$", line)
            if not match:
                continue
            tag = match.group(1).lower()
            args = command_args(match.group(2))
            if tag == "aura":
                spells.update(abs(int(a)) for a in args if a.lstrip("-").isdigit())
                continue
            if tag in SPELL_TAGS:
                spells.update(int(a) for a in args if a.isdigit())
                continue
            index = ITEM_ARGS.get(tag)
            if index is None:
                continue
            chosen = args if index == "all" else args[index : index + 1]
            if tag == "cooldown" and args and args[0].lower() != "item":
                continue
            items.update(int(a) for a in chosen if a.isdigit())
    return items, spells


def fetch_entry(kind, entry):
    url = BASE.format(kind=kind, entry=entry)
    request = urllib.request.Request(url, headers={"User-Agent": "TurtleGuides icon builder"})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=25) as response:
                return response.read().decode("utf-8", errors="replace")
        except (urllib.error.URLError, OSError):
            if attempt == 2:
                return ""
            time.sleep(0.5 * (attempt + 1))
    return ""


def parse_entry(kind, entry, page):
    group = "g_items" if kind == "item" else "g_spells"
    icon = re.search(r"_\[" + str(entry) + r"\]=\{icon:\s*'([^']*)'\}", page)
    name = re.search(
        r"typeId:\s*" + str(entry) + r"\s*,\s*name:\s*'((?:\\'|[^'])*)'", page, re.S
    )
    if not icon:
        return None
    label = html.unescape(name.group(1)) if name else ""
    return label, html.unescape(icon.group(1))


def resolve(job):
    kind, entry = job
    page = fetch_entry(kind, entry)
    if not page:
        return kind, entry, None
    return kind, entry, parse_entry(kind, entry, page)


def main():
    items, spells = guide_ids()
    jobs = [("item", entry) for entry in sorted(items)]
    jobs += [("spell", entry) for entry in sorted(spells)]

    rows, gaps = [], []
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        for kind, entry, result in pool.map(resolve, jobs):
            if result is None:
                gaps.append((kind, entry))
                continue
            label, icon = result
            rows.append((kind, entry, label, icon))

    rows.sort(key=lambda row: (row[0], row[1]))
    gaps.sort(key=lambda gap: (gap[0], gap[1]))

    with OUT.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter=";", lineterminator="\n")
        writer.writerow(["kind", "id", "name", "icon"])
        writer.writerows(rows)

    GAPS.write_text(
        "".join(f"{kind} {entry}\n" for kind, entry in gaps), encoding="utf-8"
    )

    found_items = sum(1 for row in rows if row[0] == "item")
    found_spells = sum(1 for row in rows if row[0] == "spell")
    print(f"scanned {len(jobs)} ids from guides")
    print(f"found {found_items} items and {found_spells} spells with icons")
    print(f"wrote {OUT} and {GAPS} ({len(gaps)} gaps)")
    if gaps:
        preview = ", ".join(f"{kind}:{entry}" for kind, entry in gaps[:20])
        print(f"gap preview: {preview}")


if __name__ == "__main__":
    main()
