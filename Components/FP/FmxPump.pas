unit FmxPump;

{ ===== Компонент FmxPump =====
Визуальный компонент насоса.
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cPumpStyle='pumpstyle';
  cStartStopDeviceIndex=0;
  cPowerDeviceIndex=1;
  cMaxPower = 100;//Мощность в %
  cDeltaPower = 0.1;

  //Количество свойств
  cFlowPumpPropertyCount = 36;

  //Наименования свойств
  cFlowPumpPropertys: array[0..cFlowPumpPropertyCount-1] of string = (
    cHeader, cHint,
    cPortD, cAddressD, cBaudrateD, cParityD, cModuleTypeD, cNumContactD,
    cPortU, cAddressU, cBaudrateU, cParityU, cModuleTypeU, cNumContactU,
    cLeft, cTop, cWidth, cHeight, cFirst, cNumAppFunction, сFeedback,
    cVisible, cTypeAppFunc, cTypeOfProtocolD, cTypeOfProtocolU, cModbusInputRegD,
    cModbusInputRegU, cModbusOutputRegD, cModbusOutputRegU, cMinInput, cMaxInput, cMinOutput,
    cMaxOutput,cMinFreq,cMaxFreq,cModulePriority
  );

  //типы свойств
  cFlowPumpPropertysType:array[0..cFlowPumpPropertyCount-1]of TParameterType=(
//  cHeader,cHint
    ptText,ptText,
//  cPortD, cAddressD, cBaudrateD, cModuleTypeD,cNumContactD,
    ptNumber,ptNumber,ptNumber, ptComboBox,ptComboBox,ptNumber,
//  cPortU, cAddressU, cBaudrateU,cModuleTypeU,cNumContactU,
    ptNumber,ptNumber,ptNumber, ptComboBox,ptComboBox,ptNumber,
//cLeft,cTop,cWidth,cHeight,
    ptFloat,ptFloat,ptFloat,ptFloat,
//  cFirst, cNumAppFunction, сFeedback,
    ptComboBox, ptNumber, ptComboBox,
//  cVisible, cTypeAppFunc, cTypeOfProtocolD, cTypeOfProtocolU, cModbusInputRegD,
    ptComboBox, ptComboBox,ptComboBox, ptComboBox,ptNumber,
//  cModbusInputRegU, cModbusOutputRegD, cModbusOutputRegU, cMinInput, cMaxInput, cMinOutput, cMaxOutput,cMinFreq,cModulePriority
    ptNumber,  ptNumber,  ptNumber,  ptNumber,  ptNumber,  ptNumber,  ptNumber,  ptNumber,ptNumber , ptNumber
  );

  //Комбо выпадающие списки
  cFlowPumpPropertyComboItems: array[0..cFlowPumpPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPortD, cAddressD, cBaudrateD,cParityD
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleTypeD cNumContactD,
    [cmtABBModbus,cmtDeltaModbus,cmtVLT6000,cmtVLTModbus,cmtVaconModbus,cmtATV312,cmtHSC_CTRL,cmtSuperBIO,cmtValve,cmtBIO,cmtRT2,cmtModbusD],[],
//  cPortU, cAddressU, cBaudrateU,cParityU
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleTypeU cNumContactU,
    [cmtABBModbus,cmtDeltaModbus,cmtVLT6000,cmtVLTModbus,cmtVaconModbus,cmtATV312,cmtDAC_I702X,cmtLogoDAC,cmtRT2,cmtModbusA],[],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cFirst, cNumAppFunction, сFeedback,
    [cNo,cYes],[],[cNo,cYes],
//  cVisible, cTypeAppFunc,
    [cNo,cYes],[cNumber,cMask],
//  cTypeOfProtocolD,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cTypeOfProtocolU,cModbusInputRegD,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],[],
//  cModbusInputRegU, cModbusOutputRegD, cModbusOutputRegU, cMinInput, cMaxInput, cMinOutput, cMaxOutput,cMinFreq,cModulePriority
    [],[],[],[],[],[],[],[],[],[]
    );


type
  TFmxPumpProperties = (pPumpHeader = 0,
    pPumpHint,
    pPumpPortD,
    pPumpAddressD,
    pPumpBaudrateD,
    pPumpParityD,
    pPumpModuleTypeD,
    pPumpNumContactD,
    pPumpPortU,
    pPumpAddressU,
    pPumpBaudrateU,
    pPumpParityU,
    pPumpModuleTypeU, pPumpNumContactU,
    pPumpLeft, pPumpTop, pPumpWidth, pPumpHeight, pPumpFirst, pPumpNumAppFunction,
    pPumpFeedback, pPumpVisible, pPumpTypeAppFunc, pPumpTypeOfProtocolD, pPumpTypeOfProtocolU,
    pPumpRegAddrD, pPumpRegAddrU
  );

  TFmxPump = class(TFMXDeviceCustomControl)
  private
    FWithInput: Boolean;
    //номер дискретного выхода
    FIONumber: Byte;
    //номер аналогового выхода
    FDACNumber: Byte;
    FPower: Single;
    FKOutput: Single;
    FKInput: Single;
    FMinFreq: integer;
    FMaxFreq: integer;
    FOnUpdatePower: TNotifyEvent;
    FParityD,FParityU:TComParity;

    // Обработчик прокрутки колеса мыши при вводе текста в строке ввода положения задвижки.
    procedure PositionEditChange;

    // Обработчик изменения значения полосы прокрутки.
    procedure PowerScrollBarChange;

    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;


    { ===== SetPower =====
    Устанавливает мощность насоса в соответствии со значением PowerScrollBar.Position.
    }
    procedure UpdatePower;

    // обработчик нажатия на кнопку.
    procedure StartStopButtonClick(Sender: TObject);

    procedure SetIONumber(const Value: Byte);
    procedure SetWithInput(const Value: Boolean);
    procedure SetDACNumber(const Value: Byte);
    procedure SetStarted(const Value: Boolean);
    function GetStartCaption: String;
    function GetStopCaption: String;
    function GetModuleTypeName: string;
    function GetStarted: Boolean;
    function GetPower: Single;
    function GetMaxI: Single;
    function GetMaxO: Single;
    function GetMinI: Single;
    function GetMinO: Single;
    procedure SetMaxI(const Value: Single);
    procedure SetMaxO(const Value: Single);
    procedure SetMinI(const Value: Single);
    procedure SetMinO(const Value: Single);
    function GetDPort: Integer;
    procedure SetDPort(const Value: Integer);
    function GetUPort: Integer;
    procedure SetUPort(const Value: Integer);
    function GetDAddr: Integer;
    function GetUAddr: Integer;
    procedure SetDAddr(const Value: Integer);
    procedure SetUAddr(const Value: Integer);
    function GetDBaudrate: Integer;
    function GetUBaudrate: Integer;
    procedure SetDBaudrate(const Value: Integer);
    procedure SetUBaudrate(const Value: Integer);
    function GetDModuleType: TFmxModuleType;
    function GetUModuleType: TFmxModuleType;
    procedure SetDModuleType(const Value: TFmxModuleType);
    procedure SetUModuleType(const Value: TFmxModuleType);
    function GetDTypeOfProtocol: TTypeOfProtocol;
    function GetUTypeOfProtocol: TTypeOfProtocol;
    procedure SetDTypeOfProtocol(const Value: TTypeOfProtocol);
    procedure SetUTypeOfProtocol(const Value: TTypeOfProtocol);
    function GetDInputRegister: integer;
    function GetDOutputRegister: integer;
    function GetUInputRegister: integer;
    function GetUOutputRegister: integer;
    procedure SetDInputRegister(const Value: integer);
    procedure SetDOutputRegister(const Value: integer);
    procedure SetUInputRegister(const Value: integer);
    procedure SetUOutputRegister(const Value: integer);
    procedure SetOnUpdatePower(const Value: TNotifyEvent);
    function GetCurrentFrequency: Single;
    procedure SetupPower(const Value: Single);
    function GetParityD: TComParity;
    function GetParityU: TComParity;
    procedure SetParityD(const Value: TComParity);
    procedure SetParityU(const Value: TComParity);
    function GetPriority: integer;override;
    function GetFreq: Single;

  protected
    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetMax(const Value: Single);override;
    function GetMin: Single;override;//минимальная Мощность
    procedure SetMin(const Value: Single);override;
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure SetComPort(AIdx: integer; const Value: word); override;
    procedure SetAddress(AIdx: Integer; const Value: Integer); override;
    procedure SetBaudrate(AIdx: Integer; const Value: Cardinal); override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType); override;
    function Disguise: Boolean; override;
    function GetCurState: String; override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
    function GetMaxChannels: byte;override;
    procedure SetMaxChannels(const Value: byte);override;

  public
    // Указатель на устройство включающиее и выключающее насос
    DeviceStartStop: TFmxDevicePumpStartStop;
    // Указатель на устройство устанавливающее мощность на насосе
    DevicePower: TFmxDevicePumpPower;

    constructor Create(AOwner: TComponent); override;
    procedure DoOnChange(Sender: TObject); override;
    destructor Destroy; override;
    procedure FillParametersList;override;

    { ===== Start =====
    Запускает насос.
    }
    procedure Start;
    { ===== Stop =====
    Останавливает насос.
    }
    procedure Stop;
    //установка частоты вращения
    procedure SetPower(Value: Single);
    procedure SetFreq(const Value: Single);
    // 6 до 8 для модуля Valve).
    //прячем из публишед
    property EditValue;
    property ScrollBarPosition;
