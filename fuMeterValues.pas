unit fuMeterValues;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  FMXTee.Chart,
  FMXTee.Engine,
  FMXTee.Procs,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uMeterValue;

type
  TFormMeterValues = class(TForm)
    StyleBook1: TStyleBook;
    ToolBar1: TToolBar;
    Button1: TButton;
    TabControlMeterValueSettings: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    LayoutCommonSettings: TLayout;
    EditName: TEdit;
    EditShrtName: TEdit;
    EditDescription: TEdit;
    LayoutValues: TLayout;
    EditValue: TEdit;
    EditValueDim: TEdit;
    EditMin: TEdit;
    EditMax: TEdit;
    StringGridCoefsData: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumnValue: TStringColumn;
    StringColumnEtalon: TStringColumn;
    StringColumnQ1: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumnCoefsDataHash: TStringColumn;
    RefreshConfigButton: TButton;
    DeleteConfigButton: TButton;
    AddRowButton: TButton;
    DeleteRowButton: TButton;
    LoadConfigButton: TButton;
    SaveConfigButton: TButton;
    StringGridDimensions: TStringGrid;
    StringColumn8: TStringColumn;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    StringColumn11: TStringColumn;
    StringColumnRecip: TStringColumn;
    StringColumnHash: TStringColumn;
    ButtonCoefsLoad: TButton;
    StringGridCoefs: TStringGrid;
    CheckColumn2: TCheckColumn;
    StringColumn4: TStringColumn;
    StringColumn13: TStringColumn;
    StringColumn14: TStringColumn;
    StringColumn15: TStringColumn;
    StringColumn16: TStringColumn;
    StringColumn17: TStringColumn;
    StringColumn18: TStringColumn;
    Chart1: TChart;
    CheckBoxIsToSave: TCheckBox;
    EditHash: TEdit;
    TabItem4: TTabItem;
    EditTestValueDim: TEdit;
    LabelValueDim: TLabel;
    LabelTestValueDim: TLabel;
    LabelValueRaw: TLabel;
    EditTestValueRaw: TEdit;
    LabelTestValue: TLabel;
    EditValueFull: TEdit;
    LabelValueName: TLabel;
    EditValueType: TEdit;
    TabItemListValues: TTabItem;
    StringGridValuesList: TStringGrid;
    EditNameValueMultiplier: TEdit;
    EditCoefK: TEdit;
    EditCoefP: TEdit;
    EditValueMultiplier: TEdit;
    EditNameValueDevider: TEdit;
    EditValueDevider: TEdit;
    EditNameValueRate: TEdit;
    EditValueRate: TEdit;
    LabelTestValueWoCorrection: TLabel;
    StringColumnDescription: TStringColumn;
    SpeedButtonResetSettings: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure AddRowButtonClick(Sender: TObject);
    procedure StringGridCoefsDataEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure SaveConfigButtonClick(Sender: TObject);
    procedure DeleteRowButtonClick(Sender: TObject);
    procedure RefreshConfigButtonClick(Sender: TObject);
    procedure LoadConfigButtonClick(Sender: TObject);
    procedure StringGridDimensionsSelChanged(Sender: TObject);
    procedure ButtonCoefsLoadClick(Sender: TObject);
    procedure TabControlMeterValueSettingsChange(Sender: TObject);
    procedure CheckBoxIsToSaveChange(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditShrtNameExit(Sender: TObject);
    procedure EditDescriptionExit(Sender: TObject);
    procedure EditHashExit(Sender: TObject);
    procedure EditValueExit(Sender: TObject);
    procedure EditValueDimExit(Sender: TObject);
    procedure EditMinExit(Sender: TObject);
    procedure EditMaxExit(Sender: TObject);
    procedure EditTestValueDimExit(Sender: TObject);
    procedure EditTestValueRawExit(Sender: TObject);
    procedure StringGridCoefsDataSelChanged(Sender: TObject);
    procedure TabItem4Click(Sender: TObject);
    procedure TabItemListValuesClick(Sender: TObject);
    procedure StringGridValuesListSelChanged(Sender: TObject);
    procedure EditCoefKExit(Sender: TObject);
    procedure EditCoefPExit(Sender: TObject);
    procedure SpeedButtonResetSettingsClick(Sender: TObject);
  private
    FCoef: TCoef;
    FCoefHash: string;
    function SafeFloat(const S: string): Double;
    function SafeInt(const S: string): Integer;
    procedure RefreshLayoutValues;
    procedure RefreshLayoutCoefs;
  public
    MeterValue: TMeterValue;
    procedure UpdateLayoutCommonSettings;
    procedure UpdateLayoutValues;
    procedure UpdateStringGridDimensions;
    procedure UpdateStringGridCoefs;
    procedure UpdateStringGridCoefsData;
    procedure UpdateLayoutTest;
    procedure UpdateLayoutValuesList;
    procedure UpdateLayoutCoefs;
  end;

var
  FormMeterValues: TFormMeterValues;

implementation

{$R *.fmx}

function AbsoluteError(const AValue, AArg: Double): Double;
begin
  Result := AValue - AArg;
end;

function RelativeErrorStr(const AValue, AArg: Double): string;
var
  E: Double;
begin
  if Abs(AArg) < 1E-12 then
    Exit('0');
  E := (AValue - AArg) / AArg * 100;
  Result := FloatToStr(E);
end;

function TFormMeterValues.SafeFloat(const S: string): Double;
begin
  Result := StrToFloatDef(StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
end;

function TFormMeterValues.SafeInt(const S: string): Integer;
begin
  Result := StrToIntDef(S, 0);
end;

procedure TFormMeterValues.UpdateLayoutCommonSettings;
begin
  EditName.Text := MeterValue.Name;
  EditValueType.Text := MeterValue.&Type;
  EditShrtName.Text := MeterValue.ShrtName;
  EditDescription.Text := MeterValue.Description;
  EditHash.Text := MeterValue.Hash;

  CheckBoxIsToSave.Tag := 1;
  CheckBoxIsToSave.IsChecked := MeterValue.IsToSave;
  CheckBoxIsToSave.Tag := 0;
end;

procedure TFormMeterValues.UpdateLayoutValues;
begin
  LabelValueName.Text := MeterValue.GetStrFullName;
  EditValueFull.Text := MeterValue.GetStrValue;

  EditValue.Text := FloatToStr(MeterValue.GetDoubleValueDim);
  EditMax.Text := MeterValue.GetStringNum(MeterValue.MaxValue);
  EditMin.Text := MeterValue.GetStringNum(MeterValue.MinValue);
  EditValueDim.Text := MeterValue.GetDimName;
end;

procedure TFormMeterValues.RefreshLayoutValues;
begin
  MeterValue.&Type := EditValueType.Text;
  MeterValue.Name := EditName.Text;
  MeterValue.ShrtName := EditShrtName.Text;
  MeterValue.Description := EditDescription.Text;

  MeterValue.SetValue(EditValue.Text);
  MeterValue.MinValue := MeterValue.GetDoubleNum(EditMin.Text);
  MeterValue.MaxValue := MeterValue.GetDoubleNum(EditMax.Text);
  MeterValue.Hash := EditHash.Text;

  TMeterValue.SaveToFile(0);
end;

procedure TFormMeterValues.FormShow(Sender: TObject);
begin
  if MeterValue <> nil then
  begin
    UpdateLayoutCommonSettings;
    UpdateLayoutValues;
    UpdateStringGridDimensions;
    UpdateStringGridCoefsData;
    UpdateStringGridCoefs;
    UpdateLayoutCoefs;
    UpdateLayoutValuesList;
  end;
end;

procedure TFormMeterValues.UpdateStringGridDimensions;
var
  I: Integer;
begin
  StringGridDimensions.BeginUpdate;
  try
    StringGridDimensions.RowCount := 0;

    if MeterValue.Dimensions.Count > 0 then
    begin
      StringGridDimensions.RowCount := MeterValue.Dimensions.Count;
      for I := 0 to MeterValue.Dimensions.Count - 1 do
      begin
        StringGridDimensions.Cells[0, I] := IntToStr(I + 1);
        StringGridDimensions.Cells[1, I] := MeterValue.Dimensions[I].Name;
        StringGridDimensions.Cells[2, I] := FloatToStr(MeterValue.Dimensions[I].Rate);
        StringGridDimensions.Cells[3, I] := FloatToStr(MeterValue.Dimensions[I].Devider);
        StringGridDimensions.Cells[4, I] := BoolToStr(MeterValue.Dimensions[I].Factor, True);
        StringGridDimensions.Cells[5, I] := BoolToStr(MeterValue.Dimensions[I].Recip, True);
        StringGridDimensions.Cells[6, I] := MeterValue.Dimensions[I].Hash;
      end;
    end;

    StringGridDimensions.Row := MeterValue.CurrentDimIndex;
  finally
    StringGridDimensions.EndUpdate;
  end;
end;

procedure TFormMeterValues.UpdateStringGridCoefsData;
var
  I, Index: Integer;
  Dbl: Double;
begin
  Index := -1;
  StringGridCoefsData.Tag := 1;
  StringGridCoefsData.BeginUpdate;
  try
    StringColumnEtalon.Header := 'Эталон, ' + MeterValue.GetDimName;
    StringColumnValue.Header := 'Знач. прибора, ' + MeterValue.GetDimName;

    StringGridCoefsData.RowCount := 0;

    if MeterValue.Coefs.Count > 0 then
    begin
      StringGridCoefsData.RowCount := MeterValue.Coefs.Count;
      for I := 0 to MeterValue.Coefs.Count - 1 do
      begin
        FCoef := MeterValue.Coefs[I];

        StringGridCoefsData.Cells[0, I] := BoolToStr(FCoef.InUse, True);
        StringGridCoefsData.Cells[1, I] := FCoef.Name;
        StringGridCoefsData.Cells[2, I] := MeterValue.GetStringNum(FCoef.Value);
        StringGridCoefsData.Cells[3, I] := MeterValue.GetStringNum(FCoef.Arg);
        StringGridCoefsData.Cells[4, I] := RelativeErrorStr(FCoef.Value, FCoef.Arg);

        Dbl := AbsoluteError(FCoef.Value, FCoef.Arg);
        StringGridCoefsData.Cells[5, I] := MeterValue.GetStringNum(Dbl);
        StringGridCoefsData.Cells[6, I] := '';
        StringGridCoefsData.Cells[7, I] := FCoef.Hash;

        if SameText(FCoefHash, FCoef.Hash) then
          Index := I;
      end;
    end;
  finally
    StringGridCoefsData.EndUpdate;
  end;

  StringGridCoefsData.Tag := 1;
  StringGridCoefsData.Row := Index;
end;

procedure TFormMeterValues.UpdateStringGridCoefs;
var
  I: Integer;
begin
  StringGridCoefs.BeginUpdate;
  try
    StringGridCoefs.RowCount := 0;
    if MeterValue.Coefs.Count > 0 then
    begin
      StringGridCoefs.RowCount := MeterValue.Coefs.Count;
      for I := 0 to MeterValue.Coefs.Count - 1 do
      begin
        StringGridCoefs.Cells[0, I] := BoolToStr(MeterValue.Coefs[I].InUse, True);
        StringGridCoefs.Cells[1, I] := MeterValue.Coefs[I].Name;
        StringGridCoefs.Cells[2, I] := MeterValue.GetStringNum(MeterValue.Coefs[I].Q1);
        StringGridCoefs.Cells[3, I] := MeterValue.GetStringNum(MeterValue.Coefs[I].Q2);
        StringGridCoefs.Cells[4, I] := FloatToStr(MeterValue.Coefs[I].K);
        StringGridCoefs.Cells[5, I] := FloatToStr(MeterValue.Coefs[I].b);
        StringGridCoefs.Cells[6, I] := MeterValue.Coefs[I].Hash;
      end;
    end;
  finally
    StringGridCoefs.EndUpdate;
  end;
end;

procedure TFormMeterValues.AddRowButtonClick(Sender: TObject);
begin
  FCoefHash := MeterValue.SetCoef(0, 0);
  MeterValue.CalcCoefs;
  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.StringGridCoefsDataEditingDone(Sender: TObject;
  const ACol, ARow: Integer);
var
  Dbl: Double;
  Hash: string;
  Cell: string;
  C: TCoef;
begin
  if (ARow < 0) or (ARow >= MeterValue.Coefs.Count) then
    Exit;

  FCoefHash := StringGridCoefsData.Cells[7, ARow];
  C := MeterValue.Coefs[ARow];
  Cell := StringGridCoefsData.Cells[ACol, ARow];

  case ACol of
    0: C.InUse := SameText(Cell, 'True');
    1: C.Name := Cell;
    2: C.Value := MeterValue.GetDoubleNum(Cell);
    3: C.Arg := MeterValue.GetDoubleNum(Cell);
    4:
      begin
        Dbl := SafeFloat(Cell);
        C.Value := C.Arg / (1 - Dbl / 100);
      end;
    5:
      begin
        Dbl := MeterValue.GetDoubleNum(Cell);
        C.Value := C.Arg + Dbl;
      end;
    7:
      begin
        Hash := Cell;
        if not Hash.IsEmpty then
          C.Hash := Hash;
      end;
  end;

  MeterValue.Coefs[ARow] := C;
  MeterValue.CalcCoefs;

  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;

  StringGridCoefsData.Tag := 2;
end;

procedure TFormMeterValues.SaveConfigButtonClick(Sender: TObject);
begin
  TMeterValue.SaveToFile(0);
end;

procedure TFormMeterValues.DeleteRowButtonClick(Sender: TObject);
begin
  if (StringGridCoefsData.Row <> -1) and
     (StringGridCoefsData.Row < MeterValue.Coefs.Count) then
    MeterValue.Coefs.Delete(StringGridCoefsData.Row);

  UpdateStringGridCoefsData;
  MeterValue.CalcCoefs;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.RefreshConfigButtonClick(Sender: TObject);
begin
  // В Delphi-версии TMeterValue нет SortCoefs, оставляем только обновление.
  UpdateStringGridCoefsData;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.LoadConfigButtonClick(Sender: TObject);
begin
  TMeterValue.LoadFromFile;
  UpdateStringGridCoefsData;
  MeterValue.CalcCoefs;
  UpdateStringGridCoefs;
end;

procedure TFormMeterValues.StringGridDimensionsSelChanged(Sender: TObject);
begin
  if StringGridDimensions.Row <> -1 then
    MeterValue.SetDim(StringGridDimensions.Row);
end;

procedure TFormMeterValues.ButtonCoefsLoadClick(Sender: TObject);
begin
  TMeterValue.LoadFromFile;
end;

procedure TFormMeterValues.TabControlMeterValueSettingsChange(Sender: TObject);
begin
  case TabControlMeterValueSettings.TabIndex of
    0:
      begin
        UpdateLayoutCommonSettings;
        UpdateLayoutValues;
        UpdateLayoutCoefs;
      end;
    1:
      begin
        UpdateStringGridCoefsData;
        UpdateStringGridCoefs;
      end;
    2: UpdateStringGridDimensions;
  end;
end;

procedure TFormMeterValues.CheckBoxIsToSaveChange(Sender: TObject);
begin
  if CheckBoxIsToSave.Tag = 0 then
    MeterValue.SetToSave(CheckBoxIsToSave.IsChecked)
  else
    CheckBoxIsToSave.Tag := 0;
end;

procedure TFormMeterValues.EditNameExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditShrtNameExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditDescriptionExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditHashExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditValueExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditValueDimExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditMinExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditMaxExit(Sender: TObject);
begin
  RefreshLayoutValues;
end;

procedure TFormMeterValues.EditTestValueDimExit(Sender: TObject);
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditTestValueDim.Text);
  MeterValue.SetDimValue(Dbl);
  UpdateLayoutTest;
  EditTestValueRaw.Text := '';
  LabelTestValueWoCorrection.Text := '';
end;

procedure TFormMeterValues.EditTestValueRawExit(Sender: TObject);
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditTestValueRaw.Text);
  MeterValue.SetRawValue(Dbl);
  UpdateLayoutTest;
  EditTestValueDim.Text := '';
