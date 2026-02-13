unit fuDeviceSelect;

interface

uses
  UnitClasses, UnitDeviceClass, UnitRepositories,
  UnitBaseProcedures,
  UnitDataManager,

  fuDeviceEdit,

  System.NetEncoding,
  fuTypeEditor,
  System.StrUtils,
  System.DateUtils,
  System.JSON,
  System.Generics.Defaults,
    System.Generics.Collections,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, FMX.Grid.Style, FMX.StdCtrls, FMX.Menus, FMX.Edit, FMX.Grid,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.TreeView, FMX.Layouts,
  FMX.ListView, System.Actions, FMX.ActnList, FMX.ListBox, FMX.DateTimeCtrls,
  FMX.Objects, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.Memo.Types, FMX.Memo;

type
  TFormDeviceSelect = class(TForm)
    ActionList1: TActionList;
    aCreateType: TAction;
    aEditType: TAction;
    aDeleteType: TAction;
    LayoutLeft: TLayout;
    lvFlowmeterTypes: TListView;
    TreeViewDevices: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    ToolBar2: TToolBar;
    ComboBoxRepository: TComboBox;
    Label2: TLabel;
    LayoutRight: TLayout;
    Layout4: TLayout;
    GridDevices: TGrid;
    StringColumnName: TStringColumn;
    StringColumnManufacturer: TStringColumn;
    StringColumnCategory: TStringColumn;
    StringColumnModification: TStringColumn;
    StringColumnAccuracyClass: TStringColumn;
    StringColumnReestrNumber: TStringColumn;
    StringColumnRegDate: TStringColumn;
    StringColumnValidityDate: TStringColumn;
    StringColumnProcedure: TStringColumn;
    StringColumnVerificationMethod: TStringColumn;
    StringColumnIVI: TStringColumn;
    ToolBar1: TToolBar;
    Line6: TLine;
    Layout32: TLayout;
    ButtonDeviceDelete: TButton;
    ButtonDeviceAdd: TButton;
    ButtonDeviceClear: TButton;
    Layout2: TLayout;
    sbClear: TSpeedButton;
    sbFind: TSpeedButton;
    EditFindDevice: TEdit;
    SpeedButtonFindInternet: TSpeedButton;
    Layout3: TLayout;
    Label1: TLabel;
    DateEditFilter: TDateEdit;
    Line1: TLine;
    MemoLog: TMemo;
    lyt1: TLayout;
    btnOK: TCornerButton;
    CornerButton1: TCornerButton;
    CornerButtonEditDevice: TCornerButton;
    MainMenu: TMenuBar;
    miFile: TMenuItem;
    miCreate: TMenuItem;
    miEdit: TMenuItem;
    miDelete: TMenuItem;
    miSave: TMenuItem;
    miService: TMenuItem;
    miRefreshRepository: TMenuItem;
    miAddRepository: TMenuItem;
    miDeleteRepository: TMenuItem;
    miLoadRepository: TMenuItem;
    NetHTTPClient1: TNetHTTPClient;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu2: TPopupMenu;
    mpExpandAll: TMenuItem;
    mpCollapseAll: TMenuItem;
    mpRefresh: TMenuItem;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    sbDetaled: TLabel;
    StringColumnSerial: TStringColumn;
    StringColumnOwner: TStringColumn;
    StringColumnDateOfManufacture: TStringColumn;
    miAddTestData: TMenuItem;
    miLoad: TMenuItem;
    procedure ButtonDeviceAddClick(Sender: TObject);
    procedure ButtonDeviceDeleteClick(Sender: TObject);
    procedure ButtonDeviceClearClick(Sender: TObject);
    procedure EditFindDeviceExit(Sender: TObject);
    procedure sbClearClick(Sender: TObject);
    procedure DateEditFilterChange(Sender: TObject);
    procedure ComboBoxRepositoryChange(Sender: TObject);
    procedure TreeViewDevicesChange(Sender: TObject);
    procedure sbFindClick(Sender: TObject);
    procedure GridDevicesGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure miAddRepositoryClick(Sender: TObject);
    procedure miDeleteRepositoryClick(Sender: TObject);
    procedure miLoadRepositoryClick(Sender: TObject);
    procedure miRefreshRepositoryClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CornerButtonEditDeviceClick(Sender: TObject);
    procedure miAddTestDataClick(Sender: TObject);
    procedure miLoadClick(Sender: TObject);

