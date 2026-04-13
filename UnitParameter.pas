unit UnitParameter;

interface

uses
 UnitBaseProcedures,
  UnitRepositories,
  UnitFlowMeter,
  UnitMeterValue,
  UnitClasses, UnitDeviceClass,
  UnitDataManager,
  System.SysUtils,
  System.Math,
  System.StrUtils,
  System.IniFiles,
  System.Generics.Collections

  ;

type

  EParamStatus = (
    PARAM_STOPPED,
    PARAM_STARTED
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
    FValue: Double;  // текущая
    FValueSet: Double;   //установленная
    FBefore: Double;
    FAfter: Double;
    FDelta: Double;
    FDim: integer;
    FOnStatusChange: TonStatusEvent;
    FOnActionChange: TonActionEvent;

    procedure SetMin(const Value: Double );
    procedure SetMax(const Value: Double);
    procedure SetValue(AValue: Double);
    function  GetValue: Double;
    procedure SetStatus(AStatus: EParamStatus);
    procedure SetBefore(ABefore: Double);
    procedure SetAfter(AAfter: Double);
    function GetIsRunning: Boolean;
    function GetIsChanging: Boolean;
    procedure SetParam(Avalue: Double);
  public
    constructor Create(const AName, AHint: string); virtual;
    function GetStatusAsString: string;
    procedure Stop;
    procedure Start;
    property OnStatusChange: TonStatusEvent read FOnStatusChange write FOnStatusChange;
    property OnActionChange: TonActionEvent read FOnActionChange write FOnActionChange;
    property Name: string read FName write FName;
    property Hint: string read FHint write FHint;
    property Status: EParamStatus read  FStatus   write SetStatus;
    property Action: EParamAction read FAction write FAction;
    property ValueSet: Double read FValueSet write SetParam;
    property Value: Double read GetValue write SetValue;
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
    FHeader: string; // краткое название насоса по мнемосхеме
    FPumpType: string;
  public

    class var Pumps: TObjectList<TPump>;

    constructor Create(const APumpName: string); overload;
    constructor Create;  overload;
    destructor Destroy; override;
    function GetActionAsString: string;
    property Header: string read FHeader write FHeader;
    property PumpType : string read FPumpType write FPumpType;



    procedure DoPumpStart(APumpName: string);
    procedure DoPumpStop(APumpName: string);
    procedure DoFreqSet(APumpName: string; ANewFreq: Double);
    procedure PumpSetStatus(APumpName: string; AStatus: EParamStatus);

  end;
//---------------------------------
  TFlowRate = class(TParameter)


  public
    constructor Create(const AName: string = 'FlowRate');
    function IsStable: Boolean;
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
    function IsStable: Boolean;
    constructor Create(const AName: string = 'FluidTemp');
    function GetActionAsString: string;
    procedure DoFluidTempStart(ATempSet: Double);
    procedure DoFluidTempStop;
  end;

//---------------------------------
  TFluidPress = class(TParameter)
  public
    constructor Create(const AName: string = 'FluidPress');
    function IsStable: Boolean;
    function GetActionAsString: string;
    procedure DoFluidPressStart(APressSet: Double);
    procedure DoFluidPressStop;
  end;

implementation

uses UnitWorkTable;



   {$REGION 'TConditions'}
constructor TFluidTemp.Create(const AName: string);
begin
  inherited Create(AName,'');
  FMin := -50;
  FMax := 150;
  FValue := 20.2;
  FValueSet := 24;
  FBefore := 23;
  FAfter := 25;
  FDelta := 0.1;
  FAccuracyPlus := 5;
  FAccuracyMinus := 5;
end;

function TFluidTemp.IsStable : Boolean ;

begin
  Result:= (Value<=ValueSet*(1+AccuracyPlus/100))
      AND (Value>=ValueSet*(1-AccuracyMinus/100)) ;

end;

 function TFluidTemp.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Установка нового значения температуры';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;




procedure TFluidTemp.DoFluidTempStart(ATempSet: Double);
begin
  if not( SameValue(ValueSet ,ATempSet, MinDouble)) then
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
  FValue := 10;
  FValueSet := 10;
  FBefore := 9;
  FAfter := 11;
  FDelta := 0.1;
  FAccuracyPlus := 5;
  FAccuracyMinus := 5;
end;


function TFluidPress.IsStable: Boolean ;
begin
  Result:= (Value<=ValueSet*(1+AccuracyPlus/100))
      AND (Value>=ValueSet*(1-AccuracyMinus/100)) ;

end;




 function TFluidPress.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Установка нового значения давления';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;



procedure TFluidPress.DoFluidPressStart(APressSet: Double);
begin

  if not( SameValue(ValueSet ,APressSet, MinDouble)) then
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
begin
  inherited Create(AName,'');
  FMin := 0;
  FMax := 500;
  FValue := 0;
  FValueSet := FMin;
  AccuracyPlus:=5;
  AccuracyMinus:=5;
  FDim:=0;

end;

function TFlowRate.IsStable : Boolean ;
begin
    Result:= (Value<=ValueSet*(1+AccuracyPlus/100))
        AND (Value>=ValueSet*(1-AccuracyMinus/100)) ;

end;


procedure TFlowRate.SetParamFlowRate(ANewValue: Double);
begin
  ANewValue:=ANewValue/3.6;
  if ANewValue < FMin then
    FValueSet := FMin
  else if ANewValue > FMax then
    FValueSet := FMax
  else
    FValueSet := ANewValue;

  FAction := ACTION_SET;
end;

 function TFlowRate.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Установка нового значения расхода';
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
    if not( SameValue(ValueSet ,ANewFlowRate, MinDouble)) then
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

  FValue:=10;
  FValueSet := 12;
end;

constructor TPump.Create(const APumpName: string);
begin
  Create;
  Self.FName :=   APumpName;
  Pumps.Add(Self);
end;

destructor TPump.Destroy;
begin
  inherited;
end;







 function TPump.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Запущен';
    ACTION_SET: Result := 'Изменен расход воды';
    ACTION_STOP: Result := 'Сброшен';
  else
    Result := 'Неизвестно';
  end;
end;

procedure TPump.DoPumpStart(APumpName: string);
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

procedure TPump.DoPumpStop(APumpName: string);
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

procedure TPump.DoFreqSet(APumpName: string; ANewFreq: Double);
begin
//  Pump:=FindPumpByName(APumpName);
 // if Pump = nil then
//    Exit;

  SetParam(ANewFreq);

  if Assigned(FOnActionChange) then
    FOnActionChange(self,ACTION_SET);
end;

procedure TPump.PumpSetStatus(APumpName: string;AStatus: EParamStatus);
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
  FHint := AHint;
  FStatus := PARAM_STOPPED;
  FAction := ACTION_STOP;
end;

procedure TParameter.Stop;
begin
  FAction := ACTION_STOP;
end;


procedure TParameter.Start;
begin
    if FValueSet<FMin then
      FValueSet:=FMin;
    if FValueSet>FMax then
      FValueSet:=FMax;

  FAction := ACTION_START;
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
    FValue := FMin
  else if AValue > FMax then
    FValue := FMax
  else FValue:=AValue;
end;

function TParameter.GetValue: Double;
begin
  Result :=  FValue;
end;

procedure TParameter.SetParam(AValue: Double);
begin

  if  SameValue(FValueSet ,AValue, MinDouble) then
        Exit; // Частота не изменилась

      if AValue<FMin then
        FValueSet:=FMin
      else if AValue>FMax then
        FValueSet:=FMax
      else
        FValueSet:=AValue;

      FAction:=ACTION_SET;

end;

function TParameter.GetStatusAsString: string;
begin
  case FStatus of
    PARAM_STARTED: Result := 'Запущен';
    PARAM_STOPPED: Result := 'Остановлен';
  else
    Result := 'Неизвестно';
  end;
end;




function TParameter.GetIsRunning: Boolean;
begin
  Result := (FStatus = PARAM_STARTED);
end;

function TParameter.GetIsChanging: Boolean;
begin
  Result :=  FValueSet<>FValue;
end;

  {$ENDREGION 'TPump'}



end.
