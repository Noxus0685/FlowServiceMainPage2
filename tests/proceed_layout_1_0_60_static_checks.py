from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROCEED = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
WORK_TABLE = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")


def body(name: str) -> str:
    start = PROCEED.index(f"procedure TFrameProceed.{name}")
    end = PROCEED.find("\nprocedure TFrameProceed.", start + 1)
    return PROCEED[start:] if end < 0 else PROCEED[start:end]


def test_layout_identity_and_position_are_independent():
    capture = body("CaptureGridColumnsLayout")
    apply = body("ApplyGridColumnsLayout")
    assert "Name := AGrid.Columns[I].Name" in capture
    # Columns[] is already enumerated in visual order; the inherited control
    # Index describes the FMX child tree rather than the dragged display order.
    assert "Position := I" in capture
    assert "Width := AGrid.Columns[I].Width" in capture
    assert "SameText(AGrid.Columns[J].Name, AColumns[I].Name)" in apply
    assert "AColumns[I].Position = TargetIndex" in apply


def test_position_storage_migrates_version_1_0_59_data():
    assert "Position: Integer" in WORK_TABLE
    assert "WriteInteger(Section, 'Position'" in WORK_TABLE
    assert "ReadInteger(Section, 'DisplayIndex', I)" in WORK_TABLE


def test_popup_does_not_mutate_its_control_tree():
    popup = body("PopupMenuGridResultsPopup")
    assert ".Free" not in popup
    assert "TMenuItem.Create" not in popup
    assert "Item.IsChecked := Grid.Columns[J].Visible" in popup
    initialize = body("Initialize")
    assert "BuildGridColumnsMenu(GridDataPoints" in initialize
    assert "BuildGridColumnsMenu(GridResults" in initialize
