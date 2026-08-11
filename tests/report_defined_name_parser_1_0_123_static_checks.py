from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORTS = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
PROJECT = (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")


def parser_source():
    return REPORTS.split(
        "function TryParseDefinedNameReference", 1
    )[1].split("// Проверяет наличие имени", 1)[0]


def test_parser_supports_quoted_and_unquoted_sheet_names():
    parser = parser_source()
    assert "S := Trim(AReference);" in parser
    assert "if S[1] = '''' then" in parser
    assert "I := Pos('!', S);" in parser
    assert "ParsedSheetName := ParsedSheetName + '''';" in parser
    assert "(S[I] <> '!')" in parser
    assert "AReference[1] <> ''''" not in parser
    assert "Copy(AReference, I, 3) <> '''!$'" not in parser


def test_parser_requires_an_absolute_single_cell_address():
    parser = parser_source()
    assert parser.count("(S[I] <> '$')") == 2
    assert "CharInSet(S[I], ['A'..'Z', 'a'..'z'])" in parser
    assert "CharInSet(S[I], ['0'..'9'])" in parser
    assert "if (P = I) or (I <= Length(S)) then Exit;" in parser
    assert "(ParsedRowIndex < 1)" in parser
    assert "(Pos('[', ParsedSheetName) > 0)" in parser


def test_parse_failure_does_not_publish_partial_results():
    parser = parser_source()
    initialization = parser.index("ASheetName := '';")
    success = parser.index("ASheetName := ParsedSheetName;")
    assert initialization < success
    assert "AColumnIndex := 0;" in parser[:success]
    assert "ARowIndex := 0;" in parser[:success]
    assert "Result := True;" in parser[success:]


def test_validation_error_describes_reference_and_expected_formats():
    assert "Reference=\"%s\"." in REPORTS
    assert "Sheet!$A$1 или ''Sheet Name''!$A$1" in REPORTS
    assert "ProtocolManager.AddMessage(pcError" in (
        ROOT / "frmProceed.pas"
    ).read_text(encoding="utf-8-sig")


def test_correct_existing_device_point_references_are_preserved():
    repair = REPORTS.split("procedure RepairPreparedReportDefinedNames", 1)[1]
    assert "TryParseDefinedNameReference(Node.Text" in repair
    assert "SameText(SheetName, '_DevicePoints')" in repair
    assert "(ColumnIndex = ExpectedColumnIndex)" in repair
    assert "(RowIndex = PointIndex + 2) then Continue;" in repair


def test_project_version_is_1_0_123():
    assert "APP_VERSION = '1.0.123'" in VERSION
    assert PROJECT.count("FileVersion=1.0.123.0") == 2
    assert PROJECT.count("ProductVersion=1.0.123.0") == 2
