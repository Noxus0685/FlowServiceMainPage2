unit frmProceeding;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.StdCtrls, FMX.Layouts, FMX.TreeView,
  FMX.Grid, FMX.ActnList,
  UnitWorkTable, UnitDeviceClass;

type
  TFrameProceeding = class(TFrame)
    LayoutRoot: TLayout;
    ToolBarSession: TToolBar;
    LabelSessionDate: TLabel;
    ButtonSessionNew: TButton;
    ButtonSessionClose: TButton;
    ButtonSessionDeleteDataPoint: TButton;
    ButtonSessionClearPoints: TButton;
    Splitter1: TSplitter;
    TreeViewDevices: TTreeView;
    GridDataPoints: TGrid;
    ColNum: TStringColumn;
    ColDateTime: TStringColumn;
    ColEtalon: TStringColumn;
    ColError: TStringColumn;
    ActionListSession: TActionList;
    ActionSessionNew: TAction;
    ActionSessionClose: TAction;
    ActionSessionPointDelete: TAction;
    ActionSessionPointsClear: TAction;
    procedure TreeViewDevicesChange(Sender: TObject);
    procedure ActionSessionNewExecute(Sender: TObject);
    procedure ActionSessionCloseExecute(Sender: TObject);
    procedure ActionSessionPointDeleteExecute(Sender: TObject);
    procedure ActionSessionPointsClearExecute(Sender: TObject);
  private
    FWorkTableManager: TWorkTableManager;
    FWorkTable: TWorkTable;
    FCurrentPoints: TArray<TPointSpillage>;
    function ExtractDevicesFromWorkTable(AWorkTable: TWorkTable): TList<TDevice>;
    procedure PopulateTree;
    procedure PopulatePointsForDevice(ADevice: TDevice);
    procedure PopulatePointsForSession(ASession: TSessionSpillage);
    procedure UpdateSessionDateLabel(ASession: TSessionSpillage);
    function ResolveSelectedDevice: TDevice;
    function ResolveSelectedSession: TSessionSpillage;
    procedure SaveDevice(ADevice: TDevice);
  public
    procedure SetWorkTableManager(AManager: TWorkTableManager);
    procedure SetWorkTable(AWorkTable: TWorkTable);
  end;

implementation

uses
  UnitDataManager, UnitRepositories;

{$R *.fmx}

procedure TFrameProceeding.ActionSessionCloseExecute(Sender: TObject);
var
  Session: TSessionSpillage;
  Device: TDevice;
begin
  Session := ResolveSelectedSession;
  Device := ResolveSelectedDevice;
  if (Session = nil) or (Device = nil) then
    Exit;

  Session.DateTimeClose := Now;
  Session.Active := False;
  if Session.State = osClean then
    Session.State := osModified;

  SaveDevice(Device);
  PopulateTree;
end;

procedure TFrameProceeding.ActionSessionNewExecute(Sender: TObject);
var
  Device: TDevice;
  Session: TSessionSpillage;
begin
  Device := ResolveSelectedDevice;
  if Device = nil then
    Exit;

  Session := Device.AddSessionSpillage;
  if Session <> nil then
  begin
    Session.DateTimeOpen := Now;
    Session.DateTimeClose := 0;
    Session.Status := 0;
  end;

  SaveDevice(Device);
  PopulateTree;
end;

procedure TFrameProceeding.ActionSessionPointDeleteExecute(Sender: TObject);
var
  Device: TDevice;
  Session: TSessionSpillage;
  Point: TPointSpillage;
  I: Integer;
