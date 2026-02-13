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
    procedure GridDevicesHeaderClick(Column: TColumn);
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
    procedure SpeedButtonFindInternetClick(Sender: TObject);

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
  function OpenDeviceEditor(ADevice: TDevice): Boolean;  // открытие редактора прибора
  function GetDeviceCategoryText(const ADevice: TDevice; AForTree: Boolean = False): string;
  function FindDeviceTreeNode(const ADevice: TDevice): TTreeViewItem;
  procedure SelectEditedDevice(const ADevice: TDevice);

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
  CategoryText: string;
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

        {========== КАТЕГОРИЯ =========}
        CategoryText := GetDeviceCategoryText(D, True);
        if Trim(CategoryText) <> '' then
        begin
          CatText := CategoryText;
          CatKey  := CategoryText;
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
var
  SourceDevices: TObjectList<TDevice>;
begin
  {----------------------------------}
  { 1. Фильтр по дереву }
  {----------------------------------}
  { Берём уже загруженный список, чтобы фильтрация не зависела от ActiveRepo=nil }
  SourceDevices := FDevices;

  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(SourceDevices);

  {----------------------------------}
  { 2. Текстовый фильтр }
  {----------------------------------}
  FreeAndNil(FDevFilteredByText);
  FDevFilteredByText :=
    TEntityFilters<TDevice>.ApplyTextFilter(
      FDevFilteredByTree,
      Trim(EditFindDevice.Text)
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


procedure TFormDeviceSelect.SpeedButtonFindInternetClick(Sender: TObject);
var
  Resp: IHTTPResponse;
  Url: string;
  ResponseText: string;

  Json: TJSONObject;
  ResultObj: TJSONObject;
  Items: TJSONArray;
  Item: TJSONObject;

  I: Integer;
  SearchText: string;
  DetectText: string;

  CurrentYear: Integer;
  StartYear: Integer;
  SearchYear: Integer;
  TotalCount: Integer;
  FoundCount: Integer;

  Dev: TDevice;
  FoundType: TDeviceType;
  FoundRepo: TTypeRepository;

  ImportedReestr: string;
  ImportedCategoryName: string;
  ImportedDeviceTypeName: string;
  ImportedModification: string;
  ImportedSerialNumber: string;
  ImportedOwner: string;
  ImportedRegDate: TDate;
  ImportedValidityDate: TDate;
  ImportedDocNum: string;

  function TryParseArshinDate(const S: string; out ADate: TDate): Boolean;
  var
    STrim, SDay, SMonth, SYear: string;
    P1, P2: Integer;
    D, M, Y: Integer;
  begin
    Result := False;
    ADate := 0;

    STrim := Trim(S);
    P1 := Pos('.', STrim);
    if P1 <= 0 then
      Exit;

    P2 := PosEx('.', STrim, P1 + 1);
    if P2 <= 0 then
      Exit;

    if PosEx('.', STrim, P2 + 1) > 0 then
      Exit;

    SDay := Copy(STrim, 1, P1 - 1);
    SMonth := Copy(STrim, P1 + 1, P2 - P1 - 1);
    SYear := Copy(STrim, P2 + 1, MaxInt);

    if not TryStrToInt(SDay, D) then
      Exit;

    if not TryStrToInt(SMonth, M) then
      Exit;

    if not TryStrToInt(SYear, Y) then
      Exit;

  //  Result := TryEncodeDate(Y, M, D, ADate);
  end;

  function FindTypeByReestrNumber(
    const AReestrNumber: string;
    out ARepo: TTypeRepository
  ): TDeviceType;
  var
    Repo: TTypeRepository;
    T: TDeviceType;
  begin
    Result := nil;
    ARepo := nil;

    if (AReestrNumber = '') or (DataManager = nil) then
      Exit;

    for Repo in DataManager.TypeRepositories do
    begin
      if (Repo = nil) or (Repo.Types = nil) then
        Continue;

      for T in Repo.Types do
        if SameText(Trim(T.ReestrNumber), Trim(AReestrNumber)) then
        begin
          Result := T;
          ARepo := Repo;
          Exit;
        end;
    end;
  end;

begin
  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  if EditFindDevice.Text.Trim = '' then
  begin
    MemoLog.Lines.Add('Пустая строка поиска');
    Exit;
  end;

  if ActiveRepo = nil then
  begin
    MemoLog.Lines.Add('Активный репозиторий не инициализирован');
    Exit;
  end;

  CurrentYear := YearOf(Date);
  if not DateEditFilter.IsEmpty then
    StartYear := YearOf(DateEditFilter.Date)
  else
    StartYear := CurrentYear;

  if StartYear < 2010 then
    StartYear := 2010;

  if StartYear > CurrentYear then
    StartYear := CurrentYear;

  SearchText := '*' + EditFindDevice.Text.Trim + '*';
  FoundCount := 0;

  try
    for SearchYear := StartYear to CurrentYear do
    begin
      Url :=
        'https://fgis.gost.ru/fundmetrologytest/eapi/vri/' +
        '?year=' + SearchYear.ToString +
        '&search=' + TNetEncoding.URL.Encode(SearchText) +
        '&rows=100&start=0';

      Resp := NetHTTPClient1.Get(Url);
      ResponseText := Resp.ContentAsString;

      MemoLog.Lines.Add('URL: ' + Url);
      MemoLog.Lines.Add('Status: ' + Resp.StatusCode.ToString);

      Json := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
      try
        if Json = nil then
          Continue;

        ResultObj := Json.GetValue('result') as TJSONObject;
        if ResultObj = nil then
          Continue;

        TotalCount := ResultObj.GetValue<Integer>('count');
        MemoLog.Lines.Add('Count: ' + TotalCount.ToString);

        if TotalCount <= 0 then
          Continue;

        Items := ResultObj.GetValue('items') as TJSONArray;
        if Items = nil then
          Continue;

        for I := 0 to Items.Count - 1 do
        begin
          Item := Items.Items[I] as TJSONObject;
          if Item = nil then
            Continue;

          Dev := ActiveRepo.CreateDevice(-1);

          if Item.GetValue('vri_id') <> nil then
            Dev.MitUUID := Item.GetValue('vri_id').Value;

          ImportedOwner := '';
          ImportedReestr := '';
          ImportedCategoryName := '';
          ImportedDeviceTypeName := '';
          ImportedModification := '';
          ImportedSerialNumber := '';
          ImportedRegDate := 0;
          ImportedValidityDate := 0;
          ImportedDocNum := '';

          if Item.GetValue('org_title') <> nil then
            ImportedOwner := Item.GetValue('org_title').Value;

          if Item.GetValue('mit_number') <> nil then
            ImportedReestr := Item.GetValue('mit_number').Value;

          if Item.GetValue('mit_title') <> nil then
            ImportedCategoryName := Item.GetValue('mit_title').Value;

          if Item.GetValue('mit_notation') <> nil then
            ImportedDeviceTypeName := Item.GetValue('mit_notation').Value;

          if Item.GetValue('mi_modification') <> nil then
            ImportedModification := Item.GetValue('mi_modification').Value;

          if Item.GetValue('mi_number') <> nil then
            ImportedSerialNumber := Item.GetValue('mi_number').Value;

          if (Item.GetValue('verification_date') <> nil) then
            TryParseArshinDate(Item.GetValue('verification_date').Value, ImportedRegDate);

          if (Item.GetValue('valid_date') <> nil) then
            TryParseArshinDate(Item.GetValue('valid_date').Value, ImportedValidityDate);

          if Item.GetValue('result_docnum') <> nil then
            ImportedDocNum := Item.GetValue('result_docnum').Value;

          FoundType := FindTypeByReestrNumber(ImportedReestr, FoundRepo);
          if FoundType <> nil then
          begin
            Dev.AttachType(FoundType, FoundRepo.Name);
            Dev.FillFromType(FoundType);
          end;

          Dev.Owner := ImportedOwner;
          Dev.ReestrNumber := ImportedReestr;
          Dev.CategoryName := ImportedCategoryName;
          Dev.DeviceTypeName := ImportedDeviceTypeName;
          Dev.Modification := ImportedModification;
          Dev.SerialNumber := ImportedSerialNumber;
          Dev.Documentation := ImportedDocNum;

          if ImportedRegDate > 0 then
            Dev.RegDate := ImportedRegDate;

          if ImportedValidityDate > 0 then
            Dev.ValidityDate := ImportedValidityDate;

          if Dev.Category <= 0 then
          begin
            DetectText := NormalizeSearchText(Dev.CategoryName + ' ' + Dev.DeviceTypeName);

            if DataManager.ActiveTypeRepo <> nil then
              Dev.Category := DataManager.ActiveTypeRepo.DetectCategoryByKeywords(DetectText);
          end;

          Inc(FoundCount);
        end;

        Break;
      finally
        Json.Free;
      end;
    end;

    MemoLog.Lines.Add('------------------------------');
    MemoLog.Lines.Add('Добавлено приборов: ' + FoundCount.ToString);

    if not UpdateConnection then
      Exit;

    BuildTree;
    ApplyFilter;
    UpdateGridDevices;
  except
    on E: Exception do
      MemoLog.Lines.Add('ERROR: ' + E.Message);
  end;
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

function TFormDeviceSelect.OpenDeviceEditor(ADevice: TDevice): Boolean;
var
  Frm: TFormDeviceEditor;
begin
  Result := False;

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
      Result := True;

  finally
    Frm.Free;
  end;
end;

function TFormDeviceSelect.GetDeviceCategoryText(const ADevice: TDevice; AForTree: Boolean): string;
var
  C: TDeviceCategory;
begin
  Result := '';

  if ADevice = nil then
    Exit;

  if ADevice.Category > 0 then
  begin
    if (DataManager <> nil) and (DataManager.ActiveTypeRepo <> nil) then
      Result := DataManager.ActiveTypeRepo.CategoryToText(ADevice.Category, ADevice.CategoryName)
    else if DataManager <> nil then
    begin
      C := DataManager.FindCategoryByID(ADevice.Category);
      if C <> nil then
        Result := C.Name
      else
        Result := ADevice.CategoryName;
    end
    else
      Result := ADevice.CategoryName;
  end
  else if ADevice.Category = -1 then
  begin
    if AForTree then
      Result := ''
    else
      Result := Trim(ADevice.CategoryName);
  end;
end;

function TFormDeviceSelect.FindDeviceTreeNode(const ADevice: TDevice): TTreeViewItem;
var
  ManNode, CatNode, ModNode: TTreeViewItem;
  ManKey, CatKey, ModKey: string;
begin
  Result := nil;

  if ADevice = nil then
    Exit;

  if Trim(ADevice.Manufacturer) <> '' then
    ManKey := ADevice.Manufacturer
  else
    ManKey := '';

  ManNode := FindChildInTree(TreeViewDevices, Ord(tnManufacturer), ManKey);
  if ManNode = nil then
    Exit;

  CatKey := GetDeviceCategoryText(ADevice, True);
  CatNode := FindChildInNode(ManNode, Ord(tnCategory), CatKey);
  if CatNode = nil then
    Exit(ManNode);

  if Trim(ADevice.Modification) <> '' then
    ModKey := ADevice.Modification
  else
    ModKey := '';

  ModNode := FindChildInNode(CatNode, Ord(tnModification), ModKey);
  if ModNode <> nil then
    Exit(ModNode);

  Result := CatNode;
end;

procedure TFormDeviceSelect.SelectEditedDevice(const ADevice: TDevice);
var
  Node: TTreeViewItem;
  I: Integer;
begin
  Node := FindDeviceTreeNode(ADevice);
  if Node <> nil then
    TreeViewDevices.Selected := Node;

  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(FDevices);

  ApplyFilter;
  UpdateGridDevices;

  GridDevices.Row := -1;
  if FDevFilteredDevices = nil then
    Exit;

  for I := 0 to FDevFilteredDevices.Count - 1 do
    if FDevFilteredDevices[I] = ADevice then
    begin
      GridDevices.Row := I;
      Break;
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
          if GetDeviceCategoryText(ADevice, True) <> Cur.TagString then
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
  if OpenDeviceEditor(ADevice) then
  begin
    {----------------------------------}
    { Перестраиваем дерево/таблицу и возвращаем выделение на отредактированный прибор }
    {----------------------------------}
    BuildTree;
    SelectEditedDevice(ADevice);
  end;
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
    if Trim(GetDeviceCategoryText(D)) <> '' then
      Value := GetDeviceCategoryText(D)
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

procedure TFormDeviceSelect.GridDevicesHeaderClick(Column: TColumn);
begin
  if Column = nil then
    Exit;

  {----------------------------------}
  { Логика сортировки (утверждённая) }
  {----------------------------------}
  if FSortColumn = Column.Index then
    FSortAscending := not FSortAscending
  else
  begin
    FSortColumn := Column.Index;
    FSortAscending := True;
  end;

  {----------------------------------}
  { Сортируем ТЕКУЩИЙ результат }
  {----------------------------------}
  FreeAndNil(FDevFilteredDevices);
  FDevFilteredDevices :=
    TEntitySorter<TDevice>.Sort(
      FDevFilteredByDate,          // текущий список после всех фильтров
      Ord(ColumnToSortField(FSortColumn)),
      FSortAscending
    );

  {----------------------------------}
  { Обновление таблицы }
  {----------------------------------}
  UpdateGridDevices;
end;

end.
