"""Run SPARQL queries against the PhysicalTherapy ontology.

Default source: knowledge_graph/ontology/PhysicalTherapy.ttl (Turtle).
Fallback: knowledge_graph/ontology/PhysicalTherapy.owx via owlready2
(the .owx has RDF/XML constructs that rdflib's strict parser rejects, but
owlready2 handles OWL/XML correctly).

Usage:
    uv run python scripts/run_sparql.py                       # query on stdin
    uv run python scripts/run_sparql.py <query.rq>            # one query file
    uv run python scripts/run_sparql.py --list                # show queries/
    uv run python scripts/run_sparql.py --all                 # run every .rq
    uv run python scripts/run_sparql.py --prod                # only PROD queries
    uv run python scripts/run_sparql.py --probe-properties    # property coverage
    uv run python scripts/run_sparql.py --ttl=<path> ...      # use custom .ttl
    uv run python scripts/run_sparql.py --owx                 # force .owx via owlready2

The ontology uses a default prefix pointing at http://purl.org/PhysicalTherapy#.
queries.md uses the alias `rehab:`. We pass initNs= to g.query() so both work.
"""
import argparse
import re
import sys
from pathlib import Path

import rdflib
import owlready2

BASE = Path(__file__).resolve().parents[1]
OWX = BASE / "ontology" / "PhysicalTherapy.owx"
TTL = BASE / "ontology" / "PhysicalTherapy.ttl"
QUERY_DIR = BASE / "queries"
QUERY_FIXED_DIR = BASE / "queries-fixed"

DEFAULT_NS = None
_GRAPH: rdflib.Graph | None = None
_SOURCE: str | None = None
_ARGS = None


def detect_default_ns() -> str:
    head = OWX.read_text(encoding="utf-8", errors="replace")[:1024]
    m = re.search(r'xml:base="([^"]+)"', head)
    if not m:
        raise RuntimeError(f"could not detect xml:base in {OWX}")
    return f"{m.group(1)}#"


def load_graph(source: str) -> rdflib.Graph:
    """source: 'ttl' | 'owx' | explicit path."""
    global _GRAPH, DEFAULT_NS, _SOURCE
    DEFAULT_NS = detect_default_ns()

    g = rdflib.Graph()
    g.bind("rehab", rdflib.Namespace(DEFAULT_NS))
    g.bind("rdf", rdflib.RDF)
    g.bind("rdfs", rdflib.RDFS)
    g.bind("owl", rdflib.OWL)
    g.bind("xsd", rdflib.XSD)
    g.bind("", rdflib.Namespace(DEFAULT_NS))

    if source == "owx":
        world = owlready2.World()
        world.get_ontology(OWX.resolve().as_uri()).load()
        for triple in world.as_rdflib_graph():
            g.add(triple)
        _SOURCE = f"owx://{OWX}"
    elif source == "ttl":
        if not TTL.exists():
            raise FileNotFoundError(
                f"{TTL} missing. Generate it with: uv run python scripts/owx_to_ttl.py"
            )
        g.parse(str(TTL), format="turtle")
        _SOURCE = f"ttl://{TTL}"
    else:
        path = Path(source)
        if not path.exists():
            raise FileNotFoundError(source)
        if path.suffix == ".ttl":
            g.parse(str(path), format="turtle")
        elif path.suffix == ".owx":
            world = owlready2.World()
            world.get_ontology(path.resolve().as_uri()).load()
            for triple in world.as_rdflib_graph():
                g.add(triple)
        else:
            g.parse(str(path))
        _SOURCE = f"file://{path}"

    _GRAPH = g
    return g


def init_ns() -> dict:
    return {
        "rehab": rdflib.Namespace(DEFAULT_NS),
        "rdf": rdflib.RDF,
        "rdfs": rdflib.RDFS,
        "owl": rdflib.OWL,
        "xsd": rdflib.XSD,
    }


def list_queries(prod_only: bool = False, fixed: bool = False) -> list[Path]:
    base = QUERY_FIXED_DIR if fixed else QUERY_DIR
    if not base.exists():
        return []
    files = sorted(base.glob("*.rq"))
    if prod_only:
        files = [f for f in files if "prod" in f.name.lower()]
    files = [f for f in files if "uri_lokaler_name" not in f.name]
    return files


def run_one(path: Path, ns: dict) -> tuple[int, str]:
    q = path.read_text(encoding="utf-8")
    g = _GRAPH if _GRAPH is not None else load_graph("ttl")
    try:
        res = list(g.query(q, initNs=ns))
    except Exception as e:
        return -1, f"  ERROR: {type(e).__name__}: {str(e).splitlines()[0][:160]}"
    return len(res), ""


def safe_print(*args, **kwargs):
    """Print that tolerates a closed downstream pipe (e.g. `head`)."""
    try:
        print(*args, **kwargs)
    except BrokenPipeError:
        sys.stderr.close()
        raise SystemExit(0)


