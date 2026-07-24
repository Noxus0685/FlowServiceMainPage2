unit FmxBitMask;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, System.Actions, FMX.ActnList, System.ImageList,
  Messages,  Fmx.ExtCtrls;

type
  TFmxBitMask = class(TPanel)
  private
    { Private declarations }
    Body:array[0..31] of TCheckBox;
    FValue:longword;
    FSize: integer;
    fOnChange: TNotifyEvent;
    FEnabled: boolean;
    procedure SetSize(const Value: integer);
    function GetValue: longword;
    procedure SetValue(const Value: longword);
    procedure CheckBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure SetEnabled(const Value: boolean);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function GetStringFromHint(i:integer): String;
  published
    { Published declarations }
    property Size:integer read FSize write SetSize;//количество бит
    property Value:longword read GetValue write SetValue;
    property OnChange:TNotifyEvent read fOnChange write fOnChange;
    property Enabled:boolean read FEnabled write SetEnabled;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxBitMask]);
end;

{ TFmxBitMask }

constructor TFmxBitMask.Create(AOwner: TComponent);
begin
  inherited;
  FSize:=0;
  width:=121; //8бит
  height:=15;
  ShowHint:=False;
  FEnabled := True;
end;

function TFmxBitMask.GetValue: longword;
var i:integer;
begin
  result:=0;
  if Size>0 then
  for i := 0 to Size-1 do
  begin
    if Body[i].IsChecked then
       result:=result+Longword(1 shl (Size-1-i));
  end;
end;

function TFmxBitMask.GetStringFromHint(i:integer):String;
var j,c:integer;
begin
  result:='';c:=0;
  if Hint<>'' then
  for j := 1 to Length(Hint) do
  begin
    if (Hint[j]<>#13) and (Hint[j]<>#10) then
       result:=result+Hint[j]
    else if Hint[j]=#13 then
    begin
      Inc(c);
      if c>i then break
      else result:='';
    end;

  end;


end;

procedure TFmxBitMask.SetSize(const Value: integer);
var i:integer;
begin
  FSize := Value;
  if ComponentCount>0 then
  for i := ComponentCount-1 to 0 do
  begin
     if Components[i] is TCheckBox then
     begin
        RemoveComponent(Components[i]);
        Body[i]:=nil;
     end
  end;
  if FSize in [1..32] then
  begin
     for i := 0 to FSize-1 do
     begin
       Body[i]:=TCheckBox.Create(self);
       InsertComponent(Body[i]);
       Body[i].OnMouseUp:=CheckBoxMouseDown;
       Body[i].Width:=15;Body[i].HEIGHT:=15;
       Body[i].Text:='';
       Body[i].Parent:=self;
       width:=Body[i].Width*(i+1)+1;
       Body[i].Position.x:=i*Body[i].width+1;
       Body[i].Position.Y:=1;
       if Hint<>'' then
       begin
         Body[i].Hint:=GetStringFromHint(Size-i-1);
         Body[i].ShowHint:=True;
       end;

       Height:=Body[i].Height+2;
    end;
 end;
end;

procedure TFmxBitMask.SetValue(const Value: longword);
var i:integer;
begin
  FValue:=Value;
  if Size>0 then
  for i := 0 to Size-1 do
  begin
    Body[i].IsChecked := (Value and Longword(1 shl (Size-1-i))) <> 0;
  end;
end;

procedure TFmxBitMask.CheckBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
begin
  if csDesigning in ComponentState then Exit;
  if not Enabled then Exit;
  if Value<>FValue then
  case MessageDlg('Вы хотите изменить значение параметра?',  TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) of
    mrYes:
      begin
        FValue:=Value;
        if Assigned(FOnChange) then FOnChange(self);
      end;
    mrNo:
      begin
        Value:=FValue;
      end;
  end;
end;



procedure TFmxBitMask.SetEnabled(const Value: boolean);
var i:integer;
begin
  FEnabled := Value;
  if csDesigning in ComponentState then Exit;
  for i := 0 to Size-1 do
  begin
    Body[i].Enabled := Value;
  end;
end;

end.
