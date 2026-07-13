unit frmMeterValueSelect;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
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
    ButtonEdit: TButton;
    EditFindDevice: TEdit;
    sbClear: TSpeedButton;
    sbFind: TSpeedButton;

    procedure BuildUI;
    procedure ApplyFilter;
    procedure FillValuesList;
    procedure SelectCurrentRow;
    function HasActiveFilters: Boolean;
    procedure EditFindDeviceChangeTracking(Sender: TObject);
    procedure sbClearClick(Sender: TObject);
    procedure sbFindClick(Sender: TObject);
    procedure FocusMeterValue(AMeterValue: TMeterValue);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonSelectClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure StringGridValuesListSelChanged(Sender: TObject);
  public
    Layout22: TLayout;
    StringGridValuesList: TStringGrid;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFilterText(const AFilterText: string);
    procedure SelectMeterValue(AMeterValue: TMeterValue);
    property SelectedMeterValue: TMeterValue read FSelectedMeterValue;
  end;

implementation

uses
  frmMeterValueEditFrame;

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
  FilterLayout: TLayout;
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

  FilterLayout := TLayout.Create(Self);
  FilterLayout.Parent := Layout22;
  FilterLayout.Align := TAlignLayout.Top;
  FilterLayout.Height := 36;
  FilterLayout.Margins.Bottom := 6;
  FilterLayout.Stored := False;

  sbClear := TSpeedButton.Create(Self);
  sbClear.Parent := FilterLayout;
  sbClear.Align := TAlignLayout.Right;
  sbClear.Width := 34;
  sbClear.Text := 'X';
  sbClear.OnClick := sbClearClick;

  EditFindDevice := TEdit.Create(Self);
  EditFindDevice.Parent := FilterLayout;
  EditFindDevice.Align := TAlignLayout.Client;
  EditFindDevice.TextPrompt := 'Фильтр';
  EditFindDevice.OnChangeTracking := EditFindDeviceChangeTracking;

  ButtonsLayout := TLayout.Create(Self);
  ButtonsLayout.Parent := Layout22;
  ButtonsLayout.Align := TAlignLayout.Bottom;
  ButtonsLayout.Height := 44;
  ButtonsLayout.Margins.Top := 8;
  ButtonsLayout.Stored := False;

  ButtonCancel := TButton.Create(Self);
  ButtonCancel.Parent := ButtonsLayout;
  ButtonCancel.Align := TAlignLayout.Right;
  ButtonCancel.Width := 100;
  ButtonCancel.Margins.Left := 8;
  ButtonCancel.Text := 'Отмена';
  ButtonCancel.ModalResult := mrCancel;
  ButtonCancel.OnClick := ButtonCancelClick;

  ButtonEdit := TButton.Create(Self);
  ButtonEdit.Parent := ButtonsLayout;
  ButtonEdit.Align := TAlignLayout.Right;
  ButtonEdit.Width := 100;
  ButtonEdit.Margins.Left := 8;
  ButtonEdit.Text := 'Редактировать';
  ButtonEdit.OnClick := ButtonEditClick;

  ButtonSelect := TButton.Create(Self);
  ButtonSelect.Parent := ButtonsLayout;
  ButtonSelect.Align := TAlignLayout.Right;
  ButtonSelect.Width := 100;
  ButtonSelect.Text := 'Выбрать';
  ButtonSelect.ModalResult := mrOk;
  ButtonSelect.OnClick := ButtonSelectClick;

  StringGridValuesList := TStringGrid.Create(Self);
  StringGridValuesList.Parent := Layout22;
  StringGridValuesList.Align := TAlignLayout.Client;
  StringGridValuesList.ReadOnly := True;
  StringGridValuesList.Options := StringGridValuesList.Options +
    [TGridOption.RowSelect, TGridOption.AlwaysShowSelection];
  StringGridValuesList.OnSelChanged := StringGridValuesListSelChanged;

  AddColumn('№', 45);
  AddColumn('Владелец', 150);
  AddColumn('Описание', 220);
  AddColumn('Значение', 220);
  AddColumn('Текущее', 120);
  AddColumn('Hash', 220);
end;

procedure TFormMeterValueSelect.ApplyFilter;
var
  Source: TObjectList<TMeterValue>;
  Item: TMeterValue;
  SearchText, SearchArea: string;
begin
  Source := TMeterValue.GetMeterValues;

  FreeAndNil(FFilteredValues);
  FFilteredValues := TObjectList<TMeterValue>.Create(False);

  if Source = nil then
    Exit;

  SearchText := Trim(AnsiLowerCase(EditFindDevice.Text));
  for Item in Source do
  begin
    if SearchText = '' then
    begin
      FFilteredValues.Add(Item);
      Continue;
    end;

    SearchArea := AnsiLowerCase(Item.NameOwner + ' ' + Item.Description + ' ' +
      Item.GetStrFullName + ' ' + Item.GetStrValue + ' ' + Item.Hash);

    if Pos(SearchText, SearchArea) > 0 then
      FFilteredValues.Add(Item);
  end;
