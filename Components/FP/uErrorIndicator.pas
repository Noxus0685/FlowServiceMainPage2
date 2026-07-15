unit uErrorIndicator;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.UITypes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Objects, FMX.Grid;

type
  TErrorIndicator = class(TStyledControl)
  private
    FDelta: Single;
    FMarginColor: TAlphaColor;
    FCurrentError: Double;
    FMaxError: Double;
    FAbsError: Double;
    procedure SetCurrentError(const Value: Double);
    procedure SetMaxError(const Value: Double);
    procedure ApplyStyle; override;
    procedure UpdateBarsVisibility;
    procedure UpdateCentralDigit;
    procedure HideAllBars;
    procedure SetAbsError(const Value: Double);
    function FindBarByName(const AName: string): TRectangle;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
  published
    property CurrentError: Double read FCurrentError write SetCurrentError;
    property MaxError: Double read FMaxError write SetMaxError;
    property AbsError: Double read FAbsError write SetAbsError;
    property Align;
    property Position;
    property Width;
    property Height;
    property Size;
    property Margins;
    property Padding;
    property Scale;
  end;

  // Определим тип для события проверки активности строки
  TGetRowActiveEvent = function(Sender: TObject; Row: Integer): Boolean of object;

  TErrorIndicatorColumn = class(TColumn)
  private
    FMaxError: Double;
    FOnGetRowActive: TGetRowActiveEvent;
    function GetErrorValue(const Value: TValue): Double;
    function GetCentralBlockColor(ActiveSegments: Integer): TAlphaColor;
    function GetSegmentColor(SegmentIndex: Integer): TAlphaColor;
    procedure SetMaxError(const Value: Double);
  protected
    function CanEdit: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DrawCell(const Canvas: TCanvas; const Bounds: TRectF; const Row: Integer; const Value: TValue;
      const State: TGridDrawStates); override;
  published
    property MaxError: Double read FMaxError write SetMaxError;
    property OnGetRowActive: TGetRowActiveEvent read FOnGetRowActive write FOnGetRowActive;
  end;

procedure Register;

implementation

uses
  MAth;

procedure Register;
begin
  RegisterComponents('FP', [TErrorIndicator, TErrorIndicatorColumn]);
end;

{ TErrorIndicator }

constructor TErrorIndicator.Create(AOwner: TComponent);
begin
  inherited;
  Width := 200;
  Height := 80;
  FMaxError := 4.0;
  FCurrentError := -1;
  FDelta := FMaxError / 6;
  StyleLookup := 'errorindicatorstyle';
end;

procedure TErrorIndicator.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    HideAllBars;
    SetCurrentError(0);
  end;
end;

procedure TErrorIndicator.ApplyStyle;
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    HideAllBars;
    SetCurrentError(FCurrentError);
  end;
end;

function TErrorIndicator.FindBarByName(const AName: string): TRectangle;
var
  Obj: TFMXObject;
begin
  Result := nil;
  Obj := FindStyleResource(AName);
  if (Obj <> nil) and (Obj is TRectangle) then
    Result := TRectangle(Obj);
end;

procedure TErrorIndicator.UpdateCentralDigit;
var
  CentralDigit, ValueText: TFMXObject;
begin
  CentralDigit := FindStyleResource('cental_digit_style');
  if CentralDigit = nil then
    CentralDigit := FindStyleResource('central_digit_style');

  ValueText := FindStyleResource('text_value_style');

  if (CentralDigit <> nil) and (ValueText <> nil) then
  begin
    if ValueText is TText then
    begin
      TText(ValueText).Text := Format('%.1f%%', [FCurrentError]);
      if AbsError >= FDelta * 6 then
        TText(ValueText).TextSettings.FontColor := TAlphaColorRec.White
      else
        TText(ValueText).TextSettings.FontColor := TAlphaColorRec.Black;
    end;

    if CentralDigit is TRectangle then
      TRectangle(CentralDigit).Fill.Color := FMarginColor;
  end;
