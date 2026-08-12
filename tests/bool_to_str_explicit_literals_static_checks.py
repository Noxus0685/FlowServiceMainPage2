from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def bool_to_str_calls(source: str):
    marker = "BoolToStr("
    position = 0
    while (start := source.find(marker, position)) >= 0:
        index = start + len(marker)
        depth = 1
        in_string = False
        while depth and index < len(source):
            character = source[index]
            if character == "'":
                in_string = not in_string
            elif not in_string:
                if character == "(":
                    depth += 1
                elif character == ")":
                    depth -= 1
            index += 1
        yield source[start:index]
        position = index


def test_application_bool_to_str_calls_use_explicit_literals():
    for path in ROOT.glob("*.pas"):
        if path.name == "FmxHelper.pas":
            continue
        source = path.read_text(encoding="utf-8-sig")
        for call in bool_to_str_calls(source):
            assert not call.rstrip().endswith(", True)"), (
                f"{path.name} uses the locale-dependent BoolToStr overload: {call}"
            )
