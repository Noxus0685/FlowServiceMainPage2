from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmPhotoReading.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmMainTable.fmx").read_text(encoding="utf-8-sig")
EDITOR = (ROOT / "uValueEditColumn.pas").read_text(encoding="utf-8-sig")


def test_photo_form_is_created_without_an_fmx_resource():
    assert (ROOT / "frmPhotoReading.pas").read_bytes().startswith(b"\xef\xbb\xbf")
    constructor = FORM.split("constructor TFormPhotoReading.Create", 1)[1].split(
        "class function TFormPhotoReading.Execute", 1
    )[0]
    assert "inherited CreateNew(AOwner);" in constructor
    assert "{$R *.fmx}" not in FORM


def test_reading_columns_use_designer_safe_standard_classes():
    assert "StringColumnDeviceQuantityBefore1: TStringColumn" in MAIN
    assert "StringColumnDeviceQuantityAfter1: TStringColumn" in MAIN
    assert FMX.count(": TStringColumn") >= 2
    assert "TValueEditColumn" not in MAIN + FMX + EDITOR
    assert "RegisterFmxClasses" not in EDITOR


def test_photo_editor_is_created_programmatically():
    create_editor = MAIN.split(
        "procedure TFrameMainTable.GridDevicesCreateCustomEditor", 1
    )[1].split(
        "procedure TFrameMainTable.DeviceReadingButtonVisible", 1
    )[0]
    assert "Editor := TValueEditCellEditor.Create(nil);" in create_editor
    assert "Editor.Initialize(Column.Index, GridDevices.Row, Value.ToString," in create_editor
    assert "DeviceReadingButtonClick" in create_editor
    assert "TValueEditColumn(Column)" not in create_editor


def test_photo_editor_remains_editable_with_button_on_the_right():
    assert "TValueEditCellEditor = class(TEdit)" in EDITOR
    for setting in (
        "ReadOnly := False;",
        "FPhotoButton.Parent := Self;",
        "FPhotoButton.Align := TAlignLayout.Right;",
        "FPhotoButton.Width := CValueEditButtonWidth;",
        "FPhotoButton.Margins.Rect := TRectF.Empty;",
    ):
        assert setting in EDITOR


def test_button_passes_current_editor_text_to_the_frame():
    click = EDITOR.split("procedure TValueEditCellEditor.ButtonClick", 1)[1].split(
        "procedure TValueEditCellEditor.Initialize", 1
    )[0]
    assert "LCol := FCol;" in click
    assert "LRow := FRow;" in click
    assert "LText := Text;" in click
    assert "LOnButtonClick(Self, LCol, LRow, LText);" in click

    handler = MAIN.split("procedure TFrameMainTable.DeviceReadingButtonClick", 1)[1].split(
        "procedure TFrameMainTable.BeginDeviceReadingEdit", 1
    )[0]
    assert handler.index(
        "GridDevicesSetValue(GridDevices, ACol, ARow, AText);"
    ) < handler.index("TFormPhotoReading.Execute")


def test_photo_dialog_uses_separate_before_and_after_paths():
    assert "PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoBeforePath;" in MAIN
    assert "PhotoPath := FActiveWorkTable.DeviceChannels[Row].PhotoAfterPath;" in MAIN
    assert "ResolveReadingPhotoPath(PhotoPath)" in MAIN
