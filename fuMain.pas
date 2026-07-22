unit fuMain;

interface

uses
  frmProceed,
  frmMainTable,
  UnitBaseProcedures,
  UnitWorkTable,
  UnitClasses,
  UnitDataManager,
  System.UITypes,
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls,  System.Generics.Collections, FMX.Forms, FMX.TabControl,
  FMX.Filter.Effects, FMX.StdCtrls, FMX.Colors, FMX.Effects,System.Math,
  FMX.ListBox, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Edit,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.EditBox, FMX.SpinBox, FMXTee.Chart, FMXTee.Engine, UnitParameter, uMeasurementRun, uProtocols;


const
  GraphSampleIntervalMs = 1000;
  MaxGraphSampleCountPerSeries = 3600;

type

  TGraphSample = record
    TimeStampMs: Int64;
    Value: Double;
  end;

  TFlowGraphSeries = class
  public
    Key: string;
    Caption: string;
    Visible: Boolean;
    Samples: TList<TGraphSample>;
    LineColor: TAlphaColor;
    constructor Create;
    destructor Destroy; override;
  end;

  TFlowGraphHistory = class
  private
    FSeries: TObjectDictionary<string, TFlowGraphSeries>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function EnsureSeries(const AKey, ACaption: string; const AColor: TAlphaColor): TFlowGraphSeries;
    procedure RemoveMissing(const AValidKeys: TStrings);
    property Series: TObjectDictionary<string, TFlowGraphSeries> read FSeries;
  end;
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
    CheckBoxDeviceReady: TCheckBox;
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
    procedure  PumpStateHandler(AParameters: TParameter; AAction:EActionParameter);
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

    procedure UpdateTemp(const AWorkTable: TWorkTable);


    procedure UpdateRandomTemp(const AWorkTable: TWorkTable);
    procedure UpdateRandomSignals(const AWorkTable: TWorkTable);
    procedure UpdateRandomFreq(const APump: TPump);
    procedure UpdateRandomFlowRate(const AFlowRate: TFlowRate);
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
    procedure CreateGraphsTab;
    procedure RefreshFlowGraphChannels;
    procedure AddFlowGraphSamples(const ATimeStampMs: Int64);
    procedure UpdateFlowGraphCharts(const ATimeStampMs: Int64);
    procedure ClearFlowGraphsClick(Sender: TObject);
    procedure FlowGraphCheckChanged(Sender: TObject);
    function IsFlowGraphSamplingActive(const AWorkTable: TWorkTable): Boolean;
    function BuildFlowGraphKey(const APrefix: string; const AChannel: TChannel; const AIndex: Integer): string;
    function BuildFlowGraphCaption(const APrefix: string; const AChannel: TChannel; const AIndex: Integer): string;
    function NextGraphColor(const AKey: string): TAlphaColor;
    procedure FillFlowGraphSelection(const AHistory: TFlowGraphHistory; const AParent: TFlowLayout);
    procedure RenderFlowChart(const AChart: TSimpleChart; const AHistory: TFlowGraphHistory;
      const ABaseTimeMs: Int64; const AWindowSec: Double; const ATitle: string);
    procedure SyncFlowGraphWorkTable;

    FTabItemGraphs: TTabItem;
    FChartEtalonFlow: TSimpleChart;
    FChartDeviceFlow: TSimpleChart;
    FEtalonGraphChecks: TFlowLayout;
    FDeviceGraphChecks: TFlowLayout;
    FEtalonFlowHistory: TFlowGraphHistory;
    FDeviceFlowHistory: TFlowGraphHistory;
    FLastFlowGraphSampleMs: UInt64;
    FFlowGraphWorkTable: TWorkTable;

  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}


constructor TFlowGraphSeries.Create;
begin
  inherited Create;
  Visible := True;
  Samples := TList<TGraphSample>.Create;
end;

destructor TFlowGraphSeries.Destroy;
begin
  Samples.Free;
  inherited;
end;

constructor TFlowGraphHistory.Create;
begin
  inherited Create;
  FSeries := TObjectDictionary<string, TFlowGraphSeries>.Create([doOwnsValues]);
end;

destructor TFlowGraphHistory.Destroy;
begin
  FSeries.Free;
  inherited;
end;

procedure TFlowGraphHistory.Clear;
begin
  FSeries.Clear;
end;

function TFlowGraphHistory.EnsureSeries(const AKey, ACaption: string;
  const AColor: TAlphaColor): TFlowGraphSeries;
begin
  if not FSeries.TryGetValue(AKey, Result) then
  begin
    Result := TFlowGraphSeries.Create;
    Result.Key := AKey;
    Result.LineColor := AColor;
    FSeries.Add(AKey, Result);
  end;
  Result.Caption := ACaption;
end;

procedure TFlowGraphHistory.RemoveMissing(const AValidKeys: TStrings);
var
  Key: string;
  Keys: TArray<string>;
begin
  Keys := FSeries.Keys.ToArray;
  for Key in Keys do
    if AValidKeys.IndexOf(Key) < 0 then
      FSeries.Remove(Key);
end;

function PressureRandomAroundBase(const ABaseValue: Double;
  const ARelativeDeviation: Double): Double;
var
  RandomUnit: Double;
  MinValue: Double;
  MaxValue: Double;
begin
  if ABaseValue = 0 then
    Exit(0);

  RandomUnit := Random;
  Result := ABaseValue *
    (1 - ARelativeDeviation + RandomUnit * 2 * ARelativeDeviation);

  MinValue := Min(ABaseValue * (1 - ARelativeDeviation),
    ABaseValue * (1 + ARelativeDeviation));
  MaxValue := Max(ABaseValue * (1 - ARelativeDeviation),
    ABaseValue * (1 + ARelativeDeviation));
  Result := EnsureRange(Result, MinValue, MaxValue);
end;

