unit uValueEditColumn;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  FMX.Controls,
  FMX.Edit,
  FMX.Graphics,
  FMX.Types;

const
  CValueEditButtonWidth = 24;

type
  TValueButtonClickEvent = procedure(Sender: TObject; const ACol,
    ARow: Integer; const AText: string) of object;

  { Нестилизованная кнопка редактора показания. }
  TValueEditButton = class(TEditButton)
  private
    FPressed: Boolean;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure Paint; override;
  end;

  { Программный редактор показания с кнопкой фотофиксации. }
  TValueEditCellEditor = class(TEdit)
  private
    FPhotoButton: TValueEditButton;
    FOnButtonClick: TValueButtonClickEvent;
    FCol: Integer;
    FRow: Integer;
    procedure ButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Initialize(const ACol, ARow: Integer; const AText: string;
      const AShowButton: Boolean;
      const AOnButtonClick: TValueButtonClickEvent);
  end;

implementation

procedure DrawValueEditButton(const ACanvas: TCanvas; const ARect: TRectF;
  const APressed: Boolean);
var
  State: TCanvasSaveState;
begin
  State := ACanvas.SaveState;
  try
    ACanvas.Fill.Kind := TBrushKind.Solid;
    if APressed then
      ACanvas.Fill.Color := $FFC8C8C8
    else
      ACanvas.Fill.Color := $FFE0E0E0;
    ACanvas.FillRect(ARect, 0, 0, [], 1);
    ACanvas.Stroke.Kind := TBrushKind.Solid;
    ACanvas.Stroke.Color := $FF808080;
    ACanvas.Stroke.Thickness := 1;
    ACanvas.DrawRect(ARect, 0, 0, [], 1);
    ACanvas.Fill.Color := TAlphaColors.Black;
    ACanvas.Font.Size := 12;
    ACanvas.FillText(ARect, '...', False, 1, [], TTextAlign.Center,
      TTextAlign.Center);
  finally
    ACanvas.RestoreState(State);
  end;
end;

procedure TValueEditButton.Paint;
begin
  DrawValueEditButton(Canvas, LocalRect, FPressed);
end;

procedure TValueEditButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    FPressed := True;
    Repaint;
  end;
  inherited;
end;

procedure TValueEditButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    FPressed := False;
    Repaint;
  end;
  inherited;
end;

constructor TValueEditCellEditor.Create(AOwner: TComponent);
begin
  inherited;
  Enabled := True;
  ReadOnly := False;
  HitTest := True;
  CanFocus := True;
  TabStop := True;

  FPhotoButton := TValueEditButton.Create(Self);
  FPhotoButton.Parent := Self;
  FPhotoButton.Text := '...';
  FPhotoButton.Align := TAlignLayout.Right;
  FPhotoButton.Width := CValueEditButtonWidth;
  FPhotoButton.Margins.Rect := TRectF.Empty;
  FPhotoButton.OnClick := ButtonClick;
end;

procedure TValueEditCellEditor.ButtonClick(Sender: TObject);
var
  LOnButtonClick: TValueButtonClickEvent;
  LCol: Integer;
  LRow: Integer;
  LText: string;
begin
  LOnButtonClick := FOnButtonClick;
  LCol := FCol;
  LRow := FRow;
  LText := Text;
  if Assigned(LOnButtonClick) then
    LOnButtonClick(Self, LCol, LRow, LText);
end;

procedure TValueEditCellEditor.Initialize(const ACol, ARow: Integer;
  const AText: string; const AShowButton: Boolean;
  const AOnButtonClick: TValueButtonClickEvent);
begin
  FCol := ACol;
  FRow := ARow;
  FOnButtonClick := AOnButtonClick;
  Text := AText;
  FPhotoButton.Visible := AShowButton;
end;

end.
