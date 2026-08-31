unit frmPhotoReading;

interface

uses
  FMX.Controls, FMX.Dialogs, FMX.Edit, FMX.Forms, FMX.Graphics, FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls, FMX.Types, System.Classes, System.IOUtils, System.Math,
  System.SysUtils,
  System.Types, System.UITypes;

type
  TFormPhotoReading = class(TForm)
  private
    FEditReading: TEdit;
    FSelectedPhotoFile: string;
    FPhotoScrollBox: TScrollBox;
    FImageHost: TLayout;
    FImage: TImage;
    FNotFoundLabel: TLabel;
    FScaleTrackBar: TTrackBar;
    FRotationTrackBar: TTrackBar;
    FScaleLabel: TLabel;
    FRotationLabel: TLabel;
    FPhotoContentWidth: Single;
    FPhotoContentHeight: Single;
    FPhotoDragging: Boolean;
    FPhotoMousePosition: TPointF;
    FPhotoDragStart: TPointF;
    FPhotoDragStartViewport: TPointF;
    FZoomAnchorActive: Boolean;
    FZoomAnchorViewPoint: TPointF;
    FZoomAnchorOffset: TPointF;
    FZoomScaleRatio: Single;
    procedure CloseClick(Sender: TObject);
    procedure FormKeyDownHandler(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure SaveClick(Sender: TObject);
    procedure LoadPhotoClick(Sender: TObject);
    procedure LoadImage(const AImageFile: string);
    procedure FormResizeHandler(Sender: TObject);
    procedure CalcPhotoContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
    procedure PhotoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PhotoMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure PhotoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PhotoMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure UpdateImageLayout;
    procedure ScaleTrackBarChange(Sender: TObject);
    procedure RotationTrackBarChange(Sender: TObject);
    function TryReadValue(out AValue: Double): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    { Opens the photo viewer and returns a reading only after Save is pressed. }
    class function Execute(const AImageFile, ACurrentText: string;
      out AValue: Double; out ASelectedPhotoFile: string): Boolean;
  end;

implementation

const
  CInvalidNumberMessage = 'Некорректное числовое значение';

constructor TFormPhotoReading.Create(AOwner: TComponent);
var
  FooterArea: TLayout;
  BottomArea: TLayout;
  ButtonPanel: TLayout;
  ReadingPanel: TLayout;
  TransformPanel: TLayout;
  ScaleRow: TLayout;
  RotationRow: TLayout;
  PhotoFrame: TRectangle;
  ReadingLabel: TLabel;
  SaveButton: TCornerButton;
  CloseButton: TCornerButton;
  LoadPhotoButton: TCornerButton;

  { Оформляет кнопку так же, как в окнах выбора приборов и типов. }
  procedure SetupDialogButton(AButton: TCornerButton);
  begin
    AButton.Align := TAlignLayout.Right;
    AButton.Width := 127;
    AButton.Margins.Rect := RectF(10, 10, 10, 10);
    AButton.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size,
      TStyledSetting.Style];
    AButton.TextSettings.FontColor := TAlphaColors.Darkgreen;
    AButton.XRadius := 3;
    AButton.YRadius := 3;
  end;

