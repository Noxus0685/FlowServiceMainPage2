unit frmMRResults;

interface

uses
  FmxHelper,
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

  TDisplayPointParticipant = record
    DeviceUUID: string;
    DeviceChannelUUID: string;
    SourcePointUUID: string;
    DevicePoint: TDevicePoint;
  end;

  TDisplayPointGroup = class
  public
    ScenarioPoint: TDevicePoint;
    Participants: TList<TDisplayPointParticipant>;
    Header: string;
    constructor Create;
    destructor Destroy; override;
  end;

  TFrameMRResults = class(TFrame, IEventObserver)
    GridMRResults: TGrid;
    StringColumnName: TStringColumn;
    StringColumnResult: TStringColumn;
    ToolBar: TToolBar;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButtonCreatePoints: TSpeedButton;
    ButtonClearSession: TSpeedButton;
    ButtonCreateSession: TSpeedButton;
    ButtonExportExcel: TButton;
    procedure GridMRResultsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridMRResultsDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn;
      const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure SpeedButtonCreatePointsClick(Sender: TObject);
    procedure ButtonClearSessionClick(Sender: TObject);
    procedure ButtonCreateSessionClick(Sender: TObject);
    procedure ButtonExportExcelClick(Sender: TObject);
    procedure GridMRResultsSelChanged(Sender: TObject);
  private
    FActiveWorkTable: TWorkTable;
    FPointColumns: TObjectList<TStringColumn>;
    FDisplayPoints: TObjectList<TDisplayPointGroup>;
    FRows: TList<TChannel>;
    FProceed: TObject;
    FRefreshing: Boolean;
    FColumnStructureSignature: string;

    function GetMeasurementRun: TMeasurementRun;
    procedure SetActiveWorkTable(const Value: TWorkTable);
    procedure AttachMeasurementRun;
    procedure DetachMeasurementRun;

    procedure BuildColumns;
    function GetDisplayPointKey(AGroup: TDisplayPointGroup): string;
    function HasCurrentMeasurementPoints: Boolean;
    procedure BuildRows;
    procedure RefreshRows;
    function PointBelongsToDisplayGroup(ADevice: TDevice; APoint: TDevicePoint;
      AGroup: TDisplayPointGroup): Boolean;
    procedure AddScenarioDisplayPoint(APoint: TDevicePoint);
    procedure AddStandaloneDisplayPoint(ADevice: TDevice; APoint: TDevicePoint);
    procedure MakeDisplayHeadersUnique;

    function GetRowChannel(const ARow: Integer): TChannel;
    function GetDisplayDeviceName(AChannel: TChannel): string;

    function GetDisplayPointByColumn(const ACol: Integer): TDisplayPointGroup;
    function FindDevicePoint(ADevice: TDevice; AGroup: TDisplayPointGroup): TDevicePoint;
    function FindPointSpillage(ADevice: TDevice; ADevicePoint: TDevicePoint): TPointSpillage;

    function FormatPointHeader(APoint: TDevicePoint): string;
    function FormatErrorValue(const AValue: Double): string;
    function FormatActualErrorValue(const AValue: Double): string;
    function FormatSpillageErrors(ADevicePoint: TDevicePoint; ASpillage: TPointSpillage): string;
    function BuildErrorsListText(ADevice: TDevice; ADevicePoint: TDevicePoint;
      const ACurrentError: Double; const AIncludeCurrent: Boolean): string;

    function IsCellRunning(AChannel: TChannel; AGroup: TDisplayPointGroup): Boolean;
    function GetCellState(AChannel: TChannel; AGroup: TDisplayPointGroup; out ADevicePoint: TDevicePoint;
      out ASpillage: TPointSpillage): TMRResultCellState;
    function GetCellText(AChannel: TChannel; AGroup: TDisplayPointGroup): string;
    function GetCellColor(AChannel: TChannel; AGroup: TDisplayPointGroup): TAlphaColor;

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
    procedure ReloadAndUpdate;

    property MeasurementRun: TMeasurementRun read GetMeasurementRun;
    property ActiveWorkTable: TWorkTable read FActiveWorkTable write SetActiveWorkTable;
  end;

