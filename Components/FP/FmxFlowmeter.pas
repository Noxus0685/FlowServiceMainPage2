unit FmxFlowmeter;

{ ===== Компонент FmxFlowmeter =====
Визуальный компонент эталонного расходомера
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  System.UITypes,//TMouseButton
  FmxParamsFrm,//Форма ручного ввода параметров
  //System.Types,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;



type
  TFlowmeterParams=(fpFreq,fpImpCount,fpTime);
const
  cFlowmeterStyle='flowmeterstyle';

  //Количество свойств
  cFlowmeterPropertyCount=27;

  //Наименования свойств
  cFlowmeterPropertys:array[0..cFlowmeterPropertyCount-1]of string=(
    cHeader,cHint,
    cPort,cAddress,cBaudrate,
    cParity,
    cModuleType,
    cLeft,cTop,cWidth,cHeight,
    cNumAppFunction,cActive,cEdIzm,
    cFirst,cVisible,cDigits,cNumChannel,cNumCounters,cFlowmeterMin,cFlowmeterMax,
    cFlowmeterMassCounter,cTypeAppFunc,
    cTypeOfProtocol,
    cModbusInputReg,cTypeOfInput,cModulePriority);

  //типы свойств
  cFlowmeterPropertysType:array[0..cFlowmeterPropertyCount-1]of TParameterType=(
  //  cHeader,cHint
      ptText,ptText,
  //  cPort,   cAddress,cBaudrate,cParity,
      ptNumber,ptNumber,ptNumber,ptComboBox,
  //  cModuleType,
      ptComboBox,
  //cLeft,cTop,cWidth,cHeight,
      ptNumber,ptNumber,ptNumber,ptNumber,
  //  cNumAppFunction,cActive,cEdIzm,
      ptNumber,  ptComboBox,  ptText,
  //  cFirst,cVisible,cDigits,cNumChannel,cNumCounters,cFlowmeterMin,cFlowmeterMax,
      ptComboBox, ptComboBox, ptNumber,ptNumber,ptNumber,ptFloat,ptFloat,
  //    cFlowmeterMassCounter,cTypeAppFunc,
      ptComboBox,ptComboBox,
  //  cTypeOfProtocol,
      ptComboBox,
  //cModbusInputReg,cModbusOutputReg,cModulePriority
      ptNumber,  ptNumber,  ptNumber
  );

  //Комбо выпадающие списки
  cFlowmeterPropertyComboItems: array[0..cFlowmeterPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [сmtManual,cmtHSC_IMP,cmtCounterEx,сmtCounter],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cNumAppFunction,cActive,cEdIzm,
    [],[cNo,cYes],[],
//  cFirst,cVisible,cDigits,cNumChannel,cNumCounters,cFlowmeterMin,cFlowmeterMax,
    [cNo,cYes],[cNo,cYes],[],[],[],[],[],
//  cFlowmeterMassCounter,cTypeAppFunc,
    [cNo,cYes],[cNumber,cMask],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModbusOutputReg,cModulePriority
    [],[],[]
    );

  cFlowmeterParamsCount=3;
  cFlowmeterParams:array[TFlowmeterParams]of string=(cFreqHeader,cImpHeader,cTimeHeader);
  cFlowmeterParamsWritable:array[TFlowmeterParams]of boolean=(True,True,True);


type
  TFmxFlowmeter = class(TFMXDeviceCustomControl)
  private
    FPairNumber:byte;
    FDevice:array[1..4] of TFmxDeviceFlowmeter;
    FSelected: Boolean;
    FOnSelect: TNotifyEvent;
    FMassCounter: Boolean;
    FfrmParams: TfrmParams;
    FCounters: Byte;
    FDisplay: boolean;
    FUsePriority: boolean;
    FPrimary: Boolean;
    FTypeOfInput: Byte;
    FUnitPriority: boolean;
    FMasterMode: boolean;
    procedure Select;
    function GetDevice(Idx: integer): TFmxDeviceFlowmeter;
    procedure SetDevice(Idx: integer; const Value: TFmxDeviceFlowmeter);
    procedure LoadParamValues;
    procedure StoreParamValues;
    function GetSelected: boolean;
    procedure SetOnSelect(const Value: TNotifyEvent);
    procedure SetSelected(const Value: boolean);
    procedure SetMassCounter(const Value: Boolean);
    procedure SetfrmParams(const Value: TfrmParams);
    function GetValue: Double;
    function GetManualEnter: Boolean;
    procedure SetCounters(const Value: Byte);
    function GetPairNumber: integer;
    function GetSpillTime: Single;
    function GetVersion: String;
    procedure SetDisplay(const Value: boolean);
    procedure SetPairNumber(const Value: integer);
    procedure SetTypeOfInput(const Value: Byte);
    procedure SetUsePriority(const Value: boolean);
    procedure SetUnitPriority(const Value: boolean);
//    function GetVolumeFromSlaves(SlaveNum: integer): Double;
    procedure SetMasterMode(const Value: boolean);
    function GetCountIsStarted: Boolean;
    function GetProtocolID: word;
  protected

    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    function GetPriority: integer;override;
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);override;
    function GetModuleManager: TFmxModuleManager;override;
    procedure SetComPort(AIdx: integer; const Value: word); override;
    procedure SetAddress(AIdx: Integer; const Value: Integer); override;
    procedure SetBaudrate(AIdx: Integer; const Value: Cardinal); override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType); override;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function Disguise: Boolean; override;
    procedure SetParity(const Value: TComParity);override;
    procedure UpdateStyle;override;
    function GetCurState: String; override;
  public
    // Указатель на устройство включающиее и выключающее насос
    property Device[Idx:integer]: TFmxDeviceFlowmeter read GetDevice write SetDevice;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList;override;
    procedure UpdateVolumes;
    procedure UpdateWaterDischarges;
    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;
    procedure CopyStoredToCurrentSettings;
    procedure Update;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
  public
