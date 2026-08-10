unit uReportTemplates;

interface

uses
  System.Classes,
  System.JSON,
  System.SysUtils,
  uClasses,
  uDeviceClass;

type
  TReportTemplateService = class
  public const
    MAX_DEVICE_POINTS = 7;
    MAX_POINT_SPILLAGES = 10;
    MAX_COEF_ITEMS = 20;
    DATA_SHEET_NAME = '_Data';
    DATA_TABLE_NAME = 'tblReportData';
  public
    // Возвращает общий каталог XLSX-шаблонов приложения и создаёт его при отсутствии.
    class function TemplatesPath: string; static;
    // Копирует XLSX в каталог шаблонов и добавляет фиксированную таблицу ответа _Data.
    class function ImportTemplate(const ASourceFileName: string): string; static;
    // Формирует динамический JSON из объектов прибора для последующего заполнения _Data.
    class function BuildReportJson(ADevice: TDevice;
      ADeviceType: TDeviceType): TJSONObject; static;
    // Создаёт отчёт из выбранного шаблона, заменяя только содержимое таблицы _Data.
    class procedure ExportTemplate(const ATemplateFileName, AOutputFileName: string;
      ADevice: TDevice; ADeviceType: TDeviceType); static;
  end;

implementation

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.RegularExpressions,
  System.TypInfo,
  System.Zip,
  System.Variants,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Xml.xmldom,
  uOpenXmlXlsx;

type
  PSpillageStopCriteria = ^TSpillageStopCriteria;

const
  CCoefTableTypes: array[0..4] of Integer = (10, 11, 12, 13, 14);
  CWorksheetRelation =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet';
  CTableRelation =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/table';
  CWorksheetContentType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml';
  CTableContentType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.table+xml';
  CSpreadsheetNamespace =
    'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
  CPackageRelationshipsNamespace =
    'http://schemas.openxmlformats.org/package/2006/relationships';

