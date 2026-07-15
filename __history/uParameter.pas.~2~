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
  uProtocols,
  uRepositories;

type

  EParamStatus = (
    PARAM_STOPPED,
    PARAM_STARTED,
    PARAM_NONE,
    PARAM_CHANGING
  );

  EParamAction = (
    ACTION_NONE,
    ACTION_START,
    ACTION_STOP,
    ACTION_SET
  );





type

TParameter = class(TObject)
  type
  TonStatusEvent =  procedure(AParameters: TParameter ; FStatus : EParamStatus) of object;
  TonActionEvent =  procedure(AParameters: TParameter ; FAction : EParamAction) of object;
  private
    FName: string;
    FHint: string;
    FStatus: EParamStatus;
    FAction: EParamAction;
    FMax: Double;
    FMin: Double;
    FAccuracyPlus: Double;
    FAccuracyMinus: Double;
    FValue: TMeterValue;  // òåêóùàÿ
    FValueSet: TMeterValue;   //óñòàíîâëåííàÿ
    FBefore: Double;
    FAfter: Double;
    FDelta: Double;
    FHasTaskHistory: Boolean;
    FDim: integer;
    FOnStatusChange: TonStatusEvent;
    FOnActionChange: TonActionEvent;

    procedure SetMin(const Value: Double );
    procedure SetMax(const Value: Double);
    procedure SetValue(AValue: Double);
    procedure SetStatus(AStatus: EParamStatus);
    procedure SetBefore(ABefore: Double);
    procedure SetAfter(AAfter: Double);
    function GetIsRunning: Boolean;
    function GetIsChanging: Boolean;
    procedure SetParam(Avalue: Double);
  public
    constructor Create(const AName, AHint: string); virtual;
    function IsStable(out AStableInfo: rStableInfo): Boolean;
    function GetStatusAsString: string;
    procedure Stop;
    procedure Start;
    property OnStatusChange: TonStatusEvent read FOnStatusChange write FOnStatusChange;
    property OnActionChange: TonActionEvent read FOnActionChange write FOnActionChange;
    property Name: string read FName write FName;
    property Hint: string read FHint write FHint;
    property Status: EParamStatus read  FStatus   write SetStatus;
    property Action: EParamAction read FAction write FAction;
    property ValueSet: TMeterValue read FValueSet write FValueSet;
    property Value: TMeterValue read FValue write FValue;
    property IsRunning: Boolean read GetIsRunning;
    property IsChanging: Boolean read GetIsChanging;
    property AccuracyPlus: Double read FAccuracyPlus write FAccuracyPlus;
    property AccuracyMinus: Double read FAccuracyMinus write FAccuracyMinus;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
    property BeforeValue: Double read FBefore write SetBefore;
    property AfterValue: Double read FAfter write SetAfter;
    property DeltaValue: Double read FDelta write FDelta;




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
    procedure PumpSetStatus( AStatus: EParamStatus);

  end;
//---------------------------------
  TFlowRate = class(TParameter)


  public
    constructor Create(const AName: string = 'FlowRate');
    procedure SetParamFlowRate(ANewValue: Double);
    function GetActionAsString: string;
    procedure DoFlowRateStart(ANewFlowRate: Double);  overload;
    procedure DoFlowRateStart;  overload;
    procedure DoFlowRateStop;
    procedure DoFlowRateSet(ANewFlowRate: Double);
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
  FDelta := 0.1;
  FAccuracyPlus := 5;
  FAccuracyMinus := 5;
end;



 function TFluidTemp.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Изменена утсановленная температура';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;




procedure TFluidTemp.DoFluidTempStart(ATempSet: Double);
begin
  if not( SameValue(ValueSet.Value ,ATempSet, MinDouble)) then
    begin

    SetParam(ATempSet);
    if Assigned(FOnActionChange) then
      FOnActionChange(self, ACTION_Set);

    end;
   if not( IsRunning)  then
   begin


    Start;
    if Assigned(FOnActionChange) then
      FOnActionChange(self, ACTION_START);
   end;


end;


procedure TFluidTemp.DoFluidTempStop;
begin

  IF FAction = ACTION_STOP then
    exit;

  Stop;

  if Assigned(FOnActionChange) then
    FOnActionChange(self, ACTION_STOP);
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
  FDelta := 0.1;
  FAccuracyPlus := 5;
  FAccuracyMinus := 5;
end;




 function TFluidPress.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Изменено установленное давление';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;



procedure TFluidPress.DoFluidPressStart(APressSet: Double);
begin

  if not( SameValue(ValueSet.Value ,APressSet, MinDouble)) then
    begin

    SetParam(APressSet);
    if Assigned(FOnActionChange) then
      FOnActionChange(self,ACTION_SET);

    end;
   if not( IsRunning)  then
   begin


    Start;
    if Assigned(FOnActionChange) then
      FOnActionChange(self, ACTION_START);
   end;


