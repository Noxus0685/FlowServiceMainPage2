unit uParameter;

interface

uses
  System.Generics.Collections,
  System.IniFiles,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uFlowMeter,
  uMeterValue,
  uObservable,
  uProtocols,
  uRepositories;

type

  EStateParameter = (
    spNone,
    spStopped,
    spStarted,
    spChanging,
    spOngoing
  );

  EActionParameter = (
    apNone,
    apStart,
    apStop,
    apSet
  );

  EEventParameter = (
    eparNone,
    eparStateChanged,
    eparActionChanged
  );

  EEventPump = (
    epStart,
    epStop,
    epFreqChanged,
    epError
  );

  EParameterType = (
    ptUnknown,
    ptFlow,
    ptPump,
    ptScale
  );

  EEventFlowRate = (
    efrStart,
    efrStop,
    efrSetValue,
    efrWarning,
    efrError
  );

  EEventFluidTemp = (
    eftStart,
    eftStop,
    eftSetValue,
    eftError
  );

  EEventFluidPress = (
    efpStart,
    efpStop,
    efpSetValue,
    efpError
  );





type

TParameter = class(TObservableObject)
  private
    FName: string;
    FHint: string;

    FState: EStateParameter;
    FAction: EActionParameter;

    FMax: Double;
    FMin: Double;

    /// <summary>Current measured value; owns stability settings and signal history used by IsStable.</summary>
    FValue: TMeterValue;
    /// <summary>Target/setpoint value; does not own stability settings.</summary>
    FValueSet: TMeterValue;
    /// <summary>Legacy lower/previous setup value kept for existing callers; not used for stability decisions.</summary>
    FBefore: Double;
    /// <summary>Legacy upper/next setup value kept for existing callers; not used for stability decisions.</summary>
    FAfter: Double;

    FHasTaskHistory: Boolean;
    FDim: integer;
    procedure SetMin(const Value: Double );
    procedure SetMax(const Value: Double);

    procedure SetState(AStatus: EStateParameter);
    procedure SetAction(AAction: EActionParameter);
    /// <summary>Stores legacy BeforeValue within Min..Max bounds without affecting stability analysis.</summary>
    procedure SetBefore(ABefore: Double);
    /// <summary>Stores legacy AfterValue within Min..Max bounds without affecting stability analysis.</summary>
    procedure SetAfter(AAfter: Double);
    /// <summary>Returns upper target tolerance percent from FValue.StabilitySettings.</summary>
    function GetAccuracyPlus: Double;
    /// <summary>Writes upper target tolerance percent to FValue.StabilitySettings.</summary>
    procedure SetAccuracyPlus(const AValue: Double);
    /// <summary>Returns lower target tolerance percent from FValue.StabilitySettings.</summary>
    function GetAccuracyMinus: Double;
    /// <summary>Writes lower target tolerance percent to FValue.StabilitySettings.</summary>
    procedure SetAccuracyMinus(const AValue: Double);
    /// <summary>Returns the legacy DeltaValue as the MaxVariation stability setting.</summary>
    function GetDeltaValue: Double;
    /// <summary>Writes legacy DeltaValue into the MaxVariation stability setting.</summary>
    procedure SetDeltaValue(const AValue: Double);
    function GetIsRunning: Boolean;
    function GetIsChanging: Boolean;
    procedure SetParam(Avalue: Double);
    procedure EnsureMeterValues;
    function GetSetValue: Double;
  public
    constructor Create(const AName, AHint: string); virtual;
    /// <summary>Combines TMeterValue signal analysis with target-range checks and returns measurement readiness.</summary>
    function IsStable(out AStableInfo: rStableInfo): Boolean;
    function GetStateAsString: string;
    procedure Stop;
    procedure Start;
    procedure SetValue(AValue: Double);
    property Name: string read FName write FName;
    property Hint: string read FHint write FHint;
    property State: EStateParameter read  FState write SetState;
    property Action: EActionParameter read FAction write SetAction;
    property ValueSet: TMeterValue read FValueSet write FValueSet;
    property Value: TMeterValue read FValue write FValue;
    property IsRunning: Boolean read GetIsRunning;
    property IsChanging: Boolean read GetIsChanging;
    /// <summary>Backward-compatible proxy to FValue.StabilitySettings.TargetAccuracyPlusPercent.</summary>
    property AccuracyPlus: Double read GetAccuracyPlus write SetAccuracyPlus;
    /// <summary>Backward-compatible proxy to FValue.StabilitySettings.TargetAccuracyMinusPercent.</summary>
    property AccuracyMinus: Double read GetAccuracyMinus write SetAccuracyMinus;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
    /// <summary>Legacy setup value kept for UI/process compatibility; not used in stability calculation.</summary>
    property BeforeValue: Double read FBefore write SetBefore;
    /// <summary>Legacy setup value kept for UI/process compatibility; not used in stability calculation.</summary>
    property AfterValue: Double read FAfter write SetAfter;
    /// <summary>Backward-compatible proxy to FValue.StabilitySettings.MaxVariation.</summary>
    property DeltaValue: Double read GetDeltaValue write SetDeltaValue;
    property TargetValue: Double read GetSetValue write SetParam;




