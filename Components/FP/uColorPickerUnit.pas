unit uColorPickerUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs;

type
  TFMXColorComboBox = class(TControl)
  private
    FColor: TAlphaColor;
    FPopup: TPopupBox;
    procedure CreateColorGrid;
    procedure ColorItemClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Color: TAlphaColor read FColor write SetColor;
  end;

implementation

constructor TFMXColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 30;
  FPopup := TPopupBox.Create(Self);
  FPopup.Parent := Self;
  CreateColorGrid;
end;

procedure TFMXColorComboBox.CreateColorGrid;
var
  Grid: TGrid;
  X, Y: Integer;
  ColorRect: TRectangle;
begin
  Grid := TGrid.Create(FPopup);
  Grid.Parent := FPopup;
  Grid.Align := TAlignLayout.Client;
  Grid.RowCount := 8;
  Grid.ColumnCount := 8;
  Grid.ShowScrollBars := False;

  for Y := 0 to Grid.RowCount - 1 do
    for X := 0 to Grid.ColumnCount - 1 do
    begin
      ColorRect := TRectangle.Create(Grid);
      ColorRect.Parent := Grid;
      ColorRect.Align := TAlignLayout.Client;
      ColorRect.Tag := Y * Grid.ColumnCount + X;
      ColorRect.OnClick := ColorItemClick;

      // Пример установки цветов
      ColorRect.Fill.Color := TAlphaColors.Black + (Y * Grid.ColumnCount + X) * $101010;
    end;
end;

procedure TFMXColorComboBox.ColorItemClick(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
    FColor := TRectangle(Sender).Fill.Color;
    FPopup.Close;
  end;
end;

destructor TFMXColorComboBox.Destroy;
begin
  FPopup.Free;
  inherited Destroy;
end;

end.
