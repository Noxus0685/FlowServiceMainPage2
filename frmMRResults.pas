unit frmMRResults;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.Generics.Collections,
  System.DateUtils,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDeviceClass,
  uMeasurementRun,
  uObservable,
  uResultsXlsxExporter,
  uWorkTable;

type
  TMRResultCellState = (csEmpty, csPending, csRunning, csDone);
  TFrameMRResults = class(TFrame, IEventObserver)
    GridMRResults: TGrid;
    StringColumnName: TStringColumn;
    StringColumnPoint1: TStringColumn;
    StringColumnPoint2: TStringColumn;
    StringColumnResult: TStringColumn;
    ToolBar: TToolBar;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButtonCreatePoints: TSpeedButton;
    ButtonClearSession: TButton;
    ButtonCreateSession: TButton;
    ButtonExportExcel: TButton;
    procedure GridMRResultsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridMRResultsDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
      const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure ButtonClearSessionClick(Sender: TObject);
    procedure ButtonCreateSessionClick(Sender: TObject);
    procedure ButtonExportExcelClick(Sender: TObject);
  private
    FActiveWorkTable: TWorkTable;
    FPointColumns: TObjectList<TStringColumn>;
    FDisplayPoints: TList<TDevicePoint>;
    FRows: TList<TChannel>;
    FProceed: TObject;

    function GetMeasurementRun: TMeasurementRun;
    procedure SetActiveWorkTable(const Value: TWorkTable);
    procedure AttachMeasurementRun;
    procedure DetachMeasurementRun;

    procedure BuildColumns;
    procedure BuildRows;
    procedure RefreshRows;
    function SameDisplayPoint(ALeft, ARight: TDevicePoint): Boolean;
    procedure AddDisplayPoint(APoint: TDevicePoint);

    function GetRowChannel(const ARow: Integer): TChannel;
    function GetDisplayDeviceName(AChannel: TChannel): string;

    function GetPointByColumn(const ACol: Integer): TDevicePoint;
    function FindDevicePoint(ADevice: TDevice; ASessionPoint: TDevicePoint): TDevicePoint;
    function FindPointSpillage(ADevice: TDevice; ASessionPoint: TDevicePoint): TPointSpillage;

    function FormatPointHeader(APoint: TDevicePoint): string;
    function FormatErrorValue(const AValue: Double): string;
    function FormatSpillageErrors(ADevicePoint: TDevicePoint; ASpillage: TPointSpillage): string;
    function BuildErrorsListText(ADevice: TDevice; ASessionPoint: TDevicePoint;
      const ACurrentError: Double; const AIncludeCurrent: Boolean): string;

    function IsCellRunning(AChannel: TChannel; ASessionPoint: TDevicePoint): Boolean;
    function GetCellState(AChannel: TChannel; ASessionPoint: TDevicePoint; out ADevicePoint: TDevicePoint;
      out ASpillage: TPointSpillage): TMRResultCellState;
    function GetCellText(AChannel: TChannel; ASessionPoint: TDevicePoint): string;
    function GetCellColor(AChannel: TChannel; ASessionPoint: TDevicePoint): TAlphaColor;

    function GetResultText(AChannel: TChannel): string;
    function GetResultColor(AChannel: TChannel): TAlphaColor;
    function HasExportableResults: Boolean;
    function BuildExportData(ASelected: TChannel): TResultsExportData;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
    procedure UpdateUI;
    procedure ConnectProcessingFrame(AProceed: TObject);

    property MeasurementRun: TMeasurementRun read GetMeasurementRun;
    property ActiveWorkTable: TWorkTable read FActiveWorkTable write SetActiveWorkTable;
  end;

procedure SetGridReadOnly(AGrid: TGrid);

implementation

uses
  frmProceed, uDebugLog;

{$R *.fmx}

procedure SetGridReadOnly(AGrid: TGrid);
var
  I: Integer;
begin
  if AGrid = nil then
    Exit;

  AGrid.Options := AGrid.Options - [TGridOption.Editing];
  for I := 0 to AGrid.ColumnCount - 1 do
    if AGrid.Columns[I] <> nil then
      AGrid.Columns[I].ReadOnly := True;