end;

procedure TErrorIndicator.HideAllBars;
var
  I: Integer;
  Bar: TRectangle;
  BarName: string;
begin
  FMarginColor := TAlphaColorRec.Lawngreen;

  for I := 0 to ChildrenCount - 1 do
  begin
    if Children[I] is TRectangle then
    begin
      Bar := TRectangle(Children[I]);
      BarName := Bar.StyleName;

      if (BarName.StartsWith('l') or BarName.StartsWith('r')) and
         BarName.Contains('barstyle') then
      begin
        Bar.Opacity := 0;
      end;
    end;
  end;
end;

procedure TErrorIndicator.UpdateBarsVisibility;

  procedure SetBarVisible(const BarStyleName: string; Visible: Boolean);
  var
    Bar: TRectangle;
  begin
    Bar := FindBarByName(BarStyleName);
    if Bar <> nil then
    begin
      if Visible then
      begin
        Bar.Opacity := 1;
        FMarginColor := Bar.Fill.Color;
      end
      else
      begin
        Bar.Opacity := 0;
      end;
    end;
  end;

begin
  FAbsError := Abs(FCurrentError);
  HideAllBars;

  if FCurrentError > 0 then
  begin
    SetBarVisible('l2barstyle', False);
    SetBarVisible('l3barstyle', False);
    SetBarVisible('l4barstyle', False);
    SetBarVisible('l5barstyle', False);
    SetBarVisible('l6barstyle', False);
    SetBarVisible('l7barstyle', False);

    SetBarVisible('r2barstyle', AbsError >= FDelta * 2);
    SetBarVisible('r3barstyle', AbsError >= FDelta * 3);
    SetBarVisible('r4barstyle', AbsError >= FDelta * 4);
    SetBarVisible('r5barstyle', AbsError >= FDelta * 5);
    SetBarVisible('r6barstyle', AbsError >= FDelta * 6);
    SetBarVisible('r7barstyle', AbsError >= FDelta * 7);
  end
  else if FCurrentError < 0 then
  begin
    SetBarVisible('r2barstyle', False);
    SetBarVisible('r3barstyle', False);
    SetBarVisible('r4barstyle', False);
    SetBarVisible('r5barstyle', False);
    SetBarVisible('r6barstyle', False);
    SetBarVisible('r7barstyle', False);

    SetBarVisible('l2barstyle', AbsError >= FDelta * 2);
    SetBarVisible('l3barstyle', AbsError >= FDelta * 3);
    SetBarVisible('l4barstyle', AbsError >= FDelta * 4);
    SetBarVisible('l5barstyle', AbsError >= FDelta * 5);
    SetBarVisible('l6barstyle', AbsError >= FDelta * 6);
    SetBarVisible('l7barstyle', AbsError >= FDelta * 7);
  end;
end;

procedure TErrorIndicator.SetAbsError(const Value: Double);
begin
  FAbsError := Value;
end;

procedure TErrorIndicator.SetCurrentError(const Value: Double);
begin
  if FCurrentError <> Value then
  begin
    FCurrentError := Value;
    if not (csLoading in ComponentState) and (Scene <> nil) then
    begin
      UpdateBarsVisibility;
      UpdateCentralDigit;
    end;
  end;
end;

procedure TErrorIndicator.SetMaxError(const Value: Double);
begin
  if FMaxError <> Value then
  begin
    FMaxError := Value;
    FDelta := FMaxError / 6;
    SetCurrentError(FCurrentError);
  end;
end;

{ TErrorIndicatorColumn }

constructor TErrorIndicatorColumn.Create(AOwner: TComponent);
begin
  inherited;
  Width := 120;
end;

function TErrorIndicatorColumn.CanEdit: Boolean;
begin
  Result := False; // Столбец не редактируемый
end;