function NormalizeArchivePath(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
  while Result.StartsWith('/') do
    Delete(Result, 1, 1);
end;

function ReadUtf8File(const AFileName: string): string;
begin
  Result := TFile.ReadAllText(AFileName, TEncoding.UTF8);
end;

procedure WriteUtf8File(const AFileName, AText: string);
begin
  ForceDirectories(ExtractFileDir(AFileName));
  TFile.WriteAllText(AFileName, AText, TEncoding.UTF8);
end;

function InsertBeforeClosingTag(const AXml, AClosingTag,
  AFragment: string): string;
var
  P: Integer;
begin
  // Вставляет XML-фрагмент непосредственно перед указанным закрывающим тегом.
  P := AXml.LastIndexOf(AClosingTag);
  if P < 0 then
    raise EInvalidOpException.CreateFmt('В XLSX не найден XML-узел %s',
      [AClosingTag]);
  Result := AXml.Insert(P, AFragment);
end;

function XmlAttribute(const ATag, AName: string): string;
var
  Match: TMatch;
begin
  Match := TRegEx.Match(ATag, '\b' + TRegEx.Escape(AName) +
    '="([^"]*)"', [roIgnoreCase]);
  if Match.Success then
    Result := Match.Groups[1].Value
  else
    Result := '';
end;

function FindDataSheetRelationId(const AWorkbookXml: string): string;
var
  Match: TMatch;
  Tag: string;
begin
  Result := '';
  for Match in TRegEx.Matches(AWorkbookXml, '<sheet\b[^>]*/?>',
    [roIgnoreCase]) do
  begin
    Tag := Match.Value;
    if SameText(XmlAttribute(Tag, 'name'), TReportTemplateService.DATA_SHEET_NAME) then
      Exit(XmlAttribute(Tag, 'r:id'));
  end;
end;

// Находит Target связи книги по её идентификатору rId.
function FindRelationshipTarget(const ARelsRoot: IXMLNode;
  const ARelationId: string): string;
var
  I: Integer;
  Node: IXMLNode;
  IdValue: string;
begin
  Result := '';
  if ARelsRoot = nil then
    raise EArgumentNilException.Create(
      'Не задан корневой узел связей workbook.xml.rels');

  for I := 0 to ARelsRoot.ChildNodes.Count - 1 do
  begin
    Node := ARelsRoot.ChildNodes[I];
    if not SameText(Node.LocalName, 'Relationship') then
      Continue;
    IdValue := VarToStr(Node.Attributes['Id']);
    if SameText(IdValue, ARelationId) then
      Exit(VarToStr(Node.Attributes['Target']));
  end;
end;

function NextSheetId(const AWorkbookXml: string): Integer;
var
  Match: TMatch;
begin
  Result := 0;
  for Match in TRegEx.Matches(AWorkbookXml, 'sheetId="(\d+)"',
    [roIgnoreCase]) do
    Result := Max(Result, StrToIntDef(Match.Groups[1].Value, 0));
  Inc(Result);
end;

// Возвращает следующий свободный rId по узлам Relationship файла workbook.xml.rels.
function NextRelationId(const ARelsRoot: IXMLNode): string;
var
  I, MaxId, IdNumber: Integer;
  Node: IXMLNode;
  IdValue: string;
begin
  if ARelsRoot = nil then
    raise EArgumentNilException.Create(
      'Не задан корневой узел связей workbook.xml.rels');

  MaxId := 0;
  for I := 0 to ARelsRoot.ChildNodes.Count - 1 do
  begin
    Node := ARelsRoot.ChildNodes[I];
    if not SameText(Node.LocalName, 'Relationship') then
      Continue;
    IdValue := VarToStr(Node.Attributes['Id']);
    if SameText(Copy(IdValue, 1, 3), 'rId') and
       TryStrToInt(Copy(IdValue, 4, MaxInt), IdNumber) then
      MaxId := Max(MaxId, IdNumber);
  end;
  Result := 'rId' + (MaxId + 1).ToString;
end;

// Добавляет связь скрытого листа _Data в XML-дерево связей книги.
procedure AddWorksheetRelationship(const ARelsRoot: IXMLNode;
  const ARelationId, ATarget: string);
var
  I: Integer;
  Node: IXMLNode;
begin
  if ARelsRoot = nil then
    raise EArgumentNilException.Create(
      'Не задан корневой узел связей workbook.xml.rels');
  if ARelationId = '' then
    raise EArgumentException.Create('Не задан идентификатор связи листа');
  if ATarget = '' then
    raise EArgumentException.Create('Не задан путь целевого листа');

  for I := 0 to ARelsRoot.ChildNodes.Count - 1 do
  begin
    Node := ARelsRoot.ChildNodes[I];
    if SameText(Node.LocalName, 'Relationship') and
       SameText(VarToStr(Node.Attributes['Id']), ARelationId) then
      raise EInvalidOpException.CreateFmt(
        'Связь workbook.xml.rels с Id %s уже существует', [ARelationId]);
  end;

  Node := ARelsRoot.AddChild('Relationship', ARelsRoot.NamespaceURI);
  Node.Attributes['Id'] := ARelationId;
  Node.Attributes['Type'] := CWorksheetRelation;
  Node.Attributes['Target'] := ATarget;
end;

// Включает автоматический пересчёт книги без ручной работы с индексами совпадения.
function EnsureAutomaticCalculation(const AWorkbookXml: string): string;
const
  CCalcPrPattern = '<calcPr\b[^>]*/>';
  CCalcPrXml =
    '<calcPr calcMode="auto" fullCalcOnLoad="1" forceFullCalc="1"/>';
var
  CalcPrRegex: TRegEx;
begin
  if AWorkbookXml = '' then
    raise EArgumentException.Create('Не задано содержимое xl/workbook.xml');

  CalcPrRegex := TRegEx.Create(CCalcPrPattern, [roIgnoreCase]);
  if CalcPrRegex.IsMatch(AWorkbookXml) then
    Result := CalcPrRegex.Replace(AWorkbookXml, CCalcPrXml, 1)
  else
    Result := InsertBeforeClosingTag(AWorkbookXml, '</workbook>',
      CCalcPrXml);
end;

function WorkbookTemplateReloadHint(const AStage: string): string;
begin
  if SameText(AStage, 'чтение исходного шаблона') then
    Result := ' Исходный XLSX-шаблон уже содержит повреждённый ' +
      'xl/workbook.xml. Удалите его из ReportTemplates и повторно загрузите ' +
      'исходный корректный XLSX.'
  else
    Result := '';
end;

// Проверяет известные признаки повреждения workbook.xml до запуска XML-парсера.
procedure ValidateWorkbookXmlText(const AWorkbookXml, AStage: string;
  ARequireSingleCalcPr: Boolean);
var
  DeclarationEnd: Integer;
  CalcPrCount: Integer;
  XmlBody: string;
begin
  if AWorkbookXml = '' then
    raise EInvalidOpException.CreateFmt(
      'Некорректный xl/workbook.xml на этапе "%s": содержимое пусто.%s',
      [AStage, WorkbookTemplateReloadHint(AStage)]);

  if AWorkbookXml.Contains('<<<calcPr') or
     AWorkbookXml.Contains('<<calcPr') then
    raise EInvalidOpException.CreateFmt(
      'Повреждён xl/workbook.xml на этапе "%s": перед calcPr обнаружен ' +
      'лишний символ "<".%s', [AStage, WorkbookTemplateReloadHint(AStage)]);
  if AWorkbookXml.Contains('/>extLst>') then
    raise EInvalidOpException.CreateFmt(
      'Повреждён xl/workbook.xml на этапе "%s": нарушен открывающий тег ' +
      'extLst.%s', [AStage, WorkbookTemplateReloadHint(AStage)]);
  if AWorkbookXml.Contains('/>xtLst>') then
    raise EInvalidOpException.CreateFmt(
      'Повреждён xl/workbook.xml на этапе "%s": отсутствует начало тега ' +
      'extLst.%s', [AStage, WorkbookTemplateReloadHint(AStage)]);

  if ARequireSingleCalcPr then
  begin
    CalcPrCount := TRegEx.Matches(AWorkbookXml, '<calcPr\b[^>]*>',
      [roIgnoreCase]).Count;
    if CalcPrCount <> 1 then
      raise EInvalidOpException.CreateFmt(
        'Некорректный xl/workbook.xml на этапе "%s": ожидался ровно один ' +
        'узел calcPr, найдено %d.%s',
        [AStage, CalcPrCount, WorkbookTemplateReloadHint(AStage)]);
  end;

  XmlBody := AWorkbookXml.TrimLeft;
  if XmlBody.StartsWith('<?xml') then
  begin
    DeclarationEnd := XmlBody.IndexOf('?>');
    if DeclarationEnd >= 0 then
      Delete(XmlBody, 1, DeclarationEnd + 2);
    XmlBody := XmlBody.TrimLeft;
  end;
  if XmlBody = '' then
    raise EInvalidOpException.CreateFmt(
      'Некорректный xl/workbook.xml на этапе "%s": отсутствует корневой ' +
      'узел workbook.%s', [AStage, WorkbookTemplateReloadHint(AStage)]);
  if not XmlBody.StartsWith('<workbook') then
    raise EInvalidOpException.CreateFmt(
      'Некорректный xl/workbook.xml на этапе "%s": перед корневым узлом ' +
      'workbook обнаружен символ U+%4.4X.%s',
      [AStage, Ord(XmlBody[1]), WorkbookTemplateReloadHint(AStage)]);
end;

// Проверяет XML-структуру workbook.xml и указывает этап обнаружения ошибки.
procedure ValidateWorkbookXml(const AWorkbookXml, AStage: string);
var
  Document: IXMLDocument;
  Root: IXMLNode;
begin
  if AWorkbookXml = '' then
    raise EInvalidOpException.CreateFmt(
      'Некорректный xl/workbook.xml на этапе "%s": содержимое пусто.%s',
      [AStage, WorkbookTemplateReloadHint(AStage)]);

  try
    Document := LoadXMLData(AWorkbookXml);
    Document.Active := True;
  except
    on E: EDOMParseError do
      raise EInvalidOpException.CreateFmt(
        'Некорректный xl/workbook.xml на этапе "%s": %s.%s',
        [AStage, E.Message, WorkbookTemplateReloadHint(AStage)]);
  end;
  Root := Document.DocumentElement;
  if Root = nil then
    raise EInvalidOpException.CreateFmt(
      'В xl/workbook.xml на этапе "%s" отсутствует корневой XML-узел.%s',
      [AStage, WorkbookTemplateReloadHint(AStage)]);
  if not SameText(Root.LocalName, 'workbook') then
    raise EInvalidOpException.CreateFmt(
      'Некорректный корневой узел xl/workbook.xml на этапе "%s": %s.%s',
      [AStage, Root.NodeName, WorkbookTemplateReloadHint(AStage)]);
end;

function WorkbookTargetToArchivePath(const ATarget: string): string;
begin
  Result := NormalizeArchivePath(ATarget);
  if SameText(Copy(Result, 1, 3), 'xl/') then
    Exit;
  Result := 'xl/' + Result;
end;

function JsonValueToText(AValue: TJSONValue): string;
begin
  if (AValue = nil) or (AValue is TJSONNull) then
    Exit('');
  if AValue is TJSONString then
    Exit(TJSONString(AValue).Value);
  if AValue is TJSONBool then
    Exit(BoolToStr(TJSONBool(AValue).AsBoolean, True));
  Result := AValue.Value;
end;

// Преобразует RTTI-значение набора критериев остановки в текст без вызова
// TValue.AsOrdinal.
function SpillageStopCriteriaRttiToString(const AValue: TValue): string;
var
  Criteria: TSpillageStopCriteria;
begin
  if AValue.IsEmpty then
    Exit('');

  if AValue.Kind <> tkSet then
    raise EInvalidCast.CreateFmt('Ожидался RTTI-тип tkSet, получен %s',
      [AValue.TypeInfo.Name]);

  if AValue.TypeInfo <> TypeInfo(TSpillageStopCriteria) then
    raise EInvalidCast.CreateFmt(
      'Неподдерживаемый тип набора при формировании отчёта: %s',
      [AValue.TypeInfo.Name]);

  Criteria := [];
  AValue.ExtractRawData(@Criteria);
  Result := SetToString(PTypeInfo(TypeInfo(TSpillageStopCriteria)),
    CriteriaToInt(Criteria), True);
end;

function RttiValueToJson(const ATypeName: string;
  const AValue: TValue): TJSONValue;
var
  Kind: TTypeKind;
  DateValue: TDateTime;
begin
  Result := nil;
  if AValue.IsEmpty then
    Exit(TJSONNull.Create);

  Kind := AValue.Kind;
  case Kind of
    tkInteger, tkInt64:
      Result := TJSONNumber.Create(AValue.AsInt64);
    tkFloat:
      begin
        DateValue := AValue.AsExtended;
        if SameText(ATypeName, 'TDate') then
          Result := TJSONString.Create(FormatDateTime('yyyy-mm-dd', DateValue))
        else if SameText(ATypeName, 'TDateTime') then
          Result := TJSONString.Create(FormatDateTime('yyyy-mm-dd hh:nn:ss', DateValue))
        else if IsNan(DateValue) or IsInfinite(DateValue) then
          Result := TJSONNull.Create
        else
          Result := TJSONNumber.Create(DateValue);
      end;
    tkEnumeration:
      if AValue.TypeInfo = TypeInfo(Boolean) then
        Result := TJSONBool.Create(AValue.AsBoolean)
      else
        Result := TJSONString.Create(GetEnumName(AValue.TypeInfo,
          AValue.AsOrdinal));
    tkChar, tkWChar, tkString, tkLString, tkWString, tkUString:
      Result := TJSONString.Create(AValue.ToString);
    tkSet:
      Result := TJSONString.Create(
        SpillageStopCriteriaRttiToString(AValue));
  end;
end;

procedure AddScalarMembers(AObject: TObject; ARow: TJSONObject);
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  Prop: TRttiProperty;
  JsonValue: TJSONValue;
begin
  if (AObject = nil) or (ARow = nil) then
    Exit;

  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(AObject.ClassInfo);
    if RttiType = nil then
      Exit;
    for Field in RttiType.GetFields do
      if Field.Visibility in [mvPublic, mvPublished] then
      begin
        JsonValue := RttiValueToJson(Field.FieldType.Name,
          Field.GetValue(AObject));
        if (JsonValue <> nil) and (ARow.GetValue(Field.Name) = nil) then
          ARow.AddPair(Field.Name, JsonValue)
        else
          JsonValue.Free;
      end;

    for Prop in RttiType.GetProperties do
      if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsReadable and
         (ARow.GetValue(Prop.Name) = nil) then
        try
          JsonValue := RttiValueToJson(Prop.PropertyType.Name,
            Prop.GetValue(AObject));
          if JsonValue <> nil then
            ARow.AddPair(Prop.Name, JsonValue);
        except
          { Вычисляемое свойство не должно прерывать формирование отчёта. }
        end;
  finally
    Context.Free;
  end;
end;

function NewObjectRow(const AObjectType: string; AObjectIndex,
  APointIndex, ASpillageIndex, ACoefTableType, ACoefItemIndex: Integer;
  AObject: TObject): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ObjectType', AObjectType);
  Result.AddPair('ObjectIndex', TJSONNumber.Create(AObjectIndex));
  Result.AddPair('PointIndex', TJSONNumber.Create(APointIndex));
  Result.AddPair('SpillageIndex', TJSONNumber.Create(ASpillageIndex));
  Result.AddPair('CoefTableType', TJSONNumber.Create(ACoefTableType));
  Result.AddPair('CoefItemIndex', TJSONNumber.Create(ACoefItemIndex));
  AddScalarMembers(AObject, Result);
end;

function FindCoefTable(ADevice: TDevice; ATableType: Integer): TCalibrCoefTable;
var
  Table: TCalibrCoefTable;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.CalibrCoefTables = nil) then
    Exit;
  for Table in ADevice.CalibrCoefTables do
    if (Table <> nil) and (Table.&Type = ATableType) then
      Exit(Table);
