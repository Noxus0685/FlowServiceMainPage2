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
    ActiveWorkTable: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure tcMainChange(Sender: TObject);
    procedure TimerSetValuesTimer(Sender: TObject);
    procedure ButtonApplyEtalonValuesClick(Sender: TObject);
    procedure ButtonApplyDeviceValuesClick(Sender: TObject);
    procedure  PumpStateHandler(AParameters: TParameter; AAction:EActionParameter);
    procedure EditEtalonFlowRateExit(Sender: TObject);
    procedure EditDeviceFlowRateExit(Sender: TObject);
    procedure ActiveWorkTableChangeTracking(Sender: TObject);
    procedure ActiveWorkTableExit(Sender: TObject);
    procedure ActiveWorkTableKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackStdChange(Sender: TObject);




  private
    FWorkTableManager: TWorkTableManager;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
    FSubscribedWorkTables: TList<TWorkTable>;
    FSubscribedPumps: TList<TPump>;
    FSubscribedFlowRates: TList<TFlowRate>;
    FSubscribedFluidTemps: TList<TFluidTemp>;
    FSubscribedFluidPresses: TList<TFluidPress>;

    FT_WorkBench_Last: Double;
    FT_WorkBench_First: Double;
    FPrevFlowRateValue: Double;
    FHasPrevFlowRateValue: Boolean;
    FUpdatingActiveWorkTableEdit: Boolean;

    procedure UpdateTemp(const AWorkTable: TWorkTable);




    procedure FlowRateStateHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidTempHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidPressHandler(AParameters: TParameter;
      AAction: EActionParameter);




    procedure SetT_WorkBench_First(const Value: Double);
    procedure SetT_WorkBench_Last(const Value: Double);
    procedure SyncWorkTableObservers;
    procedure SubscribeWorkTableObjects(AWorkTable: TWorkTable);
    procedure UnsubscribeWorkTableObjects(AWorkTable: TWorkTable);
    procedure ClearWorkTableObservers;
    function FindWorkTableForObject(AObject: TObject): TWorkTable;
    procedure HandleWorkTableNotify(ASender: TObject; AEvent: EWorkTableNotifyEvent; AData: TObject);
    procedure WorkTableCommandHandler(AWorkTable: TWorkTable; AAction: EActionWorkTable);
    procedure WorkTableActionHandler(Sender: TWorkTable; AEvent: ENotifyEvent; Data: TObject);
    procedure WorkTableStateChangedHandler(Sender: TWorkTable; Data: TObject);
    procedure WorkTableEventHandler(Sender: TWorkTable; AEvent: ENotifyEvent; Data: TObject);
    procedure PumpActionHandler(Sender: TPump; AEvent: ENotifyEvent; Data: TObject);
    procedure PumpStateChangedHandler(Sender: TPump; AEvent: ENotifyEvent; Data: TObject);
    procedure PumpEventHandler(Sender: TPump; AEvent: ENotifyEvent; Data: TObject);
    procedure FlowRateActionHandler(Sender: TFlowRate; AEvent: ENotifyEvent; Data: TObject);
    procedure FlowRateStateChangedHandler(Sender: TFlowRate; AEvent: ENotifyEvent; Data: TObject);
    procedure FlowRateEventHandler(Sender: TFlowRate; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidTempActionHandler(Sender: TFluidTemp; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidTempStateChangedHandler(Sender: TFluidTemp; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidTempEventHandler(Sender: TFluidTemp; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidPressActionHandler(Sender: TFluidPress; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidPressStateChangedHandler(Sender: TFluidPress; AEvent: ENotifyEvent; Data: TObject);
    procedure FluidPressEventHandler(Sender: TFluidPress; AEvent: ENotifyEvent; Data: TObject);
    procedure UpdateActiveWorkTableEdit(const AForce: Boolean = False);
    procedure ApplyActiveWorkTableName;
    procedure OnNotify(Sender: TObject; AEvent: Integer; Data: TObject);
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
  ClearWorkTableObservers;
  FreeAndNil(FSubscribedWorkTables);
  FreeAndNil(FSubscribedPumps);
  FreeAndNil(FSubscribedFlowRates);
  FreeAndNil(FSubscribedFluidTemps);
  FreeAndNil(FSubscribedFluidPresses);
  inherited Destroy;
end;

procedure TTableMainForm.ActiveWorkTableChangeTracking(Sender: TObject);
begin
  ApplyActiveWorkTableName;
end;

procedure TTableMainForm.ActiveWorkTableExit(Sender: TObject);
begin
  ApplyActiveWorkTableName;
end;

procedure TTableMainForm.ActiveWorkTableKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    ApplyActiveWorkTableName;
    Key := 0;
  end;
end;

procedure TTableMainForm.ApplyActiveWorkTableName;
var
  WorkTable: TWorkTable;
  NewName: string;
begin
  if FUpdatingActiveWorkTableEdit or (FWorkTableManager = nil) or
     (ActiveWorkTable = nil) then
    Exit;

  WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable = nil then
    Exit;

  NewName := Trim(ActiveWorkTable.Text);
  if NewName = '' then
  begin
    if not ActiveWorkTable.IsFocused then
      UpdateActiveWorkTableEdit(True);
    Exit;
  end;

  if WorkTable.Name = NewName then
    Exit;

  WorkTable.Name := NewName;
  WorkTable.FireEvent(ewtRefresh);
  FWorkTableManager.Save;
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

  ClearWorkTableObservers;

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
  FUpdatingActiveWorkTableEdit := False;

  //Значения по умолчанию
  FT_WorkBench_First:=20;
  FT_WorkBench_Last:=20;

  // Менеджер рабочих столов теперь создаётся и живёт в AppServices.
  if AppServices = nil then
    raise Exception.Create('AppServices не инициализирован. Проверьте startup в .dpr');
  if not AppServices.Initialized then
    AppServices.Initialize;
  FWorkTableManager := AppServices.WorkTableManager;

  if FSubscribedWorkTables = nil then
    FSubscribedWorkTables := TList<TWorkTable>.Create;
  if FSubscribedPumps = nil then
    FSubscribedPumps := TList<TPump>.Create;
  if FSubscribedFlowRates = nil then
    FSubscribedFlowRates := TList<TFlowRate>.Create;
  if FSubscribedFluidTemps = nil then
    FSubscribedFluidTemps := TList<TFluidTemp>.Create;
  if FSubscribedFluidPresses = nil then
    FSubscribedFluidPresses := TList<TFluidPress>.Create;

  //Подумать над динамической привязкой ко всем столам
    if FWorkTableManager.ActiveWorkTable<>nil then
  begin
    FWorkTableManager.ActiveWorkTable.AddPump('1');
    FWorkTableManager.ActiveWorkTable.AddPump('2');
    FWorkTableManager.ActiveWorkTable.AddPump('2');
    FWorkTableManager.ActiveWorkTable.AddPump('3');
  end;

  SyncWorkTableObservers;
  UpdateActiveWorkTableEdit;


  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := tiTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.OnWorkTableCommand := WorkTableCommandHandler;
  FFrameMainTable.Initialize;



  FFrameProceed := TFrameProceed.Create(Self);
  FFrameProceed.Parent := tiResults;
  FFrameProceed.Align := TAlignLayout.Client;
  FFrameProceed.Initialize;


end;

procedure TTableMainForm.SyncWorkTableObservers;
var
  WorkTable: TWorkTable;
  Pump: TPump;
  FlowRate: TFlowRate;
  FluidTemp: TFluidTemp;
  FluidPress: TFluidPress;
  I: Integer;
  Observer: IEventObserver;
begin
  if FSubscribedWorkTables = nil then
    Exit;

  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
  begin
    ClearWorkTableObservers;
    Exit;
  end;

  Observer := Self;

  for WorkTable in FWorkTableManager.WorkTables do
  begin
    if WorkTable = nil then
      Continue;

    if not FSubscribedWorkTables.Contains(WorkTable) then
    begin
      WorkTable.Subscribe(Observer);
      FSubscribedWorkTables.Add(WorkTable);
    end;

    SubscribeWorkTableObjects(WorkTable);
  end;

  for I := FSubscribedWorkTables.Count - 1 downto 0 do
  begin
    WorkTable := FSubscribedWorkTables[I];
    if (WorkTable = nil) or (FWorkTableManager.WorkTables.IndexOf(WorkTable) < 0) then
    begin
      if WorkTable <> nil then
      begin
        UnsubscribeWorkTableObjects(WorkTable);
        WorkTable.Unsubscribe(Observer);
      end;
      FSubscribedWorkTables.Delete(I);
    end;
  end;

  if FSubscribedPumps <> nil then
    for I := FSubscribedPumps.Count - 1 downto 0 do
    begin
      Pump := FSubscribedPumps[I];
      if (Pump = nil) or (FindWorkTableForObject(Pump) = nil) then
      begin
        if Pump <> nil then
          Pump.Unsubscribe(Observer);
        FSubscribedPumps.Delete(I);
      end;
    end;

  if FSubscribedFlowRates <> nil then
    for I := FSubscribedFlowRates.Count - 1 downto 0 do
    begin
      FlowRate := FSubscribedFlowRates[I];
      if (FlowRate = nil) or (FindWorkTableForObject(FlowRate) = nil) then
      begin
        if FlowRate <> nil then
          FlowRate.Unsubscribe(Observer);
        FSubscribedFlowRates.Delete(I);
      end;
    end;

  if FSubscribedFluidTemps <> nil then
    for I := FSubscribedFluidTemps.Count - 1 downto 0 do
    begin
      FluidTemp := FSubscribedFluidTemps[I];
      if (FluidTemp = nil) or (FindWorkTableForObject(FluidTemp) = nil) then
      begin
        if FluidTemp <> nil then
          FluidTemp.Unsubscribe(Observer);
        FSubscribedFluidTemps.Delete(I);
      end;
    end;

  if FSubscribedFluidPresses <> nil then
    for I := FSubscribedFluidPresses.Count - 1 downto 0 do
    begin
      FluidPress := FSubscribedFluidPresses[I];
      if (FluidPress = nil) or (FindWorkTableForObject(FluidPress) = nil) then
      begin
        if FluidPress <> nil then
          FluidPress.Unsubscribe(Observer);
        FSubscribedFluidPresses.Delete(I);
      end;
    end;
end;

procedure TTableMainForm.SubscribeWorkTableObjects(AWorkTable: TWorkTable);
var
  Pump: TPump;
  Observer: IEventObserver;
begin
  if AWorkTable = nil then
    Exit;

  Observer := Self;

  if Assigned(AWorkTable.FlowRate) and Assigned(FSubscribedFlowRates) and
     not FSubscribedFlowRates.Contains(AWorkTable.FlowRate) then
  begin
    AWorkTable.FlowRate.Subscribe(Observer);
    FSubscribedFlowRates.Add(AWorkTable.FlowRate);
  end;

  if Assigned(AWorkTable.FluidTemp) and Assigned(FSubscribedFluidTemps) and
     not FSubscribedFluidTemps.Contains(AWorkTable.FluidTemp) then
  begin
    AWorkTable.FluidTemp.Subscribe(Observer);
    FSubscribedFluidTemps.Add(AWorkTable.FluidTemp);
  end;

  if Assigned(AWorkTable.FluidPress) and Assigned(FSubscribedFluidPresses) and
     not FSubscribedFluidPresses.Contains(AWorkTable.FluidPress) then
  begin
    AWorkTable.FluidPress.Subscribe(Observer);
    FSubscribedFluidPresses.Add(AWorkTable.FluidPress);
  end;

  if AWorkTable.Pumps <> nil then
    for Pump in AWorkTable.Pumps do
      if Assigned(Pump) and Assigned(FSubscribedPumps) and
         not FSubscribedPumps.Contains(Pump) then
      begin
        Pump.Subscribe(Observer);
        FSubscribedPumps.Add(Pump);
      end;
end;

procedure TTableMainForm.UnsubscribeWorkTableObjects(AWorkTable: TWorkTable);
var
  Pump: TPump;
  Observer: IEventObserver;
begin
  if AWorkTable = nil then
    Exit;

  Observer := Self;

  if Assigned(AWorkTable.FlowRate) and Assigned(FSubscribedFlowRates) and
     FSubscribedFlowRates.Contains(AWorkTable.FlowRate) then
  begin
    AWorkTable.FlowRate.Unsubscribe(Observer);
    FSubscribedFlowRates.Remove(AWorkTable.FlowRate);
  end;

  if Assigned(AWorkTable.FluidTemp) and Assigned(FSubscribedFluidTemps) and
     FSubscribedFluidTemps.Contains(AWorkTable.FluidTemp) then
  begin
    AWorkTable.FluidTemp.Unsubscribe(Observer);
    FSubscribedFluidTemps.Remove(AWorkTable.FluidTemp);
  end;

  if Assigned(AWorkTable.FluidPress) and Assigned(FSubscribedFluidPresses) and
     FSubscribedFluidPresses.Contains(AWorkTable.FluidPress) then
  begin
    AWorkTable.FluidPress.Unsubscribe(Observer);
    FSubscribedFluidPresses.Remove(AWorkTable.FluidPress);
  end;

  if AWorkTable.Pumps <> nil then
    for Pump in AWorkTable.Pumps do
      if Assigned(Pump) and Assigned(FSubscribedPumps) and
         FSubscribedPumps.Contains(Pump) then
      begin
        Pump.Unsubscribe(Observer);
        FSubscribedPumps.Remove(Pump);
      end;
end;

procedure TTableMainForm.ClearWorkTableObservers;
var
  Observer: IEventObserver;
begin
  Observer := Self;

  if Assigned(FSubscribedWorkTables) then
    while FSubscribedWorkTables.Count > 0 do
    begin
      if FSubscribedWorkTables[FSubscribedWorkTables.Count - 1] <> nil then
        FSubscribedWorkTables[FSubscribedWorkTables.Count - 1].Unsubscribe(Observer);
      FSubscribedWorkTables.Delete(FSubscribedWorkTables.Count - 1);
    end;

  if Assigned(FSubscribedPumps) then
    while FSubscribedPumps.Count > 0 do
    begin
      if FSubscribedPumps[FSubscribedPumps.Count - 1] <> nil then
        FSubscribedPumps[FSubscribedPumps.Count - 1].Unsubscribe(Observer);
      FSubscribedPumps.Delete(FSubscribedPumps.Count - 1);
    end;

  if Assigned(FSubscribedFlowRates) then
    while FSubscribedFlowRates.Count > 0 do
    begin
      if FSubscribedFlowRates[FSubscribedFlowRates.Count - 1] <> nil then
        FSubscribedFlowRates[FSubscribedFlowRates.Count - 1].Unsubscribe(Observer);
      FSubscribedFlowRates.Delete(FSubscribedFlowRates.Count - 1);
    end;

  if Assigned(FSubscribedFluidTemps) then
    while FSubscribedFluidTemps.Count > 0 do
    begin
      if FSubscribedFluidTemps[FSubscribedFluidTemps.Count - 1] <> nil then
        FSubscribedFluidTemps[FSubscribedFluidTemps.Count - 1].Unsubscribe(Observer);
      FSubscribedFluidTemps.Delete(FSubscribedFluidTemps.Count - 1);
    end;

  if Assigned(FSubscribedFluidPresses) then
    while FSubscribedFluidPresses.Count > 0 do
    begin
      if FSubscribedFluidPresses[FSubscribedFluidPresses.Count - 1] <> nil then
        FSubscribedFluidPresses[FSubscribedFluidPresses.Count - 1].Unsubscribe(Observer);
      FSubscribedFluidPresses.Delete(FSubscribedFluidPresses.Count - 1);
    end;
end;

function TTableMainForm.FindWorkTableForObject(AObject: TObject): TWorkTable;
var
  WorkTable: TWorkTable;
begin
  Result := nil;
  if (AObject = nil) or (FWorkTableManager = nil) or
     (FWorkTableManager.WorkTables = nil) then
    Exit;

  for WorkTable in FWorkTableManager.WorkTables do
  begin
    if WorkTable = nil then
      Continue;

    if (AObject = WorkTable) or (AObject = WorkTable.FlowRate) or
       (AObject = WorkTable.FluidTemp) or (AObject = WorkTable.FluidPress) or
       ((AObject is TPump) and (WorkTable.Pumps <> nil) and
        (WorkTable.Pumps.IndexOf(TPump(AObject)) >= 0)) then
      Exit(WorkTable);
  end;
end;

procedure TTableMainForm.WorkTableStateChangedHandler(Sender: TWorkTable; Data: TObject);
var WorkTable: TWorkTable;
    State: EStateWorkTable;
begin
      WorkTable:=Sender;
      State:= WorkTable.State;

 case State of

    // ------------------------------------------------------------
    // Начальное состояние
    // ------------------------------------------------------------
    swtNONE:
     begin
      //WorkTable.State := swtSTANDBY;
     end;

    // ------------------------------------------------------------
    // Ожидание →

    // ожидаем состояние "система подключена" - swtCONNECTED
    // ------------------------------------------------------------
    swtSTANDBY:
    begin

    end;

    // ------------------------------------------------------------
    // Запуск мониторинга
    // ------------------------------------------------------------
    swtSTARTMONITOR:
    begin
      //WorkTable.State := swtSTARTMONITORWAIT;

    end;

    // ------------------------------------------------------------
    // Ожидание запуска мониторинга → переход в мониторинг
    // ------------------------------------------------------------
    swtSTARTMONITORWAIT:
    begin
      //WorkTable.State:= swtMONITOR;

    end;

    // ------------------------------------------------------------
    // Мониторинг (наблюдение без измерения)
    // ------------------------------------------------------------
    swtMONITOR:
    begin

     // UpdateRandomSignals(WorkTable); // обновление показаний
    end;

    // ------------------------------------------------------------
    // Остановка мониторинга или конфигурация
    // → возвращаемся в подключённое состояние
    // ------------------------------------------------------------
    swtSTOPMONITOR,
    swtCONFIGED:
    begin
     // WorkTable.State := swtCONNECTED;
    end;

    // ------------------------------------------------------------
    // Запуск теста
    // ------------------------------------------------------------
    swtSTARTTEST:
    begin

      //WorkTable.State := swtSTARTWAIT;
    end;

    // ------------------------------------------------------------
    // Ожидание старта → переход к выполнению
    // ------------------------------------------------------------
    swtSTARTWAIT:
    begin
      //WorkTable.State := swtEXECUTE;
    end;

    // ============================================================
    // 4. Основной процесс измерения
    // ============================================================
    swtEXECUTE:
    begin

    end;


    // ------------------------------------------------------------
    // Инициация остановки теста
    // ------------------------------------------------------------
    swtSTOPTEST:
    begin

    end;


    // ------------------------------------------------------------
    // Ожидание полной остановки
    // ------------------------------------------------------------
    swtSTOPWAIT:
    begin

    end;


    // ------------------------------------------------------------
    // Тест завершён → переход к финальному считыванию
    // ------------------------------------------------------------
    swtCOMPLETE:
    begin

    end;


  end;



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
  FlowRate := nil;
  Pump := nil;
  WorkTable := nil;
  FluidTemp := nil;
  FluidPress := nil;

  if (ASender = nil) or (FWorkTableManager = nil) then
    Exit;
  if ASender is TWorkTable then
    WorkTable:= ASender AS TWorkTable
  else
    WorkTable := FindWorkTableForObject(ASender);

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

  if WorkTable = nil then
    WorkTable := FWorkTableManager.ActiveWorkTable;

  case AEvent of
    notifyAction:
      begin





        if AData is TPump then
          begin
            if (WorkTable = nil) or (WorkTable.ActivePump = nil) then
              Exit;

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
          end;

        if AData is TFlowRate then
          begin
            if (WorkTable = nil) or (WorkTable.ActivePump = nil) then
              Exit;

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
          end;
        if AData is TFluidTemp then
        begin
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
        if (ASender is TWorkTable) and
           (TWorkTable(ASender).Event in [Ord(ewtActivated), Ord(ewtRefresh)]) then
          UpdateActiveWorkTableEdit;

      end;

  end;


end;

procedure TTableMainForm.WorkTableCommandHandler(AWorkTable: TWorkTable;
  AAction: EActionWorkTable);
begin
  if AWorkTable = nil then
    Exit;

  case AAction of
    awtStartTest:
      AWorkTable.StartTest;
    awtStopTest:
      AWorkTable.StopTest;
  end;
end;

procedure TTableMainForm.WorkTableActionHandler(Sender: TWorkTable;
  AEvent: ENotifyEvent; Data: TObject);

var WorkTable: TWorkTable;
    State: EStateWorkTable;
    Error: TErrorInfo;
begin
      WorkTable:=Sender;
      State:= Sender.State;

  case Sender.Action of
    awtStartTest:
    begin
      // Возникает, когда необходимо запустить измерение
      // (кнопка "Старт" в ручном режиме/команда запуска измерения при автомате).


       WorkTable.State := swtSTARTWAIT;

    end;

    awtStopTest:
    begin

       WorkTable.State := swtSTOPWAIT;

    end;

    awtStartMonitor:
    begin
      // Возникает, когда пользователь запускает обновление стола (режим TEST)

       WorkTable.State := swtSTARTMONITOR;

    end;


    awtStopMonitor:
       begin
      // Возникает, когда пользователь останавливает обновление стола (режим TEST)


       WorkTable.State := swtSTOPMONITOR;


      end;


    awtAddPump:
    begin
      // При добавлении насоса к столу подписываем форму на события насоса
      // и связанных объектов стола.
      SubscribeWorkTableObjects(Sender);
    end;

    awtRemovePump:
    begin
      // При добавлении насоса к столу подписываем форму на события насоса
      // и связанных объектов стола.
      SyncWorkTableObservers
    end;

  else
    begin
      // Резервная ветка: неизвестное действие.
      // Здесь можно добавить диагностику/защиту от некорректных команд.
    end;
  end;


end;



  {
procedure TTableMainForm.WorkTableStateChangedHandler(Sender: TWorkTable;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(Sender, AEvent, Data);
end;
     }
procedure TTableMainForm.WorkTableEventHandler(Sender: TWorkTable;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  if (Data is TPump) or (Data is TFlowRate) or (Data is TFluidTemp) or
     (Data is TFluidPress) then
    Exit;

  HandleWorkTableNotify(Sender, AEvent, Data);
end;

procedure TTableMainForm.PumpActionHandler(Sender: TPump; AEvent: ENotifyEvent;
  Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.PumpStateChangedHandler(Sender: TPump;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.PumpEventHandler(Sender: TPump; AEvent: ENotifyEvent;
  Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FlowRateActionHandler(Sender: TFlowRate;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FlowRateStateChangedHandler(Sender: TFlowRate;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FlowRateEventHandler(Sender: TFlowRate;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidTempActionHandler(Sender: TFluidTemp;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidTempStateChangedHandler(Sender: TFluidTemp;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidTempEventHandler(Sender: TFluidTemp;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidPressActionHandler(Sender: TFluidPress;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidPressStateChangedHandler(Sender: TFluidPress;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.FluidPressEventHandler(Sender: TFluidPress;
  AEvent: ENotifyEvent; Data: TObject);
begin
  if Sender = nil then
    Exit;

  HandleWorkTableNotify(FindWorkTableForObject(Sender), AEvent, Sender);
end;

procedure TTableMainForm.OnNotify(Sender: TObject; AEvent: Integer; Data: TObject);
var
  LNotifyEvent: ENotifyEvent;
begin
  if Sender = nil then
    Exit;

  LNotifyEvent := ENotifyEvent(AEvent);

  if Sender is TWorkTable then
  begin
    case LNotifyEvent of
      notifyStateChanged:
        WorkTableStateChangedHandler(TWorkTable(Sender),Data);
      notifyAction:
        WorkTableActionHandler(TWorkTable(Sender), LNotifyEvent, Data);
      notifyEvent:
        WorkTableEventHandler(TWorkTable(Sender), LNotifyEvent, Data);
    end;
    Exit;
  end;

  if Sender is TPump then
  begin
    case LNotifyEvent of
      notifyStateChanged:
        PumpStateChangedHandler(TPump(Sender), LNotifyEvent, Data);
      notifyAction:
        PumpActionHandler(TPump(Sender), LNotifyEvent, Data);
      notifyEvent:
        PumpEventHandler(TPump(Sender), LNotifyEvent, Data);
    end;
    Exit;
  end;

  if Sender is TFlowRate then
  begin
    case LNotifyEvent of
      notifyStateChanged:
        FlowRateStateChangedHandler(TFlowRate(Sender), LNotifyEvent, Data);
      notifyAction:
        FlowRateActionHandler(TFlowRate(Sender), LNotifyEvent, Data);
      notifyEvent:
        FlowRateEventHandler(TFlowRate(Sender), LNotifyEvent, Data);
    end;
    Exit;
  end;

  if Sender is TFluidTemp then
  begin
    case LNotifyEvent of
      notifyStateChanged:
        FluidTempStateChangedHandler(TFluidTemp(Sender), LNotifyEvent, Data);
      notifyAction:
        FluidTempActionHandler(TFluidTemp(Sender), LNotifyEvent, Data);
      notifyEvent:
        FluidTempEventHandler(TFluidTemp(Sender), LNotifyEvent, Data);
    end;
    Exit;
  end;

  if Sender is TFluidPress then
  begin
    case LNotifyEvent of
      notifyStateChanged:
        FluidPressStateChangedHandler(TFluidPress(Sender), LNotifyEvent, Data);
      notifyAction:
        FluidPressActionHandler(TFluidPress(Sender), LNotifyEvent, Data);
      notifyEvent:
        FluidPressEventHandler(TFluidPress(Sender), LNotifyEvent, Data);
    end;
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
  if (tcMain.ActiveTab =  tiTable ) then
    FFrameMainTable.UpdateForm;
end;

procedure TTableMainForm.UpdateActiveWorkTableEdit(const AForce: Boolean);
var
  WorkTable: TWorkTable;
  DisplayName: string;
begin
  if (FWorkTableManager = nil) or (ActiveWorkTable = nil) or
     (ActiveWorkTable.IsFocused and not AForce) then
    Exit;

  WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable = nil then
    DisplayName := ''
  else
  begin

    DisplayName := Trim(WorkTable.Name);
    if DisplayName = '' then
      DisplayName := WorkTable.Text;

  end;

  if ActiveWorkTable.Text = DisplayName then
    Exit;

  FUpdatingActiveWorkTableEdit := True;
  try
    ActiveWorkTable.Text := DisplayName;
  finally
    FUpdatingActiveWorkTableEdit := False;
  end;
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
  if FWorkTableManager = nil then
    Exit;

  SyncWorkTableObservers;
  UpdateActiveWorkTableEdit;

  FWorkTableManager.UpdateSimulation;
end;



procedure TTableMainForm.TrackStdChange(Sender: TObject);
begin
LabelStd.Text:=FormatFloat('0.00',TrackStd.Value);
end;

end.