procedure SetGridReadOnly(AGrid: TGrid);
function MeasurementModeToDisplayText(const AMode: EMeasurementRunMode): string;
function SessionStatusToDisplayText(const AStatus: Integer): string;

implementation

uses
  frmProceed, uDebugLog;

{$R *.fmx}

{ Converts the production measurement mode to its user-facing snapshot text. }
function MeasurementModeToDisplayText(const AMode: EMeasurementRunMode): string;
begin
  case AMode of
    mrmManual: Result := 'Ручной';
    mrmHalfAutomatic: Result := 'Полуавтоматический';
    mrmAutomatic: Result := 'Автоматический';
  else
    Result := 'Не определён';
  end;
end;

{ Session.Status is the persisted lifecycle code: new, running, or closed. }
function SessionStatusToDisplayText(const AStatus: Integer): string;
begin
  case AStatus of
    0: Result := 'Открыта';
    1: Result := 'Выполняется';
    2: Result := 'Завершена';
  else
    Result := 'Не определён';
  end;
end;

constructor TDisplayPointGroup.Create;
begin
  inherited Create;
  Participants := TList<TDisplayPointParticipant>.Create;
end;

destructor TDisplayPointGroup.Destroy;
begin
  Participants.Free;
  inherited;
end;

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
  FDisplayPoints := TObjectList<TDisplayPointGroup>.Create(True);
  FRows := TList<TChannel>.Create;
  GridMRResults.OnGetValue := GridMRResultsGetValue;
  GridMRResults.OnDrawColumnCell := GridMRResultsDrawColumnCell;
  GridMRResults.OnSetValue := nil;
  GridMRResults.OnSelChanged := GridMRResultsSelChanged;
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
  Scope: string;
begin
  Channel := GetRowChannel(GridMRResults.Row);
  if not (FProceed is TFrameProceed) then
  begin
    DebugLog('ResultsSessionClearFailed Scope=Unknown Error=ProcessingFrameNotConnected');
    ShowMessage('Вкладка «Обработка» недоступна. Очистить сессию невозможно.');
    Exit;
  end;
  if (Channel <> nil) and (Channel.FlowMeter <> nil) and
     (Channel.FlowMeter.Device <> nil) then
  begin
    Scope := 'SelectedDevice';
    Device := Channel.FlowMeter.Device;
    if TFrameProceed(FProceed).RequestClearActiveSession(Device) then ReloadAndUpdate;
  end
  else
  begin
    Scope := 'AllDevices';
    if TFrameProceed(FProceed).RequestClearActiveSessions then ReloadAndUpdate;
  end;
  DebugLog('ResultsSessionClearDispatch Scope=' + Scope);
end;

procedure TFrameMRResults.ButtonCreateSessionClick(Sender: TObject);
var
  Channel: TChannel;
  Device: TDevice;
  Scope: string;
begin
  Channel := GetRowChannel(GridMRResults.Row);
  if not (FProceed is TFrameProceed) then
  begin
    DebugLog('ResultsSessionCreateFailed Scope=Unknown Error=ProcessingFrameNotConnected');
    ShowMessage('Вкладка «Обработка» недоступна. Создать сессию невозможно.');
    Exit;
  end;
  if (Channel <> nil) and (Channel.FlowMeter <> nil) and
     (Channel.FlowMeter.Device <> nil) then
  begin
    Scope := 'SelectedDevice'; Device := Channel.FlowMeter.Device;
    if TFrameProceed(FProceed).RequestCreateSession(Device) <> nil then ReloadAndUpdate;
  end
  else
  begin
    Scope := 'AllDevices';
    if TFrameProceed(FProceed).RequestCreateSessions then ReloadAndUpdate;
  end;
  DebugLog('ResultsSessionCreateDispatch Scope=' + Scope);
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
  DevicePoint, ScenarioPoint: TDevicePoint;
  PointColumn: TResultsExportPointColumn;
  Participant: TResultsExportPointParticipant;
  Cell: TResultsExportPointCell;
  I, J, DuplicateCount: Integer;
  HeaderExists: Boolean;
  BaseHeader, CandidateHeader, Key: string;