procedure EnsureEnvironmentSimulationBase(const AWorkTable: TWorkTable);
begin
  if (AWorkTable <> nil) and
     (not AWorkTable.EnvironmentSimulationBaseInitialized) then
    AWorkTable.CaptureEnvironmentSimulationBase;
end;

procedure TFormMain.ButtonApplyDeviceValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
  FlowRate: Double;
  ImpSecValues: TArray<Double>;
begin
  if WorkTable = nil then
    Exit;

  UpdateDeviceImpSecFromFlowRate;
  WorkTable.DeviceReady := CheckBoxDeviceReady.IsChecked;
  WorkTable.EtalonFlowSet := NormalizeFloatInput(EditEtalonFlowRate.Text) / 3.6;
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

procedure TFormMain.ButtonApplyEtalonValuesClick(Sender: TObject);
var
  WorkTable: TWorkTable;
  FlowRate: Double;
  ImpSecValues: TArray<Double>;
begin
  if WorkTable = nil then
    Exit;

  UpdateEtalonImpSecFromFlowRate;
  WorkTable.EtalonFlowSet := NormalizeFloatInput(EditEtalonFlowRate.Text) / 3.6;
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

procedure TFormMain.EditTestNumExit(Sender: TObject);
begin
 LabelTestNum.Text := FWorkTableManager.ActiveWorkTable.DeviceChannels[0].FlowMeter.ValueError.GetStrNum(EditTestNum.Text)
end;



procedure  TFormMain.PumpStateHandler(AParameters: TParameter; AAction:EActionParameter);
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







procedure  TFormMain.FlowRateStateHandler(AParameters: TParameter; AAction:EActionParameter);
var
FlowRate: Double;
WorkTable:TWorkTable;
i:integer;
EnabledEtalonChannels: TObjectList<TChannel>;
AValue:Double;

begin
  WorkTable:= FWorkTableManager.ActiveWorkTable;
  FormMain.mPump.Lines.Add('Расход воды: ' + floattostr(WorkTable.FlowRate.ValueSet.value)+ ' - Состояние: ' + WorkTable.FlowRate.GetActionAsString );
  if WorkTable.FlowRate.ValueSet.value>=WorkTable.FlowRate.Value.value then
    WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value+random(5))
  else
    WorkTable.ActivePump.DoFreqSet(WorkTable.ActivePump.ValueSet.value-random(5));
  WorkTable.ActivePump.DoPumpStart;

end;

