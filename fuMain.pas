unit fuMain;

interface

uses
  fuTypeSelect,
  UnitDataManager,
  UnitDeviceClass,
  UnitFlowMeter,
  UnitClasses,
  UnitRepositories,
  UnitBaseProcedures,
  System.Math,
  System.Generics.Collections,


  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Filter.Effects, FMX.Colors, FMX.Effects, FMX.ListBox,
  FMX.Edit, FMX.StdCtrls, FMX.ComboEdit, FMX.EditBox, FMX.SpinBox, FMX.Objects,
  FMX.Grid, FMX.ScrollBox, FMX.Layouts, FMX.Controls.Presentation,
  FMX.TabControl, FMX.Menus;



type

  TRowData = record
    Enabled: Boolean;
    SignalIndex: Integer;
    SignalName: string;
  end;

  TFlowMeterRowData = record
    Enabled: Boolean;
    Channel: Integer;
    Meter: TFlowMeter;
    TypeIndex: Integer;
    SerialIndex: Integer;
  end;

  TFormMain = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabControlWorkTables: TTabControl;
    TabItemWorkTable1: TTabItem;
    Panel2: TPanel;
    Layout1: TLayout;
    GridEtalons: TGrid;
    CheckColumnEtalonEnable1: TCheckColumn;
    StringColumnEtalonChanel1: TStringColumn;
    StringColumnEtalonType1: TStringColumn;
    StringColumnEtalonSerial1: TStringColumn;
    StringColumnEtalonFlowRate1: TStringColumn;
    StringColumnEtalonVolume1: TStringColumn;
    StringColumnEtalonError1: TStringColumn;
    ToolBar2: TToolBar;
    Label30: TLabel;
    Panel3: TPanel;
    GridDevices: TGrid;
    CheckColumnDeviceEnable1: TCheckColumn;
    StringColumnDeviceChanel1: TStringColumn;
    ColumnDeviceType1: TColumn;
    StringColumnDeviceSerial1: TStringColumn;
    StringColumnDeviceFlowRate1: TStringColumn;
    StringColumnDeviceVolume1: TStringColumn;
    StringColumnDeviceError1: TStringColumn;
    ToolBar1: TToolBar;
    Label23: TLabel;
    PanelMain: TPanel;
    PanelInstruments: TPanel;
    LayoutPump: TLayout;
    Line1: TLine;
    Layout3: TLayout;
    LayoutFrequancy: TLayout;
    Rectangle1: TRectangle;
    LabelFreq: TLabel;
    LayoutFreqIn: TLayout;
    Label15: TLabel;
    SpinBoxFreq: TSpinBox;
    LayoutPumpSelect: TLayout;
    ComboEditPumps: TComboEdit;
    SpeedButton3: TSpeedButton;
    SpeedButton28: TSpeedButton;
    Rectangle14: TRectangle;
    Label14: TLabel;
    LayoutConditions: TLayout;
    Layout9: TLayout;
    Layout42: TLayout;
    Rectangle11: TRectangle;
    LabelPres: TLabel;
    Label24: TLabel;
    EditPres: TEdit;
    Layout50: TLayout;
    Label25: TLabel;
    Rectangle12: TRectangle;
    Label13: TLabel;
    Layout6: TLayout;
    Rectangle7: TRectangle;
    LabelTemp: TLabel;
    Layout7: TLayout;
    Label21: TLabel;
    EditTemp: TEdit;
    Label22: TLabel;
    Line3: TLine;
    LayoutFlowRate: TLayout;
    Line5: TLine;
    Layout5: TLayout;
    Layout12: TLayout;
    Rectangle2: TRectangle;
    LabelFlowRate: TLabel;
    Layout13: TLayout;
    Label17: TLabel;
    SpinBoxFlowRate: TSpinBox;
    Layout14: TLayout;
    ComboEditUnits: TComboEdit;
    SpeedButton9: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Rectangle15: TRectangle;
    Label19: TLabel;
    LayoutMain: TLayout;
    Line6: TLine;
    Layout16: TLayout;
    LayoutTaskMain: TLayout;
    ComboBoxTaskMain: TComboBox;
    SpeedButton11: TSpeedButton;
    SpeedButton27: TSpeedButton;
    Rectangle13: TRectangle;
    Label32: TLabel;
    LayoutTaskAddition: TLayout;
    SpeedButton12: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    ComboBoxTaskStep: TComboBox;
    Label36: TLabel;
    LayoutMesure: TLayout;
    Line13: TLine;
    Layout44: TLayout;
    Layout45: TLayout;
    Rectangle8: TRectangle;
    Label51: TLabel;
    Layout46: TLayout;
    Label52: TLabel;
    Edit11: TEdit;
    Layout17: TLayout;
    Rectangle3: TRectangle;
    LabelTime: TLabel;
    Layout48: TLayout;
    Label54: TLabel;
    EditTime: TEdit;
    Layout47: TLayout;
    ComboEdit8: TComboEdit;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    Label53: TLabel;
    Layout49: TLayout;
    Rectangle9: TRectangle;
    LabelVolume: TLabel;
    Label56: TLabel;
    EditVolume: TEdit;
    Layout51: TLayout;
    Label55: TLabel;
    EditImp: TEdit;
    Rectangle10: TRectangle;
    LabelImp: TLabel;
    TabItem2: TTabItem;
    ControlBar: TLayout;
    rctToolsPanelBackground: TRectangle;
    tbShemeColor: TToolBar;
    rct3: TRectangle;
    pnlShemeColor: TPanel;
    Label4: TLabel;
    cbSHEME_COLOR: TComboBox;
    shdwfct12: TShadowEffect;
    pnlBackColor: TPanel;
    Label3: TLabel;
    cbBACK_COLOR: TComboColorBox;
    ShadowEffect11: TShadowEffect;
    lbMainToolButtons: TLayout;
    tbMainPanel: TToolBar;
    rct2: TRectangle;
    sbSaveProject: TSpeedButton;
    ShadowEffect5: TShadowEffect;
    sbSaveSettings: TSpeedButton;
    ShadowEffect6: TShadowEffect;
    sbSetup: TSpeedButton;
    shdwfct4: TShadowEffect;
    sbSound: TSpeedButton;
    ShadowEffect7: TShadowEffect;
    sbToolPosition: TSpeedButton;
    ShadowEffect8: TShadowEffect;
    ebEditProject: TSpeedButton;
    ShadowEffect2: TShadowEffect;
    btnWorkLog: TSpeedButton;
    ShadowEffect4: TShadowEffect;
    btnProjectInfo: TSpeedButton;
    ShadowEffect3: TShadowEffect;
    SpeedButton1: TSpeedButton;
    ShadowEffect15: TShadowEffect;
    tcShemeElements: TTabControl;
    tiControl: TTabItem;
    btnCreatePump: TSpeedButton;
    btnCreateUnoperatedPump: TSpeedButton;
    btnCreatePnevmoValve: TSpeedButton;
    btnCreateElectroValve: TSpeedButton;
    btnCreateBlcdValve: TSpeedButton;
    btnCreateUPP: TSpeedButton;
    btnCreateFlowmeter: TSpeedButton;
    btnCreateTermometer: TSpeedButton;
    btnCreateManometer: TSpeedButton;
    btnCreateFlowmetersPanel: TSpeedButton;
    btnCreateLevelDetector: TSpeedButton;
    btnCreateWaterLevel: TSpeedButton;
    btnCreateScale: TSpeedButton;
    shdwfct5: TShadowEffect;
    tiPipeAndFittings: TTabItem;
    btnCreateElbow: TSpeedButton;
    btnCreateCross: TSpeedButton;
    btnCreateTee: TSpeedButton;
    btnCreateFlange: TSpeedButton;
    btnCreateHorisontalPipe: TSpeedButton;
    btnCreateVerticalPipe: TSpeedButton;
    btnCreatePump_1: TSpeedButton;
    btnCreateMotor: TSpeedButton;
    btnCreate8: TSpeedButton;
    btnCreatefitTank_V: TSpeedButton;
    btnCreate10: TSpeedButton;
    btnCreatefitTank_H: TSpeedButton;
    btnCreatePump_2: TSpeedButton;
    btnCreatePump_3: TSpeedButton;
    shdwfct6: TShadowEffect;
    tiAnimation: TTabItem;
    btnCreateGroupBox: TSpeedButton;
    btnCreateText: TSpeedButton;
    tiUserComponents: TTabItem;
    btnAddUserPrimitive: TSpeedButton;
    btnDeleteUserPrimitive: TSpeedButton;
    shdwfct14: TShadowEffect;
    tbEditProject: TToolBar;
    rct4: TRectangle;
    btnComponentsVisible: TSpeedButton;
    shdwfct9: TShadowEffect;
    btnAnimateVisible: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    btnDeleteComponet: TSpeedButton;
    shdwfct10: TShadowEffect;
    lytWorkTask: TLayout;
    Label11: TLabel;
    cbMainTask: TComboBox;
    sbRunStop: TSpeedButton;
    sbPause: TSpeedButton;
    ShadowEffect10: TShadowEffect;
    btnAbout: TSpeedButton;
    shdwfct11: TShadowEffect;
    lytWorkDesktop: TLayout;
    Label12: TLabel;
    PerspectiveTransformEffect1: TPerspectiveTransformEffect;
    cbWorkDesktop: TComboBox;
    Splitter1: TSplitter;
    ShadowEffect9: TShadowEffect;
    shdwfct8: TShadowEffect;
    TabItem3: TTabItem;
    PopupColumnEtalonSignal1: TPopupColumn;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PopupColumnDeviceSignal1: TPopupColumn;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure GridEtalonsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridEtalonsSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridEtalonsCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDevicesGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDevicesSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridDevicesCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDevicesEditingDone(Sender: TObject; const ACol,
      ARow: Integer);
  private
    { Private declarations }
  FLastClickRow: Integer;
  FLastClickCol: TColumn;
  FLastClickTick: Cardinal;


    FFlowMeters: TObjectList<TFlowMeter>;
    FFlowMeterRows: TArray<TFlowMeterRowData>;
    procedure OpenTypeSelect(ARow: Integer);
    procedure InitFlowMeters;
    procedure ApplyFlowMeterSelection(const ARow: Integer);
    function FindTypeIndex(const ATypeName: string): Integer;
    function FindSerialIndex(const ASerialNumber: string): Integer;
  public
    { Public declarations }
    destructor Destroy; override;
  end;