begin
  Result := TResultsExportData.Create;
  try
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.ValueFlowRate <> nil) then
  begin
    Result.FlowDimensionIndex := FActiveWorkTable.ValueFlowRate.CurrentDimIndex;
    Result.FlowUnitName := FActiveWorkTable.ValueFlowRate.GetDimName;
  end;

  { Prefer the current run schema. Its participants preserve merged-point identity. }
  if HasCurrentMeasurementPoints then
    for I := 0 to MeasurementRun.Points.Count - 1 do
    begin
      ScenarioPoint := MeasurementRun.Points[I];
      if (ScenarioPoint = nil) or not ScenarioPoint.Enabled then Continue;
      PointColumn := TResultsExportPointColumn.Create;
      if Length(ScenarioPoint.Participants) > 1 then
        PointColumn.Key := ScenarioPoint.UUID
      else if Length(ScenarioPoint.Participants) = 1 then
        PointColumn.Key := ScenarioPoint.Participants[0].DeviceUUID + '|' +
          ScenarioPoint.Participants[0].SourcePointUUID
      else
        PointColumn.Key := ScenarioPoint.UUID;
      PointColumn.Header := Trim(ScenarioPoint.Name);
      if PointColumn.Header = '' then PointColumn.Header := FormatPointHeader(ScenarioPoint);
      for J := 0 to High(ScenarioPoint.Participants) do
      begin
        Participant.DeviceUUID := ScenarioPoint.Participants[J].DeviceUUID;
        Participant.SourcePointUUID := ScenarioPoint.Participants[J].SourcePointUUID;
        PointColumn.Participants.Add(Participant);
      end;
      Result.PointColumns.Add(PointColumn);
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
    ES.WorkTable:=FActiveWorkTable.Name;
    ES.Mode:=MeasurementModeToDisplayText(FActiveWorkTable.MeasurementMode);
    ES.Status:=SessionStatusToDisplayText(Session.Status); Result.Sessions.Add(ES);
    for Spill in Session.Spillages do begin
      if (Spill=nil) or (Spill.State=osDeleted) then Continue;
      DevicePoint := Dev.FindMatchedDevicePointForSpillage(Spill);
      PointColumn := nil;
      if DevicePoint <> nil then
        for I := 0 to Result.PointColumns.Count - 1 do
          for J := 0 to Result.PointColumns[I].Participants.Count - 1 do
            if SameText(Result.PointColumns[I].Participants[J].DeviceUUID, Dev.UUID) and
               SameText(Result.PointColumns[I].Participants[J].SourcePointUUID, DevicePoint.UUID) then
            begin
              PointColumn := Result.PointColumns[I];
              Break;
            end;
      { After restart the run schema may be unavailable. Build only from this active session. }
      if (PointColumn = nil) and not HasCurrentMeasurementPoints and (DevicePoint <> nil) then
      begin
        Key := Dev.UUID + '|' + DevicePoint.UUID;
        for I := 0 to Result.PointColumns.Count - 1 do
          if SameText(Result.PointColumns[I].Key, Key) then PointColumn := Result.PointColumns[I];
        if PointColumn = nil then
        begin
          PointColumn := TResultsExportPointColumn.Create;
          PointColumn.Key := Key;
          PointColumn.Header := Trim(DevicePoint.Name);
          if PointColumn.Header = '' then PointColumn.Header := Trim(Spill.Name);
          Participant.DeviceUUID := Dev.UUID;
          Participant.SourcePointUUID := DevicePoint.UUID;
          PointColumn.Participants.Add(Participant);
          Result.PointColumns.Add(PointColumn);
        end;
      end;
      if PointColumn <> nil then
      begin
        Cell := Default(TResultsExportPointCell);
        Cell.DeviceUUID := Dev.UUID;
        Cell.PointColumnKey := PointColumn.Key;
        Cell.Error := Spill.Error;
        Cell.ErrorSet := not IsNan(Spill.Error) and not IsInfinite(Spill.Error);
        Result.PointCells.Add(Cell);
      end;
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
      ER.Error:=Spill.Error; ER.Status:=Spill.GetShortStateText;
      if (DevicePoint <> nil) and (not IsNan(DevicePoint.Error)) and
         (not IsInfinite(DevicePoint.Error)) and (DevicePoint.Error > 0) then
      begin
        ER.PointAllowedError := DevicePoint.Error;
        ER.PointAllowedErrorSet := True;
      end;
      ER.Valid:=Spill.Valid; ER.MeasuredAt:=Spill.DateTime; Result.Results.Add(ER);
    end;
  end;
  { Headers are presentation labels only; stable keys remain unchanged. }
  for I := 0 to Result.PointColumns.Count - 1 do
  begin
    BaseHeader := Result.PointColumns[I].Header;
    DuplicateCount := 1;
    CandidateHeader := BaseHeader;
    repeat
      HeaderExists := False;
      for J := 0 to I - 1 do
        if SameText(Result.PointColumns[J].Header, CandidateHeader) then
        begin
          HeaderExists := True;
          Break;
        end;
      if not HeaderExists then Break;
      Inc(DuplicateCount);
      CandidateHeader := Format('%s (%d)', [BaseHeader, DuplicateCount]);
    until False;
    Result.PointColumns[I].Header := CandidateHeader;
  end;
  finally
    if Result.Sessions.Count > 0 then
      DebugLog(Format('ResultsXlsxSnapshot PointColumns=%d SessionModeText=%s SessionStatusText=%s',
        [Result.PointColumns.Count, Result.Sessions[0].Mode, Result.Sessions[0].Status]))
    else
      DebugLog(Format('ResultsXlsxSnapshot PointColumns=%d SessionModeText= SessionStatusText=',
        [Result.PointColumns.Count]));
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
  if (Sender is TMeasurementRun) and not FRefreshing then
  begin
    { Measurement notifications normally only change cell values and states.
      Keeping the existing TColumn instances also keeps user column widths. }
    BuildRows;
    RefreshRows;
    GridMRResults.Repaint;
    ButtonExportExcel.Enabled := (FRows.Count > 0) and HasExportableResults;
  end;
