"""
Ontologie-gestützte Validierung des JSON-Imports.

Stellt sicher, dass jeder importierte Wert (Kategorie, Body-Part, Schwierigkeit,
Ausgangsstellung, Kontraindikation) einem realen Term in der PhysicalTherapy-
Ontologie entspricht. Bei unbekannten Werten wird ein ValidationError ausgelöst
– kein stilles Übersehen.
"""
from dataclasses import dataclass


class ValidationError(Exception):
    """Wird ausgelöst, wenn das JSON Werte enthält, die nicht in der Ontologie stehen."""


@dataclass
class OntologyIndex:
    """Lookup-Sets, einmalig aus der geladenen owlready2-World gebaut."""
    body_parts: set[str]                # pt:BodyPart-Instanzen (z.B. Knees, Thighs)
    trainings_levels: set[str]          # pt:TrainingsLevel-Instanzen
    conditions: set[str]                # pt:Condition-Instanzen (z.B. KneeIssue)
    positions: set[str]                 # transitive Subklassen von pt:Position
    exercise_subclasses: set[str]       # transitive Subklassen von pt:Exercise


def _transitive_subclasses(root) -> set[str]:
    """Sammelt alle (transitiven) Subklassen einer Klasse, Local-Names als Strings."""
    seen: set[str] = set()
    stack = [root]
    while stack:
        cls = stack.pop()
        name = cls.name
        if name in seen:
            continue
        seen.add(name)
        stack.extend(cls.subclasses())
    return seen


def build_index(world) -> OntologyIndex:
    """
    Liest die geladene owlready2-World einmalig und baut Lookup-Sets.
    Die World muss bereits via `world.get_ontology(...).load()` initialisiert sein.
    """
    pt = world.get_ontology("http://purl.org/PhysicalTherapy#").load()

    return OntologyIndex(
        body_parts={i.name for i in pt.BodyPart.instances()},
        trainings_levels={i.name for i in pt.TrainingsLevel.instances()},
        conditions={i.name for i in pt.Condition.instances()},
        positions=_transitive_subclasses(pt.Position),
        # "Exercise" selbst ausschließen – eine Aktivität MUSS eine Subklasse sein
        exercise_subclasses=_transitive_subclasses(pt.Exercise) - {"Exercise"},
    )


_KNOWN_DIFFICULTIES = {"beginner", "intermediate", "advanced"}


def validate_dataset(data, world) -> None:
    """
    Validiert die komplette JSON-Eingabe gegen die geladene Ontologie.

    - data: dict (einzelnes Item) oder list[dict]
    - world: geladene owlready2.World

    Raises:
        ValidationError: mit allen gefundenen Problemen (gesammelt, nicht first-fail).
    """
    idx = build_index(world)
    items = data if isinstance(data, list) else [data]
    errors: list[str] = []

    for item in items:
        aid = item.get("activity_id", "<no activity_id>")

        cat = item.get("category")
        if cat and cat not in idx.exercise_subclasses:
            errors.append(
                f"{aid}: category '{cat}' ist keine Subklasse von pt:Exercise"
            )

        pos = item.get("starting_position")
        if pos and pos not in idx.positions:
            errors.append(
                f"{aid}: starting_position '{pos}' ist keine Subklasse von pt:Position"
            )

        diff = (item.get("difficulty") or "").lower().strip()
        if diff and diff not in _KNOWN_DIFFICULTIES:
            errors.append(
                f"{aid}: difficulty '{diff}' unbekannt "
                f"(erwartet: {sorted(_KNOWN_DIFFICULTIES)})"
            )

        for bp in item.get("body_parts", []):
            bp_id = bp.get("id", "")
            if bp_id not in idx.body_parts:
                errors.append(
                    f"{aid}: body_part '{bp_id}' ist keine pt:BodyPart-Instanz"
                )

        for c in item.get("contraindications", []):
            if c not in idx.conditions:
                errors.append(
                    f"{aid}: contraindication '{c}' ist keine pt:Condition-Instanz"
                )

    if errors:
        raise ValidationError(
            f"Import abgebrochen – {len(errors)} Validierungsfehler:\n"
            + "\n".join(f"  - {e}" for e in errors)
        )
