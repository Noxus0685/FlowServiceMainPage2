unit uResultsXlsxExporter;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  uDeviceClass,
  uWorkTable;

type
  TResultsExportScope = (resSelectedDevice, resAllDevices);

  TResultsXlsxExporter = class
  private
    class procedure CollectDevices(AWorkTable: TWorkTable; ASelectedDevice: TDevice;
      ADevices: TList<TDevice>); static;
  public
    /// Returns True when the requested scope contains at least one saved result.
    class function CanExport(AWorkTable: TWorkTable;
      ASelectedDevice: TDevice = nil): Boolean; static;
    /// Writes prepared domain results to a real Office Open XML workbook.
    class procedure ExportToFile(AWorkTable: TWorkTable; ASelectedDevice: TDevice;
      const AFileName: string); static;
  end;

implementation

uses
  System.Classes,
  System.Diagnostics,
  System.Math,
  FlexCel.Core,
  FlexCel.XlsAdapter,
  uProtocols;

const
  CDateTimeFormat = 'dd.mm.yyyy hh:mm:ss';
  CNumberFormat = '0.000';
  CErrorFormat = '0.000\%';

class procedure TResultsXlsxExporter.CollectDevices(AWorkTable: TWorkTable;
  ASelectedDevice: TDevice; ADevices: TList<TDevice>);
var
  Channel: TChannel;
  Device: TDevice;
begin
  ADevices.Clear;
  if ASelectedDevice <> nil then
  begin
    ADevices.Add(ASelectedDevice);
    Exit;
  end;
  if (AWorkTable = nil) or (AWorkTable.DeviceChannels = nil) then
    Exit;
  for Channel in AWorkTable.DeviceChannels do
    if (Channel <> nil) and (Channel.FlowMeter <> nil) then
    begin
      Device := Channel.FlowMeter.Device;
      if (Device <> nil) and (ADevices.IndexOf(Device) < 0) then
        ADevices.Add(Device);
    end;
end;

class function TResultsXlsxExporter.CanExport(AWorkTable: TWorkTable;
  ASelectedDevice: TDevice): Boolean;
var
  Devices: TList<TDevice>;
  Device: TDevice;
  Session: TSessionSpillage;
begin
  Result := False;
  Devices := TList<TDevice>.Create;
  try
    CollectDevices(AWorkTable, ASelectedDevice, Devices);
    for Device in Devices do
    begin
      Session := Device.GetActiveSessionSpillage;
      if (Session <> nil) and (Session.Spillages <> nil) and
         (Session.Spillages.Count > 0) then
        Exit(True);
    end;
  finally
    Devices.Free;
  end;
end;

class procedure TResultsXlsxExporter.ExportToFile(AWorkTable: TWorkTable;
  ASelectedDevice: TDevice; const AFileName: string);