begin
  if (GridDataPoints = nil) or (GridDataPoints.Selected < 0) or
    (GridDataPoints.Selected >= Length(FCurrentPoints)) then
    Exit;

  Point := FCurrentPoints[GridDataPoints.Selected];
  if Point = nil then
    Exit;

  Device := ResolveSelectedDevice;
  Session := ResolveSelectedSession;
  if Device = nil then
    Exit;

  if Device.Spillages <> nil then
    for I := Device.Spillages.Count - 1 downto 0 do
      if (Device.Spillages[I] <> nil) and (Device.Spillages[I].ID = Point.ID) then
        Device.Spillages.Delete(I);

  if (Session <> nil) and (Session.Spillages <> nil) then
    for I := Session.Spillages.Count - 1 downto 0 do
      if (Session.Spillages[I] <> nil) and (Session.Spillages[I].ID = Point.ID) then
        Session.Spillages.Delete(I);

  SaveDevice(Device);

  if Session <> nil then
    PopulatePointsForSession(Session)
  else
    PopulatePointsForDevice(Device);
end;

procedure TFrameProceeding.ActionSessionPointsClearExecute(Sender: TObject);
var
  Device: TDevice;
  Session: TSessionSpillage;
  I: Integer;
begin
  Device := ResolveSelectedDevice;
  Session := ResolveSelectedSession;
  if (Device = nil) or (Session = nil) then
    Exit;

  if Device.Spillages <> nil then
    for I := Device.Spillages.Count - 1 downto 0 do
      if (Device.Spillages[I] <> nil) and (Device.Spillages[I].SessionID = Session.ID) then
        Device.Spillages.Delete(I);

  if Session.Spillages <> nil then
    Session.Spillages.Clear;

  if Session.State = osClean then
    Session.State := osModified;

  SaveDevice(Device);
  PopulatePointsForSession(Session);
end;

function TFrameProceeding.ExtractDevicesFromWorkTable(
  AWorkTable: TWorkTable): TList<TDevice>;
var
  Ch: TChannel;
  Device: TDevice;
  Added: TDictionary<string, Byte>;
  Key: string;
begin
  Result := TList<TDevice>.Create;
  Added := TDictionary<string, Byte>.Create;
  try
    if (AWorkTable = nil) or (AWorkTable.DeviceChannels = nil) then
      Exit;

    for Ch in AWorkTable.DeviceChannels do
    begin
      if (Ch = nil) or (Ch.FlowMeter = nil) then
        Continue;

      Device := Ch.FlowMeter.Device;
      if Device = nil then
        Continue;

      Key := Device.UUID;
      if Key = '' then
        Key := IntToStr(Device.ID);

      if Added.ContainsKey(Key) then
        Continue;

      Added.Add(Key, 1);
      Result.Add(Device);
    end;
  finally
    Added.Free;
  end;
end;

procedure TFrameProceeding.PopulatePointsForDevice(ADevice: TDevice);
var
  P: TPointSpillage;
  Row: Integer;
begin
  SetLength(FCurrentPoints, 0);
  GridDataPoints.RowCount := 0;
  UpdateSessionDateLabel(nil);

  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  SetLength(FCurrentPoints, ADevice.Spillages.Count);
  GridDataPoints.RowCount := ADevice.Spillages.Count;

  Row := 0;
  for P in ADevice.Spillages do
  begin
    FCurrentPoints[Row] := P;
    GridDataPoints.Cells[0, Row] := IntToStr(P.Num);
    GridDataPoints.Cells[1, Row] := DateTimeToStr(P.DateTime);
    GridDataPoints.Cells[2, Row] := P.EtalonName;
    GridDataPoints.Cells[3, Row] := FloatToStr(P.Error);
    Inc(Row);
  end;
end;

procedure TFrameProceeding.PopulatePointsForSession(ASession: TSessionSpillage);
var
  P: TPointSpillage;
  Row: Integer;
