unit uResultsXlsxExporter;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, uOpenXmlXlsx;

type
  TResultsExportSession = record
    ID, WorkTable, Mode, Status: string;
    OpenedAt: TDateTime;
  end;
  TResultsExportDevice = record
    Name, SerialNumber, UUID, Channel, DeviceType, Status, SessionID: string;
  end;
  TResultsExportPointParticipant = record
    DeviceUUID, SourcePointUUID: string;
  end;
  TResultsExportPointColumn = class
  public
    Key, Header: string;
    Participants: TList<TResultsExportPointParticipant>;
    constructor Create;
    destructor Destroy; override;
  end;
  TResultsExportPointCell = record
    DeviceUUID, PointColumnKey: string;
    Error: Double;
    ErrorSet: Boolean;
  end;
  TResultsExportResult = record
    DeviceName, SerialNumber, DeviceUUID, SessionID, PointName: string;
    EtalonName, EtalonUUID, Status, DeviceUnitName: string;
    ReferenceFlow, DeviceValue, Error: Double;
    PointAllowedError: Double;    // Allowed error from the associated TDevicePoint, in percentage points.
    PointAllowedErrorSet: Boolean;
    Valid: Boolean;
    MeasuredAt: TDateTime;
  end;

  { Carries a visual-component-free snapshot of domain values prepared for XLSX. }
  TResultsExportData = class
  public
    Sessions: TList<TResultsExportSession>;
    Devices: TList<TResultsExportDevice>;
    Results: TList<TResultsExportResult>;
    PointColumns: TObjectList<TResultsExportPointColumn>;
    PointCells: TList<TResultsExportPointCell>;
    FlowUnitName: string;
    FlowDimensionIndex: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TResultsXlsxExporter = class
  private
    class procedure PrepareSheet(ASheet: TOpenXmlWorksheet;
      const AWidths: array of Double); static;
    class procedure ValidateExportLabels; static;
  public
    class procedure ExportToFile(AData: TResultsExportData;
      const AFileName: string); static;
  end;

{ Excel percent cells store a fraction, while domain errors are percentage points. }
function PercentPointsToExcelFraction(const AValue: Double): Double;

implementation

uses
  uDebugLog;

const
  { Unicode codes keep system labels independent of PAS-file and RAD Studio encodings. }
  SWorksheetSession = #$0421#$0435#$0441#$0441#$0438#$044F;
  SWorksheetDevices = #$041F#$0440#$0438#$0431#$043E#$0440#$044B;
  SDeviceFallback = #$041F#$0440#$0438#$0431#$043E#$0440;
  SHeaderSessionID = #$0049#$0044#$0020#$0441#$0435#$0441#$0441#$0438#$0438;
  SHeaderDateTime = #$0414#$0430#$0442#$0430#$0020#$0438#$0020#$0432#$0440#$0435#$043C#$044F;
  SHeaderWorkTable = #$0420#$0430#$0431#$043E#$0447#$0438#$0439#$0020#$0441#$0442#$043E#$043B;
  SHeaderMode = #$0420#$0435#$0436#$0438#$043C#$0020#$0438#$0437#$043C#$0435#$0440#$0435#$043D#$0438#$044F;
  SHeaderStatus = #$0421#$0442#$0430#$0442#$0443#$0441;
  SHeaderName = #$041D#$0430#$0437#$0432#$0430#$043D#$0438#$0435;
  SHeaderSerial = #$0421#$0435#$0440#$0438#$0439#$043D#$044B#$0439#$0020#$043D#$043E#$043C#$0435#$0440;
  SHeaderUuid = #$0055#$0055#$0049#$0044;
  SHeaderChannel = #$041A#$0430#$043D#$0430#$043B;
  SHeaderDeviceType = #$0422#$0438#$043F#$0020#$043F#$0440#$0438#$0431#$043E#$0440#$0430;
  SHeaderActiveSessionID = #$0049#$0044#$0020#$0430#$043A#$0442#$0438#$0432#$043D#$043E#$0439#$0020#$0441#$0435#$0441#$0441#$0438#$0438;
  SHeaderResultSheet = #$041B#$0438#$0441#$0442#$0020#$0440#$0435#$0437#$0443#$043B#$044C#$0442#$0430#$0442#$043E#$0432;
  SHeaderNumber = #$2116;
  SHeaderPointName = #$041D#$0430#$0437#$0432#$0430#$043D#$0438#$0435#$0020#$0442#$043E#$0447#$043A#$0438;
  SHeaderReferenceFlow = #$0420#$0430#$0441#$0445#$043E#$0434#$0020#$044D#$0442#$0430#$043B#$043E#$043D#$0430;
  SHeaderEtalon = #$042D#$0442#$0430#$043B#$043E#$043D;
  SHeaderEtalonUuid = #$0055#$0055#$0049#$0044#$0020#$044D#$0442#$0430#$043B#$043E#$043D#$0430;
  SHeaderDeviceValue = #$0417#$043D#$0430#$0447#$0435#$043D#$0438#$0435#$0020#$043F#$0440#$0438#$0431#$043E#$0440#$0430;
  SHeaderResultError = #$041F#$043E#$0433#$0440#$0435#$0448#$043D#$043E#$0441#$0442#$044C#$0020#$0440#$0435#$0437#$0443#$043B#$044C#$0442#$0430#$0442#$0430;
  SHeaderPointError = #$041F#$043E#$0433#$0440#$0435#$0448#$043D#$043E#$0441#$0442#$044C#$0020#$0442#$043E#$0447#$043A#$0438;
  SHeaderValidity = #$0412#$0430#$043B#$0438#$0434#$043D#$043E#$0441#$0442#$044C;