var
  FormMain: TFormMain;

  FRows: array of TRowData;

implementation

{$R *.fmx}

const
  CFlowMeterTypes: array[0..2] of string = (
    'Расходомер ПРЭМ',
    'Расходомер ЭЛЕМЕР',
    'Расходомер ВЗЛЕТ'
  );

  CFlowMeterSerials: array[0..3] of string = (
    'SN-1001',
    'SN-1002',
    'SN-1003',
    'SN-1004'
  );

destructor TFormMain.Destroy;
begin
  FFlowMeters.Free;
  inherited;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FFlowMeters := TObjectList<TFlowMeter>.Create(True);

  GridDevices.RowCount := 2;

  // Заполняем список через имя колонки
  PopupColumnDeviceSignal1.Items.Clear;
  PopupColumnDeviceSignal1.Items.Add('Импульсный');
  PopupColumnDeviceSignal1.Items.Add('Частотный');
  PopupColumnDeviceSignal1.Items.Add('Токовый');
  PopupColumnDeviceSignal1.Items.Add('Напряжение');

  SetLength(FRows, 2);

  FRows[0].Enabled := True;
  FRows[0].SignalIndex := 0;

  FRows[1].Enabled := False;
  FRows[1].SignalIndex := 1;

  GridDevices.OnGetValue := GridDevicesGetValue;
  GridDevices.OnSetValue := GridDevicesSetValue;
  GridDevices.OnCellClick := GridDevicesCellClick;

  InitFlowMeters;

  FLastClickRow := -1;