end;

procedure TFormMeterValues.UpdateLayoutTest;
begin
  LabelValueRaw.Text := 'Текущее значение (' + MeterValue.RawValueName + ')';
  LabelValueDim.Text := 'Приведенное значение (' + MeterValue.GetStrFullName + ')';

  LabelTestValue.Text := MeterValue.GetStringValue + ' ' + MeterValue.GetDimName(0);

  LabelTestValueWoCorrection.Text :=
    MeterValue.GetStringNum(MeterValue.ValueWoCorrection) + ' ' + MeterValue.GetDimName(0);

  LabelTestValueDim.Text := MeterValue.GetStrValue + ' ' + MeterValue.GetDimName;
end;

procedure TFormMeterValues.StringGridCoefsDataSelChanged(Sender: TObject);
var
  Row, I: Integer;
begin
  if StringGridCoefsData.Tag = 0 then
  begin
    Row := StringGridCoefsData.Row;
    if (Row >= 0) and (Row < StringGridCoefsData.RowCount) then
      FCoefHash := StringGridCoefsData.Cells[7, Row];
  end
  else if StringGridCoefsData.Tag = 2 then
  begin
    StringGridCoefsData.Tag := 1;
    for I := 0 to MeterValue.Coefs.Count - 1 do
      if SameText(MeterValue.Coefs[I].Hash, FCoefHash) then
      begin
        StringGridCoefsData.Row := I;
        Break;
      end;
  end
  else
    StringGridCoefsData.Tag := 0;