function PercentPointsToExcelFraction(const AValue: Double): Double;
begin
  Result := AValue / 100;
end;

function SafeSheetBase(const AName: string; const AIndex: Integer): string;
var C: Char;
begin
  Result := Trim(AName);
  for C in ['\', '/', '?', '*', '[', ']', ':'] do
    Result := StringReplace(Result, C, ' ', [rfReplaceAll]);
  Result := Trim(Result);
  while (Result <> '') and (Result[1] = '''') do Delete(Result, 1, 1);
  while (Result <> '') and (Result[Length(Result)] = '''') do Delete(Result, Length(Result), 1);
  Result := Trim(Result);
  if Result = '' then Result := SDeviceFallback + ' ' + IntToStr(AIndex + 1);
end;

function UniqueSheetName(const ABase: string; AUsed: TList<string>): string;
var N, I: Integer; Suffix, Candidate: string; Exists: Boolean;
begin
  N := 1;
  repeat
    if N = 1 then Suffix := '' else Suffix := Format(' (%d)', [N]);
    Candidate := Copy(ABase, 1, 31 - Length(Suffix)) + Suffix;
    Exists := False;
    for I := 0 to AUsed.Count - 1 do
      if SameText(AUsed[I], Candidate) then begin Exists := True; Break; end;
    Inc(N);
  until not Exists;
  AUsed.Add(Candidate);
  Result := Candidate;
end;

class procedure TResultsXlsxExporter.ValidateExportLabels;
const
  Mojibake: array[0..5] of string = (#$0420#$040E, #$0420#$045F,
    #$0420#$00B5, #$0420#$201D, #$0420#$00B0, #$0421#$0403);
  Names: array[0..23] of string = ('SWorksheetSession', 'SWorksheetDevices',
    'SDeviceFallback', 'SHeaderSessionID', 'SHeaderDateTime', 'SHeaderWorkTable',
    'SHeaderMode', 'SHeaderStatus', 'SHeaderName', 'SHeaderSerial', 'SHeaderUuid',
    'SHeaderChannel', 'SHeaderDeviceType', 'SHeaderActiveSessionID',
    'SHeaderResultSheet', 'SHeaderNumber', 'SHeaderPointName',
    'SHeaderReferenceFlow', 'SHeaderEtalon', 'SHeaderEtalonUuid',
    'SHeaderDeviceValue', 'SHeaderResultError', 'SHeaderPointError',
    'SHeaderValidity');
  Values: array[0..23] of string = (SWorksheetSession, SWorksheetDevices,
    SDeviceFallback, SHeaderSessionID, SHeaderDateTime, SHeaderWorkTable,
    SHeaderMode, SHeaderStatus, SHeaderName, SHeaderSerial, SHeaderUuid,
    SHeaderChannel, SHeaderDeviceType, SHeaderActiveSessionID,
    SHeaderResultSheet, SHeaderNumber, SHeaderPointName,
    SHeaderReferenceFlow, SHeaderEtalon, SHeaderEtalonUuid,
    SHeaderDeviceValue, SHeaderResultError, SHeaderPointError,
    SHeaderValidity);
var I, J: Integer;
begin
  for I := Low(Values) to High(Values) do
    for J := Low(Mojibake) to High(Mojibake) do
      if Pos(Mojibake[J], Values[I]) > 0 then
        raise EEncodingError.CreateFmt('Invalid encoding in export label %s', [Names[I]]);
end;

constructor TResultsExportData.Create;
begin
  inherited;
  Sessions := TList<TResultsExportSession>.Create;
  Devices := TList<TResultsExportDevice>.Create;
  Results := TList<TResultsExportResult>.Create;
  PointColumns := TObjectList<TResultsExportPointColumn>.Create(True);
  PointCells := TList<TResultsExportPointCell>.Create;
  FlowDimensionIndex := -1;
end;

destructor TResultsExportData.Destroy;
begin
  PointCells.Free; PointColumns.Free; Results.Free; Devices.Free; Sessions.Free; inherited;
end;

constructor TResultsExportPointColumn.Create;
begin
  inherited;
  Participants := TList<TResultsExportPointParticipant>.Create;
end;

destructor TResultsExportPointColumn.Destroy;
begin
  Participants.Free;
  inherited;
end;

class procedure TResultsXlsxExporter.PrepareSheet(ASheet: TOpenXmlWorksheet;
  const AWidths: array of Double);
var I: Integer;
begin
  ASheet.FreezeFirstRow;
  ASheet.EnableAutoFilter;
  for I := 0 to High(AWidths) do ASheet.SetColumnWidth(I + 1, AWidths[I]);
end;

class procedure TResultsXlsxExporter.ExportToFile(AData: TResultsExportData;
  const AFileName: string);
var
  W: TOpenXmlWorkbook; S: TOpenXmlWorksheet; I, C, ResultCount, Row: Integer;
  SS: TResultsExportSession; D: TResultsExportDevice; R: TResultsExportResult;
  PC: TResultsExportPointColumn; Cell: TResultsExportPointCell;
  H: TArray<string>; UsedNames, DeviceSheets: TList<string>;
  BaseName, SheetName, DeviceValueHeader: string;
begin
  if AData = nil then raise EArgumentNilException.Create('AData');
  ValidateExportLabels;
  W := TOpenXmlWorkbook.Create;
  UsedNames := TList<string>.Create;
  DeviceSheets := TList<string>.Create;
  try
    UsedNames.Add(SWorksheetSession); UsedNames.Add(SWorksheetDevices);
    for I := 0 to AData.Devices.Count - 1 do begin
      D := AData.Devices[I]; ResultCount := 0;
      for R in AData.Results do if SameText(R.DeviceUUID, D.UUID) then Inc(ResultCount);
      if ResultCount = 0 then DeviceSheets.Add('')
      else begin
        BaseName := SafeSheetBase(Trim(D.Name + ' ' + D.SerialNumber), I);
        DeviceSheets.Add(UniqueSheetName(BaseName, UsedNames));
      end;
    end;

    S := W.AddWorksheet(SWorksheetSession); PrepareSheet(S, [20, 20, 24, 20, 18]);
    H := TArray<string>.Create(SHeaderSessionID,SHeaderDateTime,SHeaderWorkTable,SHeaderMode,SHeaderStatus);
    for C := 0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I := 0 to AData.Sessions.Count-1 do begin SS:=AData.Sessions[I]; S.WriteString(I+2,1,SS.ID); if SS.OpenedAt<>0 then S.WriteDateTime(I+2,2,SS.OpenedAt); S.WriteString(I+2,3,SS.WorkTable); S.WriteString(I+2,4,SS.Mode); S.WriteString(I+2,5,SS.Status,xsBooleanStatus); end;

    S := W.AddWorksheet(SWorksheetDevices); PrepareSheet(S, [24,18,40,12,24,18,20,31]);
    for C := 0 to AData.PointColumns.Count - 1 do S.SetColumnWidth(9 + C, 16);
    H := TArray<string>.Create(SHeaderName,SHeaderSerial,SHeaderUuid,SHeaderChannel,SHeaderDeviceType,SHeaderStatus,SHeaderActiveSessionID,SHeaderResultSheet);
    for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for C := 0 to AData.PointColumns.Count - 1 do begin
      PC := AData.PointColumns[C];
      S.WriteString(1, 9 + C, PC.Header, xsHeader);
    end;
    for I:=0 to AData.Devices.Count-1 do begin
      D:=AData.Devices[I]; S.WriteString(I+2,1,D.Name); S.WriteString(I+2,2,D.SerialNumber); S.WriteString(I+2,3,D.UUID,xsUuid); S.WriteString(I+2,4,D.Channel); S.WriteString(I+2,5,D.DeviceType); S.WriteString(I+2,6,D.Status,xsBooleanStatus); S.WriteString(I+2,7,D.SessionID); S.WriteString(I+2,8,DeviceSheets[I]);
      for C := 0 to AData.PointColumns.Count - 1 do
        for Cell in AData.PointCells do
          if Cell.ErrorSet and SameText(Cell.DeviceUUID, D.UUID) and
             SameText(Cell.PointColumnKey, AData.PointColumns[C].Key) then begin
            S.WriteNumber(I+2, 9+C, PercentPointsToExcelFraction(Cell.Error), xsError);
            Break;
          end;
    end;

    for I := 0 to AData.Devices.Count - 1 do begin
      SheetName := DeviceSheets[I]; if SheetName = '' then Continue;
      D := AData.Devices[I]; ResultCount := 0;
      for R in AData.Results do if SameText(R.DeviceUUID, D.UUID) then Inc(ResultCount);
      S := W.AddWorksheet(SheetName); PrepareSheet(S,[8,26,23,24,40,24,22,22,18,14,22]);
      DeviceValueHeader := SHeaderDeviceValue;
      for R in AData.Results do if SameText(R.DeviceUUID, D.UUID) then begin
        if R.DeviceUnitName <> '' then DeviceValueHeader := DeviceValueHeader + ', ' + R.DeviceUnitName;
        Break;
      end;
      H:=TArray<string>.Create(SHeaderNumber,SHeaderPointName,
        SHeaderReferenceFlow+', '+AData.FlowUnitName,SHeaderEtalon,SHeaderEtalonUuid,
        DeviceValueHeader,SHeaderResultError,SHeaderPointError,SHeaderStatus,
        SHeaderValidity,SHeaderDateTime);
      for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
      Row := 2;
      for R in AData.Results do if SameText(R.DeviceUUID, D.UUID) then begin
        S.WriteNumber(Row,1,Row-1); S.WriteString(Row,2,R.PointName);
        S.WriteNumber(Row,3,R.ReferenceFlow,xsFlow); S.WriteString(Row,4,R.EtalonName);
        S.WriteString(Row,5,R.EtalonUUID,xsUuid); S.WriteNumber(Row,6,R.DeviceValue,xsFlow);
        S.WriteNumber(Row,7,PercentPointsToExcelFraction(R.Error),xsError);
        if R.PointAllowedErrorSet then S.WriteNumber(Row,8,
          PercentPointsToExcelFraction(R.PointAllowedError),xsError);
        S.WriteString(Row,9,R.Status,xsBooleanStatus); S.WriteBoolean(Row,10,R.Valid);
        if R.MeasuredAt<>0 then S.WriteDateTime(Row,11,R.MeasuredAt); Inc(Row);
      end;
      DebugLog(Format('ResultsXlsxDeviceSheet Name=%s Results=%d', [SheetName, ResultCount]));
    end;
    DebugLog(Format('ResultsXlsxLayout FlowUnit=%s FlowDimensionIndex=%d Devices=%d DeviceSheets=%d PointColumns=%d DevicesSheetColumns=%d ErrorSourceUnit=PercentPoints ErrorExcelUnit=Fraction',
      [AData.FlowUnitName, AData.FlowDimensionIndex, AData.Devices.Count,
       W.Worksheets.Count - 2, AData.PointColumns.Count, 8 + AData.PointColumns.Count]));
    W.SaveToFile(AFileName);
  finally
    DeviceSheets.Free; UsedNames.Free; W.Free;
  end;
end;

end.