end;

procedure TFrameMRResults.UpdateUI;
begin
  BuildColumns;
  BuildRows;
  RefreshRows;
  GridMRResults.Repaint;
  ButtonExportExcel.Enabled := (FRows.Count > 0) and HasExportableResults;
  ButtonClearSession.Enabled := (FProceed is TFrameProceed) and
    TFrameProceed(FProceed).CanManageResultSessions;
  ButtonCreateSession.Enabled := ButtonClearSession.Enabled;
end;

{ Called when the tab opens and after session operations so the UI never
  depends on stale local session data. }
procedure TFrameMRResults.ReloadAndUpdate;
begin
  if FRefreshing then Exit;
  FRefreshing := True;
  try
    if FProceed is TFrameProceed then TFrameProceed(FProceed).RefreshResultsTab;
    UpdateUI;
  finally
    FRefreshing := False;
  end;
end;

procedure TFrameMRResults.GridMRResultsSelChanged(Sender: TObject);
begin
  ButtonClearSession.Enabled := (FProceed is TFrameProceed) and
    TFrameProceed(FProceed).CanManageResultSessions;
  ButtonCreateSession.Enabled := ButtonClearSession.Enabled;
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
  Group: TDisplayPointGroup;
  RequiredDisplayPoints, PreviousDisplayPoints: TObjectList<TDisplayPointGroup>;
  RequiredSignature: string;