def print_table(files: list[Path]) -> None:
    name_w = max((len(f.name) for f in files), default=20)
    print(f"# source: {_SOURCE}\n")
    print(f"{'file'.ljust(name_w)}  {'rows':>6}  status")
    print(f"{'-' * name_w}  {'-' * 6}  ------")
    findings: list[str] = []
    for f in files:
        head = ""
        for line in f.read_text(encoding="utf-8").splitlines()[:5]:
            if line.startswith("# Heading:"):
                head = line[len("# Heading:"):].strip()
        n, err = run_one(f, init_ns())
        rows = "--" if n < 0 else str(n)
        status = "ERROR" if err else "OK"
        print(f"{f.name.ljust(name_w)}  {rows:>6}  {status}{err}  # {head[:50]}")
        text = f.read_text(encoding="utf-8")
        for m in re.finditer(r"rehab:([A-Za-z][A-Za-z0-9_]*)", text):
            name = m.group(1)
            if name[0].isupper():
                continue
            if name == "duration" and "rehab:hasDuration" not in text:
                findings.append(f"{f.name}: uses 'rehab:duration', should be 'rehab:hasDuration'")
    if findings:
        print("\n=== Lint findings (static) ===")
        for s in findings:
            print(" -", s)


def cmd_list(args) -> int:
    fixed = getattr(args, "fixed", False)
    files = list_queries(prod_only=args.prod, fixed=fixed)
    if not files:
        print("no queries found")
        return 1
    label = "queries-fixed/" if fixed else "queries/"
    print(f"# {label}")
    for f in files:
        head = ""
        for line in f.read_text(encoding="utf-8").splitlines()[:5]:
            if line.startswith("# Heading:"):
                head = line[len("# Heading:"):].strip()
        marker = "🟢 " if "prod" in f.name.lower() else "   "
        print(f"{marker}{f.name}\n     {head}")
    return 0


def cmd_run(args) -> int:
    ns = init_ns()
    source = args.ttl or ("owx" if args.owx else "ttl")
    load_graph(source)

    if args.all or args.prod:
        files = list_queries(prod_only=args.prod, fixed=args.fixed)
        print_table(files)
        return 0

    if args.probe_properties:
        probe = """
PREFIX rehab: <http://purl.org/PhysicalTherapy#>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
SELECT ?prop (IF(BOUND(?declared), "EXISTS", "MISSING") AS ?status) WHERE {
  VALUES ?prop {
    rehab:hasInstruction rehab:hasDescription rehab:hasDuration
    rehab:hasCorrectionGuidance rehab:hasCommonMistake rehab:hasBreathingGuidance
    rehab:hasDifficultyLevel rehab:hasContraindication rehab:improves
    rehab:engagedBodyPart rehab:excludesExercise rehab:requiresEquipment
    rehab:stretches rehab:affectsBodyPart rehab:hasStartingPosition
    rehab:hasSeverityLevel rehab:isEngagedBy rehab:executedBy
  }
  OPTIONAL { { ?prop a owl:ObjectProperty } UNION { ?prop a owl:DatatypeProperty } }
  BIND(?prop AS ?declared)
}
ORDER BY ?status ?prop
"""
        for row in _GRAPH.query(probe, initNs=ns):
            safe_print(*row, sep="\t")
        return 0

    if args.query:
        path = Path(args.query)
        n, err = run_one(path, ns)
        if err:
            print(err, file=sys.stderr)
            return 1
        res = _GRAPH.query(path.read_text(encoding="utf-8"), initNs=ns)
        for row in res:
            safe_print(*[str(c) for c in row], sep="\t")
        print(f"# {n} results", file=sys.stderr)
        return 0

    q = sys.stdin.read()
    if not q.strip():
        print("no query on stdin", file=sys.stderr)
        return 2
    res = _GRAPH.query(q, initNs=ns)
    for row in res:
        safe_print(*[str(c) for c in row], sep="\t")
    return 0


def main() -> int:
    global _ARGS
    p = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    p.add_argument("query", nargs="?", help="path to a .rq file")
    p.add_argument("--list", action="store_true", help="list available queries")
    p.add_argument("--all", action="store_true", help="run every query")
    p.add_argument("--prod", action="store_true", help="only PROD queries")
    p.add_argument("--fixed", action="store_true", help="use queries-fixed/ instead of queries/")
    p.add_argument("--owx", action="store_true", help="load via owlready2 from .owx")
    p.add_argument("--ttl", default=None, metavar="PATH",
                   help="path to a .ttl file (overrides default PhysicalTherapy.ttl)")
    p.add_argument("--probe-properties", action="store_true",
                   help="check which object/datatype properties referenced by api/queries.md actually exist")
    _ARGS = p.parse_args()
    if _ARGS.list:
        return cmd_list(_ARGS)
    return cmd_run(_ARGS)


if __name__ == "__main__":
    sys.exit(main())