end;

constructor TFrameMRResults.Create(AOwner: TComponent);
begin
  inherited;
  FPointColumns := TObjectList<TStringColumn>.Create(False);
  FDisplayPoints := TList<TDevicePoint>.Create;
  FRows := TList<TChannel>.Create;

  GridMRResults.OnGetValue := GridMRResultsGetValue;
  GridMRResults.OnDrawColumnCell := GridMRResultsDrawColumnCell;
  GridMRResults.OnSetValue := nil;
  SetGridReadOnly(GridMRResults);
end;

destructor TFrameMRResults.Destroy;
begin
 // DetachMeasurementRun;
  FreeAndNil(FRows);
  FreeAndNil(FDisplayPoints);
  FreeAndNil(FPointColumns);
  inherited;
end;

function TFrameMRResults.GetMeasurementRun: TMeasurementRun;
begin
  Result := nil;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.MeasurementRun <> nil) then
    Result := TMeasurementRun(FActiveWorkTable.MeasurementRun);
end;

procedure TFrameMRResults.AttachMeasurementRun;
begin
  if MeasurementRun <> nil then
    MeasurementRun.Subscribe(Self);
end;

procedure TFrameMRResults.DetachMeasurementRun;
begin
  if MeasurementRun <> nil then
    MeasurementRun.Unsubscribe(Self);
end;

procedure TFrameMRResults.SetActiveWorkTable(const Value: TWorkTable);
begin
  if FActiveWorkTable = Value then
    Exit;

  DetachMeasurementRun;
  FActiveWorkTable := Value;
  AttachMeasurementRun;

  BuildColumns;
  BuildRows;
  RefreshRows;
end;

procedure TFrameMRResults.SpeedButtonCreatePointsClick(Sender: TObject);
begin
  if MeasurementRun = nil then
    Exit;
  MeasurementRun.InvalidatePreparedPoints;
  MeasurementRun.RebuildMeasurementPoints;
  UpdateUI;
end;

procedure TFrameMRResults.ConnectProcessingFrame(AProceed: TObject);
begin
  FProceed := AProceed;
end;

procedure TFrameMRResults.ButtonClearSessionClick(Sender: TObject);
var
  Channel: TChannel;
  Device: TDevice;
begin
  Channel := GetRowChannel(GridMRResults.Row);
  if FProceed = nil then
    Exit;
  Device := nil;
  if (Channel <> nil) and (Channel.FlowMeter <> nil) then Device := Channel.FlowMeter.Device;
  TFrameProceed(FProceed).RequestClearActiveSession(Device);
end;

procedure TFrameMRResults.ButtonCreateSessionClick(Sender: TObject);
var
  Channel: TChannel;
  Device: TDevice;
begin
  Channel := GetRowChannel(GridMRResults.Row);
  if FProceed = nil then
    Exit;
  Device := nil;
  if (Channel <> nil) and (Channel.FlowMeter <> nil) then Device := Channel.FlowMeter.Device;
  TFrameProceed(FProceed).RequestCreateSession(Device);
end;

function TFrameMRResults.HasExportableResults: Boolean;
var Ch: TChannel; Dev: TDevice; Session: TSessionSpillage;
begin
  Result := False;
  for Ch in FRows do
    if (Ch <> nil) and (Ch.FlowMeter <> nil) then begin
      Dev := Ch.FlowMeter.Device;
      if Dev <> nil then begin
        Session := Dev.GetActiveSessionSpillage;
        if (Session <> nil) and (Session.Spillages.Count > 0) then Exit(True);
      end;
    end;
end;

function TFrameMRResults.BuildExportData(ASelected: TChannel): TResultsExportData;
var Ch: TChannel; Dev: TDevice; Session: TSessionSpillage; Spill: TPointSpillage;
  ES: TResultsExportSession; ED: TResultsExportDevice; ER: TResultsExportResult;
  DevicePoint: TDevicePoint;
