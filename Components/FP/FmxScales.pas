unit FmxScales;


{ ===== Компонент FmxScales =====
Визуальный компонент весового устройства
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,//TMouseButton
  FmxParamsFrm,//Форма ручного ввода параметров
  FPCustomControl,
  FMXDeviceCustomControl,
  FmxFPDevices,
  uProcedureOfObject,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;
const
  cScalesStyle='scalesstyle';
  cShortHeight=80;
  cSensorHeight=15;

type
  TScalesParams=(spSensorValue);

const
  cScalesVolumeParams:array[TScalesParams]of string=('Датчик ');
  cScalesParamsWritable:array[TScalesParams]of boolean=(True);

  //Количество свойств
  cScalePropertyCount=24;

  //Наименования свойств
  cScalePropertys:array[0..cScalePropertyCount-1]of string=(
  cHeader,cHint,
  cPort,cAddress,cBaudrate,cParity,
  cModuleType,cLeft,cTop,cWidth,cHeight,
  cNumAppFunction,cSensorsQuantity,
  cUse_L2,cFirst,cVisible,cFlowmeterMax,cTypeAppFunc,cEdIzmSensor,cEdIzmParam,cMassMode,cTypeOfProtocol,cModbusInputReg,cModulePriority);

  //типы свойств
  cScalePropertysType:array[0..cScalePropertyCount-1]of TParameterType=(
//  cHeader,cHint
    ptText,ptText,
//  cPort,   cAddress,cBaudrate,
    ptNumber,ptNumber,ptNumber,
//  pParity
    ptComboBox,
//  cModuleType,
    ptComboBox,
//cLeft,cTop,cWidth,cHeight,
    ptFloat,ptFloat,ptFloat,ptFloat,
//  cNumAppFunction, cSensorsQuantity
    ptNumber,       ptNumber,
//  cUse_L2,    cFirst,   cVisible,cFlowmeterMax,cTypeAppFunc,
    ptComboBox, ptComboBox, ptComboBox, ptNumber, ptComboBox,
//  cEdIzmSensor,cEdIzmParam,cMassMode,cTypeOfProtocol,cModbusInputReg,cModulePriority
    ptText,      ptText,    ptComboBox, ptComboBox, ptNumber,  ptNumber
  );

  //Комбо выпадающие списки
  cScalePropertyComboItems: array[0..cScalePropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cPort,cAddress,cBaudrate,cParity
    [],[],[],[cNone,cOdd,cEven,cMark,cSpace],
//  cModuleType
    [cmtScalesAD103,cmtScalesRADWAG,cmtScales,cmtScalesMT,cmtModbusA],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
//  cNumAppFunction, cSensorsQuantity
    [],[],
//  cUse_L2,    cFirst,   cVisible,cFlowmeterMax,cTypeAppFunc,
    [cNo,cYes],[cNo,cYes],[cNo,cYes],[],[cNumber,cMask],
//  cEdIzmSensor,cEdIzmParam,cMassMode,
    [],[],[cNo,cYes],
//  cTypeOfProtocol,
    [ctpProprietary,ctpModbusRTU,ctpModbusASCII,ctpModbusTCP],
//  cModbusInputReg,cModulePriority
    [],[]
    );




type

  TFmxScales = class(TFMXDeviceCustomControl)
  private
    FSelected: Boolean;
    FOnSelect: TNotifyEvent;
    FfrmParams: TfrmParams;
    FParamExt: string;
    FSensorsQuantity: Byte;
    FLastPourOutTime: Cardinal;
    FMaxFlow: single;
    FUse_L2: boolean;
    FSensorExt: string;
    FMedianFilterSize: Integer;
    FParity: TComParity;
    FMasterMode: boolean;
    FWaterDischarge: Double;

    procedure LoadParamValues;
    procedure StoreParamValues;
    function GetSelected: boolean;
    procedure SetOnSelect(const Value: TNotifyEvent);
    procedure SetSelected(const Value: boolean);
    procedure SetfrmParams(const Value: TfrmParams);
    function GetValue: Double;
    function GetManualEnter: Boolean;
    function GetGradSensorsLevel1: boolean;
    function GetMassMode: boolean;
    function GetTare: double;
    function GetVolume: double;
    function GetWeight: double;
    procedure SetLastPourOutTime(const Value: Cardinal);
    procedure SetMassMode(const Value: boolean);
    procedure SetParamExt(const Value: string);
    procedure SetSensorExt(const Value: string);
    procedure SetSensorsQuantity(const Value: Byte);
    procedure SetUse_L2(const Value: boolean);
    procedure TareButtonClick(Sender: TObject);
    procedure SensorsUpdate;
    function GetSensorText(Idx: integer): string;
    procedure SetSensorText(Idx: integer; const Value: string);
    procedure SetMedianFilterSize(const Value: Integer);
    function GetPriority: integer;override;
    procedure SetMasterMode(const Value: boolean);
    procedure SetWaterDischarge(const Value: Double);
  protected
    //Устанавливаем приоритет устройства и в конечном итоге, модуля (контроллера)
    procedure SetPriority(const Value: integer);override;
    procedure Loaded; override;
    procedure DoOnChange(Sender: TObject);override;
    procedure UpdateStyle;override;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Single);override;
    function  GetModuleManager: TFmxModuleManager;override;
    procedure SetComPort(AIdx: integer; const Value: word); override;
    procedure SetAddress(AIdx: Integer; const Value: Integer); override;
    procedure SetBaudrate(AIdx: Integer; const Value: Cardinal); override;
    procedure SetModuleType(AIdx: integer; const Value: TFMXModuleType); override;
    procedure SetTypeOfProtocol(AIdx:Integer;const Value: TTypeOfProtocol);override;
    function  Disguise: Boolean; override;
    function  GetCurState: String; override;
    procedure SetParity(const Value: TComParity);override;
    procedure Update;override;
    // Обработчик ответов от модуля-устройства.
    procedure ReceiveResponse; override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    function GetRebootWarning(Row: integer): Boolean;override;
  public
    // Указатель на устройство включающиее и выключающее насос
    Device: TFmxDeviceScales;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SensorText[Idx:integer]:string read GetSensorText write SetSensorText;
    procedure CopyStoredToCurrentSettings;
    procedure FillParametersList;override;
  published
    // Флаг полной формы компонента (со значением текущей частоты).
    property ManualEnter:Boolean read GetManualEnter;
    property frmParams: TfrmParams read FfrmParams write SetfrmParams;
    property WaterDischarge:Double read FWaterDischarge write SetWaterDischarge;
    // Количетво используемых датчиков.
    property SensorsQuantity: Byte read FSensorsQuantity write SetSensorsQuantity default 3;
    property OnSelect:TNotifyEvent read FOnSelect write SetOnSelect;
    property Selected:boolean read GetSelected write SetSelected;
    property GradSensorsLevel1:boolean read GetGradSensorsLevel1;
    property Use_L2:boolean read FUse_L2 write SetUse_L2;
    property Weight:double read GetWeight;
    property Volume:double read GetVolume;
    property Value:double read GetValue;
    property Tare:double read GetTare;
    property LastPourOutTime:Cardinal read FLastPourOutTime write SetLastPourOutTime;
    property ParamExt:string read FParamExt write SetParamExt;
    property SensorExt:string read FSensorExt write SetSensorExt;
    property MassMode:boolean read GetMassMode write SetMassMode;
    property MedianFilterSize:Integer read FMedianFilterSize write SetMedianFilterSize;
    property OnClick;
  end;

