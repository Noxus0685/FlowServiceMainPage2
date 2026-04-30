unit fuTypeSelect;

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
  uRepositories;
type


  TFormTypeSelect = class(TForm)
    ActionList1: TActionList;
    actTypeAdd: TAction;
    actTypeEdit: TAction;
    actTypeDelete: TAction;
    LayoutLeft: TLayout;
    TreeViewTypes: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    LayoutRight: TLayout;
    GridTypes: TGrid;
    CheckColumnTypeEnable: TCheckColumn;
    StringColumnName: TStringColumn;
    StringColumnCategory: TStringColumn;
    StringColumnManufacturer: TStringColumn;
    StringColumnModification: TStringColumn;
    StringColumnReestrNumber: TStringColumn;
    StringColumnValidityDate: TStringColumn;
    StringColumnVerificationMethod: TStringColumn;
    StringColumnAccuracyClass: TStringColumn;
    EditFindType: TEdit;
    sbFind: TSpeedButton;
    lyt1: TLayout;
    btnOK: TCornerButton;
    MainMenu: TMenuBar;
    miFile: TMenuItem;
    miCreate: TMenuItem;
    miDelete: TMenuItem;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    StatusBar1: TStatusBar;
    sbDetaled: TLabel;
    CornerButtonSelectType: TCornerButton;
    CornerButtonEditType: TCornerButton;
    Splitter1: TSplitter;
    Label1: TLabel;
    Layout4: TLayout;
    StringColumnProcedure: TStringColumn;
    StringColumnRegDate: TStringColumn;
    StringColumnIVI: TStringColumn;
    DateEditFilter: TDateEdit;
    sbClear: TSpeedButton;
    Layout32: TLayout;
    ButtonTypeDelete: TButton;
    ButtonTypeAdd: TButton;
    ButtonTypeClear: TButton;
    ToolBar1: TToolBar;
    Line6: TLine;
    Layout2: TLayout;
    Layout3: TLayout;
    Line1: TLine;
    SpeedButtonFindInternet: TSpeedButton;
    NetHTTPClient1: TNetHTTPClient;
    MemoLog: TMemo;
    ToolBar2: TToolBar;
    ComboBoxRepository: TComboBox;
    Label2: TLabel;
    miService: TMenuItem;
    miAddRepository: TMenuItem;
    miDeleteRepository: TMenuItem;
    miLoadRepository: TMenuItem;
    miSave: TMenuItem;
    miRefreshRepository: TMenuItem;
    PopupMenu2: TPopupMenu;
    mpExpandAll: TMenuItem;
    mpCollapseAll: TMenuItem;
    mpRefresh: TMenuItem;
    miEdit: TMenuItem;
    miCopy: TMenuItem;
    miPaste: TMenuItem;
    miCut: TMenuItem;
    actTypeCopy: TAction;
    actTypePaste: TAction;
    actTypeCut: TAction;
    actTypeClear: TAction;
    actTypeSelect: TAction;
    actFilterFind: TAction;
    actFilterClear: TAction;
    actTypeFindInternet: TAction;
    Action3: TAction;
    StringColumnUUID: TStringColumn;
    aRefreshRepository: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridTypesGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure TreeViewTypesClick(Sender: TObject);
    procedure TreeViewTypesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure TreeViewTypesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure EditFindTypeExit(Sender: TObject);
    procedure DateEditFilterChange(Sender: TObject);
    procedure GridTypesHeaderClick(Column: TColumn);
    procedure GridTypesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure actTypeEditExecute(Sender: TObject);
    procedure actTypeClearExecute(Sender: TObject);
    procedure actTypeDeleteExecute(Sender: TObject);
    procedure actTypeAddExecute(Sender: TObject);
    procedure actTypeFindInternetExecute(Sender: TObject);
    procedure miDeleteRepositoryClick(Sender: TObject);
    procedure miAddRepositoryClick(Sender: TObject);
    procedure ComboBoxRepositoryChange(Sender: TObject);
    procedure miRefreshRepositoryClick(Sender: TObject);
    procedure mpExpandAllClick(Sender: TObject);
    procedure mpCollapseAllClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miLoadRepositoryClick(Sender: TObject);
    procedure actTypeSelectExecute(Sender: TObject);
    procedure actTypeCopyExecute(Sender: TObject);
    procedure actTypePasteExecute(Sender: TObject);
    procedure actTypeCutExecute(Sender: TObject);
    procedure actFilterFindExecute(Sender: TObject);
    procedure actFilterClearExecute(Sender: TObject);
    procedure UpdateTypeActions(Sender: TObject);
    procedure GridTypesCellClick(const Column: TColumn; const Row: Integer);

  private

  { ================= НОВАЯ АРХИТЕКТУРА ================= }

  FDeviceTypes: TObjectList<TDeviceType>;        // все типы из репозитория

  FDevFilteredByTree: TObjectList<TDeviceType>;  // фильтр по дереву
  FDevFilteredByText: TObjectList<TDeviceType>;  // фильтр по поиску
  FDevFilteredByDate: TObjectList<TDeviceType>;  // фильтр по датам

  FDevFilteredTypes: TObjectList<TDeviceType>;   // РЕЗУЛЬТАТ

  ActiveRepo: TTypeRepository;

  { ===== }

    FSortColumn: Integer;
    FSortAscending: Boolean;
    FSkipTypeDeleteConfirm: Boolean;
    FClearTreeSelectionOnClick: Boolean;
    FCheckedTypes: TList<TDeviceType>;

    procedure LoadData;
    procedure BuildTree;
    procedure UpdateGridTypes;
    procedure OpenTypeEditor(AType: TDeviceType);
    function HasActiveFilters: Boolean;
    function ColumnToSortField(ACol: Integer): TDeviceTypeSortField;

    procedure ResetSorting;
    procedure SyncTreeSelectionState(const AResetInputFilters: Boolean);
    procedure ApplyFilter;
    function  BuildFilteredByTree(
  const Source: TObjectList<TDeviceType>
): TObjectList<TDeviceType>;


    function PassTreeFilter(
      const AType: TDeviceType;
      const ANode: TTreeViewItem
    ): Boolean;
    function BuildSearchURL(const ASearch: string): string;
    procedure ApplyTreeSelectionToType(AType: TDeviceType);

    procedure FillComboBoxRepository;

     function UpdateConnection: Boolean;
     procedure ClearTreeAndGrid;
    procedure ClearGridSelection;
    function IsValidGridRow(const ARow: Integer): Boolean;
    function CurrentGridType: TDeviceType;
    procedure ClearCheckedTypes;
    function GetCheckedTypes: TObjectList<TDeviceType>;
    function GetSelectedTypes: TObjectList<TDeviceType>;
    function GetActiveTreeNode: TTreeViewItem;

  public
    { Public declarations }
    SelectedType:   TDeviceType;
    procedure SelectType (AType: TDeviceType);
    destructor Destroy; override;
  end;


