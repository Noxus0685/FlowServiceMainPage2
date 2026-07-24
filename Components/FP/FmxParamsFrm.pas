unit FmxParamsFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.ScrollBox;

type
  TfrmParams = class(TForm)
    layBottom: TLayout;
    btnOK: TButton;
    btnCancel: TButton;
    sgParamsView: TGrid;
    ParamNames: TStringColumn;
    ParamValues: TStringColumn;
    procedure sgParamsViewGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure sgParamsViewSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
  private
    FParamsCount: Integer;
    ParamName:array of string;
    ParamValue:array of Double;
    ParamWritable:array of boolean;
    function GetParamsName(Idx: Integer): String;
    function GetParamsValue(Idx: Integer): Double;
    function GetParamsWritable(Idx: Integer): boolean;
    procedure SetParamsCount(const Value: Integer);
    procedure SetParamsName(Idx: Integer; const Value: String);
    procedure SetParamsValue(Idx: Integer; const Value: Double);
    procedure SetParamsWritable(Idx: Integer; const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    property ParamsCount:Integer read FParamsCount write SetParamsCount;
    property ParamsWritable[Idx:Integer]:boolean read GetParamsWritable write SetParamsWritable;
    property ParamsName[Idx:Integer]:String read GetParamsName write SetParamsName;
    property ParamsValue[Idx:Integer]:Double read GetParamsValue write SetParamsValue;
  end;

var
  frmParams: TfrmParams;

implementation

uses FmxHelper;

{$R *.fmx}

{ TfrmParams }


function TfrmParams.GetParamsName(Idx: Integer): String;
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      result:=ParamName[Idx]
   else
      result:='';
end;

function TfrmParams.GetParamsValue(Idx: Integer): Double;
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      result:=ParamValue[Idx]
   else
      result:=0.0;
end;

function TfrmParams.GetParamsWritable(Idx: Integer): boolean;
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      result:=ParamWritable[Idx]
   else
      result:=False;
end;

procedure TfrmParams.SetParamsCount(const Value: Integer);
begin
  FParamsCount := Value;
  sgParamsView.RowCount:=Value;
  SetLength(ParamWritable,Value);
  SetLength(ParamName,Value);
  SetLength(ParamValue,Value);
  ClientHeight:=(80+Value*24);
end;

procedure TfrmParams.SetParamsName(Idx: Integer; const Value: String);
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      ParamName[Idx]:=Value;
end;

procedure TfrmParams.SetParamsValue(Idx: Integer; const Value: Double);
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      ParamValue[Idx]:=Value;
end;

procedure TfrmParams.SetParamsWritable(Idx: Integer; const Value: boolean);
begin
   if (Idx >=Low(ParamName)) and (Idx <=High(ParamName)) then
      ParamWritable[Idx]:=Value;
end;

procedure TfrmParams.sgParamsViewGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
begin
  case ACol of
  0: Value:=ParamsName[ARow];
  1: Value:=FloatToStr(ParamsValue[ARow]);
  end;
end;

procedure TfrmParams.sgParamsViewSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
begin
  ParamsValue[ARow]:=StrToFloatDef(CP(Value.AsString),ParamsValue[ARow]);
end;

end.
