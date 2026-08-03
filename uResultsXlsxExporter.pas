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
  public
    class procedure ExportToFile(AData: TResultsExportData;
      const AFileName: string); static;
  end;

implementation

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
  W := TOpenXmlWorkbook.Create;
  try
    S := W.AddWorksheet('Сессия'); PrepareSheet(S, [20, 20, 24, 20, 18]);
    H := TArray<string>.Create('ID сессии','Дата и время','Рабочий стол','Режим измерения','Статус');
    for C := 0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I := 0 to AData.Sessions.Count-1 do begin SS:=AData.Sessions[I]; S.WriteString(I+2,1,SS.ID); if SS.OpenedAt<>0 then S.WriteDateTime(I+2,2,SS.OpenedAt); S.WriteString(I+2,3,SS.WorkTable); S.WriteString(I+2,4,SS.Mode); S.WriteString(I+2,5,SS.Status,xsBooleanStatus); end;
    S := W.AddWorksheet('Приборы'); PrepareSheet(S, [24,18,40,12,24,18,20]);
    H := TArray<string>.Create('Название','Серийный номер','UUID','Канал','Тип прибора','Статус','ID активной сессии'); for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I:=0 to AData.Devices.Count-1 do begin D:=AData.Devices[I]; S.WriteString(I+2,1,D.Name); S.WriteString(I+2,2,D.SerialNumber); S.WriteString(I+2,3,D.UUID,xsUuid); S.WriteString(I+2,4,D.Channel); S.WriteString(I+2,5,D.DeviceType); S.WriteString(I+2,6,D.Status,xsBooleanStatus); S.WriteString(I+2,7,D.SessionID); end;
    S := W.AddWorksheet('Результаты'); PrepareSheet(S,[10,24,18,40,20,24,18,24,40,18,18,18,12,20]);
    H:=TArray<string>.Create('№','Прибор','Серийный номер','UUID прибора','ID сессии','Название точки','Расход эталона','Эталон','UUID эталона','Значение прибора','Погрешность','Статус','Валидность','Дата и время'); for C:=0 to High(H) do S.WriteString(1,C+1,H[C],xsHeader);
    for I:=0 to AData.Results.Count-1 do begin R:=AData.Results[I]; S.WriteNumber(I+2,1,I+1); S.WriteString(I+2,2,R.DeviceName); S.WriteString(I+2,3,R.SerialNumber); S.WriteString(I+2,4,R.DeviceUUID,xsUuid); S.WriteString(I+2,5,R.SessionID); S.WriteString(I+2,6,R.PointName); S.WriteNumber(I+2,7,R.ReferenceFlow,xsFlow); S.WriteString(I+2,8,R.EtalonName); S.WriteString(I+2,9,R.EtalonUUID,xsUuid); S.WriteNumber(I+2,10,R.DeviceValue,xsFlow); S.WriteNumber(I+2,11,R.Error,xsError); S.WriteString(I+2,12,R.Status,xsBooleanStatus); S.WriteBoolean(I+2,13,R.Valid); if R.MeasuredAt<>0 then S.WriteDateTime(I+2,14,R.MeasuredAt); end;
    W.SaveToFile(AFileName);
  finally W.Free; end;
end;

end.
