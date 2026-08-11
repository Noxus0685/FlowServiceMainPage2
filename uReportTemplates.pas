unit uReportTemplates;

interface

uses
  System.Classes,
  System.JSON,
  System.SysUtils,
  Xml.XMLIntf,
  uClasses,
  uBaseProcedures,
  uDeviceClass,
  uMeterValue;

// Добавляет в JSON-строку полный набор поддерживаемых скалярных полей класса со значениями null.
procedure AddNullScalarMembersForClass(const ARow: TJSONObject; AClass: TClass);
// Гарантирует наличие полной схемы колонок технических листов независимо от наличия данных.
procedure EnsureTechnicalSheetSchema(const ARoot: TJSONObject);

function GetReportFlowUnitName(ADevice: TDevice): string;
function GetReportBaseFlowUnitName(ADevice: TDevice): string;
function ConvertBaseFlowToReportUnits(ADevice: TDevice;
  const AValue: Double): Double;
function ConvertBaseFlowDeltaToReportUnits(ADevice: TDevice;
  const AValue: Double): Double;
function IsBaseFlowReportField(const AObjectType, AFieldName: string): Boolean;
function ConvertReportFieldValue(ADevice: TDevice;
  const AObjectType, AFieldName: string; const AValue: Double): Double;
function IsValidReportNumericValue(const AValue: Double): Boolean;
function IsFlowCoefficientTable(const ATableType: Integer): Boolean;
procedure NormalizeReportRowUnits(ADevice: TDevice;
  const AObjectType: string; ARow: TJSONObject);
// Возвращает числовое значение, округлённое по точности конкретной измеряемой величины прибора.
function RoundReportValueByMeterPrecision(const AValue: Double;
  const AMeterValue: TMeterValue): Double;

type
  TReportColumn = record
    TechnicalName: string;
  end;

  TReportWorksheetLocation = record
    SheetName: string;
    RelationId: string;
    RelationshipTarget: string;
    ArchivePath: string;
  end;

// Возвращает пути ZIP-entry пяти существующих технических листов.
function ResolveTechnicalSheetEntries(const AWorkbookXml: string;
  const AWorkbookRelsXml: string): TArray<TReportWorksheetLocation>;
// Заменяет данные только в существующих технических листах XLSX.
procedure ReplaceTechnicalSheetEntries(const ASourceFileName,
  AOutputFileName: string; const ALocations: TArray<TReportWorksheetLocation>;
  const ASheetXml: TArray<string>);
// Атомарно сохраняет сформированный XLSX и сохраняет резервную копию при ошибке замены.
procedure ReplaceReportOutputFile(const ATemporaryFileName,
  AOutputFileName: string);

type
  TReportTemplateService = class
  public const
    MAX_DEVICE_POINTS = 7;
    MAX_POINT_SPILLAGES = 10;
    MAX_COEF_ITEMS = 20;
    DATA_SHEET_NAME = '_Data';
  public
    // Возвращает общий каталог XLSX-шаблонов приложения и создаёт его при отсутствии.
    class function TemplatesPath: string; static;
    // Добавляет технические листы и именованные диапазоны в новый пользовательский XLSX-шаблон.
    class function PrepareTemplate(const ASourceFileName: string): string; static;
    // Формирует динамический JSON из объектов прибора для последующего заполнения _Data.
    class function BuildReportJson(ADevice: TDevice;
      ADeviceType: TDeviceType; AMeterValueError: TMeterValue = nil):
      TJSONObject; static;
    // Создаёт отчёт, заменяя только пять существующих технических листов.
    class procedure ExportTemplate(const ATemplateFileName, AOutputFileName: string;
      ADevice: TDevice; ADeviceType: TDeviceType); static;
    // Формирует XLSX по заранее созданному неизменяемому JSON-снимку.
    class procedure ExportTemplateFromJson(const ATemplateFileName,
      AOutputFileName, AReportJson: string); static;
  end;

implementation

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.StrUtils,
  System.RegularExpressions,
  System.TypInfo,
  System.Zip,
  System.Variants,
  Xml.XMLDoc,
  Xml.xmldom,
  uOpenXmlXlsx;

type
  PSpillageStopCriteria = ^TSpillageStopCriteria;

const
  CCoefTableTypes: array[0..4] of Integer = (10, 11, 12, 13, 14);
  CWorksheetRelation: string =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet';
  CWorksheetContentType: string =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml';
  CReportTechnicalSheetNames: array[0..4] of string =
    ('_Data', '_DevicePoints', '_Spillages', '_CoefTables', '_Meta');