begin
  Result := TResultsExportData.Create;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
  begin
    Result.FlowDimensionIndex := FActiveWorkTable.ValueFlowRate.CurrentDimIndex;
    Result.FlowUnitName := FActiveWorkTable.ValueFlowRate.GetDimName;
  end;
  for Ch in FRows do begin
    if (ASelected <> nil) and (Ch <> ASelected) then Continue;
    if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then Continue;
    Dev := Ch.FlowMeter.Device; Session := Dev.GetActiveSessionSpillage;
    ED := Default(TResultsExportDevice); ED.Name:=Dev.Name; ED.SerialNumber:=Dev.SerialNumber;
    ED.UUID:=Dev.UUID; ED.Channel:=Ch.Name; ED.DeviceType:=Dev.DeviceTypeName;
    ED.Status:=GetResultText(Ch); if Session<>nil then ED.SessionID:=IntToStr(Session.ID);
    Result.Devices.Add(ED);
    if Session=nil then Continue;
    ES := Default(TResultsExportSession); ES.ID:=IntToStr(Session.ID); ES.OpenedAt:=Session.DateTimeOpen;
    ES.WorkTable:=FActiveWorkTable.Name; ES.Mode:=IntToStr(Ord(FActiveWorkTable.MeasurementMode));
    ES.Status:=IntToStr(Session.Status); Result.Sessions.Add(ES);
    for Spill in Session.Spillages do begin
      if Spill=nil then Continue;
      ER := Default(TResultsExportResult); ER.DeviceName:=Dev.Name; ER.SerialNumber:=Dev.SerialNumber;
      ER.DeviceUUID:=Dev.UUID; ER.SessionID:=IntToStr(Session.ID); ER.PointName:=Spill.Name;
      { QavgEtalon and DeviceVolumeFlow are stored in the base flow unit (l/s).
        Prepare display-unit numbers here; the generic XLSX writer must not convert them. }
      if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
        ER.ReferenceFlow := FActiveWorkTable.ValueFlowRate.GetDoubleNum(
          Spill.QavgEtalon, Result.FlowDimensionIndex)
      else
        ER.ReferenceFlow := Spill.QavgEtalon;
      ER.EtalonName:=Spill.EtalonName; ER.EtalonUUID:=Spill.EtalonUUID;
      if TMeasuredDimension(Dev.MeasuredDimension) = mdVolumeFlow then
      begin
        if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
          ER.DeviceValue := FActiveWorkTable.ValueFlowRate.GetDoubleNum(
            Spill.DeviceVolumeFlow, Result.FlowDimensionIndex)
        else
          ER.DeviceValue := Spill.DeviceVolumeFlow;
        ER.DeviceUnitName := Result.FlowUnitName;
      end
      else
      begin
        case TMeasuredDimension(Dev.MeasuredDimension) of
          mdMassFlow: ER.DeviceValue := Dev.FromBaseUnits(Spill.DeviceMassFlow);
          mdVolume: ER.DeviceValue := Dev.FromBaseUnits(Spill.DeviceVolume);
          mdMass: ER.DeviceValue := Dev.FromBaseUnits(Spill.DeviceMass);
          mdSpeed: ER.DeviceValue := Dev.FromBaseUnits(Spill.Velocity);
        else
          ER.DeviceValue := Dev.FromBaseUnits(Spill.DeviceVolumeFlow);
        end;
        ER.DeviceUnitName := Dev.GetDimensionName;
      end;
      ER.Error:=Spill.Error; ER.Status:=Spill.StatusStr;
      DevicePoint := Dev.FindMatchedDevicePointForSpillage(Spill);
      if (DevicePoint <> nil) and (not IsNan(DevicePoint.Error)) and
         (not IsInfinite(DevicePoint.Error)) and (DevicePoint.Error > 0) then
      begin
        ER.PointAllowedError := DevicePoint.Error;
        ER.PointAllowedErrorSet := True;
      end;
      ER.Valid:=Spill.Valid; ER.MeasuredAt:=Spill.DateTime; Result.Results.Add(ER);
    end;
  end;
end;

{ Exports the selected device, or every device when no result row is selected. }
procedure TFrameMRResults.ButtonExportExcelClick(Sender: TObject);
var Data: TResultsExportData; Selected: TChannel; Scope, Sessions, FileName: string;
  Dialog: TSaveDialog;
  Started: TDateTime; I: Integer;