var
  Xls: TXlsFile;
  Devices: TList<TDevice>;
  Device: TDevice;
  Session: TSessionSpillage;
  Spillage: TPointSpillage;
  Point: TDevicePoint;
  Channel: TChannel;
  DeviceCount, ResultCount, Row, Col, SessionCount: Integer;
  Scope, SessionIDs, ErrorText: string;
  Timer: TStopwatch;

  procedure SetHeaders(const Values: array of string);
  var
    I: Integer;
    Fmt: TFlxFormat;
  begin
    Fmt := Xls.GetDefaultFormat;
    Fmt.Font.Style := [TFlxFontStyles.Bold];
    Fmt.FillPattern.Pattern := TFlxPatternStyle.Solid;
    Fmt.FillPattern.FgColor := TExcelColor.FromArgb($FFD9EAF7);
    Fmt.WrapText := True;
    Fmt.Borders.Left.Style := TFlxBorderStyle.Thin;
    Fmt.Borders.Right.Style := TFlxBorderStyle.Thin;
    Fmt.Borders.Top.Style := TFlxBorderStyle.Thin;
    Fmt.Borders.Bottom.Style := TFlxBorderStyle.Thin;
    for I := Low(Values) to High(Values) do
    begin
      Xls.SetCellValue(1, I + 1, Values[I]);
      Xls.SetCellFormat(1, I + 1, Fmt);
      Xls.SetColWidth(I + 1, 4200);
    end;
    Xls.FreezePanes(2, 1);
  end;

  procedure SetDate(const ARow, ACol: Integer; const Value: TDateTime);
  var
    Fmt: TFlxFormat;
  begin
    if Value = 0 then
      Exit;
    Xls.SetCellValue(ARow, ACol, Value);
    Fmt := Xls.GetCellVisibleFormatDef(ARow, ACol);
    Fmt.Format := CDateTimeFormat;
    Xls.SetCellFormat(ARow, ACol, Fmt);
  end;

  procedure SetNumber(const ARow, ACol: Integer; const Value: Double;
    const AFormat: string = CNumberFormat);
  var
    Fmt: TFlxFormat;
  begin
    Xls.SetCellValue(ARow, ACol, Value);
    Fmt := Xls.GetCellVisibleFormatDef(ARow, ACol);
    Fmt.Format := AFormat;
    Xls.SetCellFormat(ARow, ACol, Fmt);
  end;

  function ChannelName(ADevice: TDevice): string;
  begin
    Result := '';
    if (AWorkTable = nil) or (AWorkTable.DeviceChannels = nil) then
      Exit;
    for Channel in AWorkTable.DeviceChannels do
      if (Channel <> nil) and (Channel.FlowMeter <> nil) and
         (Channel.FlowMeter.Device = ADevice) then
        Exit(Channel.Name);
  end;

  function MeasurementModeName: string;
  begin
    case AWorkTable.MeasurementMode of
      mrmManual: Result := 'Ручной';
      mrmHalfAutomatic: Result := 'Полуавтоматический';
      mrmAutomatic: Result := 'Автоматический';
    else
      Result := '';
    end;
  end;

  procedure FinishSheet(const ALastRow, ALastCol: Integer);
  begin
    if ALastRow > 1 then
      Xls.SetAutoFilter(TXlsCellRange.Create(1, 1, ALastRow, ALastCol));
  end;

