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

    procedure UpdateTemp(const AWorkTable: TWorkTable);


    procedure UpdateRandomTemp(const AWorkTable: TWorkTable);
    procedure UpdateRandomSignals(const AWorkTable: TWorkTable);
    procedure UpdateRandomFreq(const AWorkTable: TWorkTable);
    procedure UpdateRandomFlowRate(const AWorkTable: TWorkTable);
    procedure ExecuteRandomControlAction(const AWorkTable: TWorkTable);
    function BuildImpSecValuesForChannels(AChannels: TObjectList<TChannel>;
      const AFlowRate, AFallbackImpSec: Double): TArray<Double>;



    procedure FlowRateStateHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidTempHandler(AParameters: TParameter;
      AAction: EActionParameter);
    procedure FlowFluidPressHandler(AParameters: TParameter;
      AAction: EActionParameter);




    procedure UpdateRandomPress(const AWorkTable: TWorkTable);

    function GetChannelFlowCoef(const AChannel: TChannel): Double;
    function UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0;
      AEtalonChannels: TObjectList<TChannel> = nil):Double;
    procedure UpdateDeviceImpSecFromFlowRate;
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

  UpdateDeviceImpSecFromFlowRate;
  FlowRate := NormalizeFloatInput(EditDeviceFlowRate.Text);
  ImpSecValues := BuildImpSecValuesForChannels(
    WorkTable.DeviceChannels,
    FlowRate,
    NormalizeFloatInput(EditDeviceImpSec.Text)
  );

  FFrameMainTable.ApplyChannelValues(
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

  UpdateEtalonImpSecFromFlowRate;
  FlowRate := NormalizeFloatInput(EditEtalonFlowRate.Text);
  ImpSecValues := BuildImpSecValuesForChannels(
    WorkTable.EtalonChannels,
    FlowRate,
    NormalizeFloatInput(EditEtalonImpSec.Text)
  );

  FFrameMainTable.ApplyChannelValues(
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
begin
  UpdateDeviceImpSecFromFlowRate;
end;

procedure TTableMainForm.EditEtalonFlowRateExit(Sender: TObject);
begin
  UpdateEtalonImpSecFromFlowRate;
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
    FWorkTableManager.ActiveWorkTable.AddPump('3');



    for i := 0 to TPump.Pumps.Count-1 do
    begin

    end;

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
i:integer;
EnabledEtalonChannels: TObjectList<TChannel>;
AValue:Double;
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
                {if FlowRate.ValueSet.value>=FlowRate.Value.value then
                  WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value+random(5))
                else
                  WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value-random(5));   }
                if WorkTable.ActivePump.Value.value<12 then
                  WorkTable.ActivePump.ValueSet.value:=12;
                if not(WorkTable.ActivePump.IsRunning) then
                  WorkTable.ActivePump.DoPumpStart;
               mPump.Lines.Add('Расход воды: ' + floattostr(FlowRate.ValueSet.value)+ ' - Состояние: ' + FlowRate.GetActionAsString );
          end;
        if AData is TFluidTemp then
          mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FluidTemp.ValueSet.value) + ' Состояние: ' + FluidTemp.GetActionAsString);

        if AData is TFluidPress then
          mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FluidPress.ValueSet.value) + ' Состояние: ' + FluidPress.GetActionAsString);

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
    HandleWorkTableNotify(Sender, NotifyEvent, Data);

  if (Sender is TPump) or
     (Sender is TFlowRate) or
     (Sender is TFluidTemp) or
     (Sender is TFluidPress) then
    HandleWorkTableNotify(FSubscribedWorkTable, NotifyEvent, Sender);
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

