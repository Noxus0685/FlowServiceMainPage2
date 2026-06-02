unit frmWorkTableProperties;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uMeterValue,
  uWorkTable;

type
  TFrameWorkTableProperties = class(TFrame)
  private
    FWorkTable: TWorkTable;
    FLoading: Boolean;

    LayoutRoot: TVertScrollBox;
    EditWorkTableText: TEdit;
    EditWorkTableName: TEdit;
    LabelWorkTableUUID: TLabel;
    LabelWorkTableState: TLabel;
    ComboEditMode: TComboBox;
    EditPressure: TEdit;
    EditTemperture: TEdit;
    EditFlowRate: TEdit;
    EditQuantity: TEdit;
    ButtonSelectPressure: TButton;
    ButtonSelectTemperture: TButton;
    ButtonSelectFlowRate: TButton;
    ButtonSelectQuantity: TButton;

    procedure BuildUI;
    procedure AddEditRow(const ACaption: string; out AEdit: TEdit);
    procedure AddLabelRow(const ACaption: string; out ALabel: TLabel);
    procedure AddComboRow(const ACaption: string; out ACombo: TComboBox);
    procedure AddMeterValueRow(const ACaption: string; out AEdit: TEdit; out AButton: TButton;
      AOnClick: TNotifyEvent);
    function MeterValueToText(AMeterValue: TMeterValue): string;
    procedure RefreshValues;
    procedure HandleWorkTableTextExit(Sender: TObject);
    procedure HandleWorkTableNameExit(Sender: TObject);
    procedure HandleEditModeChange(Sender: TObject);
    procedure NotifyRefreshIfChanged(const AChanged: Boolean);
    procedure ApplyEditState;
    procedure SelectMeterValue(AKind: Integer);
    procedure ButtonSelectPressureClick(Sender: TObject);
    procedure ButtonSelectTempertureClick(Sender: TObject);
    procedure ButtonSelectFlowRateClick(Sender: TObject);
    procedure ButtonSelectQuantityClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromWorkTable(AWorkTable: TWorkTable);
  end;

implementation

uses
  frmMeterValueSelect;

{$R *.fmx}

constructor TFrameWorkTableProperties.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
end;

procedure TFrameWorkTableProperties.BuildUI;
begin
  LayoutRoot := TVertScrollBox.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  AddEditRow('Название рабочего стола', EditWorkTableText);
  EditWorkTableText.OnExit := HandleWorkTableTextExit;

  AddEditRow('Имя рабочего стола', EditWorkTableName);
  EditWorkTableName.OnExit := HandleWorkTableNameExit;

  AddLabelRow('UUID рабочего стола', LabelWorkTableUUID);
  AddLabelRow('Текущее состояние', LabelWorkTableState);

  AddComboRow('Редактирование', ComboEditMode);
  ComboEditMode.Items.Add('Можно редактировать');
  ComboEditMode.Items.Add('Нельзя редактировать');
  ComboEditMode.ItemIndex := 0;
  ComboEditMode.OnChange := HandleEditModeChange;

  AddMeterValueRow('Давление', EditPressure, ButtonSelectPressure, ButtonSelectPressureClick);
  AddMeterValueRow('Температура', EditTemperture, ButtonSelectTemperture, ButtonSelectTempertureClick);
  AddMeterValueRow('Расход', EditFlowRate, ButtonSelectFlowRate, ButtonSelectFlowRateClick);
  AddMeterValueRow('Количество жидкости', EditQuantity, ButtonSelectQuantity, ButtonSelectQuantityClick);
end;

procedure TFrameWorkTableProperties.AddEditRow(const ACaption: string; out AEdit: TEdit);
var
  Row: TLayout;
  CaptionLabel: TLabel;