procedure  TFormMain.FlowFluidTempHandler(AParameters: TParameter; AAction:EActionParameter);
begin

  FormMain.mPump.Lines.Add('Изменилась заданная температура: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidTemp.ValueSet.value) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidTemp.GetActionAsString);

end;

procedure  TFormMain.FlowFluidPressHandler(AParameters: TParameter; AAction:EActionParameter);
begin

  FormMain.mPump.Lines.Add('Изменилась заданное давление: '  + floattostr(FWorkTableManager.ActiveWorkTable.FluidPress.ValueSet.value) + ' Состояние: ' + FWorkTableManager.ActiveWorkTable.FluidPress.GetActionAsString);

end;



procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.WindowState := TWindowState.wsMinimized;

  if FFrameMainTable <> nil then
    FFrameMainTable.SaveLayoutSettingsToWorkTable;

  if FFrameProceed <> nil then
    FFrameProceed.SavePendingProcessingChanges(Self);

  DataManager.Save;

  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  FreeAndNil(FEtalonFlowHistory);
  FreeAndNil(FDeviceFlowHistory);
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



    for i := 0 to TPump.Pumps.Count-1 do
    begin

    end;

  end;


  CreateGraphsTab;

  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := TabItemTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.WorkTableManager := FWorkTableManager ;
  FFrameMainTable.Initialize;



  FFrameProceed := TFrameProceed.Create(Self);
  FFrameProceed.Parent := TabItemResults;
  FFrameProceed.Align := TAlignLayout.Client;
  FFrameProceed.Initialize(FWorkTableManager);
  RefreshFlowGraphChannels;

end;

procedure TFormMain.TabControlMainChange(Sender: TObject);
begin
  if (TabControlMain.ActiveTab = TabItemResults) and (FFrameProceed <> nil) then
    FFrameProceed.RefreshResultsTab;
  if (TabControlMain.ActiveTab = FTabItemGraphs) then
    RefreshFlowGraphChannels;
end;

procedure TFormMain.UpdateTemp(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double; // Случайные приращения температуры и давления
  StableStatus: RStableInfo;     // Информация о стабильности параметра
begin
  // Если рабочая таблица не задана — выходим
  if AWorkTable = nil then
    Exit;


   //Температура до стола
   AWorkTable.FluidTemp.BeforeValue :=  20 ;

   //Температура после стола
   AWorkTable.FluidTemp.AfterValue :=  20;




    // Если система регулирования запущена
    if (AWorkTable.FluidTemp.IsRunning) then
    begin

      // Если температура ещё НЕ стабилизировалась
      if not AWorkTable.FluidTemp.IsStable(StableStatus) then
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








procedure TFormMain.UpdateRandomTemp(const AWorkTable: TWorkTable);
var
  TempDelta, PressDelta: Double; // Случайные приращения температуры и давления
  StableStatus: RStableInfo;     // Информация о стабильности параметра
begin
  // ============================================================
  // 1. Проверка входных данных
  // ============================================================

  // Если рабочая таблица не задана — выходим
  if AWorkTable = nil then
    Exit;

  // ============================================================
  // 2. Обработка управляющих команд температуры
  // ============================================================

  // В зависимости от текущего действия (Action)
  // обновляем статус параметра температуры

  if (AWorkTable.FluidTemp.Action = apStart) or
     (AWorkTable.FluidTemp.Action = apSet) then

    // Начато регулирование/установка температуры
    AWorkTable.FluidTemp.State := spStarted

  else if (AWorkTable.FluidTemp.Action = apStop) then

    // Остановка регулирования
    AWorkTable.FluidTemp.State := spStopped;


  // ============================================================
  // 3. Ограничение частоты обновления (не каждый тик таймера)
  // ============================================================

  // Обновляем температуру не постоянно, а раз в несколько секунд
  if (FNextClimateChangeAt = 0) or (Now >= FNextClimateChangeAt) then
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
      if not AWorkTable.FluidTemp.IsStable(StableStatus) then
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
    FNextClimateChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
  end;
end;




procedure TFormMain.UpdateRandomPress(const AWorkTable: TWorkTable);
const
  RelativeDeviation = 0.05;
begin
  if (AWorkTable = nil) or (AWorkTable.FluidPress = nil) then
    Exit;

  if (FNextPressChangeAt = 0) or (Now >= FNextPressChangeAt) then
  begin
    EnsureEnvironmentSimulationBase(AWorkTable);

    AWorkTable.FluidPress.BeforeValue :=
      PressureRandomAroundBase(AWorkTable.SimulationBasePressBefore, RelativeDeviation);
    AWorkTable.FluidPress.AfterValue :=
      PressureRandomAroundBase(AWorkTable.SimulationBasePressAfter, RelativeDeviation);

    FNextPressChangeAt := Now + EncodeTime(0, 0, 3 + Random(2), 0);
  end;
end;

procedure TFormMain.UpdateRandomFreq(const APump: TPump);
var
  Freq: Double;
begin



  if APump = nil then
    Exit;

  IF (APump.Action = apStart)  THEN
    APump.State:=spStarted
  else  if (APump.Action = apStop) then
    APump.State:=spStopped;




   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin
    Freq := (Random * 10);

   if APump.IsRunning = true then
    begin

      APump.Value.value:=(EnsureRange(APump.Value.value + Freq,APump.Value.value , APump.ValueSet.value));


    end
    else
    begin
      //APump.ValueSet:=(APump.ValueSet);
      APump.Value.value:=0;
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
  if (WorkTable = nil) or (WorkTable.DeviceChannels.Count = 0) then
    Exit;

  FlowRate := NormalizeFloatInput(EditDeviceFlowRate.Text);
  Coef := GetChannelFlowCoef(WorkTable.DeviceChannels[0]);
  if Coef <= 0 then
    Exit;

  ImpSec := (FlowRate * Coef) / 3.6;
  EditDeviceImpSec.Text := FloatToStr(ImpSec);
end;

function TFormMain.UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0;
  AEtalonChannels: TObjectList<TChannel> = nil):Double;
var
  WorkTable: TWorkTable;
  FlowRate, Coef, ImpSec: Double;
  i:integer;
begin
  WorkTable := FWorkTableManager.ActiveWorkTable;
  if (WorkTable = nil) or (WorkTable.EtalonChannels.Count = 0) then
    Exit;




  if (AEtalonChannels <> nil) and (AEtalonChannels.Count > 0) then
    for I := 0 to AEtalonChannels.Count - 1 do
      Coef :=Coef+ GetChannelFlowCoef(AEtalonChannels[i])
  else if AEtalonChannels=nil then
      Coef := GetChannelFlowCoef(WorkTable.EtalonChannels[0]);

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

function TFormMain.BuildImpSecValuesForChannels(AChannels: TObjectList<TChannel>;
  const AFlowRate, AFallbackImpSec: Double): TArray<Double>;
var
  I, J, GroupKey: Integer;
  Coef, SUM, MaxRatio, ChannelQmax: Double;
  WorkTable: TWorkTable;
begin
  SetLength(Result, 0);
  if AChannels = nil then
    Exit;

  WorkTable := FWorkTableManager.ActiveWorkTable;
  SetLength(Result, AChannels.Count);
  for I := 0 to AChannels.Count - 1 do
  begin
    MaxRatio := 1;
    if (WorkTable <> nil) and (AChannels = WorkTable.EtalonChannels) and
       (AChannels[I] <> nil) and (AChannels[I].FlowMeter <> nil) and
       (AChannels[I].FlowMeter.Device <> nil) then
    begin
      GroupKey := AChannels[I].Group;
      SUM := 0;
      for J := 0 to AChannels.Count - 1 do
        if (AChannels[J] <> nil) and AChannels[J].Enabled and
           (((GroupKey > 0) and (AChannels[J].Group = GroupKey)) or
            ((GroupKey <= 0) and (J = I))) and
           (AChannels[J].FlowMeter <> nil) and (AChannels[J].FlowMeter.Device <> nil) then
          SUM := SUM + WorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[J].FlowMeter.Device.Qmax, 4);

      ChannelQmax := WorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[I].FlowMeter.Device.Qmax, 4);
      if SUM > 0 then
        MaxRatio := ChannelQmax / SUM
      else
        MaxRatio := 0;
    end;

    Coef := GetChannelFlowCoef(AChannels[I]);
    if (AChannels[I] <> nil) and (not AChannels[I].Enabled) then
      Result[I] := 0
    else if Coef > 0 then
      Result[I] := (AFlowRate * MaxRatio * Coef) / 3.6
    else
      Result[I] := AFallbackImpSec;
  end;
end;


procedure TFormMain.UpdateRandomFlowRate(const AFlowRate: TFlowRate);
var
  Flow: Double;
  FlowRate: Double;
  WorkTable:TWorkTable;
  i:integer;
  EnabledEtalonChannels: TObjectList<TChannel>;
  AValue:Double;
  ImpSecValues: TArray<Double>;