//    property VolumeFromSlaves[SlaveNum:integer]:Double read GetVolumeFromSlaves;
    property CountIsStarted:Boolean read GetCountIsStarted;
  published
    // Флаг использования первичного канала в паре эталонных расходомеров модуля, на котором висит расходомер.
    property Primary: Boolean read FPrimary write FPrimary default true;

    property PairNumber:integer read GetPairNumber write SetPairNumber;

    property OnSelect:TNotifyEvent read FOnSelect write SetOnSelect;

    property Selected:boolean read GetSelected write SetSelected;

    property SpillTime:Single read GetSpillTime;

    property Version:String read GetVersion;

    //количество каналов поверяемых  счетчиков - это количество говорит, сколько модулей будет подключено к данному расходомеру
    property Counters:Byte read FCounters write SetCounters;
    // Флаг полной формы компонента (со значением текущей частоты).
    property ManualEnter:Boolean read GetManualEnter;

    property UsePriority:boolean read FUsePriority write SetUsePriority;

    property Display:boolean read FDisplay write SetDisplay;

    property MassCounter:Boolean read FMassCounter write SetMassCounter;

    property TypeOfInput:Byte read FTypeOfInput write SetTypeOfInput;

    property frmParams: TfrmParams read FfrmParams write SetfrmParams;

    property WaterDischarge:Double read GetValue;

    property UnitPriority:boolean read FUnitPriority write SetUnitPriority;

    property OnClick;

    property MasterMode:boolean read FMasterMode write SetMasterMode;

    property ProtocolID:word read GetProtocolID;
  end;
//============================================================================================================

procedure Register;
function StrToOutlayType(volume:Boolean;Value:String):TOutlayType;

implementation

uses FmxFPColors,
     FmxFPModules,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     fmxkbdhelper,
     System.Rtti;

function StrToOutlayType(volume:Boolean;Value:String):TOutlayType;
var i:TOutlayType;
begin
   result:=otCubeMeterPerHour;
   for I := otCubeMeterPerHour to otLiterPerSecond do
   begin
     if Volume then
     begin
       if cOutlayTypeNameVolume[I]=Value then
       begin
         result:=I;
         break;
       end;
     end
     else begin
       if cOutlayTypeNameMassa[I]=Value then
       begin
         result:=I;
         break;
       end;
     end;
   end;
end;


{ TFmxFlowmeter }

procedure TFmxFlowmeter.StoreParamValues;
begin
  if Assigned(frmParams) then
   begin
      Device[1].Frequency:=frmParams.ParamsValue[ord(fpFreq)];
      //Device[1].WaterDischarge
      Device[1].Impulse:=Round(frmParams.ParamsValue[ord(fpImpCount)]);
      //Device[1].VolumeOrMassa вычисляется по количеству импульсов и цене одного импульса
      Device[1].StartStopTime:=frmParams.ParamsValue[ord(fpTime)];
      ReceiveResponse;
   end;