end;

procedure TFormMeterValues.TabItem4Click(Sender: TObject);
begin
  UpdateLayoutTest;
end;

procedure TFormMeterValues.UpdateLayoutValuesList;
var
  I, Col: Integer;
  Index: Integer;
  Item: TMeterValue;
  List: TObjectList<TMeterValue>;
begin
  Index := -1;
  StringGridValuesList.BeginUpdate;
  try
    StringGridValuesList.Tag := 1;
    StringGridValuesList.RowCount := 0;

    List := TMeterValue.GetMeterValues;
    if (List <> nil) and (List.Count > 0) then
    begin
      StringGridValuesList.RowCount := List.Count;
      for I := 0 to List.Count - 1 do
      begin
        Item := List[I];
        Col := 0;
        StringGridValuesList.Cells[Col, I] := IntToStr(I); Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.NameOwner; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.Description; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.GetStrFullName; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.GetStrValue; Inc(Col);
        StringGridValuesList.Cells[Col, I] := Item.Hash; Inc(Col);

        if Item.ValueRate <> nil then
        begin
          StringGridValuesList.Cells[Col, I] := Item.ValueRate.GetStrFullName; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueRate.GetStrValue; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueRate.Hash; Inc(Col);
        end;

        if Item.ValueBaseMultiplier <> nil then
        begin
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.GetStrFullName; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.GetStrValue; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseMultiplier.Hash; Inc(Col);
        end;

        if Item.ValueBaseDevider <> nil then
        begin
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.GetStrFullName; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.GetStrValue; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueBaseDevider.Hash; Inc(Col);
        end;

        if Item.ValueCorrection <> nil then
        begin
          StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.GetStrFullName; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.GetStrValue; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueCorrection.Hash; Inc(Col);
        end;

        if Item.ValueEtalon <> nil then
        begin
          StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.GetStrFullName; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.GetStrValue; Inc(Col);
          StringGridValuesList.Cells[Col, I] := Item.ValueEtalon.Hash; Inc(Col);
        end;

        if Item.Hash = MeterValue.Hash then
          Index := I;
      end;
    end;

    StringGridValuesList.Row := Index;
    StringGridValuesList.Tag := 0;
  finally
    StringGridValuesList.EndUpdate;
  end;
