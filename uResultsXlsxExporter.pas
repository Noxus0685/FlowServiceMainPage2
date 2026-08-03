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
  TResultsExportResult = record
    DeviceName, SerialNumber, DeviceUUID, SessionID, PointName: string;
    EtalonName, EtalonUUID, Status: string;
    ReferenceFlow, DeviceValue, Error: Double;
    Valid: Boolean;
    MeasuredAt: TDateTime;
  end;

  { Carries a visual-component-free snapshot of the prepared domain results. }
  TResultsExportData = class
  public
    Sessions: TList<TResultsExportSession>;
    Devices: TList<TResultsExportDevice>;
    Results: TList<TResultsExportResult>;
    constructor Create;
    destructor Destroy; override;
  end;

  { Maps result snapshot records onto the fixed three-sheet XLSX layout. }
  TResultsXlsxExporter = class
  private
    class procedure PrepareSheet(ASheet: TOpenXmlWorksheet;
      const AWidths: array of Double); static;
    class procedure ValidateExportLabels; static;
  public
    class procedure ExportToFile(AData: TResultsExportData;
      const AFileName: string); static;
  end;

implementation

const
  { Unicode codes keep system labels independent of PAS-file and RAD Studio encodings. }
  SWorksheetSession = #$0421#$0435#$0441#$0441#$0438#$044F;
  SWorksheetDevices = #$041F#$0440#$0438#$0431#$043E#$0440#$044B;
  SWorksheetResults = #$0420#$0435#$0437#$0443#$043B#$044C#$0442#$0430#$0442#$044B;
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
  SHeaderNumber = #$2116;
  SHeaderDevice = #$041F#$0440#$0438#$0431#$043E#$0440;
  SHeaderDeviceUuid = #$0055#$0055#$0049#$0044#$0020#$043F#$0440#$0438#$0431#$043E#$0440#$0430;
  SHeaderPointName = #$041D#$0430#$0437#$0432#$0430#$043D#$0438#$0435#$0020#$0442#$043E#$0447#$043A#$0438;
  SHeaderReferenceFlow = #$0420#$0430#$0441#$0445#$043E#$0434#$0020#$044D#$0442#$0430#$043B#$043E#$043D#$0430;
  SHeaderEtalon = #$042D#$0442#$0430#$043B#$043E#$043D;
  SHeaderEtalonUuid = #$0055#$0055#$0049#$0044#$0020#$044D#$0442#$0430#$043B#$043E#$043D#$0430;
  SHeaderDeviceValue = #$0417#$043D#$0430#$0447#$0435#$043D#$0438#$0435#$0020#$043F#$0440#$0438#$0431#$043E#$0440#$0430;
  SHeaderError = #$041F#$043E#$0433#$0440#$0435#$0448#$043D#$043E#$0441#$0442#$044C;
  SHeaderValidity = #$0412#$0430#$043B#$0438#$0434#$043D#$043E#$0441#$0442#$044C;