end;

function SpillageBelongsToPoint(ADevice: TDevice; APoint: TDevicePoint;
  ASpillage: TPointSpillage): Boolean;
var
  MatchedPoint: TDevicePoint;
begin
  Result := False;
  if (ADevice = nil) or (APoint = nil) or (ASpillage = nil) then
    Exit;
  MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(ASpillage);
  Result := (MatchedPoint = APoint) or
    ((MatchedPoint <> nil) and (Trim(MatchedPoint.UUID) <> '') and
     SameText(MatchedPoint.UUID, APoint.UUID));
end;

procedure CollectTypeColumns(AClass: TClass; AColumns: TList<string>);
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  Prop: TRttiProperty;
  Kind: TTypeKind;

  procedure AddName(const AName: string);
  var
    Existing: string;
  begin
    for Existing in AColumns do
      if SameText(Existing, AName) then
        Exit;
    AColumns.Add(AName);
  end;

  function IsScalar(AType: TRttiType): Boolean;
  begin
    Kind := AType.TypeKind;
    Result := Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration, tkChar,
      tkWChar, tkString, tkLString, tkWString, tkUString, tkSet];
  end;

begin
  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(AClass.ClassInfo);
    if RttiType = nil then
      Exit;
    for Field in RttiType.GetFields do
      if (Field.Visibility in [mvPublic, mvPublished]) and IsScalar(Field.FieldType) then
        AddName(Field.Name);
    for Prop in RttiType.GetProperties do
      if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsReadable and
         IsScalar(Prop.PropertyType) then
        AddName(Prop.Name);
  finally
    Context.Free;
  end;
end;

function IsServiceColumn(const AName: string): Boolean;
var
  Normalized: string;
begin
  Normalized := LowerCase(AName);
  Result := (Pos('uuid', Normalized) > 0) or
    (Copy(Normalized, Max(1, Length(Normalized) - 1), 2) = 'id') or
    (Pos('status', Normalized) > 0) or
    (Pos('validation', Normalized) > 0) or
    SameText(AName, 'State') or SameText(AName, 'ArchivedData') or
    SameText(AName, 'Description') or SameText(AName, 'RepoName');
end;

function ColumnRank(const AName: string): Integer;
var
  Normalized: string;
begin
  if SameText(AName, 'ObjectType') then Exit(0);
  if SameText(AName, 'ObjectIndex') then Exit(1);
  if SameText(AName, 'PointIndex') then Exit(2);
  if SameText(AName, 'SpillageIndex') then Exit(3);
  if SameText(AName, 'CoefTableType') then Exit(4);
  if SameText(AName, 'CoefItemIndex') then Exit(5);
  if SameText(AName, 'Name') then Exit(10);
  Normalized := LowerCase(AName);
  if (Pos('date', Normalized) > 0) or SameText(AName, 'AppliedAt') then Exit(11);
  if IsServiceColumn(AName) then Exit(1000);
  Result := 100;