procedure Register;

implementation

uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     FMX.Text,
     System.Rtti;

{ TFmxScales }

constructor TFmxScales.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cScalesStyle;
  ControlType:=ctScale;
  ModuleType[0]:=mtCounter;
  CaptionColor:=CL_FMX_WHITE;
  Caption:='Весы '+IntToStr(FIdx+1);
  FSelected:=True;
  ShortHeight:=cShortHeight;
  LongHeight:=130;
  ValueMask:='';
  ValueType:=TNumValueType.Float;
  DecimalDigits := 4;
  StylesData['middle_rowstyle.visible']:=False;
  HitTest:=True;
  AutoCapture:=True;
  OnMouseDown:=DoOnMouseDown;
  LedON[TLeds(0)]:=TAlphaColorRec.Green;//стабильность
  LedOFF[TLeds(0)]:=TAlphaColorRec.Silver;
  LedON[TLeds(1)]:=TAlphaColorRec.Red;//перегруз
  LedOFF[TLeds(1)]:=TAlphaColorRec.Silver;
  LedState[TLeds(0)]:=False;
  LedState[TLeds(1)]:=False;
  LedsCount:=2;
  Width:=130;
  Height := ShortHeight;
  SensorsQuantity:=3;
  Full := false;
  StylesData['mainbody.OnMouseDown']:=TValue.From<TMouseEvent>(DoOnMouseDown);
  if csDesigning in ComponentState then State:=fpsDisabled
  else State:=fpsError;
