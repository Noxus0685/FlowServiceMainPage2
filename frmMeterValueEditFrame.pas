unit frmMeterValueEditFrame;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  uMeterValue;

type
  TFrameMeterValueEdit = class(TFrame)
  private
    FMeterValue: TMeterValue;
    FLoading: Boolean;
    LayoutRoot: TVertScrollBox;
    EditName: TEdit;
    EditType: TEdit;
    EditShrtName: TEdit;
    EditDescription: TEdit;
    EditHash: TEdit;
    CheckBoxIsToSave: TCheckBox;
    EditValueFull: TEdit;
    EditValue: TEdit;
    EditValueDim: TEdit;
    EditMin: TEdit;
    EditMax: TEdit;
    EditNameValueRate: TEdit;
    EditValueRate: TEdit;
    EditNameValueMultiplier: TEdit;
    EditValueMultiplier: TEdit;
    EditNameValueDevider: TEdit;
    EditValueDevider: TEdit;
    EditCoefK: TEdit;
    EditCoefP: TEdit;

    procedure BuildUI;
    procedure AddEditRow(const ACaption: string; out AEdit: TEdit);
    procedure AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
    procedure AddSectionRow(const ACaption: string);
    function SafeFloat(const S: string): Double;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromMeterValue(AMeterValue: TMeterValue);
    procedure SaveChanges;
  end;

implementation

{$R *.fmx}

constructor TFrameMeterValueEdit.Create(AOwner: TComponent);
begin
  inherited;
  BuildUI;
end;

procedure TFrameMeterValueEdit.BuildUI;
begin
  LayoutRoot := TVertScrollBox.Create(Self);
  LayoutRoot.Parent := Self;
  LayoutRoot.Align := TAlignLayout.Client;
  LayoutRoot.Padding.Rect := TRectF.Create(8, 8, 8, 8);
  LayoutRoot.Stored := False;

  AddEditRow('Полное название', EditValueFull);
  AddEditRow('Текущее значение', EditValue);
  AddSectionRow('Основные свойства');
  AddEditRow('Название', EditName);
  AddEditRow('Тип', EditType);
  AddEditRow('Краткое имя', EditShrtName);
  AddEditRow('Описание', EditDescription);
  AddEditRow('Hash', EditHash);
  AddCheckRow('Сохранять', CheckBoxIsToSave);
  AddSectionRow('Значения');
  AddEditRow('Размерность', EditValueDim);
  AddEditRow('Минимальное значение', EditMin);
  AddEditRow('Максимальное значение', EditMax);
  AddSectionRow('Коэффициенты');
  AddEditRow('Наименование Rate', EditNameValueRate);
  AddEditRow('Значение Rate', EditValueRate);
  AddEditRow('Наименование множителя', EditNameValueMultiplier);
  AddEditRow('Значение множителя', EditValueMultiplier);
  AddEditRow('Наименование делителя', EditNameValueDevider);
  AddEditRow('Значение делителя', EditValueDevider);
  AddEditRow('Коэффициент K', EditCoefK);
  AddEditRow('Коэффициент P', EditCoefP);
end;

procedure TFrameMeterValueEdit.AddEditRow(const ACaption: string; out AEdit: TEdit);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 36;
  Item.Margins.Bottom := 4;
  Item.Stored := False;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := RowGrid;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  AEdit := TEdit.Create(Self);
  AEdit.Parent := RowGrid;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  AEdit.KillFocusByReturn := True;
  RowGrid.ControlCollection.AddControl(AEdit, 1, 0);
end;

procedure TFrameMeterValueEdit.AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
var
  Item: TLayout;
  RowGrid: TGridPanelLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 36;
  Item.Margins.Bottom := 4;
  Item.Stored := False;

  RowGrid := TGridPanelLayout.Create(Self);
  RowGrid.Parent := Item;
  RowGrid.Align := TAlignLayout.Client;
  RowGrid.RowCollection.Clear;
  RowGrid.ColumnCollection.Clear;
  RowGrid.ColumnCollection.Add.Value := 45;
  RowGrid.ColumnCollection.Add.Value := 55;
  RowGrid.RowCollection.Add.Value := 100;
  RowGrid.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := RowGrid;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;
  CaptionLabel.Margins.Rect := TRectF.Create(26, 0, 8, 0);
  RowGrid.ControlCollection.AddControl(CaptionLabel, 0, 0);

  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := RowGrid;
  ACheckBox.Align := TAlignLayout.Client;
  ACheckBox.Margins.Rect := TRectF.Create(6, 3, 10, 3);
  RowGrid.ControlCollection.AddControl(ACheckBox, 1, 0);
end;