procedure TTableMainForm.UpdateRandomTemp(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double; // Случайные приращения температуры и давления
  StableState: RStableInfo;     // Информация о стабильности параметра
begin
  // ============================================================
  // 1. Проверка входных данных
  // ============================================================

  // Если рабочая таблица не задана — выходим
  if AWorkTable = nil then
    Exit;



  // ============================================================
  // 3. Ограничение частоты обновления (не каждый тик таймера)
  // ============================================================

  // Обновляем температуру не постоянно, а раз в несколько секунд
  if (AWorkTable.NextClimateChangeAt = 0) or (Now >= AWorkTable.NextClimateChangeAt) then
  begin

    // ----------------------------------------------------------
    // 3.1 Генерация случайных изменений (шум системы)
    // ----------------------------------------------------------

    // Температура ±0.15
    TempDelta := (Random * 0.30) - 0.15;

    // Давление ±0.03 (сейчас не используется)
    PressDelta := (Random * 0.06) - 0.03;


    // ----------------------------------------------------------
    // 3.2 Регулирование температуры (имитация ПИД-подобного поведения)
    // ----------------------------------------------------------

    // Если система регулирования запущена
    if (AWorkTable.FluidTemp.IsRunning) then
    begin

      // Если температура ещё НЕ стабилизировалась
      if not AWorkTable.FluidTemp.IsStable(StableState) then
      begin

        // Если текущая температура меньше заданной → "нагреваем"
        if AWorkTable.FluidTemp.Value.Value < AWorkTable.FluidTemp.ValueSet.Value then
        begin
          AWorkTable.FluidTemp.BeforeValue :=
            AWorkTable.FluidTemp.BeforeValue + 1;

          AWorkTable.FluidTemp.AfterValue :=
            AWorkTable.FluidTemp.AfterValue + 1;
        end
        else
        begin
          // Иначе → "охлаждаем"
          AWorkTable.FluidTemp.BeforeValue :=
            AWorkTable.FluidTemp.BeforeValue - 1;

          AWorkTable.FluidTemp.AfterValue :=
            AWorkTable.FluidTemp.AfterValue - 1;
        end;

      end;

    end;


    // ----------------------------------------------------------
    // 3.3 Добавление случайного шума (реалистичность)
    // ----------------------------------------------------------

    // Если задано целевое значение температуры
    if AWorkTable.FluidTemp.ValueSet.Value <> 0 then
    begin
      // Добавляем небольшое случайное отклонение
      // и ограничиваем диапазон допустимых значений

      AWorkTable.FluidTemp.BeforeValue :=
        EnsureRange(
          AWorkTable.FluidTemp.BeforeValue + TempDelta,
          -50.0, 150.0);

      AWorkTable.FluidTemp.AfterValue :=
        EnsureRange(
          AWorkTable.FluidTemp.AfterValue + TempDelta,
          -50.0, 150.0);
    end;

    // ----------------------------------------------------------
    // 3.5 Планирование следующего изменения
    // ----------------------------------------------------------

    // Следующее обновление через 3–4 секунды
    AWorkTable.NextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
  end;
end;

procedure TTableMainForm.UpdateRandomPress(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

  if (AWorkTable.NextPressChangeAt = 0) or (Now >= AWorkTable.NextPressChangeAt) then
  begin

    TempDelta :=  (Random * 0.30) - 0.15;
    PressDelta :=  (Random * 0.06) - 0.03;
    if (AWorkTable.FluidPress.IsRunning) then
    begin
      if  (AWorkTable.FluidPress.Value.value<AWorkTable.FluidPress.ValueSet.value) then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue+1);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue+1);
      end
      else if  (AWorkTable.FluidPress.Value.value>AWorkTable.FluidPress.ValueSet.value)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(AWorkTable.FluidPress.BeforeValue-0.3);
        AWorkTable.FluidPress.AfterValue:=(AWorkTable.FluidPress.AfterValue-0.3);
      end;


    end;
      if  (AWorkTable.FluidPress.Value.value<AWorkTable.FluidPress.ValueSet.value)  then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + 0.1, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + 0.1, -50.0, 150.0));
      end;
      if AWorkTable.FluidPress.ValueSet.value<>0 then
      begin
        AWorkTable.FluidPress.BeforeValue:=(EnsureRange(AWorkTable.FluidPress.BeforeValue + PressDelta, -50.0, 150.0));
        AWorkTable.FluidPress.AfterValue:=(EnsureRange(AWorkTable.FluidPress.AfterValue + PressDelta, -50.0, 150.0));
      end;




      //AWorkTable.Temp := EnsureRange(AWorkTable.Temp + TempDelta, -50.0, 150.0);
      //AWorkTable.Press := EnsureRange(AWorkTable.Press + PressDelta, 0.0, 10.0);

      AWorkTable.NextPressChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
   end;
end;

procedure TTableMainForm.UpdateRandomFreq(const AWorkTable: TWorkTable);
var
  Pump: tPump;             // Активный насос (исполнитель)
  Freq: Double;
