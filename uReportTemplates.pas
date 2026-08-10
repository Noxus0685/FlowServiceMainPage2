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
  System.StrUtils,
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
  CWorksheetRelation: string =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet';
  CWorksheetContentType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml';

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

// Записывает этап формирования отчёта в отдельный технический журнал.
procedure LogReportStage(const AStage: string);
var
  LogFileName: string;
begin
  LogFileName := TPath.Combine(TPath.GetTempPath, 'FlowServiceReport.log');
  TFile.AppendAllText(LogFileName,
    FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' + AStage + sLineBreak,
    TEncoding.UTF8);
end;

function InsertBeforeClosingTag(const AXml, AClosingTag,
  AFragment: string): string;
var
  P: Integer;
  Builder: TStringBuilder;
begin
  // Создаёт новую XML-строку через TStringBuilder без изменения входной строки.
  P := AXml.LastIndexOf(AClosingTag);
  if (P < 0) or (P > AXml.Length) then
    raise EInvalidOpException.CreateFmt('В XLSX не найден XML-узел %s',
      [AClosingTag]);
  Builder := TStringBuilder.Create(AXml.Length + AFragment.Length);
  try
    Builder.Append(AXml, 0, P);
    Builder.Append(AFragment);
    Builder.Append(AXml, P, AXml.Length - P);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
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

// Удаляет только устаревшие именованные диапазоны, созданные отчётной подсистемой.
procedure RemoveObsoleteReportDefinedNames(var AWorkbookXml: string;
  ADefinedNames: TDictionary<string, string>);
var
  Match: TMatch;
  Name: string;
  Matches: TMatchCollection;
  I: Integer;
begin
  Matches := TRegEx.Matches(AWorkbookXml,
    '<definedName\b[^>]*\bname="([^"]+)"[^>]*>.*?</definedName>',
    [roIgnoreCase, roSingleLine]);
  for I := Matches.Count - 1 downto 0 do
  begin
    Match := Matches[I];
    Name := Match.Groups[1].Value;
    if IsReportDefinedName(Name) and not ADefinedNames.ContainsKey(Name) then
      Delete(AWorkbookXml, Match.Index + 1, Match.Length);
  end;
end;

// Добавляет или обновляет именованные диапазоны служебных данных.
procedure UpdateReportDefinedNames(var AWorkbookXml: string;
  ADefinedNames: TDictionary<string, string>);
var
  Pair: TPair<string, string>;
  Match: TMatch;
  Pattern, Node, Fragment: string;
begin
  RemoveObsoleteReportDefinedNames(AWorkbookXml, ADefinedNames);
  for Pair in ADefinedNames do
  begin
    Pattern := '<definedName\b([^>]*\bname="' +
      TRegEx.Escape(Pair.Key) + '"[^>]*)>.*?</definedName>';
    Match := TRegEx.Match(AWorkbookXml, Pattern,
      [roIgnoreCase, roSingleLine]);
    Node := Format('<definedName name="%s">%s</definedName>',
      [XmlEscape(Pair.Key), XmlEscape(Pair.Value)]);
    if Match.Success then
    begin
      if not SameText(Match.Value, Node) then
      begin
        Delete(AWorkbookXml, Match.Index + 1, Match.Length);
        Insert(Node, AWorkbookXml, Match.Index + 1);
      end;
    end
    else if AWorkbookXml.Contains('</definedNames>') then
      AWorkbookXml := InsertBeforeClosingTag(AWorkbookXml,
        '</definedNames>', Node)
    else
    begin
      Fragment := '<definedNames>' + Node + '</definedNames>';
      if AWorkbookXml.Contains('<calcPr') then
        AWorkbookXml := AWorkbookXml.Replace('<calcPr', Fragment + '<calcPr', [])
      else
        AWorkbookXml := InsertBeforeClosingTag(AWorkbookXml,
          '</workbook>', Fragment);
    end;
  end;
end;

// Проверяет XML сформированного отдельного служебного листа.
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

// Удаляет артефакты прежней однотабличной схемы, не затрагивая таблицы шаблона.
procedure RemoveLegacyReportTableArtifacts(const ATempDir: string;
  var AContentTypesXml: string);
var
  Document: IXMLDocument;
  Root: IXMLNode;
  FileName, LegacyName, PartName, TablesDirectory: string;
begin
  LegacyName := 'tblReport' + 'Data';
  TablesDirectory := TPath.Combine(ATempDir, 'xl\tables');
  if not DirectoryExists(TablesDirectory) then
    Exit;
  for FileName in TDirectory.GetFiles(TablesDirectory, '*.xml') do
  begin
    try
      Document := LoadXMLData(ReadUtf8File(FileName));
      Document.Active := True;
    except
      on E: EDOMParseError do
        raise EInvalidOpException.CreateFmt(
          'Некорректный XML существующей Excel-таблицы %s: %s',
          [FileName, E.Message]);
    end;
    Root := Document.DocumentElement;
    if (Root <> nil) and
       (SameText(VarToStr(Root.Attributes['name']), LegacyName) or
        SameText(VarToStr(Root.Attributes['displayName']), LegacyName)) then
    begin
      PartName := NormalizeArchivePath(FileName.Substring(
        IncludeTrailingPathDelimiter(ATempDir).Length));
      AContentTypesXml := TRegEx.Replace(AContentTypesXml,
        '<Override\b[^>]*PartName="/' + TRegEx.Escape(PartName) +
        '"[^>]*/>', '', [roIgnoreCase]);
      DeleteFile(FileName);
    end;
  end;
