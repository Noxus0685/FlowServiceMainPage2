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
  FMX.EditBox, FMX.SpinBox,UnitParameter;

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
    LabelEtalonFlowRate: TLabel;
    LabelEtalonImpResult: TLabel;
    EditEtalonCurSec: TEdit;
    EditEtalonImpSec: TEdit;
    EditEtalonFlowRate: TEdit;
    EditEtalonImpResult: TEdit;
    ButtonApplyEtalonValues: TButton;
    GroupBoxDeviceChannels: TGroupBox;
    LabelDeviceCurSec: TLabel;
    LabelDeviceImpSec: TLabel;
    LabelDeviceFlowRate: TLabel;
    LabelDeviceImpResult: TLabel;
    EditDeviceCurSec: TEdit;
    EditDeviceImpSec: TEdit;
    EditDeviceFlowRate: TEdit;
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
    procedure  PumpStateHandler(AParameters: TParameter; AAction:EParamAction);
    procedure EditEtalonFlowRateExit(Sender: TObject);
    procedure EditDeviceFlowRateExit(Sender: TObject);

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

    procedure FlowRateStateHandler(AParameters: TParameter;
      AAction: EParamAction);

    procedure FlowFluidTempHandler(AParameters: TParameter;
      AAction: EParamAction);
    procedure FlowFluidPressHandler(AParameters: TParameter;
      AAction: EParamAction);
    procedure UpdateRandomPress(const AWorkTable: TWorkTable);

    function GetChannelFlowCoef(const AChannel: TChannel): Double;
    function UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0):Double;
    procedure UpdateDeviceImpSecFromFlowRate;


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
  UpdateDeviceImpSecFromFlowRate;

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

  UpdateEtalonImpSecFromFlowRate;

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



procedure  TFormMain.PumpStateHandler(AParameters: TParameter; AAction:EParamAction);
begin

  FormMain.mPump.Lines.Add('Насос: ' + AParameters.Name +' Состояние: ' + FWorkTableManager.ActiveWorkTable.ActivePump.GetActionAsString);
end;

procedure TFormMain.EditDeviceFlowRateExit(Sender: TObject);
begin
  UpdateDeviceImpSecFromFlowRate;
end;

procedure TFormMain.EditEtalonFlowRateExit(Sender: TObject);
begin
  UpdateEtalonImpSecFromFlowRate;
end;







procedure  TFormMain.FlowRateStateHandler(AParameters: TParameter; AAction:EParamAction);
var
FlowRate: Double;
WorkTable:TWorkTable;
begin
  WorkTable:= FWorkTableManager.ActiveWorkTable;
  FormMain.mPump.Lines.Add('Расход воды: ' + floattostr(FWorkTableManager.ActiveWorkTable.FlowRate.ValueSet)+ ' - Состояние: ' + FWorkTableManager.ActiveWorkTable.FlowRate.GetActionAsString );

   FlowRate:=WorkTable.ValueFlowRate.GetDoubleNum(WorkTable.FlowRate.ValueSet,4);

  FFrameMainTable.ApplyChannelValues(
    FWorkTableManager.ActiveWorkTable.EtalonChannels,
    NormalizeFloatInput('0'),
    UpdateEtalonImpSecFromFlowRate(FlowRate),
    NormalizeFloatInput('0')
  );
end;

procedure  TFormMain.FlowFluidTempHandler(AParameters: TParameter; AAction:EParamAction);
begin

  FormMain.mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidTemp.ValueSet) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidTemp.GetActionAsString);

end;