published
    property IONumber: Byte read FIONumber write SetIONumber default 0;

    property DACNumber: Byte read FDACNumber write SetDACNumber default 0;

    //с вохдными значениями - true InputValues соответствуют OutputValues
    property WithInput: Boolean read FWithInput write SetWithInput;

    property Started: Boolean read GetStarted write SetStarted;

    property StartCaption: String read GetStartCaption;

    property StopCaption: String read GetStopCaption;

    property ModuleTypeName: string read GetModuleTypeName;

    property Power: Single read GetPower write SetPower;

    property Frequency: Single read GetFreq write SetFreq;

    property CurrentFrequency: Single read GetCurrentFrequency; //0..50

    property MinInput: Single read GetMinI write SetMinI;

    property MaxInput: Single read GetMaxI write SetMaxI;

    property MinOutput: Single read GetMinO write SetMinO;

    property MaxOutput: Single read GetMaxO write SetMaxO;

    property DPort:Integer read GetDPort write SetDPort;

    property UPort:Integer read GetUPort write SetUPort;

    property DAddr:Integer read GetDAddr write SetDAddr;

    property UAddr:Integer read GetUAddr write SetUAddr;

    property DBaudrate:Integer read GetDBaudrate write SetDBaudrate;

    property UBaudrate:Integer read GetUBaudrate write SetUBaudrate;

    property DModuleType:TFmxModuleType read GetDModuleType write SetDModuleType;

    property UModuleType:TFmxModuleType read GetUModuleType write SetUModuleType;

    property DTypeOfProtocol:TTypeOfProtocol read GetDTypeOfProtocol write SetDTypeOfProtocol;

    property UTypeOfProtocol:TTypeOfProtocol read GetUTypeOfProtocol write SetUTypeOfProtocol;

    property DInputRegister:integer read GetDInputRegister write SetDInputRegister;

    property DOutputRegister:integer read GetDOutputRegister write SetDOutputRegister;

    property UInputRegister:integer read GetUInputRegister write SetUInputRegister;

    property UOutputRegister:integer read GetUOutputRegister write SetUOutputRegister;

    property ModuleManager: TFmxModuleManager read GetModuleManager;

    property OnUpdatePower:TNotifyEvent read FOnUpdatePower write SetOnUpdatePower;

    property ParityD:TComParity read GetParityD write SetParityD;

    property ParityU:TComParity read GetParityU write SetParityU;
  end;