function TErrorIndicatorColumn.GetSegmentColor(SegmentIndex: Integer): TAlphaColor;
begin
  case SegmentIndex of
    1: Result := $FF66FF00; // Светло-зеленый
    2: Result := $FF66FF00; // Светло-зеленый
    3: Result := $FFADFF2F; // Зелено-желтый
    4: Result := $FFFFFF00; // Желтый
    5: Result := $FFFF4500; // Оранжево-красный
    6: Result := $FFFF0000; // Красный
  else
    Result := $FF66FF00;
  end;
end;

procedure TErrorIndicatorColumn.SetMaxError(const Value: Double);
begin
  FMaxError := Value;
end;

function TErrorIndicatorColumn.GetCentralBlockColor(ActiveSegments: Integer): TAlphaColor;
begin
  case ActiveSegments of
    6: Result := $FFFF0000;    // Красный
    5: Result := $FFFF4500;    // Оранжево-красный
    4: Result := $FFFFFF00;    // Желтый
    3: Result := $FFADFF2F;    // Зелено-желтый
    2: Result := $FF66FF00;    // Светло-зеленый
    1: Result := $FF66FF00;    // Светло-зеленый
  else
    Result := $FF66FF00;       // По умолчанию светло-зеленый
  end;
end;

function TErrorIndicatorColumn.GetErrorValue(const Value: TValue): Double;
begin
  Result := 0.0;
  if not Value.IsEmpty then
  begin
    case Value.Kind of
      tkFloat: Result := Value.AsExtended;
      tkInteger: Result := Value.AsInteger;
      tkString, tkLString, tkWString, tkUString:
        begin
          var StrValue := Value.ToString.Replace(',', '.');
          if not TryStrToFloat(StrValue, Result) then
            Result := 0.0;
        end;
    else
      if not TryStrToFloat(Value.ToString, Result) then
        Result := 0.0;
    end;
  end;
end;

procedure TErrorIndicatorColumn.DrawCell(const Canvas: TCanvas;
  const Bounds: TRectF; const Row: Integer; const Value: TValue;
  const State: TGridDrawStates);
var
  ErrorValue: Double;
  AbsError: Double;
  Text: string;
  CenterX, CenterY: Single;
  I: Integer;
  SegmentRect: TRectF;
  SegmentColor: TAlphaColor;
  ActiveSegments: Integer;
  InnerBounds: TRectF;
  IsRowActive: Boolean;