private

  { ================= НОВАЯ АРХИТЕКТУРА ================= }

  FDevices: TObjectList<TDevice>;                // все приборы из репозитория

  FDevFilteredByTree: TObjectList<TDevice>;      // фильтр по дереву
  FDevFilteredByText: TObjectList<TDevice>;      // фильтр по поиску
  FDevFilteredByDate: TObjectList<TDevice>;      // фильтр по датам

  FDevFilteredDevices: TObjectList<TDevice>;     // РЕЗУЛЬТАТ ФИЛЬТРАЦИИ

  ActiveRepo: TDeviceRepository;                 // активный репозиторий приборов

  { ================= СОРТИРОВКА ================= }

  FSortColumn: Integer;
  FSortAscending: Boolean;

  { ================= ОСНОВНЫЕ ПРОЦЕДУРЫ ================= }

  procedure LoadData;                            // загрузка приборов из репозитория
  procedure BuildTree;                           // построение дерева (категории / типы / владельцы)
  procedure UpdateGridDevices;                   // обновление таблицы приборов
  procedure OpenDeviceEditor(ADevice: TDevice);  // открытие редактора прибора

  { ================= ФИЛЬТРЫ ================= }

  function HasActiveFilters: Boolean;
  procedure ApplyFilter;                         // применение всех фильтров

  function BuildFilteredByTree(
    const Source: TObjectList<TDevice>
  ): TObjectList<TDevice>;

  function PassTreeFilter(const ADevice: TDevice): Boolean;
  function BuildSearchURL(const ASearch: string): string;

  { ================= СОРТИРОВКА ================= }

  function ColumnToSortField(
    ACol: Integer
  ): TDeviceSortField;

  procedure ResetSorting;

  { ================= РЕПОЗИТОРИИ ================= }

  procedure FillComboBoxRepository;              // список репозиториев приборов
  function UpdateConnection: Boolean;             // смена активного репозитория
  procedure ClearTreeAndGrid;                     // очистка UI при смене репозитория

public
  { Public declarations }

  end;

var
  FormDeviceSelect: TFormDeviceSelect;

implementation

{$R *.fmx}
procedure TFormDeviceSelect.LoadData;
begin
  {--------------------------------------------------}
  { Проверяем наличие активного репозитория приборов }
  {--------------------------------------------------}
  if (DataManager = nil) or (DataManager.ActiveDeviceRepo = nil) then
  begin
    ActiveRepo := nil;
    FDevices := nil;
    Exit;
  end;

  ActiveRepo := DataManager.ActiveDeviceRepo;

  {--------------------------------------------------}
  { Загружаем данные из БД (в репозиторий!) }
  {--------------------------------------------------}
  ActiveRepo.Load;

  {--------------------------------------------------}
  { Берём ссылку на данные репозитория }
  {--------------------------------------------------}
  FDevices := ActiveRepo.Devices;
end;

