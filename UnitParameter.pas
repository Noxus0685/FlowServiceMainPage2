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
  System.DateUtils,
  System.Math,
  System.StrUtils,
  System.IniFiles,
  System.Generics.Collections

  ;

type

  EParamStatus = (
    PARAM_NONE,
    PARAM_STOPPED,
    PARAM_STARTED,
    PARAM_CHANGING
  );

  EParamAction = (
    ACTION_NONE,
    ACTION_START,
    ACTION_STOP,
    ACTION_SET
  );




type
  EStableState = (
    STABLE_UNDEFINED,
    STABLE_IN_PROGRESS,
    STABLE_SUCCESS,
    STABLE_FAILURE
  );

  TStableStatus = record
    State: EStableState;
    Text: string;
    IsStable: Boolean;
  end;

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
    FStabilizationTimerSec: Integer;
    FStabilizationStartedAt: TDateTime;
    FStabilityInRangeStartedAt: TDateTime;
    FHasTask: Boolean;
    procedure StartStabilizationTimer;
    function GetInAccuracyBand: Boolean;
    function GetStableStateAsString(const AState: EStableState): string;
    procedure IsStable(var Status: TStableStatus); overload;
    property StabilizationTimerSec: Integer read FStabilizationTimerSec write FStabilizationTimerSec;
    FValue: Double;  // òåêóùàÿ
    FValueSet: Double;   //óñòàíîâëåííàÿ
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
    procedure SetParam(Avalue: Double);
    function GetIsChanging: Boolean;

  public
    constructor Create(const AName, AHint: string); virtual;
    function GetStatusAsString: string;
    procedure IsStable(var Status: Boolean);
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



    procedure DoPumpStart(APumpName: string);
    procedure DoPumpStop(APumpName: string);
    procedure DoFreqSet(APumpName: string; ANewFreq: Double);
    procedure PumpSetStatus(APumpName: string; AStatus: EParamStatus);

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


 function TFluidTemp.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Çàïóùåí';
    ACTION_SET: Result := 'Óñòàíîâêà íîâîãî çíà÷åíèÿ òåìïåðàòóðû';
    ACTION_STOP: Result := 'Ñáðîøåí';
  else
    Result := 'Íåèçâåñòíî';
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






 function TFluidPress.GetActionAsString: string;
begin
  case FAction of
    ACTION_START: Result := 'Çàïóùåí';
    ACTION_SET: Result := 'Óñòàíîâêà íîâîãî çíà÷åíèÿ äàâëåíèÿ';
    ACTION_STOP: Result := 'Ñáðîøåí';
  else
    Result := 'Íåèçâåñòíî';
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
    ACTION_START: Result := 'Çàïóùåí';
    ACTION_SET: Result := 'Óñòàíîâêà íîâîãî çíà÷åíèÿ ðàñõîäà';
    ACTION_STOP: Result := 'Ñáðîøåí';
  else
    Result := 'Íåèçâåñòíî';
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
    ACTION_START: Result := 'Çàïóùåí';
    ACTION_SET: Result := 'Èçìåíåí ðàñõîä âîäû';
    ACTION_STOP: Result := 'Ñáðîøåí';
  else
    Result := 'Íåèçâåñòíî';
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
  FStabilizationTimerSec := 0;
  FStabilizationStartedAt := 0;
  FStabilityInRangeStartedAt := 0;
  FHasTask := False;
end;

procedure TParameter.Stop;
begin
  FAction := ACTION_STOP;
end;


function TParameter.GetStableStateAsString(const AState: EStableState): string;
begin
  case AState of
    STABLE_UNDEFINED: Result := ' ';
    STABLE_IN_PROGRESS: Result := ' ';
    STABLE_SUCCESS: Result := '';
    STABLE_FAILURE: Result := '';
  else
    Result := ' ';
  end;
end;

function TParameter.GetInAccuracyBand: Boolean;
begin
  Result := (Value <= ValueSet * (1 + AccuracyPlus / 100)) AND
            (Value >= ValueSet * (1 - AccuracyMinus / 100));
