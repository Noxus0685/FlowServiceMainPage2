from pathlib import Path

SOURCE = Path('uReportTemplates.pas').read_text(encoding='utf-8-sig')
VERSION = Path('uAppVersion.pas').read_text(encoding='utf-8-sig')


def section(start: str, end: str) -> str:
    return SOURCE.split(start, 1)[1].split(end, 1)[0]


def test_version_and_case_insensitive_dictionary_factory():
    assert "APP_VERSION = '1.0.127'" in VERSION
    factory = section('function CreateReportDefinedNames',
                      '// Возвращает понятное русское название поля')
    assert 'TIStringComparer.Ordinal' in factory
    assert SOURCE.count('Names := CreateReportDefinedNames;') == 2


def test_xml_defined_name_index_is_case_insensitive():
    index = section('function BuildDefinedNameIndex',
                    'procedure ValidateDefinedNameValues')
    assert 'TIStringComparer.Ordinal' in index
    assert 'Result.ContainsKey(NameValue)' in index


def test_generated_names_are_validated_before_workbook_xml():
    export = section('procedure ExportTechnicalSheets',
                     '// Добавляет сформированные именованные диапазоны')
    assert export.index('ValidateGeneratedDefinedNames(Names)') < export.index(
        'ReplaceReportDefinedNames(WorkbookXml, Names)')
    replacement = section('function ReplaceReportDefinedNames',
                          'procedure AddUtf8ZipEntry')
    assert 'ValidateDefinedNameDuplicates(NamesNode)' in replacement
    assert 'UserReference=%s; ServiceReference=%s' in replacement


def test_json_column_merge_is_case_insensitive_and_schema_canonical():
    merge = section('function MergeReportColumns', 'function BuildDataColumns')
    assert 'SameText(List[I].TechnicalName, Column.TechnicalName)' in merge
    assert 'List[I] := Column' in merge


def test_delphi_comparers_keep_dictionary_value_types_separate():
    assert 'TStringComparer.OrdinalIgnoreCase' not in SOURCE
    factory = section('function CreateReportDefinedNames',
                      '// Возвращает понятное русское название поля')
    assert 'TDictionary<string, string>.Create(' in factory
    assert 'TDictionary<string, IXMLNode>' not in factory
    index = section('function BuildDefinedNameIndex',
                    'procedure ValidateDefinedNameValues')
    assert 'TDictionary<string, IXMLNode>.Create(' in index
    assert 'Result := CreateReportDefinedNames' not in index
    validator = section('procedure ValidateGeneratedDefinedNames',
                        '// Разбирает абсолютную ссылку')
    assert 'Seen := TDictionary<string, string>.Create(' in validator
    assert validator.count('TIStringComparer.Ordinal') == 1