end;

//---------------------------------
  TPump = class(TParameter)

  private
    FHeader: string; // êðàòêîå íàçâàíèå íàñîñà ïî ìíåìîñõåìå
    FPumpType: string;
  public

    class var Pumps: TObjectList<TPump>;

    constructor Create(const APumpName: string); overload;
    constructor Create;  overload;
    destructor Destroy; override;
    function GetActionAsString: string;
    property Header: string read FHeader write FHeader;
    property PumpType : string read FPumpType write FPumpType;



    procedure DoPumpStart;
    procedure DoPumpStop;
    procedure DoFreqSet( ANewFreq: Double);
    procedure PumpSetState( AStatus: EStateParameter);
    procedure FireEvent(AEvent: EEventPump; const AError: TErrorInfo); overload;
    procedure FireEvent(AEvent: EEventPump); overload;

  end;
//---------------------------------
  TWeight = class(TParameter)
  private
    FUUID: string;
    FCurrentWeight: Double;
    FTareWeight: Double;
  public
    class var Weights: TObjectList<TWeight>;

    constructor Create(const AScaleName: string); overload;
    constructor Create; overload;

    property UUID: string read FUUID write FUUID;
    property CurrentWeight: Double read FCurrentWeight write FCurrentWeight;
    property TareWeight: Double read FTareWeight write FTareWeight;
    property CurentValue: Double read FCurrentWeight write FCurrentWeight;
  end;

  TScale = TWeight;
//---------------------------------
  TFlowRate = class(TParameter)
 private
    FCurrentPoint: TDevicePoint;
    procedure   SetPoint(ACurrentPoint: TDevicePoint);
    function    GetPoint :TDevicePoint;

 public
    constructor Create(const AName: string = 'FlowRate');
    procedure   SetParamFlowRate(ANewValue: Double);
    function    GetActionAsString: string;
    procedure   DoFlowRateStart(ANewFlowRate: Double);  overload;
    procedure   DoFlowRateStart;  overload;
    procedure   DoFlowRateStop;
    procedure   DoFlowRateSet(ANewFlowRate: Double); overload;
    procedure   DoFlowRateSet(ANewFlowRate: Double; ACurrentPoint: TDevicePoint);  overload;
    procedure   FireEvent(AEvent: EEventFlowRate; const AError: TErrorInfo); overload;
    procedure   FireEvent(AEvent: EEventFlowRate); overload;
    property    CurrentPoint: TDevicePoint  read  GetPoint write SetPoint;

  end;
//---------------------------------
  TFluidTemp = class(TParameter)
  public
    constructor Create(const AName: string = 'FluidTemp');
    function GetActionAsString: string;
    procedure DoFluidTempStart(ATempSet: Double);
    procedure DoFluidTempStop;
  end;

