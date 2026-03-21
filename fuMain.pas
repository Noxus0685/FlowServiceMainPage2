unit fuMain;

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.TabControl,
  frmProceed,
  frmMainTable,
  UnitWorkTable;

type
  TFormMain = class(TForm)
    TabControl1: TTabControl;
    TabItemTable: TTabItem;
    TabItemResults: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
  private
    FWorkTableManager: TWorkTableManager;
    FFrameProceed: TFrameProceed;
    FFrameMainTable: TFrameMainTable;
  public
    procedure SetSessionDim(const UnitName, QuantityUnitName: string);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FFrameMainTable := TFrameMainTable.Create(Self);
  FFrameMainTable.Parent := TabItemTable;
  FFrameMainTable.Align := TAlignLayout.Client;
  FFrameMainTable.Initialize;

  FWorkTableManager := FFrameMainTable.WorkTableManager;

  FFrameProceed := TFrameProceed.Create(Self);
  FFrameProceed.Parent := TabItemResults;
  FFrameProceed.Align := TAlignLayout.Client;
  FFrameProceed.Initialize(FWorkTableManager);
end;

procedure TFormMain.SetSessionDim(const UnitName, QuantityUnitName: string);
begin
  if FFrameProceed <> nil then
    FFrameProceed.SetSessionDim(UnitName, QuantityUnitName);
end;

procedure TFormMain.TabControl1Change(Sender: TObject);
begin
  if (TabControl1.ActiveTab = TabItemResults) and (FFrameProceed <> nil) then
    FFrameProceed.RefreshResultsTab;
end;

end.