end;


destructor TFmxFlowmeter.Destroy;
begin
  if Assigned(frmParams) then
     FreeAndNil(frmParams);
  inherited;
end;


function TFmxFlowmeter.Disguise: Boolean;
var i:Integer;
begin
  result:=inherited;
  for i:=1 to 4 do
  begin
     if Assigned(Device[i]) then
        if Device[i].Disguise then
        begin
           result:=True;
           Break;
        end;
  end;
end;

procedure TFmxFlowmeter.DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
   inherited;
   if (csDesigning in ComponentState) then Exit;
   if DesignMode then
   begin
     DoOnClick(Sender);
   end
   else
     if Button = TMouseButton.mbRight then
        Full:=not Full
     else begin
        if not CtrlDown then
          Selected:=not Selected;
        if Assigned(Device[1]) then
        begin
          if not ManualEnter then
             Device[1].ModuleManager.ExecuteInCOMThread(Select)
          else begin
             //Иначе вызываем диалоговое окно настройки значений параметров
             if CtrlDown and Assigned(frmParams) then
             begin
               LoadParamValues();
               if frmParams.ShowModal=mrOk then
                 StoreParamValues();
             end;
          end;
        end;
     end;
  if Assigned(OnMouseDown) then
     OnMouseDown(self,Button,Shift,X, Y);
end;


procedure TFmxFlowmeter.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cFlowmeterPropertyCount);
   for i := 0 to cFlowmeterPropertyCount-1 do
   begin
     FParameters[i].Name:=cFlowmeterPropertys[i]; //Наименование
     FParameters[i].ParamType:=cFlowmeterPropertysType[i];//тип
     FParameters[i].Items:=cFlowmeterPropertyComboItems[i];
   end;
end;

procedure TFmxFlowmeter.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) )  then
  begin
   if not (ModuleType[0] in [mtManual,mtHSC_IMP,mtCounterEx,mtCounter]) then
      ModuleType[0]:=mtHSC_IMP;

   if ModuleType[0] = mtCounterEx then
   begin
     if not (Counters in [1..32]) then Counters:=8;
     try
      if (Counters in [1..32]) and (Device[1]=nil) then
      begin
        Device[1] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[1].AddReceiver(ReceiveResponse);
      end;
      if (Counters in [9..32]) and (Device[2]=nil) then
      begin
        Device[2] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0]+1,BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[2].AddReceiver(ReceiveResponse);
      end;
      if (Counters in [17..32]) and (Device[3]=nil) then
      begin
        Device[3] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0]+2,BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[3].AddReceiver(ReceiveResponse);
      end;
      if (Counters in [25..32]) and (Device[4]=nil) then
      begin
        Device[4] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0]+3,BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[4].AddReceiver(ReceiveResponse);
      end;

     finally

     end;
   end
   else if ModuleType[0] = mtHSC_IMP then
   begin
      if not (Counters in [1..cHSC_IMP_Max_ChannelNumber+1]) then Counters:=cHSC_IMP_Max_ChannelNumber+1;
      if (Counters in [1..cHSC_IMP_Max_ChannelNumber+1]) and (Device[1]=nil) then
      begin
        Device[1] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[1].AddReceiver(ReceiveResponse);
      end;
   end
   else if ModuleType[0] = mtCounter then
   begin
      if not (Counters in [1..8]) then Counters:=8;
      if (Counters in [1..8]) and (Device[1]=nil) then
      begin
        Device[1] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
        Device[1].AddReceiver(ReceiveResponse);
      end;
   end
   else if ModuleType[0] = mtManual then
   begin
      Device[1] := TFmxDeviceFlowmeter.CreateOnModuleCounter(ModbusTCPHost,ModbusTCPPort,Port[0],Address[0],BaudRate[0], AFIdx, Primary,ModuleType[0],TypeOfProtocol[0],InputRegister[0],OutputRegister[0]);
      Device[1].AddReceiver(ReceiveResponse);
   end;
  end;
end;

//procedure TFmxFlowmeter.DoOnClick(Sender: TObject);
//begin
//
//end;