end;

procedure TFormMeterValueSelect.FillValuesList;
var
  Item: TMeterValue;
  I: Integer;
begin
  ApplyFilter;
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
    begin
      StringGridValuesList.Row := 0;
      StringGridValuesList.Selected := 0;
    end;
    if sbFind <> nil then
      sbFind.IsPressed := HasActiveFilters;
    StringGridValuesList.Tag := 0;
  finally
    StringGridValuesList.EndUpdate;
  end;
end;

function TFormMeterValueSelect.HasActiveFilters: Boolean;
begin
  Result := Trim(EditFindDevice.Text) <> '';
end;

procedure TFormMeterValueSelect.EditFindDeviceChangeTracking(Sender: TObject);
begin
  FillValuesList;
  SelectCurrentRow;
end;

procedure TFormMeterValueSelect.sbClearClick(Sender: TObject);
begin
  EditFindDevice.Text := '';
  FillValuesList;
  SelectCurrentRow;
end;

procedure TFormMeterValueSelect.sbFindClick(Sender: TObject);
begin
  FillValuesList;
  SelectCurrentRow;
end;

procedure TFormMeterValueSelect.FocusMeterValue(AMeterValue: TMeterValue);
var
  I: Integer;
begin
  if (AMeterValue = nil) or (FFilteredValues = nil) then
    Exit;

  for I := 0 to FFilteredValues.Count - 1 do
    if (FFilteredValues[I] <> nil) and (FFilteredValues[I].Hash = AMeterValue.Hash) then
    begin
      StringGridValuesList.Row := I;
      StringGridValuesList.Selected := I;
      FSelectedMeterValue := FFilteredValues[I];
      StringGridValuesList.SetFocus;
      StringGridValuesList.Repaint;
      Exit;
    end;
end;

procedure TFormMeterValueSelect.SetFilterText(const AFilterText: string);
begin
  EditFindDevice.OnChangeTracking := nil;
  try
    EditFindDevice.Text := AFilterText;
  finally
    EditFindDevice.OnChangeTracking := EditFindDeviceChangeTracking;
  end;

  FillValuesList;
  SelectCurrentRow;
end;

procedure TFormMeterValueSelect.SelectMeterValue(AMeterValue: TMeterValue);
begin
  FocusMeterValue(AMeterValue);
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

procedure TFormMeterValueSelect.ButtonEditClick(Sender: TObject);
var
  Form: TForm;
  Frame: TFrameMeterValueEdit;
  ButtonsLayout: TLayout;
  ButtonSave: TButton;
  ButtonCancelEdit: TButton;
  EditedMeterValue: TMeterValue;
begin
  SelectCurrentRow;
  EditedMeterValue := FSelectedMeterValue;
  if EditedMeterValue = nil then
    Exit;

  Form := TForm.CreateNew(Self);
  try
    Form.Caption := 'Редактирование MeterValue';
    Form.Width := 820;
    Form.Height := 520;

    ButtonsLayout := TLayout.Create(Form);
    ButtonsLayout.Parent := Form;
    ButtonsLayout.Align := TAlignLayout.Bottom;
    ButtonsLayout.Height := 44;
    ButtonsLayout.Padding.Rect := TRectF.Create(8, 4, 8, 8);

    ButtonCancelEdit := TButton.Create(Form);
    ButtonCancelEdit.Parent := ButtonsLayout;
    ButtonCancelEdit.Align := TAlignLayout.Right;
    ButtonCancelEdit.Width := 110;
    ButtonCancelEdit.Text := 'Отмена';
    ButtonCancelEdit.ModalResult := mrCancel;

    ButtonSave := TButton.Create(Form);
    ButtonSave.Parent := ButtonsLayout;
    ButtonSave.Align := TAlignLayout.Right;
    ButtonSave.Width := 110;
    ButtonSave.Margins.Right := 8;
    ButtonSave.Text := 'Сохранить';
    ButtonSave.ModalResult := mrOk;

    Frame := TFrameMeterValueEdit.Create(Form);
    Frame.Parent := Form;
    Frame.Align := TAlignLayout.Client;
    Frame.LoadFromMeterValue(EditedMeterValue);

    if Form.ShowModal = mrOk then
    begin
      Frame.ApplySettingsToWorkMeterValue;
      Frame.SaveChanges;
      FillValuesList;
      FocusMeterValue(EditedMeterValue);
    end;
  finally
    Form.Free;
  end;
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
