"""Extract every ```sparql ... ``` block from api/queries.md into
knowledge_graph/queries/<slug>.rq, preserving the surrounding heading as
a leading comment so each file is self-describing.

Usage:
    uv run python scripts/extract_queries.py            # write files
    uv run python scripts/extract_queries.py --print    # also dump to stdout
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_QUERIES = ROOT / "api" / "queries.md"
OUT_DIR = Path(__file__).resolve().parents[1] / "queries"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def slugify(s: str) -> str:
    s = s.lower()
    s = re.sub(r"[^\w\s\-äöü]", "", s)
    s = re.sub(r"\s+", "_", s.strip())
    return s[:80] or "query"


def main() -> int:
    text = API_QUERIES.read_text(encoding="utf-8")

    # Section/heading: track the latest "### ..." before each block so we
    # can use it as a description in the generated file.
    headings: list[tuple[int, str]] = []
    for m in re.finditer(r"^(#{1,4})\s+(.+?)\s*$", text, re.MULTILINE):
        headings.append((m.start(), m.group(2).strip()))

    # Find every ```sparql ... ``` block.
    blocks: list[tuple[int, str, str]] = []
    for m in re.finditer(r"```sparql\n(.*?)```", text, re.DOTALL):
        heading = ""
        for pos, h in headings:
            if pos < m.start():
                heading = h
            else:
                break
        blocks.append((m.start(), heading, m.group(1).rstrip()))

    if not blocks:
        print("no ```sparql``` blocks found", file=sys.stderr)
        return 1

    written = []
    for i, (_pos, heading, query) in enumerate(blocks, 1):
        slug = f"{i:02d}_{slugify(heading)}.rq"
        out = OUT_DIR / slug
        header = (
            f"# Extracted from api/queries.md\n"
            f"# Heading: {heading}\n"
            f"# Source offset in queries.md: {_pos}\n\n"
        )
        out.write_text(header + query + "\n", encoding="utf-8")
        written.append((slug, heading, len(query.splitlines())))

    if "--print" in sys.argv:
        print(f"extracted {len(written)} queries from {API_QUERIES}")
        for slug, heading, lines in written:
            print(f"  {slug:60s} {lines:4d} lines  | {heading}")
    return 0


if __name__ == "__main__":
    sys.exit(main())