begin
  Row := TLayout.Create(Self);
  Row.Parent := LayoutRoot;
  Row.Align := TAlignLayout.Top;
  Row.Height := 36;
  Row.Margins.Bottom := 4;
  Row.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Row;
  CaptionLabel.Align := TAlignLayout.Left;
  CaptionLabel.Width := 180;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := Row;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Left := 8;
  AEdit.KillFocusByReturn := True;
end;

procedure TFrameWorkTableProperties.AddLabelRow(const ACaption: string; out ALabel: TLabel);
var
  Row: TLayout;
  CaptionLabel: TLabel;
begin
  Row := TLayout.Create(Self);
  Row.Parent := LayoutRoot;
  Row.Align := TAlignLayout.Top;
  Row.Height := 32;
  Row.Margins.Bottom := 4;
  Row.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Row;
  CaptionLabel.Align := TAlignLayout.Left;
  CaptionLabel.Width := 180;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  ALabel := TLabel.Create(Self);
  ALabel.Parent := Row;
  ALabel.Align := TAlignLayout.Client;
  ALabel.Margins.Left := 8;
  ALabel.TextSettings.VertAlign := TTextAlign.Center;
end;

procedure TFrameWorkTableProperties.AddComboRow(const ACaption: string; out ACombo: TComboBox);
var
  Row: TLayout;
  CaptionLabel: TLabel;
begin
  Row := TLayout.Create(Self);
  Row.Parent := LayoutRoot;
  Row.Align := TAlignLayout.Top;
  Row.Height := 36;
  Row.Margins.Bottom := 4;
  Row.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Row;
  CaptionLabel.Align := TAlignLayout.Left;
  CaptionLabel.Width := 180;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  ACombo := TComboBox.Create(Self);
  ACombo.Parent := Row;
  ACombo.Align := TAlignLayout.Client;
  ACombo.Margins.Left := 8;
end;

procedure TFrameWorkTableProperties.AddMeterValueRow(const ACaption: string; out AEdit: TEdit;
  out AButton: TButton; AOnClick: TNotifyEvent);
var
  Row: TLayout;
  CaptionLabel: TLabel;
begin
  Row := TLayout.Create(Self);
  Row.Parent := LayoutRoot;
  Row.Align := TAlignLayout.Top;
  Row.Height := 36;
  Row.Margins.Bottom := 4;
  Row.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Row;
  CaptionLabel.Align := TAlignLayout.Left;
  CaptionLabel.Width := 180;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  AButton := TButton.Create(Self);
  AButton.Parent := Row;
  AButton.Align := TAlignLayout.Right;
  AButton.Width := 36;
  AButton.Margins.Left := 8;
  AButton.Text := '...';
  AButton.OnClick := AOnClick;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := Row;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Left := 8;
  AEdit.ReadOnly := True;
end;

function TFrameWorkTableProperties.MeterValueToText(AMeterValue: TMeterValue): string;
begin
  if AMeterValue = nil then
    Exit('');

  Result := AMeterValue.Name;
  if Trim(Result) = '' then
    Result := AMeterValue.GetStrFullName;
end;

procedure TFrameWorkTableProperties.LoadFromWorkTable(AWorkTable: TWorkTable);
begin
  FWorkTable := AWorkTable;
  RefreshValues;
  ApplyEditState;
end;

procedure TFrameWorkTableProperties.RefreshValues;
begin
  FLoading := True;
  try
    if FWorkTable = nil then
    begin
      EditWorkTableText.Text := '';
      EditWorkTableName.Text := '';
      LabelWorkTableUUID.Text := '';
      LabelWorkTableState.Text := '';
      ComboEditMode.Enabled := False;
      EditPressure.Text := '';
      EditTemperture.Text := '';
      EditFlowRate.Text := '';
      EditQuantity.Text := '';
      Exit;
    end;

    EditWorkTableText.Text := FWorkTable.Text;
    EditWorkTableName.Text := FWorkTable.Name;
    LabelWorkTableUUID.Text := FWorkTable.UUID;
    LabelWorkTableState.Text := TWorkTable.WorkTableStateToString(FWorkTable.State);
    ComboEditMode.Enabled := True;
    EditPressure.Text := MeterValueToText(FWorkTable.ValuePressure);
    EditTemperture.Text := MeterValueToText(FWorkTable.ValueTemperture);
    EditFlowRate.Text := MeterValueToText(FWorkTable.ValueFlowRate);
    EditQuantity.Text := MeterValueToText(FWorkTable.ValueQuantity);
  finally
    FLoading := False;
  end;