end;

procedure TFluidPress.DoFluidPressStop;
begin

  if FAction = ACTION_STOP then
    Exit;

  Stop;

  if Assigned(FOnActionChange) then
    FOnActionChange(self,ACTION_STOP);
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

  FAction := ACTION_SET;
end;

 function TFlowRate.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Изменен расход воды';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;


procedure TFlowRate.DoFlowRateStart;
begin
   if not( IsRunning)  then
   begin

    Start;

    if Assigned(FOnActionChange) then
      FOnActionChange(self, ACTION_START);
   end;
end;

procedure TFlowRate.DoFlowRateStart(ANewFlowRate: Double);
begin

    if  IsRunning  then
    begin
      if not( SameValue(ValueSet.Value ,ANewFlowRate, MinDouble)) then
        begin

          SetParam(ANewFlowRate);
          if Assigned(FOnActionChange) then
            FOnActionChange(self, ACTION_Set);

        end;

    end
    else
    begin
      if not( SameValue(ValueSet.Value ,ANewFlowRate, MinDouble)) then
        begin

        SetParam(ANewFlowRate);
        if Assigned(FOnActionChange) then
          FOnActionChange(self, ACTION_Set);

        end;
     if not( IsRunning)  then
       begin

        Start;
        if Assigned(FOnActionChange) then
          FOnActionChange(self, ACTION_START);
       end;
    end;


end;

procedure TFlowRate.DoFlowRateStop;
begin
   if IsRunning  then
   begin

    Stop;

    if Assigned(FOnActionChange) then
      FOnActionChange(self, ACTION_STOP);
   end;
end;


procedure TFlowRate.DoFlowRateSet(ANewFlowRate: Double);
begin

  SetParam(ANewFlowRate);


  if Assigned(FOnActionChange) then
    FOnActionChange(SELF, ACTION_SET);
end;


  {$ENDREGION 'TFlowRate'}

   {$REGION 'TPump'}

constructor TPump.Create;
begin
  inherited Create('','');
  FMax:= 50;
  FMin:= 0;

  //FValue:=10;
  //FValueSet := 12;
end;

constructor TPump.Create(const APumpName: string);
begin
  Create;
  Self.FName :=   APumpName;
  Pumps.Add(Self);
  Value:=TMeterValue.Create;
  ValueSet:=TMeterValue.Create;
end;

destructor TPump.Destroy;
begin
  inherited;
end;







 function TPump.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Изменена частота насоса';
    ACTION_STOP: Result := 'Сброшен';
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

      if Assigned(FOnActionChange) then
        FOnActionChange(self, ACTION_START);
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

    if Assigned(FOnActionChange) then
      FOnActionChange(self,ACTION_STOP);
   end;
end;

procedure TPump.DoFreqSet;
begin
//  Pump:=FindPumpByName(APumpName);
 // if Pump = nil then
//    Exit;

  SetParam(ANewFreq);

  if Assigned(FOnActionChange) then
    FOnActionChange(self,ACTION_SET);
end;

procedure TPump.PumpSetStatus(AStatus: EParamStatus);
begin
 // Pump:=FindPumpByName(APumpName);
 // if Pump = nil then
  //  Exit;

  SetStatus(AStatus);

  if Assigned(FOnActionChange) then
    FOnActionChange(self,ACTION_SET);
end;

  {$ENDREGION 'TPump'}

{ TParameter }

{$REGION 'TParameter'}
constructor TParameter.Create(const AName, AHint: string);
begin
  inherited Create;
  FName := AName;
  ProtocolManager.AddMessage(pcState, psParameters, 'ParameterCreate', 'Parameter created', AName);
  FHint := AHint;
  FStatus := PARAM_STOPPED;
  FAction := ACTION_STOP;
  FHasTaskHistory := False;
  //FValue:=TMeterValue.Create;
  //FValueset:=TMeterValue.Create;
end;

procedure TParameter.Stop;
begin
  FAction := ACTION_STOP;
  ProtocolManager.AddMessage(pcAction, psParameters, 'ParameterStop', 'Parameter stopped', FName);
end;

function TParameter.IsStable(out AStableInfo: RStableInfo): Boolean;
var
  IsTargetReached: Boolean;
  HasStabilization: Boolean;
  HasActiveTask: Boolean;
  HadTask: Boolean;
  IsChangingNow: Boolean;
  ADelta: Double;