procedure  TFormMain.FlowFluidPressHandler(AParameters: TParameter; AAction:EParamAction);
begin

  FormMain.mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidPress.ValueSet) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidPress.GetActionAsString);

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
var
i:integer;
begin


  FWorkTableManager := TWorkTableManager.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Settings\TableSettings.ini'
  );

    FWorkTableManager.Load;

  //Подумать над динамической привязкой ко всем столам
    if FWorkTableManager.ActiveWorkTable<>nil then
  begin
    FWorkTableManager.ActiveWorkTable.AddPump('1');
    FWorkTableManager.ActiveWorkTable.AddPump('2');
    FWorkTableManager.ActiveWorkTable.AddPump('3');



    FWorkTableManager.ActiveWorkTable.FlowRate.OnActionChange:=  FlowRateStateHandler;
    FWorkTableManager.ActiveWorkTable.FluidTemp.OnActionChange:= FlowFluidTempHandler;
    FWorkTableManager.ActiveWorkTable.FluidPress.OnActionChange:= FlowFluidPressHandler;
    for i := 0 to TPump.Pumps.Count-1 do
    begin

    TPump.Pumps[i].OnActionChange:= PumpStateHandler ;
    end;

  end;


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

  IF (AWorkTable.FluidTemp.Action = ACTION_START) OR (AWorkTable.FluidTemp.Action = ACTION_SET)THEN
    AWorkTable.FluidTemp.Status:=PARAM_STARTED
  else  if (AWorkTable.FluidTemp.Action = ACTION_STOP) then
    AWorkTable.FluidTemp.Status:=PARAM_STOPPED;


   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextClimateChangeAt = 0) or (Now >= FNextClimateChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.FluidTemp.IsRunning) then
    begin

      if NOT(AWorkTable.FluidTemp.IsStable)

      AND  (AWorkTable.FluidTemp.Value<AWorkTable.FluidTemp.ValueSet)  THEN
      begin
        AWorkTable.FluidTemp.BeforeValue:=AWorkTable.FluidTemp.BeforeValue+1;
        AWorkTable.FluidTemp.AfterValue:=(AWorkTable.FluidTemp.AfterValue+1);
      end

    ELSE if not(AWorkTable.FluidTemp.IsStable)  THEN

      begin
        AWorkTable.FluidTemp.BeforeValue:=(AWorkTable.FluidTemp.BeforeValue-1);
        AWorkTable.FluidTemp.AfterValue:=(AWorkTable.FluidTemp.AfterValue-1);
      end;

    end;


      if AWorkTable.FluidTemp.ValueSet<>0 then
      begin
        AWorkTable.FluidTemp.BeforeValue:=(EnsureRange(AWorkTable.FluidTemp.BeforeValue + TempDelta, -50.0, 150.0));
        AWorkTable.FluidTemp.AfterValue:=(EnsureRange(AWorkTable.FluidTemp.AfterValue + TempDelta, -50.0, 150.0));
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

  IF AWorkTable.FluidPress.Action = ACTION_START THEN
    AWorkTable.FluidPress.Status:=PARAM_STARTED
  else  if (AWorkTable.FluidPress.Action = ACTION_STOP) then
    AWorkTable.FluidPress.Status:=PARAM_STOPPED;

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextPressChangeAt = 0) or (Now >= FNextPressChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.FluidPress.IsRunning) then
    begin
      if  (AWorkTable.FluidPress.Value<AWorkTable.FluidPress.ValueSet) then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue+1);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue+1);
      end
      else if  (AWorkTable.FluidPress.Value>AWorkTable.FluidPress.ValueSet)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue-0.3);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue-0.3);
      end;


    end;
      if  (AWorkTable.FluidPress.Value<AWorkTable.FluidPress.ValueSet)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + 0.1, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + 0.1, -50.0, 150.0));
      end;
      if AWorkTable.FluidPress.ValueSet<>0 then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + PressDelta, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + PressDelta, -50.0, 150.0));
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

  IF (APump.Action = ACTION_START)  THEN
    APump.Status:=PARAM_STARTED
  else  if (APump.Action = ACTION_STOP) then
    APump.Status:=PARAM_STOPPED;




   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin
    Freq := (Random * 10);

   if APump.IsRunning = true then
    begin

      APump.Value:=(EnsureRange(APump.Value + Freq,APump.Value , APump.ValueSet));


    end
    else
    begin
      //APump.ValueSet:=(APump.ValueSet);
      APump.Value:=0;
    end;



    FNextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;

