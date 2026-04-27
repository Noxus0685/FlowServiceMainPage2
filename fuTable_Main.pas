unit fuTable_Main;

interface

uses
  FMX.Colors,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.EditBox,
  FMX.Effects,
  FMX.Filter.Effects,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.SpinBox,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  frmMainTable,
  frmProceed,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.SysUtils,
  System.UITypes,
  uAppServices,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uObservable,
  uParameter,
  uWorkTable;

type
  TTableMainForm = class(TForm, IEventObserver)
    tcMain: TTabControl;
    tiTable: TTabItem;
    tiResults: TTabItem;
    tiMnemo: TTabItem;
    TimerSetValues: TTimer;
    tiTest: TTabItem;
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
    Label1: TLabel;
    LabelStd: TLabel;
    TrackStd: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure tcMainChange(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
    procedure  PumpStateHandler(AParameters: TParameter; AAction:EActionParameter);
    procedure EditEtalonFlowRateExit(Sender: TObject);
    procedure EditDeviceFlowRateExit(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackStdChange(Sender: TObject);




  private
    FWorkTableManager: TWorkTableManager;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FSubscribedWorkTable: TWorkTable;

    FT_WorkBench_Last: Double;
    FT_WorkBench_First: Double;
    FPrevFlowRateValue: Double;
    FHasPrevFlowRateValue: Boolean;

    procedure UpdateTemp(const AWorkTable: TWorkTable);




    procedure FlowRateStateHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidTempHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidPressHandler(AParameters: TParameter;
      AAction: EActionParameter);




    procedure SetT_WorkBench_First(const Value: Double);
    procedure SetT_WorkBench_Last(const Value: Double);
    procedure SubscribeToWorkTable(const AWorkTable: TWorkTable);
    procedure UnsubscribeFromWorkTable;
    procedure SubscribeToRelatedObjects(const AWorkTable: TWorkTable;
      const AObserver: IEventObserver);
    procedure UnsubscribeFromRelatedObjects(const AWorkTable: TWorkTable;
      const AObserver: IEventObserver);
    procedure HandleWorkTableNotify(ASender: TObject; AEvent: EWorkTableNotifyEvent; AData: TObject);
    procedure OnNotify(Sender: TObject; Event: Integer; Data: TObject);
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;


  public
    destructor Destroy; override;
    property T_WorkBench_First:Double read FT_WorkBench_First write SetT_WorkBench_First;
    property T_WorkBench_Last:Double read FT_WorkBench_Last write SetT_WorkBench_Last;
  end;

var
  TableMainForm: TTableMainForm;

implementation

{$R *.fmx}

destructor TTableMainForm.Destroy;
begin
  UnsubscribeFromWorkTable;
  inherited Destroy;
end;

procedure TTableMainForm.ButtonApplyDeviceValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
  FlowRate: Double;
  ImpSecValues: TArray<Double>;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if WorkTable = nil then
    Exit;

  FlowRate := NormalizeFloatInput(EditDeviceFlowRate.Text);
  EditDeviceImpSec.Text := FloatToStr(
    FWorkTableManager.UpdateDeviceImpSecFromFlowRate(WorkTable, FlowRate)
  );
  ImpSecValues := FWorkTableManager.BuildImpSecValuesForChannels(
    WorkTable,
    WorkTable.DeviceChannels,
    FlowRate,
    NormalizeFloatInput(EditDeviceImpSec.Text)
  );

  WorkTable.ApplyChannelValues(
    WorkTable.DeviceChannels,
    NormalizeFloatInput(EditDeviceCurSec.Text),
    ImpSecValues,
    NormalizeFloatInput(EditDeviceImpResult.Text)
  );

end;

procedure TTableMainForm.ButtonApplyEtalonValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
  FlowRate: Double;
  ImpSecValues: TArray<Double>;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
  if WorkTable = nil then
    Exit;

  FlowRate := NormalizeFloatInput(EditEtalonFlowRate.Text);
  EditEtalonImpSec.Text := FloatToStr(
    FWorkTableManager.UpdateEtalonImpSecFromFlowRate(WorkTable, FlowRate)
  );
  ImpSecValues := FWorkTableManager.BuildImpSecValuesForChannels(
    WorkTable,
    WorkTable.EtalonChannels,
    FlowRate,
    NormalizeFloatInput(EditEtalonImpSec.Text)
  );

  WorkTable.ApplyChannelValues(
    WorkTable.EtalonChannels,
    NormalizeFloatInput(EditEtalonCurSec.Text),
    ImpSecValues,
    NormalizeFloatInput(EditEtalonImpResult.Text)
  );

end;






procedure  TTableMainForm.PumpStateHandler(AParameters: TParameter; AAction:EActionParameter);
begin
  //TableMainForm.mPump.Lines.Add('Насос: ' + AParameters.Name +' Состояние: ' + FWorkTableManager.ActiveWorkTable.ActivePump.GetActionAsString);
end;

procedure TTableMainForm.SetT_WorkBench_First(const Value: Double);
begin
  FT_WorkBench_First := Value;
end;

procedure TTableMainForm.SetT_WorkBench_Last(const Value: Double);
begin
  FT_WorkBench_Last := Value;
end;

procedure TTableMainForm.EditDeviceFlowRateExit(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable = nil then
    Exit;
  EditDeviceImpSec.Text := FloatToStr(
    FWorkTableManager.UpdateDeviceImpSecFromFlowRate(
      WorkTable,
      NormalizeFloatInput(EditDeviceFlowRate.Text)
    )
  );
end;

procedure TTableMainForm.EditEtalonFlowRateExit(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable = nil then
    Exit;
  EditEtalonImpSec.Text := FloatToStr(
    FWorkTableManager.UpdateEtalonImpSecFromFlowRate(
      WorkTable,
      NormalizeFloatInput(EditEtalonFlowRate.Text)
    )
  );
end;







procedure  TTableMainForm.FlowRateStateHandler(AParameters: TParameter; AAction:EActionParameter);
var
FlowRate: Double;
WorkTable:TWorkTable;
i:integer;
EnabledEtalonChannels: TObjectList<TChannel>;
AValue:Double;

begin
 { WorkTable:= FWorkTableManager.ActiveWorkTable;
  TableMainForm.mPump.Lines.Add('Расход воды: ' + floattostr(WorkTable.FlowRate.ValueSet.value)+ ' - Состояние: ' + WorkTable.FlowRate.GetActionAsString );


    IF WorkTable.FlowRate.Action = apStart THEN
    WorkTable.FlowRate.State:=spStarted
  else  if (WorkTable.FlowRate.Action = apStop) then
    WorkTable.FlowRate.State:=spStopped;

  if (WorkTable.FlowRate.Action = apSet) or (WorkTable.FlowRate.Action = apStart) then
    WorkTable.ResetMeasurementValues;


   if WorkTable.FlowRate.IsRunning then
   begin
    if WorkTable.FlowRate.ValueSet.value>=WorkTable.FlowRate.Value.value then
      WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value+random(5))
    else
      WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value-random(5));
    if WorkTable.ActivePump.Value.value<12 then
      WorkTable.ActivePump.ValueSet.value:=12;
    if not(WorkTable.ActivePump.IsRunning) then
     WorkTable.ActivePump.DoPumpStart;
   end;

      }
end;

procedure  TTableMainForm.FlowFluidTempHandler(AParameters: TParameter; AAction:EActionParameter);
begin

  //TableMainForm.mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidTemp.ValueSet.value) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidTemp.GetActionAsString);

end;

procedure  TTableMainForm.FlowFluidPressHandler(AParameters: TParameter; AAction:EActionParameter);
begin

  //TableMainForm.mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidPress.ValueSet.value) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidPress.GetActionAsString);

end;



procedure TTableMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Сохраняем через централизованный AppServices, а не локальными вызовами.
  Self.WindowState := TWindowState.wsMinimized;

  if FWorkTableManager = nil then
    Exit;

  UnsubscribeFromWorkTable;

  if FFrameMainTable = nil then
    Exit;

  FFrameMainTable.SaveLayoutSettingsToWorkTable;
 // if AppServices <> nil then
  //  AppServices.SaveAll;
end;

procedure TTableMainForm.FormCreate(Sender: TObject);
var
i:integer;
begin
  FPrevFlowRateValue := 0;
  FHasPrevFlowRateValue := False;

  //Значения по умолчанию
  FT_WorkBench_First:=20;
  FT_WorkBench_Last:=20;

  // Менеджер рабочих столов теперь создаётся и живёт в AppServices.
  if AppServices = nil then
    raise Exception.Create('AppServices не инициализирован. Проверьте startup в .dpr');
  if not AppServices.Initialized then
    AppServices.Initialize;
  FWorkTableManager := AppServices.WorkTableManager;
  FSubscribedWorkTable := nil;

  //Подумать над динамической привязкой ко всем столам
    if FWorkTableManager.ActiveWorkTable<>nil then
  begin
    FWorkTableManager.ActiveWorkTable.AddPump('1');
    FWorkTableManager.ActiveWorkTable.AddPump('2');
    FWorkTableManager.ActiveWorkTable.AddPump('2');
    FWorkTableManager.ActiveWorkTable.AddPump('3');
  end;

  SubscribeToWorkTable(FWorkTableManager.ActiveWorkTable);


  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := tiTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.Initialize;



  FFrameProceed := TFrameProceed.Create(Self);
  FFrameProceed.Parent := tiResults;
  FFrameProceed.Align := TAlignLayout.Client;
  FFrameProceed.Initialize;


end;

procedure TTableMainForm.SubscribeToWorkTable(const AWorkTable: TWorkTable);
var
  Observer: IEventObserver;
begin
  if AWorkTable = nil then
    Exit;

  if FSubscribedWorkTable = AWorkTable then
    Exit;

  UnsubscribeFromWorkTable;
  Observer := Self;
  AWorkTable.Subscribe(Observer);
  SubscribeToRelatedObjects(AWorkTable, Observer);
  FSubscribedWorkTable := AWorkTable;
end;

procedure TTableMainForm.UnsubscribeFromWorkTable;
var
  Observer: IEventObserver;
  WorkTable: TWorkTable;
begin
  if FSubscribedWorkTable = nil then
    Exit;

  WorkTable := FSubscribedWorkTable;
  Observer := Self;
  UnsubscribeFromRelatedObjects(WorkTable, Observer);
  WorkTable.Unsubscribe(Observer);
  FSubscribedWorkTable := nil;
end;

procedure TTableMainForm.SubscribeToRelatedObjects(const AWorkTable: TWorkTable;
  const AObserver: IEventObserver);
var
  Pump: TPump;
begin
  if (AWorkTable = nil) or (AObserver = nil) then
    Exit;

  if AWorkTable.FlowRate <> nil then
    AWorkTable.FlowRate.Subscribe(AObserver);

  if AWorkTable.FluidTemp <> nil then
    AWorkTable.FluidTemp.Subscribe(AObserver);

  if AWorkTable.FluidPress <> nil then
    AWorkTable.FluidPress.Subscribe(AObserver);

  if AWorkTable.Pumps <> nil then
    for Pump in AWorkTable.Pumps do
      if Pump <> nil then
        Pump.Subscribe(AObserver);
end;

procedure TTableMainForm.UnsubscribeFromRelatedObjects(const AWorkTable: TWorkTable;
  const AObserver: IEventObserver);
var
  Pump: TPump;
begin
  if (AWorkTable = nil) or (AObserver = nil) then
    Exit;

  if AWorkTable.FlowRate <> nil then
    AWorkTable.FlowRate.Unsubscribe(AObserver);

  if AWorkTable.FluidTemp <> nil then
    AWorkTable.FluidTemp.Unsubscribe(AObserver);

  if AWorkTable.FluidPress <> nil then
    AWorkTable.FluidPress.Unsubscribe(AObserver);

  if AWorkTable.Pumps <> nil then
    for Pump in AWorkTable.Pumps do
      if Pump <> nil then
        Pump.Unsubscribe(AObserver);
end;

procedure TTableMainForm.HandleWorkTableNotify(ASender: TObject;
  AEvent: ENotifyEvent; AData: TObject);
var
FlowRate: TFlowRate;
Pump: TPump;
WorkTable:TWorkTable;
FluidTemp:TFluidTemp;
FluidPress:TFluidPress;
AValue:integer;
i:integer;
EnabledEtalonChannels: TObjectList<TChannel>;
  begin
  if (ASender = nil) or (FWorkTableManager = nil) then
    Exit;
  if ASender is TWorkTable then
    WorkTable:= ASender AS TWorkTable;

  if AData is TPump then
    Pump := AData as TPump;
  if AData is TFlowRate then
    FlowRate := AData as TFlowRate;
  if AData is TFluidTemp then
    FluidTemp := AData as TFluidTemp;
  if AData is tFluidPress then
    FluidPress := AData as TFluidPress;

 { if (FWorkTableManager.ActiveWorkTable = nil) or
     (ASender <> FWorkTableManager.ActiveWorkTable) then
    Exit;   }

  case AEvent of
    notifyAction:
      begin
        if AData is TPump then
          begin

              IF (Pump.Action = apStart)  THEN
                Pump.State:=spStarted
              else  if (Pump.Action = apStop) then
                Pump.State := spStopped
              else  if (Pump.Action = apSet) and not(Pump.IsRunning = true) then
                Pump.State:=spChanging
              else  if (Pump.Action = apSet) and (Pump.IsRunning = true) then
                Pump.State:=spOngoing ;
              if WorkTable.ActivePump.ValueSet.value<12 then
                WorkTable.ActivePump.ValueSet.value:=12;
              mPump.Lines.Add('Насос: ' + Pump.Name +' Состояние: ' + Pump.GetActionAsString);
          end;

        if AData is TFlowRate then
          begin
              IF (FlowRate.Action = apStart)  THEN
                FlowRate.State:=spStarted
              else  if (FlowRate.Action = apStop) then
                FlowRate.State := spStopped
              else  if (FlowRate.Action = apSet) and not(FlowRate.IsRunning = true) then
                FlowRate.State:=spChanging
              else  if (FlowRate.Action = apSet) and (FlowRate.IsRunning = true) then
               FlowRate.State:=spOngoing ;
            AValue:=random(5);
            if FlowRate.Action=apSet then
              if FlowRate.IsRunning and FHasPrevFlowRateValue then
                if FlowRate.ValueSet.Value > FPrevFlowRateValue then
                  WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value+AValue)
                else if FlowRate.ValueSet.Value < FPrevFlowRateValue then
                  if (WorkTable.ActivePump.ValueSet.value-AValue)>=WorkTable.ActivePump.Min then
                    WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value-AValue)
                  else if  (WorkTable.ActivePump.ValueSet.value-AValue)<=WorkTable.ActivePump.Min then
                    WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.Min);

            FPrevFlowRateValue := FlowRate.ValueSet.Value;
            FHasPrevFlowRateValue := True;
            if not(WorkTable.ActivePump.IsRunning) and (FlowRate.IsRunning) then
              WorkTable.ActivePump.DoPumpStart;
            mPump.Lines.Add('Расход воды: ' + floattostr(FlowRate.ValueSet.value)+ ' - Состояние: ' + FlowRate.GetActionAsString );
          end;
        if AData is TFluidTemp then
        begin
          mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FluidTemp.ValueSet.value) + ' Состояние: ' + FluidTemp.GetActionAsString);
          IF (FluidTemp.Action = apStart)  THEN
            FluidTemp.State:=spStarted
          else  if (FluidTemp.Action = apStop) then
            FluidTemp.State := spStopped
          else  if (FluidTemp.Action = apSet) and not(FluidTemp.IsRunning = true) then
            FluidTemp.State:=spChanging
          else  if (FluidTemp.Action = apSet) and (FluidTemp.IsRunning = true) then
           FluidTemp.State:=spOngoing ;
        end;
        if AData is TFluidPress then
        begin
          mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FluidPress.ValueSet.value) + ' Состояние: ' + FluidPress.GetActionAsString);
          IF (FluidPress.Action = apStart)  THEN
            FluidPress.State:=spStarted
          else  if (FluidPress.Action = apStop) then
            FluidPress.State := spStopped
          else  if (FluidPress.Action = apSet) and not(FluidPress.IsRunning = true) then
            FluidPress.State:=spChanging
          else  if (FluidPress.Action = apSet) and (FluidPress.IsRunning = true) then
           FluidPress.State:=spOngoing ;
        end;
      end;

     notifyStateChanged:
      begin


      end;

     notifyEvent:
      begin
        if AData is TPump then
          mPump.Lines.Add('Событие насоса, код: ' + IntToStr(TPump(AData).Event));
        if AData is TFlowRate then
          mPump.Lines.Add('Событие расхода, код: ' + IntToStr(TFlowRate(AData).Event));
        if AData is TFluidTemp then
          mPump.Lines.Add('Событие температуры, код: ' + IntToStr(TFluidTemp(AData).Event));
        if AData is TFluidPress then
          mPump.Lines.Add('Событие давления, код: ' + IntToStr(TFluidPress(AData).Event));
      end;

  end;