begin
  Selected := GetRowChannel(GridMRResults.Row);
  if Selected=nil then Scope:='AllDevices' else Scope:='SelectedDevice';
  { Keep the nonvisual dialog out of the FMX resource to avoid RLINK32 serialization errors. }
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.DefaultExt := 'xlsx';
    Dialog.Filter := 'Excel Workbook (*.xlsx)|*.xlsx';
    Dialog.FileName := Format('Results_%s.xlsx',
      [FormatDateTime('yyyymmdd_hhnnss', Now)]);
    if not Dialog.Execute then
      Exit;
    FileName := Dialog.FileName;
  finally
    Dialog.Free;
  end;
  Started:=Now; Data:=BuildExportData(Selected);
  try
    Sessions:=''; for I:=0 to Data.Sessions.Count-1 do begin if Sessions<>'' then Sessions:=Sessions+','; Sessions:=Sessions+Data.Sessions[I].ID; end;
    DebugLog(Format('ResultsXlsxExportRequested Scope=%s File=%s SessionIDs=%s Devices=%d Results=%d',[Scope,FileName,Sessions,Data.Devices.Count,Data.Results.Count]));
    try
      TResultsXlsxExporter.ExportToFile(Data,FileName);
      DebugLog(Format('ResultsXlsxExportCompleted Scope=%s File=%s SessionIDs=%s FlowUnit=%s FlowDimensionIndex=%d Devices=%d Results=%d Size=%d DurationMs=%d',[Scope,FileName,Sessions,Data.FlowUnitName,Data.FlowDimensionIndex,Data.Devices.Count,Data.Results.Count,TFile.GetSize(FileName),MilliSecondsBetween(Now,Started)]));
    except on E:Exception do begin
      DebugLog(Format('ResultsXlsxExportFailed Scope=%s File=%s SessionIDs=%s Devices=%d Results=%d DurationMs=%d Error=%s',[Scope,FileName,Sessions,Data.Devices.Count,Data.Results.Count,MilliSecondsBetween(Now,Started),E.Message]));
      ShowMessage(Format('Не удалось сохранить файл "%s".'+#13#10+'%s',[ExpandFileName(FileName),E.Message]));
    end; end;
  finally Data.Free; end;
end;

procedure TFrameMRResults.OnNotify(Sender: TObject; Event: Integer; Data: TObject);
begin
  if Sender is TMeasurementRun then
    UpdateUI;
end;

procedure TFrameMRResults.UpdateUI;
begin
  BuildColumns;
  BuildRows;
  RefreshRows;
  GridMRResults.Repaint;
  ButtonExportExcel.Enabled := (FRows.Count > 0) and HasExportableResults;
end;

procedure TFrameMRResults.BuildRows;
var
  Ch: TChannel;
begin
  FRows.Clear;
  if (FActiveWorkTable = nil) or (FActiveWorkTable.DeviceChannels = nil) then
    Exit;

  for Ch in FActiveWorkTable.DeviceChannels do
    if Ch <> nil then
      FRows.Add(Ch);
end;

procedure TFrameMRResults.BuildColumns;
var
  I: Integer;
  Col: TStringColumn;
  DisplayPoint, MatchedPoint: TDevicePoint;
  Ch: TChannel;
  Device: TDevice;
  Session: TSessionSpillage;
  Spill: TPointSpillage;
  Diagnostic: string;
  ActiveSessionID: Integer;
  MatchColumn: Integer;
begin
  FPointColumns.Clear;
  FDisplayPoints.Clear;

  // Preserve scenario order first, then append physical device points which
  // have persisted results in the active session but are absent in scenario.
  if (MeasurementRun <> nil) and (MeasurementRun.Points <> nil) then
    for I := 0 to MeasurementRun.Points.Count - 1 do
      AddDisplayPoint(MeasurementRun.Points[I]);

  if (FActiveWorkTable <> nil) and (FActiveWorkTable.DeviceChannels <> nil) then
    for Ch in FActiveWorkTable.DeviceChannels do
      if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
      begin
        Device := Ch.FlowMeter.Device;
        Session := Device.GetActiveSessionSpillage;
        ActiveSessionID := 0;
        if Session <> nil then
          ActiveSessionID := Session.ID;
        Diagnostic := '';
        if (Session <> nil) and (Device.Spillages <> nil) then
          for Spill in Device.Spillages do
          begin
            if (Spill = nil) or (Spill.SessionID <> Session.ID) then
              Continue;
            MatchedPoint := Device.FindMatchedDevicePointForSpillage(Spill);
            if MatchedPoint <> nil then
            begin
              AddDisplayPoint(MatchedPoint);
              MatchColumn := -1;
              for I := 0 to FDisplayPoints.Count - 1 do
                if SameDisplayPoint(FDisplayPoints[I], MatchedPoint) then
                begin
                  MatchColumn := I + 1;
                  Break;
                end;
              Diagnostic := Diagnostic + Format(' Spill=%s/%s -> Point=%s/%s Column=%d;',
                [Spill.Name, Spill.UUID, MatchedPoint.Name, MatchedPoint.UUID,
                 MatchColumn]);
            end
            else
              Diagnostic := Diagnostic + Format(' Spill=%s/%s -> unmatched;',
                [Spill.Name, Spill.UUID]);
          end;
        DebugLog(Format('MRResultsPointBinding DeviceUUID=%s Serial=%s ActiveSessionID=%d%s',
          [Device.UUID, Device.SerialNumber, ActiveSessionID, Diagnostic]));
      end;

  GridMRResults.BeginUpdate;
  try
    while GridMRResults.ColumnCount > 2 do
      if (GridMRResults.Columns[1] <> StringColumnResult) then
        GridMRResults.Columns[1].Free
      else
        Break;

    StringColumnName.Index := 0;

    for I := 0 to FDisplayPoints.Count - 1 do
      begin
        DisplayPoint := FDisplayPoints[I];

        Col := TStringColumn.Create(GridMRResults);
        Col.Parent := GridMRResults;
        Col.HeaderSettings.TextSettings.WordWrap := False;
        Col.Stored := False;
        Col.Width := 130;
        Col.Header := FormatPointHeader(DisplayPoint);
        Col.Index := GridMRResults.ColumnCount - 1;

        FPointColumns.Add(Col);
      end;

    StringColumnResult.Index := GridMRResults.ColumnCount - 1;
  finally
    GridMRResults.EndUpdate;
  end;
  SetGridReadOnly(GridMRResults);
end;

function TFrameMRResults.SameDisplayPoint(ALeft, ARight: TDevicePoint): Boolean;
var
  I, J: Integer;
begin
  Result := ALeft = ARight;
  if Result or (ALeft = nil) or (ARight = nil) then
    Exit;
  if (Trim(ALeft.UUID) <> '') and SameText(Trim(ALeft.UUID), Trim(ARight.UUID)) then
    Exit(True);
  if (Trim(ALeft.DeviceTypeUUID) <> '') and
     SameText(Trim(ALeft.DeviceTypeUUID), Trim(ARight.DeviceTypeUUID)) then
    Exit(True);
  for I := 0 to High(ALeft.Participants) do
  begin
    if (Trim(ALeft.Participants[I].SourcePointUUID) <> '') and
       SameText(ALeft.Participants[I].SourcePointUUID, ARight.UUID) then
      Exit(True);
    for J := 0 to High(ARight.Participants) do
      if (Trim(ALeft.Participants[I].SourcePointUUID) <> '') and
         SameText(ALeft.Participants[I].SourcePointUUID,
           ARight.Participants[J].SourcePointUUID) then
        Exit(True);
  end;
  for J := 0 to High(ARight.Participants) do
    if (Trim(ARight.Participants[J].SourcePointUUID) <> '') and
       SameText(ARight.Participants[J].SourcePointUUID, ALeft.UUID) then
      Exit(True);
end;

procedure TFrameMRResults.AddDisplayPoint(APoint: TDevicePoint);
var
  Existing: TDevicePoint;
begin
  if APoint = nil then
    Exit;
  for Existing in FDisplayPoints do
    if SameDisplayPoint(Existing, APoint) then
      Exit;
  FDisplayPoints.Add(APoint);
end;

procedure TFrameMRResults.RefreshRows;
var
  RowCount: Integer;
begin
  RowCount := 0;
  RowCount := FRows.Count;

  GridMRResults.BeginUpdate;
  try
    GridMRResults.RowCount := 0;
    GridMRResults.RowCount := RowCount;
  finally
    GridMRResults.EndUpdate;
  end;
end;

function TFrameMRResults.GetRowChannel(const ARow: Integer): TChannel;
begin
  Result := nil;
  if (ARow < 0) or (ARow >= FRows.Count) then
    Exit;

  Result := FRows[ARow];
end;

function TFrameMRResults.GetDisplayDeviceName(AChannel: TChannel): string;
var
  Device: TDevice;
begin
  Result := '';
  if AChannel = nil then
    Exit;

  if (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.Device <> nil) then
  begin
    Device := AChannel.FlowMeter.Device;
    Result := Trim(Device.Name);
    if Trim(Device.SerialNumber) <> '' then
      Result := Trim(Result + ' ' + Trim(Device.SerialNumber));
    if Result <> '' then
      Exit;
  end;

  if (AChannel.FlowMeter <> nil) and (AChannel.FlowMeter.DeviceName <> '') then
    Exit(AChannel.FlowMeter.DeviceName);

  Result := AChannel.Name;
end;

function TFrameMRResults.GetPointByColumn(const ACol: Integer): TDevicePoint;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := ACol - 1;

  if (Idx < 0) or (Idx >= FDisplayPoints.Count) then
    Exit;

  Result := FDisplayPoints[Idx];
end;

function TFrameMRResults.FindDevicePoint(ADevice: TDevice;
  ASessionPoint: TDevicePoint): TDevicePoint;
var
  P: TDevicePoint;
  I: Integer;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Points = nil) or (ASessionPoint = nil) then
    Exit;

  for P in ADevice.Points do
  begin
    if P = ASessionPoint then
      Exit(P);
    if (Trim(P.UUID) <> '') and SameText(Trim(P.UUID), Trim(ASessionPoint.UUID)) then
      Exit(P);
    if (Trim(P.DeviceTypeUUID) <> '') and
       SameText(Trim(P.DeviceTypeUUID), Trim(ASessionPoint.DeviceTypeUUID)) then
      Exit(P);
    for I := 0 to High(ASessionPoint.Participants) do
      if SameText(Trim(P.UUID), Trim(ASessionPoint.Participants[I].SourcePointUUID)) and
         SameText(Trim(ADevice.UUID), Trim(ASessionPoint.Participants[I].DeviceUUID)) then
        Exit(P);
  end;
end;

function TFrameMRResults.FindPointSpillage(ADevice: TDevice;
  ASessionPoint: TDevicePoint): TPointSpillage;
var
  S: TPointSpillage;
  Session: TSessionSpillage;
  MatchedPoint: TDevicePoint;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Spillages = nil) or (ASessionPoint = nil) then
    Exit;

  Session := ADevice.GetActiveSessionSpillage;
  if Session = nil then
  begin
    if FProceed is TFrameProceed then
      Result := TFrameProceed(FProceed).FindResultSpillageForPoint(ADevice, ASessionPoint);
    Exit;
  end;

  for S in ADevice.Spillages do
    if (S <> nil) and (S.SessionID = Session.ID) then
    begin
      MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(S);
      if MatchedPoint = ASessionPoint then
        Exit(S);
    end;