procedure TFmxFlowmeter.LoadParamValues;
var i:Integer;
begin
  if Assigned(frmParams) then
   begin
      for i:=0 to cFlowmeterParamsCount-1 do
      begin
        frmParams.ParamsWritable[i]:=cFlowmeterParamsWritable[TFlowmeterParams(i)];
        frmParams.ParamsName[i]:=cFlowmeterParams[TFlowmeterParams(i)];
      end;
      frmParams.Caption:=cManualEnter+Caption;
      frmParams.ParamsValue[ord(fpFreq)]:=Device[1].Frequency;
      frmParams.ParamsValue[ord(fpImpCount)]:=Device[1].Impulse;
      frmParams.ParamsValue[ord(fpTime)]:=Device[1].StartStopTime;
   end;
end;



procedure TFmxFlowmeter.ReceiveResponse;
begin
  if Assigned(Device[1]) then Update;
end;

function TFmxFlowmeter.GetCountIsStarted: Boolean;
var i:Integer;
begin
  result:=False;
  for i:=1 to 4 do
  begin
     if Assigned(Device[i]) then
     begin
         result:=Device[i].CountIsStarted;
         Break;
     end;
  end;
end;

function TFmxFlowmeter.GetCurState: String;
var i:integer;
begin
  result:=inherited;
  begin
  for i:=1 to 4 do
    if Assigned(Device[I]) then
     begin
       if MassCounter then
         result:=result+Format(': %f Гц, %f т/ч, %f имп, %f кг, k=%f',[Device[i].Frequency,Device[i].WaterDischarge,
                                                 Device[i].Impulse,Device[i].VolumeOrMassa,Device[i].CurrentKoeff])
       else
         result:=result+Format(': %f Гц, %f м3/ч, %f имп, %f л, k=%f',[Device[i].Frequency,Device[i].WaterDischarge,
                                                 Device[i].Impulse,Device[i].VolumeOrMassa,Device[i].CurrentKoeff])
     end;
  end;
end;

function TFmxFlowmeter.GetDevice(Idx: integer): TFmxDeviceFlowmeter;
begin
  if Idx in [1..4] then
     result:=FDevice[Idx]
  else
     result:=nil;
end;

function TFmxFlowmeter.GetManualEnter: Boolean;
begin
     result:=ModuleType[0]=mtManual
end;

function TFmxFlowmeter.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device[1]) then
     result:=Device[1].ModuleManager
  else
     result:=nil;
end;

function TFmxFlowmeter.GetPairNumber: integer;
begin
  result:=FPairNumber;
end;

function TFmxFlowmeter.GetParamValue(Row: integer): String;
begin
  case Row of
    0:
      result := Caption; // 'Заголовок'
    1:
      result := Hint; // 'Подсказка'
    2:
      result := IntToStr(Port[0]);
    3:
      result := IntToStr(Address[0]);
    4:
      result := IntToStr(BaudRate[0]); // 'Скорость'

    5:
      result:=cComParityName[Parity];
    6:
      result := cModuleTypeNames[ModuleType[0]];
      // 'Тип модуля'

    7:
      result := FloatToStr(left+ShiftL);
    8:
      result := FloatToStr(top+ShiftT);
    9:
      result := FloatToStr(width);
    10:
      result := FloatToStr(height);
    11:
      result := IntToStr(AFIdx); // 'Номер'
    12:
      result := cBooleanName[Primary];
      // 'Активность'
    13:
      if MassCounter then
      begin
        result := cOutlayTypeNameMassa
          [Device[1].current_Settings.OutlayType];
      end
      else
      begin
        result := cOutlayTypeNameVolume
          [Device[1].current_Settings.OutlayType];
      end;
      // 'Ед.измерения'
    14:
      result := cBooleanName[First];
    15:
      result := cBooleanName[Visible];
    16:
      result := IntToStr(DecimalDigits);
    17:
      result := IntToStr(PairNumber+1);
    18:
      result := IntToStr(Counters);
    19:
      result := Format('%8.5f',[Min]);
    20:
      result := Format('%8.5f',[Max]);
    21:
      result := cBooleanName[MassCounter];
    22:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    23:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    24:
      result := IntToStr(InputRegister[0]);
    25:
      result := IntToStr(TypeOfInput);
    26:
      result := IntToStr(ModulePriority);
  end;
end;


function TFmxFlowmeter.GetRebootWarning(Row: integer): Boolean;
begin
  result:=Row in [2 .. 5];
end;

function TFmxFlowmeter.GetSelected: boolean;
begin
     result:=FSelected;
end;