end;

function BuildColumns: TList<string>;
begin
  Result := TList<string>.Create;
  Result.Add('ObjectType');
  Result.Add('ObjectIndex');
  Result.Add('PointIndex');
  Result.Add('SpillageIndex');
  Result.Add('CoefTableType');
  Result.Add('CoefItemIndex');
  CollectTypeColumns(TDeviceType, Result);
  CollectTypeColumns(TDevice, Result);
  CollectTypeColumns(TDevicePoint, Result);
  CollectTypeColumns(TPointSpillage, Result);
  CollectTypeColumns(TCalibrCoefTable, Result);
  CollectTypeColumns(TCalibrCoefItem, Result);
  Result.Sort(TComparer<string>.Construct(
    function(const Left, Right: string): Integer
    begin
      Result := ColumnRank(Left) - ColumnRank(Right);
      if Result = 0 then
        Result := CompareText(Left, Right);
    end));
end;

// Возвращает диапазон служебной таблицы по количеству строк и столбцов.
function BuildReportTableRange(ARowCount, AColumnCount: Integer): string;
begin
  if ARowCount < 0 then
    raise EArgumentOutOfRangeException.Create('Количество строк не может быть отрицательным');
  if (AColumnCount <= 0) or (AColumnCount > 16384) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Количество столбцов служебной таблицы вне диапазона Excel: %d',
      [AColumnCount]);
  if ARowCount + 1 > 1048576 then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Количество строк служебной таблицы превышает ограничение Excel: %d',
      [ARowCount + 1]);
  Result := Format('A1:%s%d',
    [ExcelColumnName(AColumnCount), ARowCount + 1]);
end;

// Проверяет имена столбцов служебной Excel-таблицы.
procedure ValidateReportTableColumns(AColumns: TList<string>);
var
  I, J: Integer;
  ColumnName: string;
  SeenNames: TDictionary<string, Integer>;