begin
  Devices := TList<TDevice>.Create;
  Xls := nil;
  Timer := TStopwatch.StartNew;
  ErrorText := '';
  Scope := 'AllDevices';
  if ASelectedDevice <> nil then
    Scope := 'SelectedDevice';
  try
    CollectDevices(AWorkTable, ASelectedDevice, Devices);
    DeviceCount := Devices.Count;
    ResultCount := 0;
    SessionCount := 0;
    SessionIDs := '';
    for Device in Devices do
    begin
      Session := Device.GetActiveSessionSpillage;
      if Session <> nil then
      begin
        Inc(SessionCount);
        if SessionIDs <> '' then SessionIDs := SessionIDs + ',';
        SessionIDs := SessionIDs + IntToStr(Session.ID);
        if Session.Spillages <> nil then
          Inc(ResultCount, Session.Spillages.Count);
      end;
    end;
    if (DeviceCount = 0) or (ResultCount = 0) then
      raise EInvalidOperation.Create('Нет результатов для экспорта');

    ProtocolManager.AddMessage(pcAction, psForm, 'ResultsXlsxExportRequested',
      'Запрошен экспорт результатов в Excel',
      Format('Scope=%s; FileName=%s; SessionIDs=%s; Devices=%d; Results=%d',
        [Scope, ExpandFileName(AFileName), SessionIDs, DeviceCount, ResultCount]));

    Xls := TXlsFile.Create(1, True);
    Xls.NewFile(3);

    Xls.ActiveSheet := 1;
    Xls.SheetName := 'Сессия';
    SetHeaders(['ID сессии', 'Дата и время открытия', 'Дата и время закрытия',
      'Рабочий стол', 'Режим измерения', 'Статус', 'Оператор', 'Прибор UUID']);
    Row := 2;
    for Device in Devices do
    begin
      Session := Device.GetActiveSessionSpillage;
      if Session = nil then Continue;
      Xls.SetCellValue(Row, 1, Session.ID);
      SetDate(Row, 2, Session.DateTimeOpen);
      SetDate(Row, 3, Session.DateTimeClose);
      Xls.SetCellValue(Row, 4, AWorkTable.Name);
      Xls.SetCellValue(Row, 5, MeasurementModeName);
      Xls.SetCellValue(Row, 6, Session.Status);
      Xls.SetCellValue(Row, 7, Session.OperatorName);
      Xls.SetCellValue(Row, 8, Session.DeviceUUID);
      Inc(Row);
    end;
    FinishSheet(Row - 1, 8);

    Xls.ActiveSheet := 2;
    Xls.SheetName := 'Приборы';
    SetHeaders(['Название', 'Серийный номер', 'UUID', 'Канал', 'Тип прибора',
      'Статус', 'ID активной сессии']);
    Row := 2;
    for Device in Devices do
    begin
      Session := Device.GetActiveSessionSpillage;
      Xls.SetCellValue(Row, 1, Device.Name);
      Xls.SetCellValue(Row, 2, Device.SerialNumber);
      Xls.SetCellValue(Row, 3, Device.UUID);
      Xls.SetCellValue(Row, 4, ChannelName(Device));
      Xls.SetCellValue(Row, 5, Device.DeviceTypeName);
      Xls.SetCellValue(Row, 6, Device.Status);
      if Session <> nil then Xls.SetCellValue(Row, 7, Session.ID);
      Inc(Row);
    end;
    FinishSheet(Row - 1, 7);

    Xls.ActiveSheet := 3;
    Xls.SheetName := 'Результаты';
    SetHeaders(['Номер', 'Прибор', 'Серийный номер', 'UUID прибора', 'ID сессии',
      'Название точки', 'Расход эталона', 'Эталон', 'UUID эталона',
      'Значение прибора', 'Погрешность', 'Статус', 'Валидность', 'Дата и время']);
    Row := 2;
    for Device in Devices do
    begin
      Session := Device.GetActiveSessionSpillage;
      if (Session = nil) or (Session.Spillages = nil) then Continue;
      for Spillage in Session.Spillages do
      begin
        Point := Device.FindMatchedDevicePointForSpillage(Spillage);
        Xls.SetCellValue(Row, 1, Spillage.Num);
        Xls.SetCellValue(Row, 2, Device.Name);
        Xls.SetCellValue(Row, 3, Device.SerialNumber);
        Xls.SetCellValue(Row, 4, Device.UUID);
        Xls.SetCellValue(Row, 5, Spillage.SessionID);
        if Point <> nil then Xls.SetCellValue(Row, 6, Point.Name);
        SetNumber(Row, 7, Spillage.QavgEtalon);
        Xls.SetCellValue(Row, 8, Spillage.EtalonName);
        Xls.SetCellValue(Row, 9, Spillage.EtalonUUID);
        SetNumber(Row, 10, Spillage.DeviceVolumeFlow);
        SetNumber(Row, 11, Spillage.Error, CErrorFormat);
        Xls.SetCellValue(Row, 12, Spillage.StatusStr);
        Xls.SetCellValue(Row, 13, Spillage.Valid);
        SetDate(Row, 14, Spillage.DateTime);
        Inc(Row);
      end;
    end;
    FinishSheet(Row - 1, 14);
    ForceDirectories(ExtractFileDir(ExpandFileName(AFileName)));
    Xls.Save(AFileName);
    Timer.Stop;
    ProtocolManager.AddMessage(pcInfo, psForm, 'ResultsXlsxExportCompleted',
      'Экспорт результатов в Excel завершён',
      Format('Scope=%s; FileName=%s; SessionIDs=%s; Devices=%d; Results=%d; DurationMs=%d',
        [Scope, ExpandFileName(AFileName), SessionIDs, DeviceCount, ResultCount,
         Timer.ElapsedMilliseconds]));
  except
    on E: Exception do
    begin
      Timer.Stop;
      ErrorText := E.Message;
      ProtocolManager.AddMessage(pcError, psForm, 'ResultsXlsxExportFailed',
        'Ошибка экспорта результатов в Excel',
        Format('Scope=%s; FileName=%s; SessionIDs=%s; Devices=%d; Results=%d; DurationMs=%d; Error=%s',
          [Scope, ExpandFileName(AFileName), SessionIDs, Devices.Count, ResultCount,
           Timer.ElapsedMilliseconds, ErrorText]));
      Xls.Free;
      Devices.Free;
      raise;
    end;
  end;
  Xls.Free;
  Devices.Free;
end;

end.
