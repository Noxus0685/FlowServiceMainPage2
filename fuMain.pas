unit fuMain;

interface

uses
  fuTypeSelect,
  UnitDataManager,
  UnitDeviceClass,
  UnitClasses,
  UnitRepositories,
  UnitBaseProcedures,
  System.Math,


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

  TFormMain = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabControlWorkTable: TTabControl;
    TabItem4: TTabItem;
    Panel2: TPanel;
    Layout1: TLayout;
    Grid2: TGrid;
    CheckColumn2: TCheckColumn;
    StringColumn7: TStringColumn;
    StringColumnType: TStringColumn;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    StringColumn11: TStringColumn;
    StringColumn12: TStringColumn;
    StringColumn13: TStringColumn;
    ToolBar2: TToolBar;
    Label30: TLabel;
    Panel3: TPanel;
    GridDevices: TGrid;
    CheckColumn1: TCheckColumn;
    StringColumn1: TStringColumn;
    Column1: TColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    ToolBar1: TToolBar;
    Label23: TLabel;
    TabItem5: TTabItem;
    Panel1: TPanel;
    Layout2: TLayout;
    Grid1: TGrid;
    CheckColumn3: TCheckColumn;
    StringColumn14: TStringColumn;
    StringColumn15: TStringColumn;
    StringColumn16: TStringColumn;
    StringColumn17: TStringColumn;
    StringColumn18: TStringColumn;
    StringColumn19: TStringColumn;
    StringColumn20: TStringColumn;
    ToolBar3: TToolBar;
    Label31: TLabel;
    Panel4: TPanel;
    Grid3: TGrid;
    CheckColumn4: TCheckColumn;
    StringColumn21: TStringColumn;
    Column2: TColumn;
    StringColumn22: TStringColumn;
    StringColumn23: TStringColumn;
    StringColumn24: TStringColumn;
    StringColumn25: TStringColumn;
    StringColumn26: TStringColumn;
    ToolBar4: TToolBar;
    Label33: TLabel;
    TabItem6: TTabItem;
    Panel5: TPanel;
    Layout4: TLayout;
    Grid4: TGrid;
    CheckColumn5: TCheckColumn;
    StringColumn27: TStringColumn;
    StringColumn28: TStringColumn;
    StringColumn29: TStringColumn;
    StringColumn30: TStringColumn;
    StringColumn31: TStringColumn;
    StringColumn32: TStringColumn;
    StringColumn33: TStringColumn;
    ToolBar6: TToolBar;
    Label34: TLabel;
    Panel6: TPanel;
    Grid5: TGrid;
    CheckColumn6: TCheckColumn;
    StringColumn34: TStringColumn;
    Column3: TColumn;
    StringColumn35: TStringColumn;
    StringColumn36: TStringColumn;
    StringColumn37: TStringColumn;
    StringColumn38: TStringColumn;
    StringColumn39: TStringColumn;
    ToolBar7: TToolBar;
    Label35: TLabel;
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
    ShadowEffect9: TShadowEffect;
    shdwfct8: TShadowEffect;
    TabItem3: TTabItem;
    PopupColumnSignal: TPopupColumn;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Grid2GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Grid2SetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure Grid2CellClick(const Column: TColumn; const Row: Integer);
  private
    { Private declarations }
    procedure OpenTypeSelect(ARow: Integer);
  public
    { Public declarations }
  end;


var
  FormMain: TFormMain;

  FRows: array of TRowData;

implementation

{$R *.fmx}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Grid2.RowCount := 2;

  // Заполняем список через имя колонки
  PopupColumnSignal.Items.Clear;
  PopupColumnSignal.Items.Add('Импульсный');
  PopupColumnSignal.Items.Add('Частотный');
  PopupColumnSignal.Items.Add('Токовый');
  PopupColumnSignal.Items.Add('Напряжение');

  SetLength(FRows, 2);

  FRows[0].Enabled := True;
  FRows[0].SignalIndex := 0;

  FRows[1].Enabled := False;
  FRows[1].SignalIndex := 1;
end;

procedure TFormMain.OpenTypeSelect(ARow: Integer);
var
  Frm: TFormTypeSelect;
  CurrentType, NewType: TDeviceType;
  FoundRepo: TTypeRepository;
  RepoName: string;
  IsTypeChanged, NeedFill: Boolean;
begin

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
    if FoundRepo <> nil then
      RepoName := FoundRepo.Name
    else
      RepoName := '';

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

procedure TFormMain.Grid2CellClick(const Column: TColumn;
  const Row: Integer);
  var  Combo: TComboEdit;
begin
  if (Row < Length(FRows)) then
  begin

  if Column = CheckColumn2 then
    FRows[Row].Enabled := not  FRows[Row].Enabled;


  if Column = PopupColumnSignal then
  begin

  end;


  if Column = StringColumnType then
   begin
      OpenTypeSelect( Row );
  end;


     Grid2.BeginUpdate;
  try
    Grid2.RowCount := 2;
  finally
    Grid2.EndUpdate;
  end;
end;


  end;


procedure TFormMain.Grid2GetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
begin
  if ARow >= Length(FRows) then Exit;

  if Grid2.Columns[ACol] = CheckColumn2 then
    Value := FRows[ARow].Enabled

  else if ACol = PopupColumnSignal.Index then
    Value := FRows[ARow].SignalName;   // ← отдаём строку
end;


procedure TFormMain.Grid2SetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
begin
  if ARow >= Length(FRows) then Exit;

  if Grid2.Columns[ACol] = CheckColumn2 then
    FRows[ARow].Enabled := Value.AsBoolean

  else if ACol = PopupColumnSignal.Index then
    FRows[ARow].SignalName := Value.AsString;  // ← сохраняем строку
end;

end.