function TFmxFlowmeter.GetSpillTime: Single;
begin
  //возвращаем время проливки - расчитанное контроллером счетчиков
    if Assigned(device[1]) then
       result:=device[1].StartStopTime
    else
       result:=10;
end;

function TFmxFlowmeter.GetValue: Double;
begin
  if Assigned(Device[1]) then
     result:=Device[1].WaterDischarge
  else
     result:=0;
end;

function TFmxFlowmeter.GetVersion: String;
begin
   if Assigned(Device[1]) then
      result:=Device[1].Version
   else
      result:='???';
end;

//function TFmxFlowmeter.GetVolumeFromSlaves(SlaveNum: integer): Double;
//var num_module,num_cnl:integer;
//begin
//  if Counters>0 then
//  begin
//    num_module:=(SlaveNum div Counters)+1;
//    num_cnl:=(SlaveNum mod Counters);
//  end
//  else begin
//    num_module:=1;
//    num_cnl:=SlaveNum mod 15;
//  end;
//  if Assigned(Device[num_module]) then
//     result:=Device[num_module].VolumesFromSlave[num_cnl]
//  else
//     result:=0;
//end;

procedure TFmxFlowmeter.CopyStoredToCurrentSettings;
var i:integer;
begin
  ODS(PChar('Flowmeter:'+IntToStr(self.FPairNumber)+' - CopyStoredToCurrentSettings'));
  for i:=1 to 4 do
    if Assigned(Device[i]) then
    begin
       Device[i].current_settings:=Device[i].stored_settings;
    end;
end;

constructor TFmxFlowmeter.Create(AOwner: TComponent);
  var i:integer;