begin
  if AFlowRate = nil then
    Exit;


  IF AFlowRate.Action = apStart THEN
    AFlowRate.State:=spStarted
  else  if (AFlowRate.Action = apStop) then
    AFlowRate.State:=spStopped;

  WorkTable:= FWorkTableManager.ActiveWorkTable;
   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextFreqChangeAt = 0) or (Now >= FNextFreqChangeAt) then
  begin

    if WorkTable=nil then
    exit;

    if WorkTable.ActivePump=nil then
    exit;

   if WorkTable.ActivePump.IsRunning=false then
    exit;
      if AFlowRate.IsRunning then
      begin
        EnabledEtalonChannels := TObjectList<TChannel>.Create(False);
        try
          for I := 0 to WorkTable.EtalonChannels.Count - 1 do
            if WorkTable.EtalonChannels[I] <> nil then
              EnabledEtalonChannels.Add(WorkTable.EtalonChannels[I]);

              IF ABS(AFlowRate.Value.Value-AFlowRate.ValueSet.Value)<1 then
               FlowRate:=WorkTable.ValueFlowRate.GetDoubleNum(AFlowRate.Valueset.Value,4)
              else IF AFlowRate.Value.Value<AFlowRate.ValueSet.Value then
                FlowRate:=WorkTable.ValueFlowRate.GetDoubleNum(AFlowRate.Value.Value+1,4)
              else if AFlowRate.Value.Value>AFlowRate.ValueSet.Value then
                FlowRate:=WorkTable.ValueFlowRate.GetDoubleNum(AFlowRate.Value.Value-1,4);

             ImpSecValues := BuildImpSecValuesForChannels(
              EnabledEtalonChannels,
              FlowRate,
              UpdateEtalonImpSecFromFlowRate(FlowRate, EnabledEtalonChannels)
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

      end;



    FNextFreqChangeAt := Now + EncodeTime(0, 0, Random(1), 0);
   end;
end;



procedure TFormMain.UpdateRandomSignals(const AWorkTable: TWorkTable);
var
  I, J: Integer;
  Channel: TChannel;
  CurDelta: Double;
  ImpDelta: Double;
  MaxImpDelta: Double;
  MinImpSec: Double;
  MaxImpSec: Double;
  EtalonFlowSet: Double;
  EtalonFlowActual: Double;
  ChannelCoef: Double;
  TargetImpSec: Double;
  CurrentFlow: Double;
  DeviceReady: Boolean;
  GroupChannelCount: Integer;
  DeviceFlow: Double;
  ActiveEtalonIndex: Integer;
  GroupFlowMax: Double;
  ChannelFlowMax: Double;

  function GetEnabledGroupFlowMax(AChannels: TObjectList<TChannel>; const AGroup, AChannelIndex: Integer): Double;
  var
    K: Integer;
  begin
    Result := 0;
    if AChannels = nil then
      Exit;

    for K := 0 to AChannels.Count - 1 do
      if (AChannels[K] <> nil) and AChannels[K].Enabled and
         (((AGroup > 0) and (AChannels[K].Group = AGroup)) or
          ((AGroup <= 0) and (K = AChannelIndex))) and
         (AChannels[K].FlowMeter <> nil) and (AChannels[K].FlowMeter.Device <> nil) then
        Result := Result + AWorkTable.ValueFlowRate.GetDoubleBaseNum(AChannels[K].FlowMeter.Device.Qmax, 4);
  end;
begin
  if AWorkTable = nil then
    Exit;

  DeviceReady := CheckBoxDeviceReady.IsChecked;
  AWorkTable.DeviceReady := DeviceReady;
  EtalonFlowSet := NormalizeFloatInput(EditEtalonFlowRate.Text) / 3.6;
  if (AWorkTable.FlowRate <> nil) and (AWorkTable.FlowRate.ValueSet <> nil) and
     (AWorkTable.FlowRate.ValueSet.Value > 0) then
    EtalonFlowSet := AWorkTable.FlowRate.ValueSet.Value;
  AWorkTable.EtalonFlowSet := EtalonFlowSet;
  if EtalonFlowSet <= 0 then
    for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
      if (AWorkTable.EtalonChannels[I] <> nil) and
         AWorkTable.EtalonChannels[I].Enabled then
      begin
        ChannelCoef := GetChannelFlowCoef(AWorkTable.EtalonChannels[I]);
        if ChannelCoef > 0 then
          EtalonFlowSet := AWorkTable.EtalonChannels[I].ImpSec / ChannelCoef;
        Break;
      end;

    AWorkTable.Time := AWorkTable.Time + 1;

  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
  begin
    Channel := AWorkTable.EtalonChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.06) - 0.03;
    if Channel.Enabled then
    begin
      Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);
      ChannelCoef := GetChannelFlowCoef(Channel);
      if Channel.ImpSec > 0 then
      begin
        MaxImpDelta := EnsureRange(Abs(Channel.ImpSec) * 0.003, 0.1, 10.0);
        ImpDelta := (Random * 2.0 - 1.0) * MaxImpDelta;
        MinImpSec := Max(0.0, Channel.ImpSec * 0.99);
        MaxImpSec := Channel.ImpSec * 1.01;
        Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, MinImpSec, MaxImpSec);
      end;
      Channel.ImpResult := EnsureRange(Channel.ImpResult + Channel.ImpSec, 0.0, 1.0E12);
    end
    else
    begin
      Channel.CurSec :=0;
      Channel.ImpSec := 0;
      Channel.ImpResult := 0;
    end;

  end;

  EtalonFlowActual := 0;
  GroupKey := 0;
  ActiveEtalonIndex := -1;
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if (AWorkTable.EtalonChannels[I] <> nil) and AWorkTable.EtalonChannels[I].Enabled then
    begin
      GroupKey := AWorkTable.EtalonChannels[I].Group;
      ActiveEtalonIndex := I;
      Break;
    end;
  for I := 0 to AWorkTable.EtalonChannels.Count - 1 do
    if (AWorkTable.EtalonChannels[I] <> nil) and AWorkTable.EtalonChannels[I].Enabled and
       (((GroupKey > 0) and (AWorkTable.EtalonChannels[I].Group = GroupKey)) or
        ((GroupKey <= 0) and (I = ActiveEtalonIndex))) then
    begin
      ChannelCoef := GetChannelFlowCoef(AWorkTable.EtalonChannels[I]);
      if ChannelCoef > 0 then
        EtalonFlowActual := EtalonFlowActual + AWorkTable.EtalonChannels[I].ImpSec / ChannelCoef;
    end;
  if EtalonFlowActual <= 0 then
    EtalonFlowActual := EtalonFlowSet;


  for I := 0 to AWorkTable.DeviceChannels.Count - 1 do
  begin
    Channel := AWorkTable.DeviceChannels[I];
    if Channel = nil then
      Continue;

    CurDelta := (Random * 0.6) - 0.3;
    if Channel.Enabled then
    begin
      Channel.CurSec := EnsureRange(Channel.CurSec + CurDelta, 0.0, 1000.0);

      if DeviceReady and (Channel.ImpSec > 0) then
      begin
        MaxImpDelta := EnsureRange(Abs(Channel.ImpSec) * 0.003, 0.1, 10.0);
        ImpDelta := (Random * 2.0 - 1.0) * MaxImpDelta;
        MinImpSec := Max(0.0, Channel.ImpSec * 0.99);
        MaxImpSec := Channel.ImpSec * 1.01;
        Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, MinImpSec, MaxImpSec);
      end
      else if not DeviceReady then
      begin
        ChannelCoef := GetChannelFlowCoef(Channel);
        GroupChannelCount := 0;
        for J := 0 to AWorkTable.DeviceChannels.Count - 1 do
          if (AWorkTable.DeviceChannels[J] <> nil) and AWorkTable.DeviceChannels[J].Enabled and
             (((Channel.Group > 0) and (AWorkTable.DeviceChannels[J].Group = Channel.Group)) or
              ((Channel.Group <= 0) and (J = I))) then
            Inc(GroupChannelCount);
        GroupFlowMax := GetEnabledGroupFlowMax(AWorkTable.DeviceChannels, Channel.Group, I);
        if (Channel.FlowMeter <> nil) and (Channel.FlowMeter.Device <> nil) then
          ChannelFlowMax := AWorkTable.ValueFlowRate.GetDoubleBaseNum(Channel.FlowMeter.Device.Qmax, 4)
        else
          ChannelFlowMax := 0;
        if (GroupFlowMax > 0) and (ChannelFlowMax > 0) then
          DeviceFlow := EtalonFlowActual * ChannelFlowMax / GroupFlowMax
        else
          DeviceFlow := 0;
        if ProtocolManager <> nil then
          ProtocolManager.AddMessage(pcState, psWorkTable, 'DeviceFlowSimulation',
            'Device flow distribution',
            Format('Device=%d Group=%d EnabledCount=%d LineFlow=%.3f DeviceFlow=%.3f',
              [I, Channel.Group, GroupChannelCount, EtalonFlowSet, DeviceFlow]));
        TargetImpSec := DeviceFlow * ChannelCoef;
        if TargetImpSec > 0 then
        begin
          MaxImpDelta := EnsureRange(Abs(Max(Channel.ImpSec, TargetImpSec)) * 0.003, 0.1, 10.0);
          if Abs(Channel.ImpSec - TargetImpSec) > MaxImpDelta then
          begin
            ImpDelta := EnsureRange(TargetImpSec - Channel.ImpSec, -MaxImpDelta, MaxImpDelta);
            MinImpSec := 0.0;
            MaxImpSec := Max(Channel.ImpSec, TargetImpSec);
          end
          else
          begin
            MaxImpDelta := EnsureRange(Abs(TargetImpSec) * 0.01, 0.1, 30.0);
            ImpDelta := (Random * 2.0 - 1.0) * MaxImpDelta;
            MinImpSec := Max(0.0, TargetImpSec * 0.99);
            MaxImpSec := TargetImpSec * 1.01;
          end;
          Channel.ImpSec := EnsureRange(Channel.ImpSec + ImpDelta, MinImpSec, MaxImpSec);
        end;
      end;

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


