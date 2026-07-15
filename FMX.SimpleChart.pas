unit FMX.SimpleChart;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Types,
  System.UITypes,
  FMX.Controls,
  FMX.Graphics,
  FMX.Types;

type
  TChartPoint = record
    X: Double;
    Y: Double;
  end;

  TChartSeries = class(TPersistent)
  private
    FColor: TAlphaColor;
    FMarkerRadius: Single;
    FPoints: TList<TChartPoint>;
    FShowLine: Boolean;
    FShowMarkers: Boolean;
    FThickness: Single;
    FTitle: string;
    FVisible: Boolean;
  public
    constructor Create(const ATitle: string; const AColor: TAlphaColor); reintroduce;
    destructor Destroy; override;
    procedure AddPoint(const AX, AY: Double);
    procedure Clear;
    property Points: TList<TChartPoint> read FPoints;
  published
    property Color: TAlphaColor read FColor write FColor;
    property MarkerRadius: Single read FMarkerRadius write FMarkerRadius;
    property ShowLine: Boolean read FShowLine write FShowLine default True;
    property ShowMarkers: Boolean read FShowMarkers write FShowMarkers default True;
    property Thickness: Single read FThickness write FThickness;
    property Title: string read FTitle write FTitle;
    property Visible: Boolean read FVisible write FVisible default True;
  end;

  TSimpleChart = class(TControl)
  private
    FSeries: TObjectList<TChartSeries>;
    FTitle: string;
    FXTitle: string;
    FYTitle: string;
    FUpdateCount: Integer;
    function NextSeriesColor: TAlphaColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddSeries(const ATitle: string): TChartSeries;
    procedure BeginUpdate;
    procedure ClearAllSeries;
    procedure EndUpdate;
    procedure InvalidateChart;
    property Series: TObjectList<TChartSeries> read FSeries;
  published
    property Align;
    property Anchors;
    property ClipChildren;
    property ClipParent;
    property Cursor;
    property Enabled;
    property Height;
    property HitTest;
    property Margins;
    property Opacity;
    property Padding;
    property Position;
    property Size;
    property TabOrder;
    property Title: string read FTitle write FTitle;
    property Visible;
    property Width;
    property XTitle: string read FXTitle write FXTitle;
    property YTitle: string read FYTitle write FYTitle;
  end;

implementation

const
  CHART_COLORS: array[0..7] of TAlphaColor = (
    TAlphaColorRec.Blue,
    TAlphaColorRec.Red,
    TAlphaColorRec.Green,
    TAlphaColorRec.Orange,
    TAlphaColorRec.Purple,
    TAlphaColorRec.Teal,
    TAlphaColorRec.Brown,
    TAlphaColorRec.Gray
  );

constructor TChartSeries.Create(const ATitle: string; const AColor: TAlphaColor);
begin
  inherited Create;
  FColor := AColor;
  FMarkerRadius := 3;
  FPoints := TList<TChartPoint>.Create;
  FShowLine := True;
  FShowMarkers := True;
  FThickness := 2;
  FTitle := ATitle;
  FVisible := True;
end;

destructor TChartSeries.Destroy;
begin
  FPoints.Free;
  inherited;
end;

procedure TChartSeries.AddPoint(const AX, AY: Double);
var
  P: TChartPoint;
begin
  if IsNan(AX) or IsInfinite(AX) or IsNan(AY) or IsInfinite(AY) then
    Exit;
  P.X := AX;
  P.Y := AY;
  FPoints.Add(P);
end;

procedure TChartSeries.Clear;
begin
  FPoints.Clear;
end;

constructor TSimpleChart.Create(AOwner: TComponent);
begin
  inherited;
  FSeries := TObjectList<TChartSeries>.Create(True);
  CanFocus := False;
end;

destructor TSimpleChart.Destroy;
begin
  FSeries.Free;
  inherited;
end;