//---------------------------------
  TFluidPress = class(TParameter)
  public
    constructor Create(const AName: string = 'FluidPress');

    function GetActionAsString: string;
    procedure DoFluidPressStart(APressSet: Double);
    procedure DoFluidPressStop;
  end;

implementation

uses uWorkTable;



   {$REGION 'TConditions'}
constructor TFluidTemp.Create(const AName: string);
begin
  inherited Create(AName,'');
  FMin := -50;
  FMax := 150;
  //FValue := 20.2;
  //FValueSet := 24;
  FBefore := 23;
  FAfter := 25;
  DeltaValue := 0.1;
  AccuracyPlus := 5;
  AccuracyMinus := 5;
end;



 function TFluidTemp.GetActionAsString: string;
begin
  case FAction of
    apStart: Result := 'Запущен';
    apSet: Result := 'Изменена установленная температура';
    apStop: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;




procedure TFluidTemp.DoFluidTempStart(ATempSet: Double);
begin
  if not( SameValue(ValueSet.Value ,ATempSet, MinDouble)) then
    begin

    SetParam(ATempSet);

    end;
   if not( IsRunning)  then
   begin


    Start;
   end;


end;

procedure TFluidTemp.DoFluidTempStop;
begin

  IF FAction = apStop then
    exit;

  Stop;
end;

constructor TFluidPress.Create(const AName: string);
begin
  inherited Create(AName,'');
  FMin := 0;
  FMax := 200;
  //FValue := 10;
  //FValueSet := 10;
  FBefore := 9;
  FAfter := 11;
  DeltaValue := 0.1;
  AccuracyPlus := 5;
  AccuracyMinus := 5;
end;

 function TFluidPress.GetActionAsString: string;
begin
  case FAction of
    apStart: Result := 'Запущен';
    apSet: Result := 'Изменено установленное давление';
    apStop: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;

procedure TFluidPress.DoFluidPressStart(APressSet: Double);
begin

  if not( SameValue(ValueSet.Value ,APressSet, MinDouble)) then
    begin

    SetParam(APressSet);

    end;
   if not( IsRunning)  then
   begin


    Start;
   end;


end;

procedure TFluidPress.DoFluidPressStop;
begin

  if FAction = apStop then
    Exit;

  Stop;
end;



  {$ENDREGION 'TConditions'}

   {$REGION 'TFlowRate'}
constructor TFlowRate.Create(const AName: string);
var
FlowMeter:TFlowMeter;
begin
  inherited Create(AName,'');
  FMin := 0;
  FMax := 500;
 // FValue := FlowMeter.ValueFlowRate;
 // FValueSet := FValue;
  AccuracyPlus:=5;
  AccuracyMinus:=5;
  FDim:=0;

end;




procedure TFlowRate.SetParamFlowRate(ANewValue: Double);
begin
  ANewValue:=ANewValue/3.6;
  if ANewValue < FMin then
    FValueSet.Value := FMin
  else if ANewValue > FMax then
    FValueSet.Value := FMax
  else
    FValueSet.Value := ANewValue;

  Action := apSet;
end;

 function TFlowRate.GetActionAsString: string;
begin
  case FAction of
    apStart: Result := 'Запущен';
    apSet: Result := 'Изменен расход воды';
    apStop: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;


procedure TFlowRate.DoFlowRateStart;
begin
   if not( IsRunning)  then
   begin

    Start;
   end;
end;

procedure TFlowRate.DoFlowRateStart(ANewFlowRate: Double);
begin

    if  IsRunning  then
    begin
      if not( SameValue(ValueSet.Value ,ANewFlowRate, MinDouble)) then
        begin

          SetParam(ANewFlowRate);

        end;

    end
    else
    begin
      if not( SameValue(ValueSet.Value ,ANewFlowRate, MinDouble)) then
        begin

        SetParam(ANewFlowRate);

        end;
     if not( IsRunning)  then
       begin

        Start;
       end;
    end;


end;

procedure TFlowRate.DoFlowRateStop;
begin
   if IsRunning  then
   begin

    Stop;
   end;
end;