procedure TFormMain.CreateGraphsTab;
var
  Root, EtalonSection, DeviceSection, Selection, ChartLayout: TLayout;
  Splitter: TSplitter;
  LabelSelection: TLabel;
  Scroll: THorzScrollBox;
  ButtonClear: TButton;
begin
  FEtalonFlowHistory := TFlowGraphHistory.Create;
  FDeviceFlowHistory := TFlowGraphHistory.Create;

  FTabItemGraphs := TTabItem.Create(TabControlMain);
  FTabItemGraphs.Text := 'Графики';
  FTabItemGraphs.Name := 'TabItemGraphs';
  TabControlMain.InsertObject(1, FTabItemGraphs);

  Root := TLayout.Create(FTabItemGraphs);
  Root.Parent := FTabItemGraphs;
  Root.Align := TAlignLayout.Client;
  Root.Padding.Rect := TRectF.Create(8, 8, 8, 8);

  EtalonSection := TLayout.Create(Root);
  EtalonSection.Parent := Root;
  EtalonSection.Name := 'LayoutEtalonGraphSection';
  EtalonSection.Align := TAlignLayout.Top;
  EtalonSection.Height := 340;

  Selection := TLayout.Create(EtalonSection);
  Selection.Parent := EtalonSection;
  Selection.Name := 'LayoutEtalonGraphSelection';
  Selection.Align := TAlignLayout.Bottom;
  Selection.Height := 48;

  LabelSelection := TLabel.Create(Selection);
  LabelSelection.Parent := Selection;
  LabelSelection.Name := 'LabelEtalonGraphSelection';
  LabelSelection.Align := TAlignLayout.Left;
  LabelSelection.Width := 70;
  LabelSelection.Text := 'Эталоны';

  ButtonClear := TButton.Create(Selection);
  ButtonClear.Parent := Selection;
  ButtonClear.Align := TAlignLayout.Right;
  ButtonClear.Width := 130;
  ButtonClear.Text := 'Очистить графики';
  ButtonClear.OnClick := ClearFlowGraphsClick;

  Scroll := THorzScrollBox.Create(Selection);
  Scroll.Parent := Selection;
  Scroll.Name := 'HorzScrollBoxEtalonGraphSelection';
  Scroll.Align := TAlignLayout.Client;
  FEtalonGraphChecks := TFlowLayout.Create(Scroll);
  FEtalonGraphChecks.Parent := Scroll;
  FEtalonGraphChecks.Name := 'FlowLayoutEtalonGraphChecks';
  FEtalonGraphChecks.Align := TAlignLayout.Left;
  FEtalonGraphChecks.Width := 1000;
  FEtalonGraphChecks.Height := 40;

  ChartLayout := TLayout.Create(EtalonSection);
  ChartLayout.Parent := EtalonSection;
  ChartLayout.Name := 'LayoutEtalonChart';
  ChartLayout.Align := TAlignLayout.Client;
  FChartEtalonFlow := TSimpleChart.Create(ChartLayout);
  FChartEtalonFlow.Parent := ChartLayout;
  FChartEtalonFlow.Name := 'PaintBoxEtalonFlowChart';
  FChartEtalonFlow.Align := TAlignLayout.Client;
  FChartEtalonFlow.Title := 'Расход эталонов';
  FChartEtalonFlow.XTitle := 'Время';
  FChartEtalonFlow.YTitle := 'Расход';

  Splitter := TSplitter.Create(Root);
  Splitter.Parent := Root;
  Splitter.Name := 'SplitterFlowGraphs';
  Splitter.Align := TAlignLayout.Top;
  Splitter.Height := 6;
  Splitter.Cursor := crVSplit;

  DeviceSection := TLayout.Create(Root);
  DeviceSection.Parent := Root;
  DeviceSection.Name := 'LayoutDeviceGraphSection';
  DeviceSection.Align := TAlignLayout.Client;

  Selection := TLayout.Create(DeviceSection);
  Selection.Parent := DeviceSection;
  Selection.Name := 'LayoutDeviceGraphSelection';
  Selection.Align := TAlignLayout.Bottom;
  Selection.Height := 48;

  LabelSelection := TLabel.Create(Selection);
  LabelSelection.Parent := Selection;
  LabelSelection.Name := 'LabelDeviceGraphSelection';
  LabelSelection.Align := TAlignLayout.Left;
  LabelSelection.Width := 70;
  LabelSelection.Text := 'Приборы';

  Scroll := THorzScrollBox.Create(Selection);
  Scroll.Parent := Selection;
  Scroll.Name := 'HorzScrollBoxDeviceGraphSelection';
  Scroll.Align := TAlignLayout.Client;
  FDeviceGraphChecks := TFlowLayout.Create(Scroll);
  FDeviceGraphChecks.Parent := Scroll;
  FDeviceGraphChecks.Name := 'FlowLayoutDeviceGraphChecks';
  FDeviceGraphChecks.Align := TAlignLayout.Left;
  FDeviceGraphChecks.Width := 1000;
  FDeviceGraphChecks.Height := 40;

  ChartLayout := TLayout.Create(DeviceSection);
  ChartLayout.Parent := DeviceSection;
  ChartLayout.Name := 'LayoutDeviceChart';
  ChartLayout.Align := TAlignLayout.Client;
  FChartDeviceFlow := TSimpleChart.Create(ChartLayout);
  FChartDeviceFlow.Parent := ChartLayout;
  FChartDeviceFlow.Name := 'PaintBoxDeviceFlowChart';
  FChartDeviceFlow.Align := TAlignLayout.Client;
  FChartDeviceFlow.Title := 'Расход приборов';
  FChartDeviceFlow.XTitle := 'Время';
  FChartDeviceFlow.YTitle := 'Расход';
