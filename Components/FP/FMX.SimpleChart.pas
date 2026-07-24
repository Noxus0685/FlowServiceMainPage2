unit FMX.SimpleChart;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Math,
  System.Generics.Collections,
  System.UITypes,
  System.Math.Vectors,
  FMX.Controls, FMX.Types, FMX.Graphics, FMX.Forms;

type
  // ---------------------------------------------------------------------------
  // Серия данных (одна линия на графике)
  // ---------------------------------------------------------------------------
  TChartSeries = class
  private
    FPoints: TList<TPointF>;
    FColor: TAlphaColor;
    FThickness: Single;
    FShowMarkers: Boolean;
    FMarkerRadius: Single;
    FLegendName: string;
    FVisible: Boolean;
    procedure SetColor(const Value: TAlphaColor);
    procedure SetThickness(const Value: Single);
    procedure SetShowMarkers(const Value: Boolean);
    procedure SetMarkerRadius(const Value: Single);
    procedure SetLegendName(const Value: string);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddPoint(X, Y: Double);
    procedure ClearPoints;
    property Points: TList<TPointF> read FPoints;
    property Color: TAlphaColor read FColor write SetColor;
    property Thickness: Single read FThickness write SetThickness;
    property ShowMarkers: Boolean read FShowMarkers write SetShowMarkers;
    property MarkerRadius: Single read FMarkerRadius write SetMarkerRadius;
    property LegendName: string read FLegendName write SetLegendName;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  // ---------------------------------------------------------------------------
  // Многосерийный график
  // ---------------------------------------------------------------------------
  TSimpleChart = class(TControl)
  private
    FSeries: TObjectList<TChartSeries>;
    FAutoRangeX: Boolean;
    FAutoRangeY: Boolean;
    FAutoRangeOnClear: Boolean;
    FUpdating: Boolean;
    FXMin, FXMax: Double;
    FYMin, FYMax: Double;
    // Глобальные настройки (применяются к первой серии для обратной совместимости)
    FLineColor: TAlphaColor;
    FLineThickness: Single;
    FShowGrid: Boolean;
    FShowMarkers: Boolean;
    FMarkerRadius: Single;
    FGridColor: TAlphaColor;
    FAxisColor: TAlphaColor;
    FBackgroundColor: TAlphaColor;
    FMarginLeft, FMarginRight, FMarginTop, FMarginBottom: Single;
    FTitle: string;
    FXTitle: string;
    FYTitle: string;
    FXTitleOffset: Single;
    FYTitleOffset: Single;
    // Вспомогательные методы
    procedure SetAutoRangeX(const Value: Boolean);
    procedure SetAutoRangeY(const Value: Boolean);
    procedure SetXMin(const Value: Double);
    procedure SetXMax(const Value: Double);
    procedure SetYMin(const Value: Double);
    procedure SetYMax(const Value: Double);
    // Совместимость со старыми свойствами
    procedure SetLineColor(const Value: TAlphaColor);
    procedure SetLineThickness(const Value: Single);
    procedure SetShowGrid(const Value: Boolean);
    procedure SetShowMarkers(const Value: Boolean);
    procedure SetMarkerRadius(const Value: Single);
    procedure SetGridColor(const Value: TAlphaColor);
    procedure SetAxisColor(const Value: TAlphaColor);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetMarginLeft(const Value: Single);
    procedure SetMarginRight(const Value: Single);
    procedure SetMarginTop(const Value: Single);
    procedure SetMarginBottom(const Value: Single);
    procedure SetTitle(const Value: string);
    procedure SetXTitle(const Value: string);
    procedure SetYTitle(const Value: string);
    procedure SetFXTitleOffset(const Value: Single);
    procedure SetFYTitleOffset(const Value: Single);
  protected
    procedure Paint; override;
    procedure UpdateRanges;
    function WorldToScreen(const Value: TPointF): TPointF;
    function GetNiceTicks(minVal, maxVal: Double; approxTicks: Integer): TArray<Double>;
    procedure DrawAxesAndGrid;    // рисует оси, сетку, подписи, заголовки
    procedure DrawSeries;         // рисует все видимые серии
    procedure DrawMarkersForSeries(Series: TChartSeries); // маркеры для одной серии
    function GetSeries(Index: Integer): TChartSeries;
    function GetSeriesCount: Integer;
    function GetFirstSeriesPoints: TList<TPointF>;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Управление сериями
    function AddSeries(const ALegendName: string = ''): TChartSeries;
    procedure RemoveSeries(Index: Integer);
    procedure ClearAllSeries;
    property Series[Index: Integer]: TChartSeries read GetSeries;
    property SeriesCount: Integer read GetSeriesCount;
    // Совместимость со старым интерфейсом (работа с первой серией)
    procedure AddPoint(X, Y: Double);
    procedure ClearPoints;
    procedure InvalidateChart;
    procedure BeginUpdate;
    procedure EndUpdate;
    property Points: TList<TPointF> read GetFirstSeriesPoints; // опасно, но для совместимости
  published
    property Align;
    property Anchors;
    property Margins;
    property Padding;
    property Visible;
    property Enabled;

    // Глобальные настройки осей и диапазонов
    property AutoRangeX: Boolean read FAutoRangeX write SetAutoRangeX default True;
    property AutoRangeY: Boolean read FAutoRangeY write SetAutoRangeY default True;
    property AutoRangeOnClear: Boolean read FAutoRangeOnClear write FAutoRangeOnClear default True;
    property XMin: Double read FXMin write SetXMin;
    property XMax: Double read FXMax write SetXMax;
    property YMin: Double read FYMin write SetYMin;
    property YMax: Double read FYMax write SetYMax;

    // Свойства для обратной совместимости (применяются к первой серии)
    property LineColor: TAlphaColor read FLineColor write SetLineColor;
    property LineThickness: Single read FLineThickness write SetLineThickness;
    property ShowMarkers: Boolean read FShowMarkers write SetShowMarkers;
    property MarkerRadius: Single read FMarkerRadius write SetMarkerRadius;

    // Оформление
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property GridColor: TAlphaColor read FGridColor write SetGridColor;
    property AxisColor: TAlphaColor read FAxisColor write SetAxisColor;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property MarginLeft: Single read FMarginLeft write SetMarginLeft;
    property MarginRight: Single read FMarginRight write SetMarginRight;
    property MarginTop: Single read FMarginTop write SetMarginTop;
    property MarginBottom: Single read FMarginBottom write SetMarginBottom;
    property Title: string read FTitle write SetTitle;
    property XTitle: string read FXTitle write SetXTitle;
    property YTitle: string read FYTitle write SetYTitle;
    property XTitleOffset: Single read FXTitleOffset write SetFXTitleOffset;
    property YTitleOffset: Single read FYTitleOffset write SetFYTitleOffset;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Charts', [TSimpleChart]);