begin
  inherited CreateNew(AOwner);
  Caption := 'Фотофиксация';
  Width := 900;
  Height := 650;
  Position := TFormPosition.ScreenCenter;
  Fill.Color := $FFF4F4F4;
  OnKeyDown := FormKeyDownHandler;
  OnResize := FormResizeHandler;

  FooterArea := TLayout.Create(Self);
  FooterArea.Parent := Self;
  FooterArea.Align := TAlignLayout.Bottom;
  FooterArea.Height := 160;

  BottomArea := TLayout.Create(Self);
  BottomArea.Parent := FooterArea;
  BottomArea.Align := TAlignLayout.Bottom;
  BottomArea.Height := 88;

  ButtonPanel := TLayout.Create(Self);
  ButtonPanel.Parent := BottomArea;
  ButtonPanel.Align := TAlignLayout.Bottom;
  ButtonPanel.Height := 44;

  CloseButton := TCornerButton.Create(Self);
  CloseButton.Parent := ButtonPanel;
  SetupDialogButton(CloseButton);
  CloseButton.Text := 'Закрыть';
  CloseButton.OnClick := CloseClick;

  SaveButton := TCornerButton.Create(Self);
  SaveButton.Parent := ButtonPanel;
  SetupDialogButton(SaveButton);
  SaveButton.Text := 'Применить';
  SaveButton.OnClick := SaveClick;

  LoadPhotoButton := TCornerButton.Create(Self);
  LoadPhotoButton.Parent := ButtonPanel;
  SetupDialogButton(LoadPhotoButton);
  LoadPhotoButton.Width := 145;
  LoadPhotoButton.Text := 'Загрузить фото';
  LoadPhotoButton.OnClick := LoadPhotoClick;

  ReadingPanel := TLayout.Create(Self);
  ReadingPanel.Parent := BottomArea;
  ReadingPanel.Align := TAlignLayout.Client;

  ReadingLabel := TLabel.Create(Self);
  ReadingLabel.Parent := ReadingPanel;
  ReadingLabel.Align := TAlignLayout.Left;
  ReadingLabel.Width := 105;
  ReadingLabel.Margins.Left := 10;
  ReadingLabel.Text := 'Показание';
  ReadingLabel.TextSettings.VertAlign := TTextAlign.Center;

  FEditReading := TEdit.Create(Self);
  FEditReading.Parent := ReadingPanel;
  FEditReading.Align := TAlignLayout.Client;
  FEditReading.Margins.Rect := RectF(10, 10, 10, 10);
  FEditReading.KeyboardType := TVirtualKeyboardType.DecimalNumberPad;

  TransformPanel := TLayout.Create(Self);
  TransformPanel.Parent := FooterArea;
  TransformPanel.Align := TAlignLayout.Client;

  ScaleRow := TLayout.Create(Self);
  ScaleRow.Parent := TransformPanel;
  ScaleRow.Align := TAlignLayout.Top;
  ScaleRow.Height := 36;

  FScaleLabel := TLabel.Create(Self);
  FScaleLabel.Parent := ScaleRow;
  FScaleLabel.Align := TAlignLayout.Right;
  FScaleLabel.Width := 150;
  FScaleLabel.Margins.Right := 10;
  FScaleLabel.TextSettings.VertAlign := TTextAlign.Center;

  FScaleTrackBar := TTrackBar.Create(Self);
  FScaleTrackBar.Parent := ScaleRow;
  FScaleTrackBar.Align := TAlignLayout.Client;
  FScaleTrackBar.Margins.Rect := RectF(10, 7, 10, 7);
  FScaleTrackBar.Min := 25;
  FScaleTrackBar.Max := 300;
  FScaleTrackBar.Value := 100;
  FScaleTrackBar.OnChange := ScaleTrackBarChange;

  RotationRow := TLayout.Create(Self);
  RotationRow.Parent := TransformPanel;
  RotationRow.Align := TAlignLayout.Client;

  FRotationLabel := TLabel.Create(Self);
  FRotationLabel.Parent := RotationRow;
  FRotationLabel.Align := TAlignLayout.Right;
  FRotationLabel.Width := 150;
  FRotationLabel.Margins.Right := 10;
  FRotationLabel.TextSettings.VertAlign := TTextAlign.Center;

  FRotationTrackBar := TTrackBar.Create(Self);
  FRotationTrackBar.Parent := RotationRow;
  FRotationTrackBar.Align := TAlignLayout.Client;
  FRotationTrackBar.Margins.Rect := RectF(10, 7, 10, 7);
  FRotationTrackBar.Min := -180;
  FRotationTrackBar.Max := 180;
  FRotationTrackBar.Value := 0;
  FRotationTrackBar.OnChange := RotationTrackBarChange;

  PhotoFrame := TRectangle.Create(Self);
  PhotoFrame.Parent := Self;
  PhotoFrame.Align := TAlignLayout.Client;
  PhotoFrame.Margins.Rect := RectF(12, 12, 12, 12);
  PhotoFrame.Fill.Color := TAlphaColors.White;
  PhotoFrame.Stroke.Color := $FFB8B8B8;
  PhotoFrame.Stroke.Thickness := 1;
  PhotoFrame.ClipChildren := True;

  FPhotoScrollBox := TScrollBox.Create(Self);
  FPhotoScrollBox.Parent := PhotoFrame;
  FPhotoScrollBox.Align := TAlignLayout.Client;
  FPhotoScrollBox.Margins.Rect := RectF(1, 1, 1, 1);
  FPhotoScrollBox.ShowScrollBars := True;
  FPhotoScrollBox.ClipChildren := True;
  FPhotoScrollBox.OnCalcContentBounds := CalcPhotoContentBounds;
  FPhotoScrollBox.OnMouseDown := PhotoMouseDown;
  FPhotoScrollBox.OnMouseMove := PhotoMouseMove;
  FPhotoScrollBox.OnMouseUp := PhotoMouseUp;
  FPhotoScrollBox.OnMouseWheel := PhotoMouseWheel;

  FImageHost := TLayout.Create(Self);
  FImageHost.Parent := FPhotoScrollBox;
  FImageHost.Align := TAlignLayout.None;
  FImageHost.HitTest := False;

  FImage := TImage.Create(Self);
  FImage.Parent := FImageHost;
  FImage.Align := TAlignLayout.None;
  FImage.WrapMode := TImageWrapMode.Fit;
  FImage.RotationCenter.Point := PointF(0.5, 0.5);
  FImage.HitTest := False;

  FNotFoundLabel := TLabel.Create(Self);
  FNotFoundLabel.Parent := PhotoFrame;
  FNotFoundLabel.Align := TAlignLayout.Client;
  FNotFoundLabel.TextSettings.Font.Size := 16;
  FNotFoundLabel.TextSettings.FontColor := TAlphaColors.Gray;
  FNotFoundLabel.TextSettings.HorzAlign := TTextAlign.Center;
  FNotFoundLabel.TextSettings.VertAlign := TTextAlign.Center;
  FNotFoundLabel.Visible := False;
  FNotFoundLabel.HitTest := False;

  ScaleTrackBarChange(FScaleTrackBar);
  RotationTrackBarChange(FRotationTrackBar);
