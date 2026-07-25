unit FmxFrame;

{ ===== Компонент FmxFrame =====
Визуальный компонент отображения текстовой информации
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl, FmxLabel,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
  cStrokeDashName:array[TStrokeDash.Solid..TStrokeDash.DashDotDot] of String=(cFrameStrokeSolid,
                                                                             cFrameStrokeDash,
                                                                             cFrameStrokeDot,
                                                                             cFrameStrokeDashDot,
                                                                             cFrameStrokeDashDotDot);
  cFrameStyle='framestyle';
  cFrameName='frame';

  //Количество свойств
  сFramePropertyCount=14;

  //Наименования свойств
  сFramePropertys:array[0..сFramePropertyCount-1]of string=(
  сText,cHeader,
  cLeft,cTop,cWidth,cHeight,
  cStretch,cColor,cSize,cFrameColor,cFrameSize,cFrameDash,cAngle,cVisible);

  //типы свойств
  сFramePropertysType:array[0..сFramePropertyCount-1]of TParameterType=(
    //сText,cHeader,
    ptText,ptText,
    //cLeft,cTop,cWidth,cHeight,
    ptFloat,ptFloat,ptFloat,ptFloat,
    //cStretch,cColor,cSize,cFrameColor,cFrameSize,cFrameDash,cAngle,cVisible
    ptComboBox,ptNumber,ptNumber,ptNumber,ptNumber,ptComboBox,ptFloat,ptComboBox
  );

  //Комбо выпадающие списки
  сFramePropertyComboItems: array[0..сFramePropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
//  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
    //cStretch,cColor,cSize,cFrameColor,cFrameSize,cFrameDash,cAngle,cVisible
    [cNo,cYes],[],[],[],[],[cFrameStrokeSolid,cFrameStrokeDash,cFrameStrokeDot,cFrameStrokeDashDot,cFrameStrokeDashDotDot],[],[cNo,cYes]
    );


type
  TFmxFrame = class(TFPCustomControl)
  private
    function GetFrameColor: TAlphaColor;
    procedure SetFrameColor(const Value: TAlphaColor);
    function GetFrameThickNess: Single;
    procedure SetFrameThickNess(const Value: Single);
    function GetFrameDash: TStrokeDash;
    procedure SetFrameDash(const Value: TStrokeDash);
    function GetStretch: boolean;
    function GetTextColor: TAlphaColor;
    function GetTextSize: Single;
    procedure SetStretch(const Value: boolean);
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetTextSize(const Value: Single);
    function StrokeDashToStr(AValue: TStrokeDash): String;
    function StrToStrokeDash(AStr: String): TStrokeDash;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    procedure FillParametersList;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
  published
    property Color:TAlphaColor read GetTextColor write SetTextColor;
    property Size:Single read GetTextSize write SetTextSize;
    property Stretch:boolean read GetStretch write SetStretch;
    property FrameColor:TAlphaColor read GetFrameColor write SetFrameColor;
    property FrameThickNess:Single read GetFrameThickNess write SetFrameThickNess;
    property FrameDash:TStrokeDash read GetFrameDash write SetFrameDash;
  end;

procedure Register;

implementation
uses FmxFPColors,
     FMXHelper,System.UIConsts,
     System.Rtti;

{ TFPLabel }

constructor TFmxFrame.Create(AOwner: TComponent);
begin
  inherited;
  Caption:='Рамка '+IntToStr(Idx+1);
  CaptionColor:=CL_FMX_BLACK;
  StyleLookup:=cFrameStyle;
  OtherView:=False;
  ControlType:=ctFrame;
  State:=fpsEnabled;
end;

procedure TFmxFrame.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,сFramePropertyCount);
   for i := 0 to сFramePropertyCount-1 do
   begin
     FParameters[i].Name:=сFramePropertys[i]; //Наименование
     FParameters[i].ParamType:=сFramePropertysType[i];//тип
     FParameters[i].Items:=сFramePropertyComboItems[i];
   end;
end;

function TFmxFrame.GetFrameColor: TAlphaColor;
begin
   result:=TAlphaColor(StylesData['frame.stroke.Color'].AsInt64);