begin
  { Builds point columns only when the actual point composition changes. }
  RequiredDisplayPoints := TObjectList<TDisplayPointGroup>.Create(True);
  PreviousDisplayPoints := FDisplayPoints;
  FDisplayPoints := RequiredDisplayPoints;
  try
    if HasCurrentMeasurementPoints then
      for I := 0 to MeasurementRun.Points.Count - 1 do
        if (MeasurementRun.Points[I] <> nil) and MeasurementRun.Points[I].Enabled then
          AddScenarioDisplayPoint(MeasurementRun.Points[I]);
    MakeDisplayHeadersUnique;
    RequiredSignature := '';
    for Group in RequiredDisplayPoints do
      RequiredSignature := RequiredSignature + '|' + GetDisplayPointKey(Group);
  finally
    FDisplayPoints := PreviousDisplayPoints;
  end;

  if RequiredSignature = FColumnStructureSignature then
  begin
    RequiredDisplayPoints.Free;
    Exit;
  end;

  GridMRResults.BeginUpdate;
  try
    FPointColumns.Clear;
    while GridMRResults.ColumnCount > 2 do
      if GridMRResults.Columns[1] <> StringColumnResult then
        GridMRResults.Columns[1].Free
      else
        Break;
    StringColumnName.Index := 0;
    for Group in RequiredDisplayPoints do
    begin
      Col := TStringColumn.Create(GridMRResults);
      Col.Parent := GridMRResults;
      Col.HeaderSettings.TextSettings.WordWrap := False;
      Col.Stored := False;
      Col.Header := Group.Header;
      Col.Index := GridMRResults.ColumnCount - 1;
      FPointColumns.Add(Col);
    end;
    StringColumnResult.Index := GridMRResults.ColumnCount - 1;
    FDisplayPoints.Free;
    FDisplayPoints := RequiredDisplayPoints;
    RequiredDisplayPoints := nil;
    FColumnStructureSignature := RequiredSignature;
    SetGridReadOnly(GridMRResults);
  finally
    GridMRResults.EndUpdate;
    RequiredDisplayPoints.Free;
  end;
end;

function TFrameMRResults.GetDisplayPointKey(AGroup: TDisplayPointGroup): string;
var
  Participant: TDisplayPointParticipant;
  KeyParts: TStringList;
  PartKey: string;
begin
  Result := 'point:';
  if AGroup = nil then
    Exit;

  // UUID сценарной точки пересоздаётся кнопкой формирования точек и поэтому
  // не может быть идентификатором визуального столбца.
  KeyParts := TStringList.Create;
  try
    KeyParts.Sorted := True;
    KeyParts.Duplicates := dupAccept;
    for Participant in AGroup.Participants do
    begin
      PartKey := LowerCase(Trim(Participant.DeviceUUID)) + ':' +
        LowerCase(Trim(Participant.DeviceChannelUUID)) + ':' +
        LowerCase(Trim(Participant.SourcePointUUID));
      if PartKey <> '::' then
        KeyParts.Add(PartKey);
    end;
    for PartKey in KeyParts do
      Result := Result + '|participant=' + IntToStr(Length(PartKey)) + ':' +
        PartKey;
  finally
    KeyParts.Free;
  end;

  if (Result = 'point:') and (AGroup.ScenarioPoint <> nil) then
    Result := Result + 'name=' + LowerCase(Trim(AGroup.ScenarioPoint.Name)) +
      '|num=' + IntToStr(AGroup.ScenarioPoint.Num);
end;

function TFrameMRResults.HasCurrentMeasurementPoints: Boolean;
var
  I: Integer;
begin
  Result := False;
  if (MeasurementRun = nil) or (MeasurementRun.Points = nil) then Exit;
  for I := 0 to MeasurementRun.Points.Count - 1 do
    if (MeasurementRun.Points[I] <> nil) and MeasurementRun.Points[I].Enabled then
      Exit(True);
