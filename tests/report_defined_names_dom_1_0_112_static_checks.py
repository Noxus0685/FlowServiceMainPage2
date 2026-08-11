from pathlib import Path

ROOT = Path(__file__).parents[1]
SRC = (ROOT / "uReportTemplates.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def section(start, end):
    return SRC.split(start, 1)[1].split(end, 1)[0]


def test_version_and_dom_helpers():
    assert "APP_VERSION = '1.0.113'" in VERSION
    for helper in ("FindDirectChildNode", "EnsureDefinedNamesNode",
                   "FindDefinedNameNode", "ContainsDefinedName",
                   "ValidateDefinedNameValues", "ValidateDefinedNameDuplicates"):
        assert helper in SRC


def test_update_defined_names_uses_dom_only():
    body = section("procedure UpdateReportDefinedNames", "procedure ValidateSeparatedWorksheetXml")
    assert "LoadXMLData(AWorkbookXml)" in body
    assert "EnsureDefinedNamesNode(WorkbookRoot)" in body
    assert "DefinedNamesNode.AddChild('definedName'" in body
    assert "DefinedNameNode.Attributes['name'] := Pair.Key" in body
    assert "DefinedNameNode.Text := Pair.Value" in body
    assert "SerializedXml := SerializeXmlDocumentUtf8(Document)" in body
    for forbidden in ("TRegEx", "InsertBeforeClosingTag", "InsertBeforeUniqueXmlNode",
                      "XmlEscape", "Delete(AWorkbookXml", "Insert(Node"):
        assert forbidden not in body


def test_obsolete_names_are_removed_through_dom_case_insensitively():
    body = section("procedure RemoveObsoleteReportDefinedNames", "procedure ValidateDefinedNameDuplicates")
    assert "ContainsDefinedName(ADefinedNames, Name)" in body
    assert "DOMNode.removeChild" in body
    assert "ContainsKey(Name)" not in body
    assert "TRegEx" not in body


def test_defined_names_container_is_inserted_before_following_nodes():
    body = section("function EnsureDefinedNamesNode", "function FindDefinedNameNode")
    assert "externalReferences" in body and "calcPr" in body and "extLst" in body
    assert "OwnerDocument.CreateNode('definedNames', ntElement" in body
    assert "DOMNode.insertBefore" in body
    assert "DOMNode.appendChild" in body


def test_values_and_duplicates_are_checked_before_commit():
    body = section("procedure UpdateReportDefinedNames", "procedure ValidateSeparatedWorksheetXml")
    assert body.index("ValidateDefinedNameValues") < body.index("DefinedNameNode.Text := Pair.Value")
    assert body.index("ValidateDefinedNameDuplicates") < body.index("SerializeXmlDocumentUtf8")
    assert body.index("ValidateWorkbookXml(SerializedXml") < body.index("AWorkbookXml := SerializedXml")
    assert "ReportMeta_GeneratedAt" in SRC