end;

destructor TFmxScales.Destroy;
begin

  inherited;
end;

procedure TFmxScales.CopyStoredToCurrentSettings;
var i,j:integer;
    tmpK:Double;
begin
  device.AmbientTemperature:= Device.settings.AmbientTemperature[0];
  device.RelativeHumidity:= Device.settings.RelativeHumidity[0];
  device.AtmosphericPressure:= Device.settings.AtmosphericPressure[0];
  //28.02.2024 - буфер не прописывался ранее - фильтр весов активирован
  device.WeightsBufferLength :=Device.settings.WeightsBufferLength;
  for i:=0 to 3 do
  begin
    j:=Length(Device.settings.CalibrationCoefficients);
    if j>i then
    begin
      device.CalibrationCoefficients[i]:= Device.settings.CalibrationCoefficients[i];
      device.CalibrationNulls[i]:= Device.settings.CalibrationNulls[i];
      device.DumbbellsDensity0[i]:=Device.settings.DumbbellsDensity[i];
    end
    else begin
      device.CalibrationCoefficients[i]:=1;
      device.CalibrationNulls[i]:= 0;
      device.DumbbellsDensity0[i]:=8000;
    end;
    SortCalibrationPointArray(Device.settings.CalibrationTable_l2);
  end;
end;


function TFmxScales.Disguise: Boolean;
begin
  if Assigned(Device) then result:=Device.Disguise
  else result:=false;
end;

procedure TFmxScales.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
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
        Selected:=not Selected;
        if Assigned(Device) then
        begin
          if Device.ModuleType=mtManual then
          begin
             //Иначе вызываем диалоговое окно настройки значений параметров
             if Assigned(frmParams) then
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

procedure TFmxScales.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,cScalePropertyCount);
   for i := 0 to cScalePropertyCount-1 do
   begin
     FParameters[i].Name:=cScalePropertys[i]; //Наименование
     FParameters[i].ParamType:=cScalePropertysType[i];//тип
     FParameters[i].Items:=cScalePropertyComboItems[i];
   end;
end;

function TFmxScales.GetCurState: String;
begin
  result:=inherited;
  if Assigned(Device) then
  begin
      if not ManualEnter then
         result:=result+Format(': %f, %s',[Device.Weight,ButtonText])
      else
         result:=result+Format(': %f',[Device.Weight]);
  end;
end;

function TFmxScales.GetGradSensorsLevel1: boolean;
begin
  case ModuleType[0] of
  mtScales: result:=True;
  mtScalesMT: result:=False;
  mtScalesAD103: result:=False;
  mtScalesRADWAG: result:=False;
  mtManual: result:=True;
  end;
end;

function TFmxScales.GetManualEnter: Boolean;
begin
  if Assigned(Device) then
     result:=Device.ModuleType=mtManual
  else
     result:=False;
end;

function TFmxScales.GetMassMode: boolean;
begin
  result:=True;
  if Assigned(Device) then
     result:=device.MassMode;
end;


function TFmxScales.GetModuleManager: TFmxModuleManager;
begin
  if Assigned(Device) then
     result:=Device.ModuleManager
  else
     result:=nil;
end;