FLastClickCol := nil;
FLastClickTick := 0;
end;

procedure TFormMain.InitFlowMeters;
var
  I: Integer;
  Meter: TFlowMeter;
begin
  FFlowMeters.Clear;
  SetLength(FFlowMeterRows, 3);

  for I := 0 to High(FFlowMeterRows) do
  begin
    Meter := TFlowMeter.Create(False);
    Meter.SetChannel(I + 1);
    Meter.DeviceTypeName := CFlowMeterTypes[I mod Length(CFlowMeterTypes)];
    Meter.SerialNumber := CFlowMeterSerials[I mod Length(CFlowMeterSerials)];
    FFlowMeters.Add(Meter);

    FFlowMeterRows[I].Enabled := True;
    FFlowMeterRows[I].Channel := I + 1;
    FFlowMeterRows[I].Meter := Meter;
    FFlowMeterRows[I].TypeIndex := FindTypeIndex(Meter.DeviceTypeName);
    FFlowMeterRows[I].SerialIndex := FindSerialIndex(Meter.SerialNumber);
  end;

  GridDevices.RowCount := Length(FFlowMeterRows);
  GridDevices.Repaint;
end;

function TFormMain.FindTypeIndex(const ATypeName: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterTypes) do
    if SameText(CFlowMeterTypes[I], ATypeName) then
      Exit(I);
end;