begin
  if AColumns = nil then
    raise EArgumentNilException.Create('Не задан список столбцов служебной таблицы');
  if AColumns.Count = 0 then
    raise EInvalidOpException.Create('Список столбцов служебной таблицы пуст');
  if AColumns.Count > 16384 then
    raise EInvalidOpException.CreateFmt(
      'Количество столбцов служебной таблицы превышает 16384: %d',
      [AColumns.Count]);

  SeenNames := TDictionary<string, Integer>.Create(
    TStringComparer.OrdinalIgnoreCase);
  try
    for I := 0 to AColumns.Count - 1 do
    begin
      ColumnName := AColumns[I];
      if ColumnName = '' then
        raise EInvalidOpException.CreateFmt('Имя столбца %d пусто', [I + 1]);
      if Length(ColumnName) > 255 then
        raise EInvalidOpException.CreateFmt(
          'Имя столбца %d превышает 255 символов: %s', [I + 1, ColumnName]);
      for J := 1 to Length(ColumnName) do
        if (Ord(ColumnName[J]) < 32) and
           not (ColumnName[J] in [#9, #10, #13]) then
          raise EInvalidOpException.CreateFmt(
            'Имя столбца %d содержит управляющий символ: %s',
            [I + 1, ColumnName]);
      if XmlEscape(ColumnName) = '' then
        raise EInvalidOpException.CreateFmt(
          'Имя столбца %d стало пустым после XML-кодирования: %s',
          [I + 1, ColumnName]);
      if SeenNames.ContainsKey(ColumnName) then
        raise EInvalidOpException.CreateFmt(
          'Имя столбца %d дублируется без учёта регистра: %s',
          [I + 1, ColumnName]);
      SeenNames.Add(ColumnName, I);
    end;
  finally
    SeenNames.Free;
  end;
end;

function BuildWorksheetXml(ARows: TJSONArray; AColumns: TList<string>): string;
var
  RowIndex, ColumnIndex: Integer;
  Row: TJSONObject;
  Value: TJSONValue;
  CellRef, TableRange, TextValue: string;
begin
  TableRange := BuildReportTableRange(ARows.Count, AColumns.Count);
  Result := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ' +
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
    Format('<dimension ref="%s"/>', [TableRange]) +
    '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" ' +
    'activePane="bottomLeft" state="frozen"/></sheetView></sheetViews><sheetData>' +
    '<row r="1">';

  for ColumnIndex := 0 to AColumns.Count - 1 do
  begin
    CellRef := ExcelColumnName(ColumnIndex + 1) + '1';
    Result := Result + Format('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>',
      [CellRef, XmlEscape(AColumns[ColumnIndex])]);
  end;
  Result := Result + '</row>';

  for RowIndex := 0 to ARows.Count - 1 do
  begin
    Row := ARows.Items[RowIndex] as TJSONObject;
    Result := Result + Format('<row r="%d">', [RowIndex + 2]);
    for ColumnIndex := 0 to AColumns.Count - 1 do
    begin
      CellRef := ExcelColumnName(ColumnIndex + 1) + (RowIndex + 2).ToString;
      Value := Row.GetValue(AColumns[ColumnIndex]);
      if (Value = nil) or (Value is TJSONNull) then
        Continue;
      if Value is TJSONNumber then
        Result := Result + Format('<c r="%s"><v>%s</v></c>',
          [CellRef, Value.Value])
      else if Value is TJSONBool then
      begin
        if TJSONBool(Value).AsBoolean then TextValue := '1' else TextValue := '0';
        Result := Result + Format('<c r="%s" t="b"><v>%s</v></c>',
          [CellRef, TextValue]);
      end
      else
      begin
        { inlineStr сохраняет пользовательский текст и не интерпретирует его как формулу. }
        TextValue := JsonValueToText(Value);
        Result := Result + Format('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>',
          [CellRef, XmlEscape(TextValue)]);
      end;
    end;
    Result := Result + '</row>';
  end;

  Result := Result + '</sheetData>' +
    '<tableParts count="1"><tablePart r:id="rId1"/></tableParts></worksheet>';
end;

// Формирует определение Excel-таблицы с уникальным идентификатором и
// согласованным диапазоном.
function BuildTableXml(ARowCount: Integer; AColumns: TList<string>;
  ATableId: Cardinal): string;
var
  I: Integer;
  TableRange: string;
begin
  if ATableId = 0 then
    raise EArgumentOutOfRangeException.Create('Идентификатор таблицы должен быть положительным');
  TableRange := BuildReportTableRange(ARowCount, AColumns.Count);
  Result := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
    Format('<table xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ' +
      'id="%d" name="%s" displayName="%s" ref="%s" totalsRowShown="0">',
      [ATableId, TReportTemplateService.DATA_TABLE_NAME,
       TReportTemplateService.DATA_TABLE_NAME,
       TableRange]) +
    Format('<autoFilter ref="%s"/><tableColumns count="%d">',
      [TableRange, AColumns.Count]);
  for I := 0 to AColumns.Count - 1 do
    Result := Result + Format('<tableColumn id="%d" name="%s"/>',
      [I + 1, XmlEscape(AColumns[I])]);
  Result := Result + '</tableColumns><tableStyleInfo name="TableStyleMedium2" ' +
    'showFirstColumn="0" showLastColumn="0" showRowStripes="1" ' +
    'showColumnStripes="0"/></table>';
end;

// Возвращает существующий идентификатор tblReportData либо следующий свободный
// идентификатор таблицы книги.
function ResolveReportTableId(const ATablesDirectory,
  AReportTableFile: string): Cardinal;
var
  Document: IXMLDocument;
  Root: IXMLNode;
  FileName, NameValue, DisplayNameValue, IdText: string;
  Files: TArray<string>;
  IdValue, MaxTableId, ReportTableId: Cardinal;
  ParsedId: UInt64;
  IdFiles: TDictionary<Cardinal, string>;
  NameFiles: TDictionary<string, string>;
  IsReportFile, IsReportName: Boolean;

  procedure RegisterName(const AName, AFileName: string);
  var
    ExistingFile: string;
  begin
    if AName = '' then
      raise EInvalidOpException.CreateFmt(
        'В определении таблицы %s отсутствует name или displayName', [AFileName]);
    if NameFiles.TryGetValue(AName, ExistingFile) and
       not SameText(ExistingFile, AFileName) then
      raise EInvalidOpException.CreateFmt(
        'Имя Excel-таблицы %s повторяется в файлах %s и %s',
        [AName, ExistingFile, AFileName]);
    if not NameFiles.ContainsKey(AName) then
      NameFiles.Add(AName, AFileName);
  end;

begin
  MaxTableId := 0;
  ReportTableId := 0;
  IdFiles := TDictionary<Cardinal, string>.Create;
  NameFiles := TDictionary<string, string>.Create(TStringComparer.OrdinalIgnoreCase);
  try
    if DirectoryExists(ATablesDirectory) then
      Files := TDirectory.GetFiles(ATablesDirectory, '*.xml')
    else
      SetLength(Files, 0);

    for FileName in Files do
    begin
      try
        Document := LoadXMLData(ReadUtf8File(FileName));
        Document.Active := True;
      except
        on E: EDOMParseError do
          raise EInvalidOpException.CreateFmt(
            'Некорректный XML определения таблицы %s: %s', [FileName, E.Message]);
      end;
      Root := Document.DocumentElement;
      if (Root = nil) or not SameText(Root.LocalName, 'table') then
        raise EInvalidOpException.CreateFmt(
          'Некорректный корневой узел определения таблицы: %s', [FileName]);

      IdText := VarToStr(Root.Attributes['id']);
      if not TryStrToUInt64(IdText, ParsedId) or (ParsedId = 0) or
         (ParsedId > High(Cardinal)) then
        raise EInvalidOpException.CreateFmt(
          'Некорректный идентификатор таблицы в %s: %s', [FileName, IdText]);
      IdValue := Cardinal(ParsedId);
      if IdFiles.ContainsKey(IdValue) then
        raise EInvalidOpException.CreateFmt(
          'Идентификатор таблицы %d повторяется в файлах %s и %s',
          [IdValue, IdFiles[IdValue], FileName]);
      IdFiles.Add(IdValue, FileName);
      if IdValue > MaxTableId then
        MaxTableId := IdValue;

      NameValue := VarToStr(Root.Attributes['name']);
      DisplayNameValue := VarToStr(Root.Attributes['displayName']);
      RegisterName(NameValue, FileName);
      RegisterName(DisplayNameValue, FileName);

      IsReportFile := SameText(ExpandFileName(FileName),
        ExpandFileName(AReportTableFile));
      IsReportName := SameText(NameValue,
        TReportTemplateService.DATA_TABLE_NAME) or
        SameText(DisplayNameValue, TReportTemplateService.DATA_TABLE_NAME);
      if IsReportName and not IsReportFile then
        raise EInvalidOpException.CreateFmt(
          'Имя %s уже используется другой таблицей: %s',
          [TReportTemplateService.DATA_TABLE_NAME, FileName]);
      if IsReportFile then
      begin
        if not SameText(NameValue, TReportTemplateService.DATA_TABLE_NAME) or
           not SameText(DisplayNameValue,
             TReportTemplateService.DATA_TABLE_NAME) then
          raise EInvalidOpException.CreateFmt(
            'Файл служебной таблицы содержит другое имя: %s', [FileName]);
        ReportTableId := IdValue;
      end;
    end;

    if ReportTableId <> 0 then
      Exit(ReportTableId);
    if MaxTableId = High(Cardinal) then
      raise EInvalidOpException.Create(
        'Невозможно назначить идентификатор служебной таблицы: переполнение Cardinal');
    Result := MaxTableId + 1;
  finally
    NameFiles.Free;
    IdFiles.Free;
  end;
end;

// Проверяет XML и обязательную структуру служебной Excel-таблицы.
procedure ValidateReportTableXml(const ATableXml, AExpectedRange: string;
  AExpectedTableId: Cardinal; AColumns: TList<string>);
var
  Document: IXMLDocument;
  Root, Node, AutoFilterNode, TableColumnsNode: IXMLNode;
  I, AutoFilterCount, TableColumnsCount, StyleCount: Integer;
  ParsedValue: UInt64;
  SeenNames: TDictionary<string, Boolean>;
begin
  try
    Document := LoadXMLData(ATableXml);
    Document.Active := True;
  except
    on E: EDOMParseError do
      raise EInvalidOpException.CreateFmt(
        'Некорректный XML служебной таблицы: %s', [E.Message]);
  end;
  Root := Document.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'table') or
     not SameText(Root.NamespaceURI, CSpreadsheetNamespace) then
    raise EInvalidOpException.Create(
      'Некорректный корневой узел XML служебной таблицы');
  if not TryStrToUInt64(VarToStr(Root.Attributes['id']), ParsedValue) or
     (ParsedValue <> AExpectedTableId) then
    raise EInvalidOpException.Create('Некорректный id служебной таблицы');
  if not SameText(VarToStr(Root.Attributes['name']),
     TReportTemplateService.DATA_TABLE_NAME) or
     not SameText(VarToStr(Root.Attributes['displayName']),
       TReportTemplateService.DATA_TABLE_NAME) then
    raise EInvalidOpException.Create('Некорректное имя служебной таблицы');
  if (VarToStr(Root.Attributes['ref']) <> AExpectedRange) or
     (VarToStr(Root.Attributes['totalsRowShown']) <> '0') then
    raise EInvalidOpException.Create('Некорректный диапазон или totalsRowShown таблицы');

  AutoFilterCount := 0;
  TableColumnsCount := 0;
  StyleCount := 0;
  for I := 0 to Root.ChildNodes.Count - 1 do
  begin
    Node := Root.ChildNodes[I];
    if SameText(Node.LocalName, 'autoFilter') then
    begin
      Inc(AutoFilterCount);
      AutoFilterNode := Node;
    end
    else if SameText(Node.LocalName, 'tableColumns') then
    begin
      Inc(TableColumnsCount);
      TableColumnsNode := Node;
    end
    else if SameText(Node.LocalName, 'tableStyleInfo') then
      Inc(StyleCount);
  end;
  if AutoFilterCount <> 1 then
    raise EInvalidOpException.Create('Некорректное количество autoFilter таблицы');
  if VarToStr(AutoFilterNode.Attributes['ref']) <> AExpectedRange then
    raise EInvalidOpException.Create('Некорректный autoFilter служебной таблицы');
  if (TableColumnsCount <> 1) or (TableColumnsNode = nil) then
    raise EInvalidOpException.Create('Отсутствует единственный tableColumns');
  if (VarToStr(TableColumnsNode.Attributes['count']) <> AColumns.Count.ToString) or
     (TableColumnsNode.ChildNodes.Count <> AColumns.Count) then
    raise EInvalidOpException.Create('Некорректное количество столбцов таблицы');
  if StyleCount <> 1 then
    raise EInvalidOpException.Create('В служебной таблице отсутствует tableStyleInfo');

  SeenNames := TDictionary<string, Boolean>.Create(TStringComparer.OrdinalIgnoreCase);
  try
    for I := 0 to AColumns.Count - 1 do
    begin
      Node := TableColumnsNode.ChildNodes[I];
      if not SameText(Node.LocalName, 'tableColumn') or
         (VarToStr(Node.Attributes['id']) <> (I + 1).ToString) or
         (VarToStr(Node.Attributes['name']) <> AColumns[I]) then
        raise EInvalidOpException.CreateFmt(
          'Некорректное определение столбца таблицы %d', [I + 1]);
      if SeenNames.ContainsKey(VarToStr(Node.Attributes['name'])) then
        raise EInvalidOpException.CreateFmt(
          'Повторяющееся имя столбца таблицы: %s',
          [VarToStr(Node.Attributes['name'])]);
      SeenNames.Add(VarToStr(Node.Attributes['name']), True);
    end;
  finally
    SeenNames.Free;
  end;
end;

// Проверяет связь служебного листа с таблицей и отсутствие листового автофильтра.
procedure ValidateReportWorksheetXml(const AWorksheetXml,
  AExpectedRange: string);
var
  Document: IXMLDocument;
  Root, Node, TablePartsNode, TablePartNode: IXMLNode;
  I, DimensionCount, SheetDataCount, AutoFilterCount, TablePartsCount: Integer;
begin
  try
    Document := LoadXMLData(AWorksheetXml);
    Document.Active := True;
  except
    on E: EDOMParseError do
      raise EInvalidOpException.CreateFmt(
        'Некорректный XML служебного листа: %s', [E.Message]);
  end;
  Root := Document.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'worksheet') then
    raise EInvalidOpException.Create('Некорректный корневой узел служебного листа');
  DimensionCount := 0;
  SheetDataCount := 0;
  AutoFilterCount := 0;
  TablePartsCount := 0;
  for I := 0 to Root.ChildNodes.Count - 1 do
  begin
    Node := Root.ChildNodes[I];
    if SameText(Node.LocalName, 'dimension') then
    begin
      Inc(DimensionCount);
      if VarToStr(Node.Attributes['ref']) <> AExpectedRange then
        raise EInvalidOpException.Create('Диапазон dimension не совпадает с таблицей');
    end
    else if SameText(Node.LocalName, 'sheetData') then
      Inc(SheetDataCount)
    else if SameText(Node.LocalName, 'autoFilter') then
      Inc(AutoFilterCount)
    else if SameText(Node.LocalName, 'tableParts') then
    begin
      Inc(TablePartsCount);
      TablePartsNode := Node;
    end;
  end;
  if (DimensionCount <> 1) or (SheetDataCount <> 1) or
     (AutoFilterCount <> 0) or (TablePartsCount <> 1) then
    raise EInvalidOpException.Create('Некорректная структура служебного листа');
  if TablePartsNode = nil then
    raise EInvalidOpException.Create('Отсутствует tableParts служебного листа');
  if (VarToStr(TablePartsNode.Attributes['count']) <> '1') or
     (TablePartsNode.ChildNodes.Count <> 1) then
    raise EInvalidOpException.Create('Некорректный tableParts служебного листа');
  TablePartNode := TablePartsNode.ChildNodes[0];
  if not SameText(TablePartNode.LocalName, 'tablePart') or
     (VarToStr(TablePartNode.Attributes['r:id']) <> 'rId1') then
    raise EInvalidOpException.Create('Некорректная связь tablePart служебного листа');