end;

procedure ValidateZipEntries(AZip: TZipFile);
var
  Names: TArray<string>;
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

// Добавляет или обновляет пять раздельных служебных листов отчёта.
procedure InjectDataSheet(const ASourceFileName, AOutputFileName: string;
  ARoot: TJSONObject);
const
  CSheetNames: array[0..4] of string =
    ('_Data', '_DevicePoints', '_Spillages', '_CoefTables', '_Meta');
  CSheetTitles: array[0..4] of string =
    ('Общие данные прибора', 'Точки прибора', 'Проливки по точкам',
     'Калибровочные таблицы и коэффициенты', 'Метаданные отчёта');
  CSheetTargets: array[0..4] of string =
    ('worksheets/flowServiceData.xml',
     'worksheets/flowServiceDevicePoints.xml',
     'worksheets/flowServiceSpillages.xml',
     'worksheets/flowServiceCoefTables.xml',
     'worksheets/flowServiceMeta.xml');
var
  Zip: TZipFile;
  WorkbookRelsDocument: IXMLDocument;
  WorkbookRelsRoot: IXMLNode;
  TempDir, TempOutput, WorkbookFile, WorkbookRelsFile, ContentTypesFile,
    WorkbookXml, ContentTypesXml, RelationId, SheetFragment,
    ContentTypeFragment, UpdatedWorkbookXml, UpdatedContentTypesXml,
    SheetArchivePath, SheetFile: string;
  SheetTargets, SheetFiles, SheetXml: array[0..4] of string;
  SheetId, I: Integer;
  Rows: TJSONArray;
  DefinedNames: TDictionary<string, string>;
  Stage: string;