end;

function TFrameMRResults.PointBelongsToDisplayGroup(ADevice: TDevice;
  APoint: TDevicePoint; AGroup: TDisplayPointGroup): Boolean;
var
  Participant: TDisplayPointParticipant;
begin
  Result := False;
  if (ADevice = nil) or (APoint = nil) or (AGroup = nil) then
    Exit;

  for Participant in AGroup.Participants do
  begin
    if (Participant.DevicePoint = APoint) or
       ((Trim(Participant.DeviceUUID) <> '') and
        SameText(Participant.DeviceUUID, ADevice.UUID) and
        (Trim(Participant.SourcePointUUID) <> '') and
        SameText(Participant.SourcePointUUID, APoint.UUID)) then
      Exit(True);
  end;

  if (AGroup.Participants.Count = 0) and (AGroup.ScenarioPoint <> nil) then
    Result := TMeasurementRun.IsPointEquivalent(APoint, AGroup.ScenarioPoint);
end;

procedure TFrameMRResults.AddScenarioDisplayPoint(APoint: TDevicePoint);
var
  Group: TDisplayPointGroup;
  Item: TDisplayPointParticipant;
  I: Integer;
begin
  if APoint = nil then
    Exit;
  Group := TDisplayPointGroup.Create;
  Group.ScenarioPoint := APoint;
  Group.Header := FormatPointHeader(APoint);
  for I := 0 to High(APoint.Participants) do
  begin
    Item.DeviceUUID := APoint.Participants[I].DeviceUUID;
    Item.DeviceChannelUUID := APoint.Participants[I].DeviceChannelUUID;
    Item.SourcePointUUID := APoint.Participants[I].SourcePointUUID;
    Item.DevicePoint := nil;
    Group.Participants.Add(Item);
  end;
  FDisplayPoints.Add(Group);
end;

procedure TFrameMRResults.AddStandaloneDisplayPoint(ADevice: TDevice;
  APoint: TDevicePoint);
var
  Group: TDisplayPointGroup;
  Item: TDisplayPointParticipant;
begin
  for Group in FDisplayPoints do
    if PointBelongsToDisplayGroup(ADevice, APoint, Group) then
      Exit;

  Group := TDisplayPointGroup.Create;
  Group.ScenarioPoint := nil;
  Group.Header := FormatPointHeader(APoint);
  Item.DeviceUUID := ADevice.UUID;
  Item.DeviceChannelUUID := '';
  Item.SourcePointUUID := APoint.UUID;
  Item.DevicePoint := APoint;
  Group.Participants.Add(Item);
  FDisplayPoints.Add(Group);
end;

procedure TFrameMRResults.MakeDisplayHeadersUnique;
var
  I, J: Integer;
  DevicePoint: TDevicePoint;
  Device: TDevice;
  Ch: TChannel;
  Suffix: string;