procedure TFlowRate.DoFlowRateSet(ANewFlowRate: Double);
begin
  SetParam(ANewFlowRate);
end;

procedure TFlowRate.DoFlowRateSet(ANewFlowRate: Double; ACurrentPoint: TDevicePoint);
begin
   CurrentPoint:=ACurrentPoint;
   DoFlowRateSet(ANewFlowRate);
end;

   procedure TFlowRate.SetPoint(ACurrentPoint: TDevicePoint);
   begin
     FCurrentPoint:= ACurrentPoint;
   end;

   function TFlowRate.GetPoint :TDevicePoint;
   begin
      Result:=FCurrentPoint;
   end;



procedure TFlowRate.FireEvent(AEvent: EEventFlowRate; const AError: TErrorInfo);
begin
  inherited FireEvent(Ord(AEvent), AError);
end;

procedure TFlowRate.FireEvent(AEvent: EEventFlowRate);
begin
  FireEvent(AEvent, TErrorInfo.Empty(Integer(State)));
end;

  {$ENDREGION 'TFlowRate'}

   {$REGION 'TPump'}

constructor TPump.Create;
begin
  inherited Create('', '');
  FMax:= 50;
  FMin:= 12;

  EnsureMeterValues;
  //FValue:=10;
  //FValueSet := 12;
end;

constructor TPump.Create(const APumpName: string);
begin
  Create;
  Self.FName :=   APumpName;
  Pumps.Add(Self);
  EnsureMeterValues;
end;

destructor TPump.Destroy;
begin
  inherited;
end;

 function TPump.GetActionAsString: string;
begin
  case FAction of
    apStart: Result := 'Запущен';
    apSet: Result := 'Изменена частота насоса';
    apStop: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;

procedure TPump.DoPumpStart;
begin
  //Pump:=FindPumpByName(APumpName);
  //if Pump = nil then
  //  Exit;
    if not( IsRunning)  then
   begin
      Start;
   end;
end;

procedure TPump.DoPumpStop;
begin

 //   Pump:=FindPumpByName(APumpName);
 //   if Pump = nil then
  //    Exit;
   if IsRunning  then
   begin
   // if Pump.FAction = CONTROL_ACTION_STOP then
    //  Exit;


    Stop;
   end;
end;

procedure TPump.DoFreqSet;
begin
//  Pump:=FindPumpByName(APumpName);
 // if Pump = nil then
//    Exit;

  SetParam(ANewFreq);
end;

procedure TPump.PumpSetState(AStatus: EStateParameter);
begin
 // Pump:=FindPumpByName(APumpName);
 // if Pump = nil then
  //  Exit;

  SetState(AStatus);
end;


procedure TPump.FireEvent(AEvent: EEventPump; const AError: TErrorInfo);
begin
  inherited FireEvent(Ord(AEvent), AError);
end;

procedure TPump.FireEvent(AEvent: EEventPump);
begin
  FireEvent(AEvent, TErrorInfo.Empty(Integer(State)));
end;

  {$ENDREGION 'TPump'}

  {$REGION 'TWeight'}

constructor TWeight.Create;
begin
  inherited Create('', '');
  FUUID := TGUID.NewGuid.ToString;
  FCurrentWeight := 0;
  FTareWeight := 0;
end;

constructor TWeight.Create(const AScaleName: string);
begin
  Create;
  Self.FName := AScaleName;
  if Weights <> nil then
    Weights.Add(Self);
end;

  {$ENDREGION 'TWeight'}

{ TParameter }

{$REGION 'TParameter'}
constructor TParameter.Create(const AName, AHint: string);
begin
  inherited Create;
  FName := AName;
  ProtocolManager.AddMessage(pcState, psParameters, 'ParameterCreate', 'Parameter created', AName);
  FHint := AHint;
  FState := spStopped;
  Action := apStop;
  FHasTaskHistory := False;
  //FValue:=TMeterValue.Create;
  //FValueset:=TMeterValue.Create;
end;

procedure TParameter.Stop;
begin
  Action := apStop;
  ProtocolManager.AddMessage(pcAction, psParameters, 'ParameterStop', 'Parameter stopped', FName);
