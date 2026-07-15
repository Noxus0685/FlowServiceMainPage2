unit FmxLabel;

{ ===== Компонент FmxLabel =====
Визуальный компонент отображения текстовой информации
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types, FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes,
  Fmx.Styles,
  FmxFPDevices, uProcedureOfObject,FMXDeviceCustomControl,FPCustomControl,
  FmxFPModuleManager, FmxFPDeviceManager, uFmxStrConsts, FmxFPModule;

const
//  cLabelStyle='textstyle';
  cLabelStyle='textlabelstyle';

  //Количество свойств
  сTextPropertyCount=11;

  //Наименования свойств
  сTextPropertys:array[0..сTextPropertyCount-1]of string=(
    сText,cHeader,
    cLeft,cTop,cWidth,cHeight,
    cStretch,cColor,cSize,cAngle,cVisible
  );

  //типы свойств
  сTextPropertysType:array[0..сTextPropertyCount-1]of TParameterType=(
      // cHeader, cHint
      ptText,ptText,
      //  cLeft,cTop,cWidth,cHeight,
      ptFloat,ptFloat,ptFloat,ptFloat,
      //cStretch,cColor,cSize,cAngle,cVisible
      ptComboBox,ptNumber,ptNumber,ptFloat,ptComboBox
    );

  //Комбо выпадающие списки
  сTextPropertyComboItems: array[0..сTextPropertyCount-1] of TArray<string> = (
  //cHeader,cHint,
    [],[],
    //  cLeft,cTop,cWidth,cHeight,
    [],[],[],[],
    //  cStretch,cColor,cSize,cAngle,cVisible
    [cNo,cYes],[],[],[],[cNo,cYes]
    );


type
  TFmxLabel = class(TFPCustomControl)
    fcaption:TText;
    TextSettings: TTextSettings;
  private
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetTextSize(const Value: Single);
    procedure SetStretch(const Value: Boolean);
    function GetStretch: Boolean;
    function GetTextColor: TAlphaColor;
    function GetTextSize: Single;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    procedure ApplyStyle; override;
    procedure FillParametersList;override;
    function GetParamValue(Row: integer): String;override;
    procedure SetParamValue(Row: integer; const Value: String);override;
  published
    property Color:TAlphaColor read GetTextColor write SetTextColor;
    property Size:Single read GetTextSize write SetTextSize;
    property Stretch:boolean read GetStretch write SetStretch;
  end;

procedure Register;

implementation
uses FmxFPColors,
     FMXHelper,System.UIConsts,
     FMX.NumberBox,
     System.Rtti;

{ TFPLabel }

procedure TFmxLabel.ApplyStyle;
var
  T: TControl;
begin
   inherited;
   if csDestroying in ComponentState then  Exit;
   if FindStyleResource<TControl>('caption', T) then
   begin
    fcaption:=TText(T);
    TextSettings:=fcaption.TextSettings;
   end;
end;

constructor TFmxLabel.Create(AOwner: TComponent);
begin
  inherited;
  StyleLookup:=cLabelStyle;
  Caption:='Текст '+IntToStr(Idx+1);
  CaptionColor:=CL_FMX_BLACK;
  OtherView:=False;
  State:=fpsEnabled;
  HitTest:=True;
  fcaption:=nil;
  ControlType:=ctTEXT;
  textSettings:=nil;
end;



procedure TFmxLabel.FillParametersList;
var
  i: Integer;
begin
   inherited;
   SetLength(FParameters,сTextPropertyCount);
   for i := 0 to сTextPropertyCount-1 do
   begin
     FParameters[i].Name:=сTextPropertys[i]; //Наименование
     FParameters[i].ParamType:=сTextPropertysType[i];//тип
     FParameters[i].Items:=сTextPropertyComboItems[i];
   end;
end;

function TFmxLabel.GetParamValue(Row: integer): String;
begin
    result:='';
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
        result := FloatToStr(RotationAngle);
      10:
        result := cBooleanName[Visible];
    end;
end;

function TFmxLabel.GetStretch: boolean;
begin
  result:=StylesData['caption.Stretch'].AsBoolean;
end;


function TFmxLabel.GetTextColor: TAlphaColor;
begin
     result:=StylesData['caption.textsettings.fontcolor'].AsType<TAlphaColor>;
end;

function TFmxLabel.GetTextSize: Single;
begin
     result:=StylesData['caption.textsettings.Font.Size'].AsType<Single>;
end;


procedure TFmxLabel.SetParamValue(Row: integer; const Value: String);
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
      Stretch := myStrToBool(Value);
    7:
      Color:=StrToAlphaColor(Value);
    8:
      Size:=StrToFloatDef(CP(Value), Size);
    9:
      RotationAngle:=StrToFloatDef(CP(Value), RotationAngle);
    10:
      Visible := myStrToBool(Value);
  end;
(*

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
        result := FloatToStr(RotationAngle);
      10:
        result := cBooleanName[Visible];
    end;
en
*)
end;

procedure TFmxLabel.SetStretch(const Value: Boolean);
begin
  StylesData['caption.Stretch']:=Value;
end;

procedure TFmxLabel.SetTextColor(const Value: TAlphaColor);
begin
    StylesData['caption.textsettings.fontcolor']:=Value;
end;

procedure TFmxLabel.SetTextSize(const Value: Single);
begin
    StylesData['caption.textsettings.Font.Size']:=Value;
end;


procedure Register;
begin
  RegisterComponents('FMXFP', [TFMXLabel]);
end;


end.