function TFmxScales.GetParamValue(Row: integer): String;
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
      result:=cComParityName[Parity];
    6:
      result := cModuleTypeNames[ModuleType[0]];
    7:
      result := FloatToStr(left+ShiftL);
    8:
      result := FloatToStr(top+ShiftT);
    9:
      result := FloatToStr(width);
    10:
      result := FloatToStr(height);
    11:
      result := IntToStr(AFIdx);
    12:
      result := IntToStr(SensorsQuantity);
    13:
      result := cBooleanName[Use_L2];
    14:
      result := cBooleanName[First];
    15:
      result := cBooleanName[Visible];
    16:
      result := Format('%8.5f',[Max]);
    17:
      result := cTypeOfAppFunc[TypeOfAppFunc];
    18:
      result := SensorExt;
    19:
      result := ParamExt;
    20:
      result := cBooleanName[MassMode];
    21:
      result := cTypeOfProtocols[CheckProtocol(TypeOfProtocol[0])];
    22:
      result := IntToStr(InputRegister[0]);
    23:
      result := IntToStr(ModulePriority);
  end;
end;


function TFmxScales.GetRebootWarning(Row: integer): Boolean;
begin
   result:=Row in [2 .. 5];
end;

function TFmxScales.GetSelected: boolean;
begin
  result:=FSelected;
  if Assigned(Device) then
     result:=Device.Active;
  FSelected:=Result;
end;

function TFmxScales.GetSensorText(Idx: integer): string;
begin
   result:=StylesData['Sensor'+IntToStr(Idx)+'_text.text'].asString;
end;

function TFmxScales.GetTare: double;
begin
  result:=0;
  if Assigned(Device) then
     result:=device.Tare;
end;

function TFmxScales.GetValue: Double;
begin
  result:=0;
  if Assigned(Device) then
     result:=device.Value;
end;

function TFmxScales.GetVolume: double;
begin
  result:=0;
  if Assigned(Device) then
     result:=device.Volume;
end;

function TFmxScales.GetWeight: double;
begin
  result:=0;
  if Assigned(Device) then
     result:=device.Weight;
end;

procedure TFmxScales.Loaded;
begin
  inherited;
  if ( not (csDesigning in ComponentState) ) and (Device = nil) then begin
    Device := TFmxDeviceScales.CreateOnModule(ModbusTCPHost,ModbusTCPPort,ModuleType[0],Port[0],Address[0],BaudRate[0], SensorsQuantity,TypeOfProtocol[0],InputRegister[0]);
    Device.AddReceiver(ReceiveResponse);
  end;
end;

procedure TFmxScales.LoadParamValues;
var i:integer;
begin
  if Assigned(frmParams) then
  begin
    frmParams.Caption:=cManualEnter+Caption;
    frmParams.ParamsCount:=SensorsQuantity;
    for I := 0 to SensorsQuantity-1 do
    begin
      frmParams.ParamsWritable[i]:=True;
      if SensorExt<>'' then
         frmParams.ParamsName[i]:=cScalesVolumeParams[spSensorValue]+IntToStr(I+1)+', '+SensorExt
      else
         frmParams.ParamsName[i]:=cScalesVolumeParams[spSensorValue]+IntToStr(I+1);
      frmParams.ParamsValue[i]:=Device.SensorValues[i];
    end;
  end;
end;

procedure TFmxScales.ReceiveResponse;
var
  i: Byte;

   //========================================================================
   // 10.07.2008, Возженников
   // функция упрощает замеренное весами значение до разрядности требуемого
   //
   //     x - измеренное весами среднее значение.
   // Discr - значение дискретности, в граммах (передается из формы настроек)
   function DiscontinuityAverage(x:Double; Discr:{longword}int64):Double;
     var  ScalesWeight,
          LowLimit     : {longword}int64;
    begin
    If (Discr<>0) then   // при передаче нулевого значения "выключаем" дискретность, работаем со значениями с датчиков
     begin
       // переводим взвешенное значение в целое - миллиграммы, и отсекаем лишние разряды
       // (по идее они только вносят помехи, поэтому используется не Round)
      ScalesWeight := Trunc(x*1000000);
       // Дискретность тоже переводим в миллиграммы
      Discr:=Discr{*1000};
       // ближайшее вниз возможное значение показаний при заданной дискретности. Как будет если меньше нуля?
      LowLimit := Trunc(ScalesWeight/Discr)*Discr;
       // проверка - если измеренное попадает в половину диапазона дискретности
       // то нижняя грань, иначе - следущее возможное значение
      If (abs(ScalesWeight-LowLimit) <= (Discr div 2)) then    // условие тут по модулю?!
       Result := (LowLimit/1000000)
      else
       If (ScalesWeight >= 0) then
            Result := ((LowLimit+Discr)/1000000)
        // если работаем с отрицательным значением веса (например при установке нуля, то дискретность вычитается)
       else Result := ((LowLimit-Discr)/1000000);
     end
      // если дискретность равна нулю, то возвращаем значение с датчика весов
    else Result := x;
   end;
   //===================================================================