function TFormMain.GetChannelFlowCoef(const AChannel: TChannel): Double;
begin
  Result := 0.0;
  if (AChannel = nil) or (AChannel.FlowMeter = nil) then
    Exit;

  if (AChannel.FlowMeter.ValueCoef <> nil) then
    Result := AChannel.FlowMeter.ValueCoef.GetDoubleValue;

  if SameValue(Result, 0.0, 1E-12) and Assigned(AChannel.FlowMeter.Device) then
    Result := AChannel.FlowMeter.Device.Coef;

  if SameValue(Result, 0.0, 1E-12) then
    Result := AChannel.FlowMeter.Kp;
end;

procedure TFormMain.UpdateDeviceImpSecFromFlowRate;
var
  WorkTable: TWorkTable;
  FlowRate, Coef, ImpSec: Double;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if (WorkTable = nil) or (WorkTable.DeviceChannels.Count = 0) then
    Exit;

  FlowRate := NormalizeFloatInput(EditDeviceFlowRate.Text);
  Coef := GetChannelFlowCoef(WorkTable.DeviceChannels[0]);
  if Coef <= 0 then
    Exit;

  ImpSec := (FlowRate * Coef) / 3.6;
  EditDeviceImpSec.Text := FloatToStr(ImpSec);
end;

function TFormMain.UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0):Double;
var
  WorkTable: TWorkTable;
  FlowRate, Coef, ImpSec: Double;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if (WorkTable = nil) or (WorkTable.EtalonChannels.Count = 0) then
    Exit;

  FlowRate := NormalizeFloatInput(EditEtalonFlowRate.Text);
  Coef := GetChannelFlowCoef(WorkTable.EtalonChannels[0]);
  if Coef <= 0 then
    Exit;
  if AFlowRate<>0 then
    ImpSec := (AFlowRate * Coef) / 3.6
  else
    ImpSec := (FlowRate * Coef) / 3.6;
  EditEtalonImpSec.Text := FloatToStr(ImpSec);
  Result:= ImpSec;
end;


procedure TFormMain.UpdateRandomFlowRate(const AFlowRate: TFlowRate);
var
  Flow: Double;
begin
  if AFlowRate = nil then
    Exit;


  IF AFlowRate.Action = ACTION_START THEN
    AFlowRate.Status:=PARAM_STARTED
  else  if (AFlowRate.Action = ACTION_STOP) then
    AFlowRate.Status:=PARAM_STOPPED;

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin
    Flow := (Random * 10);
    //AFlowRate.SetMin(10,4);
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
 if FWorkTableManager.WorkTables.Count=0 then
  exit;
 WorkTable := FWorkTableManager.WorkTables[0]; //FActiveWorkTable;

  if WorkTable = nil then
    Exit;

   if FWorkTableManager.WorkTables.Count=0 then
   Exit;

   WorkTable := FWorkTableManager.WorkTables[0]; //FActiveWorkTable;

  if WorkTable = nil then
      Exit;

  try
      Pump := WorkTable.ActivePump;
      FlowRate:= WorkTable.FlowRate;
  except
      Exit;
  end;
  if Pump <> nil then
     UpdateRandomFreq(Pump);
  if Pump <> nil then
     UpdateRandomFlowRate(FlowRate);
    UpdateRandomClimate(WorkTable);
    UpdateRandomPress(WorkTable);



  case WorkTable.State of
    STATE_NONE:
      WorkTable.State := STATE_STANDBY;

    STATE_STANDBY:
      WorkTable.State := STATE_CONNECTED;

    STATE_STARTMONITOR:
      WorkTable.State := STATE_STARTMONITORWAIT;

    STATE_STARTMONITORWAIT:
      WorkTable.State := STATE_MONITOR;

    STATE_MONITOR:
       UpdateRandomSignals(WorkTable);

    STATE_STOPMONITOR,
    STATE_CONFIGED:
      WorkTable.State := STATE_CONNECTED;

    STATE_STARTTEST:
      WorkTable.State := STATE_STARTWAIT;

    STATE_STARTWAIT:
      WorkTable.State := STATE_EXECUTE;

    STATE_EXECUTE:
       UpdateRandomSignals(WorkTable);

    STATE_STOPTEST:
      WorkTable.State := STATE_STOPWAIT;

    STATE_STOPWAIT:
      WorkTable.State := STATE_COMPLETE;

    STATE_COMPLETE:
      WorkTable.State := STATE_FINALREAD;
  end;
end;







end.
