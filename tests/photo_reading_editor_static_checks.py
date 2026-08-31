from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmPhotoReading.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8-sig")


def test_programmatic_photo_form_does_not_load_an_fmx_resource():
    assert (ROOT / "frmPhotoReading.pas").read_bytes().startswith(b"\xef\xbb\xbf")
    constructor = FORM.split("constructor TFormPhotoReading.Create", 1)[1].split(
        "class function TFormPhotoReading.Execute", 1
    )[0]
    assert "inherited CreateNew(AOwner);" in constructor
    assert "inherited Create(AOwner)" not in constructor
    assert "{$R *.fmx}" not in FORM
    for caption in ("Фотофиксация", "Фотография не найдена", "Показание", "Применить", "Отмена"):
        assert caption in FORM


def test_both_reading_columns_use_the_single_neutral_column_class():
    assert "TButtonEditColumn" not in MAIN + FMX
    assert MAIN.count("StringColumnDeviceQuantityBefore1: TValueEditColumn") == 1
    assert MAIN.count("StringColumnDeviceQuantityAfter1: TValueEditColumn") == 1
    assert FMX.count(": TValueEditColumn") == 2


def test_active_and_inactive_buttons_share_the_same_painter():
    assert "procedure DrawValueEditButton" in MAIN
    assert "DrawValueEditButton(Canvas, LocalRect, FPressed);" in MAIN
    assert "DrawValueEditButton(Canvas, ButtonBounds, False);" in MAIN
    assert "FPhotoButton := TValueEditButton.Create(Self);" in MAIN
    assert "FPhotoButton := TButton.Create" not in MAIN


def test_reading_editor_is_editable_and_has_no_internal_gap():
    for setting in (
        "TValueEditCellEditor = class(TStyledControl)",
        "FPhotoButton.Parent := FLayout;",
        "FPhotoButton.Align := TAlignLayout.Left;",
        "FPhotoButton.Width := CValueEditButtonWidth;",
        "FPhotoButton.Margins.Rect := TRectF.Empty;",
        "FValueEdit.Parent := FLayout;",
        "FValueEdit.Align := TAlignLayout.Client;",
        "FValueEdit.Margins.Rect := TRectF.Empty;",
        "FValueEdit.ReadOnly := False;",
    ):
        assert setting in MAIN
    for unsafe_reference in (
        "FPhotoReadingEditor",
        "TButtonEditCellEditor",
        "EditorEnter",
    ):
        assert unsafe_reference not in MAIN

    constructor = MAIN.split("constructor TValueEditCellEditor.Create", 1)[1].split(
        "procedure TValueEditCellEditor.DoEnter", 1
    )[0]
    initialize = MAIN.split("procedure TValueEditCellEditor.Initialize", 1)[1].split(
        "{ TFlowGraphSeries }", 1
    )[0]
    assert "SetFocus" not in constructor
    assert "SelectAll" not in constructor + initialize
    assert "SetFocus" not in initialize


def test_editor_button_is_not_a_child_of_the_styled_edit():
    constructor = MAIN.split("constructor TValueEditCellEditor.Create", 1)[1].split(
        "procedure TValueEditCellEditor.DoEnter", 1
    )[0]
    assert "FLayout.Parent := Self;" in constructor
    assert "FPhotoButton.Parent := FLayout;" in constructor
    assert "FValueEdit.Parent := FLayout;" in constructor
    assert "FPhotoButton.Parent := FValueEdit;" not in constructor

    do_enter = MAIN.split("procedure TValueEditCellEditor.DoEnter", 1)[1].split(
        "procedure TValueEditCellEditor.ButtonClick", 1
    )[0]
    assert do_enter.rstrip().endswith("FValueEdit.SetFocus;\nend;")


def test_single_click_starts_editing_outside_the_exact_button_width():
    assert "ReadOnly := False;" in MAIN
    assert "if LocalMouse.X < TValueEditColumn(Column).ButtonWidth then" in MAIN
    assert "BeginDeviceReadingEdit(Column.Index, Row);" in MAIN
    for setting in (
        "GridDevices.Col := ACol;",
        "GridDevices.Row := ARow;",
        "GridDevices.ReadOnly := False;",
        "GridDevices.SetFocus;",
    ):
        assert setting in MAIN
    begin_edit = MAIN.split(
        "procedure TFrameMainTable.BeginDeviceReadingEdit", 1
    )[1].split("procedure TFrameMainTable.GridDevicesCellClick", 1)[0]
    assert begin_edit.count("GridDevices.EditorMode := True;") == 1
    assert "Model.ShowEditor" not in begin_edit
    assert "SelectAll" not in begin_edit


def test_photo_button_copies_editor_state_before_opening_dialog():
    click = MAIN.split("procedure TValueEditCellEditor.ButtonClick", 1)[1].split(
        "procedure TValueEditCellEditor.Initialize", 1
    )[0]
    assert "LCol := FCol;" in click
    assert "LRow := FRow;" in click
    assert "LText := Text;" in click
    assert "LColumn.ClickButton(LCol, LRow, LText);" in click

    handler = MAIN.split("procedure TFrameMainTable.DeviceReadingButtonClick", 1)[1].split(
        "procedure TFrameMainTable.BeginDeviceReadingEdit", 1
    )[0]
    assert handler.index("GridDevicesSetValue(GridDevices, ACol, ARow, AText);") < handler.index(
        "TFormPhotoReading.Execute"
    )
    assert "SetFocus" not in handler


def test_photo_dialog_uses_the_stored_before_or_after_path():
    assert "PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoBeforePath;" in MAIN
    assert "PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoAfterPath;" in MAIN
    assert "ResolveReadingPhotoPath(PhotoPath)" in MAIN
    assert "misc-fbi-computer-hacker" not in MAIN