procedure TFormDeviceSelect.miAddRepositoryClick(Sender: TObject);
var
  RepoName: string;
  Values: TArray<string>;
  DBFileName: string;
  Dlg: TSaveDialog;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if DataManager = nil then
    Exit;

  {----------------------------------}
  { Запрос имени репозитория }
  {----------------------------------}
  RepoName := 'Новый репозиторий';
  Values := TArray<string>.Create(RepoName);

  if not InputQuery(
    'Новый репозиторий',
    ['Имя репозитория:'],
    Values
  ) then
    Exit;

  RepoName := Trim(Values[0]);
  if RepoName = '' then
  begin
    ShowMessage('Имя репозитория не может быть пустым');
    Exit;
  end;

  {----------------------------------}
  { Диалог выбора файла БД }
  {----------------------------------}
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := 'Файл базы данных репозитория';
    Dlg.Filter := 'SQLite database (*.db)|*.db|Все файлы (*.*)|*.*';
    Dlg.DefaultExt := 'db';
    Dlg.FileName := RepoName + '.db';
    Dlg.InitialDir := ExtractFilePath(ParamStr(0));

    if not Dlg.Execute then
      Exit;

    DBFileName := Dlg.FileName;
  finally
    Dlg.Free;
  end;

  {----------------------------------}
  { Добавление репозитория ПРИБОРОВ }
  { Менеджер сам создаёт, открывает и
  { делает его активным }
  {----------------------------------}
  DataManager.AddRepository(
    RepoName,
    rkDevice,
    DBFileName
  );

  {----------------------------------}
  { Пересборка UI }
  {----------------------------------}
  LoadData;              // берёт данные из ActiveDeviceRepo

  FillComboBoxRepository;
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.miAddTestDataClick(Sender: TObject);
begin
  DataManager.ActiveDeviceRepo.InitBulkTestData;
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;

end;

procedure TFormDeviceSelect.miDeleteRepositoryClick(Sender: TObject);
var
  Repo: TDeviceRepository;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (DataManager = nil) or (DataManager.ActiveDeviceRepo = nil) then
    Exit;

  Repo := DataManager.ActiveDeviceRepo;

  {----------------------------------}
  { Подтверждение удаления }
  {----------------------------------}
  if MessageDlg(
    Format(
      'Удалить репозиторий "%s"?' + sLineBreak +
      'Все данные в этой базе будут потеряны.',
      [Repo.Name]
    ),
    TMsgDlgType.mtWarning,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    0
  ) <> mrYes then
    Exit;

  {----------------------------------}
  { Удаление через менеджер }
  {----------------------------------}
  DataManager.RemoveRepository(Repo.Name);

  {----------------------------------}
  { Обновление UI }
  {----------------------------------}
  FillComboBoxRepository;

  if DataManager.ActiveDeviceRepo <> nil then
  begin
    LoadData;        // заново загружает данные активного репозитория
    BuildTree;
    ApplyFilter;
    UpdateGridDevices;
  end
  else
  begin
    {----------------------------------}
    { Нет активного репозитория — чистим UI }
    {----------------------------------}
    TreeViewDevices.Clear;

    if FDevFilteredDevices <> nil then
      FDevFilteredDevices.Clear;

    UpdateGridDevices;
  end;
end;

procedure TFormDeviceSelect.miLoadClick(Sender: TObject);
begin

  if DataManager.ActiveDeviceRepo = nil then
    Exit;

  try
    // TWaitCursor.Create;

    if not DataManager.ActiveDeviceRepo.Load then
      raise Exception.Create('Не удалось загрузить приборы');

    UpdateGridDevices; // обновление таблицы приборов
    BuildTree;         // если есть дерево
    ApplyFilter;

    ShowMessage('Приборы загружены');
  finally
    // Screen.Cursor := crDefault;
  end;
end;

procedure TFormDeviceSelect.miLoadRepositoryClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  DbFileName: string;
  RepoName: string;
begin
  {----------------------------------}
  { Проверка менеджера }
  {----------------------------------}
  if DataManager = nil then
    Exit;

  {----------------------------------}
  { Диалог открытия файла БД }
  {----------------------------------}
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Title := 'Открыть файл репозитория приборов';
    Dlg.Filter := 'SQLite database (*.db)|*.db|Все файлы (*.*)|*.*';
    Dlg.Options := [TOpenOption.ofFileMustExist];
    Dlg.InitialDir := ExtractFilePath(ParamStr(0));

    if not Dlg.Execute then
      Exit;

    DbFileName := Dlg.FileName;
  finally
    Dlg.Free;
  end;

  {----------------------------------}
  { Имя репозитория = имя файла }
  {----------------------------------}
  RepoName :=
    ChangeFileExt(
      ExtractFileName(DbFileName),
      ''
    );

  if RepoName = '' then
  begin
    ShowMessage('Не удалось определить имя репозитория');
    Exit;
  end;

  {----------------------------------}
  { Добавление репозитория ПРИБОРОВ }
  {----------------------------------}
  DataManager.AddRepository(
    RepoName,
    rkDevice,
    DbFileName
  );

  {----------------------------------}
  { Обновление связи и UI }
  {----------------------------------}
  if not UpdateConnection then
  begin
    ClearTreeAndGrid;
    Exit;
  end;

  FillComboBoxRepository;
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.miRefreshRepositoryClick(Sender: TObject);
begin
  {----------------------------------}
  { Пересборка дерева }
  {----------------------------------}
  BuildTree;

  {----------------------------------}
  { Полная пересборка фильтров + сортировка }
  {----------------------------------}
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.miSaveClick(Sender: TObject);
var
  Repo: TDeviceRepository;
begin
  Repo := DataManager.ActiveDeviceRepo;
  if Repo = nil then
    Exit;

  try
    // TWaitCursor.Create;

    if not Repo.Save then
      raise Exception.Create('Не удалось сохранить изменения приборов');

    UpdateGridDevices; // обновление таблицы приборов
    BuildTree;         // если есть дерево
    ApplyFilter;

    ShowMessage('Изменения успешно сохранены');
  finally
    // Screen.Cursor := crDefault;
  end;
end;

procedure TFormDeviceSelect.BuildTree;
var
  D: TDevice;

  AllNode, ManNode, CatNode, ModNode: TTreeViewItem;
  ManText, ManKey: string;
  CatText, CatKey: string;
  ModText, ModKey: string;

  ManPass: Integer;
begin
  if ActiveRepo = nil then
  begin
    TreeViewDevices.Clear;
    GridDevices.RowCount := 0;
    Exit;
  end;

  FDevices := ActiveRepo.Devices;

  TreeViewDevices.BeginUpdate;
  try
    TreeViewDevices.Clear;

    {----------------------------------}
    { Корневой узел }
    {----------------------------------}
    AllNode := TTreeViewItem.Create(TreeViewDevices);
    AllNode.Text := '...';
    AllNode.Tag := Ord(tnAll);
    AllNode.TagString := '';
    TreeViewDevices.AddObject(AllNode);

    {----------------------------------}
    { Проход по изготовителям }
    { ManPass = 0 → заполненные }
    { ManPass = 1 → пустые }
    {----------------------------------}
    for ManPass := 0 to 1 do
    begin
      for D in FDevices do
      begin
        if (Trim(D.Manufacturer) = '') xor (ManPass = 1) then
          Continue;

        {========== ИЗГОТОВИТЕЛЬ =========}
        if Trim(D.Manufacturer) <> '' then
        begin
          ManText := D.Manufacturer;
          ManKey  := D.Manufacturer;
        end
        else
        begin
          ManText := '<изготовитель>';
          ManKey  := '';
        end;

        ManNode := FindChildInTree(
          TreeViewDevices,
          Ord(tnManufacturer),
          ManKey
        );

        if ManNode = nil then
        begin
          ManNode := TTreeViewItem.Create(TreeViewDevices);
          ManNode.Text := ManText;
          ManNode.Tag := Ord(tnManufacturer);
          ManNode.TagString := ManKey;
          TreeViewDevices.AddObject(ManNode);
        end;

        {========== КАТЕГОРИЯ (ТОЛЬКО ПО ИМЕНИ) =========}
        if Trim(D.CategoryName) <> '' then
        begin
          CatText := D.CategoryName;
          CatKey  := D.CategoryName;
        end
        else
        begin
          CatText := '<категория>';
          CatKey  := '';
        end;

        CatNode := FindChildInNode(
          ManNode,
          Ord(tnCategory),
          CatKey
        );

        if CatNode = nil then
        begin
          CatNode := TTreeViewItem.Create(TreeViewDevices);
          CatNode.Text := CatText;
          CatNode.Tag := Ord(tnCategory);
          CatNode.TagString := CatKey;
          ManNode.AddObject(CatNode);
        end;

        {========== МОДИФИКАЦИИ =========}
        if Trim(D.Modification) <> '' then
        begin
          ModText := D.Modification;
          ModKey  := D.Modification;
        end
        else
        begin
          ModText := '<модификация>';
          ModKey  := '';
        end;

        ModNode := FindChildInNode(
          CatNode,
          Ord(tnModification),
          ModKey
        );

        if ModNode = nil then
        begin
          ModNode := TTreeViewItem.Create(TreeViewDevices);
          ModNode.Text := ModText;
          ModNode.Tag := Ord(tnModification);
          ModNode.TagString := ModKey;
          CatNode.AddObject(ModNode);
        end;
      end;
    end;

    TreeViewDevices.Selected := AllNode;

  finally
    TreeViewDevices.EndUpdate;
  end;
end;

procedure TFormDeviceSelect.ButtonDeviceAddClick(Sender: TObject);
var
  NewDevice, SrcDevice: TDevice;
  SelRow: Integer;
begin
  {--------------------------------------------------}
  { Если нет активного репозитория — некуда добавлять }
  {--------------------------------------------------}
  if (DataManager = nil) or (ActiveRepo = nil) then
    Exit;

  {--------------------------------------------------}
  { 1. Формируем новый прибор }
  {--------------------------------------------------}

  {--------------------------------------------------}
  { 2. Если есть выделенная строка — копируем её }
  {--------------------------------------------------}


  SelRow := GridDevices.Row;

  NewDevice := ActiveRepo.CreateDevice(SelRow);


  {--------------------------------------------------}
  { 3. Обновляем ТОЛЬКО фильтрованные списки }
  {--------------------------------------------------}
  ApplyFilter; // Tree → Text → Date → Sort

  UpdateGridDevices;

  {--------------------------------------------------}
  { 4. Выделяем добавленную строку }
  {--------------------------------------------------}
  if GridDevices.RowCount > 0 then
    GridDevices.Row := GridDevices.RowCount - 1;
end;

procedure TFormDeviceSelect.ButtonDeviceClearClick(Sender: TObject);
var
  I: Integer;
  D: TDevice;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (FDevFilteredDevices = nil) or (FDevFilteredDevices.Count = 0) then
    Exit;

  if MessageDlg(
       'Удалить все отображаемые приборы безвозвратно?',
       TMsgDlgType.mtWarning,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  {----------------------------------}
  { Удаление через репозиторий }
  { Идём с конца, чтобы ничего не сломать }
  {----------------------------------}
  for I := FDevFilteredDevices.Count - 1 downto 0 do
  begin
    D := FDevFilteredDevices[I];
    if D <> nil then
      ActiveRepo.DeleteDevice(D);
  end;

  {----------------------------------}
  { Пересборка фильтров и дерева }
  {----------------------------------}
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;

  {----------------------------------}
  { Сброс выделения }
  {----------------------------------}
  GridDevices.Row := -1;
end;

procedure TFormDeviceSelect.ButtonDeviceDeleteClick(Sender: TObject);
var
  SelRow: Integer;
  SelDevice: TDevice;
begin
  {----------------------------------}
  { Проверка списка }
  {----------------------------------}
  if (FDevFilteredDevices = nil) or (FDevFilteredDevices.Count = 0) then
    Exit;

  SelRow := GridDevices.Row;
  if (SelRow < 0) or (SelRow >= FDevFilteredDevices.Count) then
    Exit;

  SelDevice := FDevFilteredDevices[SelRow];
  if SelDevice = nil then
    Exit;

  {----------------------------------}
  { Подтверждение удаления }
  {----------------------------------}
  if MessageDlg(
       'Удалить выбранный прибор безвозвратно?',
       TMsgDlgType.mtWarning,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  {----------------------------------}
  { Удаление через репозиторий }
  {----------------------------------}
  ActiveRepo.DeleteDevice(SelDevice);

  {----------------------------------}
  { Пересборка фильтров }
  {----------------------------------}
  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(FDevices);

  ApplyFilter;
  UpdateGridDevices;

  {----------------------------------}
  { Сброс выделения }
  {----------------------------------}
  GridDevices.Row := -1;
end;

procedure TFormDeviceSelect.ApplyFilter;
begin
  {----------------------------------}
  { 1. Фильтр по дереву }
  {----------------------------------}
  // дерево остаётся как есть
  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(ActiveRepo.Devices);

  {----------------------------------}
  { 2. Текстовый фильтр }
  {----------------------------------}
  FreeAndNil(FDevFilteredByText);

  FreeAndNil(FDevFilteredByText);
  FDevFilteredByText :=
  TEntityFilters<TDevice>.ApplyTextFilter(
    FDevFilteredByTree,
    EditFindDevice.Text
  );

  {----------------------------------}
  { 3. Фильтр по дате }
  {----------------------------------}

  FreeAndNil(FDevFilteredByDate);
  FDevFilteredByDate :=
  TEntityFilters<TDevice>.ApplyDateFilter(
    FDevFilteredByText,
    DateEditFilter.Date,
    not DateEditFilter.IsEmpty
  );

  {----------------------------------}
  { 4. Сортировка }
  {----------------------------------}

    FreeAndNil(FDevFilteredDevices);
    FDevFilteredDevices :=
    TEntitySorter<TDevice>.Sort(
    FDevFilteredByDate,
    Ord(ColumnToSortField(FSortColumn)),
    FSortAscending
  );

end;

function TFormDeviceSelect.BuildFilteredByTree(
  const Source: TObjectList<TDevice>
): TObjectList<TDevice>;
var
  D: TDevice;
begin
  Result := TObjectList<TDevice>.Create(False); // ссылки, не владеем

  if Source = nil then
    Exit;

  for D in Source do
    if PassTreeFilter(D) then
      Result.Add(D);
end;

procedure TFormDeviceSelect.UpdateGridDevices;
begin
  GridDevices.BeginUpdate;
  try
    if FDevFilteredDevices <> nil then
      GridDevices.RowCount := FDevFilteredDevices.Count
    else
      GridDevices.RowCount := 0;
  finally
    GridDevices.EndUpdate;
  end;

  sbFind.IsPressed := HasActiveFilters;
end;

function TFormDeviceSelect.HasActiveFilters: Boolean;
begin
  Result :=
    (Trim(EditFindDevice.Text) <> '') or
    (not DateEditFilter.IsEmpty);
end;

procedure TFormDeviceSelect.ResetSorting;
begin
  FSortColumn := -1;
  FSortAscending := True;
end;

procedure TFormDeviceSelect.sbClearClick(Sender: TObject);
begin
  {----------------------------------}
  { 1. Очистка фильтров ввода }
  {----------------------------------}
  EditFindDevice.Text := '';
  DateEditFilter.IsEmpty := True;

  {----------------------------------}
  { 2. Пересчёт фильтров }
  {----------------------------------}
  ApplyFilter;
  UpdateGridDevices;

  {----------------------------------}
  { 3. Индикация: фильтров больше нет }
  {----------------------------------}
  sbFind.IsPressed := False;
end;


procedure TFormDeviceSelect.sbFindClick(Sender: TObject);
begin
   ApplyFilter;
    UpdateGridDevices;
end;

procedure TFormDeviceSelect.TreeViewDevicesChange(Sender: TObject);
begin
  if TreeViewDevices.Selected = nil then
    Exit;

  {----------------------------------}
  { Фильтр по дереву }
  {----------------------------------}
  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(FDevices);

  {----------------------------------}
  { Пересчёт всех фильтров }
  {----------------------------------}
  ApplyFilter;
  UpdateGridDevices;
end;


function TFormDeviceSelect.BuildSearchURL(const ASearch: string): string;
begin
  Result :=
    'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
    '?search=' + TNetEncoding.URL.Encode(ASearch) +
    '&start=0&rows=20';
end;

function TFormDeviceSelect.UpdateConnection: Boolean;
begin
  Result := False;

  ClearTreeAndGrid;

  {----------------------------------}
  { Проверка менеджера }
  {----------------------------------}
  if DataManager = nil then
    Exit;

  {----------------------------------}
  { Проверка активного репозитория приборов }
  {----------------------------------}
  if DataManager.ActiveDeviceRepo = nil then
    Exit;

  {----------------------------------}
  { Проверка данных репозитория }
  {----------------------------------}
  if DataManager.ActiveDeviceRepo.Devices = nil then
    Exit;

  {----------------------------------}
  { Обновляем ссылку на данные }
  {----------------------------------}
  ActiveRepo := DataManager.ActiveDeviceRepo;
  FDevices := ActiveRepo.Devices;

  Result := True;
end;

procedure TFormDeviceSelect.ClearTreeAndGrid;
begin
  {----------------------------------}
  { Очистка дерева }
  {----------------------------------}
  TreeViewDevices.BeginUpdate;
  try
    TreeViewDevices.Clear;
  finally
    TreeViewDevices.EndUpdate;
  end;

  {----------------------------------}
  { Очистка отфильтрованного списка }
  {----------------------------------}
  if FDevFilteredDevices <> nil then
    FDevFilteredDevices.Clear;

  {----------------------------------}
  { Очистка таблицы }
  {----------------------------------}
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.OpenDeviceEditor(ADevice: TDevice);
var
  Frm: TFormDeviceEditor;
begin
  if ADevice = nil then
    Exit;

  Frm := TFormDeviceEditor.Create(Self);
  try
    {----------------------------------}
    { Передаём контекст }
    {----------------------------------}
 //  Frm.DataManager := DataManager;
 //   Frm.ActiveRepo  := ActiveRepo;
 //   Frm.Device      := ADevice;
      Frm.LoadDevice(ADevice);
    {----------------------------------}
    { Открываем модально }
    {----------------------------------}
    if Frm.ShowModal = mrOk then
    begin
      {----------------------------------}
      { Обновляем данные и UI }
      {----------------------------------}
      ApplyFilter;
      UpdateGridDevices;
    end;

  finally
    Frm.Free;
  end;
end;

function TFormDeviceSelect.PassTreeFilter(
  const ADevice: TDevice
): Boolean;
var
  Cur: TTreeViewItem;
begin
  Result := True;

  if ADevice = nil then
    Exit(True);

  Cur := TreeViewDevices.Selected;
  if Cur = nil then
    Exit(True);

  {----------------------------------}
  { Узел "Все" }
  {----------------------------------}
  if Cur.Tag = Ord(tnAll) then
    Exit(True);

  {-------------------------------------------------}
  { Идём ВВЕРХ по дереву и сразу проверяем }
  {-------------------------------------------------}
  while Cur <> nil do
  begin
    case Cur.Tag of

      {---------- ИЗГОТОВИТЕЛЬ ----------}
      Ord(tnManufacturer):
        begin
          // TagString = '' → пустой изготовитель
          if ADevice.Manufacturer <> Cur.TagString then
            Exit(False);
        end;

      {---------- КАТЕГОРИЯ (ПО ИМЕНИ) ----------}
      Ord(tnCategory):
        begin
          // TagString = '' → без категории
          if ADevice.CategoryName <> Cur.TagString then
            Exit(False);
        end;

      {---------- МОДИФИКАЦИЯ ----------}
      Ord(tnModification):
        begin
          // TagString = '' → пустая модификация
          if ADevice.Modification <> Cur.TagString then
            Exit(False);
        end;
    end;

    Cur := Cur.ParentItem; // ⬅ только вверх
  end;

  {----------------------------------}
  { Если дошли сюда — все уровни прошли }
  {----------------------------------}
  Result := True;
end;

function TFormDeviceSelect.ColumnToSortField(
  ACol: Integer
): TDeviceSortField;
begin
  if ACol = StringColumnName.Index then
    Result := dsfName

  else if ACol = StringColumnCategory.Index then
    Result := dsfCategory

  else if ACol = StringColumnManufacturer.Index then
    Result := dsfManufacturer

  else if ACol = StringColumnModification.Index then
    Result := dsfModification

  else if ACol = StringColumnAccuracyClass.Index then
    Result := dsfAccuracyClass

  else if ACol = StringColumnReestrNumber.Index then
    Result := dsfReestrNumber

  else if ACol = StringColumnProcedure.Index then
    Result := dsfProcedure

  else if ACol = StringColumnVerificationMethod.Index then
    Result := dsfVerificationMethod

  else if ACol = StringColumnIVI.Index then
    Result := dsfIVI

  else if ACol = StringColumnRegDate.Index then
    Result := dsfRegDate

  else if ACol = StringColumnValidityDate.Index then
    Result := dsfValidityDate

  else
    Result := dsfName; // безопасный дефолт
end;

procedure TFormDeviceSelect.ComboBoxRepositoryChange(Sender: TObject);
var
  Idx: Integer;
  RepoName: string;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if DataManager = nil then
    Exit;

  Idx := ComboBoxRepository.ItemIndex;
  if Idx < 0 then
    Exit;

  RepoName := ComboBoxRepository.Items[Idx];

  {----------------------------------}
  { Смена активного репозитория через менеджер }
  {----------------------------------}
  DataManager.SetActiveDeviceRepository(RepoName);

  {----------------------------------}
  { Пересборка UI }
  {----------------------------------}
  LoadData;   // гарантирует валидный FDevices

  if not UpdateConnection then
    Exit;

  BuildTree;
  ApplyFilter;
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.CornerButtonEditDeviceClick(Sender: TObject);
var
  Row: Integer;
  ADevice: TDevice;
begin
  {----------------------------------}
  { Проверка выбора }
  {----------------------------------}
  Row := GridDevices.Row;
  if (Row < 0) then
  begin
    ShowMessage('Выберите прибор для редактирования');
    Exit;
  end;

  if (FDevFilteredDevices = nil) or (Row >= FDevFilteredDevices.Count) then
    Exit;

  {----------------------------------}
  { Получаем ПРИБОР как объект }
  {----------------------------------}
  ADevice := FDevFilteredDevices[Row];
  if ADevice = nil then
    Exit;

  {----------------------------------}
  { Открываем редактор }
  {----------------------------------}
  OpenDeviceEditor(ADevice);

    ADevice := FDevFilteredDevices[Row];
end;


procedure TFormDeviceSelect.DateEditFilterChange(Sender: TObject);
begin
  {----------------------------------}
  { Фильтр по дате поверх текста }
  {----------------------------------}
  FreeAndNil(FDevFilteredByDate);
  FDevFilteredByDate :=
    TEntityFilters<TDevice>.ApplyDateFilter(
      FDevFilteredByText,
      DateEditFilter.Date,
      not DateEditFilter.IsEmpty
    );

  {----------------------------------}
  { Сортировка }
  {----------------------------------}
  FreeAndNil(FDevFilteredDevices);
  FDevFilteredDevices :=
    TEntitySorter<TDevice>.Sort(
      FDevFilteredByDate,
      Ord(ColumnToSortField(FSortColumn)),
      FSortAscending
    );

  {----------------------------------}
  { Обновление таблицы }
  {----------------------------------}
  UpdateGridDevices;
end;

procedure TFormDeviceSelect.EditFindDeviceExit(Sender: TObject);
begin
  ApplyFilter;
    UpdateGridDevices;
end;

procedure TFormDeviceSelect.FillComboBoxRepository;
var
  Repo: TDeviceRepository;
  ItemIndex: Integer;
begin
  ComboBoxRepository.BeginUpdate;
  try
    ComboBoxRepository.Clear;

    if DataManager = nil then
      Exit;

    ItemIndex := -1;

    {----------------------------------}
    { Перебираем репозитории приборов }
    {----------------------------------}
    for Repo in DataManager.DeviceRepositories do
    begin
      ComboBoxRepository.Items.Add(Repo.Name);

      {----------------------------------}
      { Запоминаем активный репозиторий }
      {----------------------------------}
      if Repo = DataManager.ActiveDeviceRepo then
        ItemIndex := ComboBoxRepository.Items.Count - 1;
    end;

    {----------------------------------}
    { Выбираем активный репозиторий }
    {----------------------------------}
    ComboBoxRepository.ItemIndex := ItemIndex;

  finally
    ComboBoxRepository.EndUpdate;
  end;
end;

procedure TFormDeviceSelect.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DataManager.Save;
end;

procedure TFormDeviceSelect.FormCreate(Sender: TObject);
begin
  {----------------------------------}
  { Инициализация сортировки }
  {----------------------------------}
  FSortColumn := -1;
  FSortAscending := True;

  {----------------------------------}
  { Загрузка данных и репозиториев }
  {----------------------------------}
  LoadData;
  FillComboBoxRepository;

  {----------------------------------}
  { Подключение и первичная отрисовка UI }
  {----------------------------------}
  if UpdateConnection then
  begin
    BuildTree;
    ApplyFilter;
    UpdateGridDevices;
  end;
end;

procedure TFormDeviceSelect.GridDevicesGetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  var Value: TValue
);
var
  D: TDevice;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if ActiveRepo = nil then
    Exit;

  if FDevFilteredDevices = nil then
    Exit;

  if (ARow < 0) or (ARow >= FDevFilteredDevices.Count) then
    Exit;

  D := FDevFilteredDevices[ARow];
  if D = nil then
    Exit;

  {----------------------------------}
  { Значения колонок }
  {----------------------------------}
  if ACol = StringColumnName.Index then
    Value := D.Name

  else if ACol = StringColumnSerial.Index then
    Value := D.SerialNumber

  else if ACol = StringColumnManufacturer.Index then
    Value := D.Manufacturer

  else if ACol = StringColumnOwner.Index then
    Value := D.Owner

  else if ACol = StringColumnCategory.Index then
  begin
    if Trim(D.CategoryName) <> '' then
      Value := D.CategoryName
    else
      Value := '-';
  end

  else if ACol = StringColumnModification.Index then
    Value := D.Modification

  else if ACol = StringColumnAccuracyClass.Index then
    Value := D.AccuracyClass

  else if ACol = StringColumnReestrNumber.Index then
    Value := D.ReestrNumber

  else if ACol = StringColumnRegDate.Index then
  begin
    if D.RegDate > 0 then
      Value := DateToStr(D.RegDate)
    else
      Value := '-';
  end

  else if ACol = StringColumnValidityDate.Index then
  begin
    if D.ValidityDate > 0 then
      Value := DateToStr(D.ValidityDate)
    else
      Value := '-';
  end

  else if ACol = StringColumnDateOfManufacture.Index then
  begin
    if D.DateOfManufacture > 0 then
      Value := DateToStr(D.DateOfManufacture)
    else
      Value := '-';
  end

  else if ACol = StringColumnIVI.Index then
    Value := D.IVI

  else if ACol = StringColumnVerificationMethod.Index then
    Value := D.VerificationMethod

  else if ACol = StringColumnProcedure.Index then
    Value := D.ProcedureName;
end;

end.