end;

// Проверяет единственную связь служебного листа с tblReportData.
procedure ValidateReportWorksheetRelsXml(const ARelsXml: string);
var
  Document: IXMLDocument;
  Root, Node, RelationshipNode: IXMLNode;
  I, RelationshipCount: Integer;
begin
  try
    Document := LoadXMLData(ARelsXml);
    Document.Active := True;
  except
    on E: EDOMParseError do
      raise EInvalidOpException.CreateFmt(
        'Некорректный XML связей служебного листа: %s', [E.Message]);
  end;
  Root := Document.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'Relationships') or
     not SameText(Root.NamespaceURI, CPackageRelationshipsNamespace) then
    raise EInvalidOpException.Create(
      'Некорректный корневой узел связей служебного листа');
  RelationshipCount := 0;
  for I := 0 to Root.ChildNodes.Count - 1 do
  begin
    Node := Root.ChildNodes[I];
    if SameText(Node.LocalName, 'Relationship') then
    begin
      Inc(RelationshipCount);
      RelationshipNode := Node;
    end;
  end;
  if RelationshipCount <> 1 then
    raise EInvalidOpException.Create(
      'Некорректное количество связей служебного листа');
  if (VarToStr(RelationshipNode.Attributes['Id']) <> 'rId1') or
     (VarToStr(RelationshipNode.Attributes['Type']) <> CTableRelation) or
     (VarToStr(RelationshipNode.Attributes['Target']) <>
       '../tables/flowServiceReportData.xml') then
    raise EInvalidOpException.Create(
      'Некорректная связь служебного листа с tblReportData');
end;

procedure ValidateZipEntries(AZip: TZipFile);
var
  Name: string;
