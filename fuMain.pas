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
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
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
    mPump: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure TabControlMainChange(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
    procedure EditTestNumExit(Sender: TObject);
    procedure  PumpStateHandler(APump: TPump; AAction:EControlAction);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);




  private
    FWorkTableManager: TWorkTableManager;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FNextClimateChangeAt: TDateTime;
    FNextFreqChangeAt: TDateTime;
    FNextPressChangeAt: TDateTime;


    procedure UpdateRandomClimate(const AWorkTable: TWorkTable);
    procedure UpdateRandomSignals(const AWorkTable: TWorkTable);
    procedure UpdateRandomFreq(const APump: TPump);
    procedure UpdateRandomFlowRate(const AFlowRate: TFlowRate);
    procedure FlowRateStateHandler(AFlowRate: TFlowRate;
      AAction: EControlAction);
    procedure FlowConditionsTempHandler(AConditionsTemp: tConditionsTemp;
      AAction: EControlAction);
    procedure FlowConditionsPressHandler(AConditionsPress: tConditionsPress;
      AAction: EControlAction);
    procedure UpdateRandomPress(const AWorkTable: TWorkTable);

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
//1233211
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

procedure  TFormMain.PumpStateHandler(APump: TPump; AAction:EControlAction);
begin

  FormMain.mPump.Lines.Add('Насос: ' + APump.Name +' Состояние: ' + FWorkTableManager.ActiveWorkTable.ActivePump.GetActionAsString);

end;


procedure  TFormMain.FlowRateStateHandler(AFlowRate: TFlowRate; AAction:EControlAction);
begin

  FormMain.mPump.Lines.Add('Расход воды: ' + floattostr(FWorkTableManager.ActiveWorkTable.FlowRate.SetValue)+ ' - Состояние: ' + FWorkTableManager.ActiveWorkTable.FlowRate.GetActionAsString );

end;

procedure  TFormMain.FlowConditionsTempHandler(AConditionsTemp: tConditionsTemp; AAction:EControlAction);
begin

  FormMain.mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FWorkTableManager.ActiveWorkTable.ConditionsTemp.SetValue));

end;

procedure  TFormMain.FlowConditionsPressHandler(AConditionsPress: tConditionsPress; AAction:EControlAction);
begin

  FormMain.mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FWorkTableManager.ActiveWorkTable.ConditionsPress.SetValue));

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


  FWorkTableManager := TWorkTableManager.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Settings\TableSettings.ini'
  );

    FWorkTableManager.Load;
  //Подумать над динамической привязкой ко всем столам
  FWorkTableManager.ActiveWorkTable.OnPumpChange:= PumpStateHandler;
  FWorkTableManager.ActiveWorkTable.OnFlowRateChange:= FlowRateStateHandler;
  FWorkTableManager.ActiveWorkTable.OnConditionTempChange:= FlowConditionsTempHandler;
  FWorkTableManager.ActiveWorkTable.OnConditionPressChange:= FlowConditionsPressHandler;

  FWorkTableManager.ActiveWorkTable.AddPump('1');
  FWorkTableManager.ActiveWorkTable.AddPump('2');
  FWorkTableManager.ActiveWorkTable.AddPump('3');


  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := TabItemTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.WorkTableManager := FWorkTableManager ;
  FFrameMainTable.Initialize;



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

  IF (AWorkTable.ConditionsTemp.Action = CONTROL_ACTION_START)THEN
    AWorkTable.ConditionsTemp.SetState(CONTROL_STARTED)
  else  if (AWorkTable.ConditionsTemp.Action = CONTROL_ACTION_STOP) then
    AWorkTable.ConditionsTemp.SetState(CONTROL_STOPPED);


   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextClimateChangeAt = 0) or (Now >= FNextClimateChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.ConditionsTemp.IsRunning) then
    begin
      if NOT(AWorkTable.ConditionsTemp.SetValue<=AWorkTable.ConditionsTemp.Value*(1+AWorkTable.ConditionsTemp.AccuracyPlus/100))
      AND (AWorkTable.ConditionsTemp.SetValue>=AWorkTable.ConditionsTemp.Value*(1-AWorkTable.ConditionsTemp.AccuracyMinus/100))
      AND  (AWorkTable.ConditionsTemp.Value<AWorkTable.ConditionsTemp.SetValue)  THEN
      begin
        AWorkTable.ConditionsTemp.SetBefore(AWorkTable.ConditionsTemp.BeforeValue+1);
        AWorkTable.ConditionsTemp.SetAfter(AWorkTable.ConditionsTemp.AfterValue+1);
      end
    ELSE if not(AWorkTable.ConditionsTemp.SetValue<=AWorkTable.ConditionsTemp.Value*(1+AWorkTable.ConditionsTemp.AccuracyPlus/100))
      AND (AWorkTable.ConditionsTemp.SetValue>=AWorkTable.ConditionsTemp.Value*(1-AWorkTable.ConditionsTemp.AccuracyMinus/100))
      AND  (AWorkTable.ConditionsTemp.Value>AWorkTable.ConditionsTemp.SetValue)  THEN
      begin
        AWorkTable.ConditionsTemp.SetBefore(AWorkTable.ConditionsTemp.BeforeValue-1);
        AWorkTable.ConditionsTemp.SetAfter(AWorkTable.ConditionsTemp.AfterValue-1);
      end;

      if (AWorkTable.ConditionsTemp.SetValue<=AWorkTable.ConditionsTemp.Value*(1+AWorkTable.ConditionsTemp.AccuracyPlus/100))
      AND (AWorkTable.ConditionsTemp.SetValue>=AWorkTable.ConditionsTemp.Value*(1-AWorkTable.ConditionsTemp.AccuracyMinus/100)) then
        AWorkTable.DoConditionsTempStop

    end;


      if AWorkTable.ConditionsTemp.SetValue<>0 then
      begin
        AWorkTable.ConditionsTemp.SetBefore(EnsureRange(AWorkTable.ConditionsTemp.BeforeValue + TempDelta, -50.0, 150.0));
        AWorkTable.ConditionsTemp.SetAfter(EnsureRange(AWorkTable.ConditionsTemp.AfterValue + TempDelta, -50.0, 150.0));
      end;





    //AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
    //AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

    FNextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
   end;