end;

//  TStrokeDash = (Solid, Dash, Dot, DashDot, DashDotDot, Custom);
function TFmxFrame.GetFrameDash: TStrokeDash;
begin
   result:=TStrokeDash(StylesData['frame.stroke.Dash'].AsOrdinal);
end;

function TFmxFrame.GetFrameThickNess: Single;
begin
   result:=StylesData['frame.stroke.thickness'].AsExtended;
end;

function TFmxFrame.GetParamValue(Row: integer): String;
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
     result := cBooleanName[Stretch];
  7:
     result:= MyAlphaColorToStr(Color);
  8:
    result := FloatToStr(Size);
  9:
     result:= MyAlphaColorToStr(FrameColor);
  10:
    result := FloatToStr(FrameThickNess);
  11:
    result:=StrokeDashToStr(FrameDash);
  12:
    result := FloatToStr(RotationAngle);
  13:
    result := cBooleanName[Visible];
  end;
end;

function TFmxFrame.GetStretch: boolean;
begin
  result:=StylesData['caption.Stretch'].AsBoolean;
end;

function TFmxFrame.GetTextColor: TAlphaColor;
begin
  result:=StylesData['caption.textsettings.fontcolor'].AsType<TAlphaColor>;
end;

function TFmxFrame.GetTextSize: Single;
begin
  result:=StylesData['caption.textsettings.Font.Size'].AsType<Single>;
end;

procedure TFmxFrame.SetFrameColor(const Value: TAlphaColor);
begin
   StylesData['frame.stroke.Color']:=Value;
end;

procedure TFmxFrame.SetFrameDash(const Value: TStrokeDash);
begin
   if Value in [TStrokeDash.Solid..TStrokeDash.Custom] then
      StylesData['frame.stroke.Dash']:=TValue.From<TStrokeDash>(Value);
end;

procedure TFmxFrame.SetFrameThickNess(const Value: Single);
begin
   StylesData['frame.stroke.Thickness']:=Value;
end;



procedure TFmxFrame.SetParamValue(Row: integer; const Value: String);
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
       Stretch:=myStrToBool(Value);
    7:
       Color:=StrToAlphaColor(Value);
    8:
      Size:=StrToFloatDef(CP(Value), Size);
    9:
       FrameColor:=StrToAlphaColor(Value);
    10:
      FrameThickNess:=StrToFloatDef(CP(Value), FrameThickNess);
    11:
      FrameDash:=StrToStrokeDash(Value);
    12:
      RotationAngle:=StrToFloatDef(CP(Value), RotationAngle);
    13:
      Visible := myStrToBool(Value);
  end;
end;

procedure TFmxFrame.SetStretch(const Value: boolean);
begin
  StylesData['caption.Stretch']:=Value;
end;

procedure TFmxFrame.SetTextColor(const Value: TAlphaColor);
begin
    StylesData['caption.textsettings.fontcolor']:=Value;
end;

procedure TFmxFrame.SetTextSize(const Value: Single);
begin
    StylesData['caption.textsettings.Font.Size']:=Value;
    if Value>10 then
       StylesData['caption.margins.Top']:=Value-9
    else
       StylesData['caption.margins.Top']:=0;
end;

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxFrame]);
end;

function TFmxFrame.StrokeDashToStr(AValue:TStrokeDash):String;
begin
  if AValue in [TStrokeDash.Solid..TStrokeDash.DashDotDot] then
     result:=cStrokeDashName[AValue]
  else
     result:=cStrokeDashName[TStrokeDash.Solid];
end;

function TFmxFrame.StrToStrokeDash(AStr:String):TStrokeDash;
var i:TStrokeDash;
     s:string;
begin
  result:=TStrokeDash.Solid;
  for I := TStrokeDash.Solid to TStrokeDash.DashDotDot do
  begin
      s:=cStrokeDashName[i];
      if (UpperCase(s)=UpperCase(AStr)) or (AStr=IntToStr(Ord(i))) then
      begin
         result:=i;
         Break;
      end;
  end;
end;



end.