function TSimpleChart.NextSeriesColor: TAlphaColor;
begin
  Result := CHART_COLORS[FSeries.Count mod Length(CHART_COLORS)];
end;

function TSimpleChart.AddSeries(const ATitle: string): TChartSeries;
begin
  Result := TChartSeries.Create(ATitle, NextSeriesColor);
  FSeries.Add(Result);
  if FUpdateCount = 0 then
    Repaint;
end;

procedure TSimpleChart.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TSimpleChart.ClearAllSeries;
begin
  FSeries.Clear;
  if FUpdateCount = 0 then
    Repaint;
end;

procedure TSimpleChart.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);
  if FUpdateCount = 0 then
    Repaint;
end;

procedure TSimpleChart.InvalidateChart;
begin
  Repaint;
end;

procedure TSimpleChart.Paint;
var
  Bounds: TRectF;
  ChartRect: TRectF;
  S: TChartSeries;
  I: Integer;
  MinX: Double;
  MaxX: Double;
  MinY: Double;
  MaxY: Double;
  HasPoint: Boolean;

  function MapPoint(const P: TChartPoint): TPointF;
  var
    RX: Double;
    RY: Double;
  begin
    if SameValue(MaxX, MinX) then
      RX := 0.5
    else
      RX := (P.X - MinX) / (MaxX - MinX);
    if SameValue(MaxY, MinY) then
      RY := 0.5
    else
      RY := (P.Y - MinY) / (MaxY - MinY);
    Result.X := ChartRect.Left + RX * ChartRect.Width;
    Result.Y := ChartRect.Bottom - RY * ChartRect.Height;
  end;

var
  P0: TPointF;
  P1: TPointF;
  Pt: TChartPoint;
begin
  inherited;
  Bounds := LocalRect;
  Canvas.Fill.Color := TAlphaColorRec.White;
  Canvas.FillRect(Bounds, 0, 0, [], 1);

  ChartRect := Bounds;
  ChartRect.Inflate(-48, -34);
  ChartRect.Top := ChartRect.Top + 18;
  if (ChartRect.Width <= 0) or (ChartRect.Height <= 0) then
    Exit;

  Canvas.Stroke.Color := TAlphaColorRec.Lightgray;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawRect(ChartRect, 0, 0, [], 1);

  HasPoint := False;
  MinX := 0;
  MaxX := 0;
  MinY := 0;
  MaxY := 0;
  for S in FSeries do
    if S.Visible then
      for Pt in S.Points do
      begin
        if not HasPoint then
        begin
          MinX := Pt.X;
          MaxX := Pt.X;
          MinY := Pt.Y;
          MaxY := Pt.Y;
          HasPoint := True;
        end
        else
        begin
          MinX := Min(MinX, Pt.X);
          MaxX := Max(MaxX, Pt.X);
          MinY := Min(MinY, Pt.Y);
          MaxY := Max(MaxY, Pt.Y);
        end;
      end;

  if not HasPoint then
    Exit;

  for S in FSeries do
  begin
    if (not S.Visible) or (S.Points.Count = 0) then
      Continue;
    Canvas.Stroke.Color := S.Color;
    Canvas.Stroke.Thickness := S.Thickness;
    Canvas.Fill.Color := S.Color;
    if S.ShowLine and (S.Points.Count > 1) then
      for I := 1 to S.Points.Count - 1 do
      begin
        P0 := MapPoint(S.Points[I - 1]);
        P1 := MapPoint(S.Points[I]);
        Canvas.DrawLine(P0, P1, 1);
      end;
    if S.ShowMarkers then
      for I := 0 to S.Points.Count - 1 do
      begin
        P0 := MapPoint(S.Points[I]);
        Canvas.FillEllipse(TRectF.Create(P0.X - S.MarkerRadius, P0.Y - S.MarkerRadius,
          P0.X + S.MarkerRadius, P0.Y + S.MarkerRadius), 1);
      end;
  end;
end;

initialization
  RegisterFmxClasses([TSimpleChart]);

end.