end;

function TParameter.IsStable(out AStableInfo: RStableInfo): Boolean;
var
  SignalInfo: TMeterValueStabilityInfo;
  Settings: TMeterValueStabilitySettings;
  HasActiveTask: Boolean;
  HadTask: Boolean;
  CurrentCheckPassed: Boolean;
  MeanCheckPassed: Boolean;
  ForecastCheckPassed: Boolean;
begin
  EnsureMeterValues;
  AStableInfo := Default(RStableInfo);

  Settings := FValue.StabilitySettings;
  AStableInfo.IsSignalStable := FValue.AnalyzeStability(SignalInfo);
  AStableInfo.SignalInfo := SignalInfo;
  AStableInfo.CurrentValue := SignalInfo.CurrentValue;
  AStableInfo.MeanValue := SignalInfo.MeanValue;
  AStableInfo.ForecastValue := SignalInfo.ForecastValue;
  AStableInfo.TargetValue := FValueSet.Value;

  CalculateTargetLimits(AStableInfo.TargetValue, Settings.TargetAccuracyPlusPercent,
    Settings.TargetAccuracyMinusPercent, Settings.TargetToleranceAbsolute,
    AStableInfo.LowerLimit, AStableInfo.UpperLimit);

  AStableInfo.IsCurrentInRange := (SignalInfo.CurrentValue >= AStableInfo.LowerLimit) and
    (SignalInfo.CurrentValue <= AStableInfo.UpperLimit);
  AStableInfo.IsMeanInRange := (SignalInfo.MeanValue >= AStableInfo.LowerLimit) and
    (SignalInfo.MeanValue <= AStableInfo.UpperLimit);
  AStableInfo.IsForecastInRange := (SignalInfo.ForecastValue >= AStableInfo.LowerLimit) and
    (SignalInfo.ForecastValue <= AStableInfo.UpperLimit);

  CurrentCheckPassed := (not Settings.RequireCurrentValueInRange) or AStableInfo.IsCurrentInRange;
  MeanCheckPassed := (not Settings.RequireMeanValueInRange) or AStableInfo.IsMeanInRange;
  ForecastCheckPassed := (not Settings.RequireForecastInRange) or AStableInfo.IsForecastInRange;
  AStableInfo.IsTargetConditionPassed := CurrentCheckPassed and MeanCheckPassed and ForecastCheckPassed;
  AStableInfo.IsReadyForMeasurement := AStableInfo.IsSignalStable and AStableInfo.IsTargetConditionPassed;

  HasActiveTask := (FState in [spStarted, spChanging]) or (FAction in [apSet, apStart]);
  HadTask := HasActiveTask or FHasTaskHistory;
  if not HadTask then
    AStableInfo.Status := sNONE
  else if AStableInfo.IsReadyForMeasurement then
    AStableInfo.Status := sOk
  else if HasActiveTask then
  begin
    if AStableInfo.IsSignalStable and not AStableInfo.IsTargetConditionPassed then
      AStableInfo.Status := sRun_SN
    else if (not AStableInfo.IsSignalStable) and AStableInfo.IsTargetConditionPassed then
      AStableInfo.Status := sRun_NS
    else
      AStableInfo.Status := sRun_NN;
  end
  else
  begin
    if AStableInfo.IsSignalStable and not AStableInfo.IsTargetConditionPassed then
      AStableInfo.Status := sFail_SN
    else if (not AStableInfo.IsSignalStable) and AStableInfo.IsTargetConditionPassed then
      AStableInfo.Status := sFail_NS
    else
      AStableInfo.Status := sFail_NN;
  end;

  if AStableInfo.IsReadyForMeasurement then
    AStableInfo.StatusText := 'Параметр готов: текущее значение, среднее и прогноз находятся в допустимом диапазоне; стабильность подтверждена.'
  else if not AStableInfo.IsTargetConditionPassed then
  begin
    if Settings.RequireCurrentValueInRange and not AStableInfo.IsCurrentInRange then
      AStableInfo.StatusText := Format('%s ещё не готов: текущее значение %.4f вне допустимого диапазона %.4f–%.4f. ', [FName, SignalInfo.CurrentValue, AStableInfo.LowerLimit, AStableInfo.UpperLimit]);
    if Settings.RequireMeanValueInRange and not AStableInfo.IsMeanInRange then
      AStableInfo.StatusText := AStableInfo.StatusText + Format('Среднее значение %.4f вне диапазона. ', [SignalInfo.MeanValue]);
    if Settings.RequireForecastInRange and not AStableInfo.IsForecastInRange then
      AStableInfo.StatusText := AStableInfo.StatusText + Format('Прогноз %.4f выходит за диапазон %.4f–%.4f. ', [SignalInfo.ForecastValue, AStableInfo.LowerLimit, AStableInfo.UpperLimit]);
    if not AStableInfo.IsSignalStable then
      AStableInfo.StatusText := AStableInfo.StatusText + SignalInfo.StatusText;
  end
  else
    AStableInfo.StatusText := Format('%s находится в допустимом диапазоне, но стабильность не подтверждена. %s', [FName, SignalInfo.StatusText]);

  Result := AStableInfo.IsReadyForMeasurement;