end;

procedure TParameter.StartStabilizationTimer;
begin
  FStabilizationStartedAt := Now;
  FStabilityInRangeStartedAt := 0;
  FHasTask := True;
end;

procedure TParameter.IsStable(var Status: TStableStatus);
var
  AInAccuracyBand: Boolean;
  AElapsedInRangeSec: Int64;
  AElapsedFromStartSec: Int64;
  ATotalSec: Int64;
  AReachSec: Int64;
  AHoldSec: Int64;
begin
  AInAccuracyBand := GetInAccuracyBand;

  if not FHasTask then
  begin
    Status.State := STABLE_UNDEFINED;
    Status.IsStable := True;
    Status.Text := 'Ne opredeleno:' + sLineBreak +
      '1. Ne bylo zadaniy, poetomu stabilen.';
    Exit;
  end;

  ATotalSec := FStabilizationTimerSec;
  if ATotalSec <= 0 then
  begin
    Status.State := STABLE_IN_PROGRESS;
    Status.IsStable := False;
    Status.Text := 'V processe:' + sLineBreak +
      '2. Timer stabilizacii ne zadan, proverka 40/60 ne mozhet byt vypolnena.';
    Exit;
  end;

  AReachSec := Round(ATotalSec * 0.4);
  if AReachSec < 1 then
    AReachSec := 1;

  AHoldSec := ATotalSec - AReachSec;
  if AHoldSec < 1 then
    AHoldSec := 1;

  AElapsedFromStartSec := SecondsBetween(Now, FStabilizationStartedAt);

  if AInAccuracyBand then
  begin
    if FStabilityInRangeStartedAt = 0 then
      FStabilityInRangeStartedAt := Now;
  end
  else
    FStabilityInRangeStartedAt := 0;

  if FStabilityInRangeStartedAt = 0 then
    AElapsedInRangeSec := 0
  else
    AElapsedInRangeSec := SecondsBetween(Now, FStabilityInRangeStartedAt);

  if not AInAccuracyBand then
  begin
    if AElapsedFromStartSec <= AReachSec then
    begin
      Status.State := STABLE_IN_PROGRESS;
      Status.IsStable := False;
      Status.Text := 'V processe:' + sLineBreak +
        '2. Etap dostizheniya diapazona (40% vremeni), znachenie poka vne dopuska.';
      Exit;
    end;

    Status.State := STABLE_FAILURE;
    Status.IsStable := False;
    Status.Text := 'Neudacha:' + sLineBreak +
      '6. Za 40% vremeni parametr ne voshel v diapazon, stabilizaciya ne dostignuta.';
    Exit;
  end;

  if AElapsedInRangeSec < AHoldSec then
  begin
    Status.State := STABLE_IN_PROGRESS;
    Status.IsStable := False;
    Status.Text := 'V processe:' + sLineBreak +
      '3. Diapazon dostignut, idet nepreryvnoe uderzhanie (60% vremeni).';
    Exit;
  end;

  Status.State := STABLE_SUCCESS;
  Status.IsStable := True;
  Status.Text := 'Uspeh:' + sLineBreak +
    '3. Diapazon dostignut i nepreryvno uderzhan v techenie etapa 60%.';
end;

procedure TParameter.IsStable(var Status: Boolean);
var
  AStableStatus: TStableStatus;
begin
  IsStable(AStableStatus);
  Status := AStableStatus.IsStable;
end;

procedure TParameter.Start;
begin
    if FValueSet<FMin then
      FValueSet:=FMin;
    if FValueSet>FMax then
      FValueSet:=FMax;

  FAction := ACTION_START;
  StartStabilizationTimer;
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
      StartStabilizationTimer;
        Exit; // ×àñòîòà íå èçìåíèëàñü

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
    PARAM_STARTED: Result := 'Çàïóùåí';
    PARAM_STOPPED: Result := 'Îñòàíîâëåí';
  else
    Result := 'Íåèçâåñòíî';
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