begin
  Stage := 'начало выгрузки';
  LogReportStage(Stage);
  if not FileExists(ASourceFileName) then
    raise EFileNotFoundException.CreateFmt('Шаблон не найден: %s', [ASourceFileName]);
  if ARoot = nil then
    raise EArgumentNilException.Create(
      'Не заданы данные для формирования служебных листов отчёта');

  TempDir := TPath.Combine(TPath.GetTempPath,
    'FlowServiceReport_' + TPath.GetRandomFileName.Replace('.', ''));
  ForceDirectories(TempDir);
  TempOutput := AOutputFileName + '.tmp';
  DefinedNames := TDictionary<string, string>.Create;
  try
    try
    Stage := 'распаковка XLSX';
    LogReportStage(Stage);
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

    Stage := 'чтение workbook.xml';
    LogReportStage(Stage);
    WorkbookXml := ReadUtf8File(WorkbookFile);
    ValidateWorkbookXmlText(WorkbookXml, 'чтение исходного шаблона', False);
    ValidateWorkbookXml(WorkbookXml, 'чтение исходного шаблона');
    ContentTypesXml := ReadUtf8File(ContentTypesFile);
    RemoveLegacyReportTableArtifacts(TempDir, ContentTypesXml);
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

    for I := Low(CSheetNames) to High(CSheetNames) do
    begin
      Stage := 'обработка служебного листа ' + CSheetNames[I];
      LogReportStage(Stage);
      RelationId := FindSheetRelationId(WorkbookXml, CSheetNames[I]);
      if RelationId = '' then
      begin
        SheetId := NextSheetId(WorkbookXml);
        RelationId := NextRelationId(WorkbookRelsRoot);
        SheetTargets[I] := CSheetTargets[I];
        SheetFragment := Format(
          '<sheet name="%s" sheetId="%d" r:id="%s"/>',
          [CSheetNames[I], SheetId, RelationId]);
        UpdatedWorkbookXml := InsertBeforeClosingTag(
          WorkbookXml, '</sheets>', SheetFragment);
        ValidateWorkbookXmlText(UpdatedWorkbookXml,
          'добавление листа ' + CSheetNames[I], False);
        ValidateWorkbookXml(UpdatedWorkbookXml,
          'добавление листа ' + CSheetNames[I]);
        WorkbookXml := UpdatedWorkbookXml;
        AddWorksheetRelationship(WorkbookRelsRoot, RelationId, SheetTargets[I]);
        ContentTypeFragment := Format(
          '<Override PartName="/xl/%s" ContentType="%s"/>',
          [SheetTargets[I], CWorksheetContentType]);
        UpdatedContentTypesXml := InsertBeforeClosingTag(
          ContentTypesXml, '</Types>', ContentTypeFragment);
        ContentTypesXml := UpdatedContentTypesXml;
      end
      else
      begin
        SheetTargets[I] := FindRelationshipTarget(WorkbookRelsRoot, RelationId);
        if SheetTargets[I] = '' then
          raise EInvalidOpException.CreateFmt(
            'Не найдена связь служебного листа %s', [CSheetNames[I]]);
      end;

      SheetArchivePath := WorkbookTargetToArchivePath(SheetTargets[I]);
      SheetFiles[I] := TPath.Combine(TempDir,
        StringReplace(SheetArchivePath, '/', PathDelim, [rfReplaceAll]));
      SheetFile := TPath.Combine(ExtractFileDir(SheetFiles[I]), '_rels\' +
        ExtractFileName(SheetFiles[I]) + '.rels');
      if FileExists(SheetFile) then
        DeleteFile(SheetFile);
    end;

    UpdatedWorkbookXml := EnsureAutomaticCalculation(WorkbookXml);
    ValidateWorkbookXmlText(UpdatedWorkbookXml,
      'EnsureAutomaticCalculation', True);
    ValidateWorkbookXml(UpdatedWorkbookXml, 'EnsureAutomaticCalculation');
    WorkbookXml := UpdatedWorkbookXml;

    Rows := ARoot.GetValue<TJSONArray>('Rows');
    if Rows = nil then
      raise EInvalidOpException.Create(
        'В данных отчёта отсутствует массив Rows');
    Stage := 'формирование листа _Data';
    LogReportStage(Stage);
    SheetXml[0] := BuildDataWorksheetXml(CSheetTitles[0], Rows, DefinedNames);
    Stage := 'формирование листа _DevicePoints';
    LogReportStage(Stage);
    SheetXml[1] := BuildSeparatedWorksheetXml(CSheetTitles[1], CSheetNames[1],
      Rows, ['DevicePoint'], DefinedNames);
    Stage := 'формирование листа _Spillages';
    LogReportStage(Stage);
    SheetXml[2] := BuildSeparatedWorksheetXml(CSheetTitles[2], CSheetNames[2],
      Rows, ['Spillage'], DefinedNames);
    Stage := 'формирование листа _CoefTables';
    LogReportStage(Stage);
    SheetXml[3] := BuildSeparatedWorksheetXml(CSheetTitles[3], CSheetNames[3],
      Rows, ['CalibrCoefTable', 'CalibrCoefItem'], DefinedNames);
    Stage := 'формирование листа _Meta';
    LogReportStage(Stage);
    SheetXml[4] := BuildMetaWorksheetXml(ARoot, DefinedNames);

    UpdateReportDefinedNames(WorkbookXml, DefinedNames);
    ValidateWorkbookXmlText(WorkbookXml, 'именованные диапазоны', True);
    ValidateWorkbookXml(WorkbookXml, 'именованные диапазоны');

    for I := Low(CSheetNames) to High(CSheetNames) do
      ValidateSeparatedWorksheetXml(SheetXml[I], CSheetNames[I]);
    for I := Low(CSheetNames) to High(CSheetNames) do
    begin
      Stage := 'запись XML листа ' + CSheetNames[I];
      LogReportStage(Stage);
      WriteUtf8File(SheetFiles[I], SheetXml[I]);
    end;
    WriteUtf8File(WorkbookFile, WorkbookXml);
    WorkbookRelsDocument.SaveToFile(WorkbookRelsFile);
    WriteUtf8File(ContentTypesFile, ContentTypesXml);

    if FileExists(TempOutput) then
      DeleteFile(TempOutput);
    Stage := 'упаковка XLSX';
    LogReportStage(Stage);
    ZipDirectory(TempDir, TempOutput);
    ForceDirectories(ExtractFileDir(AOutputFileName));
    Stage := 'замена итогового файла';
    LogReportStage(Stage);
    if FileExists(AOutputFileName) and not DeleteFile(AOutputFileName) then
      raise EInOutError.CreateFmt('Не удалось заменить файл %s', [AOutputFileName]);
    if not RenameFile(TempOutput, AOutputFileName) then
      raise EInOutError.CreateFmt('Не удалось сохранить файл %s', [AOutputFileName]);
    Stage := 'завершение выгрузки';
    LogReportStage(Stage);
    except
      on E: Exception do
      begin
        LogReportStage(Format('ошибка на этапе "%s": %s', [Stage, E.Message]));
        raise;
      end;
    end;
  finally
    DefinedNames.Free;
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
  EmptyDevice: TDevice;
  EmptyDeviceType: TDeviceType;
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

  { Экземпляры без данных дают RTTI полную схему _Data уже
    при импорте; значения будут заменены при экспорте. }
  EmptyDevice := TDevice.Create;
  EmptyDeviceType := TDeviceType.Create;
  try
    EmptyJson := BuildReportJson(EmptyDevice, EmptyDeviceType);
    try
      InjectDataSheet(ASourceFileName, Result, EmptyJson);
    finally
      EmptyJson.Free;
    end;
  finally
    EmptyDeviceType.Free;
    EmptyDevice.Free;
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
