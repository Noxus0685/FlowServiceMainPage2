import re
from pathlib import Path


SOURCE = Path(__file__).parents[1] / "frmMRResults.pas"
TEXT = SOURCE.read_text(encoding="utf-8-sig")


def procedure_body(name: str) -> str:
    start = re.search(
        rf"procedure\s+TFrameMRResults\.{name}\b.*?;\s*begin\b", TEXT,
        re.IGNORECASE | re.DOTALL,
    )
    assert start, f"procedure {name} not found"
    next_method = re.search(
        r"\n(?:procedure|function)\s+TFrameMRResults\.",
        TEXT[start.end():], re.IGNORECASE,
    )
    assert next_method, f"end of procedure {name} not found"
    return TEXT[start.end():start.end() + next_method.start()]


def test_reload_has_only_one_column_build_path():
    reload_body = procedure_body("ReloadAndUpdate")
    assert reload_body.count("BuildColumns") == 0
    assert reload_body.count("UpdateUI") == 1
    assert procedure_body("UpdateUI").count("BuildColumns") == 1


def test_measurement_notification_is_content_only():
    notify_body = procedure_body("OnNotify")
    assert "BuildColumns" not in notify_body
    assert "UpdateUI" not in notify_body
    for operation in ("BuildRows", "RefreshRows", "GridMRResults.Repaint"):
        assert operation in notify_body


def test_column_builder_has_no_op_structure_guard_and_atomic_rebuild():
    body = procedure_body("BuildColumns")
    guard = body.index("RequiredSignature = FColumnStructureSignature")
    mutation = body.index("GridMRResults.BeginUpdate")
    assert guard < mutation
    assert body.count("GridMRResults.BeginUpdate") == 1
    assert body.count("GridMRResults.EndUpdate") == 1
    assert "GetDisplayPointKey" in body
    assert "Widths.TryGetValue" in body
    assert "GridMRResults.Model.BeginUpdate" in body
    assert "GridMRResults.Model.ContentChanged" in body


def test_other_dynamic_grid_rebuild_sites_are_explicitly_audited():
    """The repository-wide search currently has one other dynamic grid owner.

    Its rebuild is UpdateResultsPointColumns, not a periodic UpdateUI/OnNotify
    path; keeping this assertion makes any new recreation site fail review.
    """
    sources = Path(__file__).parents[1].glob("*.pas")
    recreation_sites = {
        path.name
        for path in sources
        if ".Columns[I].Free" in path.read_text(
            encoding="utf-8-sig", errors="ignore"
        )
    }
    assert recreation_sites == {"frmProceed.pas"}
