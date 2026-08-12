from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "frmProceed.pas"


def method(source: str, start: str, following: str) -> str:
    return source.split(start, 1)[1].split(following, 1)[0]


def test_exact_single_bom_and_valid_utf8():
    data = PATH.read_bytes()
    assert data[:3] == b"\xef\xbb\xbf"
    assert data[3:6] != b"\xef\xbb\xbf"
    data.decode("utf-8-sig")


def test_runtime_result_strings_use_unicode_code_constants():
    source = PATH.read_bytes().decode("utf-8-sig")
    assert "C_RESULT_VALID_TEXT = #1043#1086#1076#1077#1085;" in source
    assert "C_RESULT_INVALID_TEXT = #1053#1077#32#1075#1086#1076#1077#1085;" in source
    assert "C_NO_PROCESSING_DATA_TEXT =" in source
    result = method(source, "function TFrameProceed.BuildResultTextByStatus", "function TFrameProceed.BuildResultComment")
    spillage = method(source, "function TFrameProceed.BuildSpillageStatusText", "function TFrameProceed.BuildSpillageCommentText")
    assert "Result := C_RESULT_VALID_TEXT" in result
    assert "Result := C_RESULT_INVALID_TEXT" in result
    assert "Result := C_RESULT_VALID_TEXT" in spillage
    assert "Result := C_RESULT_INVALID_TEXT" in spillage
    assert "Row.ResultComment := C_NO_PROCESSING_DATA_TEXT;" in source
    assert "Result := 'Годен';" not in source
    assert "Result := 'Не годен';" not in source
    assert "Row.ResultComment := 'Нет данных обработки';" not in source


def test_no_known_mojibake_sequences():
    source = PATH.read_bytes().decode("utf-8-sig")
    for damaged in ("Р“", "РќРµ", "РџСЂ", "РЎС„", "РЎРі", "Р’С‹"):
        assert damaged not in source


def test_debug_checks_unicode_values_before_grid_population():
    source = PATH.read_bytes().decode("utf-8-sig")
    initialize = method(source, "procedure TFrameProceed.Initialize;", "procedure TFrameProceed.DbgProceedTree")
    assert initialize.index("BuildResultTextByStatus(5) = C_RESULT_VALID_TEXT") < initialize.index("InitializeResultsGrid")
    assert "Length(C_RESULT_VALID_TEXT) = 5" in initialize
    assert "Length(C_RESULT_INVALID_TEXT) = 8" in initialize
    assert "Length(C_NO_PROCESSING_DATA_TEXT) = 21" in initialize
    assert all(f"Ord(C_RESULT_VALID_TEXT[{i}]) = {code}" in initialize for i, code in enumerate((1043,1086,1076,1077,1085), 1))


def test_version_1_0_148():
    version = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
    project = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.148'" in version
    assert project.count("FileVersion=1.0.148.0") == 2
    assert project.count("ProductVersion=1.0.148.0") == 2
