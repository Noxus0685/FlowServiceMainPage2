unit FmxWaterLevel;

interface

uses FPCustomControl,

      System.Classes,
     uFmxStrConsts;

type
  //когда используется - с весовой бак, в перспективе уровень в обменной емкости
  TWaterLevelMode = (wlmScaleTank=0,wlmTank);
const
  cWaterLevelStyle='waterlevelstyle';
  сGauge_Name=0;
  cGaugeHeader=1;
  cGaugeLeft=2;
  cGaugeTop=3;
  cGaugeWidth=4;
  cGaugeHeight=5;
  cGaugeNumAppFunction=6;
  cGaugeMode=7;
  cGaugeAngle=8;
  cGaugeVisible=9;
  cGaugeTypeOfApp=10;

  //Количество свойств
  сGaugePropertyCount=11;

  //Наименования свойств
  сGaugePropertys:array[0..сGaugePropertyCount-1]of string=(
  cHeader,cHint,
  cLeft,cTop,cWidth,cHeight,cNumAppFunction,
  cUsingMode,cAngle,cVisible,cTypeAppFunc);

  //типы свойств
  сGaugePropertysType:array[0..сGaugePropertyCount-1]of TParameterType=(
  //cHeader,cHint,
  ptText,ptText,
  //cLeft,cTop,cWidth,cHeight,cNumAppFunction,
  ptNumber,ptNumber,ptNumber,ptNumber,ptNumber,
  //cUsingMode,cAngle,cVisible,cTypeAppFunc
  ptComboBox,ptFloat,ptComboBox,ptNumber);

  //Комбо выпадающие списки
  сGaugePropertyComboItems: array[0..сGaugePropertyCount-1] of TArray<string> = (
      //cHeader,cHint,
      [],[],
      //cLeft,cTop,cWidth,cHeight,cNumAppFunction,
      [],[],[],[],[],
      //cUsingMode,cVisible,cTypeAppFunc
      [cWeightTank,cDrainTank],[],[cNo,cYes],[]// cState - состояние (открыт/закрыт, да/нет ...)
    );


  //Тип использования
  cWaterLevelModeName:array[TWaterLevelMode] of String = (cWeightTank,cDrainTank);


type
  TFMXWaterLevel = class(TFPCustomControl)
  private
    FCurValue: Longint;
    FMode: TWaterLevelMode;
    procedure SetProgress(const _Value: Longint);
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
    procedure SetMode(const Value: TWaterLevelMode);
  public
    constructor Create(AOwner: TComponent); override;
    property Mode:TWaterLevelMode read FMode write SetMode;
    procedure FillParametersList;override;
    property Progress: Longint read FCurValue write SetProgress;
  end;

implementation

uses
  FmxHelper,
  System.SysUtils;
{ TFMXWaterLevel }

constructor TFMXWaterLevel.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cWaterLevelStyle;
  ControlType:=ctWaterLevel;
  OtherView:=False;
  State:=fpsEnabled;
  HitTest:=True;
end;

procedure TFMXWaterLevel.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,сGaugePropertyCount);
   for i := 0 to сGaugePropertyCount-1 do
   begin
     FParameters[i].Name:=сGaugePropertys[i]; //Наименование
     FParameters[i].ParamType:=сGaugePropertysType[i];//тип
     FParameters[i].Items:=сGaugePropertyComboItems[i];
   end;
end;

function TFMXWaterLevel.GetParamValue(Row: integer): String;
begin
  case Row of
  0:
    result := Caption; // 'Заголовок'
  1:
    result := Hint; // 'Подсказка'
  2:
    result := FloatToStr(left+ShiftL);
  3:
    result := FloatToStr(top+ShiftT);
  4:
    result := FloatToStr(width);
  5:
    result := FloatToStr(height);
  6:
    result := IntToStr(AFIdx);
  7:
    result := cWaterLevelModeName[Mode];
  8:
    result := FloatToStr(RotationAngle);
  9:
    result := cBooleanName[Visible];
  10:
    result := cTypeOfAppFunc[TypeOfAppFunc];
  end;
end;


procedure TFMXWaterLevel.SetMode(const Value: TWaterLevelMode);
begin
  FMode := Value;
end;

function myStrToWaterLevelMode(Value:String):TWaterLevelMode;
begin
   result:=wlmScaleTank;
   if (cWaterLevelModeName[wlmTank]=Value) or (Value='1') then
     result:=wlmTank;
end;

procedure TFMXWaterLevel.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption:=Value; // 'Заголовок'
    1:
      Hint:=Value; // 'Подсказка'
    2:
      left:=StrToFloatDef(CP(Value), left)-ShiftL;
    3:
      top:=StrToFloatDef(CP(Value), top)-ShiftT;
    4:
      width:=StrToFloatDef(CP(Value), width);
    5:
      height:=StrToFloatDef(CP(Value), height);
    6:
      AFIdx:=StrToIntDef(Value, AFIdx);
    7:
      Mode:=myStrToWaterLevelMode(Value);
    8:
      RotationAngle:=StrToFloatDef(CP(Value), RotationAngle);
    9:
      Visible := myStrToBool(Value);
    10:
      TypeOfAppFunc := myStrToTypeOfAppFunc(Value);
  end;
end;

procedure TFMXWaterLevel.SetProgress(const _Value: Longint);
begin
  FCurValue := _Value;
  ScrollBarPosition:=_Value;
end;

end.