begin
  SetLength(FCurrentPoints, 0);
  GridDataPoints.RowCount := 0;
  UpdateSessionDateLabel(ASession);

  if (ASession = nil) or (ASession.Spillages = nil) then
    Exit;

  SetLength(FCurrentPoints, ASession.Spillages.Count);
  GridDataPoints.RowCount := ASession.Spillages.Count;

  Row := 0;
  for P in ASession.Spillages do
  begin
    FCurrentPoints[Row] := P;
    GridDataPoints.Cells[0, Row] := IntToStr(P.Num);
    GridDataPoints.Cells[1, Row] := DateTimeToStr(P.DateTime);
    GridDataPoints.Cells[2, Row] := P.EtalonName;
    GridDataPoints.Cells[3, Row] := FloatToStr(P.Error);
    Inc(Row);
  end;
end;

procedure TFrameProceeding.PopulateTree;
var
  Devices: TList<TDevice>;
  Device: TDevice;
  Session: TSessionSpillage;
  DeviceItem: TTreeViewItem;
  SessionItem: TTreeViewItem;
begin
  TreeViewDevices.Clear;
  Devices := ExtractDevicesFromWorkTable(FWorkTable);
  try
    for Device in Devices do
    begin
      DeviceItem := TTreeViewItem.Create(TreeViewDevices);
      DeviceItem.Text := Device.Name;
      DeviceItem.TagObject := Device;
      TreeViewDevices.AddObject(DeviceItem);

      if Device.Sessions <> nil then
        for Session in Device.Sessions do
        begin
          SessionItem := TTreeViewItem.Create(DeviceItem);
          SessionItem.Text := Format('Сессия #%d', [Session.ID]);
          SessionItem.TagObject := Session;
          DeviceItem.AddObject(SessionItem);
        end;

      DeviceItem.Expand;
    end;
  finally
    Devices.Free;
  end;
end;

procedure TFrameProceeding.SaveDevice(ADevice: TDevice);
var
  Repo: TDeviceRepository;
begin
  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if (Repo <> nil) and (ADevice <> nil) then
    Repo.SaveDevice(ADevice);
end;

procedure TFrameProceeding.SetWorkTable(AWorkTable: TWorkTable);
begin
  FWorkTable := AWorkTable;
  PopulateTree;
  GridDataPoints.RowCount := 0;
  SetLength(FCurrentPoints, 0);
  UpdateSessionDateLabel(nil);
end;

procedure TFrameProceeding.SetWorkTableManager(AManager: TWorkTableManager);
begin
  FWorkTableManager := AManager;
end;

procedure TFrameProceeding.TreeViewDevicesChange(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  Item := TreeViewDevices.Selected;
  if Item = nil then
    Exit;

  if Item.TagObject is TSessionSpillage then
    PopulatePointsForSession(TSessionSpillage(Item.TagObject))
  else if Item.TagObject is TDevice then
    PopulatePointsForDevice(TDevice(Item.TagObject));
end;

procedure TFrameProceeding.UpdateSessionDateLabel(ASession: TSessionSpillage);
begin
  if ASession = nil then
    LabelSessionDate.Text := 'Сессия'
  else if ASession.DateTimeClose > 0 then
    LabelSessionDate.Text := Format('Сессия: %s - %s',
      [DateTimeToStr(ASession.DateTimeOpen), DateTimeToStr(ASession.DateTimeClose)])
  else
    LabelSessionDate.Text := Format('Сессия: %s - ...',
      [DateTimeToStr(ASession.DateTimeOpen)]);
end;

function TFrameProceeding.ResolveSelectedDevice: TDevice;
var
  Item: TTreeViewItem;
begin
  Result := nil;
  Item := TreeViewDevices.Selected;
  while Item <> nil do
  begin
    if Item.TagObject is TDevice then
      Exit(TDevice(Item.TagObject));
    Item := Item.ParentItem;
  end;
end;

function TFrameProceeding.ResolveSelectedSession: TSessionSpillage;
var
  Item: TTreeViewItem;
begin
  Result := nil;
  Item := TreeViewDevices.Selected;
  if (Item <> nil) and (Item.TagObject is TSessionSpillage) then
    Result := TSessionSpillage(Item.TagObject);
end;

end.
