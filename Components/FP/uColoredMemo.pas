unit uColoredMemo;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.RegularExpressions,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.TextLayout, FMX.StdCtrls, StrUtils;

type
  TFormattedTextAttribute = record
    Range: TTextRange;
    Color: TAlphaColor;
  end;

  TColoredMemo = class(TTextControl)
  private
    FVScrollBar: TScrollBar;
    FInternalText: string;
    FAttributes: TArray<TFormattedTextAttribute>;
    FLines: TStrings;
    FWordWrap: Boolean;
    FDefaultColor: TAlphaColor;
    FAutoScrollToBottom: Boolean;
    FOnChange: TNotifyEvent;
    FUpdating: Boolean;
    FScrollPos: Single;
    FContentHeight: Single;
    FFont: TFont;
    procedure SetWordWrap(const Value: Boolean);
    procedure SetDefaultColor(const Value: TAlphaColor);
    procedure SetLines(const Value: TStrings);
    procedure LinesChanged(Sender: TObject);
    procedure UpdateFromLines;
    procedure RebuildFromInternal;
    function GetText: string;
    procedure SetText(const Value: string);
    function GetLines: TStrings;
    procedure ClearAttributes;
    procedure AddAttribute(StartPos, _Length: Integer; Color: TAlphaColor);
    function ExportToHTML: string;
    procedure ImportFromHTML(const HTMLText: string);
    function HexToAlphaColor(const Hex: string): TAlphaColor;
    procedure SetFont(const Value: TFont);
    function GetFont: TFont;
    procedure UpdateContentSize;
    procedure DoChange;
    procedure VScrollBarChange(Sender: TObject);
    procedure UpdateScrollBar;
    procedure SetScrollPos(Value: Single);
    procedure FontChanged(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure AddColoredLine(const Line: string; Color: TAlphaColor);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure ScrollToBottom;
    property Text: string read GetText write SetText;
  published
    property Align;
    property TextAlign;
    property Anchors;
    property Enabled;
    property Visible;
    property Font: TFont read GetFont write SetFont;
    property Lines: TStrings read GetLines write SetLines;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default True;
    property DefaultColor: TAlphaColor read FDefaultColor write SetDefaultColor default $FF000000;
    property AutoScrollToBottom: Boolean read FAutoScrollToBottom write FAutoScrollToBottom default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

uses
  System.Math;

procedure Register;
begin
  RegisterComponents('Custom', [TColoredMemo]);
end;

{ TColoredMemo }

constructor TColoredMemo.Create(AOwner: TComponent);
begin
  inherited;
  FLines := TStringList.Create;
  TStringList(FLines).OnChange := LinesChanged;
  FWordWrap := True;
  FDefaultColor := TAlphaColors.Black;
  FAutoScrollToBottom := True;
  FInternalText := '';
  SetLength(FAttributes, 0);
  FFont := TFont.Create;
  FFont.OnChanged := FontChanged;
  Width := 200;
  Height := 150;
  FScrollPos := 0;
  FContentHeight := 0;
  FVScrollBar := TScrollBar.Create(Self);
  FVScrollBar.Parent := Self;
  FVScrollBar.Orientation := TOrientation.Vertical;
  FVScrollBar.Align := TAlignLayout.Right;
  FVScrollBar.Width := 16;
  FVScrollBar.Visible := False;
  FVScrollBar.OnChange := VScrollBarChange;
  FVScrollBar.SmallChange := 10;
end;

destructor TColoredMemo.Destroy;
begin
  ClearAttributes;
  FLines.Free;
  FFont.Free;
  inherited;
end;

procedure TColoredMemo.FontChanged(Sender: TObject);
begin
  if csDesigning in ComponentState then Exit;
  UpdateContentSize;
  Repaint;
end;

function TColoredMemo.GetFont: TFont;
begin
  Result := FFont;
end;

procedure TColoredMemo.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TColoredMemo.ClearAttributes;
begin
  SetLength(FAttributes, 0);
end;

procedure TColoredMemo.AddAttribute(StartPos, _Length: Integer; Color: TAlphaColor);
var
  Attr: TFormattedTextAttribute;
begin
  Attr.Range := TTextRange.Create(StartPos, _Length);
  Attr.Color := Color;
  SetLength(FAttributes, Length(FAttributes) + 1);
  FAttributes[High(FAttributes)] := Attr;
end;

procedure TColoredMemo.LinesChanged(Sender: TObject);
begin
  if csDesigning in ComponentState then Exit;
  if not FUpdating then
    UpdateFromLines;
  DoChange;
end;

procedure TColoredMemo.UpdateFromLines;
var
  i: Integer;
  LineText: string;
  StartPos: Integer;
begin
  if csDesigning in ComponentState then Exit;
  FUpdating := True;
  try
    ClearAttributes;
    FInternalText := '';
    for i := 0 to FLines.Count - 1 do
    begin
      LineText := FLines[i];
      StartPos := Length(FInternalText);
      if i > 0 then
      begin
        FInternalText := FInternalText + sLineBreak;
        StartPos := StartPos + Length(sLineBreak);
      end;
      FInternalText := FInternalText + LineText;
      AddAttribute(StartPos, Length(LineText), FDefaultColor);
    end;
    UpdateContentSize;
  finally
    FUpdating := False;
  end;
  Repaint;
end;

procedure TColoredMemo.RebuildFromInternal;
var
  LineList: TStringList;
begin
  LineList := TStringList.Create;
  try
    LineList.Text := FInternalText;
    FUpdating := True;
    try
      FLines.Assign(LineList);
    finally
      FUpdating := False;
    end;
  finally
    LineList.Free;
  end;
end;

function TColoredMemo.GetLines: TStrings;
begin
  Result := FLines;
end;

procedure TColoredMemo.SetLines(const Value: TStrings);
begin
  FLines.Assign(Value);
end;

function TColoredMemo.GetText: string;
begin
  Result := FInternalText;
end;

procedure TColoredMemo.SetText(const Value: string);
begin
  if csDesigning in ComponentState then
  begin
    FInternalText := Value;
    Exit;
  end;
  if FInternalText <> Value then
  begin
    FInternalText := Value;
    RebuildFromInternal;
    ClearAttributes;
    UpdateFromLines;
    DoChange;
  end;
end;

procedure TColoredMemo.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    if not (csDesigning in ComponentState) then
      UpdateContentSize;
    Repaint;
  end;
end;

procedure TColoredMemo.SetDefaultColor(const Value: TAlphaColor);
begin
  if FDefaultColor <> Value then
  begin
    FDefaultColor := Value;
    if not (csDesigning in ComponentState) then
      UpdateFromLines;
  end;
end;

procedure TColoredMemo.Clear;
begin
  Text := '';
  SetScrollPos(0);  // обязательно
end;

procedure TColoredMemo.AddColoredLine(const Line: string; Color: TAlphaColor);
var
  StartPos: Integer;
begin
  if csDesigning in ComponentState then Exit;
  FUpdating := True;
  try
    StartPos := Length(FInternalText);
    if FLines.Count > 0 then
    begin
      FInternalText := FInternalText + sLineBreak;
      Inc(StartPos, Length(sLineBreak));
    end;
    FInternalText := FInternalText + Line;
    FLines.Add(Line);
    AddAttribute(StartPos, Length(Line), Color);
    UpdateContentSize;
  finally
    FUpdating := False;
  end;
  DoChange;
  Repaint;
  // ВАЖНО: Сразу после добавления строки прокручиваем вверх,
  // чтобы строка была видна в верхней части компонента
  if FAutoScrollToBottom then
     ScrollToBottom
  else
     SetScrollPos(0);
end;

procedure TColoredMemo.UpdateContentSize;
var
  Layout: TTextLayout;
  NeededHeight: Single;
  MaxWidth: Single;
begin
  if (csDesigning in ComponentState) or (FFont = nil) or (FVScrollBar = nil) then
    Exit;
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.Font := FFont;
    Layout.Text := FInternalText;
    MaxWidth := Width - 4;
    if FVScrollBar.Visible then
      MaxWidth := MaxWidth - FVScrollBar.Width;
    if MaxWidth < 1 then MaxWidth := 1;
    if FWordWrap then
      Layout.MaxSize := TPointF.Create(MaxWidth, 10000)
    else
      Layout.MaxSize := TPointF.Create(10000, 10000);
    Layout.WordWrap := FWordWrap;
    NeededHeight := Layout.TextHeight + 4;
  finally
    Layout.Free;
  end;
  FContentHeight := NeededHeight;
  UpdateScrollBar;
end;

procedure TColoredMemo.UpdateScrollBar;
begin
  if (csDesigning in ComponentState) or (FVScrollBar = nil) then Exit;
  if FContentHeight > Height then
  begin
    FVScrollBar.Visible := True;
    FVScrollBar.Min := 0;
    FVScrollBar.Max := FContentHeight - Height;
    if FContentHeight > 0 then
      FVScrollBar.ViewportSize := Height / FContentHeight * (FContentHeight - Height);
    FVScrollBar.Value := EnsureRange(FScrollPos, FVScrollBar.Min, FVScrollBar.Max);
  end
  else
  begin
    FVScrollBar.Visible := False;
    SetScrollPos(0);
  end;
end;

procedure TColoredMemo.SetScrollPos(Value: Single);
begin
  if csDesigning in ComponentState then Exit;
  if FContentHeight > Height then
    Value := EnsureRange(Value, 0, FContentHeight - Height)
  else
    Value := 0;
  if FScrollPos <> Value then
  begin
    FScrollPos := Value;
    if (FVScrollBar <> nil) and FVScrollBar.Visible then
      FVScrollBar.Value := FScrollPos;
    Repaint;
  end;
end;

procedure TColoredMemo.VScrollBarChange(Sender: TObject);
begin
  if csDesigning in ComponentState then Exit;
  SetScrollPos(FVScrollBar.Value);
end;

procedure TColoredMemo.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited;
  if (csDesigning in ComponentState) then Exit;
  if (FVScrollBar <> nil) and FVScrollBar.Visible then
  begin
    SetScrollPos(FScrollPos - WheelDelta / 20);
    Handled := True;
  end;
end;

procedure TColoredMemo.Resize;
begin
  inherited;
  if csDesigning in ComponentState then Exit;
  UpdateContentSize;
  UpdateScrollBar;
end;

procedure TColoredMemo.Paint;
var
  Layout: TTextLayout;
  i: Integer;
  CanvasSave: TCanvasSaveState;
  ContentRect: TRectF;
  ScrollBarWidth: Single;
begin
  inherited;
  if not Visible or (csDesigning in ComponentState) then Exit;

  ScrollBarWidth := 0;
  if (FVScrollBar <> nil) and FVScrollBar.Visible then
    ScrollBarWidth := FVScrollBar.Width;

  ContentRect := RectF(2, 2 - FScrollPos, Width - 2 - ScrollBarWidth, Height - 2 - FScrollPos);
  if ContentRect.Width <= 0 then Exit;

  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font := FFont;
      Layout.Color := FDefaultColor;
      Layout.Text := FInternalText;
      Layout.HorizontalAlign := TextAlign;
      Layout.MaxSize := TPointF.Create(ContentRect.Width, 10000);
      Layout.WordWrap := FWordWrap;
      Layout.TopLeft := PointF(2, 2 - FScrollPos);

      for i := 0 to High(FAttributes) do
        Layout.AddAttribute(FAttributes[i].Range, TTextAttribute.Create(Layout.Font, FAttributes[i].Color));
    finally
      Layout.EndUpdate;
    end;

    CanvasSave := Canvas.SaveState;
    try
      Canvas.IntersectClipRect(RectF(0, 0, Width, Height));
      Layout.RenderLayout(Canvas);
    finally
      Canvas.RestoreState(CanvasSave);
    end;
  finally
    Layout.Free;
  end;
end;

procedure TColoredMemo.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TColoredMemo.HexToAlphaColor(const Hex: string): TAlphaColor;
var
  IntColor: Cardinal;
begin
  IntColor := StrToIntDef('$' + Hex.TrimLeft(['#']), 0);
  Result := TAlphaColor($FF000000 or IntColor);
end;

function TColoredMemo.ExportToHTML: string;
var
  LinesList: TStringList;
  LineStartPos: Integer;
  i, j: Integer;
  LineText: string;
  LineBuilder: TStringBuilder;
  Attr: TFormattedTextAttribute;
  LastLocalPos: Integer;
  FragmentStart, FragmentLen: Integer;
begin
  LinesList := TStringList.Create;
  try
    LinesList.Text := FInternalText;
    var ResultBuilder := TStringBuilder.Create;
    try
      LineStartPos := 0;
      for i := 0 to LinesList.Count - 1 do
      begin
        LineText := LinesList[i];
        LineBuilder := TStringBuilder.Create;
        try
          LastLocalPos := 1;
          for j := 0 to High(FAttributes) do
          begin
            Attr := FAttributes[j];
            if (Attr.Range.Pos < LineStartPos + Length(LineText)) and
               (Attr.Range.Pos + Attr.Range.Length > LineStartPos) then
            begin
              FragmentStart := Attr.Range.Pos - LineStartPos + 1;
              FragmentLen := Attr.Range.Length;
              if FragmentStart < 1 then
              begin
                FragmentLen := FragmentLen + (FragmentStart - 1);
                FragmentStart := 1;
              end;
              if FragmentStart + FragmentLen - 1 > Length(LineText) then
                FragmentLen := Length(LineText) - FragmentStart + 1;
              if FragmentLen <= 0 then Continue;

              if FragmentStart > LastLocalPos then
                LineBuilder.Append(Copy(LineText, LastLocalPos, FragmentStart - LastLocalPos));

              LineBuilder.Append(Format('<font color="#%.6x">', [Attr.Color and $FFFFFF]));
              LineBuilder.Append(Copy(LineText, FragmentStart, FragmentLen));
              LineBuilder.Append('</font>');
              LastLocalPos := FragmentStart + FragmentLen;
            end;
          end;
          if LastLocalPos <= Length(LineText) then
            LineBuilder.Append(Copy(LineText, LastLocalPos, MaxInt));

          ResultBuilder.Append(LineBuilder.ToString);
          if i < LinesList.Count - 1 then
            ResultBuilder.Append('<br>');
        finally
          LineBuilder.Free;
        end;
        Inc(LineStartPos, Length(LineText) + Length(sLineBreak));
      end;
      Result := ResultBuilder.ToString;
    finally
      ResultBuilder.Free;
    end;
  finally
    LinesList.Free;
  end;
end;

procedure TColoredMemo.ImportFromHTML(const HTMLText: string);
var
  LinesTemp: TStringList;
  i: Integer;
  LineRaw: string;
  LineClean: string;
  Color: TAlphaColor;
  StartPos: Integer;
  FontStart, FontEnd, CloseFont: Integer;
  ColorStart: Integer;
  HexColor: string;
begin
  ClearAttributes;
  var WorkText := HTMLText;
  WorkText := StringReplace(WorkText, '<br>', sLineBreak, [rfReplaceAll, rfIgnoreCase]);
  WorkText := StringReplace(WorkText, '<br />', sLineBreak, [rfReplaceAll, rfIgnoreCase]);
  WorkText := StringReplace(WorkText, '<br/>', sLineBreak, [rfReplaceAll, rfIgnoreCase]);

  LinesTemp := TStringList.Create;
  try
    LinesTemp.Text := WorkText;
    FInternalText := '';
    for i := 0 to LinesTemp.Count - 1 do
    begin
      LineRaw := LinesTemp[i];
      LineClean := LineRaw;
      Color := FDefaultColor;

      FontStart := Pos('<font', LowerCase(LineRaw));
      if FontStart > 0 then
      begin
        ColorStart := Pos('color="', LowerCase(LineRaw));
        if ColorStart = 0 then ColorStart := Pos('color=''', LowerCase(LineRaw));
        if ColorStart > 0 then
        begin
          var QuoteChar := '"';
          if Pos('color=''', LowerCase(LineRaw)) = ColorStart then
            QuoteChar := '''';
          var EqualsPos := PosEx('=', LineRaw, FontStart);
          if EqualsPos > 0 then
          begin
            var StartC := PosEx(QuoteChar, LineRaw, EqualsPos + 1);
            if StartC > 0 then
            begin
              var EndC := PosEx(QuoteChar, LineRaw, StartC + 1);
              if EndC > StartC then
              begin
                HexColor := Copy(LineRaw, StartC + 1, EndC - StartC - 1);
                Color := HexToAlphaColor(HexColor);
              end;
            end;
          end;
        end;
        FontEnd := PosEx('>', LineRaw, FontStart);
        if FontEnd > 0 then
          Delete(LineClean, FontStart, FontEnd - FontStart + 1);
        CloseFont := Pos('</font>', LowerCase(LineClean));
        if CloseFont > 0 then
          Delete(LineClean, CloseFont, 7);
      end;

      StartPos := Length(FInternalText);
      if i > 0 then
      begin
        FInternalText := FInternalText + sLineBreak;
        StartPos := StartPos + Length(sLineBreak);
      end;
      FInternalText := FInternalText + LineClean;
      AddAttribute(StartPos, Length(LineClean), Color);
    end;
  finally
    LinesTemp.Free;
  end;

  RebuildFromInternal;
  UpdateContentSize;
  SetScrollPos(0);
  Repaint;
end;

procedure TColoredMemo.LoadFromFile(const FileName: string);
var
  Strings: TStringList;
  Ext: string;
begin
  Strings := TStringList.Create;
  try
    Strings.LoadFromFile(FileName);
    Ext := LowerCase(ExtractFileExt(FileName));
    if (Ext = '.html') or (Ext = '.htm') then
      ImportFromHTML(Strings.Text)
    else
      Self.Text := Strings.Text;
  finally
    Strings.Free;
  end;
end;

procedure TColoredMemo.SaveToFile(const FileName: string);
var
  Strings: TStringList;
  Ext: string;
begin
  Strings := TStringList.Create;
  try
    Ext := LowerCase(ExtractFileExt(FileName));
    if (Ext = '.html') or (Ext = '.htm') then
      Strings.Text := ExportToHTML
    else
      Strings.Text := Self.Text;
    Strings.SaveToFile(FileName);
  finally
    Strings.Free;
  end;
end;

procedure TColoredMemo.ScrollToBottom;
begin
  if (csDesigning in ComponentState) then Exit;
  if (FVScrollBar <> nil) and FVScrollBar.Visible then
    SetScrollPos(FContentHeight - Height);
end;

end.