var
  FormTypeSelect: TFormTypeSelect;


implementation
uses uAppServices;


procedure TFormTypeSelect.LoadData;
begin
  {--------------------------------------------------}
  { Проверяем наличие активного репозитория типов }
  {--------------------------------------------------}
  if (AppServices.DataManager = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
  begin
    ActiveRepo := nil;
    FDeviceTypes := nil;
    Exit;
  end;

  ActiveRepo := AppServices.DataManager.ActiveTypeRepo;

  {--------------------------------------------------}
  { Загружаем данные из БД }
  {--------------------------------------------------}
  ActiveRepo.LoadTypes;

  {--------------------------------------------------}
  { Привязываем реальные данные ПОСЛЕ загрузки }
  {--------------------------------------------------}
  FDeviceTypes := ActiveRepo.Types;
end;

function TFormTypeSelect.PassTreeFilter(
  const AType: TDeviceType;
  const ANode: TTreeViewItem
): Boolean;
var
  Cur: TTreeViewItem;
begin
  Result := True;

  Cur := ANode;
  if Cur = nil then
    Exit(False);

  // Узел "Все"
  if Cur.Tag = Ord(tnAll) then
    Exit(True);

  {-------------------------------------------------}
  { Идём ВВЕРХ по дереву и СРАЗУ проверяем }
  {-------------------------------------------------}
  while Cur <> nil do
  begin
    case Cur.Tag of

      // ---------- ИЗГОТОВИТЕЛЬ ----------
      Ord(tnManufacturer):
        begin
          // TagString = ''  → пустой изготовитель
          if AType.Manufacturer <> Cur.TagString then
            Exit(False);
        end;

      // ---------- КАТЕГОРИЯ ----------
      Ord(tnCategory):
        begin
          // TagString содержит ID категории
          if AType.Category <> StrToIntDef(Cur.TagString, -1) then
            Exit(False);
        end;

      // ---------- МОДИФИКАЦИЯ ----------
      Ord(tnModification):
        begin
          // TagString = '' → пустая модификация
          if AType.Modification <> Cur.TagString then
            Exit(False);
        end;
    end;

    Cur := Cur.ParentItem; // ⬅ только вверх
  end;

  // если дошли сюда — ВСЕ уровни прошли проверку
  Result := True;
end;

procedure TFormTypeSelect.BuildTree;
var
  T: TDeviceType;

  AllNode, ManNode, CatNode, ModNode: TTreeViewItem;
  ManText, ManKey: string;
  CatText, CatKey: string;
  ModText, ModKey: string;

  ManPass: Integer;
begin
  if ActiveRepo = nil then
  begin
    TreeViewTypes.Clear;
    GridTypes.RowCount:=0;
    Exit;
  end;


  TreeViewTypes.BeginUpdate;
  try
    TreeViewTypes.Clear;

    {----------------------------------}
    { Корневой узел }
    {----------------------------------}
    AllNode := TTreeViewItem.Create(TreeViewTypes);
    AllNode.Text := '...';
    AllNode.Tag := Ord(tnAll);
    AllNode.TagString := '';
    TreeViewTypes.AddObject(AllNode);

    {----------------------------------}
    { Проход по изготовителям }
    { ManPass = 0 → заполненные }
    { ManPass = 1 → пустые }
    {----------------------------------}
    for ManPass := 0 to 1 do
    begin
      for T in FDeviceTypes do
      begin
        if (Trim(T.Manufacturer) = '') xor (ManPass = 1) then
          Continue;

        {========== ИЗГОТОВИТЕЛЬ =========}
        if Trim(T.Manufacturer) <> '' then
        begin
          ManText := T.Manufacturer;
          ManKey  := T.Manufacturer;
        end
        else
        begin
          ManText := '<изготовитель>';
          ManKey  := '';
        end;

        ManNode := FindChildInTree(
          TreeViewTypes,
          Ord(tnManufacturer),
          ManKey
        );

        if ManNode = nil then
        begin
          ManNode := TTreeViewItem.Create(TreeViewTypes);
          ManNode.Text := ManText;
          ManNode.Tag := Ord(tnManufacturer);
          ManNode.TagString := ManKey;
          TreeViewTypes.AddObject(ManNode);
        end;

        {========== КАТЕГОРИИ > 0 =========}
        if T.Category > 0 then
        begin
          CatText := ActiveRepo.CategoryToText(T.Category, T.CategoryName);
          CatKey  := IntToStr(T.Category);

          CatNode := FindChildInNode(
            ManNode,
            Ord(tnCategory),
            CatKey
          );

          if CatNode = nil then
          begin
            CatNode := TTreeViewItem.Create(TreeViewTypes);
            CatNode.Text := CatText;
            CatNode.Tag := Ord(tnCategory);
            CatNode.TagString := CatKey;
            ManNode.AddObject(CatNode);
          end;

          {====== МОДИФИКАЦИИ ======}
          if Trim(T.Modification) <> '' then
          begin
            ModText := T.Modification;
            ModKey  := T.Modification;
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
            ModNode := TTreeViewItem.Create(TreeViewTypes);
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
    for T in FDeviceTypes do
    begin
      if T.Category > 0 then
        Continue;

      ManKey := T.Manufacturer;
      ManNode := FindChildInTree(
        TreeViewTypes,
        Ord(tnManufacturer),
        ManKey
      );

      if ManNode = nil then
        Continue;

      CatText := '<категория>';
      CatKey  := IntToStr(T.Category); // -1 / 0

      CatNode := FindChildInNode(
        ManNode,
        Ord(tnCategory),
        CatKey
      );

      if CatNode = nil then
      begin
        CatNode := TTreeViewItem.Create(TreeViewTypes);
        CatNode.Text := CatText;
        CatNode.Tag := Ord(tnCategory);
        CatNode.TagString := CatKey;
        ManNode.AddObject(CatNode);
      end;

      if Trim(T.Modification) <> '' then
      begin
        ModText := T.Modification;
        ModKey  := T.Modification;
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
        ModNode := TTreeViewItem.Create(TreeViewTypes);
        ModNode.Text := ModText;
        ModNode.Tag := Ord(tnModification);
        ModNode.TagString := ModKey;
        CatNode.AddObject(ModNode);
      end;
    end;

    TreeViewTypes.Selected := AllNode;

  finally
    TreeViewTypes.EndUpdate;
  end;
end;

procedure TFormTypeSelect.actTypeCopyExecute(Sender: TObject);
var
  TargetTypes: TObjectList<TDeviceType>;
begin
  TargetTypes := GetSelectedTypes;
  try
    // UI вызывает бизнес-логику копирования через менеджер данных.
    AppServices.DataManager.CopyTypesToBuffer(TargetTypes);
  finally
    TargetTypes.Free;
  end;
end;

procedure TFormTypeSelect.actTypePasteExecute(Sender: TObject);
var
  NewType: TDeviceType;
  I: Integer;
  SelectedNode: TTreeViewItem;
  SelectedParent: TTreeViewItem;
  NewRows: TObjectList<TDeviceType>;
  TargetManKey, TargetCatKey, TargetModKey: string;
  TargetNode: TTreeViewItem;
  HasTargetBranch: Boolean;
begin
  if (ActiveRepo = nil) or (AppServices.DataManager = nil) or (not AppServices.DataManager.HasBufferTypes) then
    Exit;

  SelectedNode := GetActiveTreeNode;
  TargetManKey := '';
  TargetCatKey := '';
  TargetModKey := '';
  HasTargetBranch := (SelectedNode <> nil) and (SelectedNode.Tag <> Ord(tnAll));
  if HasTargetBranch then
  begin
    case SelectedNode.Tag of
      Ord(tnManufacturer):
        TargetManKey := SelectedNode.TagString;
      Ord(tnCategory):
        begin
          TargetCatKey := SelectedNode.TagString;
          SelectedParent := SelectedNode.ParentItem;
          if SelectedParent <> nil then
            TargetManKey := SelectedParent.TagString;
        end;
      Ord(tnModification):
        begin
          TargetModKey := SelectedNode.TagString;
          SelectedParent := SelectedNode.ParentItem;
          if SelectedParent <> nil then
          begin
            TargetCatKey := SelectedParent.TagString;
            SelectedParent := SelectedParent.ParentItem;
            if SelectedParent <> nil then
              TargetManKey := SelectedParent.TagString;
          end;
        end;
    end;
  end;
  // Создание новых типов выполняется в DataManager.
  NewRows := AppServices.DataManager.PasteBufferTypes;
  try
    for I := 0 to NewRows.Count - 1 do
    begin
      NewType := NewRows[I];
      if (SelectedNode <> nil) and (SelectedNode.Tag <> Ord(tnAll)) then
        AppServices.DataManager.AssignTypeTreeFields(NewType, SelectedNode);
    end;

    BuildTree;
    if HasTargetBranch then
    begin
      TargetNode := FindChildInTree(TreeViewTypes, Ord(tnManufacturer), TargetManKey);
      if (TargetNode <> nil) and (TargetCatKey <> '') then
        TargetNode := FindChildInNode(TargetNode, Ord(tnCategory), TargetCatKey);
      if (TargetNode <> nil) and (TargetModKey <> '') then
        TargetNode := FindChildInNode(TargetNode, Ord(tnModification), TargetModKey);
      if TargetNode <> nil then
        TreeViewTypes.Selected := TargetNode;
    end;

    ApplyFilter;
    UpdateGridTypes;

    if (FDevFilteredTypes <> nil) and (NewRows.Count > 0) then
      for I := 0 to FDevFilteredTypes.Count - 1 do
        if FDevFilteredTypes[I] = NewRows[0] then
        begin
          GridTypes.Row := I;
          GridTypes.Selected := I;
          SelectedType := FDevFilteredTypes[I];
          Break;
        end;
  finally
    NewRows.Free;
  end;
end;

function TFormTypeSelect.GetActiveTreeNode: TTreeViewItem;
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

      // При множественном выборе берём самую глубокую выбранную ветку
      // (подветка имеет приоритет над верхней веткой).
      if CurDepth >= BestDepth then
      begin
        BestDepth := CurDepth;
        Result := ACandidate;
      end;
    end;

    // ВАЖНО: обходим все подпункты дерева, а не только первый уровень.
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
  Result := TreeViewTypes.Selected;
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

  // Запускаем полный обход дерева от корневых узлов.
  for I := 0 to TreeViewTypes.Count - 1 do
    CheckCandidate(TreeViewTypes.ItemByIndex(I));
end;

procedure TFormTypeSelect.actTypeCutExecute(Sender: TObject);
var
  TargetTypes: TObjectList<TDeviceType>;
begin
  // UI вызывает бизнес-логику Cut через менеджер данных.
  TargetTypes := GetSelectedTypes;
  try
    AppServices.DataManager.CutTypesToBuffer(TargetTypes);
  finally
    TargetTypes.Free;
  end;
  ApplyFilter;
  UpdateGridTypes;
end;

procedure TFormTypeSelect.ApplyFilter;
var
  SourceTypes: TObjectList<TDeviceType>;
begin
  SourceTypes := FDeviceTypes;

  if (SourceTypes = nil) and (ActiveRepo <> nil) then
    SourceTypes := ActiveRepo.Types;

  {----------------------------------}
  { 1. Фильтр по дереву  }
  {----------------------------------}
  // дерево остаётся как есть
  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(SourceTypes);

  {----------------------------------}
  { 2. Текстовый фильтр }
  {----------------------------------}
  FreeAndNil(FDevFilteredByText);

  FDevFilteredByText :=
  TEntityFilters<TDeviceType>.ApplyTextFilter(
    FDevFilteredByTree,
    EditFindType.Text
  );

  {----------------------------------}
  { 3. Фильтр по дате }
  {----------------------------------}
FreeAndNil(FDevFilteredByDate);
FDevFilteredByDate :=
  TEntityFilters<TDeviceType>.ApplyDateFilter(
    FDevFilteredByText,
    DateEditFilter.Date,
    not DateEditFilter.IsEmpty
  );


  {----------------------------------}
  { 4. Сортировка }
  {----------------------------------}
  FreeAndNil(FDevFilteredTypes);
  FDevFilteredTypes :=
    SortDeviceTypes(
      FDevFilteredByDate,
      ColumnToSortField(FSortColumn),
      FSortAscending
    );

end;

procedure TFormTypeSelect.actTypeAddExecute(Sender: TObject);
var
  NewType: TDeviceType;
  SelRow: Integer;
  SourceType: TDeviceType;
  I: Integer;
begin

   { --------------------------------------------------}
  { Если нет активного репозитория — некуда добавлять }
  {--------------------------------------------------}
  if (AppServices.DataManager = nil) or (ActiveRepo = nil) then
  begin
    Exit;
  end;

  {-------------------------------------------------}
  { 1. Формируем новый тип }
  {-------------------------------------------------}
  SelRow := GridTypes.Selected;
  SourceType := nil;

  if (FDevFilteredTypes <> nil) and (SelRow >= 0) and (SelRow < FDevFilteredTypes.Count) then
    SourceType := FDevFilteredTypes[SelRow];

  NewType := ActiveRepo.CreateType(SourceType);
  if SourceType = nil then
    ApplyTreeSelectionToType(NewType);

  {-------------------------------------------------}
  { Обновляем ТОЛЬКО фильтрованные списки }
  {-------------------------------------------------}

  ApplyFilter; // Text → Date → Sort → Grid

  UpdateGridTypes;
  {-------------------------------------------------}
  { 4. Выделяем добавленную строку }
  {-------------------------------------------------}
  if FDevFilteredTypes <> nil then
    for I := 0 to FDevFilteredTypes.Count - 1 do
      if FDevFilteredTypes[I] = NewType then
      begin
        GridTypes.Row := I;
        GridTypes.Selected := I;
        SelectedType := FDevFilteredTypes[I];
        Break;
      end;
end;

procedure TFormTypeSelect.ApplyTreeSelectionToType(AType: TDeviceType);
begin
  AppServices.DataManager.AssignTypeTreeFields(AType, TreeViewTypes.Selected);
end;

 procedure TFormTypeSelect.actTypeClearExecute(Sender: TObject);
var
  I: Integer;
  T: TDeviceType;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (FDevFilteredTypes = nil) or (FDevFilteredTypes.Count = 0) then
    Exit;

  if MessageDlg(
       'Удалить все отображаемые типы безвозвратно?',
       TMsgDlgType.mtWarning,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  {----------------------------------}
  { Удаление через репозиторий }
  { Идём с конца, чтобы ничего не сломать }
  {----------------------------------}
  for I := FDevFilteredTypes.Count - 1 downto 0 do
  begin
    T := FDevFilteredTypes[I];
    if T <> nil then
      ActiveRepo.DeleteType(T);
  end;

  {----------------------------------}
  { Пересборка фильтров }
  {----------------------------------}
  //FreeAndNil(FDevFilteredByTree);
  //FDevFilteredByTree := BuildFilteredByTree(FDeviceTypes);
  BuildTree;
  ApplyFilter;
  UpdateGridTypes;
  ClearCheckedTypes;
  {----------------------------------}
  { Сброс выделения }
  {----------------------------------}
  ClearGridSelection;
end;


procedure TFormTypeSelect.actTypeDeleteExecute(Sender: TObject);
var
  I: Integer;
  SelType: TDeviceType;
  TargetTypes: TObjectList<TDeviceType>;
begin
  if (FDevFilteredTypes = nil) or (FDevFilteredTypes.Count = 0) then
    Exit;

  TargetTypes := GetSelectedTypes;
  try
    if TargetTypes.Count = 0 then
      Exit;

    if not FSkipTypeDeleteConfirm then
    begin
      if TargetTypes.Count = 1 then
      begin
        if MessageDlg(
             'Удалить выбранный тип безвозвратно?',
             TMsgDlgType.mtWarning,
             [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
             0
           ) <> mrYes then
          Exit;
      end
      else
      begin
        if MessageDlg(
             'Удалить выбранные типы безвозвратно?',
             TMsgDlgType.mtWarning,
             [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
             0
           ) <> mrYes then
          Exit;
      end;

    end;

    for I := TargetTypes.Count - 1 downto 0 do
    begin
      SelType := TargetTypes[I];
      if SelType <> nil then
        ActiveRepo.DeleteType(SelType);
    end;

    FreeAndNil(FDevFilteredByTree);
    FDevFilteredByTree := BuildFilteredByTree(FDeviceTypes);

    ApplyFilter;
    UpdateGridTypes;
    ClearCheckedTypes;
    ClearGridSelection;
  finally
    TargetTypes.Free;
  end;
end;

procedure TFormTypeSelect.DateEditFilterChange(Sender: TObject);
begin
  {----------------------------------}
  { Фильтр по дате поверх текста }
  {----------------------------------}
FreeAndNil(FDevFilteredByDate);
FDevFilteredByDate :=
  TEntityFilters<TDeviceType>.ApplyDateFilter(
    FDevFilteredByText,
    DateEditFilter.Date,
    not DateEditFilter.IsEmpty
  );


  {----------------------------------}
  { Сортировка }
  {----------------------------------}
  FreeAndNil(FDevFilteredTypes);
  FDevFilteredTypes :=
    SortDeviceTypes(
      FDevFilteredByDate,
      ColumnToSortField(FSortColumn),
      FSortAscending
    );

  {----------------------------------}
  { Обновление таблицы }
  {----------------------------------}
  UpdateGridTypes;
end;

procedure TFormTypeSelect.EditFindTypeExit(Sender: TObject);
begin
    ApplyFilter;
    UpdateGridTypes;
end;

{$R *.fmx}

procedure TFormTypeSelect.FormClose(
  Sender: TObject;
  var Action: TCloseAction
);
var
  Repo: TTypeRepository;
  Res: TModalResult;
begin
  Repo := AppServices.DataManager.ActiveTypeRepo;

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
          // закрываем без сохранения
        end;

      mrCancel:
        begin
          Action := TCloseAction.caNone;
          Exit;
        end;
    end;
  end;
end;


procedure TFormTypeSelect.FormCreate(Sender: TObject);
begin

   FSortColumn := -1;
   FSortAscending := True;
   FSkipTypeDeleteConfirm := False;
   FClearTreeSelectionOnClick := False;
   FCheckedTypes := TList<TDeviceType>.Create;
   TreeViewTypes.MultiSelect := True;
   TreeViewTypes.OnMouseUp := TreeViewTypesMouseUp;
   GridTypes.OnMouseDown := GridTypesMouseDown;

   LoadData;
   FillComboBoxRepository;
   if UpdateConnection then
   begin
     BuildTree;
     ApplyFilter;
     UpdateGridTypes;
   end;

end;

destructor TFormTypeSelect.Destroy;
begin
  FreeAndNil(FCheckedTypes);
  inherited;
end;

procedure TFormTypeSelect.FillComboBoxRepository;
var
  Repo: TTypeRepository;
  ItemIndex: Integer;
begin
  ComboBoxRepository.BeginUpdate;
  try
    ComboBoxRepository.Clear;

    if (AppServices.DataManager = nil) then
      Exit;

    ItemIndex := -1;

    // перебираем репозитории типов из менеджера
    for Repo in AppServices.DataManager.TypeRepositories do
    begin
      ComboBoxRepository.Items.Add(Repo.Name);

      // запоминаем индекс активного репозитория
      if Repo = AppServices.DataManager.ActiveTypeRepo then
        ItemIndex := ComboBoxRepository.Items.Count - 1;
    end;

    // выбираем активный репозиторий
    ComboBoxRepository.ItemIndex := ItemIndex;

  finally
    ComboBoxRepository.EndUpdate;
  end;
end;

procedure TFormTypeSelect.GridTypesCellClick(const Column: TColumn;
  const Row: Integer);
begin
  if not IsValidGridRow(Row) then
    Exit;

  GridTypes.Row := Row;
  GridTypes.Selected := Row;
  SelectedType := FDevFilteredTypes[Row];

  if Column = CheckColumnTypeEnable then
  begin
    if FCheckedTypes.IndexOf(SelectedType) >= 0 then
      FCheckedTypes.Remove(SelectedType)
    else
      FCheckedTypes.Add(SelectedType);
    UpdateGridTypes;
    Exit;
  end;
end;

procedure TFormTypeSelect.GridTypesGetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  var Value: TValue
);
var
  T: TDeviceType;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if ActiveRepo = nil then
    Exit;

  if FDevFilteredTypes = nil then
    Exit;

  if (ARow < 0) or (ARow >= FDevFilteredTypes.Count) then
    Exit;

  T := FDevFilteredTypes[ARow];
  if T = nil then
    Exit;

  {----------------------------------}
  { Значения колонок }
  {----------------------------------}
  if ACol = CheckColumnTypeEnable.Index then
    Value := FCheckedTypes.IndexOf(T) >= 0

  else if ACol = StringColumnName.Index then
    Value := T.Name

  else if ACol = StringColumnCategory.Index then
  begin
    if Trim(T.CategoryName) <> '' then
      Value := T.CategoryName
    else
      Value := ActiveRepo.CategoryToText(T.Category, T.CategoryName);
  end

  else if ACol = StringColumnManufacturer.Index then
    Value := T.Manufacturer

  else if ACol = StringColumnModification.Index then
    Value := T.Modification

  else if ACol = StringColumnAccuracyClass.Index then
    Value := T.AccuracyClass

  else if ACol = StringColumnReestrNumber.Index then
    Value := T.ReestrNumber

  else if ACol = StringColumnRegDate.Index then
  begin
    if T.RegDate > 0 then
      Value := DateToStr(T.RegDate)
    else
      Value := '-';
  end

  else if ACol = StringColumnValidityDate.Index then
  begin
    if T.ValidityDate > 0 then
      Value := DateToStr(T.ValidityDate)
    else
      Value := '-';
  end

  else if ACol = StringColumnIVI.Index then
    Value := T.IVI

  else if ACol = StringColumnVerificationMethod.Index then
    Value := T.VerificationMethod

  else if ACol = StringColumnProcedure.Index then
    Value := T.ProcedureName

   else if ACol =  StringColumnUUID.Index  then
    Value := T.UUID;

end;


procedure TFormTypeSelect.GridTypesHeaderClick(Column: TColumn);
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
  FreeAndNil(FDevFilteredTypes);
  FDevFilteredTypes :=
    SortDeviceTypes(
      FDevFilteredByDate,          // текущий список после всех фильтров
      ColumnToSortField(FSortColumn),
      FSortAscending
    );

  {----------------------------------}
  { Обновление таблицы }
  {----------------------------------}
  UpdateGridTypes;
end;

procedure TFormTypeSelect.GridTypesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Col, Row: Integer;
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  if not GridTypes.CellByPoint(X, Y, Col, Row) then
    Exit;

  if not IsValidGridRow(Row) then
    Exit;

  if (Col < 0) or (Col >= GridTypes.ColumnCount) then
    Exit;

  if GridTypes.Columns[Col] = CheckColumnTypeEnable then
    Exit;

  GridTypes.Row := Row;
  GridTypes.Selected := Row;
  SelectedType := FDevFilteredTypes[Row];
end;



procedure TFormTypeSelect.actFilterClearExecute(Sender: TObject);
begin
  // 1. очистка фильтров ввода
  EditFindType.Text := '';
  DateEditFilter.IsEmpty := True;

  // 2. пересчёт фильтров
  ClearCheckedTypes;
  ApplyFilter;
  UpdateGridTypes;
  // фильтров больше нет
  sbFind.IsPressed := False;
end;

procedure TFormTypeSelect.actFilterFindExecute(Sender: TObject);
begin
   // 2. пересчёт фильтров   обновление таблицы
  //FilterTypesByTreeNode(TreeViewTypes.Selected);
  ClearCheckedTypes;
  ApplyFilter;
  UpdateGridTypes;
end;

procedure TFormTypeSelect.TreeViewTypesClick(Sender: TObject);
begin
  SyncTreeSelectionState(True);
  {
  if FClearTreeSelectionOnClick then
  begin
    TreeViewTypes.Selected := nil;
    FClearTreeSelectionOnClick := False;

    FreeAndNil(FDevFilteredByTree);
    FDevFilteredByTree := BuildFilteredByTree(FDeviceTypes);

    ApplyFilter;
    UpdateGridTypes;
  end;                     }
end;

procedure TFormTypeSelect.SyncTreeSelectionState(const AResetInputFilters: Boolean);
var
  Item: TTreeViewItem;
  HasSelection: Boolean;
  I: Integer;
begin
  HasSelection := False;
  for I := 0 to TreeViewTypes.Count - 1 do
    if TreeViewTypes.ItemByIndex(I).IsSelected then
    begin
      HasSelection := True;
      Break;
    end;

  if not HasSelection then
    TreeViewTypes.Selected := nil;

  FreeAndNil(FDevFilteredByTree);
  FDevFilteredByTree := BuildFilteredByTree(FDeviceTypes);

  ClearCheckedTypes;
  ApplyFilter;
  UpdateGridTypes;

  ClearGridSelection;
  Item := TreeViewTypes.Selected;
  if Assigned(Item) then
  begin
    if AResetInputFilters then
    begin
      // 1. очистка фильтров ввода
      EditFindType.Text := '';
      DateEditFilter.IsEmpty := True;

      // 2. пересчёт фильтров
      ApplyFilter;
      UpdateGridTypes;
      // фильтров больше нет
      sbFind.IsPressed := False;
    end;
  end
  else
  begin
    ClearGridSelection;
  end;
end;

procedure TFormTypeSelect.TreeViewTypesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  ClickedItem: TTreeViewItem;
begin
  FClearTreeSelectionOnClick := False;

  if Button <> TMouseButton.mbLeft then
    Exit;

  if (ssCtrl in Shift) or (ssShift in Shift) then
    Exit;

  ClickedItem := TreeViewTypes.ItemByPoint(X, Y);

  if (ClickedItem <> nil) and ClickedItem.IsSelected then
    FClearTreeSelectionOnClick := True;
end;

procedure TFormTypeSelect.TreeViewTypesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  if (ssCtrl in Shift) or (ssShift in Shift) then
    SyncTreeSelectionState(False);
end;

function TFormTypeSelect.BuildFilteredByTree(
  const Source: TObjectList<TDeviceType>
): TObjectList<TDeviceType>;
var
  T: TDeviceType;
  I: Integer;
  J: Integer;
  Item: TTreeViewItem;
  IsMatch: Boolean;
  SelectedNodes: TList<TTreeViewItem>;
  procedure CollectSelectedNodes(const ANode: TTreeViewItem);
  var
    K: Integer;
    Child: TTreeViewItem;
  begin
    if ANode = nil then
      Exit;

    if ANode.IsSelected then
      if SelectedNodes.IndexOf(ANode) < 0 then
        SelectedNodes.Add(ANode);

    for K := 0 to ANode.Count - 1 do
    begin
      Child := ANode.ItemByIndex(K);
      CollectSelectedNodes(Child);
    end;
  end;
begin
  Result := TObjectList<TDeviceType>.Create(False); // ссылки, не владеем

  if Source = nil then
    Exit;

  SelectedNodes := TList<TTreeViewItem>.Create;
  try
    for I := 0 to TreeViewTypes.Count - 1 do
    begin
      Item := TreeViewTypes.ItemByIndex(I);
      CollectSelectedNodes(Item);
    end;

    if SelectedNodes.Count = 0 then
      Exit;

    for T in Source do
    begin
      IsMatch := False;

      for J := 0 to SelectedNodes.Count - 1 do
        if PassTreeFilter(T, SelectedNodes[J]) then
        begin
          IsMatch := True;
          Break;
        end;

      if IsMatch then
        Result.Add(T);
    end;
  finally
    SelectedNodes.Free;
  end;
end;

procedure TFormTypeSelect.UpdateGridTypes;
var
  I: Integer;
begin
  if FCheckedTypes <> nil then
    for I := FCheckedTypes.Count - 1 downto 0 do
      if (FDevFilteredTypes = nil) or (FDevFilteredTypes.IndexOf(FCheckedTypes[I]) < 0) then
        FCheckedTypes.Delete(I);

  GridTypes.BeginUpdate;
  try
    if FDevFilteredTypes <> nil then
      GridTypes.RowCount := FDevFilteredTypes.Count
    else
      GridTypes.RowCount := 0;
  finally
    GridTypes.EndUpdate;
  end;

  if (GridTypes.Row >= GridTypes.RowCount) then
    GridTypes.Row := -1;
  GridTypes.Selected := GridTypes.Row;
  if IsValidGridRow(GridTypes.Row) then
    SelectedType := FDevFilteredTypes[GridTypes.Row]
  else
    SelectedType := nil;

  GridTypes.Repaint;

  sbFind.IsPressed := HasActiveFilters;
end;

procedure TFormTypeSelect.ClearGridSelection;
begin
  GridTypes.Row := -1;
  GridTypes.Selected := -1;
  SelectedType := nil;
end;

function TFormTypeSelect.IsValidGridRow(const ARow: Integer): Boolean;
begin
  Result :=
    (FDevFilteredTypes <> nil) and
    (ARow >= 0) and
    (ARow < FDevFilteredTypes.Count);
end;

function TFormTypeSelect.CurrentGridType: TDeviceType;
var
  Row: Integer;
begin
  Row := GridTypes.Selected;
  if Row < 0 then
    Row := GridTypes.Row;

  if IsValidGridRow(Row) then
    Result := FDevFilteredTypes[Row]
  else
    Result := nil;
end;

procedure TFormTypeSelect.ClearCheckedTypes;
begin
  if FCheckedTypes <> nil then
    FCheckedTypes.Clear;
end;

function TFormTypeSelect.GetCheckedTypes: TObjectList<TDeviceType>;
var
  I: Integer;
  AType: TDeviceType;
begin
  Result := TObjectList<TDeviceType>.Create(False);
  if (FCheckedTypes = nil) or (FDevFilteredTypes = nil) then
    Exit;

  for I := 0 to FCheckedTypes.Count - 1 do
  begin
    AType := FCheckedTypes[I];
    if (AType <> nil) and (FDevFilteredTypes.IndexOf(AType) >= 0) then
      Result.Add(AType);
  end;
end;

function TFormTypeSelect.GetSelectedTypes: TObjectList<TDeviceType>;
var
  I: Integer;
  CheckedTypes: TObjectList<TDeviceType>;
  AType: TDeviceType;
begin
  Result := TObjectList<TDeviceType>.Create(False);

  CheckedTypes := GetCheckedTypes;
  try
    if CheckedTypes.Count > 0 then
    begin
      for I := 0 to CheckedTypes.Count - 1 do
        Result.Add(CheckedTypes[I]);
      Exit;
    end;
  finally
    CheckedTypes.Free;
  end;

  AType := CurrentGridType;
  if AType <> nil then
  begin
    Result.Add(AType);
    Exit;
  end;

  if FDevFilteredTypes = nil then
    Exit;

  for I := 0 to FDevFilteredTypes.Count - 1 do
    Result.Add(FDevFilteredTypes[I]);
end;

procedure TFormTypeSelect.UpdateTypeActions(Sender: TObject);
var
  HasRepo: Boolean;
  HasRows: Boolean;
begin
  HasRepo := (AppServices.DataManager <> nil) and (ActiveRepo <> nil);
  HasRows := (FDevFilteredTypes <> nil) and (FDevFilteredTypes.Count > 0);

  actTypeAdd.Enabled := HasRepo;
  actTypeEdit.Enabled := HasRows;
  actTypeSelect.Enabled := HasRows;
  actTypeDelete.Enabled := HasRepo and HasRows;
  actTypeCopy.Enabled := HasRows;
  actTypeCut.Enabled := HasRepo and HasRows;
  actTypePaste.Enabled := HasRepo and (AppServices.DataManager <> nil) and AppServices.DataManager.HasBufferTypes;
  actTypeClear.Enabled := HasRepo and HasRows;

  actFilterFind.Enabled := HasRepo;
  actFilterClear.Enabled := HasRepo and HasActiveFilters;
  actTypeFindInternet.Enabled := HasRepo and (Trim(EditFindType.Text) <> '');
end;

function TFormTypeSelect.HasActiveFilters: Boolean;
begin
  Result :=
    (Trim(EditFindType.Text) <> '') or
    (not DateEditFilter.IsEmpty);
end;

procedure TFormTypeSelect.miAddRepositoryClick(Sender: TObject);
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

  {----------------------------------}
  { Диалог выбора файла БД }
  {----------------------------------}
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := 'Файл базы данных репозитория';
    Dlg.Filter := 'SQLite database (*.db)|*.db|Все файлы (*.*)|*.*';
    Dlg.DefaultExt := 'db';
    Dlg.FileName := RepoName + '.db';
    Dlg.InitialDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Types';

    ForceDirectories(Dlg.InitialDir);

    if not Dlg.Execute then
      Exit;

    DBFileName := Dlg.FileName;
  finally
    Dlg.Free;
  end;

  {----------------------------------}
  { Добавление репозитория }
  {----------------------------------}
  AppServices.DataManager.AddRepository(
    RepoName,
    rkType,
    DBFileName
  );


  {----------------------------------}
  { Обновление UI }
  {----------------------------------}
  if AppServices.DataManager.ActiveTypeRepo = nil then
    Exit;

  FDeviceTypes := AppServices.DataManager.ActiveTypeRepo.Types;

  FillComboBoxRepository;
  BuildTree;
  ApplyFilter;
  UpdateGridTypes;
end;

procedure TFormTypeSelect.miDeleteRepositoryClick(Sender: TObject);
var
  Repo: TTypeRepository;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (AppServices.DataManager = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
    Exit;

  Repo := AppServices.DataManager.ActiveTypeRepo;

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

  if AppServices.DataManager.ActiveTypeRepo <> nil then
  begin
    LoadData;        // заново загружает данные активного репозитория
    BuildTree;
    ApplyFilter;
    UpdateGridTypes;
  end
  else
  begin
    { нет активного репозитория — чистим UI }
    TreeViewTypes.Clear;

    if FDevFilteredTypes <> nil then
      FDevFilteredTypes.Clear;

    UpdateGridTypes;
  end;
end;

procedure TFormTypeSelect.miLoadRepositoryClick(Sender: TObject);
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
    Dlg.Title := 'Открыть файл репозитория';
    Dlg.Filter := 'SQLite database (*.db)|*.db|Все файлы (*.*)|*.*';
    Dlg.Options := [TOpenOption.ofFileMustExist];
    Dlg.InitialDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Types';

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
  { Добавление репозитория }
  {----------------------------------}
  AppServices.DataManager.AddRepository(
    RepoName,
    rkType,
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
  UpdateGridTypes;
end;

procedure TFormTypeSelect.miRefreshRepositoryClick(Sender: TObject);
begin
      { Пересборка дерева (с восстановлением выбора) }
      BuildTree;

      { Полная пересборка фильтров + сортировка }
      ApplyFilter;
        UpdateGridTypes;
end;

procedure TFormTypeSelect.miSaveClick(Sender: TObject);
var
  Repo: TTypeRepository;
begin
  Repo := AppServices.DataManager.ActiveTypeRepo;
  if Repo = nil then
    Exit;

  try
      //TWaitCursor.Create;

    if not Repo.Save then
      raise Exception.Create('Не удалось сохранить изменения типов');

    UpdateGridTypes;   // обновление таблицы типов
    BuildTree;   // если есть дерево
    ApplyFilter;
    ShowMessage('Изменения успешно сохранены');
  finally
    //Screen.Cursor := crDefault;
  end;
end;


procedure TFormTypeSelect.mpCollapseAllClick(Sender: TObject);
begin
        TreeViewTypes.CollapseAll;
end;

procedure TFormTypeSelect.mpExpandAllClick(Sender: TObject);
begin
      TreeViewTypes.ExpandAll;
end;

procedure TFormTypeSelect.OpenTypeEditor(AType: TDeviceType);
var
  Form: TFormTypeEditor;
  Res: TModalResult;
begin
  if AType = nil then
    Exit;

  Form := TFormTypeEditor.Create(Self, AType);

  try
    Res := Form.ShowModal;              //  КОНТРОЛИРУЕМ РЕЗУЛЬТАТ

    if (Res = mrOk) and Form.Modified then
    begin
      { Репозиторий уже обновлён редактором }

      // Пересборка UI
      // BuildTree;
      // ApplyFilter;
      UpdateGridTypes;
    end;

  finally
    Form.Free;
  end;
end;

function TFormTypeSelect.ColumnToSortField(
  ACol: Integer
): TDeviceTypeSortField;
begin
  if ACol = StringColumnName.Index then
    Result := sfName

  else if ACol = StringColumnCategory.Index then
    Result := sfCategory

  else if ACol = StringColumnManufacturer.Index then
    Result := sfManufacturer

  else if ACol = StringColumnModification.Index then
    Result := sfModification

  else if ACol = StringColumnAccuracyClass.Index then
    Result := sfAccuracyClass

  else if ACol = StringColumnReestrNumber.Index then
    Result := sfReestrNumber

  else if ACol = StringColumnProcedure.Index then
    Result := sfProcedure

  else if ACol = StringColumnVerificationMethod.Index then
    Result := sfVerificationMethod

  else if ACol = StringColumnIVI.Index then
    Result := sfIVI

  else if ACol = StringColumnRegDate.Index then
    Result := sfRegDate

  else if ACol = StringColumnValidityDate.Index then
    Result := sfValidityDate

  else
    Result := sfName; // безопасный дефолт
end;

procedure TFormTypeSelect.ComboBoxRepositoryChange(Sender: TObject);
var
  Idx: Integer;
  RepoName: string;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (AppServices.DataManager = nil) then
    Exit;

  Idx := ComboBoxRepository.ItemIndex;
  if Idx < 0 then
    Exit;

  RepoName := ComboBoxRepository.Items[Idx];

  {----------------------------------}
  { Смена активного репозитория через менеджер }
  {----------------------------------}
  AppServices.DataManager.SetActiveTypeRepository(RepoName);

  {----------------------------------}
  { Пересборка UI }
  {----------------------------------}
  LoadData;      // гарантирует валидный FDeviceTypes



      if not UpdateConnection then
        Exit;

  BuildTree;
  ApplyFilter;
    UpdateGridTypes;
end;

procedure TFormTypeSelect.actTypeFindInternetExecute(Sender: TObject);
var
  Resp: IHTTPResponse;
  Url: string;
  ResponseText: string;

  Json: TJSONObject;
  ResultObj: TJSONObject;
  Items: TJSONArray;
  Item: TJSONObject;

  I: Integer;
  DevType: TDeviceType;

  SearchText: string;
  DetectText: string;
  TotalCount: Integer;
begin
  {----------------------------------}
  { Подготовка лога }
  {----------------------------------}
  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  if EditFindType.Text.Trim = '' then
  begin
    MemoLog.Lines.Add('Пустая строка поиска');
    Exit;
  end;

  if ActiveRepo = nil then
  begin
    MemoLog.Lines.Add('Активный репозиторий не инициализирован');
    Exit;
  end;

  {----------------------------------}
  { Формирование запроса }
  {----------------------------------}
  SearchText := '*' + EditFindType.Text.Trim + '*';

  Url :=
    'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
    '?search=' + TNetEncoding.URL.Encode(SearchText) +
    '&start=0&rows=100';

  try
    {----------------------------------}
    { HTTP-запрос }
    {----------------------------------}
    Resp := NetHTTPClient1.Get(Url);
    ResponseText := Resp.ContentAsString;

    MemoLog.Lines.Add('URL: ' + Url);
    MemoLog.Lines.Add('Status: ' + Resp.StatusCode.ToString);
    MemoLog.Lines.Add('------------------------------');
    MemoLog.Lines.Add(ResponseText);
    MemoLog.Lines.Add('------------------------------');

    {----------------------------------}
    { Парсинг JSON }
    {----------------------------------}
    Json := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      if Json = nil then Exit;

      ResultObj := Json.GetValue('result') as TJSONObject;
      if ResultObj = nil then Exit;

      {----------------------------------}
      { Проверка количества }
      {----------------------------------}
      TotalCount := ResultObj.GetValue<Integer>('count');

      if TotalCount > 100 then
      begin
        MemoLog.Lines.Add(
          Format(
            'Найдено %d записей. Уточните запрос.',
            [TotalCount]
          )
        );

        ShowMessage(
          Format(
            'Найдено %d записей.' + sLineBreak +
            'Уточните запрос для уменьшения выборки.',
            [TotalCount]
          )
        );

        Exit;
      end;

      Items := ResultObj.GetValue('items') as TJSONArray;
      if Items = nil then Exit;

if MessageDlg(
  'Добавить данные из АРШИН в текущий репозиторий?',
  TMsgDlgType.mtConfirmation,
  [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
  0
) <> mrYes then
  Exit;


      {----------------------------------}
      { Заполнение типов }
      {----------------------------------}
      for I := 0 to Items.Count - 1 do
      begin
        Item := Items.Items[I] as TJSONObject;


        DevType := ActiveRepo.CreateType(0);

        {------------ mit_uuid ------------}
        if Item.GetValue('mit_uuid') <> nil then
          DevType.UUID := Item.GetValue('mit_uuid').Value;

        {------------ ГРСИ ------------}
        if Item.GetValue('number') <> nil then
          DevType.ReestrNumber := Item.GetValue('number').Value;

        {------------ Наименование ------------}
        if Item.GetValue('notation') <> nil then
          DevType.Name := Item.GetValue('notation').Value;

        {------------ title → CategoryName ------------}
        if Item.GetValue('title') <> nil then
          DevType.CategoryName := Item.GetValue('title').Value;

        {------------ Производитель ------------}
        if Item.GetValue('manufacturers') <> nil then
          DevType.Manufacturer :=
            ExtractManufacturerName(
              Item.GetValue('manufacturers').Value
            );

        {----------------------------------}
        { Автоопределение категории }
        {----------------------------------}
        DetectText :=
          NormalizeSearchText(
            DevType.CategoryName + ' ' + DevType.Name
          );

        DevType.Category :=
          ActiveRepo.DetectCategoryByKeywords(DetectText);


      end;

    finally
      Json.Free;
    end;



    {----------------------------------}
    { Обновление UI }
    {----------------------------------}
      if not UpdateConnection then
        Exit;

    BuildTree;
    ApplyFilter;
    UpdateGridTypes;

  except
    on E: Exception do
      MemoLog.Lines.Add('ERROR: ' + E.Message);
  end;
end;

procedure TFormTypeSelect.actTypeSelectExecute(Sender: TObject);
var
  TargetTypes: TObjectList<TDeviceType>;
begin
  TargetTypes := GetSelectedTypes;
  try
    if TargetTypes.Count = 0 then
    begin
      ShowMessage('Выберите тип');
      Exit;
    end;

    SelectedType := TargetTypes[0];
    if SelectedType = nil then
      Exit;

    ModalResult := mrOk;
  finally
    TargetTypes.Free;
  end;
end;

procedure TFormTypeSelect.actTypeEditExecute(Sender: TObject);
var
  TargetTypes: TObjectList<TDeviceType>;
  AType: TDeviceType;
begin
  TargetTypes := GetSelectedTypes;
  try
    if TargetTypes.Count = 0 then
    begin
      ShowMessage('Выберите тип для редактирования');
      Exit;
    end;
    AType := TargetTypes[0];
  finally
    TargetTypes.Free;
  end;

  if AType = nil then
    Exit;

  {----------------------------------}
  { Открываем редактор }
  {----------------------------------}
  OpenTypeEditor(AType);

  SelectedType:=AType;

  ModalResult := mrOk;

end;


procedure TFormTypeSelect.ResetSorting;
begin
  FSortColumn := -1;
  FSortAscending := True;
end;

function TFormTypeSelect.BuildSearchURL(const ASearch: string): string;
begin
  Result :=
    'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
    '?search=' + TNetEncoding.URL.Encode(ASearch) +
    '&start=0&rows=20';
end;

function TFormTypeSelect.UpdateConnection: Boolean;
begin
  Result := False;

  ClearTreeAndGrid;
  {----------------------------------}
  { Проверка менеджера }
  {----------------------------------}
  if AppServices.DataManager = nil then
    Exit;

  {----------------------------------}
  { Проверка активного репозитория }
  {----------------------------------}
  if AppServices.DataManager.ActiveTypeRepo = nil then
    Exit;

  {----------------------------------}
  { Проверка данных репозитория }
  {----------------------------------}
  if AppServices.DataManager.ActiveTypeRepo.Types = nil then
    Exit;

  {----------------------------------}
  { Обновляем ссылку на данные }
  {----------------------------------}
  ActiveRepo := AppServices.DataManager.ActiveTypeRepo;
  FDeviceTypes := AppServices.DataManager.ActiveTypeRepo.Types;

  Result := True;
end;

procedure TFormTypeSelect.ClearTreeAndGrid;
begin
  ActiveRepo := nil;
  FDeviceTypes := nil;
  ClearGridSelection;

  {----------------------------------}
  { Очистка дерева }
  {----------------------------------}
  TreeViewTypes.BeginUpdate;
  try
    TreeViewTypes.Clear;
  finally
    TreeViewTypes.EndUpdate;
  end;

  {----------------------------------}
  { Очистка отфильтрованного списка }
  {----------------------------------}
  if FDevFilteredTypes <> nil then
    FDevFilteredTypes.Clear;

  {----------------------------------}
  { Очистка таблицы }
  {----------------------------------}
  UpdateGridTypes;
end;

procedure TFormTypeSelect.SelectType(AType: TDeviceType);
var
  ManKey, CatKey, ModKey: string;
  ManNode, CatNode, ModNode: TTreeViewItem;
  I: Integer;
begin
  if (AType = nil) or (FDevFilteredTypes = nil) then
    Exit;

  {---------------- Изготовитель ----------------}
  ManKey := Trim(AType.Manufacturer);
  ManNode := FindChildInTree(TreeViewTypes, Ord(tnManufacturer), ManKey);
  if ManNode = nil then
    Exit;

  {---------------- Категория ----------------}
  CatKey := IntToStr(AType.Category);
  CatNode := FindChildInNode(ManNode, Ord(tnCategory), CatKey);
  if CatNode = nil then
    Exit;

  {---------------- Модификация ----------------}
  ModKey := Trim(AType.Modification);
  ModNode := FindChildInNode(CatNode, Ord(tnModification), ModKey);
  if ModNode = nil then
    Exit;

  {---------------- Раскрываем дерево ----------------}
  TreeViewTypes.ExpandAll;

  {---------------- Выбираем узел ----------------}
  TreeViewTypes.Selected := ModNode;

  {---------------- Выбираем строку в отфильтрованном гриде ----------------}
  for I := 0 to FDevFilteredTypes.Count - 1 do
    if FDevFilteredTypes[I] = AType then
    begin
      GridTypes.Row := I;
      GridTypes.Selected := I;
      SelectedType := FDevFilteredTypes[I];
      Break;
    end;
end;


end.