end;

procedure TParameter.Start;
begin
  EnsureMeterValues;

    if FValueSet.Value<FMin then
      FValueSet.Value:=FMin;
    if FValueSet.Value>FMax then
      FValueSet.Value:=FMax;

  FValue.ClearSamplesHistory;
  Action := apStart;
  FHasTaskHistory := True;
  ProtocolManager.AddMessage(pcAction, psParameters, 'ParameterStart', 'Parameter started', FName);
end;

procedure TParameter.SetMin(const Value: Double);
begin
  if Value > FMax then
    Exit;

  FMin := Value;
end;

procedure TParameter.SetMax(const Value: Double);
begin
  if Value < FMin then
    Exit;

  FMax := Value;
end;

procedure TParameter.SetState(AStatus: EStateParameter);
var
  OldState: EStateParameter;
begin
  if FState = AStatus  then
    Exit;

  OldState := FState;
  FState := AStatus;
  FireEvent(Ord(eparStateChanged));
  NotifyOwned(notifyStateChanged, TStateNotification.Create(Ord(OldState), Ord(AStatus)));
end;

procedure TParameter.SetAction(AAction: EActionParameter);
begin
  //if FAction = AAction then
  //  Exit;

  FAction := AAction;
  FireEvent(Ord(eparActionChanged));
  if Self is TPump then
  begin
    case AAction of
      apStart: TPump(Self).FireEvent(epStart);
      apStop: TPump(Self).FireEvent(epStop);
      apSet: TPump(Self).FireEvent(epFreqChanged);
    else
      TPump(Self).FireEvent(epError);
    end;
  end
  else if Self is TFlowRate then
  begin
    case AAction of
      apStart: TFlowRate(Self).FireEvent(efrStart);
      apStop: TFlowRate(Self).FireEvent(efrStop);
      apSet: TFlowRate(Self).FireEvent(efrSetValue);
    else
      TFlowRate(Self).FireEvent(efrError);
    end;
  end
  else if Self is TFluidTemp then
  begin
    case AAction of
      apStart: FireEvent(Ord(eftStart));
      apStop: FireEvent(Ord(eftStop));
      apSet: FireEvent(Ord(eftSetValue));
    else
      FireEvent(Ord(eftError));
    end;
  end
  else if Self is TFluidPress then
  begin
    case AAction of
      apStart: FireEvent(Ord(efpStart));
      apStop: FireEvent(Ord(efpStop));
      apSet: FireEvent(Ord(efpSetValue));
    else
      FireEvent(Ord(efpError));
    end;
  end;

  NotifyOwned(notifyAction, TActionNotification.Create(Ord(AAction)));
end;

procedure TParameter.SetBefore(ABefore: Double);
begin
  if ABefore < FMin then
    FBefore := FMin
  else if ABefore > FMax then
    FBefore := FMax
  else
    FBefore := ABefore;