begin
  if Device.ConnectIsOK then
  begin
     if Device.Disguise then
     begin
       State:=fpsDisguise;
       Exit;
     end;
    controlpanelvisible:=True;
    if ControlsEnabled then
    begin
        if Selected then
          State:=fpsEnabledSelected
        else
          State:=fpsEnabled;
    end
    else if Selected then
        State:=fpsDisabledSelected
    else
        State:=fpsDisabled;

    ButtonText := 'тара = ' + FloatToStrF(Device.Tare, ffFixed, 15, 4) + ParamExt;
    if not  (State in [fpsDisabled,fpsDisabledSelected]) then
       ButtonEnabled := true;
    InputValue:=DiscontinuityAverage(Device.Weight,Device.Discontinuity);
    if ManualEnter then
    begin
      for i:=1 to SensorsQuantity do
        SensorText[i] := FloatToStrF(Device.SensorValues[i-1], ffFixed, 15, DecimalDigits+1);
    end
    else begin
      for i:=1 to SensorsQuantity do
        SensorText[i] := FloatToStrF(Device.SensorWeights[i-1], ffFixed, 15, DecimalDigits+1);
    end;
    LEDState[lpLED1]:=not Device.changed;
  end
  else begin
    State:=fpsError;
    ButtonText := 'тара';
    ButtonEnabled := false;
    controlpanelvisible:=False;
  end;
end;

procedure TFmxScales.SetAddress(AIdx: Integer; const Value: Integer);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.Address:=Value;
end;

procedure TFmxScales.SetBaudrate(AIdx: Integer; const Value: Cardinal);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.BaudRate:=Value;
end;

procedure TFmxScales.SetComPort(AIdx: integer; const Value: word);
begin
  inherited;
  if Assigned(Device) then
    if Assigned(Device.Module) then
     Device.Module.PortNumber:=Value;
end;

procedure TFmxScales.SetfrmParams(const Value: TfrmParams);
begin
  FfrmParams := Value;
end;


procedure TFmxScales.UpdateStyle;
begin
  inherited;
  if Full then SensorsUpdate();
  StylesData['middle_rowstyle.visible']:=Full;
end;


procedure TFmxScales.SetLastPourOutTime(const Value: Cardinal);
begin
  FLastPourOutTime := Value;
end;


procedure TFmxScales.SetMassMode(const Value: boolean);
begin
  if Assigned(Device) then
     device.MassMode:=Value;
end;



procedure TFmxScales.SetMasterMode(const Value: boolean);
begin
  FMasterMode := Value;
end;

procedure TFmxScales.SetMedianFilterSize(const Value: Integer);
begin
  FMedianFilterSize := Value;
end;

procedure TFmxScales.SetModuleType(AIdx: integer; const Value: TFMXModuleType);
begin
  inherited;
  if Assigned(Device) then
     Device.ModuleType:=Value;
end;

procedure TFmxScales.SetOnSelect(const Value: TNotifyEvent);
begin
  FOnSelect:=Value;
end;

procedure TFmxScales.SetParamExt(const Value: string);
begin
  FParamExt := Value;
end;

procedure TFmxScales.SetParamValue(Row: integer; const Value: String);
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
      top := StrToFloatDef(CP(Value), top)-ShiftT;
    9:
      width :=StrToFloatDef(CP(Value), width);
    10:
      height :=StrToFloatDef(CP(Value), height);
    11:
      AFIdx :=
        StrToIntDef(Value, AFIdx);
    12:
      SensorsQuantity := StrToIntDef(Value, SensorsQuantity);
    13:
      Use_L2 := myStrToBool(Value);
    14:
      First := myStrToBool(Value);
    15:
      Visible := myStrToBool(Value);
    16:
      Max:=StrToFloatDef(Value, 0);
    17:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
    18:
      SensorExt := Value;
    19:
      ParamExt := Value;
    20:
      MassMode:=myStrToBool(Value);
    21:
      TypeOfProtocol[0] := CheckProtocol(myStrToTypeOfProtocol(Value));
    22:
      InputRegister[0] := StrToIntDef(Value, 0);
    23:
      ModulePriority := StrToIntDef(Value, 0);
  end;
