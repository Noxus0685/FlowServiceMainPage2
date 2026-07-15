
unit uCardItem;

interface

uses
  System.SysUtils, System.Classes,
  FMX.Objects, FMX.Layouts,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, System.Actions, FMX.ActnList, System.ImageList,
  idTCPClient, FMX.ImgList, FMX.Controls.Presentation,uFloatEdit,
  uErrorIndicator,
  FMX.Styles;

const
  cPlacenumberStyle='placenumber';
  cErrorStyle='error';
  cVolumeStyle='volume';
  cOutlayStyle='outlay';
  cHardwareStyle='hardware';
  cSetupButtonStyle='setupbutton';
  cCardBodyStyle='cardbody';

type
  TCardItem = class(TStyledControl)
  private
    FSetupButton:TCornerButton;
    FError:TErrorIndicator;
    FHardware :TText;//Заводской номер
    sHardwareText:String;
    FPlace: integer;
    FVolume :TFloatEdit;//Объем
    FOutlay :TFloatEdit;//Расход
    FCardBody:TLayout;
    FOnSetupClick: TNotifyEvent;
    FActive: boolean;
    FCardStyleName: String;
    procedure HandleSetupClick(Sender: TObject);
    procedure ApplyStyle;
    function GetHardware: string;
    function GetOutlay: Double;
    function GetVolume: Double;
    procedure SetHardware(const Value: string);
    procedure SetActive(const Value: boolean);
    procedure SetPlace(const Value: integer);
    procedure SetCardStyleName(const Value: String);
    procedure SetOutlay(const Value: Double);
    procedure SetVolume(const Value: Double);
    function GetError: Double;
    procedure SetError(const Value: Double);
    { Private declarations }
  protected
    { Protected declarations }
    procedure ApplyStyleLookup; override;
  public
    constructor Create(AOwner: TComponent); override;
    //procedure DiagnoseEnabledChain;
    { Public declarations }
  published
    { Published declarations }
    property Volume: Double read GetVolume write SetVolume;
    property Outlay: Double read GetOutlay write SetOutlay;
    property Error: Double read GetError write SetError;
    property Hardware: string read GetHardware write SetHardware;
    property OnSetupClick: TNotifyEvent read FOnSetupClick write FOnSetupClick;
    property Active:boolean read FActive write SetActive;
    property Place:integer read FPlace write SetPlace;
    property CardStyleName:String read FCardStyleName write SetCardStyleName;
    property Align;
    property Width;
    property Height;
    property Left;
    property Top;
    property Scale;
 end;

procedure Register;

implementation

uses FmxHelper;

procedure Register;
begin
  RegisterComponents('FP', [TCardItem]);
end;

procedure TCardItem.ApplyStyleLookup;
begin
  inherited;
  ApplyStyle;
end;

constructor TCardItem.Create(AOwner: TComponent);
begin
  inherited;
  Width:=100;
  Height:=140;
//  Scale.x:=0.8;
//  Scale.y:=0.8;
  // Установка StyleLookup по умолчанию при создании компонента
  CardStyleName := 'simplecard';
  Place:=1;

end;

function TCardItem.GetError: Double;
begin
  if Assigned(FError) then
     result:=FError.CurrentError
  else
     result:=0;
end;

function TCardItem.GetHardware: string;
begin
  if Assigned(FHardware) then
     result:=FHardware.Text
  else
     result:='--------';
end;

function TCardItem.GetOutlay: Double;
begin
  if Assigned(FOutlay) then
     result:=FOutlay.value
  else
     result:=0;
end;


function TCardItem.GetVolume: Double;
begin
  if Assigned(FVolume) then
     result:=FVolume.value
  else
     result:=0;
end;

procedure TCardItem.HandleSetupClick(Sender: TObject);
begin
   if Assigned(OnSetupClick) then
      OnSetupClick(self);
end;

procedure TCardItem.SetActive(const Value: boolean);
begin
  FActive := Value;
  if Assigned(FCardBody) then
     FCardBody.Visible:=Value;
end;

procedure TCardItem.SetCardStyleName(const Value: String);
begin
  FCardStyleName := Value;
  StyleLookup := Value;
end;

procedure TCardItem.SetError(const Value: Double);
begin
  if Assigned(FError) then
     FError.CurrentError:=Value;
end;

procedure TCardItem.SetHardware(const Value: string);
begin
  if Assigned(FHardware) then
     FHardware.Text:=Value;
end;

procedure TCardItem.SetOutlay(const Value: Double);
begin
  if Assigned(FOutlay) then
     FOutlay.Value:=Value;
end;

procedure TCardItem.SetPlace(const Value: integer);
begin
  FPlace := Value;
  if Assigned(Fsetupbutton) then
     Fsetupbutton.text:=Format('Место № %d',[FPlace]);
end;

procedure TCardItem.SetVolume(const Value: Double);
begin
  if Assigned(FVolume) then
     FVolume.Value:=Value;
end;

procedure TCardItem.ApplyStyle;
var
  Obj: TFmxObject;
begin
  FVolume :=nil;//Объем
  FOutlay :=nil;//Расход
  FHardware :=nil;//Заводской номер
  FSetupButton:=nil;
  FError:=nil;
  FCardBody:=nil;

  Obj := FindStyleResource(cVolumeStyle);
  if (Obj <> nil) and (Obj is TFloatEdit) then
    FVolume := TFloatEdit(Obj);
  Obj := FindStyleResource(cOutlayStyle);
  if (Obj <> nil) and (Obj is TFloatEdit) then
    FOutlay := TFloatEdit(Obj);
  Obj := FindStyleResource(cHardwareStyle);
  if (Obj <> nil) and (Obj is TText) then
    FHardware := TText(Obj);
  Obj := FindStyleResource(cSetupButtonStyle);
  if (Obj <> nil) and (Obj is TCornerButton) then
  begin
   FSetupButton:=TCornerButton(obj);
   FSetupButton.OnClick := HandleSetupClick;
   FSetupButton.Enabled := True;
   FSetupButton.Visible := True;
   FSetupButton.HitTest := True;
  end;
  Obj := FindStyleResource(cCardBodyStyle);
  if (Obj <> nil) and (Obj is TLayout) then
   FCardBody:=TLayout(obj);
  Obj := FindStyleResource(cErrorStyle);
  if (Obj <> nil) and (Obj is TErrorIndicator) then
   FError:=TErrorIndicator(obj);

  if Assigned(FSetupButton) then
  begin
    if FSetupButton.Enabled then
       OutputDebugMessage('SetupButton Enabled')
    else
       OutputDebugMessage('SetupButton Disabled');
  end
  else
    OutputDebugMessage('SetupButton NOT found');

  Self.Enabled := True;
  Self.HitTest := True;
end;

//procedure TCardItem.DiagnoseEnabledChain;
//var
//  Ctrl: TFmxObject;
//  Level: Integer;
//begin
//  Ctrl := Self;
//  Level := 0;
//  while Ctrl <> nil do
//  begin
//    OutputDebugMessage(PChar(Format('Level %d: %s, Name=%s,Enabled=%s, HitTest=%s',
//      [Level, Ctrl.ClassName,Ctrl.Name, BoolToStr(TControl(Ctrl).Enabled, 'True','False'), BoolToStr(TControl(Ctrl).HitTest, 'True','False')])));
//    Ctrl := Ctrl.Parent;
//    Inc(Level);
//    if Level > 20 then Break; // защита от бесконечности
//  end;
//end;

end.