end;

procedure TTableMainForm.OnNotify(Sender: TObject; Event: Integer; Data: TObject);
var
  NotifyEvent: EWorkTableNotifyEvent;
begin
  if Sender = nil then
    Exit;


  {if (Event < Ord(Low(EWorkTableNotifyEvent))) or
     (Event > Ord(High(EWorkTableNotifyEvent))) then
    Exit;  }

  NotifyEvent := EWorkTableNotifyEvent(Event);

  if Sender is TWorkTable then
  begin
    HandleWorkTableNotify(Sender, NotifyEvent, Data);
    Exit;
  end;

  if (Sender is TPump) or
     (Sender is TFlowRate) or
     (Sender is TFluidTemp) or
     (Sender is TFluidPress) then
  begin
    // Параметры подписаны напрямую и через TWorkTable (агрегация в HandleParameterNotify).
    // Чтобы не обрабатывать одно и то же событие дважды, пропускаем прямое уведомление
    // при активной подписке на рабочий стол.
    if FSubscribedWorkTable <> nil then
      Exit;

    HandleWorkTableNotify(Sender, NotifyEvent, Sender);
  end;
end;

function TTableMainForm.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := HResult($80004002);
end;

function TTableMainForm._AddRef: Integer;
begin
  Result := -1;