end;

procedure TFormMeterValues.TabItemListValuesClick(Sender: TObject);
begin
  UpdateLayoutValuesList;
end;

procedure TFormMeterValues.StringGridValuesListSelChanged(Sender: TObject);
var
  List: TObjectList<TMeterValue>;
begin
  if StringGridValuesList.Tag = 0 then
  begin
    List := TMeterValue.GetMeterValues;
    if (List <> nil) and (StringGridValuesList.Row >= 0) and
       (StringGridValuesList.Row < List.Count) then
      MeterValue := List[StringGridValuesList.Row];
  end;

  UpdateLayoutValues;
  UpdateStringGridCoefs;
  UpdateStringGridCoefsData;
end;

procedure TFormMeterValues.UpdateLayoutCoefs;
begin
  if MeterValue.ValueRate <> nil then
  begin
    EditNameValueRate.Text := MeterValue.ValueRate.GetStrFullName;
    EditValueRate.Text := MeterValue.ValueRate.GetStrValue;
  end
  else
  begin
    EditNameValueRate.Text := '-';
    EditValueRate.Text := '-';
  end;

  if MeterValue.ValueBaseMultiplier <> nil then
  begin
    EditNameValueMultiplier.Text := MeterValue.ValueBaseMultiplier.GetStrFullName;
    EditValueMultiplier.Text := MeterValue.ValueBaseMultiplier.GetStrValue;
  end
  else
  begin
    EditNameValueMultiplier.Text := '-';
    EditValueMultiplier.Text := '-';
  end;

  if MeterValue.ValueBaseDevider <> nil then
  begin
    EditNameValueDevider.Text := MeterValue.ValueBaseDevider.GetStrFullName;
    EditValueDevider.Text := MeterValue.ValueBaseDevider.GetStrValue;
  end
  else
  begin
    EditNameValueDevider.Text := '-';
    EditValueDevider.Text := '-';
  end;

  EditCoefK.Text := FloatToStr(MeterValue.CoefK);
  EditCoefP.Text := FloatToStr(MeterValue.CoefP);