begin
  for I := 0 to FDisplayPoints.Count - 1 do
    for J := 0 to I - 1 do
      if SameText(FDisplayPoints[I].Header, FDisplayPoints[J].Header) then
      begin
        Device := nil;
        DevicePoint := nil;
        if FDisplayPoints[I].Participants.Count > 0 then
          DevicePoint := FDisplayPoints[I].Participants[0].DevicePoint;
        if (DevicePoint <> nil) and (FActiveWorkTable <> nil) and
           (FActiveWorkTable.DeviceChannels <> nil) then
          for Ch in FActiveWorkTable.DeviceChannels do
            if (Ch <> nil) and (Ch.FlowMeter <> nil) and
               (Ch.FlowMeter.Device <> nil) and
               SameText(Ch.FlowMeter.Device.UUID,
                 FDisplayPoints[I].Participants[0].DeviceUUID) then
            begin
              Device := Ch.FlowMeter.Device;
              Break;
            end;
        Suffix := '';
        if FDisplayPoints[I].Participants.Count > 0 then
        begin
          Suffix := Copy(FDisplayPoints[I].Participants[0].SourcePointUUID, 1, 8);
          if Suffix = '' then
            Suffix := Copy(FDisplayPoints[I].Participants[0].DeviceUUID, 1, 8);
        end
        else if FDisplayPoints[I].ScenarioPoint <> nil then
          Suffix := LowerCase(Trim(FDisplayPoints[I].ScenarioPoint.Name)) + '-' +
            IntToStr(FDisplayPoints[I].ScenarioPoint.Num);
        if Device <> nil then
          if Trim(Device.SerialNumber) <> '' then
            Suffix := Device.SerialNumber
          else
            Suffix := Device.Name;
        if (DevicePoint <> nil) and (Trim(DevicePoint.UUID) <> '') then
          Suffix := Trim(Suffix + ' ' + Copy(DevicePoint.UUID, 1, 8));
        if Suffix = '' then
          Suffix := IntToStr(I + 1);
        FDisplayPoints[I].Header := FDisplayPoints[I].Header + ' (' + Suffix + ')';
        Break;
      end;
end;

procedure TFrameMRResults.RefreshRows;
begin
  RefreshGridContent(GridMRResults, FRows.Count, 'mr-results');
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

function TFrameMRResults.GetDisplayPointByColumn(
  const ACol: Integer): TDisplayPointGroup;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := ACol - 1;
  if (Idx >= 0) and (Idx < FDisplayPoints.Count) then
    Result := FDisplayPoints[Idx];
end;

function TFrameMRResults.FindDevicePoint(ADevice: TDevice;
  AGroup: TDisplayPointGroup): TDevicePoint;
var
  P: TDevicePoint;
  Participant: TDisplayPointParticipant;
  HasLegacyParticipant: Boolean;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Points = nil) or (AGroup = nil) then
    Exit;

  HasLegacyParticipant := AGroup.Participants.Count = 0;
  for Participant in AGroup.Participants do
  begin
    if (Trim(Participant.DeviceUUID) <> '') and
       not SameText(Participant.DeviceUUID, ADevice.UUID) then
      Continue;
    if Participant.DevicePoint <> nil then
      Exit(Participant.DevicePoint);
    if Trim(Participant.SourcePointUUID) <> '' then
      for P in ADevice.Points do
        if SameText(P.UUID, Participant.SourcePointUUID) then
          Exit(P)
    else
      HasLegacyParticipant := True;
  end;

  // Old persisted scenarios may lack participant UUIDs.  Equivalence is only
  // allowed for a participant already assigned to this device/group.
  if HasLegacyParticipant and (AGroup.ScenarioPoint <> nil) then
    for P in ADevice.Points do
      if TMeasurementRun.IsPointEquivalent(P, AGroup.ScenarioPoint) then
        Exit(P);
end;

function TFrameMRResults.FindPointSpillage(ADevice: TDevice;
  ADevicePoint: TDevicePoint): TPointSpillage;
var
  S: TPointSpillage;
  Session: TSessionSpillage;
  MatchedPoint: TDevicePoint;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Spillages = nil) or (ADevicePoint = nil) then
    Exit;

  Session := ADevice.GetActiveSessionSpillage;
  if Session = nil then
  begin
    if FProceed is TFrameProceed then
      Result := TFrameProceed(FProceed).FindResultSpillageForPoint(ADevice, ADevicePoint);
    Exit;
  end;

  for S in ADevice.Spillages do
    if (S <> nil) and (S.SessionID = Session.ID) then
    begin
      MatchedPoint := ADevice.FindMatchedDevicePointForSpillage(S);
      if MatchedPoint = ADevicePoint then
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

function TFrameMRResults.FormatActualErrorValue(const AValue: Double): string;
begin
  // Processing renders saved result cells with this production precision.
  // -MaxDouble is TMeterValue's marker for an unavailable numeric value.
  if IsNan(AValue) or IsInfinite(AValue) or (AValue <= -MaxDouble) then
    Exit('-');
  Result := FormatFloat('0.###', AValue);