procedure Register;

implementation

uses
  FmxFPColors,
  FMX.Text,
  SYNCOBJS, FmxHelper;

procedure TFmxPump.ReceiveResponse;
begin
  try
    if not Assigned(DeviceStartStop) then
    begin
      State:=fpsError;
      Exit;
    end;
    if not Assigned(DevicePower) then
    begin
      State:=fpsError;
      Exit;
    end;

    if DeviceStartStop.Disguise or DevicePower.Disguise then
    begin
      State:=fpsDisguise;
      Exit;
    end;

    if DeviceStartStop.ConnectIsOK and DevicePower.ConnectIsOK then
    begin
      if DeviceStartStop.Started then
        ButtonText := StopCaption
      else
        ButtonText := StartCaption;
      LED1Light :=Started;
      if not  (State in [fpsDisabled,fpsDisabledSelected]) then
         ButtonEnabled := true;
      if ControlsEnabled then
      begin
        if (Started) and (Power<>0) then State:=fpsEnabledSelected;
        if (not Started) or (Power=0) then State:=fpsEnabled;
        end
      else begin
        if (Started) and (Power<>0) then State:=fpsDisabledSelected;
        if (not Started) or (Power=0) then State:=fpsDisabled;
      end;
      if StylesData['positionbar.value'].asExtended<>CurrentFrequency then
      begin
        StylesData['positionbar.value']:=CurrentFrequency;
        //ScrollBarPosition:=CurrentFrequency;
      end;

    end
    else
    begin
      State:=fpsError;
      LED1Light :=false;
    end;
  except
  end;
end;




procedure TFmxPump.PositionEditChange;
var FValue:Single;
begin
  FValue:=EditValue;
  FPower := FValue*2;  //Частота
  ScrollBarPosition:=FValue; //Частота
  PowerScrollBarChange();
  DevicePower.ModuleManager.ExecuteInCOMThread(UpdatePower);
end;