begin
  Pump := AWorkTable.ActivePump;   // Насос (может быть nil)


  if Pump = nil then
    Exit;



   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (AWorkTable.NextFreqChangeAt = 0) or (Now >= AWorkTable.NextFreqChangeAt) then
  begin
    Freq := (Random * 10);

   if Pump.IsRunning = true then
    begin

      Pump.Value.value:=(EnsureRange(Pump.Value.value + Freq,Pump.Value.value , Pump.ValueSet.value));


    end
    else
    begin
      //Pump.ValueSet:=(Pump.ValueSet);
      Pump.Value.value:=0;
    end;



    AWorkTable.NextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;

function TTableMainForm.GetChannelFlowCoef(const AChannel: TChannel): Double;
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

procedure TTableMainForm.UpdateDeviceImpSecFromFlowRate;
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

function TTableMainForm.UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0;
  AEtalonChannels: TObjectList<TChannel> = nil):Double;
var
  WorkTable: TWorkTable;
  FlowRate, Coef, ImpSec: Double;
  i:integer;
begin
  Coef:=0;
  WorkTable := FWorkTableManager.WorkTables[0];
  if (WorkTable = nil) or (WorkTable.EtalonChannels.Count = 0) then
    Exit;




  if (AEtalonChannels <> nil) and (AEtalonChannels.Count > 0) then
    for I := 0 to AEtalonChannels.Count - 1 do
      Coef :=Coef+ GetChannelFlowCoef(AEtalonChannels[i])
  else if AEtalonChannels=nil then
      Coef := GetChannelFlowCoef(WorkTable.EtalonChannels[0]);

  FlowRate := NormalizeFloatInput(EditEtalonFlowRate.Text);
  //Coef := GetChannelFlowCoef(WorkTable.EtalonChannels[0]);
  if Coef <= 0 then
    Exit;
  if AFlowRate<>0 then
    ImpSec := (AFlowRate * Coef) / 3.6
  else
    ImpSec := (FlowRate * Coef) / 3.6;
  EditEtalonImpSec.Text := FloatToStr(ImpSec);
  Result:= ImpSec;
end;

function TTableMainForm.BuildImpSecValuesForChannels(AChannels: TObjectList<TChannel>;
  const AFlowRate, AFallbackImpSec: Double): TArray<Double>;
var
  I: Integer;
  Coef,SUM,MaxRatio : Double;
  WorkTable:tWorkTable;
begin
  WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable = nil then
    Exit;
  SetLength(Result, 0);
  if AChannels = nil then
    Exit;
  SUM:=0;
   for I := 0 to AChannels.Count-1 do
    begin
      SUM:=SUM+WorkTable.ValueFlowRate.GetDoubleBaseNum( AChannels[i].FlowMeter.Device.Qmax,4);
    end;

  SetLength(Result, AChannels.Count);
  for I := 0 to AChannels.Count - 1 do
  begin
    if SameValue(SUM, 0.0, 1e-12) then
      MaxRatio:=0
    else
      MaxRatio := (WorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[i].FlowMeter.Device.Qmax,4))/SUM;
    Coef := GetChannelFlowCoef(AChannels[I]);
    if Coef > 0 then
      Result[I] := (AFlowRate*MaxRatio * Coef) / 3.6
    else
      Result[I] := AFallbackImpSec;
  end;
end;

procedure TTableMainForm.UpdateRandomFlowRate(const AWorkTable: TWorkTable);
var
  Flow: Double;

  WorkTable:TWorkTable;
  FlowRate: TFlowRate;
  i:integer;
  EnabledEtalonChannels: TObjectList<TChannel>;
  EnabledDeviceChannels: TObjectList<TChannel>;
  AValue:Double;
  ImpSecValues: TArray<Double>;
  TotalQmax: Double;
  ChannelQmax: Double;
  ChannelFlowRate: Double;
  ChannelCoef: Double;
  ChannelRatio: Double;