end;

procedure TFormMain.UpdateRandomPress(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

  IF AWorkTable.ConditionsPress.Action = CONTROL_ACTION_START THEN
    AWorkTable.ConditionsPress.SetState(CONTROL_STARTED)
  else  if (AWorkTable.ConditionsPress.Action = CONTROL_ACTION_STOP) then
    AWorkTable.ConditionsPress.SetState(CONTROL_STOPPED);

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextPressChangeAt = 0) or (Now >= FNextPressChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.ConditionsPress.IsRunning) then
    begin
      if  (AWorkTable.ConditionsPress.Value<AWorkTable.ConditionsPress.SetValue) then
      begin
        AWorkTable.ConditionsPress.SetBefore(AWorkTable.ConditionsPress.BeforeValue+1);
        AWorkTable.ConditionsPress.SetAfter(AWorkTable.ConditionsPress.AfterValue+1);
      end
      else if  (AWorkTable.ConditionsPress.Value>AWorkTable.ConditionsPress.SetValue)  then
      begin
        AWorkTable.ConditionsPress.SetBefore(AWorkTable.ConditionsPress.BeforeValue-0.3);
        AWorkTable.ConditionsPress.SetAfter(AWorkTable.ConditionsPress.AfterValue-0.3);
      end;
      if (AWorkTable.ConditionsPress.SetValue<=AWorkTable.ConditionsPress.Value*(1+AWorkTable.ConditionsPress.AccuracyPlus/100))
      AND (AWorkTable.ConditionsPress.SetValue>=AWorkTable.ConditionsPress.Value*(1-AWorkTable.ConditionsPress.AccuracyMinus/100)) then
        AWorkTable.DoConditionsPressStop;

    end;
      if  (AWorkTable.ConditionsPress.Value<AWorkTable.ConditionsPress.SetValue)  then
      begin
        AWorkTable.ConditionsPress.SetBefore(EnsureRange(AWorkTable.ConditionsPress.BeforeValue + 0.1, -50.0, 150.0));
        AWorkTable.ConditionsPress.SetAfter(EnsureRange(AWorkTable.ConditionsPress.AfterValue + 0.1, -50.0, 150.0));
      end;
      if AWorkTable.ConditionsPress.SetValue<>0 then
      begin
        AWorkTable.ConditionsPress.SetBefore(EnsureRange(AWorkTable.ConditionsPress.BeforeValue + PressDelta, -50.0, 150.0));
        AWorkTable.ConditionsPress.SetAfter(EnsureRange(AWorkTable.ConditionsPress.AfterValue + PressDelta, -50.0, 150.0));
      end;




      //AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
      //AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

      FNextPressChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
   end;
end;




procedure TFormMain.UpdateRandomFreq(const APump: TPump);
var
  Freq: Double;
begin
  if APump = nil then
    Exit;

  IF (APump.Action = CONTROL_ACTION_START)  THEN
    APump.SetState(CONTROL_STARTED)
  else  if (APump.Action = CONTROL_ACTION_STOP) then
    APump.SetState(CONTROL_STOPPED);

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin
    Freq := (Random * 10);

   if APump.IsRunning = true then
    begin
      APump.Value := EnsureRange(APump.Value + Freq,APump.Value , APump.SetValue);
    end
    else
    begin
      APump.Value := EnsureRange(APump.Value - Freq,0 , APump.Value);
    end;



    FNextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;


procedure TFormMain.UpdateRandomFlowRate(const AFlowRate: TFlowRate);
var
  Flow: Double;
begin
  if AFlowRate = nil then
    Exit;


  IF AFlowRate.Action = CONTROL_ACTION_START THEN
    AFlowRate.SetState(CONTROL_STARTED)
  else  if (AFlowRate.Action = CONTROL_ACTION_STOP) then
    AFlowRate.SetState(CONTROL_STOPPED);

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin
    Flow := (Random * 10);

   if AFlowRate.IsRunning = true then
    begin
      AFlowRate.Value := EnsureRange(AFlowRate.Value + Flow,AFlowRate.Value, AFlowRate.SetValue);
    end
    else
    begin
      AFlowRate.Value  := EnsureRange(AFlowRate.Value  - Flow,0 , AFlowRate.Value );
    end;



    FNextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
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
  Pump: tPump;
  FlowRate: TFlowRate;
begin

  try
      WorkTable := FWorkTableManager.WorkTables[0]; //FActiveWorkTable;
      Pump := WorkTable.ActivePump;
      FlowRate:= WorkTable.FlowRate;
  except
       Exit;
  end;


  if WorkTable = nil then
    Exit;

   if Pump = nil then
    Exit;

    UpdateRandomClimate(WorkTable);
    UpdateRandomFreq(Pump);
    UpdateRandomFlowRate(FlowRate);
    UpdateRandomPress(WorkTable);



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