begin
  // Фон ячейки
  if TGridDrawState.Selected in State then
    Canvas.Fill.Color := $FFF0F8FF
  else if Row mod 2 = 0 then
    Canvas.Fill.Color := TAlphaColors.White
  else
    Canvas.Fill.Color := $FFF8F8F8;

  Canvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  // Проверяем активность строки
  IsRowActive := True; // По умолчанию активна
  if Assigned(FOnGetRowActive) then
    IsRowActive := FOnGetRowActive(Self, Row);

  // Если строка неактивна - рисуем только фон и выходим
  if not IsRowActive then
  begin
    // Рамка ячейки (сетка)
    Canvas.Stroke.Color := $FFCCCCCC;
    Canvas.Stroke.Thickness := 1;
    Canvas.DrawRect(Bounds, 0, 0, AllCorners, 1);
    Exit;
  end;

  // Внутренняя область с минимальными отступами
  InnerBounds := RectF(
    Bounds.Left + 1,
    Bounds.Top + 1,
    Bounds.Right - 1,
    Bounds.Bottom - 1
  );

  // Получаем значение ошибки
  ErrorValue := GetErrorValue(Value);
  AbsError := Abs(ErrorValue);

  CenterX := InnerBounds.Left + InnerBounds.Width / 2;
  CenterY := InnerBounds.Top + InnerBounds.Height / 2;

  // Размеры элементов - БЕЗ РАССТОЯНИЙ МЕЖДУ СЕГМЕНТАМИ
  var SegmentWidth: Single := 7;
  var SegmentHeight: Single := InnerBounds.Height * 0.6;
  var CentralBlockWidth: Single := 45;
  var CentralBlockHeight: Single := InnerBounds.Height * 1;

  ActiveSegments := 0;

  // Рисуем левые сегменты (отрицательные ошибки)
  for I := 1 to 6 do
  begin
    SegmentRect := RectF(
      CenterX - CentralBlockWidth/2 - I * SegmentWidth,
      CenterY - SegmentHeight / 2,
      CenterX - CentralBlockWidth/2 - (I - 1) * SegmentWidth,
      CenterY + SegmentHeight / 2
    );

    if ErrorValue < 0 then
    begin
      if AbsError >= I * 0.5 then
      begin
        SegmentColor := GetSegmentColor(I);
        ActiveSegments := Max(ActiveSegments, I);
        Canvas.Fill.Color := SegmentColor;
        Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
      end
      else
      begin
        Canvas.Fill.Color := TAlphaColors.Null;
        Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
      end;
    end
    else
    begin
      Canvas.Fill.Color := TAlphaColors.Null;
      Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
    end;

    Canvas.Stroke.Color := TAlphaColors.Black;
    Canvas.Stroke.Thickness := 0.5;
    Canvas.DrawRect(SegmentRect, 0, 0, AllCorners, 1);
  end;

  // Рисуем правые сегменты (положительные ошибки)
  for I := 1 to 6 do
  begin
    SegmentRect := RectF(
      CenterX + CentralBlockWidth/2 + (I - 1) * SegmentWidth,
      CenterY - SegmentHeight / 2,
      CenterX + CentralBlockWidth/2 + I * SegmentWidth,
      CenterY + SegmentHeight / 2
    );

    if ErrorValue > 0 then
    begin
      if AbsError >= I * 0.5 then
      begin
        SegmentColor := GetSegmentColor(I);
        ActiveSegments := Max(ActiveSegments, I);
        Canvas.Fill.Color := SegmentColor;
        Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
      end
      else
      begin
        Canvas.Fill.Color := TAlphaColors.Null;
        Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
      end;
    end
    else
    begin
      Canvas.Fill.Color := TAlphaColors.Null;
      Canvas.FillRect(SegmentRect, 0, 0, AllCorners, 1);
    end;

    Canvas.Stroke.Color := TAlphaColors.Black;
    Canvas.Stroke.Thickness := 0.5;
    Canvas.DrawRect(SegmentRect, 0, 0, AllCorners, 1);
  end;

  // Центральный блок
  var CentralRect := RectF(
    CenterX - CentralBlockWidth / 2,
    CenterY - CentralBlockHeight / 2,
    CenterX + CentralBlockWidth / 2,
    CenterY + CentralBlockHeight / 2
  );

  // Цвет центрального блока
  Canvas.Fill.Color := GetCentralBlockColor(ActiveSegments);
  Canvas.FillRect(CentralRect, 0, 0, AllCorners, 1);

  // Обводка центрального блока
  Canvas.Stroke.Color := $FF606060;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawRect(CentralRect, 0, 0, AllCorners, 1);

  // Текст в центральном блоке
  Text := Format('%.2f', [ErrorValue]);

  // Цвет текста
  if (ActiveSegments >= 5) then
    Canvas.Fill.Color := TAlphaColors.White
  else
    Canvas.Fill.Color := TAlphaColors.Black;

  Canvas.Font.Size := 11;
  Canvas.Font.Style := [TFontStyle.fsBold];

  Canvas.FillText(
    CentralRect,
    Text,
    False, 1, [], TTextAlign.Center, TTextAlign.Center
  );

  // Рамка ячейки (сетка)
  Canvas.Stroke.Color := $FFCCCCCC;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawRect(Bounds, 0, 0, AllCorners, 1);
end;

initialization
  RegisterClass(TErrorIndicator);
end.