begin
  if AZip = nil then
    raise EArgumentNilException.Create('Не задан ZIP-архив для проверки');

  for Name in AZip.FileNames do
    if Name.Contains('..') or Name.StartsWith('/') or Name.StartsWith('\') then
      raise EInvalidOpException.CreateFmt('Недопустимый путь внутри XLSX: %s', [Name]);
end;

procedure ZipDirectory(const ASourceDir, AFileName: string);
var
  Zip: TZipFile;
  FileName, ArchiveName: string;
begin
  Zip := TZipFile.Create;
  try
    Zip.Open(AFileName, zmWrite);
    for FileName in TDirectory.GetFiles(ASourceDir, '*',
      TSearchOption.soAllDirectories) do
    begin
      ArchiveName := NormalizeArchivePath(FileName.Substring(
        IncludeTrailingPathDelimiter(ASourceDir).Length));
      Zip.Add(FileName, ArchiveName);
    end;
  finally
    Zip.Free;
  end;
end;

procedure InjectDataSheet(const ASourceFileName, AOutputFileName: string;
  ARoot: TJSONObject);
var
  Zip: TZipFile;
  WorkbookRelsDocument: IXMLDocument;
  WorkbookRelsRoot: IXMLNode;
  TempDir, TempOutput, WorkbookFile, WorkbookRelsFile, ContentTypesFile,
    WorkbookXml, ContentTypesXml, RelationId, Target,
    SheetArchivePath, SheetFile, SheetRelsFile, TableFile,
    SheetFragment, SheetContentTypeFragment, TableContentTypeFragment,
    UpdatedWorkbookXml, UpdatedContentTypesXml, WorksheetXml,
    WorksheetRelsXml, TableXml, ExpectedTableRange: string;
  ReportTableId: Cardinal;
  SheetId: Integer;
  Rows: TJSONArray;
  Columns: TList<string>;
begin
  if not FileExists(ASourceFileName) then
    raise EFileNotFoundException.CreateFmt('Шаблон не найден: %s', [ASourceFileName]);

  TempDir := TPath.Combine(TPath.GetTempPath,
    'FlowServiceReport_' + TPath.GetRandomFileName.Replace('.', ''));
  ForceDirectories(TempDir);
  TempOutput := AOutputFileName + '.tmp';
  try
    Zip := TZipFile.Create;
    try
      Zip.Open(ASourceFileName, zmRead);
      ValidateZipEntries(Zip);
      Zip.ExtractAll(TempDir);
    finally
      Zip.Free;
    end;

    WorkbookFile := TPath.Combine(TempDir, 'xl\workbook.xml');
    WorkbookRelsFile := TPath.Combine(TempDir, 'xl\_rels\workbook.xml.rels');
    ContentTypesFile := TPath.Combine(TempDir, '[Content_Types].xml');
    if not FileExists(WorkbookFile) or not FileExists(WorkbookRelsFile) or
       not FileExists(ContentTypesFile) then
      raise EInvalidOpException.Create('Файл не является корректной книгой XLSX');

    WorkbookXml := ReadUtf8File(WorkbookFile);
    ValidateWorkbookXmlText(WorkbookXml, 'чтение исходного шаблона', False);
    ValidateWorkbookXml(WorkbookXml, 'чтение исходного шаблона');
    ContentTypesXml := ReadUtf8File(ContentTypesFile);
    // Загружает связи книги через XML DOM, не используя повторные присваивания
    // больших UnicodeString.
    WorkbookRelsDocument := LoadXMLDocument(WorkbookRelsFile);
    WorkbookRelsDocument.Active := True;
    WorkbookRelsRoot := WorkbookRelsDocument.DocumentElement;
    if WorkbookRelsRoot = nil then
      raise EInvalidOpException.Create(
        'В workbook.xml.rels отсутствует корневой XML-узел');
    if not SameText(WorkbookRelsRoot.LocalName, 'Relationships') then
      raise EInvalidOpException.CreateFmt(
        'Некорректный корневой узел workbook.xml.rels: %s',
        [WorkbookRelsRoot.NodeName]);

    RelationId := FindDataSheetRelationId(WorkbookXml);
    if RelationId = '' then
    begin
      SheetId := NextSheetId(WorkbookXml);
      RelationId := NextRelationId(WorkbookRelsRoot);
      Target := 'worksheets/flowServiceReportData.xml';

      if RelationId = '' then
        raise EInvalidOpException.Create('Не задан идентификатор связи листа');
      if Target = '' then
        raise EInvalidOpException.Create('Не задан путь целевого листа');

      SheetFragment := Format(
        '<sheet name="%s" sheetId="%d" state="hidden" r:id="%s"/>',
        [TReportTemplateService.DATA_SHEET_NAME, SheetId, RelationId]);
      UpdatedWorkbookXml := InsertBeforeClosingTag(
        WorkbookXml, '</sheets>', SheetFragment);
      ValidateWorkbookXmlText(UpdatedWorkbookXml,
        'добавление листа _Data', False);
      ValidateWorkbookXml(UpdatedWorkbookXml, 'добавление листа _Data');
      WorkbookXml := UpdatedWorkbookXml;

      AddWorksheetRelationship(WorkbookRelsRoot, RelationId, Target);

      SheetContentTypeFragment := Format(
        '<Override PartName="/xl/%s" ContentType="%s"/>',
        [Target, CWorksheetContentType]);
      UpdatedContentTypesXml := InsertBeforeClosingTag(
        ContentTypesXml, '</Types>', SheetContentTypeFragment);
      ContentTypesXml := UpdatedContentTypesXml;
    end
    else
    begin
      Target := FindRelationshipTarget(WorkbookRelsRoot, RelationId);
      if Target = '' then
        raise EInvalidOpException.Create('Не найдена связь листа _Data в XLSX');
    end;
    UpdatedWorkbookXml := EnsureAutomaticCalculation(WorkbookXml);
    ValidateWorkbookXmlText(UpdatedWorkbookXml,
      'EnsureAutomaticCalculation', True);
    ValidateWorkbookXml(UpdatedWorkbookXml, 'EnsureAutomaticCalculation');
    WorkbookXml := UpdatedWorkbookXml;

    SheetArchivePath := WorkbookTargetToArchivePath(Target);
    SheetFile := TPath.Combine(TempDir,
      StringReplace(SheetArchivePath, '/', PathDelim, [rfReplaceAll]));
    SheetRelsFile := TPath.Combine(ExtractFileDir(SheetFile), '_rels\' +
      ExtractFileName(SheetFile) + '.rels');
    TableFile := TPath.Combine(TempDir, 'xl\tables\flowServiceReportData.xml');
    ReportTableId := ResolveReportTableId(
      TPath.Combine(TempDir, 'xl\tables'), TableFile);

    if not ContentTypesXml.Contains(
      'PartName="/xl/tables/flowServiceReportData.xml"') then
    begin
      TableContentTypeFragment := Format(
        '<Override PartName="/xl/tables/flowServiceReportData.xml" ContentType="%s"/>',
        [CTableContentType]);
      UpdatedContentTypesXml := InsertBeforeClosingTag(
        ContentTypesXml, '</Types>', TableContentTypeFragment);
      ContentTypesXml := UpdatedContentTypesXml;
    end;

    // Проверяет структуру JSON до формирования служебного листа _Data.
    if ARoot = nil then
      raise EArgumentNilException.Create(
        'Не заданы данные для формирования листа _Data');

    Rows := ARoot.GetValue<TJSONArray>('Rows');
    if Rows = nil then
      raise EInvalidOpException.Create(
        'В данных отчёта отсутствует массив Rows');
    Columns := BuildColumns;
    try
      ValidateReportTableColumns(Columns);
      ExpectedTableRange := BuildReportTableRange(Rows.Count, Columns.Count);
      WorksheetXml := BuildWorksheetXml(Rows, Columns);
      TableXml := BuildTableXml(Rows.Count, Columns, ReportTableId);
      WorksheetRelsXml :=
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
        Format('<Relationship Id="rId1" Type="%s" Target="../tables/flowServiceReportData.xml"/>',
          [CTableRelation]) + '</Relationships>';
      ValidateReportWorksheetXml(WorksheetXml, ExpectedTableRange);
      ValidateReportTableXml(TableXml, ExpectedTableRange,
        ReportTableId, Columns);
      ValidateReportWorksheetRelsXml(WorksheetRelsXml);

      WriteUtf8File(SheetFile, WorksheetXml);
      WriteUtf8File(SheetRelsFile, WorksheetRelsXml);
      WriteUtf8File(TableFile, TableXml);
      WriteUtf8File(WorkbookFile, WorkbookXml);
      WorkbookRelsDocument.SaveToFile(WorkbookRelsFile);
      WriteUtf8File(ContentTypesFile, ContentTypesXml);
    finally
      Columns.Free;
    end;

    if FileExists(TempOutput) then
      DeleteFile(TempOutput);
    ZipDirectory(TempDir, TempOutput);
    ForceDirectories(ExtractFileDir(AOutputFileName));
    if FileExists(AOutputFileName) and not DeleteFile(AOutputFileName) then
      raise EInOutError.CreateFmt('Не удалось заменить файл %s', [AOutputFileName]);
    if not RenameFile(TempOutput, AOutputFileName) then
      raise EInOutError.CreateFmt('Не удалось сохранить файл %s', [AOutputFileName]);
  finally
    if FileExists(TempOutput) then
      DeleteFile(TempOutput);
    if DirectoryExists(TempDir) then
      TDirectory.Delete(TempDir, True);
  end;
end;

class function TReportTemplateService.TemplatesPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'ReportTemplates');
  ForceDirectories(Result);