begin
  inherited Create(AOwner);
  for i:=1 to 4 do
      Device[i] := nil;
  UnitPriority:=True;//TODO - Пока не используем это свойство
  FfrmParams := nil; //форма для ручного ввода
  StyleLookup:=cFlowmeterStyle;
  ControlType:=ctFlowmter;
  ModuleType[0]:=mtCounter;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Расходомер '+IntToStr(FIdx+1);
  FSelected:=True;
  ShortHeight:=55;
  LongHeight:=90;
  Height := ShortHeight;
  Width := 120;
  ValueMask:='';
  DecimalDigits := 2;
  StylesData['middle_rowstyle.visible']:=False;
  StylesData['bottom_rowstyle.visible']:=False;
  HitTest:=True;
  AutoCapture:=True;
  OnMouseDown:=DoOnMouseDown;
  LedON[TLeds(0)]:=TAlphaColorRec.Green;
  LedOFF[TLeds(0)]:=TAlphaColorRec.Silver;
  LedON[TLeds(1)]:=TAlphaColorRec.Red;
  LedOFF[TLeds(1)]:=TAlphaColorRec.Silver;
  LedsCount:=1;
  LedVisible:=True;
  StylesData['mainbody.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  Full:=False;
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;

//  OnClick:=DoOnClick;
  frmParams:=TfrmParams.Create(self);
  frmParams.ParamsCount:=cFlowmeterParamsCount;
end;



procedure TFmxFlowmeter.Select;
var i:Integer;
begin
  Active:=Selected;
  for i:=1 to 4 do
    if  Assigned(Device[i]) then
    begin
      if not Selected then
        Device[i].UnSelect
      else
        Device[i].Select;
    end;
  if Assigned(FOnSelect) then OnSelect(self);
  Update;
end;

procedure TFmxFlowmeter.SetAddress(AIdx: Integer; const Value: Integer);
var i:integer;
begin
  for i:=1 to 4 do
  begin
    inherited;
    if Assigned(Device[i]) then
    begin
      if Assigned(Device[i].Module) then
         Device[i].Module.Address:=Value+(i-1);
    end;
  end;
end;

procedure TFmxFlowmeter.SetBaudrate(AIdx: Integer; const Value: Cardinal);
var i:integer;
begin
  for i:=1 to 4 do
  begin
    inherited;
    if Assigned(Device[i]) then
    begin
      if Assigned(Device[i].Module) then
       Device[i].Module.BaudRate:=Value;
    end;
  end;
end;

procedure TFmxFlowmeter.SetComPort(AIdx: integer; const Value: word);
var i:integer;
begin
  for i:=1 to 4 do
  begin
  inherited;
    if Assigned(Device[i]) then
    begin
      if Assigned(Device[i].Module) then
       Device[i].Module.PortNumber:=Value;
    end;
  end;
end;

procedure TFmxFlowmeter.SetCounters(const Value: Byte);
begin
  FCounters := Value;
end;

procedure TFmxFlowmeter.SetDevice(Idx: integer;
  const Value: TFmxDeviceFlowmeter);
begin
  if Idx in [1..4] then
     FDevice[Idx]:=Value;
end;

procedure TFmxFlowmeter.SetDisplay(const Value: boolean);
begin
  FDisplay := Value;
end;

procedure TFmxFlowmeter.SetfrmParams(const Value: TfrmParams);
begin
  FfrmParams := Value;
end;

procedure TFmxFlowmeter.SetMassCounter(const Value: Boolean);
begin
  FMassCounter := Value;
end;


procedure TFmxFlowmeter.SetMasterMode(const Value: boolean);
var i:integer;
begin
  FMasterMode := Value;
  for i:=1 to 4 do
  begin
    if Assigned(Device[i]) then
    begin
       if Device[i].ModuleType=mtHSC_IMP then
          Device[i].MasterMode:=Value;
    end;
  end;
end;

procedure TFmxFlowmeter.SetModuleType(AIdx: integer;
  const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device[AIdx]) then
  begin
    Device[AIdx].ModuleType:=Value;
    if Assigned(Device[AIdx].Module) then
     Device[AIdx].Module.ModuleType:=Value;
  end;
end;

procedure TFmxFlowmeter.SetOnSelect(const Value: TNotifyEvent);
begin
  FOnSelect := Value;
end;

procedure TFmxFlowmeter.SetPairNumber(const Value: integer);
var i:integer;
begin
  FPairNumber:=Value;
  for i:=1 to 4 do
  begin
    if Assigned(Device[i]) then
       Device[i].PairNumber:=FPairNumber;
  end;
end;

procedure TFmxFlowmeter.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Port[0] :=
        StrToIntDef(Value, Port[0]);
    3:
      Address[0] :=
        StrToIntDef(Value, Address[0]);
    4:
      BaudRate[0] := StrToIntDef(Value, 9600);
    5:
      Parity := StrToParity(Value);
    6:
      ModuleType[0] := StrToModuleType(Value);
    7:
      left := StrToFloatDef(CP(Value), left)-ShiftL;
    8:
      top :=  StrToFloatDef(CP(Value), top)-ShiftT;
    9:
      width :=StrToFloatDef(CP(Value), width);
    10:
      height := StrToFloatDef(Value, height);
    11:
      AFIdx := StrToIntDef(Value, AFIdx);
    12:
      Primary := myStrToBool(Value);
    13:
      Device[1].current_Settings.OutlayType :=
        StrToOutlayType(MassCounter,Value);
    14:
      First := myStrToBool(Value);
    15:
      Visible := myStrToBool(Value);
    16:
      DecimalDigits:=StrToIntDef(Value, 3);
    17:
      PairNumber:=StrToIntDef(Value, 1)-1;
    18:
      Counters:=StrToIntDef(Value, 8);
    19:
      Min:=StrToFloatDef(Value, 0);
    20:
      Max:=StrToFloatDef(Value, 0);
    21:
      MassCounter := myStrToBool(Value);
    22:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    23:
      TypeOfProtocol[0]:= CheckProtocol(myStrToTypeOfProtocol(Value));
    24:
      InputRegister[0] := StrToIntDef(Value, 0);
    25:
      TypeOfInput:=StrToIntDef(Value, 0);
    26:
      ModulePriority := StrToIntDef(Value, 0);
  end;
end;

procedure TFmxFlowmeter.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device[1]) then
     Device[1].Parity:=Value;
end;

procedure TFmxFlowmeter.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device[1]) then
     Device[1].ModulePriority:=Value;
end;

function TFmxFlowmeter.GetPriority: integer;
begin
  if Assigned(Device[1]) then
     result:=Device[1].ModulePriority
  else
     result:=inherited;
end;


function TFmxFlowmeter.GetProtocolID: word;
begin
  if Assigned(Device[1]) then
    result:=Device[1].ProtocolID
  else
    result:=1;
end;

