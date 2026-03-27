unit fuMain;

interface

uses
  frmProceed,
  frmMainTable,
  UnitBaseProcedures,
  UnitWorkTable,
  UnitDataManager,
  System.UITypes,
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Forms, FMX.TabControl,
  FMX.Filter.Effects, FMX.StdCtrls, FMX.Colors, FMX.Effects,System.Math,
  FMX.ListBox, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Edit,
  FMX.EditBox, FMX.SpinBox;

type
  TFormMain = class(TForm)
    TabControlMain: TTabControl;
    TabItemTable: TTabItem;
    TabItemResults: TTabItem;
    TimerSetValues: TTimer;
    TabItemTest: TTabItem;
    LayoutTestValues: TLayout;
    GroupBoxEtalonChannels: TGroupBox;
    LabelEtalonCurSec: TLabel;
    LabelEtalonImpSec: TLabel;
    LabelEtalonImpResult: TLabel;
    EditEtalonCurSec: TEdit;
    EditEtalonImpSec: TEdit;
    EditEtalonImpResult: TEdit;
    ButtonApplyEtalonValues: TButton;
    GroupBoxDeviceChannels: TGroupBox;
    LabelDeviceCurSec: TLabel;
    LabelDeviceImpSec: TLabel;
    LabelDeviceImpResult: TLabel;
    EditDeviceCurSec: TEdit;
    EditDeviceImpSec: TEdit;
    EditDeviceImpResult: TEdit;
    ButtonApplyDeviceValues: TButton;
    EditTestNum: TEdit;
    LabelTestNum: TLabel;
    Label5: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure TabControlMainChange(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
    procedure EditTestNumExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);




  private
    FWorkTableManager: TWorkTableManager;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FNextClimateChangeAt: TDateTime;

    procedure UpdateRandomClimate(const AWorkTable: TWorkTable);
    procedure UpdateRandomSignals(const AWorkTable: TWorkTable);

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.ButtonApplyDeviceValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if WorkTable = nil then
    Exit;

  FFrameMainTable.ApplyChannelValues(
    WorkTable.DeviceChannels,
    NormalizeFloatInput(EditDeviceCurSec.Text),
    NormalizeFloatInput(EditDeviceImpSec.Text),
    NormalizeFloatInput(EditDeviceImpResult.Text)
  );

end;

procedure TFormMain.ButtonApplyEtalonValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if WorkTable = nil then
    Exit;

  FFrameMainTable.ApplyChannelValues(
    WorkTable.EtalonChannels,
    NormalizeFloatInput(EditEtalonCurSec.Text),
    NormalizeFloatInput(EditEtalonImpSec.Text),
    NormalizeFloatInput(EditEtalonImpResult.Text)
  );

end;

procedure TFormMain.EditTestNumExit(Sender: TObject);
begin
 LabelTestNum.Text := FWorkTableManager.WorkTables[0].DeviceChannels[0].FlowMeter.ValueError.GetStrNum(EditTestNum.Text)
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
       Self.WindowState := TWindowState.wsMinimized;
       DataManager.Save;

     if FWorkTableManager = nil then
    Exit;

    if FFrameMainTable= nil then
    Exit;

  FFrameMainTable.SaveLayoutSettingsToWorkTable;
  FWorkTableManager.Save;



end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := TabItemTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.Initialize;

  FWorkTableManager := FFrameMainTable.WorkTableManager;

  FFrameProceed := TFrameProceed.Create(Self);
  FFrameProceed.Parent := TabItemResults;
  FFrameProceed.Align := TAlignLayout.Client;
  FFrameProceed.Initialize(FWorkTableManager);
end;

procedure TFormMain.TabControlMainChange(Sender: TObject);
begin
  if (TabControlMain.ActiveTab = TabItemResults) and (FFrameProceed <> nil) then
    FFrameProceed.RefreshResultsTab;
end;

procedure TFormMain.UpdateRandomClimate(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

   // Обновляем не каждую секунду
  if (FNextClimateChangeAt = 0) or (Now >= FNextClimateChangeAt) then
  begin
    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;

    AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
    AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

    FNextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
   end;
end;

procedure TFormMain.UpdateRandomSignals(const AWorkTable: TWorkTable);
var
  I: Integer;
  Channel: TChannel;
  CurDelta: Double;
  ImpDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

    AWorkTable.Time := AWorkTable.Time + 1;

  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := AWorkTable.EtalonChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.06) - 0.03;
    ImpDelta := Random(11) - 5;

    Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
    Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
    Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;

  for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.6) - 0.3;
    ImpDelta := Random(11) - 5;

    Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
    Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
    Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
  end;
end;

procedure TFormMain.TimerSetValuesTimer(Sender: TObject);
var
  WorkTable: TWorkTable;
begin

  WorkTable := FWorkTableManager.WorkTables[0]; //FActiveWorkTable;

  if WorkTable = nil then
    Exit;

    UpdateRandomClimate(WorkTable);


  case WorkTable.MeasurementState of
    STATE_NONE:
      FFrameMainTable.OnChangeState(STATE_STANDBY);

    STATE_STANDBY:
      FFrameMainTable.OnChangeState(STATE_CONNECTED);

    STATE_STARTMONITOR:
      FFrameMainTable.OnChangeState(STATE_STARTMONITORWAIT);

    STATE_STARTMONITORWAIT:
      FFrameMainTable.OnChangeState(STATE_MONITOR);

    STATE_MONITOR:
       UpdateRandomSignals(WorkTable);

    STATE_STOPMONITOR,
    STATE_CONFIGED:
      FFrameMainTable.OnChangeState(STATE_CONNECTED);

    STATE_STARTTEST:
      FFrameMainTable.OnChangeState(STATE_STARTWAIT);

    STATE_STARTWAIT:
      FFrameMainTable.OnChangeState(STATE_EXECUTE);

    STATE_EXECUTE:
       UpdateRandomSignals(WorkTable);

    STATE_STOPTEST:
      FFrameMainTable.OnChangeState(STATE_STOPWAIT);

    STATE_STOPWAIT:
      FFrameMainTable.OnChangeState(STATE_COMPLETE);

    STATE_COMPLETE:
      FFrameMainTable.OnChangeState(STATE_FINALREAD);
  end;
end;

end.