end;

class function TReportTemplateService.BuildReportJson(ADevice: TDevice;
  ADeviceType: TDeviceType): TJSONObject;
var
  Rows: TJSONArray;
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  Table: TCalibrCoefTable;
  Item: TCalibrCoefItem;
  PointIndex, SpillageIndex, TableIndex, ItemIndex, ActualSpillageIndex: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('SchemaVersion', TJSONNumber.Create(1));
  Result.AddPair('GeneratedAt', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
  Result.AddPair('MaxDevicePoints', TJSONNumber.Create(MAX_DEVICE_POINTS));
  Result.AddPair('MaxPointSpillages', TJSONNumber.Create(MAX_POINT_SPILLAGES));
  Result.AddPair('MaxCoefItems', TJSONNumber.Create(MAX_COEF_ITEMS));
  Rows := TJSONArray.Create;
  Result.AddPair('Rows', Rows);

  Rows.AddElement(NewObjectRow('DeviceType', 1, 0, 0, 0, 0, ADeviceType));
  Rows.AddElement(NewObjectRow('Device', 1, 0, 0, 0, 0, ADevice));

  for PointIndex := 1 to MAX_DEVICE_POINTS do
  begin
    Point := nil;
    if (ADevice <> nil) and (ADevice.Points <> nil) and
       (PointIndex <= ADevice.Points.Count) then
      Point := ADevice.Points[PointIndex - 1];
    Rows.AddElement(NewObjectRow('DevicePoint', PointIndex, PointIndex,
      0, 0, 0, Point));

    ActualSpillageIndex := 0;
    for SpillageIndex := 1 to MAX_POINT_SPILLAGES do
    begin
      Spillage := nil;
      if (ADevice <> nil) and (ADevice.Spillages <> nil) and (Point <> nil) then
        for ItemIndex := ActualSpillageIndex to ADevice.Spillages.Count - 1 do
          if SpillageBelongsToPoint(ADevice, Point, ADevice.Spillages[ItemIndex]) then
          begin
            Spillage := ADevice.Spillages[ItemIndex];
            ActualSpillageIndex := ItemIndex + 1;
            Break;
          end;
      Rows.AddElement(NewObjectRow('Spillage',
        (PointIndex - 1) * MAX_POINT_SPILLAGES + SpillageIndex,
        PointIndex, SpillageIndex, 0, 0, Spillage));
    end;
  end;

  for TableIndex := Low(CCoefTableTypes) to High(CCoefTableTypes) do
  begin
    Table := FindCoefTable(ADevice, CCoefTableTypes[TableIndex]);
    Rows.AddElement(NewObjectRow('CalibrCoefTable', TableIndex + 1, 0, 0,
      CCoefTableTypes[TableIndex], 0, Table));
    for ItemIndex := 1 to MAX_COEF_ITEMS do
    begin
      Item := nil;
      if (Table <> nil) and (Table.Items <> nil) and
         (ItemIndex <= Table.Items.Count) then
        Item := Table.Items[ItemIndex - 1];
      Rows.AddElement(NewObjectRow('CalibrCoefItem',
        TableIndex * MAX_COEF_ITEMS + ItemIndex, 0, 0,
        CCoefTableTypes[TableIndex], ItemIndex, Item));
    end;
  end;
end;

class function TReportTemplateService.ImportTemplate(
  const ASourceFileName: string): string;
var
  BaseName, Extension: string;
  Suffix: Integer;
  EmptyJson: TJSONObject;
begin
  if not SameText(ExtractFileExt(ASourceFileName), '.xlsx') then
    raise EArgumentException.Create('Поддерживаются только шаблоны XLSX');

  BaseName := TPath.GetFileNameWithoutExtension(ASourceFileName);
  Extension := ExtractFileExt(ASourceFileName);
  Result := TPath.Combine(TemplatesPath, BaseName + Extension);
  Suffix := 2;
  while FileExists(Result) do
  begin
    Result := TPath.Combine(TemplatesPath,
      Format('%s_%d%s', [BaseName, Suffix, Extension]));
    Inc(Suffix);
  end;

  EmptyJson := BuildReportJson(nil, nil);
  try
    InjectDataSheet(ASourceFileName, Result, EmptyJson);
  finally
    EmptyJson.Free;
  end;
end;

class procedure TReportTemplateService.ExportTemplate(
  const ATemplateFileName, AOutputFileName: string; ADevice: TDevice;
  ADeviceType: TDeviceType);
var
  Json: TJSONObject;
begin
  if ADevice = nil then
    raise EArgumentNilException.Create('Для отчёта не выбран прибор');
  Json := BuildReportJson(ADevice, ADeviceType);
  try
    InjectDataSheet(ATemplateFileName, AOutputFileName, Json);
  finally
    Json.Free;
  end;
end;

end.
