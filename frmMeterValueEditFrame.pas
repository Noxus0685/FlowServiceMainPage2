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

    procedure BuildUI;
    procedure AddEditRow(const ACaption: string; out AEdit: TEdit);
    procedure AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
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

  AddEditRow('Название', EditName);
  AddEditRow('Тип', EditType);
  AddEditRow('Краткое имя', EditShrtName);
  AddEditRow('Описание', EditDescription);
  AddEditRow('Hash', EditHash);
  AddCheckRow('Сохранять', CheckBoxIsToSave);
end;

procedure TFrameMeterValueEdit.AddEditRow(const ACaption: string; out AEdit: TEdit);
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
  CaptionLabel.Width := 160;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := Row;
  AEdit.Align := TAlignLayout.Client;
  AEdit.Margins.Left := 8;
  AEdit.KillFocusByReturn := True;
end;

procedure TFrameMeterValueEdit.AddCheckRow(const ACaption: string; out ACheckBox: TCheckBox);
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
  CaptionLabel.Width := 160;
  CaptionLabel.Text := ACaption;
  CaptionLabel.TextSettings.VertAlign := TTextAlign.Center;
  CaptionLabel.HitTest := False;

  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := Row;
  ACheckBox.Align := TAlignLayout.Client;
  ACheckBox.Margins.Left := 8;
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
      CheckBoxIsToSave.IsChecked := False;
      Exit;
    end;

    EditName.Text := FMeterValue.Name;
    EditType.Text := FMeterValue.&Type;
    EditShrtName.Text := FMeterValue.ShrtName;
    EditDescription.Text := FMeterValue.Description;
    EditHash.Text := FMeterValue.Hash;
    CheckBoxIsToSave.IsChecked := FMeterValue.IsToSave;
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
  FMeterValue.SetToSave(CheckBoxIsToSave.IsChecked);
  TMeterValue.SaveToFile(0);
end;

end.