end;

function TFrameMRResults.FormatPointHeader(APoint: TDevicePoint): string;
var
  QText: string;
begin
  Result := '';
  if APoint = nil then
    Exit;




  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
  begin
     if (APoint.Q>=0) then
    QText := ', ' + FActiveWorkTable.ValueFlowRate.GetStrNum(APoint.Q)  + ' '+
    FActiveWorkTable.ValueFlowRate.GetDimName
      else
    QText := '';

  end

  else
    QText := FormatFloat('0.###', APoint.Q);

  if APoint.Name <> '' then
    Result := APoint.Name + QText
  else
    Result := QText;
end;

function TFrameMRResults.FormatErrorValue(const AValue: Double): string;
begin
  if FProceed is TFrameProceed then
    Exit(TFrameProceed(FProceed).FormatResultErrorValue(AValue));
  Result := FormatDeviceError(AValue);
end;

function TFrameMRResults.FormatSpillageErrors(ADevicePoint: TDevicePoint; ASpillage: TPointSpillage): string;
begin
  Result := '';
  if ASpillage = nil then
    Exit;
  // ProtocolDataPoints is rebuilt by analysis and is not a stable session
  // binding. Display the persisted spillage selected for this physical point.
  Result := FormatErrorValue(ASpillage.Error);