procedure TFmxPump.PowerScrollBarChange;
var FValue:Single;
begin
  FValue:=ScrollBarPosition;
  if Power <> (FValue * 2) then
    Power := FValue * 2;
end;


procedure TFmxPump.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  case AIdx of
    0: begin
      if Assigned(DeviceStartStop) then
        if Assigned(DeviceStartStop.Module) then
          DeviceStartStop.Module.Address := Value;
    end;
    1: begin
      if Assigned(DevicePower) then
        if Assigned(DevicePower.Module) then
          DevicePower.Module.Address := Value;
    end;
  end;
end;

procedure TFmxPump.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  case AIdx of
    0: begin
      if Assigned(DeviceStartStop) then
        if Assigned(DeviceStartStop.Module) then
          DeviceStartStop.Module.BaudRate := Value;
    end;
    1: begin
      if Assigned(DevicePower) then
        if Assigned(DevicePower.Module) then
          DevicePower.Module.BaudRate := Value;
    end;
  end;
end;

procedure TFmxPump.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  case AIdx of
    0: begin
      if Assigned(DeviceStartStop) then
        if Assigned(DeviceStartStop.Module) then
          DeviceStartStop.Module.PortNumber := Value;
    end;
    1: begin
      if Assigned(DevicePower) then
        if Assigned(DevicePower.Module) then
          DevicePower.Module.PortNumber := Value;
    end;
  end;
end;

procedure TFmxPump.SetupPower(const Value: Single);
begin
  FPower:=Value;
  EditValue:=Value/2;
  ScrollBarPosition:=EditValue;
  if Assigned(DevicePower) then
  begin
     if Assigned(DevicePower.ModuleManager) then
     begin
        DevicePower.ModuleManager.ExecuteInCOMThread(UpdatePower);
     end;
  end;
end;

procedure TFmxPump.SetDACNumber(const Value: Byte);
begin
  FDACNumber := Value;
  if Assigned(DevicePower) then
    DevicePower.DAC_Number := Value;
end;

