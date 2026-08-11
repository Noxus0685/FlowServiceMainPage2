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
    // Сохраняет выбранный готовый XLSX-шаблон в каталог ReportTemplates без изменения его содержимого.
    class function ImportTemplate(const ASourceFileName: string): string; static;
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
  uOpenXmlXlsx,
  uProtocols;

var
  GReportLogLock: TObject;


type
  PSpillageStopCriteria = ^TSpillageStopCriteria;

const
  CCoefTableTypes: array[0..4] of Integer = (10, 11, 12, 13, 14);
  CWorksheetRelation: string =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet';
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

// Возвращает индекс имени столбца без учёта регистра.
function IndexOfColumnName(AColumns: TList<string>;
  const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if AColumns = nil then Exit;
  for I := 0 to AColumns.Count - 1 do
    if SameText(AColumns[I], AName) then Exit(I);
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

// Возвращает набор столбцов по фактическим полям выбранных строк JSON.
function BuildSeparatedColumns(ARows: TJSONArray;
  const AObjectTypes: array of string): TList<string>;
var
  I: Integer;
  Pair: TJSONPair;
  Row: TJSONObject;
begin
  Result := TList<string>.Create;
  AddUniqueColumn(Result, 'ObjectType');
  AddUniqueColumn(Result, 'ObjectIndex');
  AddUniqueColumn(Result, 'PointIndex');
  AddUniqueColumn(Result, 'SpillageIndex');
  AddUniqueColumn(Result, 'CoefTableType');
  AddUniqueColumn(Result, 'CoefItemIndex');
  for I := 0 to ARows.Count - 1 do
  begin
    Row := ARows.Items[I] as TJSONObject;
    if RowHasObjectType(Row, AObjectTypes) then
      for Pair in Row do
        AddUniqueColumn(Result, Pair.JsonString.Value);
  end;
  { PointError is a calculated report field, therefore its physical position
    must not depend on RTTI enumeration order. }
  if (Length(AObjectTypes) = 1) and SameText(AObjectTypes[0], 'DevicePoint') then
  begin
    I := IndexOfColumnName(Result, 'PointError');
    if I >= 0 then
      Result.Delete(I);
    I := IndexOfColumnName(Result, 'Q');
    if I < 0 then
      raise EInvalidOpException.Create(
        'Нельзя добавить PointError: в _DevicePoints отсутствует столбец Q');
    Result.Insert(I + 1, 'PointError');
  end;
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
      if RowHasObjectType(ARows.Items[I] as TJSONObject, AObjectTypes) then
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
      if not RowHasObjectType(Row, AObjectTypes) then
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

// Формирует вертикальный XML листа общих данных прибора.
function BuildDataWorksheetXml(const ATitle: string; ARows: TJSONArray;
  ADefinedNames: TDictionary<string, string>): string;
var
  RowIndex, OutputRow: Integer;
  Row: TJSONObject;
  Pair: TJSONPair;
  ObjectType, FieldName, TechnicalName, ValueCell: string;
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    OutputRow := 2;
    for RowIndex := 0 to ARows.Count - 1 do
      if RowHasObjectType(ARows.Items[RowIndex] as TJSONObject,
        ['DeviceType', 'Device']) then
        for Pair in (ARows.Items[RowIndex] as TJSONObject) do
          if not MatchText(Pair.JsonString.Value, ['ObjectType', 'ObjectIndex',
            'PointIndex', 'SpillageIndex', 'CoefTableType', 'CoefItemIndex']) then
            Inc(OutputRow);
    Builder.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    Builder.Append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    Builder.Append(Format('<dimension ref="A1:D%d"/>', [OutputRow]));
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
    for RowIndex := 0 to ARows.Count - 1 do
    begin
      Row := ARows.Items[RowIndex] as TJSONObject;
      if not RowHasObjectType(Row, ['DeviceType', 'Device']) then
        Continue;
      ObjectType := Row.GetValue<string>('ObjectType');
      for Pair in Row do
      begin
        FieldName := Pair.JsonString.Value;
        if MatchText(FieldName, ['ObjectType', 'ObjectIndex', 'PointIndex',
          'SpillageIndex', 'CoefTableType', 'CoefItemIndex']) then
          Continue;
        TechnicalName := BuildReportDefinedName(ObjectType + '_' + FieldName);
        ValueCell := 'C' + OutputRow.ToString;
        Builder.Append(Format('<row r="%d">', [OutputRow]));
        Builder.Append(Format('<c r="A%d" t="inlineStr"><is><t>%s</t></is></c>',
          [OutputRow, XmlEscape(TechnicalName)]));
        Builder.Append(Format('<c r="B%d" t="inlineStr"><is><t>%s</t></is></c>',
          [OutputRow, XmlEscape(GetReportFieldCaption(ObjectType, FieldName))]));
        if Pair.JsonValue is TJSONNumber then
          Builder.Append(Format('<c r="%s"><v>%s</v></c>',
            [ValueCell, Pair.JsonValue.Value]))
        else if Pair.JsonValue is TJSONBool then
          Builder.Append(Format('<c r="%s" t="b"><v>%d</v></c>',
            [ValueCell, Ord(TJSONBool(Pair.JsonValue).AsBoolean)]))
        else if not (Pair.JsonValue is TJSONNull) then
          Builder.Append(Format('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>',
            [ValueCell, XmlEscape(JsonValueToText(Pair.JsonValue))]));
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

// Находит именованный диапазон по атрибуту name без учёта регистра.
function FindDefinedNameNode(const ADefinedNamesNode: IXMLNode;
  const AName: string): IXMLNode;
var
  I, FoundCount: Integer;
  Child: IXMLNode;
  NameValue: string;
begin
  Result := nil;
  FoundCount := 0;
  if ADefinedNamesNode = nil then Exit;
  for I := 0 to ADefinedNamesNode.ChildNodes.Count - 1 do
  begin
    Child := ADefinedNamesNode.ChildNodes[I];
    if not SameText(Child.LocalName, 'definedName') then Continue;
    NameValue := VarToStr(Child.Attributes['name']);
    if SameText(NameValue, AName) then
    begin
      Inc(FoundCount);
      Result := Child;
    end;
  end;
  if FoundCount > 1 then
    raise EInvalidOpException.CreateFmt(
      'Найдено несколько definedName с именем %s: %d', [AName, FoundCount]);
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
  if not TRegEx.IsMatch(AReference,
    '^''[^'']+''!\$[A-Z]+\$[1-9][0-9]*$') then
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

// Возвращает буквенную часть столбца из ссылки Excel вида K2 или $K$2.
function ExtractExcelColumnName(const ACellReference: string): string;
var
  CleanReference: string;
  I, DigitStart: Integer;
begin
  Result := '';
  CleanReference := StringReplace(Trim(ACellReference), '$', '', [rfReplaceAll]);
  I := 1;
  while (I <= Length(CleanReference)) and
        CharInSet(UpCase(CleanReference[I]), ['A'..'Z']) do
  begin
    Result := Result + UpCase(CleanReference[I]);
    Inc(I);
  end;
  DigitStart := I;
  while (I <= Length(CleanReference)) and
        CharInSet(CleanReference[I], ['0'..'9']) do Inc(I);
  if (Result = '') or (DigitStart > Length(CleanReference)) or
     (I <= Length(CleanReference)) then Result := '';
end;

function ExcelColumnIndex(const AColumnName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if AColumnName = '' then Exit;
  Result := 0;
  for I := 1 to Length(AColumnName) do
  begin
    if not CharInSet(UpCase(AColumnName[I]), ['A'..'Z']) then Exit(-1);
    Result := Result * 26 + Ord(UpCase(AColumnName[I])) - Ord('A') + 1;
  end;
  Dec(Result);
end;

function GetWorksheetCellText(const ACell: IXMLNode): string;
var InlineNode, TextNode: IXMLNode;
begin
  Result := '';
  if ACell = nil then Exit;
  InlineNode := FindDirectChildNode(ACell, 'is');
  if InlineNode <> nil then
  begin
    TextNode := FindDirectChildNode(InlineNode, 't');
    if TextNode <> nil then Exit(TextNode.Text);
  end;
  TextNode := FindDirectChildNode(ACell, 'v');
  if TextNode <> nil then Result := TextNode.Text;
end;

// Читает строку заголовков _DevicePoints и определяет позиции Q и PointError.
function GetDevicePointsHeaderInfo(
  const ADevicePointsDocument: IXMLDocument): TDevicePointsHeaderInfo;
var
  Worksheet, SheetData, RowNode, Cell: IXMLNode;
  I, ColumnIndex: Integer;
  HeaderText, ColumnName: string;
begin
  Result := Default(TDevicePointsHeaderInfo);
  Result.QIndex := -1;
  Result.PointErrorIndex := -1;
  if ADevicePointsDocument = nil then Exit;
  Worksheet := ADevicePointsDocument.DocumentElement;
  if (Worksheet = nil) or not SameText(Worksheet.LocalName, 'worksheet') then Exit;
  SheetData := FindDirectChildNode(Worksheet, 'sheetData');
  if SheetData = nil then Exit;
  RowNode := nil;
  for I := 0 to SheetData.ChildNodes.Count - 1 do
    if SameText(SheetData.ChildNodes[I].LocalName, 'row') and
       SameText(VarToStr(SheetData.ChildNodes[I].Attributes['r']), '2') then
    begin RowNode := SheetData.ChildNodes[I]; Break; end;
  if RowNode = nil then Exit;
  Result.HeaderRowFound := True;
  for I := 0 to RowNode.ChildNodes.Count - 1 do
  begin
    Cell := RowNode.ChildNodes[I];
    if not SameText(Cell.LocalName, 'c') then Continue;
    ColumnName := ExtractExcelColumnName(VarToStr(Cell.Attributes['r']));
    HeaderText := Trim(GetWorksheetCellText(Cell));
    ColumnIndex := ExcelColumnIndex(ColumnName);
    if SameText(HeaderText, 'Q') then
    begin
      if Result.QIndex >= 0 then Result.QIndex := -2
      else begin Result.QIndex := ColumnIndex; Result.QColumn := ColumnName; end;
    end;
    if SameText(HeaderText, 'PointError') then
    begin
      Inc(Result.PointErrorCount);
      if Result.PointErrorCount = 1 then
      begin
        Result.PointErrorIndex := ColumnIndex;
        Result.PointErrorColumn := ColumnName;
      end;
    end;
  end;
end;

// Нормализует ссылку definedName для безопасного сравнения.
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
var SourceZip, OutputZip: TZipFile; Name, Normalized: string; I, ReplaceIndex: Integer;
  Stream: TStream; Header: TZipHeader; Bytes: TBytes; Replaced: TArray<Boolean>;
begin
  if Length(ALocations) <> Length(ASheetXml) then
    raise EArgumentException.Create('Число XML-листов не совпадает с числом ZIP-entry');
  SetLength(Replaced, Length(ALocations));
  SourceZip := TZipFile.Create; OutputZip := TZipFile.Create;
  try
    SourceZip.Open(ASourceFileName, zmRead);
    OutputZip.Open(AOutputFileName, zmWrite);
    for Name in SourceZip.FileNames do
    begin
      Normalized := NormalizeArchivePath(Name); ReplaceIndex := -1;
      for I := 0 to High(ALocations) do
        if SameText(Normalized, NormalizeArchivePath(ALocations[I].ArchivePath)) then
        begin ReplaceIndex := I; Break; end;
      if ReplaceIndex >= 0 then
      begin
        Bytes := TEncoding.UTF8.GetBytes(ASheetXml[ReplaceIndex]);
        Stream := TBytesStream.Create(Bytes); Replaced[ReplaceIndex] := True;
      end
      else
      begin
        Stream := nil; SourceZip.Read(Name, Stream, Header);
      end;
      try
        Stream.Position := 0;
        OutputZip.Add(Stream, Name);
      finally
        Stream.Free;
      end;
    end;
    for I := 0 to High(Replaced) do
      if not Replaced[I] then
        raise EInvalidOpException.CreateFmt(
          'Шаблон не содержит обязательный технический лист: %s',
          [ALocations[I].SheetName]);
  finally
    OutputZip.Free; SourceZip.Free;
  end;
end;

procedure ValidateTechnicalSheetOutput(const AFileName: string;
  const ALocations: TArray<TReportWorksheetLocation>);
var Zip: TZipFile; I: Integer; Xml: string; Doc: IXMLDocument;
begin
  if not FileExists(AFileName) or (TFile.GetSize(AFileName) = 0) then
    raise EInvalidOpException.Create('Сформированный XLSX пуст или отсутствует');
  Zip := TZipFile.Create;
  try
    Zip.Open(AFileName, zmRead);
    for I := 0 to High(ALocations) do
    begin
      if not ZipEntryExists(Zip, ALocations[I].ArchivePath) then
        raise EInvalidOpException.CreateFmt('Не записан технический лист: %s',
          [ALocations[I].SheetName]);
      Xml := ReadZipEntryUtf8(Zip, ALocations[I].ArchivePath);
      Doc := LoadXMLData(Xml); Doc.Active := True;
      if (Doc.DocumentElement = nil) or
         not SameText(Doc.DocumentElement.LocalName, 'worksheet') then
        raise EInvalidOpException.CreateFmt('Некорректный XML листа: %s',
          [ALocations[I].SheetName]);
    end;
  finally
    Zip.Free;
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

procedure ExportTechnicalSheets(const ASourceFileName, AOutputFileName: string;
  ARoot: TJSONObject);
const
  Titles: array[0..4] of string = ('Общие данные прибора', 'Точки прибора',
    'Проливки по точкам', 'Калибровочные таблицы и коэффициенты',
    'Метаданные отчёта');
var Zip: TZipFile; WorkbookXml, RelsXml, TempOutput: string;
  Locations: TArray<TReportWorksheetLocation>; SheetXml: TArray<string>;
  Rows: TJSONArray; Names: TDictionary<string, string>; I: Integer;
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
    for I := 0 to High(SheetXml) do
      ValidateSeparatedWorksheetXml(SheetXml[I], Locations[I].SheetName);
  finally
    Names.Free;
  end;
  TempOutput := BuildTemporaryReportFileName(AOutputFileName);
  try
    ReplaceTechnicalSheetEntries(ASourceFileName, TempOutput, Locations, SheetXml);
    ValidateTechnicalSheetOutput(TempOutput, Locations);
    ReplaceReportOutputFile(TempOutput, AOutputFileName);
  finally
    if FileExists(TempOutput) then TFile.Delete(TempOutput);
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
  ApplyReportErrorPrecision(Rows, AMeterValueError);
end;

class function TReportTemplateService.ImportTemplate(
  const ASourceFileName: string): string;
var
  BaseName, Extension: string;
  Suffix: Integer;
begin
  if not FileExists(ASourceFileName) then
    raise EFileNotFoundException.CreateFmt('Шаблон не найден: %s', [ASourceFileName]);
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
  TFile.Copy(ASourceFileName, Result, False);
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