function NormalizeArchivePath(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
  while Result.StartsWith('/') do
    Delete(Result, 1, 1);
end;

// Возвращает уникальное имя временного XLSX рядом с итоговым файлом.
function BuildTemporaryReportFileName(const AOutputFileName: string): string;
var
  DirectoryName, BaseName: string;
begin
  DirectoryName := ExtractFileDir(AOutputFileName);
  if DirectoryName = '' then DirectoryName := GetCurrentDir;
  BaseName := TPath.GetFileNameWithoutExtension(AOutputFileName);
  repeat
    Result := TPath.Combine(DirectoryName, BaseName + '.' +
      TPath.GetRandomFileName.Replace('.', '') + '.tmp.xlsx');
  until not FileExists(Result);
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

function FindSheetRelationId(const AWorkbookXml, ASheetName: string): string;
var
  Match: TMatch;
  Tag: string;
begin
  Result := '';
  for Match in TRegEx.Matches(AWorkbookXml, '<sheet\b[^>]*/?>',
    [roIgnoreCase]) do
  begin
    Tag := Match.Value;
    if SameText(XmlAttribute(Tag, 'name'), ASheetName) then
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

procedure ValidateWorkbookXml(const AWorkbookXml, AStage: string); forward;

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

// Вставляет XML-фрагмент ровно перед первым подтверждённым структурным узлом.
function InsertBeforeUniqueXmlNode(const AXml, ANodeStart, AFragment,
  AStage: string): string;
var
  FirstPos, SecondPos: Integer;
begin
  FirstPos := AXml.IndexOf(ANodeStart);
  if FirstPos < 0 then
    raise EInvalidOpException.CreateFmt(
      'На этапе "%s" не найден структурный узел %s', [AStage, ANodeStart]);
  SecondPos := AXml.IndexOf(ANodeStart, FirstPos + ANodeStart.Length);
  if SecondPos >= 0 then
    raise EInvalidOpException.CreateFmt(
      'На этапе "%s" найдено несколько узлов %s', [AStage, ANodeStart]);
  Result := AXml;
  Insert(AFragment, Result, FirstPos + 1);
end;

// Включает автоматический пересчёт книги, не изменяя соседние узлы workbook.xml.
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

// Возвращает безопасный диагностический фрагмент XML вокруг позиции ошибки.
function GetXmlErrorContext(const AXml: string;
  const ALine, ALinePos, ARadius: Integer): string;
var
  I, CurrentLine, AbsolutePos, Radius, StartPos, Count: Integer;
begin
  Result := '';
  if (AXml = '') or (ALine < 1) or (ALinePos < 1) then Exit;
  CurrentLine := 1;
  AbsolutePos := 1;
  for I := 1 to Length(AXml) do
  begin
    if CurrentLine = ALine then
    begin
      AbsolutePos := I + ALinePos - 1;
      Break;
    end;
    if AXml[I] = #10 then
      Inc(CurrentLine);
  end;
  AbsolutePos := EnsureRange(AbsolutePos, 1, Length(AXml));
  Radius := EnsureRange(ARadius, 100, 200);
  StartPos := Max(1, AbsolutePos - Radius);
  Count := Min(Length(AXml) - StartPos + 1, Radius * 2 + 1);
  Result := Copy(AXml, StartPos, Count);
  Result := StringReplace(Result, #13#10, ' | ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' | ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' | ', [rfReplaceAll]);
  Insert('[[ERROR]]', Result, AbsolutePos - StartPos + 1);
end;

// Проверяет workbook.xml через MSXML и возвращает точную позицию повреждённого XML-фрагмента.
procedure ValidateWorkbookXml(const AWorkbookXml, AStage: string);
var
  Document: IXMLDocument;
  Root: IXMLNode;
  Context, Url, Reason: string;
  ErrorChar: Integer;
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
    begin
      Context := GetXmlErrorContext(AWorkbookXml, E.Line, E.LinePos, 160);
      Reason := E.Reason;
      if Reason = '' then Reason := E.Message;
      Url := E.URL;
      ErrorChar := 0;
      if (E.LinePos > 0) and (E.SrcText <> '') and
         (E.LinePos <= Length(E.SrcText)) then
        ErrorChar := Ord(E.SrcText[E.LinePos]);
      raise EInvalidOpException.CreateFmt(
        'Некорректный xl/workbook.xml на этапе "%s": %s; Line=%d; ' +
        'LinePos=%d; URL=%s; Char=U+%.4X; Context=%s.%s',
        [AStage, Reason, E.Line, E.LinePos, Url, ErrorChar, Context,
         WorkbookTemplateReloadHint(AStage)]);
    end;
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

// Читает workbook.xml, исправляет только известные повреждения и проверяет результат через XML-парсер.
function ResolveWorkbookTargetArchivePath(const ATarget: string): string;
var
  Source, Part: string;
  Parts, Resolved: TArray<string>;
  I, Count: Integer;
begin
  Source := StringReplace(Trim(ATarget), '\', '/', [rfReplaceAll]);
  if Source = '' then
    raise EArgumentException.Create('Пустой Target связи workbook');
  if Source.StartsWith('/') then Delete(Source, 1, 1)
  else Source := 'xl/' + Source;
  Parts := Source.Split(['/']);
  SetLength(Resolved, Length(Parts)); Count := 0;
  for Part in Parts do
  begin
    if (Part = '') or (Part = '.') then Continue;
    if Part = '..' then
    begin
      if Count = 0 then
        raise EInvalidOpException.CreateFmt('Target выходит за корень XLSX: %s', [ATarget]);
      Dec(Count);
    end
    else
    begin
      if (Pos(':', Part) > 0) or (Part = '.') then
        raise EInvalidOpException.CreateFmt('Недопустимый сегмент Target: %s', [ATarget]);
      Resolved[Count] := Part; Inc(Count);
    end;
  end;
  if Count = 0 then
    raise EInvalidOpException.CreateFmt('Target не указывает на ZIP entry: %s', [ATarget]);
  Result := Resolved[0];
  for I := 1 to Count - 1 do Result := Result + '/' + Resolved[I];
end;

function WorkbookTargetToArchivePath(const ATarget: string): string;
begin
  Result := ResolveWorkbookTargetArchivePath(ATarget);
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

// Формирует безопасное имя именованного диапазона.
function BuildReportDefinedName(const AName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AName) do
    if CharInSet(AName[I], ['A'..'Z', 'a'..'z', '0'..'9', '_', '.']) then
      Result := Result + AName[I]
    else
      Result := Result + '_';
  if (Result = '') or CharInSet(Result[1], ['0'..'9', '.']) then
    Result := '_' + Result;
end;

// Возвращает понятное русское название поля служебного отчёта.
function GetReportFieldCaption(const AObjectType, AFieldName: string): string;
const
  CNames: array[0..39, 0..1] of string = (
    ('Name', 'Название'), ('UUID', 'Уникальный идентификатор'),
    ('SerialNumber', 'Серийный номер'), ('Manufacturer', 'Производитель'),
    ('Owner', 'Владелец'), ('Modification', 'Модификация'),
    ('ReestrNumber', 'Номер в ГРСИ'), ('Category', 'Категория СИ'),
    ('CategoryName', 'Название категории'), ('AccuracyClass', 'Класс точности'),
    ('RegDate', 'Дата регистрации'), ('ValidityDate', 'Действителен до'),
    ('DateOfManufacture', 'Дата изготовления'), ('Documentation', 'Документация'),
    ('IVI', 'Межповерочный интервал'), ('DN', 'Условный диаметр'),
    ('Qmax', 'Максимальный расход'), ('Qmin', 'Минимальный расход'),
    ('Qnom', 'Номинальный расход'), ('Error', 'Погрешность'),
    ('Temp', 'Температура'), ('Coef', 'Коэффициент преобразования'),
    ('DeviceTypeName', 'Название типа прибора'), ('DeviceTypeUUID', 'UUID типа прибора'),
    ('VerificationMethod', 'Методика поверки'), ('ProcedureName', 'Тип процедуры'),
    ('MeasuredDimension', 'Измеряемая величина'), ('Units', 'Единицы измерения'),
    ('OutputType', 'Тип выходного сигнала'), ('Freq', 'Максимальная частота'),
    ('ProtocolName', 'Протокол связи'), ('BaudRate', 'Скорость обмена'),
    ('DeviceAddress', 'Адрес прибора'), ('Repeats', 'Количество измерений'),
    ('RepeatsProtocol', 'Измерений в протоколе'), ('Comment', 'Примечание'),
    ('Enabled', 'Используется'), ('ReportingForm', 'Форма отчётности'),
    ('RangeDynamic', 'Динамический диапазон'), ('Kp', 'Коэффициент Kp'));
var
  I: Integer;
begin
  if SameText(AFieldName, 'Q') then Exit('Расход (Q)');
  if SameText(AFieldName, 'PointError') then
    Exit('Погрешность точки (PointError)');
  if SameText(AFieldName, 'FlowUnitName') then
    Exit('Единица расхода (FlowUnitName)');
  if SameText(AFieldName, 'FlowBaseUnitName') then
    Exit('Базовая единица расхода (FlowBaseUnitName)');
  if SameText(AFieldName, 'FlowUnitIndex') then
    Exit('Индекс единицы расхода (FlowUnitIndex)');
  if SameText(AFieldName, 'QavgEtalon') then
    Exit('Средний расход по эталону (QavgEtalon)');
  if SameText(AFieldName, 'QEtalonStd') then
    Exit('СКО расхода эталона (QEtalonStd)');
  if SameText(AFieldName, 'QStd') then
    Exit('СКО расхода прибора (QStd)');
  Result := AFieldName;
  for I := Low(CNames) to High(CNames) do
    if SameText(CNames[I, 0], AFieldName) then
      Exit(CNames[I, 1]);
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
        JsonValue := nil;
        try
          JsonValue := RttiValueToJson(Field.FieldType.Name,
            Field.GetValue(AObject));
          if (JsonValue <> nil) and (ARow.GetValue(Field.Name) = nil) then
          begin
            ARow.AddPair(Field.Name, JsonValue);
            JsonValue := nil;
          end;
        finally
          JsonValue.Free;
        end;
      end;

    for Prop in RttiType.GetProperties do
      if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsReadable and
         (ARow.GetValue(Prop.Name) = nil) then
      begin
        JsonValue := nil;
        try
          try
            JsonValue := RttiValueToJson(Prop.PropertyType.Name,
              Prop.GetValue(AObject));
            if JsonValue <> nil then
            begin
              ARow.AddPair(Prop.Name, JsonValue);
              JsonValue := nil;
            end;
          finally
            JsonValue.Free;
          end;
        except
          { Вычисляемое свойство не должно прерывать формирование отчёта. }
        end;
      end;
  finally
    Context.Free;
  end;
end;

// Добавляет в JSON-строку полный набор поддерживаемых скалярных полей класса со значениями null.
procedure AddNullScalarMembersForClass(const ARow: TJSONObject; AClass: TClass);
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Field: TRttiField;
  Prop: TRttiProperty;
  Kind: TTypeKind;
begin
  if (ARow = nil) or (AClass = nil) then Exit;
  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(AClass.ClassInfo);
    if RttiType = nil then Exit;
    for Field in RttiType.GetFields do
      if Field.Visibility in [mvPublic, mvPublished] then
      begin
        Kind := Field.FieldType.TypeKind;
        if (Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration, tkChar,
          tkWChar, tkString, tkLString, tkWString, tkUString, tkSet]) and
          (ARow.GetValue(Field.Name) = nil) then
          ARow.AddPair(Field.Name, TJSONNull.Create);
      end;
    for Prop in RttiType.GetProperties do
      if (Prop.Visibility in [mvPublic, mvPublished]) and Prop.IsReadable then
      begin
        Kind := Prop.PropertyType.TypeKind;
        if (Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration, tkChar,
          tkWChar, tkString, tkLString, tkWString, tkUString, tkSet]) and
          (ARow.GetValue(Prop.Name) = nil) then
          ARow.AddPair(Prop.Name, TJSONNull.Create);
      end;
  finally
    Context.Free;
  end;
end;

procedure AddSchemaRow(const ARows: TJSONArray; const AObjectType: string;
  AClass: TClass);
var Row: TJSONObject;
begin
  Row := TJSONObject.Create;
  Row.AddPair('ObjectType', AObjectType);
  Row.AddPair('_SchemaOnly', TJSONBool.Create(True));
  AddNullScalarMembersForClass(Row, AClass);
  ARows.AddElement(Row);
end;

// Гарантирует наличие полной схемы колонок технических листов независимо от наличия данных.
procedure EnsureTechnicalSheetSchema(const ARoot: TJSONObject);
var Rows: TJSONArray; Row: TJSONObject;
begin
  if ARoot = nil then Exit;
  Rows := ARoot.GetValue<TJSONArray>('Rows');
  if Rows = nil then
  begin
    Rows := TJSONArray.Create;
    ARoot.AddPair('Rows', Rows);
  end;
  AddSchemaRow(Rows, 'Device', TDevice);
  AddSchemaRow(Rows, 'DeviceType', TDeviceType);
  AddSchemaRow(Rows, 'DevicePoint', TDevicePoint);
  Row := Rows.Items[Rows.Count - 1] as TJSONObject;
  if Row.GetValue('Q') = nil then Row.AddPair('Q', TJSONNull.Create);
  if Row.GetValue('PointError') = nil then
    Row.AddPair('PointError', TJSONNull.Create);
  AddSchemaRow(Rows, 'Spillage', TPointSpillage);
  AddSchemaRow(Rows, 'CalibrCoefTable', TCalibrCoefTable);
  AddSchemaRow(Rows, 'CalibrCoefItem', TCalibrCoefItem);
  AddSchemaRow(Rows, 'Session', TSessionSpillage);
end;

function GetReportFlowUnitName(ADevice: TDevice): string;
begin
  if ADevice = nil then Exit('');
  Result := ADevice.GetDimensionName;
end;

function GetReportBaseFlowUnitName(ADevice: TDevice): string;
begin
  if ADevice = nil then Exit('');
  if (ADevice.Dimensions = nil) or (ADevice.Dimensions.Count = 0) then
    Exit('-');
  Result := ADevice.Dimensions[0].Name;
end;

function IsValidReportNumericValue(const AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue) and
    (Abs(AValue) < MaxDouble);
end;

function ConvertBaseFlowToReportUnits(ADevice: TDevice;
  const AValue: Double): Double;
begin
  if (ADevice = nil) or not IsValidReportNumericValue(AValue) then
    Exit(AValue);
  Result := ADevice.FromBaseUnits(AValue);
end;

function ConvertBaseFlowDeltaToReportUnits(ADevice: TDevice;
  const AValue: Double): Double;
begin
  if (ADevice = nil) or not IsValidReportNumericValue(AValue) then
    Exit(AValue);
  { Difference conversion deliberately cancels any affine offset.  Flow
    dimensions currently are linear; reciprocal/non-linear dimensions must
    never be added to the delta rule table below. }
  Result := ADevice.FromBaseUnits(AValue) - ADevice.FromBaseUnits(0);
end;

function IsBaseFlowReportField(const AObjectType, AFieldName: string): Boolean;
begin
  Result :=
    (SameText(AObjectType, 'Device') and MatchText(AFieldName,
      ['Qmin', 'Qmax', 'Qnom', 'Qtr', 'Q2tr', 'QFmax'])) or
    (SameText(AObjectType, 'DevicePoint') and SameText(AFieldName, 'Q')) or
    (SameText(AObjectType, 'Spillage') and MatchText(AFieldName,
      ['QavgEtalon', 'EtalonVolumeFlow', 'EtalonMassFlow',
       'DeviceVolumeFlow', 'DeviceMassFlow'])) or
    (SameText(AObjectType, 'CalibrCoefItem') and MatchText(AFieldName,
      ['Arg', 'QFrom', 'QTo', 'RangeArg']));
end;

function ConvertReportFieldValue(ADevice: TDevice;
  const AObjectType, AFieldName: string; const AValue: Double): Double;
begin
  if SameText(AObjectType, 'Spillage') and
     MatchText(AFieldName, ['QEtalonStd', 'QStd']) then
    Exit(ConvertBaseFlowDeltaToReportUnits(ADevice, AValue));
  if IsBaseFlowReportField(AObjectType, AFieldName) then
    Exit(ConvertBaseFlowToReportUnits(ADevice, AValue));
  Result := AValue;
end;

function IsFlowCoefficientTable(const ATableType: Integer): Boolean;
begin
  Result := ATableType = Ord(cctDeviceFlowRateCorrection);
end;

// Возвращает числовое значение, округлённое по точности конкретной измеряемой величины прибора.
function RoundReportValueByMeterPrecision(const AValue: Double;
  const AMeterValue: TMeterValue): Double;
var
  DisplayText: string;
  FormatSettings: TFormatSettings;
begin
  if (AMeterValue = nil) or not IsValidReportNumericValue(AValue) then
    Exit(AValue);
  DisplayText := AMeterValue.GetStrNum(AValue);
  FormatSettings := TFormatSettings.Create;
  if TryStrToFloat(DisplayText, Result, FormatSettings) then Exit;
  FormatSettings.DecimalSeparator := '.';
  DisplayText := StringReplace(DisplayText, ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(DisplayText, Result, FormatSettings) then
    raise EConvertError.CreateFmt(
      'Штатное отображение погрешности не является числом: %s',
      [AMeterValue.GetStrNum(AValue)]);
end;

function ReportErrorDecimals(const AText: string): Integer;
var
  SeparatorPosition, I: Integer;
begin
  Result := -1;
  SeparatorPosition := LastDelimiter(',.', AText);
  if SeparatorPosition = 0 then Exit(0);
  Result := 0;
  for I := SeparatorPosition + 1 to Length(AText) do
    if CharInSet(AText[I], ['0'..'9']) then Inc(Result)
    else begin Result := -1; Exit; end;
end;

procedure ReplaceJsonNumber(const ARow: TJSONObject; const AName: string;
  const AValue: Double);
var Pair: TJSONPair;
begin
  Pair := ARow.RemovePair(AName); Pair.Free;
  ARow.AddPair(AName, TJSONNumber.Create(AValue));
end;

// Фиксирует в JSON исходную и отображаемую погрешность до запуска фоновой выгрузки.
procedure ApplyReportErrorPrecision(const ARows: TJSONArray;
  const AMeterValue: TMeterValue);
var
  I: Integer;
  Row: TJSONObject;
  Pair: TJSONPair;
  Value: TJSONValue;
  RawValue, RoundedValue: Double;
  ErrorText, SourceField: string;
begin
  if (ARows = nil) or (AMeterValue = nil) then Exit;
  for I := 0 to ARows.Count - 1 do
  begin
    Row := ARows.Items[I] as TJSONObject;
    if SameText(Row.GetValue<string>('ObjectType'), 'DevicePoint') and
       (Row.GetValue('PointError') is TJSONNumber) then
      SourceField := 'PointError'
    else if Row.GetValue('Error') is TJSONNumber then
      SourceField := 'Error'
    else
      Continue;
    Value := Row.GetValue(SourceField);
    RawValue := TJSONNumber(Value).AsDouble;
    if not IsValidReportNumericValue(RawValue) then
    begin
      Pair := Row.RemovePair(SourceField); Pair.Free;
      Row.AddPair(SourceField, TJSONNull.Create);
      Continue;
    end;
    ErrorText := AMeterValue.GetStrNum(RawValue);
    RoundedValue := RoundReportValueByMeterPrecision(RawValue, AMeterValue);
    ReplaceJsonNumber(Row, SourceField, RoundedValue);
    ReplaceJsonNumber(Row, 'ErrorRaw', RawValue);
    ReplaceJsonNumber(Row, 'Error', RoundedValue);
    Row.AddPair('ErrorText', ErrorText);
    Row.AddPair('ErrorDecimals', TJSONNumber.Create(
      ReportErrorDecimals(ErrorText)));
  end;
end;

procedure NormalizeReportRowUnits(ADevice: TDevice;
  const AObjectType: string; ARow: TJSONObject);
const
  CFields: array[0..20] of string = ('Qmin', 'Qmax', 'Qnom', 'Qtr',
    'Q2tr', 'QFmax', 'Q', 'QavgEtalon', 'QEtalonStd', 'EtalonVolumeFlow',
    'EtalonMassFlow', 'DeviceVolumeFlow', 'DeviceMassFlow', 'QStd', 'Arg',
    'QFrom', 'QTo', 'RangeArg', 'CommonMinQ', 'CommonMaxQ',
    'MinEtalonDeltaQ');
var
  FieldName: string;
  Value: TJSONValue;
  Pair: TJSONPair;
  Number: Double;
  TableType: Integer;
begin
  if (ADevice = nil) or (ARow = nil) or
     (ARow.GetValue<Boolean>('_FlowUnitsNormalized', False)) then Exit;
  TableType := ARow.GetValue<Integer>('CoefTableType', 0);
  for FieldName in CFields do
  begin
    Value := ARow.GetValue(FieldName);
    if not (Value is TJSONNumber) then Continue;
    Number := TJSONNumber(Value).AsDouble;
    if not IsValidReportNumericValue(Number) then
    begin
      Pair := ARow.RemovePair(FieldName); Pair.Free;
      ARow.AddPair(FieldName, TJSONNull.Create);
      Continue;
    end;
    if SameText(AObjectType, 'CalibrCoefItem') and
       not IsFlowCoefficientTable(TableType) then Continue;
    if IsBaseFlowReportField(AObjectType, FieldName) or
       (SameText(AObjectType, 'Spillage') and
        MatchText(FieldName, ['QEtalonStd', 'QStd'])) then
    begin
      Pair := ARow.RemovePair(FieldName); Pair.Free;
      ARow.AddPair(FieldName, TJSONNumber.Create(ConvertReportFieldValue(
        ADevice, AObjectType, FieldName, Number)));
    end;
  end;
  ARow.AddPair('FlowUnitName', GetReportFlowUnitName(ADevice));
  ARow.AddPair('FlowBaseUnitName', GetReportBaseFlowUnitName(ADevice));
  if (ADevice.Dimensions = nil) or (ADevice.Units < 0) or
     (ADevice.Units >= ADevice.Dimensions.Count) then
    ARow.AddPair('FlowUnitIndex', TJSONNumber.Create(0))
  else
    ARow.AddPair('FlowUnitIndex', TJSONNumber.Create(ADevice.Units));
  ARow.AddPair('_FlowUnitsNormalized', TJSONBool.Create(True));
end;

function NewObjectRow(const AObjectType: string; AObjectIndex,
  APointIndex, ASpillageIndex, ACoefTableType, ACoefItemIndex: Integer;
  AObject: TObject; ADevice: TDevice): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ObjectType', AObjectType);
  Result.AddPair('ObjectIndex', TJSONNumber.Create(AObjectIndex));
  Result.AddPair('PointIndex', TJSONNumber.Create(APointIndex));
  Result.AddPair('SpillageIndex', TJSONNumber.Create(ASpillageIndex));
  Result.AddPair('CoefTableType', TJSONNumber.Create(ACoefTableType));
  Result.AddPair('CoefItemIndex', TJSONNumber.Create(ACoefItemIndex));
  AddScalarMembers(AObject, Result);
  NormalizeReportRowUnits(ADevice, AObjectType, Result);
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

// Добавляет имя столбца без дубликатов без учёта регистра.
procedure AddUniqueColumn(AColumns: TList<string>; const AName: string);
var
  Existing: string;
begin
  for Existing in AColumns do
    if SameText(Existing, AName) then
      Exit;
  AColumns.Add(AName);
end;

// Проверяет принадлежность строки JSON одному из типов служебного листа.
function RowHasObjectType(ARow: TJSONObject;
  const AObjectTypes: array of string): Boolean;
var
  I: Integer;
  ObjectType: string;
  ObjectTypeValue: TJSONValue;
begin
  Result := False;
  if ARow = nil then
    Exit;
  ObjectTypeValue := ARow.GetValue('ObjectType');
  if ObjectTypeValue = nil then
    Exit;
  ObjectType := ObjectTypeValue.Value;
  for I := Low(AObjectTypes) to High(AObjectTypes) do
    if SameText(ObjectType, AObjectTypes[I]) then
      Exit(True);
end;

function IsSchemaRow(const ARow: TJSONObject): Boolean;
begin
  Result := (ARow <> nil) and ARow.GetValue<Boolean>('_SchemaOnly', False);
end;

function JsonRowsToColumns(ARows: TJSONArray;
  const AObjectTypes: array of string; const ASchemaOnly: Boolean): TArray<TReportColumn>;
var List: TList<TReportColumn>; I: Integer; Pair: TJSONPair;
  Row: TJSONObject; Column: TReportColumn; Existing: TReportColumn;
  Found: Boolean;
begin
  List := TList<TReportColumn>.Create;
  try
    for I := 0 to ARows.Count - 1 do
    begin
      Row := ARows.Items[I] as TJSONObject;
      if (IsSchemaRow(Row) <> ASchemaOnly) or
         not RowHasObjectType(Row, AObjectTypes) then Continue;
      for Pair in Row do
      begin
        if SameText(Pair.JsonString.Value, '_SchemaOnly') then Continue;
        Found := False;
        for Existing in List do
          if SameText(Existing.TechnicalName, Pair.JsonString.Value) then
          begin Found := True; Break; end;
        if not Found then
        begin
          Column.TechnicalName := Pair.JsonString.Value;
          List.Add(Column);
        end;
      end;
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

// Объединяет схему и фактические поля без дублирования и с сохранением порядка схемы.
function MergeReportColumns(const ASchemaColumns,
  AActualColumns: TArray<TReportColumn>): TArray<TReportColumn>;
var List: TList<TReportColumn>; Column, Existing: TReportColumn; Found: Boolean;
begin
  List := TList<TReportColumn>.Create;
  try
    for Column in ASchemaColumns do List.Add(Column);
    for Column in AActualColumns do
    begin
      Found := False;
      for Existing in List do
        if SameText(Existing.TechnicalName, Column.TechnicalName) then
        begin Found := True; Break; end;
      if not Found then List.Add(Column);
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function BuildDataColumns(ARows: TJSONArray): TArray<TReportColumn>;
begin
  Result := MergeReportColumns(
    JsonRowsToColumns(ARows, ['DeviceType', 'Device', 'Session'], False),
    JsonRowsToColumns(ARows, ['DeviceType', 'Device', 'Session'], True));
end;

function BuildDevicePointsColumns(ARows: TJSONArray): TArray<TReportColumn>;
begin
  Result := MergeReportColumns(
    JsonRowsToColumns(ARows, ['DevicePoint'], False),
    JsonRowsToColumns(ARows, ['DevicePoint'], True));
end;

function BuildSpillageColumns(ARows: TJSONArray): TArray<TReportColumn>;
begin
  Result := MergeReportColumns(JsonRowsToColumns(ARows, ['Spillage'], False),
    JsonRowsToColumns(ARows, ['Spillage'], True));
end;

function BuildCalibrCoefTableColumns(ARows: TJSONArray): TArray<TReportColumn>;
begin
  Result := MergeReportColumns(JsonRowsToColumns(ARows,
    ['CalibrCoefTable', 'CalibrCoefItem'], False), JsonRowsToColumns(ARows,
    ['CalibrCoefTable', 'CalibrCoefItem'], True));
end;

function BuildMetaColumns(ARoot: TJSONObject): TArray<TReportColumn>;
var Pair: TJSONPair; List: TList<TReportColumn>; Column: TReportColumn;
begin
  List := TList<TReportColumn>.Create;
  try
    for Pair in ARoot do
      if not SameText(Pair.JsonString.Value, 'Rows') then
      begin
        Column.TechnicalName := Pair.JsonString.Value;
        List.Add(Column);
      end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

// Возвращает актуальный порядок полей технического листа, используемый для заголовков, значений и definedName.
function BuildTechnicalSheetColumns(const ASheetName: string;
  ARows: TJSONArray): TArray<TReportColumn>;
begin
  if SameText(ASheetName, '_DevicePoints') then
    Result := BuildDevicePointsColumns(ARows)
  else if SameText(ASheetName, '_Spillages') then
    Result := BuildSpillageColumns(ARows)
  else if SameText(ASheetName, '_CoefTables') then
    Result := BuildCalibrCoefTableColumns(ARows)
  else
    raise EArgumentException.CreateFmt('Неизвестный технический лист: %s', [ASheetName]);
end;

// Возвращает устойчивый набор столбцов канонической схемы.
function BuildSeparatedColumns(ARows: TJSONArray;
  const AObjectTypes: array of string): TList<string>;
var Columns: TArray<TReportColumn>; SheetName: string;
  Column: TReportColumn;
begin
  if (Length(AObjectTypes) = 1) and SameText(AObjectTypes[0], 'DevicePoint') then
    SheetName := '_DevicePoints'
  else if (Length(AObjectTypes) = 1) and SameText(AObjectTypes[0], 'Spillage') then
    SheetName := '_Spillages'
  else
    SheetName := '_CoefTables';
  Columns := BuildTechnicalSheetColumns(SheetName, ARows);
  Result := TList<string>.Create;
  for Column in Columns do AddUniqueColumn(Result, Column.TechnicalName);
end;

// Возвращает ширину столбца по содержимому с ограничением для читаемости.
function ReportColumnWidth(const AName: string; ARows: TJSONArray;
  const AObjectTypes: array of string): Integer;
var
  I: Integer;
  Row: TJSONObject;
  Value: TJSONValue;
begin
  Result := Max(10, Length(AName) + 2);
  for I := 0 to ARows.Count - 1 do
  begin
    Row := ARows.Items[I] as TJSONObject;
    if not RowHasObjectType(Row, AObjectTypes) then
      Continue;
    Value := Row.GetValue(AName);
    if Value <> nil then
      Result := Max(Result, Length(JsonValueToText(Value)) + 2);
  end;
  Result := Min(Result, 40);
end;

// Формирует читаемый XML отдельного служебного листа по выбранным типам JSON.
function SeparatedRowDefinedName(ARow: TJSONObject;
  const AFieldName: string): string;
var
  ObjectType, TableTypeName: string;
  PointIndex, SpillageIndex, CoefType, ItemIndex: Integer;
begin
  ObjectType := ARow.GetValue<string>('ObjectType');
  PointIndex := ARow.GetValue<Integer>('PointIndex');
  SpillageIndex := ARow.GetValue<Integer>('SpillageIndex');
  CoefType := ARow.GetValue<Integer>('CoefTableType');
  ItemIndex := ARow.GetValue<Integer>('CoefItemIndex');
  if SameText(ObjectType, 'DevicePoint') then
    Result := Format('DevicePoints_%.2d_%s', [PointIndex, AFieldName])
  else if SameText(ObjectType, 'Spillage') then
    Result := Format('DevicePoints_%.2d_Spillages_%.2d_%s',
      [PointIndex, SpillageIndex, AFieldName])
  else if SameText(ObjectType, 'CalibrCoefTable') or
          SameText(ObjectType, 'CalibrCoefItem') then
  begin
    case CoefType of
      10: TableTypeName := 'cctReference';
      11: TableTypeName := 'cctLinear';
      12: TableTypeName := 'cctPiecewiseLinear';
      13: TableTypeName := 'cctPolynomial';
      14: TableTypeName := 'cctFlowCorrection';
    else
      TableTypeName := 'Type' + CoefType.ToString;
    end;
    if SameText(ObjectType, 'CalibrCoefItem') then
      Result := Format('CalibrCoefTables_%s_Items_%.2d_%s',
        [TableTypeName, ItemIndex, AFieldName])
    else
      Result := Format('CalibrCoefTables_%s_%s', [TableTypeName, AFieldName]);
  end
  else
    Result := ObjectType + '_' + AFieldName;
  Result := BuildReportDefinedName(Result);
end;

procedure RegisterPreparedRowNames(const ASheetName: string;
  const ARow: TJSONObject; AColumns: TList<string>; const AExcelRow: Integer;
  ADefinedNames: TDictionary<string, string>);
var I: Integer; FieldName: string;
begin
  for I := 0 to AColumns.Count - 1 do
  begin
    FieldName := AColumns[I];
    if MatchText(FieldName, ['ObjectType', 'ObjectIndex', 'PointIndex',
      'SpillageIndex', 'CoefTableType', 'CoefItemIndex', '_SchemaOnly']) then
      Continue;
    ADefinedNames.AddOrSetValue(SeparatedRowDefinedName(ARow, FieldName),
      Format('''%s''!$%s$%d', [ASheetName, ExcelColumnName(I + 1), AExcelRow]));
  end;
end;

// Создаёт диапазоны будущих строк без добавления фиктивных строк в worksheet XML.
procedure RegisterPreparedSeparatedNames(ARows: TJSONArray;
  ADefinedNames: TDictionary<string, string>);
var Columns: TList<string>; Row: TJSONObject;
  PointIndex, SpillageIndex, TableIndex, ItemIndex, ExcelRow: Integer;
begin
  Columns := BuildSeparatedColumns(ARows, ['DevicePoint']);
  try
    for PointIndex := 1 to TReportTemplateService.MAX_DEVICE_POINTS do
    begin
      Row := TJSONObject.Create;
      try
        Row.AddPair('ObjectType', 'DevicePoint');
        Row.AddPair('PointIndex', TJSONNumber.Create(PointIndex));
        Row.AddPair('SpillageIndex', TJSONNumber.Create(0));
        Row.AddPair('CoefTableType', TJSONNumber.Create(0));
        Row.AddPair('CoefItemIndex', TJSONNumber.Create(0));
        RegisterPreparedRowNames('_DevicePoints', Row, Columns, PointIndex + 2,
          ADefinedNames);
      finally Row.Free; end;
    end;
  finally Columns.Free; end;

  Columns := BuildSeparatedColumns(ARows, ['Spillage']);
  try
    ExcelRow := 3;
    for PointIndex := 1 to TReportTemplateService.MAX_DEVICE_POINTS do
      for SpillageIndex := 1 to TReportTemplateService.MAX_POINT_SPILLAGES do
      begin
        Row := TJSONObject.Create;
        try
          Row.AddPair('ObjectType', 'Spillage');
          Row.AddPair('PointIndex', TJSONNumber.Create(PointIndex));
          Row.AddPair('SpillageIndex', TJSONNumber.Create(SpillageIndex));
          Row.AddPair('CoefTableType', TJSONNumber.Create(0));
          Row.AddPair('CoefItemIndex', TJSONNumber.Create(0));
          RegisterPreparedRowNames('_Spillages', Row, Columns, ExcelRow,
            ADefinedNames);
        finally Row.Free; end;
        Inc(ExcelRow);
      end;
  finally Columns.Free; end;

  Columns := BuildSeparatedColumns(ARows,
    ['CalibrCoefTable', 'CalibrCoefItem']);
  try
    ExcelRow := 3;
    for TableIndex := Low(CCoefTableTypes) to High(CCoefTableTypes) do
    begin
      Row := TJSONObject.Create;
      try
        Row.AddPair('ObjectType', 'CalibrCoefTable');
        Row.AddPair('PointIndex', TJSONNumber.Create(0));
        Row.AddPair('SpillageIndex', TJSONNumber.Create(0));
        Row.AddPair('CoefTableType', TJSONNumber.Create(CCoefTableTypes[TableIndex]));
        Row.AddPair('CoefItemIndex', TJSONNumber.Create(0));
        RegisterPreparedRowNames('_CoefTables', Row, Columns, ExcelRow,
          ADefinedNames);
      finally Row.Free; end;
      Inc(ExcelRow);
      for ItemIndex := 1 to TReportTemplateService.MAX_COEF_ITEMS do
      begin
        Row := TJSONObject.Create;
        try
          Row.AddPair('ObjectType', 'CalibrCoefItem');
          Row.AddPair('PointIndex', TJSONNumber.Create(0));
          Row.AddPair('SpillageIndex', TJSONNumber.Create(0));
          Row.AddPair('CoefTableType', TJSONNumber.Create(CCoefTableTypes[TableIndex]));
          Row.AddPair('CoefItemIndex', TJSONNumber.Create(ItemIndex));
          RegisterPreparedRowNames('_CoefTables', Row, Columns, ExcelRow,
            ADefinedNames);
        finally Row.Free; end;
        Inc(ExcelRow);
      end;
    end;
  finally Columns.Free; end;
end;

// Формирует читаемый XML повторяющихся служебных данных.
function BuildSeparatedWorksheetXml(const ATitle, ASheetName: string;
  ARows: TJSONArray; const AObjectTypes: array of string;
  ADefinedNames: TDictionary<string, string>): string;
var
  Columns: TList<string>;
  I, RowIndex, OutputRow, Width: Integer;
  Row: TJSONObject;
  Value: TJSONValue;
  Builder: TStringBuilder;
begin
  Columns := BuildSeparatedColumns(ARows, AObjectTypes);
  Builder := nil;
  try
    Builder := TStringBuilder.Create;
    OutputRow := 2;
    for I := 0 to ARows.Count - 1 do
      if RowHasObjectType(ARows.Items[I] as TJSONObject, AObjectTypes) and
         not IsSchemaRow(ARows.Items[I] as TJSONObject) then
        Inc(OutputRow);
    Builder.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    Builder.Append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    Builder.Append(Format('<dimension ref="A1:%s%d"/>',
      [ExcelColumnName(Columns.Count), OutputRow]));
    Builder.Append('<sheetViews><sheetView workbookViewId="0"/></sheetViews><cols>');
    for I := 0 to Columns.Count - 1 do
    begin
      Width := ReportColumnWidth(Columns[I], ARows, AObjectTypes);
      Builder.Append(Format(
        '<col min="%d" max="%d" width="%d" customWidth="1"/>',
        [I + 1, I + 1, Width]));
    end;
    Builder.Append('</cols><sheetData><row r="1">');
    Builder.Append(Format('<c r="A1" t="inlineStr"><is><t>%s</t></is></c>',
      [XmlEscape(ATitle)]));
    Builder.Append('</row><row r="2">');
    for I := 0 to Columns.Count - 1 do
      Builder.Append(Format(
        '<c r="%s2" t="inlineStr"><is><t>%s</t></is></c>',
        [ExcelColumnName(I + 1), XmlEscape(Columns[I])]));
    Builder.Append('</row>');

    OutputRow := 3;
    for RowIndex := 0 to ARows.Count - 1 do
    begin
      Row := ARows.Items[RowIndex] as TJSONObject;
      if IsSchemaRow(Row) or not RowHasObjectType(Row, AObjectTypes) then
        Continue;
      Builder.Append(Format('<row r="%d">', [OutputRow]));
      for I := 0 to Columns.Count - 1 do
      begin
        Value := Row.GetValue(Columns[I]);
        if not SameText(Columns[I], 'ObjectType') and
           not SameText(Columns[I], 'ObjectIndex') and
           not SameText(Columns[I], 'PointIndex') and
           not SameText(Columns[I], 'SpillageIndex') and
           not SameText(Columns[I], 'CoefTableType') and
           not SameText(Columns[I], 'CoefItemIndex') then
          ADefinedNames.AddOrSetValue(
            SeparatedRowDefinedName(Row, Columns[I]),
            Format('''%s''!$%s$%d', [ASheetName,
              ExcelColumnName(I + 1), OutputRow]));
        if (Value = nil) or (Value is TJSONNull) then
          Continue;
        if Value is TJSONNumber then
          Builder.Append(Format('<c r="%s"><v>%s</v></c>',
            [ExcelColumnName(I + 1) + OutputRow.ToString, Value.Value]))
        else if Value is TJSONBool then
        begin
          if TJSONBool(Value).AsBoolean then
            Builder.Append(Format('<c r="%s" t="b"><v>1</v></c>',
              [ExcelColumnName(I + 1) + OutputRow.ToString]))
          else
            Builder.Append(Format('<c r="%s" t="b"><v>0</v></c>',
              [ExcelColumnName(I + 1) + OutputRow.ToString]));
        end
        else
          Builder.Append(Format(
            '<c r="%s" t="inlineStr"><is><t>%s</t></is></c>',
            [ExcelColumnName(I + 1) + OutputRow.ToString,
             XmlEscape(JsonValueToText(Value))]));
      end;
      Builder.Append('</row>');
      Inc(OutputRow);
    end;
    Builder.Append('</sheetData></worksheet>');
    Result := Builder.ToString;
  finally
    Builder.Free;
    Columns.Free;
  end;
end;

// Формирует вертикальный XML листа общих данных по устойчивой схеме.
function BuildDataWorksheetXml(const ATitle: string; ARows: TJSONArray;
  ADefinedNames: TDictionary<string, string>): string;
const
  ObjectTypes: array[0..2] of string = ('DeviceType', 'Device', 'Session');
  ServiceFields: array[0..6] of string = ('ObjectType', 'ObjectIndex',
    'PointIndex', 'SpillageIndex', 'CoefTableType', 'CoefItemIndex',
    '_SchemaOnly');
var
  ObjectType, FieldName, TechnicalName, ValueCell: string;
  SchemaColumns, ActualColumns, Columns: TArray<TReportColumn>;
  Column: TReportColumn;
  ActualRow, Row: TJSONObject;
  Builder: TStringBuilder;
  ObjectIndex, RowIndex, OutputRow, TotalRows: Integer;
  Value: TJSONValue;
begin
  TotalRows := 2;
  for ObjectIndex := Low(ObjectTypes) to High(ObjectTypes) do
  begin
    ActualColumns := JsonRowsToColumns(ARows, [ObjectTypes[ObjectIndex]], False);
    SchemaColumns := JsonRowsToColumns(ARows, [ObjectTypes[ObjectIndex]], True);
    Columns := MergeReportColumns(ActualColumns, SchemaColumns);
    for Column in Columns do
      if not MatchText(Column.TechnicalName, ServiceFields) then Inc(TotalRows);
  end;
  Builder := TStringBuilder.Create;
  try
    Builder.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    Builder.Append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    Builder.Append(Format('<dimension ref="A1:D%d"/>', [TotalRows]));
    Builder.Append('<sheetViews><sheetView workbookViewId="0"/></sheetViews>');
    Builder.Append('<cols><col min="1" max="1" width="36" customWidth="1"/>');
    Builder.Append('<col min="2" max="2" width="38" customWidth="1"/>');
    Builder.Append('<col min="3" max="3" width="30" customWidth="1"/>');
    Builder.Append('<col min="4" max="4" width="16" customWidth="1"/></cols>');
    Builder.Append('<sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>');
    Builder.Append(XmlEscape(ATitle));
    Builder.Append('</t></is></c></row><row r="2">');
    Builder.Append('<c r="A2" t="inlineStr"><is><t>Техническое имя</t></is></c>');
    Builder.Append('<c r="B2" t="inlineStr"><is><t>Название</t></is></c>');
    Builder.Append('<c r="C2" t="inlineStr"><is><t>Значение</t></is></c>');
    Builder.Append('<c r="D2" t="inlineStr"><is><t>Тип объекта</t></is></c></row>');
    OutputRow := 3;
    for ObjectIndex := Low(ObjectTypes) to High(ObjectTypes) do
    begin
      ObjectType := ObjectTypes[ObjectIndex];
      ActualRow := nil;
      for RowIndex := 0 to ARows.Count - 1 do
      begin
        Row := ARows.Items[RowIndex] as TJSONObject;
        if not IsSchemaRow(Row) and RowHasObjectType(Row, [ObjectType]) then
        begin ActualRow := Row; Break; end;
      end;
      ActualColumns := JsonRowsToColumns(ARows, [ObjectType], False);
      SchemaColumns := JsonRowsToColumns(ARows, [ObjectType], True);
      Columns := MergeReportColumns(ActualColumns, SchemaColumns);
      for Column in Columns do
      begin
        FieldName := Column.TechnicalName;
        if MatchText(FieldName, ServiceFields) then Continue;
        TechnicalName := BuildReportDefinedName(ObjectType + '_' + FieldName);
        ValueCell := 'C' + OutputRow.ToString;
        Builder.Append(Format('<row r="%d">', [OutputRow]));
        Builder.Append(Format('<c r="A%d" t="inlineStr"><is><t>%s</t></is></c>',
          [OutputRow, XmlEscape(TechnicalName)]));
        Builder.Append(Format('<c r="B%d" t="inlineStr"><is><t>%s</t></is></c>',
          [OutputRow, XmlEscape(GetReportFieldCaption(ObjectType, FieldName))]));
        Value := nil;
        if ActualRow <> nil then Value := ActualRow.GetValue(FieldName);
        if Value is TJSONNumber then
          Builder.Append(Format('<c r="%s"><v>%s</v></c>', [ValueCell, Value.Value]))
        else if Value is TJSONBool then
          Builder.Append(Format('<c r="%s" t="b"><v>%d</v></c>',
            [ValueCell, Ord(TJSONBool(Value).AsBoolean)]))
        else if (Value <> nil) and not (Value is TJSONNull) then
          Builder.Append(Format('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>',
            [ValueCell, XmlEscape(JsonValueToText(Value))]));
        Builder.Append(Format('<c r="D%d" t="inlineStr"><is><t>%s</t></is></c></row>',
          [OutputRow, XmlEscape(ObjectType)]));
        ADefinedNames.AddOrSetValue(TechnicalName,
          Format('''_Data''!$C$%d', [OutputRow]));
        Inc(OutputRow);
      end;
    end;
    Builder.Append('</sheetData></worksheet>');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

// Формирует служебный лист метаданных отчёта.
function BuildMetaWorksheetXml(ARoot: TJSONObject;
  ADefinedNames: TDictionary<string, string>): string;
var
  Pair: TJSONPair;
  RowIndex: Integer;
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    Builder.Append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    Builder.Append('<dimension ref="A1:B20"/><sheetViews><sheetView workbookViewId="0"/></sheetViews>');
    Builder.Append('<cols><col min="1" max="1" width="30" customWidth="1"/>');
    Builder.Append('<col min="2" max="2" width="40" customWidth="1"/></cols><sheetData>');
    Builder.Append('<row r="1"><c r="A1" t="inlineStr"><is><t>Метаданные отчёта</t></is></c></row>');
    Builder.Append('<row r="2"><c r="A2" t="inlineStr"><is><t>Параметр</t></is></c>');
    Builder.Append('<c r="B2" t="inlineStr"><is><t>Значение</t></is></c></row>');
    RowIndex := 3;
    for Pair in ARoot do
      if not SameText(Pair.JsonString.Value, 'Rows') then
      begin
        Builder.Append(Format(
          '<row r="%d"><c r="A%d" t="inlineStr"><is><t>%s</t></is></c>' +
          '<c r="B%d" t="inlineStr"><is><t>%s</t></is></c></row>',
          [RowIndex, RowIndex, XmlEscape(Pair.JsonString.Value), RowIndex,
           XmlEscape(JsonValueToText(Pair.JsonValue))]));
        ADefinedNames.AddOrSetValue(
          BuildReportDefinedName('ReportMeta_' + Pair.JsonString.Value),
          Format('''_Meta''!$B$%d', [RowIndex]));
        Inc(RowIndex);
      end;
    Builder.Append('</sheetData></worksheet>');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function IsReportDefinedName(const AName: string): Boolean;
const
  CPrefixes: array[0..5] of string = ('DeviceType_', 'Device_',
    'DevicePoints_', 'Spillages_', 'CalibrCoefTables_', 'ReportMeta_');
var
  Prefix: string;
begin
  Result := False;
  for Prefix in CPrefixes do
    if AName.StartsWith(Prefix, True) then
      Exit(True);
end;

// Возвращает непосредственный дочерний XML-узел с указанным LocalName.
function FindDirectChildNode(const AParent: IXMLNode;
  const ALocalName: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;
  if AParent = nil then Exit;
  for I := 0 to AParent.ChildNodes.Count - 1 do
    if SameText(AParent.ChildNodes[I].LocalName, ALocalName) then
      Exit(AParent.ChildNodes[I]);
end;

// Создаёт контейнер definedNames в допустимой позиции структуры workbook.
function EnsureDefinedNamesNode(const AWorkbookRoot: IXMLNode): IXMLNode;
const
  CFollowingNodes: array[0..4] of string = ('externalReferences',
    'pivotCaches', 'calcPr', 'oleSize', 'extLst');
var
  I, ExistingCount: Integer;
  Child, BeforeNode, NewNode: IXMLNode;
begin
  if AWorkbookRoot = nil then
    raise EArgumentNilException.Create('Не задан корневой узел workbook');
  if FindDirectChildNode(AWorkbookRoot, 'sheets') = nil then
    raise EInvalidOpException.Create(
      'Нельзя создать definedNames: в workbook отсутствует sheets');
  Result := nil;
  ExistingCount := 0;
  BeforeNode := nil;
  for I := 0 to AWorkbookRoot.ChildNodes.Count - 1 do
  begin
    Child := AWorkbookRoot.ChildNodes[I];
    if SameText(Child.LocalName, 'definedNames') then
    begin
      Inc(ExistingCount);
      Result := Child;
    end
    else if (BeforeNode = nil) and MatchText(Child.LocalName,
      CFollowingNodes) then
      BeforeNode := Child;
  end;
  if ExistingCount > 1 then
    raise EInvalidOpException.CreateFmt(
      'В workbook найдено несколько контейнеров definedNames: %d',
      [ExistingCount]);
  if Result <> nil then Exit;

  NewNode := AWorkbookRoot.OwnerDocument.CreateNode('definedNames', ntElement,
    AWorkbookRoot.NamespaceURI);
  if BeforeNode <> nil then
    AWorkbookRoot.DOMNode.insertBefore(NewNode.DOMNode, BeforeNode.DOMNode)
  else
    AWorkbookRoot.DOMNode.appendChild(NewNode.DOMNode);
  Result := FindDirectChildNode(AWorkbookRoot, 'definedNames');
  if Result = nil then
    raise EInvalidOpException.Create(
      'Не удалось создать контейнер definedNames через XML DOM');
end;

// Строит регистронезависимый индекс существующих definedName за один проход.
function BuildDefinedNameIndex(const ADefinedNamesNode: IXMLNode):
  TDictionary<string, IXMLNode>;
var I: Integer; Child: IXMLNode; NameValue: string;
begin
  Result := TDictionary<string, IXMLNode>.Create;
  if ADefinedNamesNode = nil then Exit;
  for I := 0 to ADefinedNamesNode.ChildNodes.Count - 1 do
  begin
    Child := ADefinedNamesNode.ChildNodes[I];
    if not SameText(Child.LocalName, 'definedName') then Continue;
    NameValue := VarToStr(Child.Attributes['name']);
    if Result.ContainsKey(NameValue) then
      raise EInvalidOpException.CreateFmt(
        'Найдено несколько definedName с именем %s', [NameValue]);
    Result.Add(NameValue, Child);
  end;
end;

// Разбирает абсолютную ссылку definedName с quoted и unquoted именем листа.
function TryParseDefinedNameReference(
  const AReference: string;
  out ASheetName: string;
  out AColumnIndex: Integer;
  out ARowIndex: Integer
): Boolean;
var
  S, ParsedSheetName, ColumnName, RowName: string;
  P, I, ParsedColumnIndex, ParsedRowIndex, Digit: Integer;
  Ch: Char;
begin
  Result := False;
  ASheetName := '';
  AColumnIndex := 0;
  ARowIndex := 0;
  S := Trim(AReference);
  if S = '' then Exit;
  ParsedSheetName := '';
  if S[1] = '''' then
  begin
    I := 2;
    while I <= Length(S) do
    begin
      if S[I] = '''' then
      begin
        if (I < Length(S)) and (S[I + 1] = '''') then
        begin
          ParsedSheetName := ParsedSheetName + '''';
          Inc(I, 2);
          Continue;
        end;
        Break;
      end;
      ParsedSheetName := ParsedSheetName + S[I];
      Inc(I);
    end;
    if (ParsedSheetName = '') or (I > Length(S)) then Exit;
    Inc(I);
    if (I > Length(S)) or (S[I] <> '!') then Exit;
  end;
  if S[1] <> '''' then
  begin
    I := Pos('!', S);
    if I <= 1 then Exit;
    ParsedSheetName := Copy(S, 1, I - 1);
  end;
  if (Pos('[', ParsedSheetName) > 0) or
     (Pos(']', ParsedSheetName) > 0) then Exit;
  Inc(I);
  if (I > Length(S)) or (S[I] <> '$') then Exit;
  Inc(I);
  P := I;
  while (I <= Length(S)) and CharInSet(S[I], ['A'..'Z', 'a'..'z']) do Inc(I);
  ColumnName := UpperCase(Copy(S, P, I - P));
  if (ColumnName = '') or (I > Length(S)) or (S[I] <> '$') then Exit;
  Inc(I);
  P := I;
  while (I <= Length(S)) and CharInSet(S[I], ['0'..'9']) do Inc(I);
  if (P = I) or (I <= Length(S)) then Exit;
  RowName := Copy(S, P, I - P);
  if not TryStrToInt(RowName, ParsedRowIndex) or (ParsedRowIndex < 1) then Exit;
  ParsedColumnIndex := 0;
  for Ch in ColumnName do
  begin
    Digit := Ord(Ch) - Ord('A') + 1;
    if ParsedColumnIndex > (MaxInt - Digit) div 26 then Exit;
    ParsedColumnIndex := ParsedColumnIndex * 26 + Digit;
  end;
  if ParsedColumnIndex < 1 then Exit;
  ASheetName := ParsedSheetName;
  AColumnIndex := ParsedColumnIndex;
  ARowIndex := ParsedRowIndex;
  Result := True;
end;

// Проверяет наличие имени в наборе FlowService без учёта регистра.
function ContainsDefinedName(ADefinedNames: TDictionary<string, string>;
  const AName: string): Boolean;
var
  Pair: TPair<string, string>;
begin
  Result := False;
  if ADefinedNames = nil then Exit;
  for Pair in ADefinedNames do
    if SameText(Pair.Key, AName) then Exit(True);
end;

// Проверяет допустимость имени и ссылки именованного диапазона до записи в DOM.
procedure ValidateDefinedNameValues(const AName, AReference: string);
var
  I: Integer;
  SheetName: string;
  ColumnIndex, RowIndex: Integer;
begin
  if (AName = '') or (AName <> BuildReportDefinedName(AName)) or
     CharInSet(AName[1], ['0'..'9', '.']) then
    raise EArgumentException.CreateFmt(
      'Недопустимое имя диапазона FlowService: %s', [AName]);
  for I := 1 to Length(AName) do
    if Ord(AName[I]) <= 32 then
      raise EArgumentException.CreateFmt(
        'Имя диапазона содержит пробельный или управляющий символ: %s',
        [AName]);
  if AReference = '' then
    raise EArgumentException.CreateFmt('Пустая ссылка диапазона %s', [AName]);
  for I := 1 to Length(AReference) do
    if (AReference[I] = #0) or
       ((Ord(AReference[I]) < 32) and
        not CharInSet(AReference[I], [#9, #10, #13])) then
      raise EArgumentException.CreateFmt(
        'Ссылка диапазона %s содержит недопустимый XML-символ', [AName]);
  if not TryParseDefinedNameReference(AReference, SheetName, ColumnIndex,
    RowIndex) then
    raise EArgumentException.CreateFmt(
      'Недопустимый формат ссылки диапазона %s: %s', [AName, AReference]);
end;

// Удаляет через XML DOM только устаревшие именованные диапазоны FlowService.
procedure RemoveObsoleteReportDefinedNames(
  const ADefinedNamesNode: IXMLNode;
  ADefinedNames: TDictionary<string, string>);
var
  I: Integer;
  Child: IXMLNode;
  Name: string;
begin
  if ADefinedNamesNode = nil then Exit;
  for I := ADefinedNamesNode.ChildNodes.Count - 1 downto 0 do
  begin
    Child := ADefinedNamesNode.ChildNodes[I];
    if not SameText(Child.LocalName, 'definedName') then Continue;
    Name := VarToStr(Child.Attributes['name']);
    if IsReportDefinedName(Name) and
       not ContainsDefinedName(ADefinedNames, Name) then
      ADefinedNamesNode.DOMNode.removeChild(Child.DOMNode);
  end;
end;

// Проверяет отсутствие повторяющихся именованных диапазонов в workbook.
procedure ValidateDefinedNameDuplicates(
  const ADefinedNamesNode: IXMLNode);
var
  Counts: TDictionary<string, Integer>;
  I, Count: Integer;
  Child: IXMLNode;
  Name, NormalizedName, LocalSheetId: string;
begin
  if ADefinedNamesNode = nil then
    Exit;

  Counts := TDictionary<string, Integer>.Create;
  try
    for I := 0 to ADefinedNamesNode.ChildNodes.Count - 1 do
    begin
      Child := ADefinedNamesNode.ChildNodes[I];

      if not SameText(Child.LocalName, 'definedName') then
        Continue;

      Name := VarToStr(Child.Attributes['name']);
      NormalizedName := UpperCase(Name);

      if Counts.TryGetValue(NormalizedName, Count) then
      begin
        LocalSheetId := VarToStr(Child.Attributes['localSheetId']);

        raise EInvalidOpException.CreateFmt(
          'Повтор definedName %s; Count=%d; localSheetId=%s; FlowService=%s',
          [
            Name,
            Count + 1,
            LocalSheetId,
            BoolToStr(IsReportDefinedName(Name), True)
          ]
        );
      end;

      Counts.Add(NormalizedName, 1);
    end;
  finally
    Counts.Free;
  end;
end;
function SerializeXmlDocumentUtf8(const ADocument: IXMLDocument): string;
var
  Stream: TMemoryStream;
  Bytes: TBytes;
  Offset: Integer;
begin
  if ADocument = nil then
    raise EArgumentNilException.Create('Не задан XML-документ для сериализации');
  ADocument.Encoding := 'UTF-8';
  Stream := TMemoryStream.Create;
  try
    ADocument.SaveToStream(Stream);
    if Stream.Size > MaxInt then
      raise EInvalidOpException.Create('XML-документ слишком велик');
    SetLength(Bytes, Integer(Stream.Size));
    Stream.Position := 0;
    if Length(Bytes) > 0 then
      Stream.ReadBuffer(Bytes[0], Length(Bytes));
  finally
    Stream.Free;
  end;
  Offset := 0;
  if (Length(Bytes) >= 3) and (Bytes[0] = $EF) and (Bytes[1] = $BB) and
     (Bytes[2] = $BF) then
    Offset := 3;
  Result := TEncoding.UTF8.GetString(Bytes, Offset, Length(Bytes) - Offset);
end;

function ExcelColumnIndexFromCellReference(const AReference: string): Integer;
var I: Integer; Ch: Char;
begin
  Result := 0;
  for I := 1 to Length(AReference) do
  begin
    Ch := UpCase(AReference[I]);
    if not CharInSet(Ch, ['A'..'Z']) then Break;
    Result := Result * 26 + Ord(Ch) - Ord('A') + 1;
  end;
end;

procedure AppendDescendantTextNodes(const ANode: IXMLNode;
  var AText: string);
var
  I: Integer;
  Child: IXMLNode;
begin
  if ANode = nil then Exit;
  for I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    Child := ANode.ChildNodes[I];
    if SameText(Child.LocalName, 't') then
      AText := AText + Child.Text
    else
      AppendDescendantTextNodes(Child, AText);
  end;
end;

// Разбирает таблицу общих строк XLSX и возвращает текст каждого элемента si.
function ParseSharedStrings(
  const ASharedStringsXml: string
): TArray<string>;
var
  Doc: IXMLDocument;
  Root, Node: IXMLNode;
  Values: TList<string>;
  I: Integer;
  Value: string;
begin
  SetLength(Result, 0);
  if ASharedStringsXml = '' then Exit;
  try
    Doc := LoadXMLData(ASharedStringsXml);
    Doc.Active := True;
  except
    on E: Exception do
      raise EInvalidOpException.CreateFmt(
        'Некорректный XML ZIP-entry xl/sharedStrings.xml: %s',
        [E.Message]);
  end;
  Root := Doc.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'sst') then
    raise EInvalidOpException.Create(
      'Некорректный XML ZIP-entry xl/sharedStrings.xml: отсутствует sst');
  Values := TList<string>.Create;
  try
    for I := 0 to Root.ChildNodes.Count - 1 do
    begin
      Node := Root.ChildNodes[I];
      if not SameText(Node.LocalName, 'si') then Continue;
      Value := '';
      AppendDescendantTextNodes(Node, Value);
      Values.Add(Value);
    end;
    Result := Values.ToArray;
  finally
    Values.Free;
  end;
end;

// Возвращает фактический текст ячейки worksheet с учётом типа хранения XLSX.
function GetWorksheetCellText(const ACellNode: IXMLNode;
  const ASharedStrings: TArray<string>): string;
var
  CellType, CellReference, RawValue: string;
  ValueNode, InlineNode: IXMLNode;
  SharedStringIndex: Integer;
begin
  Result := '';
  if ACellNode = nil then Exit;
  CellType := VarToStr(ACellNode.Attributes['t']);
  CellReference := VarToStr(ACellNode.Attributes['r']);
  ValueNode := FindDirectChildNode(ACellNode, 'v');
  if ValueNode <> nil then RawValue := ValueNode.Text else RawValue := '';
  if SameText(CellType, 's') then
  begin
    if (ValueNode = nil) or not TryStrToInt(RawValue, SharedStringIndex) or
       (SharedStringIndex < 0) or (SharedStringIndex >= Length(ASharedStrings)) then
      raise EInvalidOpException.CreateFmt(
        'Некорректный индекс shared string в ячейке %s: ' +
        'Type="%s"; Index="%s"; SharedStringsCount=%d; Entry=xl/sharedStrings.xml.',
        [CellReference, CellType, RawValue, Length(ASharedStrings)]);
    Exit(ASharedStrings[SharedStringIndex]);
  end;
  if SameText(CellType, 'inlineStr') then
  begin
    InlineNode := FindDirectChildNode(ACellNode, 'is');
    AppendDescendantTextNodes(InlineNode, Result);
    Exit;
  end;
  if SameText(CellType, 'b') or SameText(CellType, 'e') or
     SameText(CellType, 'd') then Exit;
  if (CellType = '') or SameText(CellType, 'str') then Result := RawValue;
end;

// Строит соответствие технического имени заголовка и номера столбца листа.
function BuildWorksheetHeaderIndex(const AWorksheetXml: string;
  const AHeaderRow: Integer;
  const ASharedStrings: TArray<string>): TDictionary<string, Integer>;
var Doc: IXMLDocument; Root, SheetData, RowNode, CellNode: IXMLNode;
  I, J, ColumnIndex: Integer;
  CellReference, Header, NormalizedHeader: string;
begin
  Result := TDictionary<string, Integer>.Create;
  try
    Doc := LoadXMLData(AWorksheetXml); Doc.Active := True;
    Root := Doc.DocumentElement;
    SheetData := FindDirectChildNode(Root, 'sheetData');
    if SheetData = nil then
      raise EInvalidOpException.Create('В worksheet отсутствует sheetData');
    RowNode := nil;
    for I := 0 to SheetData.ChildNodes.Count - 1 do
      if SameText(SheetData.ChildNodes[I].LocalName, 'row') and
         (StrToIntDef(VarToStr(SheetData.ChildNodes[I].Attributes['r']), 0) = AHeaderRow) then
      begin RowNode := SheetData.ChildNodes[I]; Break; end;
    if RowNode = nil then
      raise EInvalidOpException.CreateFmt('В worksheet отсутствует строка заголовков %d', [AHeaderRow]);
    for J := 0 to RowNode.ChildNodes.Count - 1 do
    begin
      CellNode := RowNode.ChildNodes[J];
      if not SameText(CellNode.LocalName, 'c') then Continue;
      CellReference := VarToStr(CellNode.Attributes['r']);
      ColumnIndex := ExcelColumnIndexFromCellReference(CellReference);
      if ColumnIndex = 0 then Continue;
      Header := GetWorksheetCellText(CellNode, ASharedStrings);
      NormalizedHeader := LowerCase(Trim(Header));
      if NormalizedHeader = '' then Continue;
      if Result.ContainsKey(NormalizedHeader) then
        raise EInvalidOpException.CreateFmt(
          'Повторяющийся технический заголовок "%s" в строке %d',
          [Header, AHeaderRow]);
      Result.Add(NormalizedHeader, ColumnIndex);
    end;
  except
    Result.Free;
    raise;
  end;
end;

// Возвращает ссылку definedName на ячейку поля по фактическому заголовку листа.
function BuildDefinedNameReference(const ASheetName, AFieldName: string;
  const AExcelRow: Integer; const AHeaderIndex: TDictionary<string, Integer>): string;
var ColumnIndex: Integer;
begin
  if not AHeaderIndex.TryGetValue(LowerCase(Trim(AFieldName)), ColumnIndex) then
    raise EInvalidOpException.CreateFmt('Лист %s не содержит технический заголовок %s',
      [ASheetName, AFieldName]);
  Result := Format('''%s''!$%s$%d',
    [StringReplace(ASheetName, '''', '''''', [rfReplaceAll]),
     ExcelColumnName(ColumnIndex), AExcelRow]);
end;

// Проверяет неизменность технических заголовков между шаблоном и сформированным листом.
procedure ValidateTechnicalSheetColumnOrder(const ATemplateWorksheetXml,
  AGeneratedWorksheetXml, ASheetName: string;
  const ATemplateSharedStrings: TArray<string>;
  const AGeneratedSharedStrings: TArray<string>);
var TemplateHeaders, GeneratedHeaders: TDictionary<string, Integer>;
  Pair: TPair<string, Integer>; GeneratedColumn: Integer;
begin
  TemplateHeaders := BuildWorksheetHeaderIndex(ATemplateWorksheetXml, 2,
    ATemplateSharedStrings);
  GeneratedHeaders := BuildWorksheetHeaderIndex(AGeneratedWorksheetXml, 2,
    AGeneratedSharedStrings);
  try
    if TemplateHeaders.Count <> GeneratedHeaders.Count then
      raise EInvalidOpException.CreateFmt('Изменилось число колонок листа %s', [ASheetName]);
    for Pair in TemplateHeaders do
      if not GeneratedHeaders.TryGetValue(Pair.Key, GeneratedColumn) or
         (GeneratedColumn <> Pair.Value) then
        raise EInvalidOpException.CreateFmt(
          'Изменился порядок колонок %s: %s', [ASheetName, Pair.Key]);
  finally GeneratedHeaders.Free; TemplateHeaders.Free; end;
end;

// Добавляет, обновляет и удаляет только именованные диапазоны FlowService через XML DOM.
procedure ValidateSeparatedWorksheetXml(const AXml, ASheetName: string);
var
  Document: IXMLDocument;
  Root: IXMLNode;
begin
  try
    Document := LoadXMLData(AXml);
    Document.Active := True;
  except
    on E: EDOMParseError do
      raise EInvalidOpException.CreateFmt(
        'Некорректный XML служебного листа %s: %s', [ASheetName, E.Message]);
  end;
  Root := Document.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'worksheet') then
    raise EInvalidOpException.CreateFmt(
      'Некорректный корневой узел служебного листа %s', [ASheetName]);
end;

procedure ValidateZipEntries(AZip: TZipFile);
var
  Name: string;
  Seen: TDictionary<string, Byte>;
begin
  if AZip = nil then
    raise EArgumentNilException.Create('Не задан ZIP-архив для проверки');

  Seen := TDictionary<string, Byte>.Create;
  try
    for Name in AZip.FileNames do
    begin
      if Name.Contains('..') or Name.StartsWith('/') or Name.StartsWith('\') then
        raise EInvalidOpException.CreateFmt(
          'Недопустимый путь внутри XLSX: %s', [Name]);
      if Seen.ContainsKey(LowerCase(NormalizeArchivePath(Name))) then
        raise EInvalidOpException.CreateFmt(
          'Повторяющийся путь внутри XLSX: %s', [Name]);
      Seen.Add(LowerCase(NormalizeArchivePath(Name)), 0);
    end;
  finally
    Seen.Free;
  end;
end;

// Проверяет наличие ZIP entry по нормализованному пути.
function ZipEntryExists(AZip: TZipFile; const AArchivePath: string): Boolean;
var Name, Wanted: string;
begin
  Result := False;
  Wanted := NormalizeArchivePath(AArchivePath);
  for Name in AZip.FileNames do
    if SameText(NormalizeArchivePath(Name), Wanted) then Exit(True);
end;

function FindActualZipEntryName(AZip: TZipFile; const AArchivePath: string): string;
var Name, Wanted: string;
begin
  Result := ''; Wanted := NormalizeArchivePath(AArchivePath);
  for Name in AZip.FileNames do
    if SameText(NormalizeArchivePath(Name), Wanted) then Exit(Name);
end;

function ReadZipEntryUtf8(AZip: TZipFile; const AArchivePath: string): string;
var Bytes: TBytes; ActualName: string; Stream: TStream; Header: TZipHeader;
begin
  ActualName := FindActualZipEntryName(AZip, AArchivePath);
  if ActualName = '' then
    raise EFileNotFoundException.CreateFmt('В XLSX отсутствует ZIP entry %s', [AArchivePath]);
  Stream := nil;
  AZip.Read(ActualName, Stream, Header);
  try
    if Stream.Size > MaxInt then
      raise EInvalidOpException.CreateFmt('ZIP entry слишком велик: %s', [AArchivePath]);
    SetLength(Bytes, Integer(Stream.Size)); Stream.Position := 0;
    if Length(Bytes) > 0 then Stream.ReadBuffer(Bytes[0], Length(Bytes));
  finally
    Stream.Free;
  end;
  Result := TEncoding.UTF8.GetString(Bytes);
  if (Result <> '') and (Result[1] = #$FEFF) then Delete(Result, 1, 1);
end;

// Возвращает пути ZIP-entry пяти существующих технических листов.
function ResolveTechnicalSheetEntries(const AWorkbookXml: string;
  const AWorkbookRelsXml: string): TArray<TReportWorksheetLocation>;
var Doc: IXMLDocument; Root, Node: IXMLNode; I, J: Integer; RelationType: string;
begin
  Doc := LoadXMLData(AWorkbookRelsXml); Doc.Active := True;
  Root := Doc.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'Relationships') then
    raise EInvalidOpException.Create('Некорректный xl/_rels/workbook.xml.rels');
  SetLength(Result, Length(CReportTechnicalSheetNames));
  for I := Low(CReportTechnicalSheetNames) to High(CReportTechnicalSheetNames) do
  begin
    Result[I].SheetName := CReportTechnicalSheetNames[I];
    Result[I].RelationId := FindSheetRelationId(AWorkbookXml, Result[I].SheetName);
    if Result[I].RelationId = '' then
      raise EInvalidOpException.CreateFmt(
        'Шаблон не содержит обязательный технический лист: %s', [Result[I].SheetName]);
    for J := 0 to Root.ChildNodes.Count - 1 do
    begin
      Node := Root.ChildNodes[J];
      if SameText(Node.LocalName, 'Relationship') and
         SameText(VarToStr(Node.Attributes['Id']), Result[I].RelationId) then
      begin
        RelationType := VarToStr(Node.Attributes['Type']);
        if not SameText(RelationType, CWorksheetRelation) then Break;
        Result[I].RelationshipTarget := VarToStr(Node.Attributes['Target']);
        Result[I].ArchivePath := ResolveWorkbookTargetArchivePath(
          Result[I].RelationshipTarget);
        Break;
      end;
    end;
    if Result[I].ArchivePath = '' then
      raise EInvalidOpException.CreateFmt(
        'Шаблон не содержит обязательный технический лист: %s', [Result[I].SheetName]);
  end;
end;

// Заменяет данные только в существующих технических листах XLSX.
procedure ReplaceTechnicalSheetEntries(const ASourceFileName,
  AOutputFileName: string; const ALocations: TArray<TReportWorksheetLocation>;
  const ASheetXml: TArray<string>);
var
  InputArchive: TZipFile;
  ResultArchive: TZipFile;
  EntryName: string;
  NormalizedEntryName: string;
  LocationIndex: Integer;
  ReplacementIndex: Integer;
  EntryStream: TStream;
  EntryHeader: TZipHeader;
  XmlBytes: TBytes;
begin
  if Length(ALocations) <> Length(ASheetXml) then
    raise EArgumentException.Create(
      'Число XML-листов не совпадает с числом ZIP-entry');

  InputArchive := TZipFile.Create;
  ResultArchive := TZipFile.Create;
  try
    InputArchive.Open(ASourceFileName, zmRead);
    for LocationIndex := 0 to High(ALocations) do
      if not ZipEntryExists(InputArchive, ALocations[LocationIndex].ArchivePath) then
        raise EInvalidOpException.CreateFmt(
          'Шаблон не содержит обязательный технический лист: %s',
          [ALocations[LocationIndex].SheetName]);

    ResultArchive.Open(AOutputFileName, zmWrite);
    for EntryName in InputArchive.FileNames do
    begin
      NormalizedEntryName := NormalizeArchivePath(EntryName);
      ReplacementIndex := -1;
      for LocationIndex := 0 to High(ALocations) do
        if SameText(NormalizedEntryName,
          NormalizeArchivePath(ALocations[LocationIndex].ArchivePath)) then
        begin
          ReplacementIndex := LocationIndex;
          Break;
        end;

      if ReplacementIndex >= 0 then
      begin
        XmlBytes := TEncoding.UTF8.GetBytes(ASheetXml[ReplacementIndex]);
        EntryStream := TBytesStream.Create(XmlBytes);
      end
      else
      begin
        EntryStream := nil;
        InputArchive.Read(EntryName, EntryStream, EntryHeader);
      end;
      try
        EntryStream.Position := 0;
        ResultArchive.Add(EntryStream, EntryName);
      finally
        EntryStream.Free;
      end;
    end;
  finally
    ResultArchive.Free;
    InputArchive.Free;
  end;
end;

procedure ValidateGeneratedTechnicalSheets(const AFileName: string;
  const ALocations: TArray<TReportWorksheetLocation>);
var
  Archive: TZipFile;
  LocationIndex: Integer;
  WorksheetXml: string;
  WorksheetDocument: IXMLDocument;
begin
  if not FileExists(AFileName) or (TFile.GetSize(AFileName) = 0) then
    raise EInvalidOpException.Create('Сформированный XLSX пуст или отсутствует');
  Archive := TZipFile.Create;
  try
    Archive.Open(AFileName, zmRead);
    for LocationIndex := 0 to High(ALocations) do
    begin
      if not ZipEntryExists(Archive, ALocations[LocationIndex].ArchivePath) then
        raise EInvalidOpException.CreateFmt('Не записан технический лист: %s',
          [ALocations[LocationIndex].SheetName]);
      WorksheetXml := ReadZipEntryUtf8(Archive,
        ALocations[LocationIndex].ArchivePath);
      WorksheetDocument := LoadXMLData(WorksheetXml);
      WorksheetDocument.Active := True;
      if (WorksheetDocument.DocumentElement = nil) or
         not SameText(WorksheetDocument.DocumentElement.LocalName,
           'worksheet') then
        raise EInvalidOpException.CreateFmt('Некорректный XML листа: %s',
          [ALocations[LocationIndex].SheetName]);
    end;
  finally
    Archive.Free;
  end;
end;

// Атомарно сохраняет сформированный XLSX и сохраняет резервную копию при ошибке замены.
procedure ReplaceReportOutputFile(const ATemporaryFileName,
  AOutputFileName: string);
var BackupFileName: string;
begin
  if ExtractFileDir(AOutputFileName) <> '' then
    ForceDirectories(ExtractFileDir(AOutputFileName));
  if not FileExists(AOutputFileName) then
  begin
    TFile.Move(ATemporaryFileName, AOutputFileName); Exit;
  end;
  BackupFileName := AOutputFileName + '.backup-' +
    TPath.GetRandomFileName.Replace('.', '') + '.xlsx';
  try
    TFile.Replace(ATemporaryFileName, AOutputFileName, BackupFileName);
    if FileExists(BackupFileName) then TFile.Delete(BackupFileName);
  except
    on E: Exception do
      raise EInOutError.CreateFmt(
        'Не удалось заменить итоговый XLSX. Закройте файл в Excel и повторите. ' +
        'Резервная копия сохранена: %s. %s', [BackupFileName, E.Message]);
  end;
end;

function ReplaceReportDefinedNames(const AWorkbookXml: string;
  const ADefinedNames: TDictionary<string, string>): string; forward;
procedure CopyXlsxReplacingWorkbook(const ASourceFileName, AOutputFileName,
  AWorkbookXml: string); forward;

procedure ExportTechnicalSheets(const ASourceFileName, AOutputFileName: string;
  ARoot: TJSONObject);
const
  Titles: array[0..4] of string = ('Общие данные прибора', 'Точки прибора',
    'Проливки по точкам', 'Калибровочные таблицы и коэффициенты',
    'Метаданные отчёта');
var Zip: TZipFile; WorkbookXml, RelsXml, TempOutput, WorkbookOutput: string;
  Locations: TArray<TReportWorksheetLocation>; SheetXml: TArray<string>;
  Rows: TJSONArray; Names, TechnicalSheets: TDictionary<string, string>;
  InlineSharedStrings: TArray<string>; I: Integer;
begin
  if not FileExists(ASourceFileName) then
    raise EFileNotFoundException.CreateFmt('Шаблон не найден: %s', [ASourceFileName]);
  Zip := TZipFile.Create;
  try
    Zip.Open(ASourceFileName, zmRead);
    WorkbookXml := ReadZipEntryUtf8(Zip, 'xl/workbook.xml');
    RelsXml := ReadZipEntryUtf8(Zip, 'xl/_rels/workbook.xml.rels');
  finally
    Zip.Free;
  end;
  Locations := ResolveTechnicalSheetEntries(WorkbookXml, RelsXml);
  Rows := ARoot.GetValue<TJSONArray>('Rows');
  if Rows = nil then raise EInvalidOpException.Create('В снимке отсутствует массив Rows');
  Names := TDictionary<string, string>.Create;
  try
    SetLength(SheetXml, 5);
    SheetXml[0] := BuildDataWorksheetXml(Titles[0], Rows, Names);
    SheetXml[1] := BuildSeparatedWorksheetXml(Titles[1], '_DevicePoints', Rows,
      ['DevicePoint'], Names);
    SheetXml[2] := BuildSeparatedWorksheetXml(Titles[2], '_Spillages', Rows,
      ['Spillage'], Names);
    SheetXml[3] := BuildSeparatedWorksheetXml(Titles[3], '_CoefTables', Rows,
      ['CalibrCoefTable', 'CalibrCoefItem'], Names);
    SheetXml[4] := BuildMetaWorksheetXml(ARoot, Names);
    RegisterPreparedSeparatedNames(Rows, Names);
    for I := 0 to High(SheetXml) do
      ValidateSeparatedWorksheetXml(SheetXml[I], Locations[I].SheetName);
    WorkbookXml := ReplaceReportDefinedNames(WorkbookXml, Names);
    TechnicalSheets := TDictionary<string, string>.Create;
    try
      for I := 0 to High(SheetXml) do
        TechnicalSheets.Add(Locations[I].SheetName, SheetXml[I]);
      SetLength(InlineSharedStrings, 0);
      ValidateReportDefinedNameBindings(WorkbookXml, TechnicalSheets,
        InlineSharedStrings);
    finally
      TechnicalSheets.Free;
    end;
  finally
    Names.Free;
  end;
  TempOutput := BuildTemporaryReportFileName(AOutputFileName);
  WorkbookOutput := BuildTemporaryReportFileName(AOutputFileName);
  try
    CopyXlsxReplacingWorkbook(ASourceFileName, WorkbookOutput, WorkbookXml);
    ReplaceTechnicalSheetEntries(WorkbookOutput, TempOutput, Locations, SheetXml);
    ValidateGeneratedTechnicalSheets(TempOutput, Locations);
    ReplaceReportOutputFile(TempOutput, AOutputFileName);
  finally
    if FileExists(TempOutput) then TFile.Delete(TempOutput);
    if FileExists(WorkbookOutput) then TFile.Delete(WorkbookOutput);
  end;
end;

// Добавляет сформированные именованные диапазоны только при первичной подготовке книги.
function AddPreparedDefinedNames(const AWorkbookXml: string;
  const ADefinedNames: TDictionary<string, string>): string;
var Doc: IXMLDocument; Root, NamesNode, NameNode: IXMLNode;
  Pair: TPair<string, string>;
  NameIndex: TDictionary<string, IXMLNode>;
begin
  Doc := LoadXMLData(AWorkbookXml); Doc.Active := True;
  Root := Doc.DocumentElement;
  if (Root = nil) or not SameText(Root.LocalName, 'workbook') then
    raise EInvalidOpException.Create('Некорректный xl/workbook.xml');
  NamesNode := EnsureDefinedNamesNode(Root);
  NameIndex := BuildDefinedNameIndex(NamesNode);
  try
    for Pair in ADefinedNames do
    begin
      ValidateDefinedNameValues(Pair.Key, Pair.Value);
      if NameIndex.ContainsKey(Pair.Key) then
        raise EInvalidOpException.CreateFmt(
          'В исходном шаблоне уже существует definedName %s', [Pair.Key]);
      NameNode := NamesNode.AddChild('definedName', NamesNode.NamespaceURI);
      NameNode.Attributes['name'] := Pair.Key;
      NameNode.Text := Pair.Value;
      NameIndex.Add(Pair.Key, NameNode);
    end;
    Result := SerializeXmlDocumentUtf8(Doc);
  finally
    NameIndex.Free;
  end;
end;

// Полностью заменяет только управляемые приложением definedName, сохраняя
// пользовательские имена книги без изменений.
function ReplaceReportDefinedNames(const AWorkbookXml: string;
  const ADefinedNames: TDictionary<string, string>): string;
var
  Doc: IXMLDocument;
  NamesNode, NameNode: IXMLNode;
  Pair: TPair<string, string>;
  I: Integer;
begin
  Doc := LoadXMLData(AWorkbookXml);
  Doc.Active := True;
  NamesNode := EnsureDefinedNamesNode(Doc.DocumentElement);
  for I := NamesNode.ChildNodes.Count - 1 downto 0 do
  begin
    NameNode := NamesNode.ChildNodes[I];
    if SameText(NameNode.LocalName, 'definedName') and
       IsReportDefinedName(VarToStr(NameNode.Attributes['name'])) then
      NamesNode.DOMNode.removeChild(NameNode.DOMNode);
  end;
  for Pair in ADefinedNames do
  begin
    ValidateDefinedNameValues(Pair.Key, Pair.Value);
    NameNode := NamesNode.AddChild('definedName', NamesNode.NamespaceURI);
    NameNode.Attributes['name'] := Pair.Key;
    NameNode.Text := Pair.Value;
  end;
  ValidateDefinedNameDuplicates(NamesNode);
  Result := SerializeXmlDocumentUtf8(Doc);
end;

procedure AddUtf8ZipEntry(AZip: TZipFile; const AName, AText: string);
var Bytes: TBytes; Stream: TBytesStream;
begin
  Bytes := TEncoding.UTF8.GetBytes(AText);
  Stream := TBytesStream.Create(Bytes);
  try
    AZip.Add(Stream, AName);
  finally
    Stream.Free;
  end;
end;

procedure CopyOrReplaceZipEntries(const ASourceFileName, AOutputFileName,
  AWorkbookXml, ARelsXml, AContentTypesXml: string;
  const ASheetXml: TArray<string>);
const
  SheetPaths: array[0..4] of string =
    ('xl/worksheets/flowServiceData.xml',
     'xl/worksheets/flowServiceDevicePoints.xml',
     'xl/worksheets/flowServiceSpillages.xml',
     'xl/worksheets/flowServiceCoefTables.xml',
     'xl/worksheets/flowServiceMeta.xml');
var SourceZip, OutputZip: TZipFile; Name, Normalized: string;
  Stream: TStream; Header: TZipHeader; I: Integer;
begin
  SourceZip := TZipFile.Create; OutputZip := TZipFile.Create;
  try
    SourceZip.Open(ASourceFileName, zmRead);
    for I := Low(SheetPaths) to High(SheetPaths) do
      if ZipEntryExists(SourceZip, SheetPaths[I]) then
        raise EInvalidOpException.CreateFmt(
          'Исходный XLSX уже содержит ZIP-entry технического листа: %s',
          [SheetPaths[I]]);
    OutputZip.Open(AOutputFileName, zmWrite);
    for Name in SourceZip.FileNames do
    begin
      Normalized := NormalizeArchivePath(Name);
      if SameText(Normalized, 'xl/workbook.xml') then
        AddUtf8ZipEntry(OutputZip, Name, AWorkbookXml)
      else if SameText(Normalized, 'xl/_rels/workbook.xml.rels') then
        AddUtf8ZipEntry(OutputZip, Name, ARelsXml)
      else if SameText(Normalized, '[Content_Types].xml') then
        AddUtf8ZipEntry(OutputZip, Name, AContentTypesXml)
      else
      begin
        Stream := nil; SourceZip.Read(Name, Stream, Header);
        try
          Stream.Position := 0; OutputZip.Add(Stream, Name);
        finally
          Stream.Free;
        end;
      end;
    end;
    for I := Low(SheetPaths) to High(SheetPaths) do
      AddUtf8ZipEntry(OutputZip, SheetPaths[I], ASheetXml[I]);
  finally
    OutputZip.Free; SourceZip.Free;
  end;
end;

procedure CopyXlsxReplacingWorkbook(const ASourceFileName, AOutputFileName,
  AWorkbookXml: string);
var SourceZip, OutputZip: TZipFile; Name: string; Stream: TStream;
  Header: TZipHeader;
begin
  SourceZip := TZipFile.Create; OutputZip := TZipFile.Create;
  try
    SourceZip.Open(ASourceFileName, zmRead);
    OutputZip.Open(AOutputFileName, zmWrite);
    for Name in SourceZip.FileNames do
      if SameText(NormalizeArchivePath(Name), 'xl/workbook.xml') then
        AddUtf8ZipEntry(OutputZip, Name, AWorkbookXml)
      else
      begin
        Stream := nil; SourceZip.Read(Name, Stream, Header);
        try Stream.Position := 0; OutputZip.Add(Stream, Name); finally Stream.Free; end;
      end;
  finally
    OutputZip.Free; SourceZip.Free;
  end;
end;

function TryDevicePointDefinedNameParts(const AName: string;
  out APointIndex: Integer; out AFieldName: string): Boolean;
var Parts: TArray<string>;
begin
  Parts := AName.Split(['_']);
  Result := (Length(Parts) = 3) and SameText(Parts[0], 'DevicePoints') and
    TryStrToInt(Parts[1], APointIndex) and (APointIndex >= 1) and
    (APointIndex <= TReportTemplateService.MAX_DEVICE_POINTS);
  if Result then AFieldName := Parts[2] else AFieldName := '';
end;

// Проверяет, что каждый служебный definedName указывает на поле с соответствующим техническим заголовком.
procedure ValidateReportDefinedNameBindings(const AWorkbookXml: string;
  const ATechnicalSheets: TDictionary<string, string>;
  const ASharedStrings: TArray<string>);
var Doc: IXMLDocument; NamesNode, Node: IXMLNode; Name, Reference, SheetName,
  FieldName: string; I, ColumnIndex, RowIndex, PointIndex, ActualColumn: Integer;
  HeaderIndex: TDictionary<string, Integer>; Seen: TDictionary<string, Byte>;
begin
  Doc := LoadXMLData(AWorkbookXml); Doc.Active := True;
  NamesNode := FindDirectChildNode(Doc.DocumentElement, 'definedNames');
  Seen := TDictionary<string, Byte>.Create;
  HeaderIndex := nil;
  try
    if ATechnicalSheets.ContainsKey('_DevicePoints') then
      HeaderIndex := BuildWorksheetHeaderIndex(
        ATechnicalSheets['_DevicePoints'], 2, ASharedStrings);
    if NamesNode = nil then raise EInvalidOpException.Create('workbook не содержит definedNames');
    for I := 0 to NamesNode.ChildNodes.Count - 1 do
    begin
      Node := NamesNode.ChildNodes[I];
      if not SameText(Node.LocalName, 'definedName') then Continue;
      Name := VarToStr(Node.Attributes['name']);
      if not IsReportDefinedName(Name) then Continue;
      if Seen.ContainsKey(Name) then
        raise EInvalidOpException.CreateFmt('Повтор definedName %s', [Name]);
      Seen.Add(Name, 0); Reference := Node.Text;
      if not TryParseDefinedNameReference(Reference, SheetName, ColumnIndex, RowIndex) then
        raise EInvalidOpException.CreateFmt(
          'Некорректная ссылка definedName %s:'#13#10 +
          'Reference="%s".'#13#10 +
          'Ожидается абсолютная ссылка вида Sheet!$A$1 или ''Sheet Name''!$A$1.',
          [Name, Reference]);
      if not ATechnicalSheets.ContainsKey(SheetName) then
        raise EInvalidOpException.CreateFmt('definedName %s указывает на неизвестный лист %s', [Name, SheetName]);
      if TryDevicePointDefinedNameParts(Name, PointIndex, FieldName) then
      begin
        if not SameText(SheetName, '_DevicePoints') or (RowIndex <> PointIndex + 2) then
          raise EInvalidOpException.CreateFmt('Неверная строка definedName %s', [Name]);
        if (HeaderIndex = nil) or not HeaderIndex.TryGetValue(
           LowerCase(Trim(FieldName)), ActualColumn) then
          raise EInvalidOpException.CreateFmt(
            'definedName %s: Reference="%s"; на листе %s ' +
            'отсутствует технический заголовок %s; ' +
            'столбец ссылки=%s.',
            [Name, Reference, SheetName, FieldName,
             ExcelColumnName(ColumnIndex)]);
        if ActualColumn <> ColumnIndex then
          raise EInvalidOpException.CreateFmt(
            'definedName %s: Reference="%s"; лист=%s; поле=%s; ' +
            'ссылка указывает на столбец %s, но заголовок ' +
            'находится в столбце %s.',
            [Name, Reference, SheetName, FieldName,
             ExcelColumnName(ColumnIndex), ExcelColumnName(ActualColumn)]);
      end;
    end;
  finally HeaderIndex.Free; Seen.Free; end;
end;

// Полностью пересоздаёт технические листы подготовленного шаблона по
// актуальной JSON-схеме, не затрагивая пользовательские ZIP-entry.
procedure RepairPreparedReportDefinedNames(const ASourceFileName,
  AOutputFileName: string);
var
  Root: TJSONObject;
  Rows: TJSONArray;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('SchemaVersion', TJSONNumber.Create(1));
    Root.AddPair('GeneratedAt', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    Root.AddPair('MaxDevicePoints',
      TJSONNumber.Create(TReportTemplateService.MAX_DEVICE_POINTS));
    Root.AddPair('MaxPointSpillages',
      TJSONNumber.Create(TReportTemplateService.MAX_POINT_SPILLAGES));
    Root.AddPair('MaxCoefItems',
      TJSONNumber.Create(TReportTemplateService.MAX_COEF_ITEMS));
    Rows := TJSONArray.Create;
    Root.AddPair('Rows', Rows);
    EnsureTechnicalSheetSchema(Root);
    ExportTechnicalSheets(ASourceFileName, AOutputFileName, Root);
  finally
    Root.Free;
  end;
end;

function MissingTechnicalSheetNames(const AWorkbookXml: string): TArray<string>;
var Missing: TList<string>; I: Integer;
begin
  Missing := TList<string>.Create;
  try
    for I := Low(CReportTechnicalSheetNames) to High(CReportTechnicalSheetNames) do
      if FindSheetRelationId(AWorkbookXml, CReportTechnicalSheetNames[I]) = '' then
        Missing.Add(CReportTechnicalSheetNames[I]);
    Result := Missing.ToArray;
  finally
    Missing.Free;
  end;
end;

// Один раз добавляет пять технических листов в исходный пользовательский XLSX.
procedure PrepareNewTemplateFile(const ASourceFileName, AOutputFileName: string;
  ARoot: TJSONObject);
const
  Titles: array[0..4] of string = ('Общие данные прибора', 'Точки прибора',
    'Проливки по точкам', 'Калибровочные таблицы и коэффициенты',
    'Метаданные отчёта');
  Targets: array[0..4] of string =
    ('worksheets/flowServiceData.xml',
     'worksheets/flowServiceDevicePoints.xml',
     'worksheets/flowServiceSpillages.xml',
     'worksheets/flowServiceCoefTables.xml',
     'worksheets/flowServiceMeta.xml');
var Zip: TZipFile; WorkbookXml, RelsXml, ContentTypesXml, Fragment,
  RelationId: string; RelsDoc: IXMLDocument; RelsRoot: IXMLNode;
  SheetXml: TArray<string>; Names: TDictionary<string, string>;
  Rows: TJSONArray; I, SheetId: Integer;
begin
  Zip := TZipFile.Create;
  try
    Zip.Open(ASourceFileName, zmRead);
    WorkbookXml := ReadZipEntryUtf8(Zip, 'xl/workbook.xml');
    RelsXml := ReadZipEntryUtf8(Zip, 'xl/_rels/workbook.xml.rels');
    ContentTypesXml := ReadZipEntryUtf8(Zip, '[Content_Types].xml');
  finally
    Zip.Free;
  end;
  RelsDoc := LoadXMLData(RelsXml); RelsDoc.Active := True;
  RelsRoot := RelsDoc.DocumentElement;
  if (RelsRoot = nil) or not SameText(RelsRoot.LocalName, 'Relationships') then
    raise EInvalidOpException.Create('Некорректный xl/_rels/workbook.xml.rels');
  Names := TDictionary<string, string>.Create;
  try
    Rows := ARoot.GetValue<TJSONArray>('Rows');
    SetLength(SheetXml, 5);
    SheetXml[0] := BuildDataWorksheetXml(Titles[0], Rows, Names);
    SheetXml[1] := BuildSeparatedWorksheetXml(Titles[1], '_DevicePoints', Rows,
      ['DevicePoint'], Names);
    SheetXml[2] := BuildSeparatedWorksheetXml(Titles[2], '_Spillages', Rows,
      ['Spillage'], Names);
    SheetXml[3] := BuildSeparatedWorksheetXml(Titles[3], '_CoefTables', Rows,
      ['CalibrCoefTable', 'CalibrCoefItem'], Names);
    SheetXml[4] := BuildMetaWorksheetXml(ARoot, Names);
    RegisterPreparedSeparatedNames(Rows, Names);
    for I := 0 to 4 do
      ValidateSeparatedWorksheetXml(SheetXml[I], CReportTechnicalSheetNames[I]);
    for I := 0 to 4 do
    begin
      SheetId := NextSheetId(WorkbookXml);
      RelationId := NextRelationId(RelsRoot);
      Fragment := Format('<sheet name="%s" sheetId="%d" state="hidden" r:id="%s"/>',
        [CReportTechnicalSheetNames[I], SheetId, RelationId]);
      WorkbookXml := InsertBeforeUniqueXmlNode(WorkbookXml, '</sheets>',
        Fragment, 'добавление ' + CReportTechnicalSheetNames[I]);
      AddWorksheetRelationship(RelsRoot, RelationId, Targets[I]);
      Fragment := Format('<Override PartName="/xl/%s" ContentType="%s"/>',
        [Targets[I], CWorksheetContentType]);
      ContentTypesXml := InsertBeforeUniqueXmlNode(ContentTypesXml, '</Types>',
        Fragment, 'добавление ContentType ' + CReportTechnicalSheetNames[I]);
    end;
    WorkbookXml := AddPreparedDefinedNames(WorkbookXml, Names);
    RelsXml := SerializeXmlDocumentUtf8(RelsDoc);
    CopyOrReplaceZipEntries(ASourceFileName, AOutputFileName, WorkbookXml,
      RelsXml, ContentTypesXml, SheetXml);
  finally
    Names.Free;
  end;
end;

class function TReportTemplateService.TemplatesPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'ReportTemplates');
  ForceDirectories(Result);
end;

class function TReportTemplateService.BuildReportJson(ADevice: TDevice;
  ADeviceType: TDeviceType; AMeterValueError: TMeterValue): TJSONObject;
var
  Rows: TJSONArray;
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  Table: TCalibrCoefTable;
  Item: TCalibrCoefItem;
  ActiveSession: TSessionSpillage;
  PointRow: TJSONObject;
  PointError: Double;
  Session: TSessionSpillage;
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
  ActiveSession := nil;
  if (ADevice <> nil) and (ADevice.Sessions <> nil) then
    for Session in ADevice.Sessions do
      if (Session <> nil) and (Session.State <> osDeleted) and
         Session.Active then
      begin
        ActiveSession := Session;
        Break;
      end;

  Rows.AddElement(NewObjectRow('DeviceType', 1, 0, 0, 0, 0, ADeviceType, ADevice));
  Rows.AddElement(NewObjectRow('Device', 1, 0, 0, 0, 0, ADevice, ADevice));
  if ActiveSession <> nil then
    Rows.AddElement(NewObjectRow('Session', 1, 0, 0, 0, 0,
      ActiveSession, ADevice));

  for PointIndex := 1 to MAX_DEVICE_POINTS do
  begin
    Point := nil;
    if (ADevice <> nil) and (ADevice.Points <> nil) and
       (PointIndex <= ADevice.Points.Count) then
      Point := ADevice.Points[PointIndex - 1];
    PointRow := NewObjectRow('DevicePoint', PointIndex, PointIndex,
      0, 0, 0, Point, ADevice);
    if TryGetDevicePointDisplayError(ADevice, Point, ActiveSession,
      PointError) then
      PointRow.AddPair('PointError', TJSONNumber.Create(PointError))
    else
      PointRow.AddPair('PointError', TJSONNull.Create);
    Rows.AddElement(PointRow);

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
        PointIndex, SpillageIndex, 0, 0, Spillage, ADevice));
    end;
  end;

  for TableIndex := Low(CCoefTableTypes) to High(CCoefTableTypes) do
  begin
    Table := FindCoefTable(ADevice, CCoefTableTypes[TableIndex]);
    Rows.AddElement(NewObjectRow('CalibrCoefTable', TableIndex + 1, 0, 0,
      CCoefTableTypes[TableIndex], 0, Table, ADevice));
    for ItemIndex := 1 to MAX_COEF_ITEMS do
    begin
      Item := nil;
      if (Table <> nil) and (Table.Items <> nil) and
         (ItemIndex <= Table.Items.Count) then
        Item := Table.Items[ItemIndex - 1];
      Rows.AddElement(NewObjectRow('CalibrCoefItem',
        TableIndex * MAX_COEF_ITEMS + ItemIndex, 0, 0,
        CCoefTableTypes[TableIndex], ItemIndex, Item, ADevice));
    end;
  end;
  EnsureTechnicalSheetSchema(Result);
  ApplyReportErrorPrecision(Rows, AMeterValueError);
end;

class function TReportTemplateService.PrepareTemplate(
  const ASourceFileName: string): string;
var
  BaseName, Extension, WorkbookXml, RelsXml, TemporaryFileName: string;
  Suffix: Integer;
  Zip: TZipFile;
  Missing: TArray<string>;
  PreparedLocations: TArray<TReportWorksheetLocation>;
  EmptyJson: TJSONObject;
  EmptyRows: TJSONArray;
begin
  if not FileExists(ASourceFileName) then
    raise EFileNotFoundException.CreateFmt('Шаблон не найден: %s', [ASourceFileName]);
  if not SameText(ExtractFileExt(ASourceFileName), '.xlsx') then
    raise EArgumentException.Create('Поддерживаются только шаблоны XLSX');
  Zip := TZipFile.Create;
  try
    Zip.Open(ASourceFileName, zmRead);
    WorkbookXml := ReadZipEntryUtf8(Zip, 'xl/workbook.xml');
    RelsXml := ReadZipEntryUtf8(Zip, 'xl/_rels/workbook.xml.rels');
  finally
    Zip.Free;
  end;
  Missing := MissingTechnicalSheetNames(WorkbookXml);
  if (Length(Missing) <> 0) and
     (Length(Missing) <> Length(CReportTechnicalSheetNames)) then
    raise EInvalidOpException.Create('Шаблон содержит только часть технических листов. ' +
      'Отсутствуют: ' + string.Join(', ', Missing));
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
  if Length(Missing) = 0 then
  begin
    ResolveTechnicalSheetEntries(WorkbookXml, RelsXml);
    TemporaryFileName := BuildTemporaryReportFileName(Result);
    try
      RepairPreparedReportDefinedNames(ASourceFileName, TemporaryFileName);
      TFile.Move(TemporaryFileName, Result);
    finally
      if FileExists(TemporaryFileName) then TFile.Delete(TemporaryFileName);
    end;
    Exit;
  end;
  EmptyJson := TJSONObject.Create;
  try
    EmptyJson.AddPair('SchemaVersion', TJSONNumber.Create(1));
    EmptyJson.AddPair('GeneratedAt', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    EmptyJson.AddPair('MaxDevicePoints', TJSONNumber.Create(MAX_DEVICE_POINTS));
    EmptyJson.AddPair('MaxPointSpillages', TJSONNumber.Create(MAX_POINT_SPILLAGES));
    EmptyJson.AddPair('MaxCoefItems', TJSONNumber.Create(MAX_COEF_ITEMS));
    EmptyRows := TJSONArray.Create;
    EmptyJson.AddPair('Rows', EmptyRows);
    EnsureTechnicalSheetSchema(EmptyJson);
    TemporaryFileName := BuildTemporaryReportFileName(Result);
      try
        PrepareNewTemplateFile(ASourceFileName, TemporaryFileName, EmptyJson);
        Zip := TZipFile.Create;
        try
          Zip.Open(TemporaryFileName, zmRead);
          WorkbookXml := ReadZipEntryUtf8(Zip, 'xl/workbook.xml');
          RelsXml := ReadZipEntryUtf8(Zip, 'xl/_rels/workbook.xml.rels');
        finally
          Zip.Free;
        end;
        PreparedLocations := ResolveTechnicalSheetEntries(WorkbookXml, RelsXml);
        ValidateGeneratedTechnicalSheets(TemporaryFileName, PreparedLocations);
        TFile.Move(TemporaryFileName, Result);
      finally
        if FileExists(TemporaryFileName) then TFile.Delete(TemporaryFileName);
      end;
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
    ExportTechnicalSheets(ATemplateFileName, AOutputFileName, Json);
  finally
    Json.Free;
  end;
end;


class procedure TReportTemplateService.ExportTemplateFromJson(
  const ATemplateFileName, AOutputFileName, AReportJson: string);
var
  JsonValue: TJSONValue;
  Json: TJSONObject;
begin
  if SameText(TPath.GetFullPath(ATemplateFileName),
    TPath.GetFullPath(AOutputFileName)) then
    raise EArgumentException.Create(
      'Итоговый файл отчёта не должен совпадать с исходным шаблоном');
  JsonValue := TJSONObject.ParseJSONValue(AReportJson);
  if not (JsonValue is TJSONObject) then
  begin
    JsonValue.Free;
    raise EArgumentException.Create('Снимок данных отчёта не является JSON-объектом');
  end;
  Json := TJSONObject(JsonValue);
  try
    ExportTechnicalSheets(ATemplateFileName, AOutputFileName, Json);
  finally
    Json.Free;
  end;
end;


end.