begin

  FlowRate := AWorkTable.FlowRate; // Контроллер расхода
  if FlowRate = nil then
    Exit;



  WorkTable:= FWorkTableManager.ActiveWorkTable;
   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (AWorkTable.NextFreqChangeAt = 0) or (Now >= AWorkTable.NextFreqChangeAt) then
  begin

    if WorkTable=nil then
    exit;

    if WorkTable.ActivePump=nil then
    exit;

      if FlowRate.IsRunning then
      begin
        EnabledEtalonChannels := TObjectList<TChannel>.Create(False);
        try
          for I := 0 to WorkTable.EtalonChannels.Count - 1 do
            if (WorkTable.EtalonChannels[I] <> nil) and (WorkTable.EtalonChannels[I].Enabled) then
              EnabledEtalonChannels.Add(WorkTable.EtalonChannels[I]);

              IF ABS(FlowRate.Value.Value-FlowRate.ValueSet.Value)<1 then
               Flow:=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Valueset.Value,4)
              else IF FlowRate.Value.Value<FlowRate.ValueSet.Value then
                Flow  :=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Value.Value+1,4)
              else if FlowRate.Value.Value>FlowRate.ValueSet.Value then
                Flow:=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Value.Value-1,4);



             ImpSecValues := BuildImpSecValuesForChannels(
              EnabledEtalonChannels,
              Flow,
              //UpdateEtalonImpSecFromFlowRate(Flow, EnabledEtalonChannels)
              NormalizeFloatInput(EditDeviceImpSec.Text)
            );

            FFrameMainTable.ApplyChannelValues(
              EnabledEtalonChannels,
              NormalizeFloatInput('0'),
              ImpSecValues,
              NormalizeFloatInput('0')
            );

        finally
          EnabledEtalonChannels.Free;
        end;
        EnabledDeviceChannels := TObjectList<TChannel>.Create(False);
        try
          for I := 0 to WorkTable.DeviceChannels.Count - 1 do
            begin
            if (WorkTable.DeviceChannels[I] <> nil) and (WorkTable.DeviceChannels[I].Enabled) then
              EnabledDeviceChannels.Add(WorkTable.DeviceChannels[I]);
            end;

              IF ABS(FlowRate.Value.Value-FlowRate.ValueSet.Value)<1 then
               Flow:=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Valueset.Value,4)
              else IF FlowRate.Value.Value<FlowRate.ValueSet.Value then
                Flow  :=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Value.Value+1,4)
              else if FlowRate.Value.Value>FlowRate.ValueSet.Value then
                Flow:=WorkTable.ValueFlowRate.GetDoubleNum(FlowRate.Value.Value-1,4);

          SetLength(ImpSecValues, EnabledDeviceChannels.Count);
           for I := 0 to EnabledDeviceChannels.Count - 1 do
            if i in [1,3,6] then
              ImpSecValues[i] := (Flow*(Random * (trackStd.Value)/10 + 1.00001)*GetChannelFlowCoef(EnabledDeviceChannels[I]))/3.6
            else if i in [2,4,5] then
              ImpSecValues[i] := (Flow*(Random * (trackStd.Value)/10 + 1.00015)*GetChannelFlowCoef(EnabledDeviceChannels[I]))/3.6
            else
              ImpSecValues[i] := (Flow*(Random *  (trackStd.Value)/10 +  1.0008)*GetChannelFlowCoef(EnabledDeviceChannels[I]))/3.6 ;

            FFrameMainTable.ApplyChannelValues(
              EnabledDeviceChannels,
              NormalizeFloatInput('0'),
              ImpSecValues,
              NormalizeFloatInput('0')
            );

        finally
          EnabledDeviceChannels.Free;
        end;

      end;



    AWorkTable.NextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;

procedure TTableMainForm.UpdateRandomSignals(const AWorkTable: TWorkTable);
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
    if Channel.Enabled then
    begin
      Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
      Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
    end
    else
    begin
      Channel.CurSec :=0;
      Channel.ImpSec := 0;
      Channel.ImpResult := 0;
    end;

  end;

  for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random*(trackStd.Value)/10 * 0.06) - 0.03;
    ImpDelta := Random(11)*(trackStd.Value)/10 - 5;
    if Channel.Enabled then
    begin
      Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
      Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, 0.0, 1000000.0);
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
    end
    else
    begin
      Channel.CurSec :=0;
      Channel.ImpSec := 0;
      Channel.ImpResult := 0;
    end;
  end;
end;

procedure TTableMainForm.ExecuteRandomControlAction(const AWorkTable: TWorkTable);
var
  ActionIndex: Integer;