end;

procedure TFmxScales.SetParity(const Value: TComParity);
begin
  inherited;
  if Assigned(Device) then
     Device.Parity:=Value;
end;

procedure TFmxScales.SetPriority(const Value: integer);
begin
  inherited;
  if Assigned(Device) then
     Device.ModulePriority:=Value;
end;

function TFmxScales.GetPriority: integer;
begin
  if Assigned(Device) then
     result:=Device.ModulePriority
  else
     result:=inherited;
end;

procedure TFmxScales.SetSelected(const Value: boolean);
var i:integer;
begin
  if FSelected <> Value then
  begin
    FSelected := Value;
    //видимые блоки
    controlpanelvisible:=Value;
    StylesData['ledspanel.visible']:=Value and LedVisible;
    if Assigned(device) then
    begin
       Device.Active:=Value;
    end;
    if Assigned(FOnSelect) then FOnSelect(self);
  end;
end;

procedure TFmxScales.SetSensorExt(const Value: string);
var i:integer;
begin
  FSensorExt := Value;
  for i := 1 to 4 do
     StylesData['Sensor'+IntToStr(i)+'_ext.text']:=Value;
end;

procedure TFmxScales.SensorsUpdate;
var
  i: Byte;
  SensorVisible:boolean;
begin
  LongHeight:=cShortHeight;
  for i:=1 to 4 do
  begin
    if i <= FSensorsQuantity then
    begin
      LongHeight:=LongHeight+cSensorHeight;
      StylesData['Sensor'+IntToStr(i)+'.visible']:=true;
    end
    else
      StylesData['Sensor'+IntToStr(i)+'.visible']:=false;
  end;
end;

procedure TFmxScales.SetSensorsQuantity(const Value: Byte);
begin
  if (Value >= 1) and (Value <= 4)  then
  begin
    FSensorsQuantity := Value;
    SensorsUpdate();
  end;
  if Assigned(Device) then
     Device.SensorsQuantity:=FSensorsQuantity;
end;

procedure TFmxScales.SetSensorText(Idx: integer; const Value: string);
begin
   StylesData['Sensor'+IntToStr(Idx)+'_text.text']:=Value;
end;

procedure TFmxScales.SetTypeOfProtocol(AIdx: Integer;
  const Value: TTypeOfProtocol);
begin
  inherited;
  if Assigned(Device) then
     Device.TypeOfProtocol:=Value;
end;

procedure TFmxScales.SetUse_L2(const Value: boolean);
begin
  FUse_L2 := Value;
  if Assigned(Device) then
     Device.Use_L2:=Value;
end;

procedure TFmxScales.SetWaterDischarge(const Value: Double);
begin
  FWaterDischarge := Value;
end;

procedure TFmxScales.StoreParamValues;
var i:integer;
begin
  for I := 0 to SensorsQuantity-1 do
  begin
    Device.SensorValues[I]:=frmParams.ParamsValue[ord(spSensorValue)+I];
  end;
  ReceiveResponse;
end;

procedure TFmxScales.TareButtonClick(Sender: TObject);
begin
  if not Assigned(Device) then Exit;
  Device.Tare := 0;
  Device.Tare := Device.ClearWeight;
  Update();
end;


procedure TFmxScales.Update;
begin
  inherited;
  ReceiveResponse;
end;


procedure TFmxScales.DoOnChange(Sender: TObject);
begin
  inherited;
  //Произошло изменение контрола
  case CCN of
    ccnNone: ;
    ccnEdit: begin
      end;
    ccnTrackBar: begin
    end;
    ccnStartStopButton: begin
      TareButtonClick(self);
    end;
    ccnOpenButton:begin
    end;
    ccnCloseButton: begin
    end;
  end;
  CCN:=ccnNone;

end;


procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxScales]);
end;



end.