end;

function TFormMain.NextGraphColor(const AKey: string): TAlphaColor;
const
  Colors: array[0..9] of TAlphaColor = (claBlue, claRed, claGreen, claOrange, claPurple,
    claTeal, claBrown, claMagenta, claDarkcyan, claCrimson);
var
  I, Hash: Integer;
begin
  Hash := 0;
  for I := 1 to Length(AKey) do
    Hash := Hash + Ord(AKey[I]) * I;
  Result := Colors[Abs(Hash) mod Length(Colors)];
end;

function TFormMain.BuildFlowGraphKey(const APrefix: string; const AChannel: TChannel;
  const AIndex: Integer): string;
var
  Id: string;
begin
  Id := '';
  if AChannel <> nil then
  begin
    Id := Trim(AChannel.DeviceUUID);
    if (Id = '') and (AChannel.FlowMeter <> nil) then
      Id := Trim(AChannel.FlowMeter.UUID);
  end;
  if Id = '' then
    Id := IntToStr(AIndex);
  Result := APrefix + ':' + Id + ':' + IntToStr(AIndex);
end;

function TFormMain.BuildFlowGraphCaption(const APrefix: string; const AChannel: TChannel;
  const AIndex: Integer): string;
var
  Device: TDevice;
  Parts: string;
begin
  Device := nil;
  if (AChannel <> nil) and (AChannel.FlowMeter <> nil) then
    Device := AChannel.FlowMeter.Device;
  if Device <> nil then
  begin
    Parts := Trim(Device.Name);
    if Parts = '' then
      Parts := Trim(Device.DeviceTypeName);
    if Trim(Device.DN) <> '' then
      Parts := Trim(Parts + ' DN' + Device.DN);
    if Trim(Device.SerialNumber) <> '' then
      Parts := Trim(Parts + ' — №' + Device.SerialNumber);
    Result := Parts;
  end
  else
    Result := '';
  if Result = '' then
  begin
    if SameText(APrefix, 'Etalon') then
      Result := 'Эталонный канал ' + IntToStr(AIndex + 1)
    else
      Result := 'Приборный канал ' + IntToStr(AIndex + 1);
  end;
end;

procedure TFormMain.FillFlowGraphSelection(const AHistory: TFlowGraphHistory; const AParent: TFlowLayout);
var
  Pair: TPair<string, TFlowGraphSeries>;
  Check: TCheckBox;