end;

function TFrameMRResults.BuildErrorsListText(ADevice: TDevice;
  ADevicePoint: TDevicePoint; const ACurrentError: Double;
  const AIncludeCurrent: Boolean): string;
var
  S: TPointSpillage;
  Session: TSessionSpillage;
  Items: TArray<string>;
  Cnt: Integer;
  MatchedPoint: TDevicePoint;
begin
  Result := '';
  if (ADevice = nil) or (ADevice.Spillages = nil) or (ADevicePoint = nil) then
    Exit;

  Session := ADevice.GetActiveSessionSpillage;
  SetLength(Items, 0);
  Cnt := 0;

  for S in ADevice.Spillages do
  begin
    if (S = nil) or ((Session <> nil) and (S.SessionID <> Session.ID)) then
      Continue;
    // The list contains only spillages which the production device matcher
    // assigns to this concrete physical device point.
    MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(S);
    if MatchedPoint <> ADevicePoint then
      Continue;

    SetLength(Items, Cnt + 1);
    Items[Cnt] := FormatErrorValue(S.Error);
    Inc(Cnt);
  end;

  if AIncludeCurrent then
  begin
    SetLength(Items, Cnt + 1);
    Items[Cnt] := FormatErrorValue(ACurrentError);
    Inc(Cnt);
  end;

  if Cnt = 0 then
    Exit('');

  Result := '[' + string.Join(', ', Items) + ']';