class procedure TResultsXlsxExporter.ValidateExportLabels;
const
  Mojibake: array[0..5] of string = (#$0420#$040E, #$0420#$045F,
    #$0420#$00B5, #$0420#$201D, #$0420#$00B0, #$0421#$0403);
  Names: array[0..23] of string = ('SWorksheetSession', 'SWorksheetDevices',
    'SWorksheetResults', 'SHeaderSessionID', 'SHeaderDateTime', 'SHeaderWorkTable',
    'SHeaderMode', 'SHeaderStatus', 'SHeaderName', 'SHeaderSerial', 'SHeaderUuid',
    'SHeaderChannel', 'SHeaderDeviceType', 'SHeaderActiveSessionID', 'SHeaderNumber',
    'SHeaderDevice', 'SHeaderDeviceUuid', 'SHeaderPointName', 'SHeaderReferenceFlow',
    'SHeaderEtalon', 'SHeaderEtalonUuid', 'SHeaderDeviceValue', 'SHeaderError',
    'SHeaderValidity');
  Values: array[0..23] of string = (SWorksheetSession, SWorksheetDevices,
    SWorksheetResults, SHeaderSessionID, SHeaderDateTime, SHeaderWorkTable,
    SHeaderMode, SHeaderStatus, SHeaderName, SHeaderSerial, SHeaderUuid,
    SHeaderChannel, SHeaderDeviceType, SHeaderActiveSessionID, SHeaderNumber,
    SHeaderDevice, SHeaderDeviceUuid, SHeaderPointName, SHeaderReferenceFlow,
    SHeaderEtalon, SHeaderEtalonUuid, SHeaderDeviceValue, SHeaderError,
    SHeaderValidity);
var
  I, J: Integer;
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
end;

destructor TResultsExportData.Destroy;
begin
  Results.Free; Devices.Free; Sessions.Free; inherited;
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
var W: TOpenXmlWorkbook; S: TOpenXmlWorksheet; I, C: Integer;
  SS: TResultsExportSession; D: TResultsExportDevice; R: TResultsExportResult;
  H: TArray<string>;
begin
  if AData = nil then raise EArgumentNilException.Create('AData');
  ValidateExportLabels;
  W := TOpenXmlWorkbook.Create;
  try
    S := W.AddWorksheet(SWorksheetSession); PrepareSheet(S, [20, 20, 24, 20, 18]);
    H := TArray<string>.Create(SHeaderSessionID,SHeaderDateTime,SHeaderWorkTable,SHeaderMode,SHeaderStatus);
    for C := 0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I := 0 to AData.Sessions.Count-1 do begin SS:=AData.Sessions[I]; S.WriteString(I+2,1,SS.ID); if SS.OpenedAt<>0 then S.WriteDateTime(I+2,2,SS.OpenedAt); S.WriteString(I+2,3,SS.WorkTable); S.WriteString(I+2,4,SS.Mode); S.WriteString(I+2,5,SS.Status,xsBooleanStatus); end;
    S := W.AddWorksheet(SWorksheetDevices); PrepareSheet(S, [24,18,40,12,24,18,20]);
    H := TArray<string>.Create(SHeaderName,SHeaderSerial,SHeaderUuid,SHeaderChannel,SHeaderDeviceType,SHeaderStatus,SHeaderActiveSessionID); for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I:=0 to AData.Devices.Count-1 do begin D:=AData.Devices[I]; S.WriteString(I+2,1,D.Name); S.WriteString(I+2,2,D.SerialNumber); S.WriteString(I+2,3,D.UUID,xsUuid); S.WriteString(I+2,4,D.Channel); S.WriteString(I+2,5,D.DeviceType); S.WriteString(I+2,6,D.Status,xsBooleanStatus); S.WriteString(I+2,7,D.SessionID); end;
    S := W.AddWorksheet(SWorksheetResults); PrepareSheet(S,[10,24,18,40,20,24,18,24,40,18,18,18,12,20]);
    H:=TArray<string>.Create(SHeaderNumber,SHeaderDevice,SHeaderSerial,SHeaderDeviceUuid,SHeaderSessionID,SHeaderPointName,SHeaderReferenceFlow,SHeaderEtalon,SHeaderEtalonUuid,SHeaderDeviceValue,SHeaderError,SHeaderStatus,SHeaderValidity,SHeaderDateTime); for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I:=0 to AData.Results.Count-1 do begin R:=AData.Results[I]; S.WriteNumber(I+2,1,I+1); S.WriteString(I+2,2,R.DeviceName); S.WriteString(I+2,3,R.SerialNumber); S.WriteString(I+2,4,R.DeviceUUID,xsUuid); S.WriteString(I+2,5,R.SessionID); S.WriteString(I+2,6,R.PointName); S.WriteNumber(I+2,7,R.ReferenceFlow,xsFlow); S.WriteString(I+2,8,R.EtalonName); S.WriteString(I+2,9,R.EtalonUUID,xsUuid); S.WriteNumber(I+2,10,R.DeviceValue,xsFlow); S.WriteNumber(I+2,11,R.Error,xsError); S.WriteString(I+2,12,R.Status,xsBooleanStatus); S.WriteBoolean(I+2,13,R.Valid); if R.MeasuredAt<>0 then S.WriteDateTime(I+2,14,R.MeasuredAt); end;
    W.SaveToFile(AFileName);
  finally W.Free; end;
end;

end.