begin
  AParent.DeleteChildren;
  AParent.Width := Max(1000, AHistory.Series.Count * 260);
  for Pair in AHistory.Series do
  begin
    Check := TCheckBox.Create(AParent);
    Check.Parent := AParent;
    Check.Width := 250;
    Check.Height := 36;
    Check.Text := Pair.Value.Caption;
    Check.IsChecked := Pair.Value.Visible;
    Check.TagString := Pair.Key;
    Check.OnChange := FlowGraphCheckChanged;
    Check.TextSettings.FontColor := Pair.Value.LineColor;
  end;
end;

procedure TFormMain.RefreshFlowGraphChannels;
var
  WorkTable: TWorkTable;
  I: Integer;
  Channel: TChannel;
  Key: string;
  ValidEtalons, ValidDevices: TStringList;
begin
  WorkTable := nil;
  if FWorkTableManager <> nil then
    WorkTable := FWorkTableManager.ActiveWorkTable;
  if WorkTable <> FFlowGraphWorkTable then
  begin
    FFlowGraphWorkTable := WorkTable;
    if FEtalonFlowHistory <> nil then FEtalonFlowHistory.Clear;
    if FDeviceFlowHistory <> nil then FDeviceFlowHistory.Clear;
    FLastFlowGraphSampleMs := 0;
  end;
  ValidEtalons := TStringList.Create;
  ValidDevices := TStringList.Create;
  try
    if (WorkTable <> nil) and (WorkTable.EtalonChannels <> nil) then
      for I := 0 to WorkTable.EtalonChannels.Count - 1 do
      begin
        Channel := WorkTable.EtalonChannels[I];
        if (Channel = nil) or (Channel.FlowMeter = nil) or (Channel.FlowMeter.ValueFlow = nil) or (Channel.State = osDeleted) then Continue;
        Key := BuildFlowGraphKey('Etalon', Channel, I);
        ValidEtalons.Add(Key);
        if not FEtalonFlowHistory.Series.ContainsKey(Key) then
          FEtalonFlowHistory.EnsureSeries(Key, BuildFlowGraphCaption('Etalon', Channel, I), NextGraphColor(Key)).Visible := Channel.Enabled
        else
          FEtalonFlowHistory.EnsureSeries(Key, BuildFlowGraphCaption('Etalon', Channel, I), NextGraphColor(Key));
      end;
    if (WorkTable <> nil) and (WorkTable.DeviceChannels <> nil) then
      for I := 0 to WorkTable.DeviceChannels.Count - 1 do
      begin
        Channel := WorkTable.DeviceChannels[I];
        if (Channel = nil) or (Channel.FlowMeter = nil) or (Channel.FlowMeter.ValueFlow = nil) or (Channel.State = osDeleted) then Continue;
        Key := BuildFlowGraphKey('Device', Channel, I);
        ValidDevices.Add(Key);
        if not FDeviceFlowHistory.Series.ContainsKey(Key) then
          FDeviceFlowHistory.EnsureSeries(Key, BuildFlowGraphCaption('Device', Channel, I), NextGraphColor(Key)).Visible := Channel.Enabled
        else
          FDeviceFlowHistory.EnsureSeries(Key, BuildFlowGraphCaption('Device', Channel, I), NextGraphColor(Key));
      end;
    FEtalonFlowHistory.RemoveMissing(ValidEtalons);
    FDeviceFlowHistory.RemoveMissing(ValidDevices);
  finally
    ValidEtalons.Free;
    ValidDevices.Free;
  end;
  FillFlowGraphSelection(FEtalonFlowHistory, FEtalonGraphChecks);
  FillFlowGraphSelection(FDeviceFlowHistory, FDeviceGraphChecks);
  UpdateFlowGraphCharts(0);
end;

procedure TFormMain.FlowGraphCheckChanged(Sender: TObject);
var
  Check: TCheckBox;
  Series: TFlowGraphSeries;
begin
  Check := Sender as TCheckBox;
  if FEtalonFlowHistory.Series.TryGetValue(Check.TagString, Series) or
     FDeviceFlowHistory.Series.TryGetValue(Check.TagString, Series) then
    Series.Visible := Check.IsChecked;
  UpdateFlowGraphCharts(0);
end;

procedure TFormMain.ClearFlowGraphsClick(Sender: TObject);
begin
  if FEtalonFlowHistory <> nil then FEtalonFlowHistory.Clear;
  if FDeviceFlowHistory <> nil then FDeviceFlowHistory.Clear;
  FLastFlowGraphSampleMs := 0;
  RefreshFlowGraphChannels;
end;

function TFormMain.IsFlowGraphSamplingActive(const AWorkTable: TWorkTable): Boolean;
begin
  Result := (AWorkTable <> nil) and
    ((AWorkTable.State in [swtMONITOR, swtSTARTMONITOR, swtSTARTMONITORWAIT,
      swtSTARTTEST, swtSTARTWAIT, swtEXECUTE, swtSTOPTEST, swtSTOPWAIT, swtFINALREAD]) or
     ((AWorkTable.MeasurementRun <> nil) and not (TMeasurementRun(AWorkTable.MeasurementRun).Stage in [msNone, msDone])));
end;

procedure TFormMain.AddFlowGraphSamples(const ATimeStampMs: Int64);
var
  WorkTable: TWorkTable;
  I: Integer;
  Channel: TChannel;
  Series: TFlowGraphSeries;
  Sample: TGraphSample;
  Key: string;

  procedure AddChannelSample(const APrefix: string; AChannel: TChannel; AIndex: Integer; AHistory: TFlowGraphHistory);
  begin
    if (AChannel = nil) or (AChannel.FlowMeter = nil) or (AChannel.FlowMeter.ValueFlow = nil) or (AChannel.State = osDeleted) then Exit;
    Key := BuildFlowGraphKey(APrefix, AChannel, AIndex);
    Series := AHistory.EnsureSeries(Key, BuildFlowGraphCaption(APrefix, AChannel, AIndex), NextGraphColor(Key));
    if (Series.Samples.Count > 0) and (Series.Samples.Last.TimeStampMs = ATimeStampMs) then Exit;
    Sample.TimeStampMs := ATimeStampMs;
    Sample.Value := AChannel.FlowMeter.ValueFlow.GetDoubleValueDim;
    if IsNan(Sample.Value) or IsInfinite(Sample.Value) then Exit;
    Series.Samples.Add(Sample);
    while Series.Samples.Count > MaxGraphSampleCountPerSeries do
      Series.Samples.Delete(0);
  end;

