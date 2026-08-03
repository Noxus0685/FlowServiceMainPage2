from collections import Counter
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
FMX_PATH = ROOT / "frmMRResults.fmx"
PASCAL = (ROOT / "frmMRResults.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")
DPR = (ROOT / "ProjectFornTest.dpr").read_text(encoding="utf-8-sig")


def has_balanced_pascal_quotes(value: str) -> bool:
    """Accept doubled apostrophes while rejecting an unterminated FMX literal."""
    inside = False
    index = 0
    while index < len(value):
        if value[index] == "'":
            if inside and index + 1 < len(value) and value[index + 1] == "'":
                index += 2
                continue
            inside = not inside
        index += 1
    return not inside


def test_results_fmx_is_plain_utf8_text():
    raw = FMX_PATH.read_bytes()
    assert not raw.startswith((b"\xff\xfe", b"\xfe\xff"))
    assert b"\x00" not in raw
    assert raw.count(b"\xef\xbb\xbf") <= 1
    text = raw.decode("utf-8-sig")
    assert text.startswith("object FrameMRResults: TFrameMRResults\n")


def test_results_fmx_structure_and_unique_components():
    text = FMX_PATH.read_text(encoding="utf-8-sig")
    names = re.findall(r"^\s*object\s+(\w+):\s*\w+", text, re.MULTILINE)
    assert len(re.findall(r"^\s*object\s+", text, re.MULTILINE)) == len(
        re.findall(r"^\s*end\s*$", text, re.MULTILINE)
    )
    assert not [name for name, count in Counter(names).items() if count > 1]
    assert names.count("ButtonExportExcel") == 1
    assert text.count("object ButtonExportExcel: TButton") == 1
    assert "SaveDialogXlsx" not in names
    assert "TSaveDialog" not in text
    assert "#1042#1099#1075#1088#1091#1079#1080#1090#1100' '#1074' Excel" in text


def test_all_results_fmx_string_properties_are_terminated():
    text = FMX_PATH.read_text(encoding="utf-8-sig")
    string_properties = {"Text", "Header", "Filter", "FileName", "DefaultExt"}
    for number, line in enumerate(text.splitlines(), 1):
        match = re.match(r"\s*(\w+)\s*=\s*(.*)$", line)
        if match and match.group(1) in string_properties:
            assert has_balanced_pascal_quotes(match.group(2)), f"line {number}: {line}"
    assert "#1074' Excel'" in text
    assert "#1074' Excel\n" not in text


def test_resource_class_and_events_match_pascal_frame():
    text = FMX_PATH.read_text(encoding="utf-8-sig")
    assert "TFrameMRResults = class(TFrame" in PASCAL
    assert "{$R *.fmx}" in PASCAL
    for handler in re.findall(r"^\s*On[A-Z]\w+\s*=\s*(\w+)", text, re.MULTILINE):
        assert f"procedure {handler}(" in PASCAL


def test_save_dialog_is_strictly_local_to_export_handler():
    body = PASCAL.split("procedure TFrameMRResults.ButtonExportExcelClick", 1)[1]
    body = body.split("procedure TFrameMRResults.OnNotify", 1)[0]
    assert "Dialog: TSaveDialog" in body
    assert "Dialog := TSaveDialog.Create(Self)" in body
    assert "try" in body and "finally" in body and "Dialog.Free" in body
    assert "SaveDialogXlsx" not in PASCAL
    interface_uses = PASCAL.split("interface", 1)[1].split("type", 1)[0]
    assert "FMX.Dialogs" in interface_uses
    production_sources = [
        path for pattern in ("*.pas", "*.fmx", "*.dpr", "*.dproj")
        for path in ROOT.glob(pattern)
    ]
    assert not [path.name for path in production_sources
                if b"SaveDialogXlsx" in path.read_bytes()]


def test_fmx_is_not_a_standalone_project_resource():
    lowered = PROJECT.lower()
    assert "frmmrresults.fmx" not in lowered
    assert "<rcitem" not in lowered
    assert "resfiles" not in lowered
    assert '<dccreference include="frmmrresults.pas">' in lowered
    assert "<form>framemrresults</form>" in lowered
    assert "<formtype>fmx</formtype>" in lowered
    assert "<designclass>tframe</designclass>" in lowered
    assert "frmMRResults in 'frmMRResults.pas' {FrameMRResults: TFrame}" in DPR
