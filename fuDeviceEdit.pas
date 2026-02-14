unit fuDeviceEdit;

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
  FMX.Grid.Style, FMX.Memo.Types, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.StdCtrls, FMX.Menus, FMX.Memo,
  FMX.DateTimeCtrls, FMX.EditBox, FMX.SpinBox, FMX.Grid, FMX.ScrollBox,
  FMX.Effects, FMX.TabControl, FMX.ListBox, FMX.ComboEdit, FMX.Edit,
  FMX.Controls.Presentation, FMX.Layouts;

type
  TFormDeviceEditor = class(TForm)
    layLeft: TLayout;
    grpCommonInfo: TGroupBox;
    Layout5: TLayout;
    labName: TLabel;
    EditName: TEdit;
    Layout6: TLayout;
    Label11: TLabel;
    ceCategory: TComboEdit;
    Layout3: TLayout;
    Label1: TLabel;
    edtManufacturer: TEdit;
    Layout4: TLayout;
    Label2: TLabel;
    edtDocumentation: TEdit;
    sbDocumentation: TSpeedButton;
    Layout8: TLayout;
    Label3: TLabel;
    edtReestrNumber: TEdit;
    sbFindReestrNumber: TSpeedButton;
    Layout33: TLayout;
    Label29: TLabel;
    EditModification: TEdit;
    LayoutDate: TLayout;
    Label30: TLabel;
    Layout46: TLayout;
    EditValidityDate: TEdit;
    Label34: TLabel;
    EditRegDate: TEdit;
    LayoutIVI: TLayout;
    Label31: TLabel;
    EditIVI: TEdit;
    Layout36: TLayout;
    Label32: TLabel;
    EditAccuracyClass: TEdit;
    Layout31: TLayout;
    Label23: TLabel;
    EditReportingForm: TEdit;
    sbReportingForm: TSpeedButton;
    Layout43: TLayout;
    Label39: TLabel;
    cbProcedure: TComboEdit;
    Layout45: TLayout;
    Label41: TLabel;
    EditError: TEdit;
    grpTypeOfCheck: TGroupBox;
    Layout12: TLayout;
    Label4: TLabel;
    ComboBoxOutputType: TComboBox;
    Layout14: TLayout;
    Label7: TLabel;
    cbMeasuredDimension: TComboBox;
    tcOutPutType: TTabControl;
    tiVoltage: TTabItem;
    grpVoltage: TGroupBox;
    Layout24: TLayout;
    Label21: TLabel;
    cbVoltageRange: TComboBox;
    Layout25: TLayout;
    Label22: TLabel;
    Layout7: TLayout;
    Label5: TLabel;
    EditVoltageQmin: TEdit;
    Layout10: TLayout;
    Label6: TLabel;
    EditVoltageQmax: TEdit;
    tiCurrent: TTabItem;
    grpCurrent: TGroupBox;
    Layout18: TLayout;
    Label16: TLabel;
    cbCurrentRange: TComboBox;
    Layout19: TLayout;
    labCurrentMin: TLabel;
    EditCurrentQmin: TEdit;
    Layout22: TLayout;
    Label17: TLabel;
    Layout23: TLayout;
    Label20: TLabel;
    EditCurrentQmax: TEdit;
    tiImpulse: TTabItem;
    grpFreq: TGroupBox;
    Layout1: TLayout;
    Label9: TLabel;
    cbOutPutType2: TComboBox;
    Layout2: TLayout;
    Label14: TLabel;
    EditCoef: TEdit;
    Layout9: TLayout;
    Label15: TLabel;
    cbCoefViewType: TComboBox;
    tiInterface: TTabItem;
    GroupBox4: TGroupBox;
    Layout28: TLayout;
    Label25: TLabel;
    cbLibrares: TComboBox;
    SpeedButton1: TSpeedButton;
    Layout29: TLayout;
    edtAddr: TEdit;
    Label42: TLabel;
    Layout30: TLayout;
    Label27: TLabel;
    cbBaudRate: TComboBox;
    Layout47: TLayout;
    Label26: TLabel;
    cbParity: TComboBox;
    tiVisual: TTabItem;
    GroupBox5: TGroupBox;
    Layout11: TLayout;
    Label8: TLabel;
    cbInputType: TComboBox;
    Layout13: TLayout;
    Label10: TLabel;
    Edit10: TEdit;
    Layout26: TLayout;
    Label12: TLabel;
    ComboBox3: TComboBox;
    Layout27: TLayout;
    Label13: TLabel;
    Edit11: TEdit;
    tiFrequency: TTabItem;
    GroupBox3: TGroupBox;
    Layout39: TLayout;
    Label35: TLabel;
    cbOutPutType: TComboBox;
    Layout40: TLayout;
    Label36: TLabel;
    EditFreq: TEdit;
    Layout41: TLayout;
    Label37: TLabel;
    ComboBox6: TComboBox;
    Layout42: TLayout;
    Label38: TLabel;
    EditFreqFlowRate: TEdit;
    shdwfct1: TShadowEffect;
    layRight: TLayout;
    grpWorkShedule: TGroupBox;
    Layout15: TLayout;
    GridPoints: TGrid;
    StringColumnPointName: TStringColumn;
    StringColumnPointFlowRate: TStringColumn;
    StringColumnPointQ: TStringColumn;
    StringColumnPointVolume: TStringColumn;
    StringColumnPointImp: TStringColumn;
    StringColumnPointTime: TStringColumn;
    StringColumnPointError: TStringColumn;
    StringColumnPointFlowError: TStringColumn;
    StringColumnPointStab: TStringColumn;
    IntegerColumnPointRepeatsForm: TIntegerColumn;
    IntegerColumnPointRepeats: TIntegerColumn;
    StringColumnPointPres: TStringColumn;
    StringColumnPontTemp: TStringColumn;
    StringColumnPointTempError: TStringColumn;
    Layout17: TLayout;
    Label24: TLabel;
    cbSpillageStop: TComboBox;
    Label28: TLabel;
    cbSpillageType: TComboBox;
    Layout38: TLayout;
    ButtonPointDelete: TButton;
    ButtonPointAdd: TButton;
    ButtonPointsClear: TButton;
    Label40: TLabel;
    sbRepeats: TSpinBox;
    shdwfct2: TShadowEffect;
    GroupBox6: TGroupBox;
    Layout37: TLayout;
    Label44: TLabel;
    edtOwner: TEdit;
    Layout44: TLayout;
    Label45: TLabel;
    mmoComment: TMemo;
    layTop: TLayout;
    GroupBox1: TGroupBox;
    lytButtons: TLayout;
    btnOK: TCornerButton;
    btnCancel: TCornerButton;
    shdwfct3: TShadowEffect;
    MemoLog: TMemo;
    DeepSeek: TSpeedButton;
    NetHTTPClient1: TNetHTTPClient;
    ppmnuCalculateVolume: TPopupMenu;
    miCalculateVolume: TMenuItem;
    Splitter1: TSplitter;
    GroupBox7: TGroupBox;
    Layout48: TLayout;
    Label46: TLabel;
    Layout49: TLayout;
    Label47: TLabel;
    EditQmax: TEdit;
    Layout50: TLayout;
    Label48: TLabel;
    EditTypeName: TEdit;
    SpeedButtonFindType: TSpeedButton;
    ComboEditDN: TComboEdit;
    Layout32: TLayout;
    Label43: TLabel;
    edtSerialNumber: TEdit;
    Layout16: TLayout;
    Label33: TLabel;
    dedtDateOfManufacture: TDateEdit;
    EditQmin: TEdit;
    Label49: TLabel;
    StringColumnHash: TStringColumn;
    ShadowEffect1: TShadowEffect;
    procedure GridPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure SpeedButtonFindTypeClick(Sender: TObject);
    procedure ceCategoryChange(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditNameTyping(Sender: TObject);
    procedure EditTypeNameExit(Sender: TObject);
    procedure edtManufacturerExit(Sender: TObject);
    procedure EditModificationExit(Sender: TObject);
    procedure edtReestrNumberExit(Sender: TObject);
    procedure edtReestrNumberTyping(Sender: TObject);
    procedure edtDocumentationExit(Sender: TObject);
    procedure EditAccuracyClassExit(Sender: TObject);
    procedure EditErrorExit(Sender: TObject);
    procedure EditReportingFormExit(Sender: TObject);
    procedure cbMeasuredDimensionChange(Sender: TObject);
    procedure ComboBoxOutputTypeChange(Sender: TObject);
    procedure cbVoltageRangeChange(Sender: TObject);
    procedure EditVoltageQmaxExit(Sender: TObject);
    procedure EditVoltageQminExit(Sender: TObject);
    procedure cbCurrentRangeChange(Sender: TObject);
    procedure cbOutPutType2Change(Sender: TObject);
    procedure cbCoefViewTypeChange(Sender: TObject);
    procedure EditCoefExit(Sender: TObject);
    procedure cbOutPutTypeChange(Sender: TObject);
    procedure EditFreqExit(Sender: TObject);
    procedure EditFreqFlowRateExit(Sender: TObject);
    procedure edtOwnerExit(Sender: TObject);
    procedure edtSerialNumberExit(Sender: TObject);
    procedure edtSerialNumberTyping(Sender: TObject);
    procedure dedtDateOfManufactureChange(Sender: TObject);
    procedure ButtonPointAddClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonPointDeleteClick(Sender: TObject);
    procedure ButtonPointsClearClick(Sender: TObject);
    procedure ComboEditDNChange(Sender: TObject);
    procedure mmoCommentExit(Sender: TObject);


  private
    { Private declarations }
     FDevice: TDevice;
     FOriginalDevice: TDevice;


     FDeviceType: TDeviceType; // ссылка на найденный тип
     FLoading: Boolean;
     FBlockCategoryEdit: Boolean;

     procedure ApplyMassMode;
     procedure ApplyVolumeMode;
     procedure ApplyMeasuredDimension;
     procedure ApplyOutputType;

     procedure FillSpillageStopVolume;
     procedure FillSpillageStopMass;
     procedure FillConversionCoefVolume;
     procedure FillConversionCoefMass;

     function GetDisplayedCoef: Double;
     procedure RecalcDevicePointsCoef;
     procedure RefreshDeviceTypeReference;

     procedure UpdateUIFromDevice;
     procedure InitCategoryComboEdit;
     procedure UpdatePointsGrid;
     procedure SetModified;

     procedure CloseEditor(ASave: Boolean);
     function   GetSelectedPoint: TDevicePoint;
     function GetPointByVisibleRow(ARow: Integer): TDevicePoint;
      procedure UpdateQmaxQmin;

  public
    { Public declarations }
     procedure LoadDevice(ADevice: TDevice);
  end;

var
  FormDeviceEditor: TFormDeviceEditor;

implementation

{$R *.fmx}

procedure TFormDeviceEditor.ApplyMeasuredDimension;
var
  Dim: TMeasuredDimension;
begin
  if FDevice = nil then
    Exit;

  FLoading := True;
  try
    {----------------------------------}
    { Синхронизация ComboBox }
    {----------------------------------}
    if (FDevice.MeasuredDimension >= 0) and
       (FDevice.MeasuredDimension < cbMeasuredDimension.Items.Count) then
      cbMeasuredDimension.ItemIndex := FDevice.MeasuredDimension
    else
    begin
      cbMeasuredDimension.ItemIndex := -1;
      Exit;
    end;

    Dim := TMeasuredDimension(FDevice.MeasuredDimension);
    cbMeasuredDimension.Hint := cbMeasuredDimension.Text;

    // ==================================================
    // СБРОС ЗАГОЛОВКОВ
    // ==================================================
    StringColumnPointQ.Header      := '';
    StringColumnPointVolume.Header := '';

    // ==================================================
    // КРИТЕРИЙ ОСТАНОВКИ (cbSpillageStop)
    // ==================================================
    cbSpillageStop.Items.BeginUpdate;
    try
      cbSpillageStop.Items.Clear;

      // Импульсы доступны всегда
      cbSpillageStop.Items.Add('Импульсы');

      case Dim of
        mdVolumeFlow,
        mdVolume:
          cbSpillageStop.Items.Add('Объем, л');

        mdMassFlow,
        mdMass:
          cbSpillageStop.Items.Add('Масса, кг');

        mdSpeed:
          cbSpillageStop.Items.Add('Скорость');

        mdHeat:
          cbSpillageStop.Items.Add('Теплота');
      end;

      // Время доступно всегда
      cbSpillageStop.Items.Add('Время, с');
    finally
      cbSpillageStop.Items.EndUpdate;
    end;

    if cbSpillageStop.ItemIndex < 0 then
      cbSpillageStop.ItemIndex := 0;

    // ==================================================
    // ОСНОВНАЯ ЛОГИКА ПО ИЗМЕРЯЕМОЙ ВЕЛИЧИНЕ
    // ==================================================
    case Dim of

      // --------------------------------------------------
      // ОБЪЁМНЫЙ РАСХОД / ОБЪЁМ
      // --------------------------------------------------
      mdVolumeFlow,
      mdVolume:
        ApplyVolumeMode;

      // --------------------------------------------------
      // МАССОВЫЙ РАСХОД / МАССА
      // --------------------------------------------------
      mdMassFlow,
      mdMass:
        ApplyMassMode;

      // --------------------------------------------------
      // СКОРОСТЬ
      // --------------------------------------------------
      mdSpeed:
        begin
          StringColumnPointQ.Header := 'V, м/с';
        end;

      // --------------------------------------------------
      // ТЕПЛОТА
      // --------------------------------------------------
      mdHeat:
        begin
          StringColumnPointQ.Header      := 'Q, Гкал/ч';
          StringColumnPointVolume.Header := 'E, Гкал';
        end;
    end;

    // ==================================================
    // ОБНОВЛЕНИЕ ТАБЛИЦ
    // ==================================================
    UpdatePointsGrid;

  finally
    FLoading := False;
  end;
end;

procedure TFormDeviceEditor.ApplyVolumeMode;
begin
  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, м³/ч';
  StringColumnPointVolume.Header := 'V, л';

  // ===== Критерий остановки =====
  FillSpillageStopVolume;

  // ===== Представление коэффициента =====
  FillConversionCoefVolume;
end;

procedure TFormDeviceEditor.btnCancelClick(Sender: TObject);
begin
  // Отменяем все изменения
  if FDevice.State = osModified then
  begin
    // Если форма была изменена, запрашиваем подтверждение
    if MessageDlg('Вы уверены, что хотите отменить изменения?', TMsgDlgType.mtWarning,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      // Возвращаем форму в исходное состояние
      DataManager.ActiveDeviceRepo.Load;    // предполагается, что у FDevice есть метод для отката изменений

      // Закрываем форму с результатом Cancel
      ModalResult := mrCancel;
    end;
  end
  else
  begin
    // Если изменений не было, просто закрываем форму
    ModalResult := mrCancel;
  end;
end;

procedure TFormDeviceEditor.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFormDeviceEditor.ButtonPointAddClick(Sender: TObject);
var
  NewP: TDevicePoint;
  AccClass: Double;
begin
  if (FDevice = nil) or (FDevice.Points = nil) then
    Exit;

  {-----------------------------------------------------}
  { Создаём НОВУЮ точку прибора }
  {-----------------------------------------------------}
  NewP := FDevice.AddPoint;

  {-----------------------------------------------------}
  { Имя и расход }
  {-----------------------------------------------------}
  if NewP.FlowRate < 1 then
    NewP.Name := Format('%g · Qmax', [NewP.FlowRate])
  else
    NewP.Name := 'Qmax';

  {-----------------------------------------------------}
  { Базовые параметры }
  {-----------------------------------------------------}
  NewP.LimitImp  := 10000;
  NewP.LimitTime := 52;
  NewP.Pause     := 10;
  NewP.Pressure  := 0;
  NewP.Temp      := 0;

  {-----------------------------------------------------}
  { Класс точности → погрешности }
  {-----------------------------------------------------}
  AccClass := ParseAccuracyClass(EditAccuracyClass.Text);

  { Погрешность прибора }
  NewP.Error := AccClass;

  { Погрешность задания расхода }
  if AccClass > 1 then
    NewP.FlowAccuracy := '±10%'
  else if AccClass >= 0.5 then
    NewP.FlowAccuracy := '±5%'
  else
    NewP.FlowAccuracy := '±2%';

  {-----------------------------------------------------}
  { Повторы }
  {-----------------------------------------------------}
  NewP.RepeatsProtocol := 3;
  NewP.Repeats := 3;


  {-----------------------------------------------------}
  { Обновляем таблицу }
  {-----------------------------------------------------}
  UpdatePointsGrid;

  {-----------------------------------------------------}
  { Выделяем новую точку }
  {-----------------------------------------------------}
  if GridPoints.RowCount > 0 then
    GridPoints.Selected := GridPoints.RowCount - 1;

  SetModified;
end;

function TFormDeviceEditor.GetSelectedPoint: TDevicePoint;
var
  VisibleIndex: Integer;
  i, VisibleCounter: Integer;
  SelectedRow: Integer;
begin
    Result := nil;
  SelectedRow := GridPoints.Selected;
  if (FDevice = nil) then
    Exit;

  if GridPoints.Row < 0 then
    Exit;

    if SelectedRow < 0 then
    Exit;


  VisibleIndex := SelectedRow;
  VisibleCounter := -1;

  for i := 0 to FDevice.Points.Count - 1 do
  begin
    if FDevice.Points[i].State <> osDeleted then
    begin
      Inc(VisibleCounter);

      if VisibleCounter = VisibleIndex then
      begin
        Result := FDevice.Points[i];
        Exit;
      end;
    end;
  end;
end;


procedure TFormDeviceEditor.ButtonPointDeleteClick(Sender: TObject);
var
  Point: TDevicePoint;
  PointIdx: Integer;
begin
  if FDevice = nil then
    Exit;

  Point := GetSelectedPoint;  // ← твой метод получения выбранной точки

  if Point = nil then
    Exit;

  {----------------------------------}
  { Если точка новая — удаляем физически }
  {----------------------------------}
  if Point.State = osNew then
  begin
    PointIdx := FDevice.Points.IndexOf(Point);
    if PointIdx >= 0 then
      FDevice.Points.Delete(PointIdx);
  end
  else
  begin
    {----------------------------------}
    { Если точка существующая — помечаем }
    {----------------------------------}
    Point.State := osDeleted;
  end;
  SetModified;

  GridPoints.Row := -1;

  UpdatePointsGrid;  // обновить UI
end;

procedure TFormDeviceEditor.ButtonPointsClearClick(Sender: TObject);
var
  I: Integer;
  P: TDevicePoint;
begin
  if (FDevice = nil) or (FDevice.Points = nil) or (FDevice.Points.Count = 0) then
    Exit;

  for I := FDevice.Points.Count - 1 downto 0 do
  begin
    P := FDevice.Points[I];
    if P.State = osNew then
      FDevice.Points.Delete(I)
    else
      P.State := osDeleted;
  end;

  GridPoints.Row := -1;
  UpdatePointsGrid;
  SetModified;
end;

procedure TFormDeviceEditor.ApplyMassMode;
begin
  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, т/ч';
  StringColumnPointVolume.Header := 'M, кг';

  // ===== Критерий остановки =====
  FillSpillageStopMass;

  // ===== Представление коэффициента =====
  FillConversionCoefMass;
end;

procedure TFormDeviceEditor.FillSpillageStopVolume;
begin
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;
    cbSpillageStop.Items.Add('Импульсы');
    cbSpillageStop.Items.Add('Объем, л');
    cbSpillageStop.Items.Add('Время, с');
  finally
    cbSpillageStop.Items.EndUpdate;
  end;

  if cbSpillageStop.ItemIndex < 0 then
    cbSpillageStop.ItemIndex := 0;
end;

procedure TFormDeviceEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
      FreeAndNil(FDevice);      // уничтожаем клон
      FOriginalDevice := nil;
end;

procedure TFormDeviceEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;

  try
    if ModalResult = mrOk then
    begin
      {----------------------------------}
      { Нажали OK }
      {----------------------------------}

      if FOriginalDevice <> nil then
      begin
        { редактирование существующего }
        FOriginalDevice.Assign(FDevice);
        DataManager.ActiveDeviceRepo.SaveDevice(FOriginalDevice);
      end
      else
      begin
        { новый прибор }
        DataManager.ActiveDeviceRepo.SaveDevice(FDevice);
      end;
    end
    else if ModalResult = mrCancel then
    begin
      {----------------------------------}
      { Нажали Отмена }
      {----------------------------------}
      { Ничего не сохраняем }
      { Просто закрываем форму }
    end;

  except
    on E: Exception do
    begin
      CanClose := False;
      ShowMessage('Ошибка сохранения: ' + E.Message);
    end;
  end;
end;

procedure TFormDeviceEditor.FillSpillageStopMass;
begin
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;
    cbSpillageStop.Items.Add('Импульсы');
    cbSpillageStop.Items.Add('Масса, кг');
    cbSpillageStop.Items.Add('Время, с');
  finally
    cbSpillageStop.Items.EndUpdate;
  end;

  if cbSpillageStop.ItemIndex < 0 then
    cbSpillageStop.ItemIndex := 0;
end;

procedure TFormDeviceEditor.FillConversionCoefVolume;
begin
  cbCoefViewType.Items.BeginUpdate;
  try
    cbCoefViewType.Items.Clear;
    cbCoefViewType.Items.Add('Имп/л');
    cbCoefViewType.Items.Add('л/имп');
  finally
    cbCoefViewType.Items.EndUpdate;
  end;

  if cbCoefViewType.ItemIndex < 0 then
    cbCoefViewType.ItemIndex := 0;
end;

procedure TFormDeviceEditor.FillConversionCoefMass;
begin
  cbCoefViewType.Items.BeginUpdate;
  try
    cbCoefViewType.Items.Clear;
    cbCoefViewType.Items.Add('Имп/кг');
    cbCoefViewType.Items.Add('кг/имп');
  finally
    cbCoefViewType.Items.EndUpdate;
  end;

  if cbCoefViewType.ItemIndex < 0 then
    cbCoefViewType.ItemIndex := 0;
end;

procedure TFormDeviceEditor.ApplyOutputType;
begin
  if FDevice = nil then
    Exit;

  // --- выбор вкладки по имени ---
  case FDevice.OutputType of
    0: tcOutPutType.ActiveTab := tiFrequency;  // Частота
    1: tcOutPutType.ActiveTab := tiImpulse;    // Импульсы
    2: tcOutPutType.ActiveTab := tiVoltage;    // Напряжение
    3: tcOutPutType.ActiveTab := tiCurrent;    // Ток
    4: tcOutPutType.ActiveTab := tiInterface;  // Интерфейс
    5: tcOutPutType.ActiveTab := tiVisual;     // Визуальный
  end;

  // --- столбцы коэффициентов / импульсов (ТОЛЬКО точки прибора) ---
  case FDevice.OutputType of
    0, // Частота
    1: // Импульсы
      begin
        StringColumnPointImp.Visible := True;
      end;
  else
    begin
      StringColumnPointImp.Visible := False;
    end;
  end;
end;

function TFormDeviceEditor.GetDisplayedCoef: Double;
begin
  Result := 0;

  if FDevice = nil then
    Exit;

  // базовый коэффициент всегда хранится как имп/л (имп/кг)
  if FDevice.Coef <= 0 then
    Exit;

  case FDevice.DimensionCoef of
    0: // имп/л (имп/кг)
      Result := FDevice.Coef;

    1: // л/имп (кг/имп)
      Result := 1 / FDevice.Coef;
  else
    Result := FDevice.Coef;
  end;
end;

procedure TFormDeviceEditor.LoadDevice(ADevice: TDevice);
var
  FoundType: TDeviceType;
  FoundRepo: TTypeRepository;
begin
  FLoading := True;
  try
    FreeAndNil(FDevice);
    FDeviceType := nil;

    if ADevice <> nil then
    begin
      {----------------------------------}
      { Редактирование существующего прибора }
      {----------------------------------}
      FOriginalDevice := ADevice;
      FDevice := ADevice.Clone;
    end
    else
    begin
      {----------------------------------}
      { Новый прибор }
      {----------------------------------}
      FOriginalDevice := nil;
      FDevice := DataManager.ActiveDeviceRepo.CreateDevice(0);
      FDevice.State := osNew;
    end;

    {----------------------------------}
    { Поиск типа по UUID и имени }
    {----------------------------------}
    if (DataManager <> nil) and
       ((FDevice.DeviceTypeUUID <> '') or
        (FDevice.DeviceTypeName <> '')) then
    begin
      FoundType :=
        DataManager.FindType(
          FDevice.DeviceTypeUUID,
          FDevice.DeviceTypeName,
          FoundRepo
        );

      if FoundType <> nil then
      begin
        FDeviceType := FoundType;
        if FoundRepo <> nil then
          DataManager.ActiveTypeRepo := FoundRepo;
      end;
    end;

    UpdateUIFromDevice;

  finally
    FLoading := False;
  end;
end;

procedure TFormDeviceEditor.mmoCommentExit(Sender: TObject);
begin
   FDevice.Description :=   mmoComment.Text;
end;

procedure TFormDeviceEditor.RefreshDeviceTypeReference;
var
  FoundType: TDeviceType;
  FoundRepo: TTypeRepository;
begin
  if (DataManager = nil) or (FDevice = nil) then
    Exit;

  if (FDevice.DeviceTypeUUID = '') and (FDevice.DeviceTypeName = '') then
  begin
    FDeviceType := nil;
    Exit;
  end;

  FoundType := DataManager.FindType(
    FDevice.DeviceTypeUUID,
    FDevice.DeviceTypeName,
    FoundRepo
  );

  FDeviceType := FoundType;
  if FoundRepo <> nil then
    DataManager.ActiveTypeRepo := FoundRepo;
end;


procedure TFormDeviceEditor.SpeedButtonFindTypeClick(Sender: TObject);
var
  Frm: TFormTypeSelect;
  CurrentType, NewType: TDeviceType;
  FoundRepo: TTypeRepository;
  NeedFill, IsTypeChanged: Boolean;
  RepoName: string;

function AskFillFromType: Boolean;
begin
  Result :=
    MessageDlg(
      'Тип прибора изменён.' + sLineBreak +
      'Заполнить данные прибора на основании выбранного типа?',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      0
    ) = mrYes;
end;

begin
  if (FDevice = nil) or (DataManager = nil) then
    Exit;

  RefreshDeviceTypeReference;

  Frm := TFormTypeSelect.Create(Self);
  try
    {----------------------------------------------------}
    { 1. Предвыбор текущего типа }
    {----------------------------------------------------}
    CurrentType := DataManager.FindType(FDevice.DeviceTypeUUID, FDevice.DeviceTypeName, FoundRepo);
    if (CurrentType <> nil) and (FoundRepo <> nil) then
    begin
      DataManager.ActiveTypeRepo := FoundRepo;
      Frm.SelectType(CurrentType);
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
      if (CurrentType = NewType) then
        IsTypeChanged := False
      else if (CurrentType.MitUUID <> '') and (NewType.MitUUID <> '') then
        IsTypeChanged := not SameText(CurrentType.MitUUID, NewType.MitUUID)
      else
        IsTypeChanged :=
          (CurrentType.ID <> NewType.ID) or
          (not SameText(CurrentType.Name, NewType.Name)) or
          (not SameText(CurrentType.Modification, NewType.Modification));
    end;

    //NeedFill := IsTypeChanged;

    //if NeedFill then
      NeedFill := AskFillFromType;

    {----------------------------------------------------}
    { 4. Привязываем тип }
    {----------------------------------------------------}
    if FoundRepo <> nil then
      RepoName := FoundRepo.Name
    else
      RepoName := '';

    if NeedFill then
    begin
      FDevice.AttachType(NewType, RepoName);
      FDeviceType := NewType;

    {----------------------------------------------------}
    { 5. Копируем данные из типа → в прибор }
    {----------------------------------------------------}

      FDevice.FillFromType(NewType);
    end;





    {----------------------------------------------------}
    { 6. Обновляем UI }
    {----------------------------------------------------}
    UpdateUIFromDevice;

    SetModified;

  finally
    Frm.Free;
  end;
end;

 procedure TFormDeviceEditor.UpdateQmaxQmin;
 begin
    // =====================================================
// == Максимальный расход
// =====================================================
EditQmax.Text := '';
EditQmax.TextPrompt := '';

if FDevice.Qmax > 0 then
  EditQmax.Text :=  FormatQorV(FDevice.Qmax, FDevice.Error)
else
  EditQmax.TextPrompt := '—';

// =====================================================
// == Минимальный расход
// =====================================================
EditQmin.Text := '';
EditQmin.TextPrompt := '';

if FDevice.Qmin > 0 then
  EditQmin.Text :=  FormatQorV(FDevice.Qmin, FDevice.Error)
else
  EditQmin.TextPrompt := '—';
end;



procedure TFormDeviceEditor.UpdateUIFromDevice;
var
  AccErr: Double;
  Idx: Integer;
begin
  FLoading := True;
  try
    RefreshDeviceTypeReference;

    // =====================================================
    // == Основные текстовые поля
    // =====================================================
    EditName.Text          := FDevice.Name;

    EditTypeName.Text  :=     FDevice.DeviceTypeName;

    EditModification.Text := FDevice.Modification;
    edtSerialNumber.Text  := FDevice.SerialNumber;
    edtReestrNumber.Text  := FDevice.ReestrNumber;

    // =====================================================
    // == Изготовитель
    // =====================================================
    edtManufacturer.Text := Trim(FDevice.Manufacturer);
    if edtManufacturer.Text <> '' then
    begin
      edtManufacturer.TextPrompt := '';
      edtManufacturer.Hint := edtManufacturer.Text;
    end
    else
    begin
      edtManufacturer.TextPrompt := 'Изготовитель';
      edtManufacturer.Hint := '';
    end;

    // =====================================================
    // == Владелец
    // =====================================================
    edtOwner.Text := Trim(FDevice.Owner);
    if edtOwner.Text <> '' then
      edtOwner.Hint := edtOwner.Text
    else
      edtOwner.Hint := '';

      mmoComment.Text := FDevice.Description;

    // =====================================================
    // == Даты
    // =====================================================
    if FDevice.RegDate > 0 then
      EditRegDate.Text := DateToStr(FDevice.RegDate)
    else
      EditRegDate.Text := '';

    if FDevice.ValidityDate > 0 then
      EditValidityDate.Text := DateToStr(FDevice.ValidityDate)
    else
      EditValidityDate.Text := '';

    if FDevice.DateOfManufacture > 0 then
      dedtDateOfManufacture.Date := FDevice.DateOfManufacture
    else
      dedtDateOfManufacture.Text := '';

    // =====================================================
    // == Числовые поля
    // =====================================================
    EditIVI.Text            := FDevice.IVI.ToString;
    EditAccuracyClass.Text := FDevice.AccuracyClass;

    // =====================================================
    // == Категория СИ
    // =====================================================
    InitCategoryComboEdit;

    cbProcedure.Text        := FDevice.ProcedureName;
    edtDocumentation.Text  := FDevice.VerificationMethod;
    EditReportingForm.Text := FDevice.ReportingForm;

    // =====================================================
    // == Тип испытания / критерий остановки
    // =====================================================
    if (FDevice.SpillageType >= 0) and (FDevice.SpillageType < cbSpillageType.Items.Count) then
      cbSpillageType.ItemIndex := FDevice.SpillageType
    else
      cbSpillageType.ItemIndex := 0;

    if (FDevice.SpillageStop >= 0) and (FDevice.SpillageStop < cbSpillageStop.Items.Count) then
      cbSpillageStop.ItemIndex := FDevice.SpillageStop
    else
      cbSpillageStop.ItemIndex := 0;

    // =====================================================
    // == Повторы
    // =====================================================
    if FDevice.Repeats > 0 then
      sbRepeats.Value := FDevice.Repeats
    else
      sbRepeats.Value := 1;

    // =====================================================
    // == Базовая погрешность
    // =====================================================
    EditError.Text := '';
    EditError.TextPrompt := '—';

    if FDevice.Error > 0 then
      EditError.Text := FormatPercentPM(FDevice.Error)
    else
    begin
      AccErr := ExtractFirstFloat(FDevice.AccuracyClass);
      if AccErr > 0 then
        EditError.TextPrompt := FormatPercentPM(AccErr);
    end;

    // =====================================================
    // == Измеряемая величина
    // =====================================================
    if (FDevice.MeasuredDimension >= 0) and
       (FDevice.MeasuredDimension < cbMeasuredDimension.Items.Count) then
      cbMeasuredDimension.ItemIndex := FDevice.MeasuredDimension
    else
      cbMeasuredDimension.ItemIndex := 0;

    // =====================================================
    // == Тип сигнала
    // =====================================================
    if (FDevice.OutputType >= 0) and
       (FDevice.OutputType < ComboBoxOutputType.Items.Count) then
      ComboBoxOutputType.ItemIndex := FDevice.OutputType
    else
      ComboBoxOutputType.ItemIndex := 0;
    ComboBoxOutputType.Hint := ComboBoxOutputType.Text;

    // =====================================================
    // == Тип выхода (OutputSet)
    // =====================================================
    if (FDevice.OutputSet >= 0) and
       (FDevice.OutputSet < cbOutPutType.Items.Count) then
    begin
      cbOutPutType.ItemIndex  := FDevice.OutputSet;
      cbOutPutType2.ItemIndex := FDevice.OutputSet;
    end
    else
    begin
      cbOutPutType.ItemIndex  := -1;
      cbOutPutType2.ItemIndex := -1;
    end;

    // =====================================================
    // == Представление коэффициента
    // =====================================================
    if (FDevice.DimensionCoef >= 0) and
       (FDevice.DimensionCoef < cbCoefViewType.Items.Count) then
      cbCoefViewType.ItemIndex := FDevice.DimensionCoef
    else
      cbCoefViewType.ItemIndex := -1;

    // =====================================================
    // == Коэффициент
    // =====================================================
    if FDevice.Coef > 0 then
      EditCoef.Text := FloatToStr(FDevice.Coef)
    else
      EditCoef.Text := '';

    // =====================================================
    // == Частота
    // =====================================================
    if FDevice.Freq > 0 then
      EditFreq.Text := IntToStr(FDevice.Freq)
    else
      EditFreq.Text := '';

    // =====================================================
    // == Отношение расхода к частоте
    // =====================================================
    if FDevice.FreqFlowRate > 0 then
      EditFreqFlowRate.Text := FloatToStr(FDevice.FreqFlowRate)
    else
      EditFreqFlowRate.Text := '';

    // =====================================================
    // == Интерфейс / библиотека
    // =====================================================
    Idx := cbLibrares.Items.IndexOf(FDevice.ProtocolName);
    if Idx >= 0 then
      cbLibrares.ItemIndex := Idx
    else
      cbLibrares.ItemIndex := -1;

    // =====================================================
    // == Скорость передачи
    // =====================================================
    case FDevice.BaudRate of
      2400:   cbBaudRate.ItemIndex := 0;
      4800:   cbBaudRate.ItemIndex := 1;
      9600:   cbBaudRate.ItemIndex := 2;
      19200:  cbBaudRate.ItemIndex := 3;
      115200: cbBaudRate.ItemIndex := 4;
    else
      cbBaudRate.ItemIndex := -1;
    end;

    // =====================================================
    // == Четность
    // =====================================================
    if (FDevice.Parity >= 0) and (FDevice.Parity < cbParity.Items.Count) then
      cbParity.ItemIndex := FDevice.Parity
    else
      cbParity.ItemIndex := 0;

    // =====================================================
    // == Адрес прибора
    // =====================================================
    if FDevice.DeviceAddress >= 0 then
      edtAddr.Text := IntToStr(FDevice.DeviceAddress)
    else
      edtAddr.Text := '';

    // =====================================================
    // == Визуальный ввод
    // =====================================================
    if (FDevice.InputType >= 0) and (FDevice.InputType < cbInputType.Items.Count) then
      cbInputType.ItemIndex := FDevice.InputType
    else
      cbInputType.ItemIndex := 0;

    // =====================================================
    // == Комментарий
    // =====================================================
    mmoComment.Text := FDevice.Comment;

    UpdateQmaxQmin;


 // =====================================================
// == Диаметр (DN)
// =====================================================
ComboEditDN.Text := '';
ComboEditDN.Hint := '';

if FDeviceType <> nil then
begin
  // Если у нас есть ассоциированный тип, заполняем диаметр
  ComboEditDN.Items.BeginUpdate;
  try
    ComboEditDN.Items.Clear;

    // Заполняем ComboBox диаметрами типа
    if FDeviceType.Diameters <> nil then
      for var D in FDeviceType.Diameters do
        if (D <> nil) and (D.State <> osDeleted) then
          ComboEditDN.Items.Add(D.Name);

  finally
    ComboEditDN.Items.EndUpdate;
  end;

  // Выбираем текущий диаметр, если он задан в FDevice.DN
  if FDevice.DN <> '' then
  begin
    Idx := ComboEditDN.Items.IndexOf(FDevice.DN);
    if Idx >= 0 then
    begin
      ComboEditDN.ItemIndex := Idx;
      ComboEditDN.Text := ComboEditDN.Items[Idx];
    end
    else
    begin
      // Если диаметра нет в списке, то оставляем текст как есть
      ComboEditDN.ItemIndex := -1;
      ComboEditDN.Text := FDevice.DN;
    end;
  end
  else
  begin
    ComboEditDN.ItemIndex := -1;
    ComboEditDN.Text := '';  // если DN пустое, ComboBox тоже пустой
  end;

  ComboEditDN.Hint := ComboEditDN.Text;
end
else
begin
  // Если типа нет, выводим DN из устройства
  ComboEditDN.ItemIndex := -1;
  ComboEditDN.Text := FDevice.DN;  // показываем текущее значение DN
  ComboEditDN.Hint := FDevice.DN;
end;


    // =====================================================
    // == Точки прибора
    // =====================================================
    UpdatePointsGrid;

        finally
        FLoading := False;
    end;
  end;

procedure TFormDeviceEditor.cbCoefViewTypeChange(Sender: TObject);
var
  ViewType: Integer;
  DisplayCoef: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  ViewType := cbCoefViewType.ItemIndex;
  if ViewType < 0 then
    Exit;

  { сохраняем тип представления }
  FDevice.DimensionCoef := ViewType;

  { базовый коэффициент всегда хранится как имп/л (имп/кг) }
  if FDevice.Coef <= 0 then
  begin
    EditCoef.Text := '';
    Exit;
  end;

  case ViewType of
    0: // имп/л (имп/кг)
      DisplayCoef := FDevice.Coef;

    1: // л/имп (кг/имп)
      DisplayCoef := 1 / FDevice.Coef;
  else
    DisplayCoef := FDevice.Coef;
  end;

  { отображаем }
  EditCoef.Text := FormatFloat('0.########', DisplayCoef);

  SetModified;
end;


procedure TFormDeviceEditor.cbCurrentRangeChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  if cbCurrentRange.ItemIndex < 0 then
    Exit;

  { сохраняем диапазон }
  FDevice.CurrentRange := cbCurrentRange.ItemIndex;

  { при необходимости — пересчёт параметров прибора }
//  RecalcDeviceBySignalSettings; // если метод есть

  SetModified;
end;


procedure TFormDeviceEditor.cbMeasuredDimensionChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  V := cbMeasuredDimension.ItemIndex;
  if V < 0 then
    Exit;

  { сохраняем в модель }
  FDevice.MeasuredDimension := V;

  { применяем логику для выбранной величины }
  ApplyMeasuredDimension;

  SetModified;
end;

procedure TFormDeviceEditor.cbOutPutType2Change(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  V := cbOutPutType2.ItemIndex;
  if V < 0 then
    Exit;

  { сохраняем в модель }
  FDevice.OutputSet := V;

  SetModified;
end;

procedure TFormDeviceEditor.cbOutPutTypeChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  V := cbOutPutType.ItemIndex;
  if V < 0 then
    Exit;

  { сохраняем в модель }
  FDevice.OutputSet := V;

  SetModified;
end;



procedure TFormDeviceEditor.cbVoltageRangeChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  if cbVoltageRange.ItemIndex < 0 then
    Exit;

  { сохраняем диапазон }
  FDevice.VoltageRange := cbVoltageRange.ItemIndex;

  { пересчитываем параметры прибора при необходимости }
// RecalcDeviceBySignalSettings; // ←

  SetModified;
end;


procedure TFormDeviceEditor.ceCategoryChange(Sender: TObject);
var
  CatID: Integer;
  C: TDeviceCategory;
  Idx: Integer;
begin
  if FLoading or (FDevice = nil) then
    Exit;

  Idx := ceCategory.ItemIndex;

  if (Idx >= 0) and (Idx < ceCategory.Items.Count) then
  begin
    CatID := Integer(ceCategory.Items.Objects[Idx]);

    FDevice.Category := CatID;
    FDevice.CategoryName := '';

    C := DataManager.FindCategoryByID(CatID);
    if C <> nil then
    begin
      if FDevice.MeasuredDimension <> Ord(C.MeasuredDimension) then
        FDevice.MeasuredDimension := Ord(C.MeasuredDimension);

      if FDevice.OutputType <> Ord(C.DefaultOutputType) then
      begin
        FDevice.OutputType := Ord(C.DefaultOutputType);
        cbOutputType.ItemIndex := FDevice.OutputType;
      end;
    end;

    // 🔒 после выбора запрещаем редактирование
    FBlockCategoryEdit := True;
  end
  else
  begin
    FDevice.Category := -1;
    FDevice.CategoryName := Trim(ceCategory.Text);
  end;

  ceCategory.Hint := ceCategory.Text;
  SetModified;

end;

procedure TFormDeviceEditor.ComboBoxOutputTypeChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  V := ComboBoxOutputType.ItemIndex;
  if V < 0 then
    Exit;

  { сохраняем в модель }
  FDevice.OutputType := V;

  { применяем настройки UI под тип сигнала }
  ApplyOutputType;

  SetModified;
end;

procedure TFormDeviceEditor.ComboEditDNChange(Sender: TObject);
var
  NewDN: string;
  D: TDiameter;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  NewDN := Trim(ComboEditDN.Text);
  if NewDN = '' then
    Exit;

  RefreshDeviceTypeReference;

  {----------------------------------}
  { Если тип НЕ привязан }
  {----------------------------------}
  if FDeviceType = nil then
  begin
    FDevice.DN := NewDN;
    Exit;
  end;

  {----------------------------------}
  { Тип привязан — ищем диаметр }
  {----------------------------------}
  D := FDeviceType.FindDiameterByDN(NewDN);   // ← существующая функция

  if D = nil then
  begin
    { Диаметр в типе не найден }
    FDevice.DN := NewDN;
    Exit;
  end;

  {----------------------------------}
  { Перенос данных диаметра в прибор }
  {----------------------------------}
  FDevice.DN := D.Name;

  FDevice.Qmax := D.Qmax;
  FDevice.Qmin := D.Qmin;

  if D.Qmin > 0 then
    FDevice.RangeDynamic := D.Qmax / D.Qmin;

  FDevice.Coef := D.Kp;

  {----------------------------------}
  { Пересчёт точек прибора }
  {----------------------------------}
  RecalcDevicePointsCoef;

  {----------------------------------}
  { Обновление UI }
  {----------------------------------}
  UpdateUIFromDevice;
end;

procedure TFormDeviceEditor.dedtDateOfManufactureChange(Sender: TObject);
var
  D: TDateTime;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  // ----------------------------------------
  // Пустое значение
  // ----------------------------------------
  if dedtDateOfManufacture.Text = '' then
  begin
    if FDevice.DateOfManufacture <> 0 then
    begin
      FDevice.DateOfManufacture := 0;
      SetModified;
    end;
    Exit;
  end;

  // ----------------------------------------
  // Корректная дата
  // ----------------------------------------
  D := dedtDateOfManufacture.Date;

  if SameValue(FDevice.DateOfManufacture, D) then
    Exit;

  FDevice.DateOfManufacture := D;

  SetModified;
end;

procedure TFormDeviceEditor.EditAccuracyClassExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(EditAccuracyClass.Text);

  { сохраняем в модель }
  FDevice.AccuracyClass := S;
  EditAccuracyClass.Text := S;

  { prompt, если пусто }
  if S = '' then
    EditAccuracyClass.TextPrompt := 'Класс точности'
  else
    EditAccuracyClass.TextPrompt := '';

  SetModified;
end;

procedure TFormDeviceEditor.EditCoefExit(Sender: TObject);
var
  InputValue: Double;
  NewBaseCoef: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  // 1. Безопасный ввод
  InputValue := NormalizeFloatInput(EditCoef.Text);

  // 2. Защита от мусора и нуля
  if InputValue <= 0 then
  begin
    EditCoef.Text := FormatFloat('0.########', GetDisplayedCoef);
    Exit;
  end;

  // 3. Приводим введённое значение к базовому виду (имп/л или имп/кг)
  case FDevice.DimensionCoef of
    0: NewBaseCoef := InputValue;        // имп/л (имп/кг)
    1: NewBaseCoef := 1 / InputValue;    // л/имп (кг/имп) → имп/л
  else
    NewBaseCoef := InputValue;
  end;

  // 4. Если базовый коэффициент не изменился — выходим
  if SameValue(FDevice.Coef, NewBaseCoef, 1e-12) then
    Exit;

  // 5. Сохраняем базовый коэффициент
  FDevice.Coef := NewBaseCoef;

  // 6. Пересчёт точек прибора
  RecalcDevicePointsCoef;   // ← аналог RecalcDiametersKp + RecalcPointsBySelectedDiameter

  // 7. Обновление таблицы точек
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormDeviceEditor.RecalcDevicePointsCoef;
var
  I: Integer;
  P: TDevicePoint;
  Q, V, Tm, Coef: Double;
begin
  if (FDevice = nil) or (FDevice.Points = nil) then
    Exit;

  // -----------------------------------------------------
  // Базовый коэффициент прибора (имп/л или имп/кг)
  // -----------------------------------------------------
  Coef := FDevice.Coef;
  if Coef <= 0 then
    Exit;

  // -----------------------------------------------------
  // Пересчёт всех точек прибора
  // -----------------------------------------------------
  for I := 0 to FDevice.Points.Count - 1 do
  begin
    P := FDevice.Points[I];

    // Абсолютный расход точки
    // FlowRate у DevicePoint — абсолютный (м³/ч или т/ч)
    Q := P.FlowRate;

    // Если задано время
    if (Q > 0) and (P.LimitTime > 0) then
    begin
      Tm := P.LimitTime;

      // Объём / масса:
      // Q [м³/ч] * T [с] / 3600
      V := Q * Tm / 3.6;

      P.LimitVolume := V;
      P.LimitImp    := Round(V * Coef);
    end;
  end;

  // -----------------------------------------------------
  // Обновляем таблицу точек
  // -----------------------------------------------------
  GridPoints.Repaint;
end;


procedure TFormDeviceEditor.EditErrorExit(Sender: TObject);
var
  Err: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  Err := NormalizeFloatInput(EditError.Text);

  if Err <= 0 then
  begin
    FDevice.Error := 0;
    EditError.Text := '';
    EditError.TextPrompt := '—';
  end
  else
  begin
    FDevice.Error := Err;
    EditError.Text := FormatPercentPM(Err);
    EditError.TextPrompt := '';
  end;

  { 🔴 КЛЮЧЕВОЕ МЕСТО }
  { обновляем погрешность в точках прибора }
  //UpdateDevicePointsError;     // ← аналог UpdatePointsErrorFromType
  UpdatePointsGrid;            // ← обновление таблицы точек прибора
  UpdateQmaxQmin;

  SetModified;
end;

procedure TFormDeviceEditor.EditFreqExit(Sender: TObject);
var
  NewFreq: Integer;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  // ----------------------------------------
  // Безопасный ввод (частота — целое)
  // ----------------------------------------
  NewFreq := Trunc(NormalizeFloatInput(EditFreq.Text));

  // ----------------------------------------
  // Защита от мусора
  // ----------------------------------------
  if NewFreq <= 0 then
  begin
    EditFreq.Text := IntToStr(FDevice.Freq);
    Exit;
  end;

  // ----------------------------------------
  // Нет изменений
  // ----------------------------------------
  if FDevice.Freq = NewFreq then
    Exit;

  // ----------------------------------------
  // Сохраняем в прибор
  // ----------------------------------------
  FDevice.Freq := NewFreq;

  // ----------------------------------------
  // Обновляем точки прибора (если частота влияет)
  // ----------------------------------------
  //RecalcDeviceBySignalSettings; // если есть / нужен

  SetModified;
end;

procedure TFormDeviceEditor.EditFreqFlowRateExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  // ----------------------------------------
  // Безопасный ввод
  // ----------------------------------------
  NewRate := NormalizeFloatInput(EditFreqFlowRate.Text);

  if NewRate <= 0 then
  begin
    EditFreqFlowRate.Text := FloatToStr(FDevice.FreqFlowRate);
    Exit;
  end;

  // ----------------------------------------
  // Нет изменений
  // ----------------------------------------
  if SameValue(FDevice.FreqFlowRate, NewRate) then
    Exit;

  // ----------------------------------------
  // Сохраняем в прибор
  // ----------------------------------------
  FDevice.FreqFlowRate := NewRate;

  // ----------------------------------------
  // Пересчёт параметров прибора
  // (частота → расход в точках)
  // ----------------------------------------
  //RecalcDevicePointsFreqFlow; // ← аналог QF = Qmax * FreqFlowRate

  // ----------------------------------------
  // Обновление таблицы точек
  // ----------------------------------------
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormDeviceEditor.EditModificationExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(EditModification.Text);

  { сохраняем в модель }
  FDevice.Modification := S;
  EditModification.Text := S;

  { prompt, если пусто }
  if S = '' then
    EditModification.TextPrompt := 'Модификация'
  else
    EditModification.TextPrompt := '';

  SetModified;
end;

procedure TFormDeviceEditor.EditNameExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(EditName.Text);

  { сохраняем в модель }
  FDevice.Name := S;
  EditName.Text := S;

  { prompt, если пусто }
  if S = '' then
    EditName.TextPrompt := 'Наименование прибора'
  else
    EditName.TextPrompt := '';

  SetModified;
end;


procedure TFormDeviceEditor.EditNameTyping(Sender: TObject);
var
  E: TEdit;
begin
  if FLoading then
    Exit;

  E := Sender as TEdit;

  { убираем двойные пробелы }
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;


procedure TFormDeviceEditor.EditReportingFormExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(EditReportingForm.Text);

  { сохраняем в модель }
  FDevice.ReportingForm := S;
  EditReportingForm.Text := S;

  { prompt, если пусто }
  if S = '' then
    EditReportingForm.TextPrompt := 'Отчетная форма'
  else
    EditReportingForm.TextPrompt := '';

  SetModified;
end;


procedure TFormDeviceEditor.EditTypeNameExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(EditTypeName.Text);

  { сохраняем в модель }
  FDevice.DeviceTypeName := S;
  EditTypeName.Text := S;

  { prompt, если пусто }
  if S = '' then
    EditTypeName.TextPrompt := 'Тип прибора'
  else
    EditTypeName.TextPrompt := '';

  SetModified;
end;


procedure TFormDeviceEditor.EditVoltageQmaxExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  NewRate := NormalizeFloatInput(EditVoltageQmax.Text);

  { допустимы только доли 0..1 }
  if (NewRate <= 0) or (NewRate > 1) then
  begin
    EditVoltageQmax.Text := FloatToStr(FDevice.VoltageQmaxRate);
    Exit;
  end;

  if SameValue(FDevice.VoltageQmaxRate, NewRate) then
    Exit;

  FDevice.VoltageQmaxRate := NewRate;

  SetModified;
end;

procedure TFormDeviceEditor.EditVoltageQminExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  NewRate := NormalizeFloatInput(EditVoltageQmin.Text);

  { допустимы только доли 0..1 }
  if (NewRate <= 0) or (NewRate >= 1) then
  begin
    EditVoltageQmin.Text := FloatToStr(FDevice.VoltageQminRate);
    Exit;
  end;

  if SameValue(FDevice.VoltageQminRate, NewRate) then
    Exit;

  FDevice.VoltageQminRate := NewRate;

  SetModified;
end;



procedure TFormDeviceEditor.edtDocumentationExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(edtDocumentation.Text);

  { сохраняем в модель }
  FDevice.Documentation := S;
  edtDocumentation.Text := S;

  { prompt, если пусто }
  if S = '' then
    edtDocumentation.TextPrompt := 'Методика поверки'
  else
    edtDocumentation.TextPrompt := '';

  SetModified;
end;


procedure TFormDeviceEditor.edtManufacturerExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(edtManufacturer.Text);

  { сохраняем в модель }
  FDevice.Manufacturer := S;
  edtManufacturer.Text := S;

  { prompt и hint }
  if S <> '' then
  begin
    edtManufacturer.TextPrompt := '';
    edtManufacturer.Hint := S;
  end
  else
  begin
    edtManufacturer.TextPrompt := 'Изготовитель';
    edtManufacturer.Hint := '';
  end;

  SetModified;
end;

procedure TFormDeviceEditor.edtOwnerExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(edtOwner.Text);

  { сохраняем в модель }
  FDevice.Owner := S;
  edtOwner.Text := S;

  { prompt и hint }
  if S <> '' then
  begin
    edtOwner.TextPrompt := '';
    edtOwner.Hint := S;
  end
  else
  begin
    edtOwner.TextPrompt := 'Владелец';
    edtOwner.Hint := '';
  end;

  SetModified;
end;


procedure TFormDeviceEditor.edtReestrNumberExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(edtReestrNumber.Text);

  { сохраняем в модель }
  FDevice.ReestrNumber := S;
  edtReestrNumber.Text := S;

  { prompt, если пусто }
  if S = '' then
    edtReestrNumber.TextPrompt := 'ГРСИ'
  else
    edtReestrNumber.TextPrompt := '';

  SetModified;
end;

procedure TFormDeviceEditor.edtReestrNumberTyping(Sender: TObject);
var
  E: TEdit;
begin
  if FLoading then
    Exit;

  E := Sender as TEdit;

  { убираем двойные пробелы }
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;

procedure TFormDeviceEditor.edtSerialNumberExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  S := Trim(edtSerialNumber.Text);

  { сохраняем в модель }
  FDevice.SerialNumber := S;
  edtSerialNumber.Text := S;

  { prompt и hint }
  if S <> '' then
  begin
    edtSerialNumber.TextPrompt := '';
    edtSerialNumber.Hint := S;
  end
  else
  begin
    edtSerialNumber.TextPrompt := 'Заводской номер';
    edtSerialNumber.Hint := '';
  end;

  SetModified;
end;

function TFormDeviceEditor.GetPointByVisibleRow(ARow: Integer): TDevicePoint;
var
  i, VisibleIndex: Integer;
begin
  Result := nil;

  if (FDevice = nil) or (ARow < 0) then
    Exit;

  VisibleIndex := -1;

  for i := 0 to FDevice.Points.Count - 1 do
  begin
    if FDevice.Points[i].State <> osDeleted then
    begin
      Inc(VisibleIndex);

      if VisibleIndex = ARow then
      begin
        Result := FDevice.Points[i];
        Exit;
      end;
    end;
  end;
end;


procedure TFormDeviceEditor.edtSerialNumberTyping(Sender: TObject);
var
  E: TEdit;
begin
  if FLoading then
    Exit;

  E := Sender as TEdit;

  { убираем двойные пробелы }
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;
procedure TFormDeviceEditor.GridPointsGetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  var Value: TValue
);
var
  P: TDevicePoint;
  Qmax, Q: Double;
begin
  {-----------------------------------------------------}
  { Защита }
  {-----------------------------------------------------}
  if (FDevice = nil) then
    Exit;

  P := GetPointByVisibleRow(ARow);   // ← ВАЖНО
  if P = nil then
    Exit;

  {=====================================================}
  { НЕ зависят от прибора }
  {=====================================================}

  if ACol = StringColumnPointName.Index then
    Value := P.Name

  else if ACol = StringColumnPointFlowRate.Index then
    Value := FormatFloatN(P.FlowRate, 3)

  else if ACol = StringColumnPointFlowError.Index then
    Value := FormatAccuracy(P.FlowAccuracy)

  else if ACol = StringColumnPointPres.Index then
    Value := FormatPhys(P.Pressure)

  else if ACol = StringColumnPontTemp.Index then
    Value := FormatPhys(P.Temp)

  else if ACol = StringColumnPointTempError.Index then
  begin
    if (P.Temp = 0) or (P.TempAccuracy = '') or (P.TempAccuracy = '—') then
      Value := '—'
    else
      Value := FormatAccuracy(P.TempAccuracy);
  end

  else if ACol = StringColumnPointError.Index then
    Value := FormatDeviceError(P.Error)

  {=====================================================}
  { INTEGER-КОЛОНКИ }
  {=====================================================}

  else if ACol = IntegerColumnPointRepeatsForm.Index then
  begin
    if P.RepeatsProtocol > 0 then
      Value := P.RepeatsProtocol
    else
      Value := 1;
  end

  else if ACol = StringColumnHash.Index then
  begin

      Value := P.MitUUID;

  end

  else if ACol = IntegerColumnPointRepeats.Index then
  begin
    if P.Repeats > 0 then
      Value := P.Repeats
    else
      Value := 1;
  end

  else if ACol = StringColumnPointStab.Index then
    Value := P.Pause

  {=====================================================}
  { ВСЕГДА отображаются }
  {=====================================================}

  else if ACol = StringColumnPointImp.Index then
  begin
    if P.LimitImp = 0 then
      Value := '—'
    else
      Value := IntToStr(P.LimitImp);
  end

  else if ACol = StringColumnPointTime.Index then
    Value := FormatTime(P.LimitTime)

  {=====================================================}
  { ЗАВИСЯТ ОТ ПРИБОРА: Q и V }
  {=====================================================}

  else if (ACol = StringColumnPointQ.Index) or
          (ACol = StringColumnPointVolume.Index) then
  begin
    if (FDevice.Qmax <= 0) then
    begin
      Value := '—';
      Exit;
    end;

    Qmax := FDevice.Qmax;
    Q := P.FlowRate * Qmax;

    {---------------------------}
    { Q }
    {---------------------------}
    if ACol = StringColumnPointQ.Index then
    begin
      if Q <= 0 then
        Value := '—'
      else
        Value := FormatQorV(Q, P.Error);
    end

    {---------------------------}
    { V }
    {---------------------------}
    else
    begin
      if P.LimitVolume > 0 then
        Value := FormatQorV(P.LimitVolume, P.Error)

      else if (Q > 0) and (P.LimitTime > 0) then
        Value := FormatQorV(Q * P.LimitTime / 3.6, P.Error)

      else
        Value := '—';
    end;
  end;
end;
procedure TFormDeviceEditor.InitCategoryComboEdit;
var
  C: TDeviceCategory;
  TextValue: string;
begin
  if (DataManager.ActiveDeviceRepo = nil) or (FDevice = nil) then
    Exit;

  {----------------------------------}
  { Заполняем список категорий }
  {----------------------------------}
  ceCategory.Items.BeginUpdate;
  try
    ceCategory.Items.Clear;

    for C in DataManager.Categories do
    begin
      // ⛔ пропускаем служебную категорию
      if C.ID = -1 then
        Continue;

      // ✅ сохраняем ID в Objects
      ceCategory.Items.AddObject(C.Name, TObject(C.ID));
    end;
  finally
    ceCategory.Items.EndUpdate;
  end;

  {----------------------------------}
  { Определяем отображаемый текст }
  {----------------------------------}
  if FDevice.Category > 0 then
    TextValue :=
      DataManager.ActiveTypeRepo.CategoryToText(
        FDevice.Category,
        FDevice.CategoryName
      )
  else if FDevice.Category = -1 then
    TextValue := FDevice.CategoryName
  else
    TextValue := '';

  ceCategory.Text := TextValue;
  ceCategory.Hint := TextValue;
end;

procedure TFormDeviceEditor.UpdatePointsGrid;
var
  i, VisibleCount: Integer;
begin
  if FDevice = nil then
    Exit;

  GridPoints.BeginUpdate;
  try
    VisibleCount := 0;

    for i := 0 to FDevice.Points.Count - 1 do
      if FDevice.Points[i].State <> osDeleted then
        Inc(VisibleCount);

    GridPoints.RowCount := VisibleCount;

    { корректировка текущей строки }
    if GridPoints.Row >= GridPoints.RowCount then
      GridPoints.Row := GridPoints.RowCount - 1;

    if GridPoints.RowCount = 0 then
      GridPoints.Row := -1;

  finally
    GridPoints.EndUpdate;
  end;
end;

procedure TFormDeviceEditor.SetModified;
begin
  if FLoading then
    Exit;

  if FDevice = nil then
    Exit;

  if FDevice.State = osClean then
    FDevice.State := osModified;
end;

procedure TFormDeviceEditor.CloseEditor(ASave: Boolean);
begin
  try
    if ASave then
    begin
      {----------------------------------}
      { Сохранение }
      {----------------------------------}

      if FOriginalDevice <> nil then
      begin
        { редактирование существующего }
        FOriginalDevice.Assign(FDevice);
        DataManager.ActiveDeviceRepo.SaveDevice(FOriginalDevice);
      end
      else
      begin
        { новый прибор }
        DataManager.ActiveDeviceRepo.SaveDevice(FDevice);
      end;

      ModalResult := mrOk;
    end
    else
    begin
      {----------------------------------}
      { Отмена }
      {----------------------------------}
      ModalResult := mrCancel;
    end;

  except
    on E: Exception do
    begin
      ShowMessage('Ошибка сохранения: ' + E.Message);
      Exit;  // НЕ закрываем форму
    end;
  end;

  Close;
end;



end.
