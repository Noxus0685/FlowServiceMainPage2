unit frmMeterValueSelect;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Grid,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uMeterValue;

type
  TFormMeterValueSelect = class(TForm)
  private
    FSelectedMeterValue: TMeterValue;
    FFilteredValues: TObjectList<TMeterValue>;
    ButtonSelect: TButton;
    ButtonCancel: TButton;

    procedure BuildUI;
    procedure FillValuesList;
    procedure SelectCurrentRow;
    procedure ButtonSelectClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure StringGridValuesListSelChanged(Sender: TObject);
  public
    Layout22: TLayout;
    StringGridValuesList: TStringGrid;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SelectedMeterValue: TMeterValue read FSelectedMeterValue;
  end;

implementation

{$R *.fmx}

constructor TFormMeterValueSelect.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
  FillValuesList;
  SelectCurrentRow;
end;

destructor TFormMeterValueSelect.Destroy;
begin
  FFilteredValues.Free;
  inherited;
end;

procedure TFormMeterValueSelect.BuildUI;

  procedure AddColumn(const AHeader: string; const AWidth: Single);
  var
    Column: TStringColumn;
  begin
    Column := TStringColumn.Create(Self);
    Column.Parent := StringGridValuesList;
    Column.Header := AHeader;
    Column.Width := AWidth;
  end;

var
  ButtonsLayout: TLayout;
begin
  Caption := 'Выбор MeterValue';
  Width := 900;
  Height := 520;

  Layout22 := TLayout.Create(Self);
  Layout22.Parent := Self;
  Layout22.Align := TAlignLayout.Client;
  Layout22.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  Layout22.Stored := False;

  ButtonsLayout := TLayout.Create(Self);
  ButtonsLayout.Parent := Layout22;
  ButtonsLayout.Align := TAlignLayout.Bottom;
  ButtonsLayout.Height := 44;
  ButtonsLayout.Stored := False;

  ButtonCancel := TButton.Create(Self);
  ButtonCancel.Parent := ButtonsLayout;
  ButtonCancel.Align := TAlignLayout.Right;
  ButtonCancel.Width := 110;
  ButtonCancel.Margins.Left := 8;
  ButtonCancel.Text := 'Отмена';
  ButtonCancel.ModalResult := mrCancel;
  ButtonCancel.OnClick := ButtonCancelClick;

  ButtonSelect := TButton.Create(Self);
  ButtonSelect.Parent := ButtonsLayout;
  ButtonSelect.Align := TAlignLayout.Right;
  ButtonSelect.Width := 110;
  ButtonSelect.Text := 'Выбрать';
  ButtonSelect.ModalResult := mrOk;
  ButtonSelect.OnClick := ButtonSelectClick;

  StringGridValuesList := TStringGrid.Create(Self);
  StringGridValuesList.Parent := Layout22;
  StringGridValuesList.Align := TAlignLayout.Client;
  StringGridValuesList.ReadOnly := True;
  StringGridValuesList.OnSelChanged := StringGridValuesListSelChanged;

  AddColumn('№', 45);
  AddColumn('Владелец', 150);
  AddColumn('Описание', 220);
  AddColumn('Значение', 220);
  AddColumn('Текущее', 120);
  AddColumn('Hash', 220);
end;

procedure TFormMeterValueSelect.FillValuesList;
var
  Source: TObjectList<TMeterValue>;
  Item: TMeterValue;
  I: Integer;
begin
  FreeAndNil(FFilteredValues);
  FFilteredValues := TObjectList<TMeterValue>.Create(False);

  Source := TMeterValue.GetMeterValues;
  if Source <> nil then
    for Item in Source do
      FFilteredValues.Add(Item);

  StringGridValuesList.BeginUpdate;
  try
    StringGridValuesList.Tag := 1;
    StringGridValuesList.RowCount := FFilteredValues.Count;
    for I := 0 to FFilteredValues.Count - 1 do
    begin
      Item := FFilteredValues[I];
      StringGridValuesList.Cells[0, I] := IntToStr(I);
      StringGridValuesList.Cells[1, I] := Item.NameOwner;
      StringGridValuesList.Cells[2, I] := Item.Description;
      StringGridValuesList.Cells[3, I] := Item.GetStrFullName;
      StringGridValuesList.Cells[4, I] := Item.GetStrValue;
      StringGridValuesList.Cells[5, I] := Item.Hash;
    end;

    if StringGridValuesList.RowCount > 0 then
      StringGridValuesList.Row := 0;
    StringGridValuesList.Tag := 0;
  finally
    StringGridValuesList.EndUpdate;
  end;
end;

procedure TFormMeterValueSelect.SelectCurrentRow;
begin
  FSelectedMeterValue := nil;
  if (FFilteredValues <> nil) and (StringGridValuesList.Row >= 0) and
     (StringGridValuesList.Row < FFilteredValues.Count) then
    FSelectedMeterValue := FFilteredValues[StringGridValuesList.Row];
end;

procedure TFormMeterValueSelect.StringGridValuesListSelChanged(Sender: TObject);
begin
  if StringGridValuesList.Tag = 0 then
    SelectCurrentRow;
end;

procedure TFormMeterValueSelect.ButtonSelectClick(Sender: TObject);
begin
  SelectCurrentRow;
  ModalResult := mrOk;
end;

procedure TFormMeterValueSelect.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