procedure TFmxFlowmeter.SetSelected(const Value: boolean);
var i:integer;
begin
  if FSelected <> Value then
  begin
    FSelected := Value;
    //видимые блоки
    controlpanelvisible:=Value;
    StylesData['ledspanel.visible']:=Value and LedVisible;
    StylesData['middle_rowstyle.visible']:=Full;
    StylesData['bottom_rowstyle.visible']:=Full;
    for I := 1 to 4 do
      if Assigned(device[i]) then
      begin
         Device[i].CounterIsActive[self.PairNumber]:=Value;
         Device[i].Selected:=Value;
      end;
      Update;
  end;

end;


procedure TFmxFlowmeter.SetTypeOfInput(const Value: Byte);
begin
  FTypeOfInput := Value;
  if Assigned(Device[1]) then
     Device[1].TypeOfInput:=Value;
end;

procedure TFmxFlowmeter.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
   if not (Idx in [1..4]) then Exit;
   if Assigned(FDevice[Idx]) then
      FDevice[Idx].TypeOfProtocol := Value;
end;

procedure TFmxFlowmeter.SetUnitPriority(const Value: boolean);
begin
  FUnitPriority := Value;
end;

procedure TFmxFlowmeter.SetUsePriority(const Value: boolean);
begin
  FUsePriority := Value;
end;

procedure TFmxFlowmeter.Update;
var s:String;
begin
  inherited;
  //базовым считается первое устройство- все действия по расходомеру проводим с ним
  if not Assigned(Device[1]) then Exit;

  if Device[1].ConnectIsOK then begin
    try
      if Device[1].Disguise then
      begin
         State:=fpsDisguise;
         Exit;
      end;
    except
    end;
    if Disguise then
       State:=fpsDisguise
    else if ControlsEnabled then
    begin
      if Selected then State:=fpsEnabledSelected
                       else State:=fpsEnabled;
    end
    else begin
      if Selected then State:=fpsDisabledSelected
                       else State:=fpsDisabled;
    end;
  end
  else begin
    if ManualEnter then
    begin
      if Selected then
        State:=fpsEnabledSelected
      else
        State:=fpsEnabled;
    end
    else
      State:=fpsError;
  end;
  try
    if MassCounter then
    begin
      case Device[1].current_settings.OutlayType of
      otCubeMeterPerHour: begin InputValue:=Device[1].WaterDischarge; Ext:=' т /ч'; end;
      otLiterPerHour: begin InputValue:=Device[1].WaterDischarge * 1000;Ext:=' кг/ч'; end;
      otLiterPerMinute: begin InputValue:=(Device[1].WaterDischarge * 1000/60);Ext:=' кг/мин';end;
      otLiterPerSecond: begin InputValue:=(Device[1].WaterDischarge * 1000)/3600;Ext:=' кг/сек';end;
      end;
    end
    else begin
      case Device[1].current_settings.OutlayType of
      otCubeMeterPerHour: begin InputValue:=Device[1].WaterDischarge;Ext:=' м3/ч';end;
      otLiterPerHour: begin InputValue:=Device[1].WaterDischarge * 1000;Ext:=' л/ч';end;
      otLiterPerMinute: begin InputValue:=(Device[1].WaterDischarge * 1000/60);Ext:=' л/мин';end;
      otLiterPerSecond: begin InputValue:=(Device[1].WaterDischarge * 1000)/3600;Ext:=' л/сек';end;
      end;
    end;
    StylesData['middle_textvalue.text']:=Format('%8.2f',[Device[1].Frequency]);
    StylesData['bottom_textvalue.text']:=Format('%8.2f',[Device[1].CurrentKoeff]);
    //Индицируем состояние счета
    LedState[TLeds(0)]:=Device[1].CountIsStarted and Selected;
  finally

  end;


end;

procedure TFmxFlowmeter.UpdateStyle;
var dopinfovisible:Boolean;
begin
  inherited;
  dopinfovisible:=Full;
  StylesData['middle_rowstyle.visible']:=dopinfovisible;
  StylesData['bottom_rowstyle.visible']:=dopinfovisible;
end;


procedure TFmxFlowmeter.UpdateVolumes();
var i:Integer;
begin
  for i:=1 to 4 do
  begin
     if Assigned(Device[i]) then
           Device[i].UpdateVolumes();
  end;
end;


procedure TFmxFlowmeter.UpdateWaterDischarges;
var i:Integer;
begin
  for i:=1 to 4 do
  begin
     if Assigned(Device[i]) then
        Device[i].UpdateWaterDischarges();
  end;
end;


procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxFlowmeter]);
end;

end.