end;

function TTableMainForm._Release: Integer;
begin
  Result := -1;
end;

procedure TTableMainForm.tcMainChange(Sender: TObject);
begin
  if (tcMain.ActiveTab = tiResults) and (FFrameProceed <> nil) then
    FFrameProceed.RefreshResultsTab;
end;

procedure TTableMainForm.UpdateTemp(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double; // Случайные приращения температуры и давления
  StableState: RStableInfo;     // Информация о стабильности параметра
begin
  // Если рабочая таблица не задана — выходим
  if AWorkTable = nil then
    Exit;


   //Температура до стола
   AWorkTable.FluidTemp.BeforeValue :=  FT_WorkBench_First;

   //Температура после стола
   AWorkTable.FluidTemp.AfterValue :=  FT_WorkBench_Last;



    // Если система регулирования запущена
    if (AWorkTable.FluidTemp.IsRunning) then
    begin

      // Если температура ещё НЕ стабилизировалась
      if not AWorkTable.FluidTemp.IsStable(StableState) then
      begin
        //   AWorkTable.FluidTemp.ValueSet.Value; //Значение Уставки температуры
         { }
      end
      else
        begin
         {       }
        end;

      end;

end;



procedure TTableMainForm.TimerSetValuesTimer(Sender: TObject);
begin
  FWorkTableManager.UpdateSimulation;
end;

procedure TTableMainForm.TrackStdChange(Sender: TObject);
begin
LabelStd.Text:=FormatFloat('0.00',TrackStd.Value);
end;

end.
