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


def test_column_builder_delegates_atomic_rebuild_to_layout_manager():
    body = procedure_body("BuildColumns")
    assert body.count("TGridLayoutManager.Apply") == 1
    assert "GetDisplayPointKey" in body
    assert "GridMRResults.BeginUpdate" not in body
    assert "GridMRResults.EndUpdate" not in body
    assert "GridMRResults.Model.ContentChanged" not in body
    assert "GridMRResults.Model.InvalidateContentSize" not in body


def test_refresh_rows_cannot_change_column_widths_directly():
    body = procedure_body("RefreshRows")
    assert "TGridLayoutManager.SetRowCount" in body
    assert ".Width :=" not in body
    assert "GridMRResults.BeginUpdate" not in body
    assert "GridMRResults.EndUpdate" not in body


def test_other_dynamic_grid_rebuild_sites_are_explicitly_audited():
    """Dynamic column ownership is centralized in the layout manager."""
    sources = Path(__file__).parents[1].glob("*.pas")
    recreation_sites = {
        path.name
        for path in sources
        if ".Columns[I].Free" in path.read_text(
            encoding="utf-8-sig", errors="ignore"
        )
    }
    assert recreation_sites == set()

    proceed = (Path(__file__).parents[1] / "frmProceed.pas").read_text(
        encoding="utf-8-sig"
    )
    assert "TGridLayoutManager.Apply(GridResults" in proceed

def test_manual_resize_captures_stable_widths_on_mouse_up():
    constructor = TEXT[
        TEXT.index("constructor TFrameMRResults.Create"):
        TEXT.index("destructor TFrameMRResults.Destroy")
    ]
    mouse_up = procedure_body("GridMRResultsMouseUp")
    assert "GridMRResults.OnMouseUp := GridMRResultsMouseUp" in constructor
    assert "TGridLayoutManager.CaptureWidths(FGridLayoutState)" in mouse_up
    assert "if not FRefreshing then" in mouse_up