procedure TFrameMeterValueEdit.AddSectionRow(const ACaption: string);
var
  Item: TLayout;
  CaptionLabel: TLabel;
begin
  Item := TLayout.Create(Self);
  Item.Parent := LayoutRoot;
  Item.Align := TAlignLayout.Top;
  Item.Height := 30;
  Item.Margins.Top := 8;
  Item.Stored := False;

  CaptionLabel := TLabel.Create(Self);
  CaptionLabel.Parent := Item;
  CaptionLabel.Align := TAlignLayout.Client;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.Margins.Rect := TRectF.Create(10, 0, 8, 0);
  CaptionLabel.HitTest := False;
end;

function TFrameMeterValueEdit.SafeFloat(const S: string): Double;
begin
  Result := StrToFloatDef(StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
end;

procedure TFrameMeterValueEdit.LoadFromMeterValue(AMeterValue: TMeterValue);
begin
  FMeterValue := AMeterValue;
  FLoading := True;
  try
    if FMeterValue = nil then
    begin
      EditName.Text := '';
      EditType.Text := '';
      EditShrtName.Text := '';
      EditDescription.Text := '';
      EditHash.Text := '';
      EditValueFull.Text := '';
      EditValue.Text := '';
      EditValueDim.Text := '';
      EditMin.Text := '';
      EditMax.Text := '';
      EditNameValueRate.Text := '';
      EditValueRate.Text := '';
      EditNameValueMultiplier.Text := '';
      EditValueMultiplier.Text := '';
      EditNameValueDevider.Text := '';
      EditValueDevider.Text := '';
      EditCoefK.Text := '';
      EditCoefP.Text := '';
      CheckBoxIsToSave.IsChecked := False;
      Exit;
    end;

    EditValueFull.Text := FMeterValue.GetStrFullName;
    EditValue.Text := FloatToStr(FMeterValue.GetDoubleValueDim);
    EditValueDim.Text := FMeterValue.GetDimName;
    EditMin.Text := FMeterValue.GetStringNum(FMeterValue.MinValue);
    EditMax.Text := FMeterValue.GetStringNum(FMeterValue.MaxValue);
    EditName.Text := FMeterValue.Name;
    EditType.Text := FMeterValue.&Type;
    EditShrtName.Text := FMeterValue.ShrtName;
    EditDescription.Text := FMeterValue.Description;
    EditHash.Text := FMeterValue.Hash;
    CheckBoxIsToSave.IsChecked := FMeterValue.IsToSave;

    if FMeterValue.ValueRate <> nil then
    begin
      EditNameValueRate.Text := FMeterValue.ValueRate.GetStrFullName;
      EditValueRate.Text := FMeterValue.ValueRate.GetStrValue;
    end
    else
    begin
      EditNameValueRate.Text := '-';
      EditValueRate.Text := '-';
    end;

    if FMeterValue.ValueBaseMultiplier <> nil then
    begin
      EditNameValueMultiplier.Text := FMeterValue.ValueBaseMultiplier.GetStrFullName;
      EditValueMultiplier.Text := FMeterValue.ValueBaseMultiplier.GetStrValue;
    end
    else
    begin
      EditNameValueMultiplier.Text := '-';
      EditValueMultiplier.Text := '-';
    end;

    if FMeterValue.ValueBaseDevider <> nil then
    begin
      EditNameValueDevider.Text := FMeterValue.ValueBaseDevider.GetStrFullName;
      EditValueDevider.Text := FMeterValue.ValueBaseDevider.GetStrValue;
    end
    else
    begin
      EditNameValueDevider.Text := '-';
      EditValueDevider.Text := '-';
    end;

    EditCoefK.Text := FloatToStr(FMeterValue.CoefK);
    EditCoefP.Text := FloatToStr(FMeterValue.CoefP);
  finally
    FLoading := False;
  end;
end;

procedure TFrameMeterValueEdit.SaveChanges;
begin
  if FLoading or (FMeterValue = nil) then
    Exit;

  FMeterValue.Name := EditName.Text;
  FMeterValue.&Type := EditType.Text;
  FMeterValue.ShrtName := EditShrtName.Text;
  FMeterValue.Description := EditDescription.Text;
  FMeterValue.Hash := EditHash.Text;
  FMeterValue.SetValue(EditValue.Text);
  FMeterValue.MinValue := FMeterValue.GetDoubleNum(EditMin.Text);
  FMeterValue.MaxValue := FMeterValue.GetDoubleNum(EditMax.Text);
  FMeterValue.CoefK := SafeFloat(EditCoefK.Text);
  FMeterValue.CoefP := SafeFloat(EditCoefP.Text);
  FMeterValue.SetToSave(CheckBoxIsToSave.IsChecked);
  TMeterValue.SaveToFile(0);
end;

end.
