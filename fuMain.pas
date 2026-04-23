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


  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.ButtonApplyDeviceValuesClick(Sender: TObject);
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

procedure TFormMain.ButtonApplyEtalonValuesClick(Sender: TObject);
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

procedure TFormMain.EditTestNumExit(Sender: TObject);
begin
 LabelTestNum.Text := FWorkTableManager.WorkTables[0].DeviceChannels[0].FlowMeter.ValueError.GetStrNum(EditTestNum.Text)
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



    for i := 0 to TPump.Pumps.Count-1 do
    begin

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
    AWorkTable.FluidTemp.Status := spStarted

  else if (AWorkTable.FluidTemp.Action = apStop) then

    // Остановка регулирования
    AWorkTable.FluidTemp.Status := spStopped;


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
var
  TempDelta, PressDelta: Double;
begin
  if AWorkTable = nil then
    Exit;

  IF AWorkTable.FluidPress.Action = apStart THEN
    AWorkTable.FluidPress.Status:=spStarted
  else  if (AWorkTable.FluidPress.Action = apStop) then
    AWorkTable.FluidPress.Status:=spStopped;

   // Îáíîâëÿåì íå êàæäóþ ñåêóíäó
  if (FNextPressChangeAt = 0) or (Now >= FNextPressChangeAt) then
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
    APump.Status:=spStarted
  else  if (APump.Action = apStop) then
    APump.Status:=spStopped;




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

function TFormMain.UpdateEtalonImpSecFromFlowRate(AFlowRate:Double = 0;
  AEtalonChannels: TObjectList<TChannel> = nil):Double;
var
  WorkTable: TWorkTable;
  FlowRate, Coef, ImpSec: Double;
  i:integer;
begin
  WorkTable := FWorkTableManager.WorkTables[0];
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
  I: Integer;
  Coef: Double;
begin
  SetLength(Result, 0);
  if AChannels = nil then
    Exit;

  SetLength(Result, AChannels.Count);
  for I := 0 to AChannels.Count - 1 do
  begin
    Coef := GetChannelFlowCoef(AChannels[I]);
    if Coef > 0 then
      Result[I] := (AFlowRate * Coef) / 3.6
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
    AFlowRate.Status:=spStarted
  else  if (AFlowRate.Action = apStop) then
    AFlowRate.Status:=spStopped;

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
            if (WorkTable.EtalonChannels[I] <> nil) and (WorkTable.EtalonChannels[I].Enabled) then
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

    CurDelta := (Random * 0.6) - 0.3;
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

  // Берём первую таблицу (по факту — активную)
  // В будущем лучше заменить на FActiveWorkTable
  WorkTable := FWorkTableManager.WorkTables[0];

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
end;






end.