begin
  if AWorkTable = nil then
    Exit;

  ActionIndex :=  Random(11);
  case ActionIndex of
    0:
      if AWorkTable.ActivePump <> nil then
        AWorkTable.ActivePump.DoPumpStart;
    1:
      if AWorkTable.ActivePump <> nil then
        AWorkTable.ActivePump.DoFreqSet(Random(10));
    2:
      if AWorkTable.ActivePump <> nil then
        AWorkTable.ActivePump.DoPumpStop;
    3:
      if AWorkTable.FlowRate <> nil then
        AWorkTable.FlowRate.DoFlowRateStart;
    4:
      if AWorkTable.FlowRate <> nil then
        AWorkTable.FlowRate.DoFlowRateStart(Random(10));
    5:
      if AWorkTable.FlowRate <> nil then
        AWorkTable.FlowRate.DoFlowRateStop;
    6:
      if AWorkTable.FlowRate <> nil then
        AWorkTable.FlowRate.DoFlowRateSet(Random(10));
    7:
      if AWorkTable.FluidTemp <> nil then
        AWorkTable.FluidTemp.DoFluidTempStart(Random(10));
    8:
      if AWorkTable.FluidTemp <> nil then
        AWorkTable.FluidTemp.DoFluidTempStop;
    9:
      if AWorkTable.FluidPress <> nil then
        AWorkTable.FluidPress.DoFluidPressStart(Random(10));
    10:
      if AWorkTable.FluidPress <> nil then
        AWorkTable.FluidPress.DoFluidPressStop;
  end;
end;

procedure TTableMainForm.TimerSetValuesTimer(Sender: TObject);
var
  WorkTable: TWorkTable;   // Текущая рабочая таблица (сессия измерения)
  Pump: tPump;             // Активный насос (исполнитель)
  FlowRate: TFlowRate;     // Управление расходом
  LimitReached: Boolean;   // Флаг: достигнут хотя бы один критерий остановки
  HasLimits: Boolean;      // Флаг: заданы ли критерии остановки
  CurrentImp: Double;      // Текущие импульсы (максимум по эталонным каналам)
  CurrentVolume: Double;   // Текущий измеренный объём/масса
  I: Integer;