begin
  WorkTable := FWorkTableManager.ActiveWorkTable;
  SyncFlowGraphWorkTable;
  if (WorkTable = nil) or not IsFlowGraphSamplingActive(WorkTable) then Exit;
  if WorkTable.EtalonChannels <> nil then
    for I := 0 to WorkTable.EtalonChannels.Count - 1 do
      AddChannelSample('Etalon', WorkTable.EtalonChannels[I], I, FEtalonFlowHistory);
  if WorkTable.DeviceChannels <> nil then
    for I := 0 to WorkTable.DeviceChannels.Count - 1 do
      AddChannelSample('Device', WorkTable.DeviceChannels[I], I, FDeviceFlowHistory);
  UpdateFlowGraphCharts(ATimeStampMs);
end;

procedure TFormMain.SyncFlowGraphWorkTable;
begin
  if (FWorkTableManager <> nil) and (FWorkTableManager.ActiveWorkTable <> FFlowGraphWorkTable) then
    RefreshFlowGraphChannels;
end;

procedure TFormMain.RenderFlowChart(const AChart: TSimpleChart; const AHistory: TFlowGraphHistory;
  const ABaseTimeMs: Int64; const AWindowSec: Double; const ATitle: string);
var
  Pair: TPair<string, TFlowGraphSeries>;
  ChartSeries: TChartSeries;
  Sample: TGraphSample;
begin
  if AChart = nil then Exit;
  AChart.BeginUpdate;
  try
    AChart.ClearAllSeries;
    AChart.Title := ATitle;
    AChart.XTitle := 'Время, с';
    AChart.YTitle := 'Расход';
    AChart.XMin := 0;
    AChart.XMax := AWindowSec;
    for Pair in AHistory.Series do
      if Pair.Value.Visible and (Pair.Value.Samples.Count > 0) then
      begin
        ChartSeries := AChart.AddSeries(Pair.Value.Caption);
        ChartSeries.Color := Pair.Value.LineColor;
        ChartSeries.Thickness := 2;
        ChartSeries.ShowMarkers := False;
        for Sample in Pair.Value.Samples do
          ChartSeries.AddPoint((Sample.TimeStampMs - ABaseTimeMs) / 1000, Sample.Value);
      end;
  finally
    AChart.EndUpdate;
  end;
end;

procedure TFormMain.UpdateFlowGraphCharts(const ATimeStampMs: Int64);
var
  NowMs, MinMs: Int64;
begin
  if ATimeStampMs > 0 then NowMs := ATimeStampMs else NowMs := TThread.GetTickCount64;
  MinMs := Max(0, NowMs - Int64(GraphSampleIntervalMs) * MaxGraphSampleCountPerSeries);
  RenderFlowChart(FChartEtalonFlow, FEtalonFlowHistory, MinMs, (NowMs - MinMs) / 1000, 'Расход эталонов');
  RenderFlowChart(FChartDeviceFlow, FDeviceFlowHistory, MinMs, (NowMs - MinMs) / 1000, 'Расход приборов');
end;

procedure TFormMain.TimerSetValuesTimer(Sender: TObject);
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

  // Берём активную таблицу
  WorkTable := FWorkTableManager.ActiveWorkTable;

  // Дополнительная защита от nil
  if WorkTable = nil then
    Exit;


  // ============================================================
  // 2. Получение исполнительных объектов
  // ============================================================

  Pump := WorkTable.ActivePump;   // Насос (может быть nil)
  FlowRate := WorkTable.FlowRate; // Контроллер расхода

  // ============================================================
  // 3. Эмуляция физического процесса (стенд)
  // ============================================================

  // Обновление частоты насоса (имитация работы)
  UpdateRandomFreq(Pump);

  // Обновление текущего расхода  (имитация работы)
  UpdateRandomFlowRate(FlowRate);

  // Обновление климатических параметров (температура и др.)
  UpdateRandomTemp(WorkTable);

  // Обновление давления
  UpdateRandomPress(WorkTable);


  UpdateTemp(WorkTable);




  // ============================================================
  // 4. Машина состояний измерения
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
    // 5. Основной процесс измерения
    // ============================================================
    swtEXECUTE:
    begin
      // Обновление сигналов (имитация работы датчиков)
      UpdateRandomSignals(WorkTable);


      // ----------------------------------------------------------
      // 5.1 Расчёт текущих импульсов
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
      // 5.2 Получение текущего объёма/массы
      // ----------------------------------------------------------

      CurrentVolume := 0;

      // ValueQuantity — агрегированное значение измеренного количества
      if WorkTable.ValueQuantity <> nil then
        CurrentVolume := WorkTable.ValueQuantity.GetDoubleValue;


      // ----------------------------------------------------------
      // 5.3 Проверка наличия критериев остановки
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
      // 5.4 Проверка достижения критериев остановки
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
      // 5.5 Завершение измерения
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

  SyncFlowGraphWorkTable;
  if IsFlowGraphSamplingActive(WorkTable) and
     ((FLastFlowGraphSampleMs = 0) or (TThread.GetTickCount64 - FLastFlowGraphSampleMs >= GraphSampleIntervalMs)) then
  begin
    FLastFlowGraphSampleMs := TThread.GetTickCount64;
    AddFlowGraphSamples(FLastFlowGraphSampleMs);
  end;
end;






end.
