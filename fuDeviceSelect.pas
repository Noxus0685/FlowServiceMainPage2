unit fuDeviceSelect;

interface

uses
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.DateTimeCtrls,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Menus,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Types,
  fuDeviceEdit,
  fuTypeEditor,
  System.Actions,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uRepositories,
  uProtocols;

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
    CheckColumnDeviceEnable: TCheckColumn;
    StringColumnName: TStringColumn;
    StringColumnManufacturer: TStringColumn;
    StringColumnCategory: TStringColumn;
    StringColumnModification: TStringColumn;
    StringColumnAccuracyClass: TStringColumn;
    StringTemp: TStringColumn;
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
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PopupMenu2: TPopupMenu;
    mpExpandAll: TMenuItem;
    mpCollapseAll: TMenuItem;
    mpRefresh: TMenuItem;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    sbDetaled: TLabel;
    StringColumnSerial: TStringColumn;
    StringColumnHASH: TStringColumn;
    StringColumnOwner: TStringColumn;
    StringColumnDateOfManufacture: TStringColumn;
    miAddTestData: TMenuItem;
    miLoad: TMenuItem;
    aDevicePaste: TAction;
    aDeviceCut: TAction;
    aDeviceCopy: TAction;
    aRefreshRepository: TAction;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    actDeviceSelect: TAction;
    sbClearDate: TSpeedButton;
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
    procedure GridDevicesCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDevicesHeaderClick(Column: TColumn);
    procedure miAddRepositoryClick(Sender: TObject);
    procedure miDeleteRepositoryClick(Sender: TObject);
    procedure miLoadRepositoryClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miAddTestDataClick(Sender: TObject);
    procedure miLoadClick(Sender: TObject);
    procedure SpeedButtonFindInternetClick(Sender: TObject);
    procedure aCreateTypeExecute(Sender: TObject);
    procedure aEditTypeExecute(Sender: TObject);
    procedure aDeleteTypeExecute(Sender: TObject);
    procedure aDeviceCopyExecute(Sender: TObject);
    procedure aDevicePasteExecute(Sender: TObject);
    procedure aDeviceCutExecute(Sender: TObject);
    procedure UpdateDeviceActions(Sender: TObject);
    procedure aRefreshRepositoryExecute(Sender: TObject);
    procedure FullRefreshDevicesView;
    procedure GridDevicesKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure GridDevicesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridDevicesEnter(Sender: TObject);
    procedure GridDevicesExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure actDeviceSelectExecute(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure sbClearDateClick(Sender: TObject);

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
  FSkipDeviceDeleteConfirm: Boolean;
  FCheckedDevices: TList<TDevice>;
  FDeletedDeviceUUIDs: TStringList;

  { ================= ОСНОВНЫЕ ПРОЦЕДУРЫ ================= }

  procedure LoadData;                            // загрузка приборов из репозитория
  procedure BuildTree;                           // построение дерева (категории / типы / владельцы)
  procedure UpdateGridDevices;                   // обновление таблицы приборов
  function OpenDeviceEditor(ADevice: TDevice): Boolean;  // открытие редактора прибора
  function GetDeviceCategoryText(const ADevice: TDevice; AForTree: Boolean = False): string;
  function FindDeviceTreeNode(const ADevice: TDevice): TTreeViewItem;
  procedure SelectEditedDevice(const ADevice: TDevice);
  procedure ClearTreeSelectionFlags;
  procedure ApplyInitialSelection;

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
  procedure RebuildTreeFull;                      // полная перерисовка дерева
  function GetSelectedDevices: TObjectList<TDevice>;
  function GetActiveTreeNode: TTreeViewItem;
  procedure ClearCheckedDevices;
  function GetCheckedDevices: TObjectList<TDevice>;
  procedure ClearGridSelection;
  function IsGridInputFocused: Boolean;
  procedure SyncTreeAfterGridRowsRemoved;
  procedure WriteDeviceActionLog(const AAction: string; ADevice: TDevice; const ADetails: string = '');
  procedure LogDuplicateDeviceUUIDs;

public
  { Public declarations }
  constructor Create(AOwner: TComponent); override;
  function GetSelectedDevice: TDevice;
  destructor Destroy; override;
  property DeletedDeviceUUIDs: TStringList read FDeletedDeviceUUIDs;

  end;

var
  FormDeviceSelect: TFormDeviceSelect;

implementation
  uses
   uAppServices,
   uWorkTable;
{$R *.fmx}
constructor TFormDeviceSelect.Create(AOwner: TComponent);
begin
  inherited;
  FDeletedDeviceUUIDs := TStringList.Create;
  FDeletedDeviceUUIDs.Duplicates := dupIgnore;
  FDeletedDeviceUUIDs.CaseSensitive := False;
end;

destructor TFormDeviceSelect.Destroy;
begin
  FreeAndNil(FDeletedDeviceUUIDs);
  FreeAndNil(FCheckedDevices);
  inherited;
end;

function TFormDeviceSelect.GetSelectedDevice: TDevice;
var
  Row: Integer;
begin
  Result := nil;

  Row := GridDevices.Row;
  if Row < 0 then
    Exit;

  if (FDevFilteredDevices = nil) or (Row >= FDevFilteredDevices.Count) then
    Exit;

  Result := FDevFilteredDevices[Row];
end;

procedure TFormDeviceSelect.WriteDeviceActionLog(const AAction: string; ADevice: TDevice; const ADetails: string);
var
  Details: string;
begin
  if (ADevice = nil) or (ProtocolManager = nil) then
    Exit;

  Details := Format('Action=%s; Form=%s; Object=%s; UUID=%s; Name=%s; Serial=%s; TypeUUID=%s; TypeName=%s; Time=%s',
    [AAction, 'fuDeviceSelect', 'Device', string(ADevice.UUID), ADevice.Name, ADevice.SerialNumber,
     string(ADevice.DeviceTypeUUID), ADevice.DeviceTypeName, FormatDateTime('dd.mm.yyyy hh:nn:ss', Now)]);
  if Trim(ADetails) <> '' then
    Details := Details + '; ' + ADetails;

  ProtocolManager.AddMessage(pcInfo, psForm, 'DeviceAction', 'Действие с прибором', Details);
end;

procedure TFormDeviceSelect.LogDuplicateDeviceUUIDs;
var
  I: Integer;
  D: TDevice;
  UUIDMap: TDictionary<string, Integer>;
  U: string;
begin
  if (ProtocolManager = nil) or (FDevices = nil) then
    Exit;
  UUIDMap := TDictionary<string, Integer>.Create;
  try
    for I := 0 to FDevices.Count - 1 do
    begin
      D := FDevices[I];
      if D = nil then
        Continue;
      U := Trim(string(D.UUID));
      if U = '' then
        Continue;
      if UUIDMap.ContainsKey(U) then
        UUIDMap[U] := UUIDMap[U] + 1
      else
        UUIDMap.Add(U, 1);
    end;
    for U in UUIDMap.Keys do
      if UUIDMap[U] > 1 then
        ProtocolManager.AddMessage(
          pcError, psForm, 'DeviceActionError', 'Обнаружены дубли UUID приборов',
          Format('Action=%s; Form=%s; UUID=%s; TypeUUID=%s; Count=%d; Time=%s',
            ['DuplicateUUID', 'fuDeviceSelect', U, '-', UUIDMap[U], FormatDateTime('dd.mm.yyyy hh:nn:ss', Now)]));
  finally
    UUIDMap.Free;
  end;
end;

procedure TFormDeviceSelect.LoadData;
begin
  {--------------------------------------------------}
  { Проверяем наличие активного репозитория приборов }
  {--------------------------------------------------}
  if (AppServices.DataManager = nil) or (AppServices.DataManager.ActiveDeviceRepo = nil) then
  begin
    ActiveRepo := nil;
    FDevices := nil;
    Exit;
  end;

  ActiveRepo := AppServices.DataManager.ActiveDeviceRepo;

  {--------------------------------------------------}
  { Не перезагружаем уже открытый репозиторий при простом открытии формы:
    каналы GridDevices держат ссылки на приборы из него, а повторный Load
    пересоздаёт объекты и может визуально менять UUID при Cancel/Close. }
  {--------------------------------------------------}
  if not (ActiveRepo.State in [osLoaded, osClean, osModified]) then
    ActiveRepo.Load;

  {--------------------------------------------------}
  { Берём ссылку на данные репозитория }
  {--------------------------------------------------}
  FDevices := ActiveRepo.Devices;
  LogDuplicateDeviceUUIDs;
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
  if AppServices.DataManager = nil then
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

  if AppServices.DataManager.RepositoryNameExists(RepoName) then
  begin
    ShowMessage(Format(
      'Репозиторий с именем "%s" уже существует. Создание отменено.',
      [RepoName]
    ));
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
    Dlg.InitialDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Devices';

    ForceDirectories(Dlg.InitialDir);

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
  AppServices.DataManager.AddRepository(
    RepoName,
    rkDevice,
    DBFileName
  );

  {----------------------------------}
  { Пересборка UI }
  {----------------------------------}
  LoadData;              // берёт данные из ActiveDeviceRepo

  FillComboBoxRepository;
  TreeViewDevices.Clear;
  TreeViewDevices.Clear;
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;
  ClearCheckedDevices;
end;

procedure TFormDeviceSelect.miAddTestDataClick(Sender: TObject);
begin
  AppServices.DataManager.ActiveDeviceRepo.InitBulkTestData;
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
  if (AppServices.DataManager = nil) or (AppServices.DataManager.ActiveDeviceRepo = nil) then
    Exit;

  Repo := AppServices.DataManager.ActiveDeviceRepo;

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
  AppServices.DataManager.RemoveRepository(Repo.Name);

  {----------------------------------}
  { Обновление UI }
  {----------------------------------}
  FillComboBoxRepository;

  if AppServices.DataManager.ActiveDeviceRepo <> nil then
  begin
    LoadData;        // заново загружает данные активного репозитория
    TreeViewDevices.Clear;
    TreeViewDevices.Clear;
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

  if AppServices.DataManager.ActiveDeviceRepo = nil then
    Exit;

  try
    // TWaitCursor.Create;

    if not AppServices.DataManager.ActiveDeviceRepo.Load then
      raise Exception.Create('Не удалось загрузить приборы');

    FullRefreshDevicesView;

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
  if AppServices.DataManager = nil then
    Exit;

  {----------------------------------}
  { Диалог открытия файла БД }
  {----------------------------------}
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Title := 'Открыть файл репозитория приборов';
    Dlg.Filter := 'SQLite database (*.db)|*.db|Все файлы (*.*)|*.*';
    Dlg.Options := [TOpenOption.ofFileMustExist];
    Dlg.InitialDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Devices';

    ForceDirectories(Dlg.InitialDir);

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
  AppServices.DataManager.AddRepository(
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
  UpdateDeviceActions(nil);
end;



procedure TFormDeviceSelect.miSaveClick(Sender: TObject);
var
  Repo: TDeviceRepository;
begin
  Repo := AppServices.DataManager.ActiveDeviceRepo;
  if Repo = nil then
    Exit;

  try
    // TWaitCursor.Create;

    if not Repo.Save then
      raise Exception.Create('Не удалось сохранить изменения приборов');

    FullRefreshDevicesView;

    ShowMessage('Изменения успешно сохранены');
  finally
    // Screen.Cursor := crDefault;
  end;
end;

procedure TFormDeviceSelect.BuildTree;
var
  D: TDevice;

  AllNode, ManNode, CatNode, ModNode: TTreeViewItem;
  PrevSelectedNode, RestoredNode: TTreeViewItem;
  PrevNodeText, PrevNodeTagString, PrevNodePath: string;
  PrevNodeTag: NativeInt;
  PrevExpandedPaths: TStringList;
  ManText, ManKey: string;
  CatText, CatKey: string;
  ModText, ModKey: string;
  CategoryText:String;
  ManPass: Integer;
  I: Integer;
  function BuildNodePath(const ANode: TTreeViewItem): string;
  var
    Cur: TTreeViewItem;
  begin
    Result := '';
    Cur := ANode;
    while Cur <> nil do
    begin
      if Result = '' then
        Result := IntToStr(Cur.Tag) + '|' + NormalizeTreeKey(Cur.TagString) + '|' + Cur.Text
      else
        Result := IntToStr(Cur.Tag) + '|' + NormalizeTreeKey(Cur.TagString) + '|' + Cur.Text + '/' + Result;
      Cur := Cur.ParentItem;
    end;
  end;
  procedure FindNodeRecursive(const ANode: TTreeViewItem);
  var
    J: Integer;
    ChildNode: TTreeViewItem;
  begin
    if (ANode = nil) or (RestoredNode <> nil) then
      Exit;
    if (ANode.Tag = PrevNodeTag)
      and (NormalizeTreeKey(ANode.TagString) = NormalizeTreeKey(PrevNodeTagString))
      and (ANode.Text = PrevNodeText)
      and ((PrevNodePath = '') or (BuildNodePath(ANode) = PrevNodePath)) then
    begin
      RestoredNode := ANode;
      Exit;
    end;
    for J := 0 to ANode.Count - 1 do
      if ANode.ItemByIndex(J) is TTreeViewItem then
      begin
        ChildNode := TTreeViewItem(ANode.ItemByIndex(J));
        FindNodeRecursive(ChildNode);
        if RestoredNode <> nil then
          Exit;
      end;
  end;
  procedure CollectExpandedNodes(const ANode: TTreeViewItem);
  var
    J: Integer;
    ChildNode: TTreeViewItem;
  begin
    if ANode = nil then
      Exit;
    if ANode.IsExpanded then
      PrevExpandedPaths.Add(BuildNodePath(ANode));
    for J := 0 to ANode.Count - 1 do
      if ANode.ItemByIndex(J) is TTreeViewItem then
      begin
        ChildNode := TTreeViewItem(ANode.ItemByIndex(J));
        CollectExpandedNodes(ChildNode);
      end;
  end;
  procedure RestoreExpandedNodes(const ANode: TTreeViewItem);
  var
    J: Integer;
    ChildNode: TTreeViewItem;
  begin
    if ANode = nil then
      Exit;
    if PrevExpandedPaths.IndexOf(BuildNodePath(ANode)) >= 0 then
      ANode.Expand;
    for J := 0 to ANode.Count - 1 do
      if ANode.ItemByIndex(J) is TTreeViewItem then
      begin
        ChildNode := TTreeViewItem(ANode.ItemByIndex(J));
        RestoreExpandedNodes(ChildNode);
      end;
  end;
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
    PrevExpandedPaths := TStringList.Create;
    PrevExpandedPaths.Sorted := True;
    PrevExpandedPaths.Duplicates := TDuplicates.dupIgnore;
    for I := 0 to TreeViewDevices.Count - 1 do
      CollectExpandedNodes(TreeViewDevices.ItemByIndex(I));

    PrevSelectedNode := GetActiveTreeNode;
    PrevNodeText := '';
    PrevNodeTagString := '';
    PrevNodeTag := -1;
    PrevNodePath := '';
    if PrevSelectedNode <> nil then
    begin
      PrevNodeText := PrevSelectedNode.Text;
      PrevNodeTagString := NormalizeTreeKey(PrevSelectedNode.TagString);
      PrevNodeTag := PrevSelectedNode.Tag;
      PrevNodePath := BuildNodePath(PrevSelectedNode);
    end;
    //TreeViewDevices.Clear;

    {----------------------------------}
    { Корневой узел }
    {----------------------------------}
    if (TreeViewDevices.Count = 0) or (TreeViewDevices.Items[0].Tag <> Ord(tnAll)) then
    begin
      AllNode := TTreeViewItem.Create(TreeViewDevices);
      AllNode.Text := '...';
      AllNode.Tag := Ord(tnAll);
      AllNode.TagString := '';
      TreeViewDevices.AddObject(AllNode);
    end ;


    {----------------------------------}
    { Проход по изготовителям }
    { ManPass = 0 → заполненные }
    { ManPass = 1 → пустые }
    {----------------------------------}
    for ManPass := 0 to 1 do
    begin
      for D in FDevices do
      begin
        if D.State = osDeleted then
          Continue;

        if (Trim(D.Manufacturer) = '') xor (ManPass = 1) then
          Continue;

        {========== ИЗГОТОВИТЕЛЬ =========}
        if Trim(D.Manufacturer) <> '' then
        begin
          ManText := D.Manufacturer;
          ManKey  := NormalizeTreeKey(D.Manufacturer);
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

        {========== КАТЕГОРИИ > 0 =========}
        if D.Category > 0 then
        begin
          CategoryText := GetDeviceCategoryText(D, True);
          if Trim(CategoryText) <> '' then
            CatText := CategoryText
          else
            CatText := ActiveRepo.CategoryToText(D.Category, D.CategoryName);
          CatKey := IntToStr(D.Category);
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
            ModKey  := NormalizeTreeKey(D.Modification);
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
    end;

    {----------------------------------}
    { Второй проход: Category <= 0 }
    {----------------------------------}
    for D in FDevices do
    begin
      if D.State = osDeleted then
        Continue;

      if D.Category > 0 then
        Continue;

      ManKey := NormalizeTreeKey(D.Manufacturer);
      ManNode := FindChildInTree(
        TreeViewDevices,
        Ord(tnManufacturer),
        ManKey
      );

      if ManNode = nil then
        Continue;

      CatText := '<категория>';
      CatKey  := IntToStr(D.Category); // -1 / 0

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

      if Trim(D.Modification) <> '' then
      begin
        ModText := D.Modification;
        ModKey  := NormalizeTreeKey(D.Modification);
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

    //TreeViewDevices.Selected := AllNode;

    RestoredNode := nil;
    if PrevSelectedNode <> nil then
      for I := 0 to TreeViewDevices.Count - 1 do
      begin
        FindNodeRecursive(TreeViewDevices.ItemByIndex(I));
        if RestoredNode <> nil then
          Break;
      end;

    if RestoredNode <> nil then
      TreeViewDevices.Selected := RestoredNode
    else
      TreeViewDevices.Selected := AllNode;

    for I := 0 to TreeViewDevices.Count - 1 do
      RestoreExpandedNodes(TreeViewDevices.ItemByIndex(I));
  finally
    PrevExpandedPaths.Free;
    TreeViewDevices.EndUpdate;
  end;
end;

procedure TFormDeviceSelect.ButtonDeviceAddClick(Sender: TObject);
var

  SrcDevice: TDevice;
  SelRow: Integer;
  NewDevice: TDevice;
  NewRow: Integer;
  SelectedTreeNode: TTreeViewItem;
  HasGridSelection: Boolean;
  SelectedNodeTag: Integer;
begin
  {--------------------------------------------------}
  { Если нет активного репозитория — некуда добавлять }
  {--------------------------------------------------}
  if (AppServices.DataManager = nil) or (ActiveRepo = nil) then
    Exit;

  {--------------------------------------------------}
  { 1. Формируем новый прибор }
  {--------------------------------------------------}

  {--------------------------------------------------}
  { 2. Если есть выделенная строка — копируем её }
  {--------------------------------------------------}


  SelRow := GridDevices.Row;
  SrcDevice := nil;
  SelectedTreeNode := GetActiveTreeNode;

  HasGridSelection :=
    (FDevFilteredDevices <> nil) and
    (SelRow >= 0) and
    (SelRow < FDevFilteredDevices.Count);

  if HasGridSelection then
    SrcDevice := FDevFilteredDevices[SelRow];

  if SelectedTreeNode <> nil then
    SelectedNodeTag := SelectedTreeNode.Tag
  else
    SelectedNodeTag := Ord(tnAll);

  if (SrcDevice <> nil) and (SelectedNodeTag = Ord(tnModification)) then
    NewDevice := TDeviceCreationService.CreateDevice(ActiveRepo, dcmUserCreated, SrcDevice)
  else
    NewDevice := TDeviceCreationService.CreateDevice(ActiveRepo, dcmUserCreated, nil);

  if SrcDevice <> nil then
  begin
    case SelectedNodeTag of
      Ord(tnManufacturer):
        begin
          NewDevice.Manufacturer := SrcDevice.Manufacturer;
          NewDevice.Name := SrcDevice.Name;
          NewDevice.AccuracyClass := '';
          NewDevice.VerificationMethod := '';
          NewDevice.ProcedureName := '';
        end;

      Ord(tnCategory):
        begin
          NewDevice.Manufacturer := SrcDevice.Manufacturer;
          NewDevice.Category := SrcDevice.Category;
          NewDevice.CategoryName := SrcDevice.CategoryName;
          NewDevice.Name := SrcDevice.Name;
          NewDevice.AccuracyClass := '';
          NewDevice.VerificationMethod := '';
          NewDevice.ProcedureName := '';
        end;
    else
    end;
  end;

  BuildTree;

  {--------------------------------------------------}
  { 3. Обновляем ТОЛЬКО фильтрованные списки }
  {--------------------------------------------------}
  ApplyFilter; // Tree → Text → Date → Sort

  UpdateGridDevices;

  {--------------------------------------------------}
  { 4. Выделяем добавленную строку }
  {--------------------------------------------------}
  GridDevices.Row := -1;
  if (NewDevice <> nil) and (FDevFilteredDevices <> nil) then
    for NewRow := 0 to FDevFilteredDevices.Count - 1 do
      if FDevFilteredDevices[NewRow] = NewDevice then
      begin
        GridDevices.Row := NewRow;
        Break;
      end;

  if (GridDevices.Row < 0) and (GridDevices.RowCount > 0) then
    GridDevices.Row := GridDevices.RowCount - 1;

  LogDuplicateDeviceUUIDs;
end;

procedure TFormDeviceSelect.aCreateTypeExecute(Sender: TObject);
begin
  ButtonDeviceAddClick(Sender);
end;

procedure TFormDeviceSelect.CornerButton1Click(Sender: TObject);
begin
  if (FDevFilteredDevices = nil) or (GridDevices.Row < 0) or (GridDevices.Row >= FDevFilteredDevices.Count) then
    Exit;

  ModalResult := mrOk;
end;

procedure TFormDeviceSelect.actDeviceSelectExecute(Sender: TObject);
begin
  if not IsGridInputFocused then
    Exit;

  if (FDevFilteredDevices = nil) or (GridDevices.Row < 0) or (GridDevices.Row >= FDevFilteredDevices.Count) then
    Exit;

  ModalResult := mrOk;
end;

procedure TFormDeviceSelect.aDeleteTypeExecute(Sender: TObject);
var
  TargetDevices: TObjectList<TDevice>;
  D: TDevice;
  DeviceUUID: string;
begin
  {----------------------------------}
  { Проверка списка }
  {----------------------------------}
  if (FDevFilteredDevices = nil) or (FDevFilteredDevices.Count = 0) then
    Exit;

  TargetDevices := GetSelectedDevices;
  try
    if TargetDevices.Count = 0 then
      Exit;

    {----------------------------------}
    { Мягкое удаление по аналогии с TypeSelect }
    {----------------------------------}
    WriteDeviceActionLog('Удалён прибор', TargetDevices[0], Format('Count=%d', [TargetDevices.Count]));

    for D in TargetDevices do
    begin
      if D = nil then
        Continue;

      DeviceUUID := Trim(D.UUID);
      if DeviceUUID <> '' then
        FDeletedDeviceUUIDs.Add(DeviceUUID);

      if ActiveRepo <> nil then
        ActiveRepo.DeleteDevice(D);
    end;

    BuildTree;
    ApplyFilter;
    UpdateGridDevices;

    {----------------------------------}
    { Сброс выделения }
    {----------------------------------}
    GridDevices.Row := -1;
    ClearCheckedDevices;
    UpdateDeviceActions(nil);
  finally
    TargetDevices.Free;
  end;
end;

procedure TFormDeviceSelect.aEditTypeExecute(Sender: TObject);
  var
  Row: Integer;
  ADevice: TDevice;
  OldManufacturer: string;
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
  WriteDeviceActionLog('Выбран прибор', ADevice);
  OldManufacturer := ADevice.Manufacturer;
  if OpenDeviceEditor(ADevice) then
  begin
    if (AppServices.DataManager <> nil) and
       (OldManufacturer <> ADevice.Manufacturer) then
      AppServices.DataManager.NeedRemoveOldManufacturerBranchForDevice(
        FDevices, ADevice, OldManufacturer, ADevice.Manufacturer
      );

    SelectEditedDevice(ADevice);
  end;
end;

procedure TFormDeviceSelect.aDeviceCopyExecute(Sender: TObject);
var
  TargetDevices: TObjectList<TDevice>;
begin
  TargetDevices := GetSelectedDevices;
  try
    AppServices.DataManager.CopyDevicesToBuffer(TargetDevices);
    if TargetDevices.Count > 0 then
      WriteDeviceActionLog('Скопирован прибор', TargetDevices[0]);
  finally
    TargetDevices.Free;
  end;
end;

procedure TFormDeviceSelect.aDeviceCutExecute(Sender: TObject);
var
  TargetDevices: TObjectList<TDevice>;
  D: TDevice;
begin
  if (FDevFilteredDevices = nil) or (FDevFilteredDevices.Count = 0) then
    Exit;

  TargetDevices := GetSelectedDevices;
  try
    if TargetDevices.Count = 0 then
      Exit;

    AppServices.DataManager.CopyDevicesToBuffer(TargetDevices);

    for D in TargetDevices do
    begin
      if D = nil then
        Continue;

      if Trim(D.UUID) <> '' then
        FDeletedDeviceUUIDs.Add(Trim(D.UUID));

      if ActiveRepo <> nil then
        ActiveRepo.DeleteDevice(D);
    end;

    WriteDeviceActionLog('Вырезан прибор', TargetDevices[0]);
  finally
    TargetDevices.Free;
  end;

  SyncTreeAfterGridRowsRemoved;
  BuildTree;
  ApplyFilter;
  UpdateGridDevices;
  ClearCheckedDevices;
  GridDevices.Row := -1;
  UpdateDeviceActions(nil);
end;

procedure TFormDeviceSelect.aDevicePasteExecute(Sender: TObject);
var
  SelectedNode: TTreeViewItem;
  NewRows: TObjectList<TDevice>;
  RestoredNode: TTreeViewItem;
  I: Integer;
  procedure FindNodeRecursive(const ANode: TTreeViewItem);
  var
    J: Integer;
    ChildNode: TTreeViewItem;
  begin
    if (ANode = nil) or (RestoredNode <> nil) then
      Exit;

    if (SelectedNode <> nil)
      and (ANode.Tag = SelectedNode.Tag)
      and (NormalizeTreeKey(ANode.TagString) = NormalizeTreeKey(SelectedNode.TagString)) then
    begin
      RestoredNode := ANode;
      Exit;
    end;

    for J := 0 to ANode.Count - 1 do
      if ANode.ItemByIndex(J) is TTreeViewItem then
      begin
        ChildNode := TTreeViewItem(ANode.ItemByIndex(J));
        FindNodeRecursive(ChildNode);
        if RestoredNode <> nil then
          Exit;
      end;
  end;
begin
  if (ActiveRepo = nil) or (AppServices.DataManager = nil) or (not AppServices.DataManager.HasBufferDevices) then
    Exit;

  SelectedNode := GetActiveTreeNode;

  // UI-слой: передаём выбранный узел, вставка выполняется в DataManager.
  NewRows := AppServices.DataManager.PasteBufferDevices(SelectedNode);
  try
    if (NewRows <> nil) and (NewRows.Count > 0) then
      WriteDeviceActionLog('Вставлен прибор', NewRows[0], Format('Count=%d', [NewRows.Count]));
  finally
    NewRows.Free;
  end;

  ApplyFilter;
  UpdateGridDevices;
  BuildTree;
  LogDuplicateDeviceUUIDs;
end;

function TFormDeviceSelect.GetActiveTreeNode: TTreeViewItem;
var
  BestDepth: Integer;
  procedure CheckCandidate(const ACandidate: TTreeViewItem);
  var
    CurDepth: Integer;
    Parent: TTreeViewItem;
    J: Integer;
    ChildNode: TTreeViewItem;
  begin
    if ACandidate = nil then
      Exit;

    if ACandidate.IsSelected then
    begin
      CurDepth := 0;
      Parent := ACandidate.ParentItem;
      while Parent <> nil do
      begin
        Inc(CurDepth);
        Parent := Parent.ParentItem;
      end;

      // При множественном выборе берём наиболее глубокий выбранный узел,
      // чтобы подветка имела приоритет над родительской веткой.
      if CurDepth >= BestDepth then
      begin
        BestDepth := CurDepth;
        Result := ACandidate;
      end;
    end;

    // Обходим всё дерево рекурсивно, а не только корневые элементы.
    for J := 0 to ACandidate.Count - 1 do
      if ACandidate.ItemByIndex(J) is TTreeViewItem then
      begin
        ChildNode := TTreeViewItem(ACandidate.ItemByIndex(J));
        CheckCandidate(ChildNode);
      end;
  end;
var
  I: Integer;
  CurDepth: Integer;
  Parent: TTreeViewItem;
begin
  Result := TreeViewDevices.Selected;
  BestDepth := -1;

  if Result <> nil then
  begin
    CurDepth := 0;
    Parent := Result.ParentItem;
    while Parent <> nil do
    begin
      Inc(CurDepth);
      Parent := Parent.ParentItem;
    end;
    BestDepth := CurDepth;
  end;

  for I := 0 to TreeViewDevices.Count - 1 do
    CheckCandidate(TreeViewDevices.ItemByIndex(I));
end;

procedure TFormDeviceSelect.UpdateDeviceActions(Sender: TObject);
var
  HasRepo: Boolean;
  HasRows: Boolean;
  HasGridFocus: Boolean;
  HasSelectedRow: Boolean;
begin
  HasRepo := (AppServices.DataManager <> nil) and (ActiveRepo <> nil);
  HasRows := (FDevFilteredDevices <> nil) and (FDevFilteredDevices.Count > 0);
  HasGridFocus := GridDevices.Row>=0;// IsGridInputFocused;
  HasSelectedRow :=
    HasRows and
    HasGridFocus and
    (GridDevices.Row >= 0) and
    (GridDevices.Row < FDevFilteredDevices.Count);

  aCreateType.Enabled := HasRepo;
  aEditType.Enabled := HasSelectedRow;
  aDeleteType.Enabled := HasSelectedRow;
  aDeviceCopy.Enabled := HasRows;
  aDeviceCut.Enabled := HasRepo and HasRows;
  aDevicePaste.Enabled := HasRepo and (AppServices.DataManager <> nil) and AppServices.DataManager.HasBufferDevices;

  CornerButtonEditDevice.Enabled := aEditType.Enabled;
  CornerButton1.Enabled := HasSelectedRow;
end;

function TFormDeviceSelect.GetSelectedDevices: TObjectList<TDevice>;
var
  I: Integer;
  CheckedDevices: TObjectList<TDevice>;
  SelectedDevice: TDevice;
begin
  Result := TObjectList<TDevice>.Create(False);

  CheckedDevices := GetCheckedDevices;
  try
    if CheckedDevices.Count > 0 then
    begin
      for I := 0 to CheckedDevices.Count - 1 do
        Result.Add(CheckedDevices[I]);
      Exit;
    end;
  finally
    CheckedDevices.Free;
  end;

  SelectedDevice := GetSelectedDevice;
  if SelectedDevice <> nil then
  begin
    Result.Add(SelectedDevice);
    Exit;
  end;

  if FDevFilteredDevices = nil then
    Exit;

  for I := 0 to FDevFilteredDevices.Count - 1 do
    Result.Add(FDevFilteredDevices[I]);
end;

function TFormDeviceSelect.IsGridInputFocused: Boolean;
var
  Ref: IInterfaceComponentReference;
begin
  Result := False;

  if (GridDevices = nil) or (not GridDevices.IsFocused) then
    Exit;

  if ActiveControl = nil then
    Exit;

  if not Supports(ActiveControl, IInterfaceComponentReference, Ref) then
    Exit;

  Result := Ref.GetComponent = GridDevices;
end;

procedure TFormDeviceSelect.ClearCheckedDevices;
begin
  if FCheckedDevices <> nil then
    FCheckedDevices.Clear;
end;

function TFormDeviceSelect.GetCheckedDevices: TObjectList<TDevice>;
var
  I: Integer;
  ADevice: TDevice;
begin
  Result := TObjectList<TDevice>.Create(False);
  if (FCheckedDevices = nil) or (FDevFilteredDevices = nil) then
    Exit;

  for I := 0 to FCheckedDevices.Count - 1 do
  begin
    ADevice := FCheckedDevices[I];
    if (ADevice <> nil) and (FDevFilteredDevices.IndexOf(ADevice) >= 0) then
      Result.Add(ADevice);
  end;
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
    begin
      if Trim(D.UUID) <> '' then
        FDeletedDeviceUUIDs.Add(Trim(D.UUID));
      ActiveRepo.DeleteDevice(D);
    end;
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
  ClearCheckedDevices;
end;

procedure TFormDeviceSelect.ButtonDeviceDeleteClick(Sender: TObject);
begin
  aDeleteTypeExecute(Sender);
end;

procedure TFormDeviceSelect.SyncTreeAfterGridRowsRemoved;
var
  I, J, NodeIndex: Integer;
  SelectedNode, ParentNode, ReplacementNode, CurrentNode: TTreeViewItem;
  SectionHasDevices: Boolean;
  function PassTreeFilterForNode(const ADevice: TDevice; const ANode: TTreeViewItem): Boolean;
  var
    PrevSelected: TTreeViewItem;
  begin
    PrevSelected := TreeViewDevices.Selected;
    TreeViewDevices.Selected := ANode;
    try
      Result := PassTreeFilter(ADevice);
    finally
      TreeViewDevices.Selected := PrevSelected;
    end;
  end;
begin
  SelectedNode := GetActiveTreeNode;
  if (SelectedNode = nil) or (SelectedNode.Tag = Ord(tnAll)) then
    Exit;

  SectionHasDevices := False;
  if FDevices <> nil then
    for I := 0 to FDevices.Count - 1 do
      if PassTreeFilterForNode(FDevices[I], SelectedNode) then
      begin
        SectionHasDevices := True;
        Break;
      end;

  if SectionHasDevices then
    Exit;

  ParentNode := SelectedNode.ParentItem;
  ReplacementNode := nil;
  if ParentNode <> nil then
  begin
    NodeIndex := -1;
    for J := 0 to ParentNode.Count - 1 do
      if ParentNode.ItemByIndex(J) = SelectedNode then
      begin
        NodeIndex := J;
        Break;
      end;

    if (NodeIndex > 0) and (ParentNode.ItemByIndex(NodeIndex - 1) is TTreeViewItem) then
      ReplacementNode := TTreeViewItem(ParentNode.ItemByIndex(NodeIndex - 1))
    else if (NodeIndex >= 0) and (NodeIndex < ParentNode.Count - 1)
      and (ParentNode.ItemByIndex(NodeIndex + 1) is TTreeViewItem) then
      ReplacementNode := TTreeViewItem(ParentNode.ItemByIndex(NodeIndex + 1));
    ParentNode.RemoveObject(SelectedNode);
  end
  else
    TreeViewDevices.RemoveObject(SelectedNode);
  SelectedNode.DisposeOf;

  CurrentNode := ParentNode;
  while (CurrentNode <> nil) and (CurrentNode.Tag <> Ord(tnAll)) and (CurrentNode.Count = 0) do
  begin
    SectionHasDevices := False;
    if FDevices <> nil then
      for I := 0 to FDevices.Count - 1 do
        if PassTreeFilterForNode(FDevices[I], CurrentNode) then
        begin
          SectionHasDevices := True;
          Break;
        end;
    if SectionHasDevices then
      Break;

    ParentNode := CurrentNode.ParentItem;
    if ParentNode <> nil then
      ParentNode.RemoveObject(CurrentNode)
    else
      TreeViewDevices.RemoveObject(CurrentNode);
    CurrentNode.DisposeOf;
    CurrentNode := ParentNode;
  end;

  if (ReplacementNode <> nil) and (ReplacementNode.TreeView = TreeViewDevices) then
    TreeViewDevices.Selected := ReplacementNode
  else if (CurrentNode <> nil) and (CurrentNode.TreeView = TreeViewDevices) then
    TreeViewDevices.Selected := CurrentNode
  else if TreeViewDevices.Count > 0 then
    TreeViewDevices.Selected := TreeViewDevices.ItemByIndex(0)
  else
    TreeViewDevices.Selected := nil;
end;

procedure TFormDeviceSelect.ApplyFilter;
var
  SourceDevices: TObjectList<TDevice>;
  DateFilterEnabled: Boolean;
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
  DateFilterEnabled := (not DateEditFilter.IsEmpty) and (DateEditFilter.Date > 0);
  FDevFilteredByDate := TObjectList<TDevice>.Create(False);

  if (not DateFilterEnabled) or (FDevFilteredByText = nil) then
  begin
    if FDevFilteredByText <> nil then
      FDevFilteredByDate.AddRange(FDevFilteredByText);
  end
  else
    for var D in FDevFilteredByText do
      if (D.RegDate > 0) and (D.ValidityDate > 0) and
         (D.RegDate <= DateEditFilter.Date) and
         (DateEditFilter.Date <= D.ValidityDate) then
        FDevFilteredByDate.Add(D);

  {----------------------------------}
  { 4. Сортировка }
  {----------------------------------}
  FreeAndNil(FDevFilteredDevices);
  if FDevFilteredByDate = nil then
    FDevFilteredDevices := TObjectList<TDevice>.Create(False)
  else
    FDevFilteredDevices :=
      TEntitySorter<TDevice>.Sort(
        FDevFilteredByDate,
        Ord(ColumnToSortField(FSortColumn)),
        FSortAscending
      );
end;

procedure TFormDeviceSelect.aRefreshRepositoryExecute(Sender: TObject);
begin
  FullRefreshDevicesView;
end;

procedure TFormDeviceSelect.FullRefreshDevicesView;
begin
  RebuildTreeFull;
  ApplyFilter;
  UpdateGridDevices;
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
var
  I: Integer;
begin
  if FCheckedDevices <> nil then
    for I := FCheckedDevices.Count - 1 downto 0 do
      if (FDevFilteredDevices = nil) or (FDevFilteredDevices.IndexOf(FCheckedDevices[I]) < 0) then
        FCheckedDevices.Delete(I);

  GridDevices.BeginUpdate;
  try
    GridDevices.RowCount := 0;
    if FDevFilteredDevices <> nil then
      GridDevices.RowCount := FDevFilteredDevices.Count;
  finally
    GridDevices.EndUpdate;
  end;

  if (GridDevices.Row < 0) or (GridDevices.Row >= GridDevices.RowCount) then
    GridDevices.Row := -1;

  GridDevices.Repaint;
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


procedure TFormDeviceSelect.sbClearDateClick(Sender: TObject);
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

    if (AReestrNumber = '') or (AppServices.DataManager = nil) then
      Exit;

    for Repo in AppServices.DataManager.TypeRepositories do
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
            Dev.UUID := Item.GetValue('vri_id').Value;

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
            Dev.AttachType(FoundType, FoundRepo.Name);



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

            if AppServices.DataManager.ActiveTypeRepo <> nil then
              Dev.Category := AppServices.DataManager.ActiveTypeRepo.DetectCategoryByKeywords(DetectText);
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

  { Выбор строки в гриде должен быть явным: при выборе ветки работаем со всей веткой. }
  GridDevices.Row := -1;
end;

procedure TFormDeviceSelect.ClearGridSelection;
begin
  GridDevices.Row := -1;
  TreeViewDevices.SetFocus;
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
  if AppServices.DataManager = nil then
    Exit;

  {----------------------------------}
  { Проверка активного репозитория приборов }
  {----------------------------------}
  if AppServices.DataManager.ActiveDeviceRepo = nil then
    Exit;

  {----------------------------------}
  { Проверка данных репозитория }
  {----------------------------------}
  if AppServices.DataManager.ActiveDeviceRepo.Devices = nil then
    Exit;

  {----------------------------------}
  { Обновляем ссылку на данные }
  {----------------------------------}
  ActiveRepo := AppServices.DataManager.ActiveDeviceRepo;
  FDevices := ActiveRepo.Devices;

  Result := True;
end;

procedure TFormDeviceSelect.RebuildTreeFull;
begin
  TreeViewDevices.BeginUpdate;
  try
    TreeViewDevices.Clear;
  finally
    TreeViewDevices.EndUpdate;
  end;

  BuildTree;
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
    if (AppServices.DataManager <> nil) and (AppServices.DataManager.ActiveTypeRepo <> nil) then
      Result := AppServices.DataManager.ActiveTypeRepo.CategoryToText(ADevice.Category, ADevice.CategoryName)
    else if AppServices.DataManager <> nil then
    begin
      C := AppServices.DataManager.FindCategoryByID(ADevice.Category);
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
    ManKey := NormalizeTreeKey(ADevice.Manufacturer)
  else
    ManKey := '';

  ManNode := FindChildInTree(TreeViewDevices, Ord(tnManufacturer), ManKey);
  if ManNode = nil then
    Exit;

  if ADevice.Category <> 0 then
    CatKey := IntToStr(ADevice.Category)
  else
    CatKey := '';
  CatNode := FindChildInNode(ManNode, Ord(tnCategory), CatKey);
  if CatNode = nil then
    Exit(ManNode);

  if Trim(ADevice.Modification) <> '' then
    ModKey := NormalizeTreeKey(ADevice.Modification)
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
  ParentNode: TTreeViewItem;
  I: Integer;
  FoundRow: Boolean;
begin
  BuildTree;
  Node := FindDeviceTreeNode(ADevice);

  if Node <> nil then
  begin
    ClearTreeSelectionFlags;
    TreeViewDevices.CollapseAll;

    ParentNode := Node.ParentItem;
    while ParentNode <> nil do
    begin
      ParentNode.Expand;
      ParentNode := ParentNode.ParentItem;
    end;

    Node.IsSelected := True;
    TreeViewDevices.Selected := Node;
  end;

  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(FDevices);

  ApplyFilter;
  UpdateGridDevices;



  GridDevices.Row := -1;
  if FDevFilteredDevices = nil then
    Exit;

  FoundRow := False;
  for I := 0 to FDevFilteredDevices.Count - 1 do
    if FDevFilteredDevices[I] = ADevice then
    begin
      GridDevices.Row := I;
      GridDevices.Selected := I;
      FoundRow := True;
      Break;
    end;

  if FoundRow and (GridDevices <> nil) and GridDevices.Visible then
    GridDevices.SetFocus;

end;

procedure TFormDeviceSelect.ClearTreeSelectionFlags;
  procedure ClearNodeRecursive(const ANode: TTreeViewItem);
  var
    J: Integer;
  begin
    if ANode = nil then
      Exit;
    ANode.IsSelected := False;
    for J := 0 to ANode.Count - 1 do
      if ANode.ItemByIndex(J) is TTreeViewItem then
        ClearNodeRecursive(TTreeViewItem(ANode.ItemByIndex(J)));
  end;
var
  I: Integer;
begin
  TreeViewDevices.BeginUpdate;
  try
    for I := 0 to TreeViewDevices.Count - 1 do
      ClearNodeRecursive(TreeViewDevices.ItemByIndex(I));
    TreeViewDevices.Selected := nil;
  finally
    TreeViewDevices.EndUpdate;
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

  if ADevice.State = osDeleted then
    Exit(False);

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
          if NormalizeTreeKey(ADevice.Manufacturer) <> NormalizeTreeKey(Cur.TagString) then
            Exit(False);
        end;

      {---------- КАТЕГОРИЯ (ПО ID) ----------}
      Ord(tnCategory):
        begin
          // TagString = '' → без категории,
          // иначе TagString хранит числовой ID категории.
          if ADevice.Category <> 0 then
          begin
            if IntToStr(ADevice.Category) <> Cur.TagString then
              Exit(False);
          end
          else if Cur.TagString <> '' then
            Exit(False);
        end;

      {---------- МОДИФИКАЦИЯ ----------}
      Ord(tnModification):
        begin
          // TagString = '' → пустая модификация
          if NormalizeTreeKey(ADevice.Modification) <> NormalizeTreeKey(Cur.TagString) then
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

  else if ACol = StringColumnSerial.Index then
    Result := dsfSerialNumber

  else if ACol = StringColumnCategory.Index then
    Result := dsfCategory

  else if ACol = StringColumnManufacturer.Index then
    Result := dsfManufacturer

  else if ACol = StringColumnOwner.Index then
    Result := dsfOwner

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

  else if ACol = StringColumnDateOfManufacture.Index then
    Result := dsfDateOfManufacture

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
  if AppServices.DataManager = nil then
    Exit;

  Idx := ComboBoxRepository.ItemIndex;
  if Idx < 0 then
    Exit;

  RepoName := ComboBoxRepository.Items[Idx];

  {----------------------------------}
  { Смена активного репозитория через менеджер }
  {----------------------------------}
  AppServices.DataManager.SetActiveDeviceRepository(RepoName);

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




procedure TFormDeviceSelect.DateEditFilterChange(Sender: TObject);
var
  DateFilterEnabled: Boolean;
begin
  {----------------------------------}
  { Фильтр по дате поверх текста }
  {----------------------------------}
  FreeAndNil(FDevFilteredByDate);
  DateFilterEnabled := (not DateEditFilter.IsEmpty) and (DateEditFilter.Date > 0);
  FDevFilteredByDate := TObjectList<TDevice>.Create(False);

  if (not DateFilterEnabled) or (FDevFilteredByText = nil) then
  begin
    if FDevFilteredByText <> nil then
      FDevFilteredByDate.AddRange(FDevFilteredByText);
  end
  else
    for var D in FDevFilteredByText do
      if (D.RegDate > 0) and (D.ValidityDate > 0) and
         (D.RegDate <= DateEditFilter.Date) and
         (DateEditFilter.Date <= D.ValidityDate) then
        FDevFilteredByDate.Add(D);

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

    if AppServices.DataManager = nil then
      Exit;

    ItemIndex := -1;

    {----------------------------------}
    { Перебираем репозитории приборов }
    {----------------------------------}
    for Repo in AppServices.DataManager.DeviceRepositories do
    begin
      ComboBoxRepository.Items.Add(Repo.Name);

      {----------------------------------}
      { Запоминаем активный репозиторий }
      {----------------------------------}
      if Repo = AppServices.DataManager.ActiveDeviceRepo then
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
var
  Repo: TDeviceRepository;
  Res: TModalResult;
begin
  Repo := AppServices.DataManager.ActiveDeviceRepo;

  if ModalResult <> mrOk then
    Exit;

  if (Repo <> nil) and (Repo.State = osModified) then
  begin
    Res := MessageDlg(
      'Есть несохранённые изменения. Сохранить перед выходом?',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel],
      0
    );

    case Res of
      mrYes:
        begin
          try
            if not Repo.Save then
            begin
              Action := TCloseAction.caNone;
              Exit;
            end;
          except
            on E: Exception do
            begin
              ShowMessage('Ошибка сохранения: ' + E.Message);
              Action := TCloseAction.caNone;
              Exit;
            end;
          end;
        end;

      mrNo:
        begin
          { Откатываем изменения в памяти, чтобы вызывающая форма не считала
            несохранённо удалённые приборы реально удалёнными. }
          FDeletedDeviceUUIDs.Clear;
          if not Repo.Load then
          begin
            ShowMessage('Не удалось отменить несохранённые изменения приборов');
            Action := TCloseAction.caNone;
            Exit;
          end;
          LoadData;
          BuildTree;
          ApplyFilter;
          UpdateGridDevices;
        end;

      mrCancel:
        Action := TCloseAction.caNone;
    end;
  end;
end;

procedure TFormDeviceSelect.FormCreate(Sender: TObject);
begin
  OnKeyDown := FormKeyDown;
  GridDevices.OnKeyDown := GridDevicesKeyDown;
  GridDevices.OnMouseDown := GridDevicesMouseDown;
  GridDevices.OnEnter := GridDevicesEnter;
  GridDevices.OnExit := GridDevicesExit;

  {----------------------------------}
  { Инициализация сортировки }
  {----------------------------------}
  FSortColumn := -1;
  FSortAscending := True;
  FSkipDeviceDeleteConfirm := False;
  FCheckedDevices := TList<TDevice>.Create;

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
    ApplyInitialSelection;
  end;
end;

procedure TFormDeviceSelect.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkEscape) and IsGridInputFocused then
  begin
    ModalResult := mrCancel;
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TFormDeviceSelect.GridDevicesKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkEscape) and IsGridInputFocused then
  begin
    ModalResult := mrCancel;
    Key := 0;
    KeyChar := #0;
    Exit;
  end;

  if (Key = vkReturn) and (GridDevices.Row>=0) then
  begin
    ModalResult := mrOk;
    Key := 0;
    KeyChar := #0;
    Exit;
  end;

  if (Key = vkDelete) and (GridDevices.Row>=0) then
  begin
    aDeleteTypeExecute(aDeleteType);
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TFormDeviceSelect.GridDevicesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Col, Row: Integer;
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  if not GridDevices.CellByPoint(X, Y, Col, Row) then
    Exit;

  if (FDevFilteredDevices = nil) or (Row < 0) or (Row >= FDevFilteredDevices.Count) then
    Exit;

  if ssDouble in Shift then
    aEditTypeExecute(CornerButtonEditDevice) ;
    //CornerButtonEditDeviceClick(CornerButtonEditDevice);