end;

class function TFormPhotoReading.Execute(const AImageFile,
  ACurrentText: string; out AValue: Double;
  out ASelectedPhotoFile: string): Boolean;
var
  Form: TFormPhotoReading;
begin
  ASelectedPhotoFile := '';
  Form := TFormPhotoReading.Create(nil);
  try
    Form.FEditReading.Text := ACurrentText;
    Form.LoadImage(AImageFile);
    Result := Form.ShowModal = mrOk;
    if Result then
    begin
      Result := Form.TryReadValue(AValue);
      if Result then
        ASelectedPhotoFile := Form.FSelectedPhotoFile;
    end;
  finally
    Form.Free;
  end;
end;

{ Выбирает новую фотографию с диска и сразу показывает её в форме. }
procedure TFormPhotoReading.LoadPhotoClick(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Выберите фотографию';
    Dialog.Filter :=
      'Изображения (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|' +
      'Все файлы (*.*)|*.*';
    if FileExists(FSelectedPhotoFile) then
    begin
      Dialog.InitialDir := TPath.GetDirectoryName(FSelectedPhotoFile);
      Dialog.FileName := FSelectedPhotoFile;
    end;

    if not Dialog.Execute then
      Exit;

    LoadImage(Dialog.FileName);
    if not FImage.Bitmap.IsEmpty then
      FSelectedPhotoFile := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;

{ Загружает снимок и показывает понятную причину, если он недоступен. }
procedure TFormPhotoReading.LoadImage(const AImageFile: string);
begin
  FImage.Bitmap.Clear(TAlphaColors.Null);
  FNotFoundLabel.Text := '';

  if Trim(AImageFile) = '' then
    FNotFoundLabel.Text := 'Путь к фотографии не задан'
  else if not FileExists(AImageFile) then
    FNotFoundLabel.Text := 'Файл фотографии не найден:' +
      sLineBreak + AImageFile
  else
    try
      FImage.Bitmap.LoadFromFile(AImageFile);
    except
      on E: Exception do
        FNotFoundLabel.Text := 'Не удалось открыть фотографию:' +
          sLineBreak + E.Message;
    end;

  FImage.Visible := not FImage.Bitmap.IsEmpty;
  FImageHost.Visible := not FImage.Bitmap.IsEmpty;
  FPhotoScrollBox.Visible := not FImage.Bitmap.IsEmpty;
  FNotFoundLabel.Visible := FImage.Bitmap.IsEmpty;
  UpdateImageLayout;
end;

{ Обновляет изображение при изменении размера окна. }
procedure TFormPhotoReading.FormResizeHandler(Sender: TObject);
begin
  UpdateImageLayout;
end;

{ Возвращает точные размеры прокручиваемой области фотографии. }
procedure TFormPhotoReading.CalcPhotoContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
  ContentBounds := RectF(0, 0, FPhotoContentWidth, FPhotoContentHeight);
end;

{ Запоминает исходную точку для перемещения фотографии мышью. }
procedure TFormPhotoReading.PhotoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FPhotoMousePosition := PointF(X, Y);
  if Button <> TMouseButton.mbLeft then
    Exit;

  FPhotoDragging := True;
  FPhotoDragStart := PointF(X, Y);
  FPhotoDragStartViewport := FPhotoScrollBox.ViewportPosition;
end;

{ Перемещает увеличенную фотографию вслед за зажатой левой кнопкой мыши. }
procedure TFormPhotoReading.PhotoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var
  NewPosition: TPointF;
  MaxX: Single;
  MaxY: Single;
begin
  FPhotoMousePosition := PointF(X, Y);
  if not FPhotoDragging then
    Exit;

  if not (ssLeft in Shift) then
  begin
    FPhotoDragging := False;
    Exit;
  end;

  MaxX := Max(0, FPhotoContentWidth - Max(1, FPhotoScrollBox.Width - 4));
  MaxY := Max(0, FPhotoContentHeight - Max(1, FPhotoScrollBox.Height - 4));

  NewPosition := PointF(
    FPhotoDragStartViewport.X - (X - FPhotoDragStart.X),
    FPhotoDragStartViewport.Y - (Y - FPhotoDragStart.Y));

  if NewPosition.X < 0 then
    NewPosition.X := 0
  else if NewPosition.X > MaxX then
    NewPosition.X := MaxX;

  if NewPosition.Y < 0 then
    NewPosition.Y := 0
  else if NewPosition.Y > MaxY then
    NewPosition.Y := MaxY;

  FPhotoScrollBox.ViewportPosition := NewPosition;
end;

{ Завершает перемещение фотографии. }
procedure TFormPhotoReading.PhotoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FPhotoMousePosition := PointF(X, Y);
  if Button = TMouseButton.mbLeft then
    FPhotoDragging := False;
end;

{ Изменяет масштаб колесом мыши только при зажатой клавише Ctrl. }
procedure TFormPhotoReading.PhotoMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
const
  CWheelScaleStep = 5;
var
  NewScale: Single;
begin
  if not (ssCtrl in Shift) or (WheelDelta = 0) then
    Exit;

  if WheelDelta > 0 then
    NewScale := Min(FScaleTrackBar.Max,
      FScaleTrackBar.Value + CWheelScaleStep)
  else
    NewScale := Max(FScaleTrackBar.Min,
      FScaleTrackBar.Value - CWheelScaleStep);

  Handled := True;
  if NewScale = FScaleTrackBar.Value then
    Exit;

  { Запоминаем точку фотографии под курсором до изменения масштаба. }
  FZoomAnchorViewPoint := FPhotoMousePosition;
  FZoomAnchorOffset := PointF(
    FPhotoScrollBox.ViewportPosition.X + FPhotoMousePosition.X -
      FPhotoContentWidth / 2,
    FPhotoScrollBox.ViewportPosition.Y + FPhotoMousePosition.Y -
      FPhotoContentHeight / 2);
  FZoomScaleRatio := NewScale / FScaleTrackBar.Value;
  FZoomAnchorActive := True;

  FScaleTrackBar.Value := NewScale;
end;

{ Масштабирует фотографию по центру и обновляет область прокрутки. }
procedure TFormPhotoReading.UpdateImageLayout;
var
  ViewWidth: Single;
  ViewHeight: Single;
  BitmapWidth: Single;
  BitmapHeight: Single;
  FitScale: Single;
  ImageScale: Single;
  ImageWidth: Single;
  ImageHeight: Single;
  HostWidth: Single;
  HostHeight: Single;
  Angle: Single;
  CosAngle: Single;
  SinAngle: Single;
  NewPosition: TPointF;
  MaxX: Single;
  MaxY: Single;
begin
  if (FPhotoScrollBox = nil) or (FImageHost = nil) or (FImage = nil) or
     FImage.Bitmap.IsEmpty then
    Exit;

  { Небольшой запас исключает полосы из-за рамки и округления при 100 %. }
  ViewWidth := Max(1, FPhotoScrollBox.Width - 4);
  ViewHeight := Max(1, FPhotoScrollBox.Height - 4);
  BitmapWidth := Max(1, FImage.Bitmap.Width);
  BitmapHeight := Max(1, FImage.Bitmap.Height);

  FitScale := Min(ViewWidth / BitmapWidth, ViewHeight / BitmapHeight);
  ImageScale := FitScale * FScaleTrackBar.Value / 100;
  ImageWidth := BitmapWidth * ImageScale;
  ImageHeight := BitmapHeight * ImageScale;

  Angle := DegToRad(FRotationTrackBar.Value);
  CosAngle := Abs(Cos(Angle));
  SinAngle := Abs(Sin(Angle));
  HostWidth := ImageWidth * CosAngle + ImageHeight * SinAngle;
  HostHeight := ImageWidth * SinAngle + ImageHeight * CosAngle;

  FPhotoContentWidth := Max(ViewWidth, HostWidth);
  FPhotoContentHeight := Max(ViewHeight, HostHeight);
  FImageHost.SetBounds(0, 0, FPhotoContentWidth, FPhotoContentHeight);
  FImage.SetBounds(
    (FPhotoContentWidth - ImageWidth) / 2,
    (FPhotoContentHeight - ImageHeight) / 2,
    ImageWidth,
    ImageHeight);
  FImage.RotationAngle := FRotationTrackBar.Value;

  { Публично обновляем границы содержимого и состояние полос прокрутки. }
  FPhotoScrollBox.InvalidateContentSize;
  FPhotoScrollBox.RealignContent;

  if FZoomAnchorActive then
  begin
    { Оставляем точку фотографии под курсором на прежнем месте. }
    NewPosition := PointF(
      FPhotoContentWidth / 2 + FZoomAnchorOffset.X * FZoomScaleRatio -
        FZoomAnchorViewPoint.X,
      FPhotoContentHeight / 2 + FZoomAnchorOffset.Y * FZoomScaleRatio -
        FZoomAnchorViewPoint.Y);

    MaxX := Max(0, FPhotoContentWidth - ViewWidth);
    MaxY := Max(0, FPhotoContentHeight - ViewHeight);

    if NewPosition.X < 0 then
      NewPosition.X := 0
    else if NewPosition.X > MaxX then
      NewPosition.X := MaxX;

    if NewPosition.Y < 0 then
      NewPosition.Y := 0
    else if NewPosition.Y > MaxY then
      NewPosition.Y := MaxY;

    FPhotoScrollBox.ViewportPosition := NewPosition;
    FZoomAnchorActive := False;

    { Продолжаем перетаскивание без скачка после изменения масштаба. }
    if FPhotoDragging then
    begin
      FPhotoDragStart := FPhotoMousePosition;
      FPhotoDragStartViewport := NewPosition;
    end;
  end
  else
    { Трекбар и поворот по-прежнему работают относительно центра. }
    FPhotoScrollBox.ViewportPosition := PointF(
      Max(0, (FPhotoContentWidth - ViewWidth) / 2),
      Max(0, (FPhotoContentHeight - ViewHeight) / 2));
end;

{ Изменяет масштаб фотографии относительно её центра. }
procedure TFormPhotoReading.ScaleTrackBarChange(Sender: TObject);
begin
  FScaleLabel.Text := Format('Масштаб: %.0f %%', [FScaleTrackBar.Value]);
  UpdateImageLayout;
end;

{ Поворачивает фотографию относительно её центра. }
procedure TFormPhotoReading.RotationTrackBarChange(Sender: TObject);
begin
  FRotationLabel.Text := Format('Поворот: %.0f°',
    [FRotationTrackBar.Value]);
  UpdateImageLayout;
end;

function TFormPhotoReading.TryReadValue(out AValue: Double): Boolean;
var
  Text: string;
begin
  Text := Trim(FEditReading.Text);
  Text := StringReplace(Text, '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Text := StringReplace(Text, ',', FormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Result := (Text <> '') and TryStrToFloat(Text, AValue);
end;

procedure TFormPhotoReading.SaveClick(Sender: TObject);
var
  Value: Double;
begin
  if not TryReadValue(Value) then
  begin
    ShowMessage(CInvalidNumberMessage);
    FEditReading.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TFormPhotoReading.CloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormPhotoReading.FormKeyDownHandler(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

end.