end;

// =============================================================================
// TChartSeries
// =============================================================================

constructor TChartSeries.Create;
begin
  FPoints := TList<TPointF>.Create;
  FColor := $FF0000FF;   // синий
  FThickness := 2;
  FShowMarkers := True;
  FMarkerRadius := 3;
  FLegendName := '';
  FVisible := True;
end;

destructor TChartSeries.Destroy;
begin
  FPoints.Free;
  inherited;
end;

procedure TChartSeries.AddPoint(X, Y: Double);
begin
  FPoints.Add(TPointF.Create(X, Y));
end;

procedure TChartSeries.ClearPoints;
begin
  FPoints.Clear;
end;

procedure TChartSeries.SetColor(const Value: TAlphaColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    // Уведомление владельца о необходимости перерисовки – делегируем графику
  end;
end;

procedure TChartSeries.SetThickness(const Value: Single);
begin
  if not SameValue(FThickness, Value) then
    FThickness := Value;
end;

procedure TChartSeries.SetShowMarkers(const Value: Boolean);
begin
  if FShowMarkers <> Value then
    FShowMarkers := Value;
end;

procedure TChartSeries.SetMarkerRadius(const Value: Single);
begin
  if not SameValue(FMarkerRadius, Value) then
    FMarkerRadius := Value;
end;

procedure TChartSeries.SetLegendName(const Value: string);
begin
  if FLegendName <> Value then
    FLegendName := Value;
end;

procedure TChartSeries.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
    FVisible := Value;
end;

// =============================================================================
// TSimpleChart
// =============================================================================

constructor TSimpleChart.Create(AOwner: TComponent);
begin
  inherited;
  FSeries := TObjectList<TChartSeries>.Create(True); // владеет объектами
  // Создаём серию по умолчанию
  FSeries.Add(TChartSeries.Create);

  FAutoRangeX := True;
  FAutoRangeY := True;
  FAutoRangeOnClear := True;
  FUpdating := False;
  FXMin := 0;
  FXMax := 100;
  FYMin := 0;
  FYMax := 100;
  FLineColor := $FF0000FF;
  FLineThickness := 2;
  FShowGrid := True;
  FShowMarkers := True;
  FMarkerRadius := 3;
  FGridColor := $FFCCCCCC;
  FAxisColor := $FF000000;
  FBackgroundColor := $FFFFFFFF;
  FMarginLeft := 40;
  FMarginRight := 20;
  FMarginTop := 40;
  FMarginBottom := 40;
  FTitle := '';
  FXTitle := '';
  FYTitle := '';
  FXTitleOffset := 5;
  FYTitleOffset := 30;
  Width := 400;
  Height := 300;
end;

destructor TSimpleChart.Destroy;
begin
  FSeries.Free;
  inherited;
end;

// -----------------------------------------------------------------------------
// Управление сериями
// -----------------------------------------------------------------------------
function TSimpleChart.AddSeries(const ALegendName: string): TChartSeries;
begin
  Result := TChartSeries.Create;
  Result.LegendName := ALegendName;
  // Наследуем цвет/толщину от первой серии (если есть)
  if FSeries.Count > 0 then
  begin
    Result.Color := FSeries[0].Color;
    Result.Thickness := FSeries[0].Thickness;
    Result.ShowMarkers := FSeries[0].ShowMarkers;
    Result.MarkerRadius := FSeries[0].MarkerRadius;
  end;
  FSeries.Add(Result);
  UpdateRanges;
  Repaint;
end;

procedure TSimpleChart.RemoveSeries(Index: Integer);
begin
  if (Index >= 0) and (Index < FSeries.Count) then
  begin
    FSeries.Delete(Index);
    if FSeries.Count = 0 then // оставляем хотя бы одну пустую серию
      FSeries.Add(TChartSeries.Create);
    UpdateRanges;
    Repaint;
  end;
end;

procedure TSimpleChart.ClearAllSeries;
begin
  FSeries.Clear;
  UpdateRanges;
  Repaint;
end;

function TSimpleChart.GetSeries(Index: Integer): TChartSeries;
begin
  Result := FSeries[Index];
end;

function TSimpleChart.GetSeriesCount: Integer;
begin
  Result := FSeries.Count;
end;

// -----------------------------------------------------------------------------
// Совместимость со старым кодом
// -----------------------------------------------------------------------------
function TSimpleChart.GetFirstSeriesPoints: TList<TPointF>;
begin
  if FSeries.Count > 0 then
    Result := FSeries[0].Points
  else
    Result := nil;
end;

procedure TSimpleChart.AddPoint(X, Y: Double);
begin
  if FSeries.Count = 0 then
    FSeries.Add(TChartSeries.Create);
  FSeries[0].AddPoint(X, Y);
  if not FUpdating then
  begin
    if FAutoRangeX or FAutoRangeY then
      UpdateRanges;
    Repaint;
  end;
end;

procedure TSimpleChart.ClearPoints;
begin
  if FSeries.Count > 0 then
    FSeries[0].ClearPoints;
  if FAutoRangeOnClear then
  begin
    FAutoRangeX := True;
    FAutoRangeY := True;
  end;
  UpdateRanges;
  if not FUpdating then
    Repaint;
end;

procedure TSimpleChart.BeginUpdate;
begin
  FUpdating := True;
end;

procedure TSimpleChart.EndUpdate;
begin
  FUpdating := False;
  UpdateRanges;
  Repaint;
end;

procedure TSimpleChart.InvalidateChart;
begin
  UpdateRanges;
  if not FUpdating then
    Repaint;
end;

// -----------------------------------------------------------------------------
// Расчет диапазонов по всем сериям
// -----------------------------------------------------------------------------
procedure TSimpleChart.UpdateRanges;
var
  i, j: Integer;
  minX, maxX, minY, maxY: Double;
  p: TPointF;
  anyPoint: Boolean;
begin
  anyPoint := False;
  minX := 0; maxX := 0; minY := 0; maxY := 0; // ← инициализация
  for i := 0 to FSeries.Count - 1 do
  begin
    if FSeries[i].Points.Count = 0 then Continue;
    if not anyPoint then
    begin
      p := FSeries[i].Points[0];
      minX := p.X; maxX := p.X;
      minY := p.Y; maxY := p.Y;
      anyPoint := True;
    end;
    for j := 0 to FSeries[i].Points.Count - 1 do
    begin
      p := FSeries[i].Points[j];
      if p.X < minX then minX := p.X;
      if p.X > maxX then maxX := p.X;
      if p.Y < minY then minY := p.Y;
      if p.Y > maxY then maxY := p.Y;
    end;
  end;

  if not anyPoint then
  begin
    if FAutoRangeX then
    begin
      FXMin := 0;
      FXMax := 100;
    end;
    if FAutoRangeY then
    begin
      FYMin := 0;
      FYMax := 100;
    end;
    Exit;
  end;

  if FAutoRangeX then
  begin
    if SameValue(minX, maxX) then
    begin
      FXMin := minX - 1;
      FXMax := maxX + 1;
    end
    else
    begin
      FXMin := minX;
      FXMax := maxX;
    end;
  end;

  if FAutoRangeY then
  begin
    if SameValue(minY, maxY) then
    begin
      FYMin := minY - 1;
      FYMax := maxY + 1;
    end
    else
    begin
      FYMin := minY;
      FYMax := maxY;
    end;
  end;
end;

// -----------------------------------------------------------------------------
// Преобразование мировых координат в экранные
// -----------------------------------------------------------------------------
function TSimpleChart.WorldToScreen(const Value: TPointF): TPointF;
var
  plotRect: TRectF;
begin
  plotRect := TRectF.Create(
    MarginLeft,
    MarginTop,
    Width - MarginRight,
    Height - MarginBottom
  );
  Result.X := plotRect.Left + (Value.X - FXMin) / (FXMax - FXMin) * plotRect.Width;
  Result.Y := plotRect.Bottom - (Value.Y - FYMin) / (FYMax - FYMin) * plotRect.Height;
end;

// -----------------------------------------------------------------------------
// Красивые метки на осях
// -----------------------------------------------------------------------------
function TSimpleChart.GetNiceTicks(minVal, maxVal: Double; approxTicks: Integer): TArray<Double>;
var
  rangeVal, step: Double;
  stepExp: Integer;
  stepMantissa: Double;
  tick: Double;
  list: TList<Double>;
begin
  SetLength(Result, 0);
  if maxVal <= minVal then
    Exit;

  rangeVal := maxVal - minVal;
  step := rangeVal / approxTicks;
  stepExp := Floor(Log10(step));
  stepMantissa := step / Power(10, stepExp);
  if stepMantissa < 1.5 then
    stepMantissa := 1
  else if stepMantissa < 3.5 then
    stepMantissa := 2
  else if stepMantissa < 7.5 then
    stepMantissa := 5
  else
    stepMantissa := 10;
  step := stepMantissa * Power(10, stepExp);

  tick := Ceil(minVal / step) * step;
  list := TList<Double>.Create;
  try
    while tick <= maxVal + step/1000 do
    begin
      list.Add(tick);
      tick := tick + step;
    end;
    Result := list.ToArray;
  finally
    list.Free;
  end;
end;

// -----------------------------------------------------------------------------
// Отрисовка осей, сетки, подписей и заголовков
// -----------------------------------------------------------------------------
procedure TSimpleChart.DrawAxesAndGrid;
var
  Canvas: TCanvas;
  plotRect: TRectF;
  xTicks, yTicks: TArray<Double>;
  i: Integer;
  tickVal: Double;
  p1, p2: TPointF;
  textRect: TRectF;
  txt: string;
  corners: TCorners;
  SaveState: TCanvasSaveState;
  CenterY: Single;
begin
  Canvas := Self.Canvas;
  if Canvas = nil then Exit;

  if FAutoRangeX or FAutoRangeY then
    UpdateRanges;

  corners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight];
  plotRect := TRectF.Create(
    MarginLeft,
    MarginTop,
    Width - MarginRight,
    Height - MarginBottom
  );

  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  // Фон
  Canvas.Fill.Color := FBackgroundColor;
  Canvas.FillRect(TRectF.Create(0, 0, Width, Height), 0, 0, corners, 1);

  // Сетка
  if FShowGrid then
  begin
    Canvas.Stroke.Color := FGridColor;
    xTicks := GetNiceTicks(FXMin, FXMax, 8);
    for i := 0 to Length(xTicks) - 1 do
    begin
      tickVal := xTicks[i];
      p1 := WorldToScreen(TPointF.Create(tickVal, FYMax));
      p2 := TPointF.Create(p1.X, plotRect.Bottom);
      Canvas.DrawLine(p1, p2, 1);
    end;
    yTicks := GetNiceTicks(FYMin, FYMax, 6);
    for i := 0 to Length(yTicks) - 1 do
    begin
      tickVal := yTicks[i];
      p1 := WorldToScreen(TPointF.Create(0, tickVal));
      p2 := TPointF.Create(plotRect.Right, p1.Y);
      Canvas.DrawLine(p1, p2, 1);
    end;
  end;

  // Оси
  Canvas.Stroke.Color := FAxisColor;
  Canvas.Stroke.Thickness := 1.5;
  p1 := TPointF.Create(plotRect.Left, plotRect.Top);
  p2 := TPointF.Create(plotRect.Left, plotRect.Bottom);
  Canvas.DrawLine(p1, p2, 1);
  p1 := TPointF.Create(plotRect.Left, plotRect.Bottom);
  p2 := TPointF.Create(plotRect.Right, plotRect.Bottom);
  Canvas.DrawLine(p1, p2, 1);

  // Y-метки
  Canvas.Fill.Color := FAxisColor;
  Canvas.Font.Size := 10;
  yTicks := GetNiceTicks(FYMin, FYMax, 6);
  for i := 0 to Length(yTicks) - 1 do
  begin
    tickVal := yTicks[i];
    p1 := WorldToScreen(TPointF.Create(FXMin, tickVal));
    p2 := TPointF.Create(plotRect.Left - 5, p1.Y);
    Canvas.DrawLine(p1, p2, 1);
    txt := FormatFloat('0.###', tickVal);
    textRect := TRectF.Create(plotRect.Left - 35, p1.Y - 8, plotRect.Left - 5, p1.Y + 8);
    if textRect.Top < 0 then
      textRect := TRectF.Create(plotRect.Left - 35, 0, plotRect.Left - 5, 16);
    if textRect.Bottom > Height then
      textRect := TRectF.Create(plotRect.Left - 35, Height - 16, plotRect.Left - 5, Height);
    Canvas.FillText(textRect, txt, False, 1, [], TTextAlign.Trailing, TTextAlign.Center);
  end;

  // X-метки
  xTicks := GetNiceTicks(FXMin, FXMax, 8);
  for i := 0 to Length(xTicks) - 1 do
  begin
    tickVal := xTicks[i];
    p1 := WorldToScreen(TPointF.Create(tickVal, FYMin));
    p2 := TPointF.Create(p1.X, plotRect.Bottom + 5);
    Canvas.DrawLine(p1, p2, 1);
    txt := FormatFloat('0.###', tickVal);
    textRect := TRectF.Create(p1.X - 25, plotRect.Bottom + 5, p1.X + 25, plotRect.Bottom + 25);
    if textRect.Right > Width then
      textRect := TRectF.Create(Width - 50, textRect.Top, Width - 5, textRect.Bottom);
    if textRect.Left < 0 then
      textRect := TRectF.Create(5, textRect.Top, 55, textRect.Bottom);
    Canvas.FillText(textRect, txt, False, 1, [], TTextAlign.Center, TTextAlign.Leading);
  end;

  // X Title
  if FXTitle <> '' then
  begin
    textRect := TRectF.Create(plotRect.Left, Height - MarginBottom + FXTitleOffset, plotRect.Right, Height - 5 + FXTitleOffset);
    Canvas.FillText(textRect, FXTitle, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  end;

  // Y Title (с поворотом)
  if FYTitle <> '' then
  begin
    SaveState := Canvas.SaveState;
    try
      Canvas.MultiplyMatrix(TMatrix.CreateRotation(-Pi/2));
      CenterY := (plotRect.Top + plotRect.Bottom) / 2;
      textRect := TRectF.Create(
        -CenterY - 30,
        FYTitleOffset - 40,
        -CenterY + 30,
        FYTitleOffset + 40
      );
      Canvas.FillText(textRect, FYTitle, False, 1, [], TTextAlign.Center, TTextAlign.Center);
    finally
      Canvas.RestoreState(SaveState);
    end;
  end;

  // Chart Title
  if FTitle <> '' then
  begin
    textRect := TRectF.Create(0, 5, Width, MarginTop - 5);
    Canvas.FillText(textRect, FTitle, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  end;
end;

// -----------------------------------------------------------------------------
// Отрисовка маркеров для одной серии
// -----------------------------------------------------------------------------
procedure TSimpleChart.DrawMarkersForSeries(Series: TChartSeries);
var
  i: Integer;
  screenPt: TPointF;
begin
  Canvas.Fill.Color := Series.Color;
  Canvas.Stroke.Color := FAxisColor;
  Canvas.Stroke.Thickness := 1;
  for i := 0 to Series.Points.Count - 1 do
  begin
    screenPt := WorldToScreen(Series.Points[i]);
    Canvas.FillEllipse(RectF(screenPt.X - Series.MarkerRadius,
                             screenPt.Y - Series.MarkerRadius,
                             screenPt.X + Series.MarkerRadius,
                             screenPt.Y + Series.MarkerRadius), 1);
  end;
end;

// -----------------------------------------------------------------------------
// Отрисовка всех серий (линий и маркеров)
// -----------------------------------------------------------------------------
procedure TSimpleChart.DrawSeries;
var
  i, j: Integer;
  screenPoints: TArray<TPointF>;
  series: TChartSeries;
begin
  for i := 0 to FSeries.Count - 1 do
  begin
    series := FSeries[i];
    if not series.Visible then Continue;
    if series.Points.Count <= 1 then Continue;

    SetLength(screenPoints, series.Points.Count);
    for j := 0 to series.Points.Count - 1 do
      screenPoints[j] := WorldToScreen(series.Points[j]);

    Canvas.Stroke.Color := series.Color;
    Canvas.Stroke.Thickness := series.Thickness;
    Canvas.Stroke.Kind := TBrushKind.Solid;

    for j := 0 to Length(screenPoints) - 2 do
      Canvas.DrawLine(screenPoints[j], screenPoints[j+1], 1);

    if series.ShowMarkers then
      DrawMarkersForSeries(series);
  end;
end;

// -----------------------------------------------------------------------------
// Основной метод отрисовки
// -----------------------------------------------------------------------------
procedure TSimpleChart.Paint;
begin
  inherited;
  if FSeries = nil then Exit;
  Canvas.BeginScene;
  try
    DrawAxesAndGrid;
    DrawSeries;
  finally
    Canvas.EndScene;
  end;
end;

// -----------------------------------------------------------------------------
// Свойства для обратной совместимости (действуют на первую серию)
// -----------------------------------------------------------------------------
procedure TSimpleChart.SetLineColor(const Value: TAlphaColor);
begin
  if FLineColor <> Value then
  begin
    FLineColor := Value;
    if FSeries.Count > 0 then
      FSeries[0].Color := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetLineThickness(const Value: Single);
begin
  if not SameValue(FLineThickness, Value) then
  begin
    FLineThickness := Value;
    if FSeries.Count > 0 then
      FSeries[0].Thickness := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetShowMarkers(const Value: Boolean);
begin
  if FShowMarkers <> Value then
  begin
    FShowMarkers := Value;
    if FSeries.Count > 0 then
      FSeries[0].ShowMarkers := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetMarkerRadius(const Value: Single);
begin
  if not SameValue(FMarkerRadius, Value) then
  begin
    FMarkerRadius := Value;
    if FSeries.Count > 0 then
      FSeries[0].MarkerRadius := Value;
    Repaint;
  end;
end;

// Остальные сеттеры без изменений
procedure TSimpleChart.SetAutoRangeX(const Value: Boolean);
begin
  if FAutoRangeX <> Value then
  begin
    FAutoRangeX := Value;
    if FAutoRangeX then
      UpdateRanges;
    Repaint;
  end;
end;

procedure TSimpleChart.SetAutoRangeY(const Value: Boolean);
begin
  if FAutoRangeY <> Value then
  begin
    FAutoRangeY := Value;
    if FAutoRangeY then
      UpdateRanges;
    Repaint;
  end;
end;

procedure TSimpleChart.SetXMin(const Value: Double);
begin
  if not FAutoRangeX and not SameValue(FXMin, Value) then
  begin
    FXMin := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetXMax(const Value: Double);
begin
  if not FAutoRangeX and not SameValue(FXMax, Value) then
  begin
    FXMax := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetYMin(const Value: Double);
begin
  if not FAutoRangeY and not SameValue(FYMin, Value) then
  begin
    FYMin := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetYMax(const Value: Double);
begin
  if not FAutoRangeY and not SameValue(FYMax, Value) then
  begin
    FYMax := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetShowGrid(const Value: Boolean);
begin
  if FShowGrid <> Value then
  begin
    FShowGrid := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetGridColor(const Value: TAlphaColor);
begin
  if FGridColor <> Value then
  begin
    FGridColor := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetAxisColor(const Value: TAlphaColor);
begin
  if FAxisColor <> Value then
  begin
    FAxisColor := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetBackgroundColor(const Value: TAlphaColor);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetMarginLeft(const Value: Single);
begin
  if not SameValue(FMarginLeft, Value) then
  begin
    FMarginLeft := Max(Value, 5);
    Repaint;
  end;
end;

procedure TSimpleChart.SetMarginRight(const Value: Single);
begin
  if not SameValue(FMarginRight, Value) then
  begin
    FMarginRight := Max(Value, 5);
    Repaint;
  end;
end;

procedure TSimpleChart.SetMarginTop(const Value: Single);
begin
  if not SameValue(FMarginTop, Value) then
  begin
    FMarginTop := Max(Value, 5);
    Repaint;
  end;
end;

procedure TSimpleChart.SetMarginBottom(const Value: Single);
begin
  if not SameValue(FMarginBottom, Value) then
  begin
    FMarginBottom := Max(Value, 5);
    Repaint;
  end;
end;

procedure TSimpleChart.SetTitle(const Value: string);
begin
  if FTitle <> Value then
  begin
    FTitle := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetXTitle(const Value: string);
begin
  if FXTitle <> Value then
  begin
    FXTitle := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetYTitle(const Value: string);
begin
  if FYTitle <> Value then
  begin
    FYTitle := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetFXTitleOffset(const Value: Single);
begin
  if not SameValue(FXTitleOffset, Value) then
  begin
    FXTitleOffset := Value;
    Repaint;
  end;
end;

procedure TSimpleChart.SetFYTitleOffset(const Value: Single);
begin
  if not SameValue(FYTitleOffset, Value) then
  begin
    FYTitleOffset := Value;
    Repaint;
  end;
end;




end.
