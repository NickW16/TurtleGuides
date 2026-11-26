"""Resolve guide item and spell names to octowow icons by name search."""

import concurrent.futures
import csv
import glob
import json
import re
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV = ROOT / "tools" / "octowow-icons.csv"
GAPS = ROOT / "tools" / "octowow-name-gaps.txt"
CACHE = ROOT / "tools" / "octowow-name-cache.json"
SEARCH = "https://octowow.st/db/opensearch.php?search="
WORKERS = 10


def guide_names():
    names = set()
    for file in glob.glob(str(ROOT / "src" / "guides" / "*.lua")):
        text = Path(file).read_text(encoding="utf-8", errors="replace")
        names.update(n.strip() for n in re.findall(r"\|cRXP_(?:LOOT|ITEM)_([^|]+)\|r", text))
        for name in re.findall(r"\|T\d+:[^|]*\|t\[([^\[\]\n]+)\]", text):
            cleaned = re.sub(r"\|c%x{8}|\|r", "", name).strip()
            if cleaned and len(cleaned) <= 80:
                names.add(cleaned)
    return sorted(names)


def get(name):
    request = urllib.request.Request(
        SEARCH + urllib.parse.quote(name),
        headers={"User-Agent": "TurtleGuides icon builder"},
    )
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=25) as response:
                return response.read()
        except (urllib.error.URLError, OSError):
            if attempt == 2:
                return None
    return None


def search_entries(name):
    raw = get(name)
    if not raw:
        return []
    try:
        data = json.loads(raw.decode("utf-8", errors="replace"))
    except ValueError:
        return []
    if not isinstance(data, list) or len(data) < 8:
        return []
    labels, results = data[1], data[-1]
    if not isinstance(labels, list) or not isinstance(results, list):
        return []
    entries = []
    for label, entry in zip(labels, results):
        if isinstance(entry, list) and len(entry) >= 3 and entry[0] in (3, 6) and entry[2]:
            entries.append((str(label), entry[0], entry[1], entry[2]))
    return entries


def resolve(name):
    candidates = [name]
    if name.endswith("s"):
        candidates.append(name[:-1])
    entries = []
    for candidate in candidates:
        entries = search_entries(candidate)
        if entries:
            break
    if not entries:
        return None
    exact = [e for e in entries if e[0].lower().startswith(candidates[-1].lower() + " (")]
    chosen = exact[0] if exact else entries[0]
    kind = "item" if chosen[1] == 3 else "spell"
    return name, kind, chosen[2], chosen[3]


def main():
    known_rows = list(csv.DictReader(CSV.open(newline="", encoding="utf-8"), delimiter=";"))
    known_names = {row["name"] for row in known_rows if row["name"]}
    cache = json.loads(CACHE.read_text(encoding="utf-8")) if CACHE.exists() else {}
    names = [name for name in guide_names() if name not in known_names and name not in cache]
    print(f"{len(names)} names to resolve, {len(cache)} cached", flush=True)

    completed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {pool.submit(resolve, name): name for name in names}
        for future in concurrent.futures.as_completed(futures):
            try:
                result = future.result()
            except Exception:
                result = None
            cache[futures[future]] = result
            completed += 1
            if completed % 100 == 0:
                CACHE.write_text(json.dumps(cache, sort_keys=True), encoding="utf-8")
                print(f"resolved {completed}/{len(names)}", flush=True)
    CACHE.write_text(json.dumps(cache, sort_keys=True), encoding="utf-8")

    for name, result in cache.items():
        if not result:
            continue
        _, kind, entry, icon = result
        if any(row["id"] == str(entry) and row["kind"] == kind for row in known_rows):
            continue
        known_rows.append({"kind": kind, "id": str(entry), "name": name, "icon": icon})

    rows = sorted(known_rows, key=lambda row: (row["kind"], int(row["id"])))
    with CSV.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter=";", lineterminator="\n")
        writer.writerow(["kind", "id", "name", "icon"])
        for row in rows:
            writer.writerow([row["kind"], row["id"], row["name"], row["icon"]])

    gaps = sorted(name for name, result in cache.items() if not result)
    GAPS.write_text("".join(f"{name}\n" for name in gaps), encoding="utf-8")
    found = sum(1 for result in cache.values() if result)
    print(f"resolved {found} names, wrote {CSV} ({len(rows)} total rows)", flush=True)
    print(f"wrote {GAPS} ({len(gaps)} gaps)", flush=True)


if __name__ == "__main__":
    main()