begin

  // ============================================================
  // 1. Получение рабочей таблицы
  // ============================================================

  // Если нет ни одной рабочей таблицы — выходим
  if FWorkTableManager.WorkTables.Count = 0 then
    Exit;

  // Берём первую таблицу (по факту — активную)
  // В будущем лучше заменить на FActiveWorkTable
  WorkTable := FWorkTableManager.WorkTables[0];

  // Дополнительная защита от nil
  if WorkTable = nil then
    Exit;

   // ============================================================
  // 2. Эмуляция физического процесса (стенд)
  // ============================================================

  // Обновление частоты насоса (имитация работы)
  UpdateRandomFreq(WorkTable);

  // Обновление текущего расхода  (имитация работы)
  UpdateRandomFlowRate(WorkTable);

  // Обновление климатических параметров (температура и др.)
  UpdateRandomTemp(WorkTable);

  // Обновление давления
  UpdateRandomPress(WorkTable);

  // Рандомный вызов одной из уникальных управляющих функций
  //ExecuteRandomControlAction(WorkTable);


  //UpdateTemp(WorkTable);




  // ============================================================
  // 3. Машина состояний измерения
  // ============================================================

  case WorkTable.State of

    // ------------------------------------------------------------
    // Начальное состояние → переход в режим ожидания
    // ------------------------------------------------------------
    swtNONE:
      WorkTable.State := swtSTANDBY;


    // ------------------------------------------------------------
    // Ожидание → считаем, что система подключена
    // ------------------------------------------------------------
    swtSTANDBY:
      WorkTable.State := swtCONNECTED;


    // ------------------------------------------------------------
    // Запуск мониторинга
    // ------------------------------------------------------------
    swtSTARTMONITOR:
      WorkTable.State := swtSTARTMONITORWAIT;


    // ------------------------------------------------------------
    // Ожидание запуска мониторинга → переход в мониторинг
    // ------------------------------------------------------------
    swtSTARTMONITORWAIT:
      WorkTable.State := swtMONITOR;


    // ------------------------------------------------------------
    // Мониторинг (наблюдение без измерения)
    // ------------------------------------------------------------
    swtMONITOR:
      UpdateRandomSignals(WorkTable); // обновление показаний


    // ------------------------------------------------------------
    // Остановка мониторинга или конфигурация
    // → возвращаемся в подключённое состояние
    // ------------------------------------------------------------
    swtSTOPMONITOR,
    swtCONFIGED:
      WorkTable.State := swtCONNECTED;


    // ------------------------------------------------------------
    // Запуск теста
    // ------------------------------------------------------------
    swtSTARTTEST:
      WorkTable.State := swtSTARTWAIT;


    // ------------------------------------------------------------
    // Ожидание старта → переход к выполнению
    // ------------------------------------------------------------
    swtSTARTWAIT:
      WorkTable.State := swtEXECUTE;


    // ============================================================
    // 4. Основной процесс измерения
    // ============================================================
    swtEXECUTE:
    begin
      // Обновление сигналов (имитация работы датчиков)
      UpdateRandomSignals(WorkTable);


      // ----------------------------------------------------------
      // 4.1 Расчёт текущих импульсов
      // ----------------------------------------------------------

      CurrentImp := 0;

      for I := 0 to WorkTable.EtalonChannels.Count - 1 do
      begin
        // Пропускаем неинициализированные или отключённые каналы
        if (WorkTable.EtalonChannels[I] = nil) or
           (not WorkTable.EtalonChannels[I].Enabled) then
          Continue;

        // Берём максимальное значение импульсов среди эталонов
        // (используется как репрезентативное значение)
        CurrentImp := Max(CurrentImp,
                          WorkTable.EtalonChannels[I].ImpResult);
      end;


      // ----------------------------------------------------------
      // 4.2 Получение текущего объёма/массы
      // ----------------------------------------------------------

      CurrentVolume := 0;

      // ValueQuantity — агрегированное значение измеренного количества
      if WorkTable.ValueQuantity <> nil then
        CurrentVolume := WorkTable.ValueQuantity.GetDoubleValue;


      // ----------------------------------------------------------
      // 4.3 Проверка наличия критериев остановки
      // ----------------------------------------------------------

      HasLimits :=
        (WorkTable.CurrentPoint <> nil) and
        (
          // Ограничение по времени
          ((scTime in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitTime > 0)) or

          // Ограничение по импульсам
          ((scImpulse in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitImp > 0)) or

          // Ограничение по объёму/массе
          ((scVolume in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.CurrentPoint.LimitVolume > 0))
        );


      // ----------------------------------------------------------
      // 4.4 Проверка достижения критериев остановки
      // ----------------------------------------------------------

      LimitReached :=
        (WorkTable.CurrentPoint <> nil) and
        (
          // По времени
          ((scTime in WorkTable.CurrentPoint.StopCriteria) and
           (WorkTable.Time >= WorkTable.CurrentPoint.LimitTime)) or

          // По импульсам
          ((scImpulse in WorkTable.CurrentPoint.StopCriteria) and
           (CurrentImp >= WorkTable.CurrentPoint.LimitImp)) or

          // По объёму/массе
          ((scVolume in WorkTable.CurrentPoint.StopCriteria) and
           (CurrentVolume >= WorkTable.CurrentPoint.LimitVolume))
        );


      // ----------------------------------------------------------
      // 4.5 Завершение измерения
      // ----------------------------------------------------------

      // Если заданы ограничения и хотя бы одно достигнуто
      // → инициируем остановку теста
      if HasLimits and LimitReached then
        WorkTable.State := swtSTOPTEST;
    end;


    // ------------------------------------------------------------
    // Инициация остановки теста
    // ------------------------------------------------------------
    swtSTOPTEST:
      WorkTable.State := swtSTOPWAIT;


    // ------------------------------------------------------------
    // Ожидание полной остановки
    // ------------------------------------------------------------
    swtSTOPWAIT:
      WorkTable.State := swtCOMPLETE;


    // ------------------------------------------------------------
    // Тест завершён → переход к финальному считыванию
    // ------------------------------------------------------------
    swtCOMPLETE:
      WorkTable.State := swtFINALREAD;

  end;


end;






procedure TTableMainForm.TrackStdChange(Sender: TObject);
begin
LabelStd.Text:=FormatFloat('0.00',TrackStd.Value);
end;

end.