function TFormMain.FindSerialIndex(const ASerialNumber: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(CFlowMeterSerials) do
    if SameText(CFlowMeterSerials[I], ASerialNumber) then
      Exit(I);
end;

procedure TFormMain.ApplyFlowMeterSelection(const ARow: Integer);
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  FFlowMeterRows[ARow].TypeIndex := EnsureRange(FFlowMeterRows[ARow].TypeIndex, 0, High(CFlowMeterTypes));
  FFlowMeterRows[ARow].SerialIndex := EnsureRange(FFlowMeterRows[ARow].SerialIndex, 0, High(CFlowMeterSerials));

  FFlowMeterRows[ARow].Meter.DeviceTypeName := CFlowMeterTypes[FFlowMeterRows[ARow].TypeIndex];
  FFlowMeterRows[ARow].Meter.SerialNumber := CFlowMeterSerials[FFlowMeterRows[ARow].SerialIndex];
end;

procedure TFormMain.OpenTypeSelect(ARow: Integer);
var
  Frm: TFormTypeSelect;
  CurrentType, NewType: TDeviceType;
  FoundRepo: TTypeRepository;
  RepoName: string;
  IsTypeChanged, NeedFill: Boolean;
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  CurrentType := nil;

 // if (FDevice = nil) or (DataManager = nil) then
 //   Exit;

  //RefreshDeviceTypeReference;

  Frm := TFormTypeSelect.Create(Self);
  try
    {----------------------------------------------------}
    { 1. Предвыбор текущего типа }
    {----------------------------------------------------}
 //   CurrentType := DataManager.FindType(
 //     FDevice.DeviceTypeUUID,
 //     FDevice.DeviceTypeName,
 //     FoundRepo
 //   );

 //   if (CurrentType <> nil) and (FoundRepo <> nil) then
//    begin
  //    DataManager.ActiveTypeRepo := FoundRepo;
  //    Frm.SelectType(CurrentType);
  //  end;


    if (DataManager <> nil) then
    begin
      CurrentType := DataManager.FindType('', FFlowMeterRows[ARow].Meter.DeviceTypeName, FoundRepo);
      if (CurrentType <> nil) and (FoundRepo <> nil) then
      begin
        DataManager.ActiveTypeRepo := FoundRepo;
        Frm.SelectType(CurrentType);
      end;
    end;

    {----------------------------------------------------}
    { 2. Открываем форму выбора }
    {----------------------------------------------------}
    if Frm.ShowModal <> mrOk then
      Exit;

    NewType := Frm.SelectedType;
    if NewType = nil then
      Exit;

    FoundRepo := DataManager.ActiveTypeRepo;

    {----------------------------------------------------}
    { 3. Проверяем смену типа }
    {----------------------------------------------------}
    IsTypeChanged := True;

    if CurrentType <> nil then
    begin
      if CurrentType = NewType then
        IsTypeChanged := False
      else if (CurrentType.MitUUID <> '') and (NewType.MitUUID <> '') then
        IsTypeChanged :=
          not SameText(CurrentType.MitUUID, NewType.MitUUID)
      else
        IsTypeChanged :=
          (CurrentType.ID <> NewType.ID) or
          (not SameText(CurrentType.Name, NewType.Name)) or
          (not SameText(CurrentType.Modification, NewType.Modification));
    end;

    NeedFill := False;

//    if IsTypeChanged then
//      NeedFill := AskFillFromType;

    {----------------------------------------------------}
    { 4. Привязываем тип }
    {----------------------------------------------------}
    if (DataManager <> nil) and (DataManager.ActiveTypeRepo <> nil) then
      FoundRepo := DataManager.ActiveTypeRepo;

    if FoundRepo <> nil then
      RepoName := FoundRepo.Name
    else
      RepoName := '';

    FFlowMeterRows[ARow].Meter.DeviceTypeName := NewType.Name;
    FFlowMeterRows[ARow].TypeIndex := FindTypeIndex(NewType.Name);

  //  if NeedFill then
  //  begin
  //    FDevice.AttachType(NewType, RepoName);
  //    FDeviceType := NewType;

      {----------------------------------------------------}
      { 5. Копируем данные из типа → в прибор }
      {----------------------------------------------------}
  //    FDevice.FillFromType(NewType);
  //  end;

    {----------------------------------------------------}
    { 6. Обновляем UI }
    {----------------------------------------------------}
  //  UpdateUIFromDevice;

  //  Grid2.Invalidate;   // обновить грид
  //  SetModified;

  finally
    Frm.Free;
  end;
end;

procedure TFormMain.GridDevicesCellClick(const Column: TColumn; const Row: Integer);
const
  SECOND_CLICK_MS = 700; // окно "второго клика" (подбери по ощущениям)
var
  Tick: Cardinal;
  IsSecondClick: Boolean;
  Rows: Integer;
begin
  if (Row < 0) or (Row >= Length(FFlowMeterRows)) then
    Exit;

  Rows := GridDevices.RowCount;
  Tick := TThread.GetTickCount;
  GridDevices.ReadOnly:=True;

  IsSecondClick :=
    (Row = FLastClickRow) and
    (Column = FLastClickCol) ;
   // and (Tick - FLastClickTick <= SECOND_CLICK_MS)

  // Обновляем "последний клик" ВСЕГДА
  FLastClickRow := Row;
  FLastClickCol := Column;
  FLastClickTick := Tick;

  if (Column = CheckColumnDeviceEnable1) then
    FFlowMeterRows[Row].Enabled := not FFlowMeterRows[Row].Enabled;


  if (Column = PopupColumnDeviceSignal1 ) then
   begin
    GridDevices.ReadOnly:=False;
    GridDevices.EditorMode := True;
    inherited;
    Exit;
   end ;


  // Первый клик по ячейке — ничего кроме выделения (грид уже выделил сам)
  if IsSecondClick then
  begin

  // === Второй клик по уже выделенной ячейке — выполняем действие ===
  if Column = ColumnDeviceType1 then
   begin
    GridDevices.EditorMode := False;
    OpenTypeSelect(Row);
    end

  else if Column = StringColumnDeviceSerial1 then
  begin
         GridDevices.ReadOnly:=False;
         GridDevices.EditorMode := True;

    FFlowMeterRows[Row].SerialIndex :=
      (FFlowMeterRows[Row].SerialIndex + 1) mod Length(CFlowMeterSerials);
    ApplyFlowMeterSelection(Row);
  end;

  end;

  GridDevices.BeginUpdate;
  try
    GridDevices.RowCount := Rows;
  finally
    GridDevices.EndUpdate;
  end;
end;

procedure TFormMain.GridDevicesEditingDone(Sender: TObject; const ACol,
  ARow: Integer);
begin
         GridDevices.ReadOnly:=True;
end;

procedure TFormMain.GridDevicesGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
    Value := FFlowMeterRows[ARow].Enabled
  else if GridDevices.Columns[ACol] = StringColumnDeviceChanel1 then
    Value := FFlowMeterRows[ARow].Channel
  else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
    Value := FFlowMeterRows[ARow].Meter.DeviceTypeName
  else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
    Value := FFlowMeterRows[ARow].Meter.SerialNumber;
end;

procedure TFormMain.GridDevicesSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
begin
  if (ARow < 0) or (ARow >= Length(FFlowMeterRows)) then
    Exit;

  if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
    FFlowMeterRows[ARow].Enabled := Value.AsBoolean
  else if GridDevices.Columns[ACol] = ColumnDeviceType1 then
  begin
    FFlowMeterRows[ARow].Meter.DeviceTypeName := Value.AsString;
    FFlowMeterRows[ARow].TypeIndex := FindTypeIndex(FFlowMeterRows[ARow].Meter.DeviceTypeName);
  end
  else if GridDevices.Columns[ACol] = StringColumnDeviceSerial1 then
  begin
    FFlowMeterRows[ARow].Meter.SerialNumber := Value.AsString;
    FFlowMeterRows[ARow].SerialIndex := FindSerialIndex(FFlowMeterRows[ARow].Meter.SerialNumber);
  end;

           GridDevices.ReadOnly:=False;
end;

procedure TFormMain.GridEtalonsCellClick(const Column: TColumn;
  const Row: Integer);
  var  Combo: TComboEdit;
begin
  if (Row < Length(FRows)) then
  begin

  if Column = CheckColumnEtalonEnable1 then
    FRows[Row].Enabled := not  FRows[Row].Enabled;


  if Column = PopupColumnEtalonSignal1 then
  begin

  end;


  if Column = StringColumnEtalonType1 then
   begin
      OpenTypeSelect( Row );
  end;


     GridEtalons.BeginUpdate;
  try
   GridEtalons.RowCount := 2;
  finally
    GridEtalons.EndUpdate;
  end;
end;


  end;


procedure TFormMain.GridEtalonsGetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
begin
  if ARow >= Length(FRows) then Exit;

  if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1 then
    Value := FRows[ARow].Enabled

  //else if ACol = PopupColumnDeviceSignal1.Index then
  //  Value := FRows[ARow].SignalName;   // ← отдаём строку
end;


procedure TFormMain.GridEtalonsSetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
begin
  if ARow >= Length(FRows) then Exit;

  if GridDevices.Columns[ACol] = CheckColumnDeviceEnable1  then
    FRows[ARow].Enabled := Value.AsBoolean

 // else if ACol = PopupColumnSignal.Index then
 //   FRows[ARow].SignalName := Value.AsString;  // ← сохраняем строку
end;

end.