procedure TFmxPump.SetDAddr(const Value: Integer);
begin
   Address[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDBaudrate(const Value: Integer);
begin
   Baudrate[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDInputRegister(const Value: integer);
begin
   InputRegister[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDModuleType(const Value: TFmxModuleType);
begin
   ModuleType[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDOutputRegister(const Value: integer);
begin
   OutputRegister[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDPort(const Value: Integer);
begin
   Port[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetDTypeOfProtocol(const Value: TTypeOfProtocol);
begin
   TypeOfProtocol[cStartStopDeviceIndex]:=Value;
end;

procedure TFmxPump.SetFreq(const Value: Single);
begin
  { TODO -oНиколай -cError : Проверить на максимум частоты}
  Power:=Value*2;
end;

procedure TFmxPump.SetIONumber(const Value: Byte);
begin
  FIONumber := Value;
  if Assigned(DeviceStartStop) then
    if Assigned(DeviceStartStop.Module) then
      if (Value >= 1) and (Value <= 16) then
        DeviceStartStop.IONumber := Value;
end;

procedure TFmxPump.SetMax(const Value: Single);
begin
  Inherited;
  EditMax:=Value;
  ScrollBarPositionMax:=Value;
end;

procedure TFmxPump.SetMaxChannels(const Value: byte);
begin
  inherited;
  if Assigned(DeviceStartStop) then
     DeviceStartStop.MaxChannels:=Value;
end;

procedure TFmxPump.SetMaxI(const Value: Single);
begin
  if Assigned(DevicePower) then
    DevicePower.MaxInput := Value;
end;

procedure TFmxPump.SetMaxO(const Value: Single);
begin
  if Assigned(DevicePower) then
    DevicePower.MaxOutput := Value;
end;

procedure TFmxPump.SetMin(const Value: Single);
begin
    if Min<>Value then
    begin
      inherited;
      StylesData['scrollbar.max']:=50;//%
      StylesData['positionbar.max']:=50;//Гц
      StylesData['editvalue.max']:=50;//Гц
      StylesData['editvalue.min']:=Value;//Гц
      if Assigned(DevicePower) then
         DevicePower.MinFreq:=Round(Value);
    end;
end;

procedure TFmxPump.SetMinI(const Value: Single);
begin
  if Assigned(DevicePower) then
    DevicePower.MinInput := Value;
end;

procedure TFmxPump.SetMinO(const Value: Single);
begin
  if Assigned(DevicePower) then
    DevicePower.MinOutput := Value;
end;

procedure TFmxPump.SetModuleType(AIdx: integer; const Value: TFMXModuleType);
begin
  inherited;
  case AIdx of
    0: begin
      if Assigned(DeviceStartStop) then
        if Assigned(DeviceStartStop.Module) then
          DeviceStartStop.Module.ModuleType := Value;
    end;
    1: begin
      if Assigned(DevicePower) then
        if Assigned(DevicePower.Module) then
          DevicePower.Module.ModuleType := Value;
    end;
  end;
end;


procedure TFmxPump.SetOnUpdatePower(const Value: TNotifyEvent);
begin
  FOnUpdatePower := Value;
end;

procedure TFmxPump.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] := StrToIntDef(Value, Port[0]);
    3:
      Address[0] :=
        StrToIntDef(Value, Address[0]);
    4:
      BaudRate[0] := StrToIntDef(Value, 9600);
    5:
      ParityD:=StrToParity(Value);
    6:
      ModuleType[0] := StrToModuleType(Value);
    7:
      IONumber :=
        StrToIntDef(Value, IONumber+1)-1;
    8:
      Port[1] := StrToIntDef(Value, Port[1]);
    9:
      Address[1] :=
        StrToIntDef(Value, Address[1]);
    10:
      BaudRate[1] := StrToIntDef(Value, 9600);
    11:
      ParityU:=StrToParity(Value);
    12:
      ModuleType[1] := StrToModuleType(Value);
    13:
      DACNumber :=
        StrToIntDef(Value, DACNumber+1)-1;
    14:
      left :=StrToFloatDef(CP(Value), left)-ShiftL;
    15:
      top :=StrToFloatDef(CP(Value), top)-ShiftT;
    16:
      width :=StrToFloatDef(CP(Value), width);
    17:
      height :=StrToFloatDef(CP(Value), height);
    18:
      First := myStrToBool(Value);
    19:
      AFIdx := StrToIntDef(Value, 1);
    20:
      WithInput := myStrToBool(Value);
    21:
      Visible := myStrToBool(Value);
    22:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    23:
      DTypeOfProtocol := CheckProtocol(myStrToTypeOfProtocol(Value));
    24:
      UTypeOfProtocol := CheckProtocol(myStrToTypeOfProtocol(Value));
    25:
      InputRegister[0] := StrToIntDef(Value, 0);
    26:
      InputRegister[1] := StrToIntDef(Value, 0);
    27:
      OutputRegister[0] := StrToIntDef(Value, 0);
    28:
      OutputRegister[1] := StrToIntDef(Value, 0);
    29:
      MinInput := StrToFloatDef(CP(Value), MinInput);
    30:
      MaxInput := StrToFloatDef(CP(Value), MaxInput);
    31:
      MinOutput := StrToFloatDef(CP(Value), MinOutput);
    32:
      MaxOutput := StrToFloatDef(CP(Value), MaxOutput);
    33:
      Min:= StrToFloatDef(CP(Value), Min);
    34:
      Max:= StrToFloatDef(CP(Value), Max);
    35:
      ModulePriority := StrToIntDef(Value, 0);
  end;
end;

procedure TFmxPump.SetParityD(const Value: TComParity);
begin
  FParityD := Value;
  if Assigned(DeviceStartStop) then
     DeviceStartStop.Parity:=Value;
end;

procedure TFmxPump.SetParityU(const Value: TComParity);
begin
  FParityU := Value;
  if Assigned(DevicePower) then
     DevicePower.Parity:=Value;
end;

procedure TFmxPump.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(DevicePower) then
     DevicePower.ModulePriority:=Value;
  if Assigned(DeviceStartStop) then
     DeviceStartStop.ModulePriority:=Value;
end;

function TFmxPump.GetPriority: integer;
begin
  if Assigned(DevicePower) then
     result:=DevicePower.ModulePriority
  else if Assigned(DeviceStartStop) then
     result:=DeviceStartStop.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxPump.UpdatePower;
begin
  if Assigned(DevicePower) then
  begin
    if Round(DevicePower.Power * 100) <> Round(FPower * 100) then
    begin
      DevicePower.DAC_Number := DACNumber;
      DevicePower.Power := Power;
    end;
  end;
end;

procedure TFmxPump.SetPower(Value: Single);
begin
  FPower:=Value;
  if Assigned(DevicePower) then
    SetupPower(Value);
end;

procedure TFmxPump.SetStarted(const Value: Boolean);
begin
  if Assigned(DeviceStartStop) then
    DeviceStartStop.Started := Value;
end;



procedure TFmxPump.SetUAddr(const Value: Integer);
begin
   Address[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUBaudrate(const Value: Integer);
begin
   Baudrate[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUInputRegister(const Value: integer);
begin
   InputRegister[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUModuleType(const Value: TFmxModuleType);
begin
   ModuleType[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUOutputRegister(const Value: integer);
begin
   OutputRegister[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUPort(const Value: Integer);
begin
   Port[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetUTypeOfProtocol(const Value: TTypeOfProtocol);
begin
   TypeOfProtocol[cPowerDeviceIndex]:=Value;
end;

procedure TFmxPump.SetWithInput(const Value: Boolean);
begin
  FWithInput := Value;
  if Assigned(DeviceStartStop) then
    DeviceStartStop.WithInput := Value;
end;


procedure TFmxPump.Start;
begin
  Started := True;
  try
    if Assigned(DeviceStartStop) then
      DeviceStartStop.StartPump;
    if Assigned(CriticalSection) then
    begin
      CriticalSection.Enter;
      if PumpsOpened < 255 then
        Inc(PumpsOpened);
      CriticalSection.Leave;
    end;
  finally
  end;
end;


procedure TFmxPump.StartStopButtonClick(Sender: TObject);
begin
  ButtonEnabled := False;
//  PowerScrollBar.Enabled := False;
  if Assigned(DeviceStartStop) then
  begin
    if DeviceStartStop.Started then
    begin
      //PositionEdit.Enabled := False;
      DeviceStartStop.ModuleManager.ExecuteInCOMThread(Stop);
      Started := False;
    end
    else begin
        if (aftAskingBeforExec in AFTypeSet) then
        begin
          if DialogYesNo('Вы действительно хотите включить ' + Caption + '?') then
            begin
              if Assigned(DeviceStartStop.AddToWorkLogProc) then
                 DeviceStartStop.AddToWorkLogProc('Пользователь в ручном режиме включил ' + Caption);
              //PositionEdit.Enabled := False;
              DeviceStartStop.ModuleManager.ExecuteInCOMThread(Start);
              Started := True;
            end;
        end//if (aftAskingBeforExec in AFTypeSet)
        else
            DeviceStartStop.ModuleManager.ExecuteInCOMThread(Start);
    end;//else begin
  end;//if Assigned(DeviceStartStop) then
end;

procedure TFmxPump.Stop;
begin
  Started := False;
  try
    if Assigned(DeviceStartStop) then
      DeviceStartStop.StopPump;
    if Assigned(CriticalSection) then
    begin
      CriticalSection.Enter;
      if PumpsOpened > 0 then
        Dec(PumpsOpened);
      CriticalSection.Leave;
    end;
  finally
  end;
end;


procedure TFmxPump.Loaded;
begin
  inherited;
  if (not (csDesigning in ComponentState)) and (DeviceStartStop = nil) then begin
    if not (ModuleType[0] in [mtVLT6000, mtATV312, mtBIO, mtHSC_CTRL, mtSuperBIO, mtValve, mtRT2, mtVLTModbus, mtLogoDAC, mtVaconModbus, mtModbusD,mtABBModbus,mtDeltaModbus]) then
      ModuleType[0] := mtVLT6000;
    if not (ModuleType[1] in [mtVLT6000, mtATV312, mtDAC_I702X, mtHSC_CTRL, mtRT2, mtVLTModbus, mtLogoDAC, mtVaconModbus, mtModbusA,mtDeltaModbus,mtABBModbus]) then
      ModuleType[1] := mtVLT6000;

    DeviceStartStop := TFmxDevicePumpStartStop.CreateOnModule(ModbusTCPHost, ModbusTCPPort, Port[0], Address[0], BaudRate[0], FIONumber, ModuleType[0], TypeOfProtocol[0], InputRegister[0], OutputRegister[0]);
    DeviceStartStop.AddReceiver(ReceiveResponse);

    DevicePower := TFmxDevicePumpPower.CreateOnModule(ModbusTCPHost, ModbusTCPPort, Port[1], Address[1], BaudRate[1], FDACNumber, ModuleType[1], TypeOfProtocol[1], InputRegister[1], OutputRegister[1]);
    DevicePower.AddReceiver(ReceiveResponse);
  end;
  if CriticalSection = nil then
    CriticalSection := TCriticalSection.Create;
end;

procedure TFmxPump.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited MouseMove(Shift, X, Y);
  SetFocus;
end;


constructor TFmxPump.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DeviceStartStop := nil;
  DevicePower := nil;
  StyleLookup:=cPumpStyle;
  ControlType:=ctPump;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Насос '+IntToStr(FIdx+1);
  ModuleType[0] := mtVLT6000;
  Address[0] := 1;
  BaudRate[0] := 9600;
  ModuleType[1] := mtVLT6000;
  Address[1] := 1;
  BaudRate[1] := 9600;
  WithInput:=False;
  Height := 81;
  Width := 112;
  LedsCount:=1;
  LED1ONColor:=CL_FMX_GREEN;
  LED1OFFColor:=CL_FMX_RED;
  LED1Light:=False;
  Min:=0;
  Max:=cMaxPower div 2;
  EditMax:=Max;
  EditMin:=Min;
  ScrollBarPositionMax:=Max;
  ScrollBarPositionMin:=Min;
  ScrollVsEdit:=1;//Все в частоте
  ButtonText:=StartCaption;
  ValueType:=TNumValueType.Float;
  DecimalDigits:=2;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
end;


destructor TFmxPump.Destroy;
begin
  if CriticalSection <> nil then
  begin
    CriticalSection.Free;
    CriticalSection := nil;
  end;
  inherited Destroy;
end;

function TFmxPump.Disguise: Boolean;
begin
  if Assigned(DevicePower) and Assigned(DeviceStartStop) then
    Result := (DevicePower.Disguise or DeviceStartStop.Disguise)
  else
    Result := False;
end;


procedure TFmxPump.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnEdit: begin
      //Пользователь выставил частоту в TEdit
      PositionEditChange();
      end;
    ccnTrackBar: begin
      //Пользователь выставил частоту в TTrackBar
      PowerScrollBarChange();
    end;
    ccnStartStopButton: begin
      //Пользователь нажал кнопку стартстоп
      //LED1Light:=not LED1Light;
      StartStopButtonClick(self);
//      if not LED1Light then
//         ButtonText:=StartCaption
//      else
//         ButtonText:=StopCaption;
    end;
    ccnOpenButton:begin
      //Пользователь шагово прибавил мощность
      if Power<cMaxPower then
         Power:=Power+cDeltaPower;
    end;
    ccnCloseButton: begin
      //Пользователь шагово убавил мощность
      if Power<cMaxPower then
         Power:=Power-cDeltaPower;
    end;
  end;
  CCN:=ccnNone;

end;

procedure TFmxPump.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cFlowPumpPropertyCount);
   for i := 0 to cFlowPumpPropertyCount-1 do
   begin
     FParameters[i].Name:=cFlowPumpPropertys[i]; //Наименование
     FParameters[i].ParamType:=cFlowPumpPropertysType[i];//тип
     FParameters[i].Items:=cFlowPumpPropertyComboItems[i];
   end;
end;




function TFmxPump.GetMaxChannels: byte;
begin
  if Assigned(DeviceStartStop) then
     result:=DeviceStartStop.MaxChannels
  else
     inherited;
end;

function TFmxPump.GetMaxI: Single;
begin
  if Assigned(DevicePower) then
    Result := DevicePower.MaxInput
  else
    Result := 0;
end;

function TFmxPump.GetMaxO: Single;
begin
  if Assigned(DevicePower) then
    Result := DevicePower.MaxOutput
  else
    Result := 0;
end;

function TFmxPump.GetMin: Single;
begin
  if Assigned(DevicePower) then
     result:=DevicePower.MinFreq
  else
     result:=Inherited;
end;

function TFmxPump.GetMinI: Single;
begin
  if Assigned(DevicePower) then
    Result := DevicePower.MinInput
  else
    Result := 0;
end;

function TFmxPump.GetMinO: Single;
begin
  if Assigned(DevicePower) then
    Result := DevicePower.MinOutput
  else
    Result := 0;
end;

function TFmxPump.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(DevicePower) then
     result:=DevicePower.ModuleManager
  else
     result:=nil;
end;

function TFmxPump.GetModuleTypeName: string;
begin
  Result := '???';
  if Assigned(DeviceStartStop) then
    Result := DeviceStartStop.ModuleTypeName;
  if Assigned(DevicePower) and Assigned(DeviceStartStop) then
    if DevicePower.ModuleType <> DeviceStartStop.ModuleType then
      Result := Result + ':' + DevicePower.ModuleTypeName;
end;

function TFmxPump.GetParamValue(Row: integer): String;
begin
  case Row of
    0:
      result := Caption;
    1:
      result := Hint;
    2:
      result := IntToStr(Port[0]);
    3:
      result := IntToStr(Address[0]);
    4:
      result := IntToStr(BaudRate[0]);
    5:
      result:=cComParityName[ParityD];
    6:
      result := cModuleTypeNames[ModuleType[0]];
    7:
      result := IntToStr(IONumber+1);

    8:
      result := IntToStr(Port[1]);
    9:
      result := IntToStr(Address[1]);
    10:
      result := IntToStr(BaudRate[1]);
    11:
      result:=cComParityName[ParityU];
    12:
      result := cModuleTypeNames[ModuleType[1]];
    13:
      result := IntToStr(DACNumber+1);

    14:
      result := FloatToStr(left+ShiftL);
    15:
      result := FloatToStr(top+ShiftT);
    16:
      result := FloatToStr(width);
    17:
      result := FloatToStr(height);
    18:
      result := cBooleanName[Boolean(First)];
    19:
      result := IntToStr(AFIdx);
    20:
      result := cBooleanName[Boolean(WithInput)];
    21:
      result := cBooleanName[Visible];
    22:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    23:
      result := cTypeOfProtocols[CheckProtocol(DTypeOfProtocol)];
    24:
      result := cTypeOfProtocols[CheckProtocol(UTypeOfProtocol)];
    25:
      result := IntToStr(InputRegister[0]);
    26:
      result := IntToStr(InputRegister[1]);
    27:
      result := IntToStr(OutputRegister[0]);
    28:
      result := IntToStr(OutputRegister[1]);
    29:
      result := FloatToStrF(MinInput, ffFixed, 15, 5);
    30:
      result := FloatToStrF(MaxInput, ffFixed, 15, 5);
    31:
      result := FloatToStrF(MinOutput, ffFixed, 15, 5);
    32:
      result := FloatToStrF(MaxOutput, ffFixed, 15, 5);
    33:
      result := IntToStr(Round(Min));
    34:
      result := IntToStr(Round(Max));
    35:
      result := IntToStr(ModulePriority);
  end;
end;

function TFmxPump.GetParityD: TComParity;
begin
  if not (FParityD in [cpNone..cpSpace]) then
     FParityD:=cpNone;
  result:=FParityD;
end;

function TFmxPump.GetParityU: TComParity;
begin
  if not (FParityU in [cpNone..cpSpace]) then
     FParityU:=cpNone;
  result:=FParityU;
end;

function TFmxPump.GetPower: Single;
begin
  Result:=FPower;
end;

function TFmxPump.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 10];
end;

function TFmxPump.GetStartCaption: String;
begin
   Result := 'пуск';
end;

function TFmxPump.GetStarted: Boolean;
begin
  if Assigned(DeviceStartStop) then
    Result := DeviceStartStop.Started
  else
    Result := False;
end;

function TFmxPump.GetCurrentFrequency: Single;
begin
  if Assigned(DevicePower) then
     result:=DevicePower.CurrentFrequency
  else
     result:=0;
end;

function TFmxPump.GetCurState: String;
begin
  Result := inherited;
  if Assigned(DevicePower) then
    Result := Result + Format(': %s, [%f Гц]', [ButtonText, DevicePower.CurrentFrequency]);
end;

function TFmxPump.GetDAddr: Integer;
begin
   result:=Address[cStartStopDeviceIndex];
end;

function TFmxPump.GetDBaudrate: Integer;
begin
   result:=Baudrate[cStartStopDeviceIndex];
end;

function TFmxPump.GetDInputRegister: integer;
begin
   result:=InputRegister[cStartStopDeviceIndex];
end;

function TFmxPump.GetDModuleType: TFmxModuleType;
begin
   result:=ModuleType[cStartStopDeviceIndex];
end;

function TFmxPump.GetDOutputRegister: integer;
begin
   result:=OutputRegister[cStartStopDeviceIndex];
end;

function TFmxPump.GetDPort: Integer;
begin
   result:=Port[cStartStopDeviceIndex];
end;

function TFmxPump.GetDTypeOfProtocol: TTypeOfProtocol;
begin
   result:=TypeOfProtocol[cStartStopDeviceIndex];
end;

function TFmxPump.GetFreq: Single;
begin
  Result:=FPower/2;
end;

function TFmxPump.GetStopCaption: String;
begin
//  if StartStopButton.Visible then
//    Result := 'стоп  '
//  else
    Result := 'стоп';
end;


function TFmxPump.GetUAddr: Integer;
begin
   result:=Address[cPowerDeviceIndex];
end;

function TFmxPump.GetUBaudrate: Integer;
begin
   result:=Baudrate[cPowerDeviceIndex];
end;

function TFmxPump.GetUInputRegister: integer;
begin
   result:=InputRegister[cPowerDeviceIndex];
end;

function TFmxPump.GetUModuleType: TFmxModuleType;
begin
   result:=ModuleType[cPowerDeviceIndex];
end;

function TFmxPump.GetUOutputRegister: integer;
begin
   result:=OutputRegister[cPowerDeviceIndex];
end;

function TFmxPump.GetUPort: Integer;
begin
   result:=Port[cPowerDeviceIndex];
end;

function TFmxPump.GetUTypeOfProtocol: TTypeOfProtocol;
begin
   result:=TypeOfProtocol[cPowerDeviceIndex];
end;



procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxPump]);
end;

end.