end;

procedure TParameter.SetAfter(AAfter: Double);
begin
  if AAfter < FMin then
    FAfter := FMin
  else if AAfter > FMax then
    FAfter := FMax
  else
    FAfter := AAfter;
end;

function TParameter.GetAccuracyPlus: Double;
begin
  EnsureMeterValues;
  Result := FValue.StabilitySettings.TargetAccuracyPlusPercent;
end;

procedure TParameter.SetAccuracyPlus(const AValue: Double);
var
  Settings: TMeterValueStabilitySettings;
begin
  EnsureMeterValues;
  Settings := FValue.StabilitySettings;
  Settings.TargetAccuracyPlusPercent := System.Math.Max(0.0, AValue);
  FValue.StabilitySettings := Settings;
end;

function TParameter.GetAccuracyMinus: Double;
begin
  EnsureMeterValues;
  Result := FValue.StabilitySettings.TargetAccuracyMinusPercent;
end;

procedure TParameter.SetAccuracyMinus(const AValue: Double);
var
  Settings: TMeterValueStabilitySettings;
begin
  EnsureMeterValues;
  Settings := FValue.StabilitySettings;
  Settings.TargetAccuracyMinusPercent := System.Math.Max(0.0, AValue);
  FValue.StabilitySettings := Settings;
end;

function TParameter.GetDeltaValue: Double;
begin
  EnsureMeterValues;
  Result := FValue.StabilitySettings.MaxVariation;
end;

procedure TParameter.SetDeltaValue(const AValue: Double);
var
  Settings: TMeterValueStabilitySettings;
begin
  EnsureMeterValues;
  // DeltaValue is a deprecated compatibility name for the stability variation limit.
  Settings := FValue.StabilitySettings;
  Settings.MaxVariation := System.Math.Max(0.0, AValue);
  FValue.StabilitySettings := Settings;
end;

procedure TParameter.SetValue(AValue: Double);
begin
  EnsureMeterValues;

  if AValue < FMin then
    FValue.Value := FMin
  else if AValue > FMax then
    FValue.Value := FMax
  else FValue.Value:=AValue;
end;


function TParameter.GetSetValue: Double;
begin
  EnsureMeterValues;
  Result := FValueSet.Value;
end;



procedure TParameter.EnsureMeterValues;
begin
  if FValue = nil then
    FValue := TMeterValue.Create;
  if FValueSet = nil then
    FValueSet := TMeterValue.Create;
end;

procedure TParameter.SetParam(AValue: Double);
begin
      EnsureMeterValues;

       if  SameValue(FValueSet.Value ,AValue, MinDouble) then
       Exit;

      if AValue<FMin then
        FValueSet.Value:=FMin
      else if AValue>FMax then
        FValueSet.Value:=FMax
      else
        FValueSet.Value:=AValue;
      FValue.ClearSamplesHistory;
      ProtocolManager.AddMessage(pcAction, psParameters, 'ParameterSet', 'Parameter set changed', Format('%s=%.4f', [FName, FValueSet.Value]));

      Action := apSet;
      FHasTaskHistory := True;
end;

function TParameter.GetStateAsString: string;
begin
  case FState of
    spStarted: Result := 'Запущен';
    spStopped: Result := 'Остановлен';
    spNone: Result := 'Бездействует';
    spChanging: Result := 'Изменяется';

  else
    Result := 'Неизвестно';
  end;
end;




function TParameter.GetIsRunning: Boolean;
begin
  Result := (FState = spStarted) or (FState = spOngoing  );
end;

function TParameter.GetIsChanging: Boolean;
var
  AStableInfo: rStableInfo;
begin
  IsStable(AStableInfo);
  Result := (FState = spChanging) or
    ((not AStableInfo.IsTargetConditionPassed) and (not AStableInfo.SignalInfo.IsTrendStable)) or
    ((FAction in [apSet, apStart]) and (not AStableInfo.IsSignalStable));
end;

  {$ENDREGION 'TPump'}



end.
