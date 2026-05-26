def infer_body_parts(text: str):
    """
    Annotation von Körperteilen
    (ersetzbar durch NLP / ML)
    """
    text = text.lower()
    parts = []

    if "schulter" in text:
        parts.append("schulter")
    if "arm" in text:
        parts.append("arm")
    if "nacken" in text:
        parts.append("nacken")
    if "rücken" in text:
        parts.append("ruecken")
    if "knie" in text:
        parts.append("knie")

    return parts