end;

procedure TFrameWorkTableProperties.ApplyEditState;
var
  CanEdit: Boolean;
begin
  CanEdit := (FWorkTable <> nil) and (ComboEditMode.ItemIndex = 0);

  EditWorkTableText.Enabled := CanEdit;
  EditWorkTableName.Enabled := CanEdit;
  ButtonSelectPressure.Enabled := CanEdit;
  ButtonSelectTemperture.Enabled := CanEdit;
  ButtonSelectFlowRate.Enabled := CanEdit;
  ButtonSelectQuantity.Enabled := CanEdit;
end;

procedure TFrameWorkTableProperties.HandleEditModeChange(Sender: TObject);
begin
  ApplyEditState;
end;

procedure TFrameWorkTableProperties.NotifyRefreshIfChanged(const AChanged: Boolean);
begin
  if AChanged and (FWorkTable <> nil) then
    FWorkTable.FireEvent(ewtRefresh);
end;

procedure TFrameWorkTableProperties.HandleWorkTableTextExit(Sender: TObject);
var
  NewValue: string;
begin
  if FLoading or (FWorkTable = nil) then
    Exit;

  NewValue := EditWorkTableText.Text;
  if FWorkTable.Text = NewValue then
    Exit;

  FWorkTable.Text := NewValue;
  NotifyRefreshIfChanged(True);
end;

procedure TFrameWorkTableProperties.HandleWorkTableNameExit(Sender: TObject);
var
  NewValue: string;
begin
  if FLoading or (FWorkTable = nil) then
    Exit;

  NewValue := EditWorkTableName.Text;
  if FWorkTable.Name = NewValue then
    Exit;

  FWorkTable.Name := NewValue;
  NotifyRefreshIfChanged(True);
end;

procedure TFrameWorkTableProperties.SelectMeterValue(AKind: Integer);
var
  Form: TFormMeterValueSelect;
  SelectedMeterValue: TMeterValue;
begin
  if (FWorkTable = nil) or (ComboEditMode.ItemIndex <> 0) then
    Exit;

  Form := TFormMeterValueSelect.Create(Self);
  try
    if Form.ShowModal <> mrOk then
      Exit;

    SelectedMeterValue := Form.SelectedMeterValue;
    if SelectedMeterValue = nil then
      Exit;

    case AKind of
      0: FWorkTable.ValuePressure := SelectedMeterValue;
      1: FWorkTable.ValueTemperture := SelectedMeterValue;
      2: FWorkTable.ValueFlowRate := SelectedMeterValue;
      3: FWorkTable.ValueQuantity := SelectedMeterValue;
    else
      Exit;
    end;

    RefreshValues;
    FWorkTable.FireEvent(ewtRefresh);
  finally
    Form.Free;
  end;
end;

procedure TFrameWorkTableProperties.ButtonSelectPressureClick(Sender: TObject);
begin
  SelectMeterValue(0);
end;

procedure TFrameWorkTableProperties.ButtonSelectTempertureClick(Sender: TObject);
begin
  SelectMeterValue(1);
end;

procedure TFrameWorkTableProperties.ButtonSelectFlowRateClick(Sender: TObject);
begin
  SelectMeterValue(2);
end;

procedure TFrameWorkTableProperties.ButtonSelectQuantityClick(Sender: TObject);
begin
  SelectMeterValue(3);
end;

end.