end;

procedure TFormDeviceSelect.GridDevicesEnter(Sender: TObject);
begin
  UpdateDeviceActions(nil);
end;

procedure TFormDeviceSelect.GridDevicesExit(Sender: TObject);
begin
  UpdateDeviceActions(nil);
end;

procedure TFormDeviceSelect.ApplyInitialSelection;
var
  TargetUUID: string;
  I: Integer;
begin
  if (AppServices.DataManager = nil) or (ActiveRepo = nil) then
    Exit;

  TargetUUID := Trim(AppServices.DataManager.PendingSelectedDeviceUUID);
  AppServices.DataManager.PendingSelectedDeviceUUID := '';

  if TargetUUID = '' then
    Exit;

  for I := 0 to ActiveRepo.Devices.Count - 1 do
    if (ActiveRepo.Devices[I] <> nil) and SameText(ActiveRepo.Devices[I].UUID, TargetUUID) then
    begin
      SelectEditedDevice(ActiveRepo.Devices[I]);
      Exit;
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
  if ACol = CheckColumnDeviceEnable.Index then
    Value := FCheckedDevices.IndexOf(D) >= 0

  else if ACol = StringColumnName.Index then
    Value := D.Name

  else if ACol = StringColumnSerial.Index then
    Value := D.SerialNumber

  else if ACol = StringColumnHASH.Index then
    Value := D.UUID

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

  else if ACol = StringTemp.Index then
    Value := D.Temp

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

procedure TFormDeviceSelect.GridDevicesCellClick(const Column: TColumn;
  const Row: Integer);
var
  SelectedDevice: TDevice;
begin
  if (Column <> CheckColumnDeviceEnable) or (FDevFilteredDevices = nil) then
    Exit;

  if (Row < 0) or (Row >= FDevFilteredDevices.Count) then
    Exit;

  SelectedDevice := FDevFilteredDevices[Row];
  if SelectedDevice = nil then
    Exit;

  if FCheckedDevices.IndexOf(SelectedDevice) >= 0 then
    FCheckedDevices.Remove(SelectedDevice)
  else
    FCheckedDevices.Add(SelectedDevice);

  GridDevices.Row := Row;

  UpdateGridDevices;
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