end;

procedure TFormMeterValues.RefreshLayoutCoefs;
var
  Dbl: Double;
begin
  Dbl := SafeFloat(EditCoefK.Text);
  MeterValue.CoefK := Dbl;

  Dbl := SafeFloat(EditCoefP.Text);
  MeterValue.CoefP := Dbl;
end;

procedure TFormMeterValues.SpeedButtonResetSettingsClick(Sender: TObject);
begin
  if MeterValue = nil then
    Exit;

  if SameText(MeterValue.&Type, 'Время') then
    MeterValue.SetAsTime
  else if SameText(MeterValue.&Type, 'Объем') then
    MeterValue.SetAsVolume
  else if SameText(MeterValue.&Type, 'Масса') then
    MeterValue.SetAsMass
  else if SameText(MeterValue.&Type, 'Объемный расход') then
    MeterValue.SetAsVolumeFlow
  else if SameText(MeterValue.&Type, 'Массовый расход') then
    MeterValue.SetAsMassFlow
  else if SameText(MeterValue.&Type, 'Импульсы') then
    MeterValue.SetAsImp
  else if SameText(MeterValue.&Type, 'Погрешность') then
    MeterValue.SetAsError
  else if SameText(MeterValue.&Type, 'Погрешность по массе') then
    MeterValue.SetAsMassError
  else if SameText(MeterValue.&Type, 'Погрешность по объему') then
    MeterValue.SetAsVolumeError
  else if SameText(MeterValue.&Type, 'Расчётная плотность') then
    MeterValue.SetAsDensity
  else if SameText(MeterValue.&Type, 'PT100') then
    MeterValue.SetAsTempPT100
  else if SameText(MeterValue.&Type, 'Температурный датчик') then
    MeterValue.SetAsTemp
  else if SameText(MeterValue.&Type, 'Датчик температуры ИВТМ') then
    MeterValue.SetAsAirTemp
  else if SameText(MeterValue.&Type, 'Датчик токовый') then
    MeterValue.SetAsPressure
  else if SameText(MeterValue.&Type, 'Давление атмосферное') then
    MeterValue.SetAsAirPressure
  else if SameText(MeterValue.&Type, 'Токовый вход') then
    MeterValue.SetAsCurrent
  else if SameText(MeterValue.&Type, 'Коэффициент массы') then
    MeterValue.SetAsMassCoef
  else if SameText(MeterValue.&Type, 'Коэффициент объема') then
    MeterValue.SetAsVolumeCoef
  else if SameText(MeterValue.&Type, 'Датчик влажности') then
    MeterValue.SetAsHumidity
  else if SameText(MeterValue.Name, 'Температура') and SameText(MeterValue.RawValueName, 'Сопротивление') then
    MeterValue.SetAsTempPT100
  else if SameText(MeterValue.Name, 'Температура') then
    MeterValue.SetAsTemp
  else if SameText(MeterValue.Name, 'Температура атм') then
    MeterValue.SetAsAirTemp
  else if SameText(MeterValue.Name, 'Давление') then
    MeterValue.SetAsPressure
  else if SameText(MeterValue.Name, 'Плотность') then
    MeterValue.SetAsDensity
  else if SameText(MeterValue.Name, 'Влажность') then
    MeterValue.SetAsHumidity;

  UpdateLayoutCommonSettings;
  UpdateLayoutValues;
  UpdateStringGridDimensions;
  UpdateLayoutTest;
  UpdateLayoutCoefs;
end;

procedure TFormMeterValues.EditCoefKExit(Sender: TObject);
begin
  RefreshLayoutCoefs;
end;

procedure TFormMeterValues.EditCoefPExit(Sender: TObject);
begin
  RefreshLayoutCoefs;
end;

end.