end;

function TFrameMRResults.IsCellRunning(AChannel: TChannel;
  ASessionPoint: TDevicePoint): Boolean;
var
  Device: TDevice;
  CurrentPoint: TDevicePoint;
begin
  Result := False;

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;
  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  if (MeasurementRun = nil) or (MeasurementRun.Stage in [msNone, msDone]) then
    Exit;

  CurrentPoint := MeasurementRun.CurrentPoint;
  if CurrentPoint = nil then
    Exit;

  if not TMeasurementRun.IsPointEquivalent(CurrentPoint, ASessionPoint) then
    Exit;

  Result := (FindDevicePoint(Device, ASessionPoint) <> nil);
end;

function TFrameMRResults.GetCellState(AChannel: TChannel; ASessionPoint: TDevicePoint;
  out ADevicePoint: TDevicePoint; out ASpillage: TPointSpillage): TMRResultCellState;
var
  Device: TDevice;
begin
  Result := csEmpty;
  ADevicePoint := nil;
  ASpillage := nil;

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;
  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  Device.AnalyseDevicePointsResults;

  ADevicePoint := FindDevicePoint(Device, ASessionPoint);
  if ADevicePoint = nil then
    Exit(csEmpty);

  ASpillage := FindPointSpillage(Device, ASessionPoint);

  if (ASpillage = nil) and IsCellRunning(AChannel, ASessionPoint) then
    Exit(csRunning);

  if ASpillage = nil then
    Exit(csPending);

  Result := csDone;
end;

function TFrameMRResults.GetCellText(AChannel: TChannel;
  ASessionPoint: TDevicePoint): string;
var
  Device: TDevice;
  DevicePoint: TDevicePoint;
  Spillage: TPointSpillage;
  CellState: TMRResultCellState;
  CurrentError: Double;
  ErrorsText: string;
