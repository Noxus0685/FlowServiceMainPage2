from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BOM = b"\xef\xbb\xbf"
CHANGED_PASCAL_FILES = (
    "frmProceed.pas",
    "frmMainTable.pas",
    "uWorkTable.pas",
    "uDeviceClass.pas",
    "uRepositories.pas",
    "uAppVersion.pas",
)
MOJIBAKE = (
    "Р“РѕРґРµРЅ",
    "РќРµ РіРѕРґРµРЅ",
    "РќРµС‚ РґР°РЅРЅС‹С…",
    "РџРѕРіСЂРµС€РЅРѕСЃС‚СЊ",
)


def has_cyrillic_string_literal(text: str) -> bool:
    literals = re.findall(r"'(?:''|[^'])*'", text)
    return any(re.search(r"[А-Яа-яЁё]", literal) for literal in literals)


def test_frm_proceed_is_utf8_with_bom_and_preserves_russian_literals():
    data = (ROOT / "frmProceed.pas").read_bytes()
    assert data.startswith(BOM)
    source = data.decode("utf-8-sig")
    assert "C_RESULT_VALID_TEXT = #1043#1086#1076#1077#1085;" in source
    assert "C_RESULT_INVALID_TEXT = #1053#1077#32#1075#1086#1076#1077#1085;" in source
    assert "Row.ResultComment := C_NO_PROCESSING_DATA_TEXT;" in source
    for damaged in MOJIBAKE:
        assert damaged not in source


def test_changed_pascal_sources_are_valid_utf8_and_bom_marked_when_needed():
    for relative_name in CHANGED_PASCAL_FILES:
        data = (ROOT / relative_name).read_bytes()
        source = data.decode("utf-8-sig")
        if has_cyrillic_string_literal(source):
            assert data.startswith(BOM), relative_name


def test_version_1_0_147():
    version = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
    project = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.148'" in version
    assert project.count("FileVersion=1.0.148.0") == 2
    assert project.count("ProductVersion=1.0.148.0") == 2