begin

  //код кодекса, надо переделывать
  IsTargetReached := (Value.Value<=ValueSet.Value*(1+AccuracyPlus/100))
      AND (Value.Value>=ValueSet.Value*(1-AccuracyMinus/100)) ;
  ADelta := Abs(FDelta);
  if ADelta <= MinDouble then
    ADelta := 0.001;
  HasStabilization := Abs(FAfter - FBefore) <= ADelta;
  HasActiveTask := (FStatus in [PARAM_STARTED, PARAM_CHANGING]) or (FAction in [ACTION_SET, ACTION_START]);
  HadTask := HasActiveTask or FHasTaskHistory;
  IsChangingNow := (FValueSet.Value<>FValue.Value) and (not IsTargetReached);

  if not HadTask then
    AStableInfo.Status := ssNONE
  else if not IsTargetReached then
  begin
    if IsChangingNow then
    begin
      if HasStabilization then
        AStableInfo.Status := ssRun_SN
      else
        AStableInfo.Status := ssRun_NN;
    end
    else if HasStabilization then
      AStableInfo.Status := ssFail_SN
    else
      AStableInfo.Status := ssFail_NN;
  end
  else
  begin
    if IsChangingNow then
      AStableInfo.Status := ssRun_NS
    else if HasStabilization then
      AStableInfo.Status := ssOk
    else
      AStableInfo.Status := ssFail_NS;
  end;

  case AStableInfo.Status of
    ssNONE:
      AStableInfo.StatusText := 'Не было заданий, поэтому стабилен.';
    ssRun_NN:
      AStableInfo.StatusText := 'Есть задание, происходит изменение, задание не достигнуто, стабилизации нет.';
    ssRun_SN:
      AStableInfo.StatusText := 'Есть задание, происходит изменение, задание не достигнуто, стабилизация есть.';
    ssRun_NS:
      AStableInfo.StatusText := 'Есть задание, происходит изменение, задание достигнуто, стабилизации нет.';
    ssOk:
      AStableInfo.StatusText := 'Было задание, оно выполнено, стабилизация достигнута.';
    ssFail_SN:
      AStableInfo.StatusText := 'Было задание, оно не достигнуто, стабилизация есть.';
    ssFail_NS:
      AStableInfo.StatusText := 'Было задание, оно достигнуто, стабилизации нет.';
    ssFail_NN:
      AStableInfo.StatusText := 'Было задание, оно не достигнуто и нет стабилизации.';
  end;

  AStableInfo.CurrentValue := Value.Value;
  Result := IsTargetReached;
end;
procedure TParameter.Start;
begin
    if FValueSet.Value<FMin then
      FValueSet.Value:=FMin;
    if FValueSet.Value>FMax then
      FValueSet.Value:=FMax;

  FAction := ACTION_START;
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



procedure TParameter.SetStatus(AStatus: EParamStatus);
begin
  FStatus := AStatus;
end;

procedure TParameter.SetBefore(ABefore: Double);
begin
  if ABefore < FMin then
    FBefore := FMin
  else if ABefore > FMax then
    FBefore := FMax
  else FBefore:=ABefore;
end;


procedure TParameter.SetAfter(AAfter: Double);
begin
  if AAfter < FMin then
    FAfter := FMin
  else if AAfter > FMax then
    FAfter := FMax
  else FAfter:=AAfter;
end;

procedure TParameter.SetValue(AValue: Double);
begin
  if AValue < FMin then
    FValue.Value := FMin
  else if AValue > FMax then
    FValue.Value := FMax
  else FValue.Value:=AValue;
end;


procedure TParameter.SetParam(AValue: Double);
begin

  if  SameValue(FValueSet.Value ,AValue, MinDouble) then
       Exit;



      if AValue<FMin then
        FValueSet.Value:=FMin
      else if AValue>FMax then
        FValueSet.Value:=FMax
      else
        FValueSet.Value:=AValue;

      ProtocolManager.AddMessage(pcAction, psParameters, 'ParameterSet', 'Parameter set changed', Format('%s=%.4f', [FName, FValueSet.Value]));


      FAction:=ACTION_SET;
      FHasTaskHistory := True;

end;

function TParameter.GetStatusAsString: string;
begin
  case FStatus of
    PARAM_STARTED: Result := 'Запущен';
    PARAM_STOPPED: Result := 'Остановлен';
    PARAM_NONE: Result := 'Бездействует';
    PARAM_CHANGING: Result := 'Изменяется';

  else
    Result := 'Неизвестно';
  end;
end;




function TParameter.GetIsRunning: Boolean;
begin
  Result := (FStatus = PARAM_STARTED);
end;

function TParameter.GetIsChanging: Boolean;
var
  AStableInfo: rStableInfo;
begin
  Result :=  (FValueSet.Value<>FValue.Value) and not(IsStable(AStableInfo));
end;

  {$ENDREGION 'TPump'}



end.