begin
  Result := '';

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;
  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  CellState := GetCellState(AChannel, ASessionPoint, DevicePoint, Spillage);

  case CellState of
    csEmpty:
      Result := '';

    csPending:
      Result := FormatErrorValue(DevicePoint.Error);

    csRunning:
      begin
        CurrentError := 0.0;
        if (AChannel.FlowMeter.ValueError <> nil) then
          CurrentError := AChannel.FlowMeter.ValueError.GetDoubleValue;

        ErrorsText := BuildErrorsListText(Device, DevicePoint, CurrentError, True);
        if ErrorsText = '' then
          ErrorsText := '[' + FormatErrorValue(CurrentError) + ']';
        Result := FormatErrorValue(DevicePoint.Error) + ' / ' + ErrorsText;
      end;

    csDone:
      begin
        ErrorsText := BuildErrorsListText(Device, DevicePoint, 0.0, False);
        if ErrorsText <> '' then
          Result := FormatErrorValue(DevicePoint.Error) + ' / ' + ErrorsText
        else
          Result := FormatErrorValue(DevicePoint.Error) + ' / ' + FormatSpillageErrors(DevicePoint, Spillage);
      end;
  end;
end;

function TFrameMRResults.GetCellColor(AChannel: TChannel;
  ASessionPoint: TDevicePoint): TAlphaColor;
var
  DevicePoint: TDevicePoint;
  Spillage: TPointSpillage;
  CellState: TMRResultCellState;
begin
  Result := TAlphaColors.Null;
  CellState := GetCellState(AChannel, ASessionPoint, DevicePoint, Spillage);

  case CellState of
    csRunning: Result := COLOR_RUNNING;
    csDone:
      if FProceed is TFrameProceed then
        Result := TFrameProceed(FProceed).GetPointResultColor(
          AChannel.FlowMeter.Device, DevicePoint, Spillage);
  end;
end;

function TFrameMRResults.GetResultText(AChannel: TChannel): string;
var
  Device: TDevice;
begin
  Result := '';

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;

  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  if FProceed is TFrameProceed then
    Result := TFrameProceed(FProceed).GetDeviceResultText(Device);
end;

function TFrameMRResults.GetResultColor(AChannel: TChannel): TAlphaColor;
var
  Device: TDevice;
begin
  Result := TAlphaColors.Null;

  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;

  Device := AChannel.FlowMeter.Device;
  if Device = nil then
    Exit;

  if FProceed is TFrameProceed then
    Result := TFrameProceed(FProceed).GetDeviceResultColor(Device);
end;

procedure TFrameMRResults.GridMRResultsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Channel: TChannel;
  SessionPoint: TDevicePoint;
begin
  Channel := GetRowChannel(ARow);
  if Channel = nil then
    Exit;

  if GridMRResults.Columns[ACol] = StringColumnName then
  begin
    Value := GetDisplayDeviceName(Channel);
    Exit;
  end;

  if GridMRResults.Columns[ACol] = StringColumnResult then
  begin
    Value := GetResultText(Channel);
    Exit;
  end;

  SessionPoint := GetPointByColumn(ACol);   // Точка сессии (из MR)
  Value := GetCellText(Channel, SessionPoint);
end;

procedure TFrameMRResults.GridMRResultsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  Channel: TChannel;
  SessionPoint: TDevicePoint;
  C: TAlphaColor;
  SavedState: TCanvasSaveState;
begin
  Channel := GetRowChannel(Row);
  if Channel = nil then
    Exit;

  C := TAlphaColors.Null;
  if Column = StringColumnResult then
    C := GetResultColor(Channel)
  else if (Column <> StringColumnName) then
  begin
    SessionPoint := GetPointByColumn(Column.Index);
    C := GetCellColor(Channel, SessionPoint);
  end;

  SavedState := Canvas.SaveState;
  try
    if C <> TAlphaColors.Null then
    begin
      Canvas.Fill.Kind := TBrushKind.Solid;
      Canvas.Fill.Color := C;
      Canvas.FillRect(Bounds, 0, 0, [], 1);
    end;

    Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
  finally
    Canvas.RestoreState(SavedState);
  end;
end;

end.