end;

function FormatMRActualErrorValue(const AValue: Double): string;
begin
  // Processing renders saved result cells with this production precision.
  // -MaxDouble is TMeterValue's marker for an unavailable numeric value.
  if IsNan(AValue) or IsInfinite(AValue) or (AValue <= -MaxDouble) then
    Exit('-');
  Result := FormatFloat('0.###', AValue);
end;



function TFrameMRResults.FormatSpillageErrors(ADevicePoint: TDevicePoint; ASpillage: TPointSpillage): string;
var
  DataPoint: TPointSpillage;
begin
  Result := '';
  if ASpillage = nil then
    Exit;

  if (ADevicePoint <> nil) and (ADevicePoint.ProtocolDataPoints <> nil) and (ADevicePoint.ProtocolDataPoints.Count > 0) then
  begin
    if ADevicePoint.ProtocolDataPoints.Count = 1 then
      Exit(FormatMRActualErrorValue(ADevicePoint.ProtocolDataPoints[0].Error));

    Result := '[';
    for DataPoint in ADevicePoint.ProtocolDataPoints do
    begin
      if Result <> '[' then
        Result := Result + '; ';
      Result := Result + FormatMRActualErrorValue(DataPoint.Error);
    end;
    Result := Result + ']';
  end
  else
    Result := FormatMRActualErrorValue(ASpillage.Error);
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
    Items[Cnt] := FormatMRActualErrorValue(S.Error);
    Inc(Cnt);
  end;

  if AIncludeCurrent then
  begin
    SetLength(Items, Cnt + 1);
    Items[Cnt] := FormatMRActualErrorValue(ACurrentError);
    Inc(Cnt);
  end;

  if Cnt = 0 then
    Exit('');

  Result := '[' + string.Join(', ', Items) + ']';
end;

function TFrameMRResults.IsCellRunning(AChannel: TChannel;
  AGroup: TDisplayPointGroup): Boolean;
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

  if (AGroup = nil) or (AGroup.ScenarioPoint = nil) or
     not TMeasurementRun.IsPointEquivalent(CurrentPoint, AGroup.ScenarioPoint) then
    Exit;

  Result := (FindDevicePoint(Device, AGroup) <> nil);
end;

function TFrameMRResults.GetCellState(AChannel: TChannel; AGroup: TDisplayPointGroup;
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

  ADevicePoint := FindDevicePoint(Device, AGroup);
  if ADevicePoint = nil then
    Exit(csEmpty);

  ASpillage := FindPointSpillage(Device, ADevicePoint);

  if (ASpillage = nil) and IsCellRunning(AChannel, AGroup) then
    Exit(csRunning);

  if ASpillage = nil then
    Exit(csPending);

  Result := csDone;
end;

function TFrameMRResults.GetCellText(AChannel: TChannel;
  AGroup: TDisplayPointGroup): string;
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

  CellState := GetCellState(AChannel, AGroup, DevicePoint, Spillage);

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
          ErrorsText := '[' + FormatMRActualErrorValue(CurrentError) + ']';
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
  AGroup: TDisplayPointGroup): TAlphaColor;
var
  DevicePoint: TDevicePoint;
  Spillage: TPointSpillage;
  CellState: TMRResultCellState;
begin
  Result := TAlphaColors.Null;
  CellState := GetCellState(AChannel, AGroup, DevicePoint, Spillage);

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
  DisplayPoint: TDisplayPointGroup;
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

  DisplayPoint := GetDisplayPointByColumn(ACol);
  Value := GetCellText(Channel, DisplayPoint);
end;

procedure TFrameMRResults.GridMRResultsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  Channel: TChannel;
  DisplayPoint: TDisplayPointGroup;
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
    DisplayPoint := GetDisplayPointByColumn(Column.Index);
    C := GetCellColor(Channel, DisplayPoint);
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
