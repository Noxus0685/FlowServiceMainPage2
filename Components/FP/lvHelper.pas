(*
  Вспомогательный файл для формирования страницы "результаты измерений"
*)
unit lvHelper;
interface
uses
  FMX.StdCtrls,
  FMX.Types,
  FMX.Layouts,
  FMX.Objects,
  System.UITypes,
  System.sysUtils,
  FMX.Grid;
type
  TInitColumnRecord=record
    Header:string;
    Mask:string;
    width:Integer;
    IsInteger:Boolean;
  end;

  TInitGridRecord=record
    Idx:integer;
    RowCount:Integer;
    RowHeight:Integer;
    OnGetValue:TOnGetValue;
    OnSellClick:TCellClick;
    OnDrawColumnCell:TDrawColumnCellEvent;
    Columns:array of TInitColumnRecord;
  end;

function AddTableToScrollBox(lv: TScrollBox;Idx:integer;columns:TInitGridRecord;aHeader:String):TGrid;
function AddTextToScrollBox(lv: TScrollBox;Idx:integer;aCaption:String;aValue:String):TText;
procedure ClearTextAndGridsFromScrollBox(lv: TScrollBox);
procedure RefreshResultTables(lv: TScrollBox);

implementation

uses
  System.Rtti;

procedure OnGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
//
end;

procedure RefreshResultTables(lv: TScrollBox);
var i:integer;
begin
  for i := 1 to lv.ComponentCount do
  begin
    if lv.Components[i-1] is TGrid then
    begin
       TGrid(lv.Components[i-1]).BeginUpdate;
       TGrid(lv.Components[i-1]).EndUpdate;
    end;
  end;
end;

function AddTableToScrollBox(lv: TScrollBox;Idx:integer;columns:TInitGridRecord;aHeader:String):TGrid;
var i:integer;
    ic:TIntegerColumn;
    fc:TFloatColumn;
    header:TText;
begin
  //таблица
  result:=TGrid.Create(lv);
//  TGridOption = (AlternatingRowBackground, Editing, AlwaysShowEditor, ColumnResize, ColumnMove, ColLines, RowLines,
//    RowSelect, AlwaysShowSelection, Tabs, Header, HeaderClick, CancelEditingByDefault, AutoDisplacement);
  result.Options:=result.Options-[
    TGridOption.Editing,
    TGridOption.ColumnResize,
    TGridOption.AlwaysShowSelection,
    TGridOption.HeaderClick,
    TGridOption.RowSelect,
    TGridOption.ColumnMove
  ];
  result.DefaultDrawing := False;//Включаем ручную отрисовку
  result.Name:='_ResultTableForPoint'+IntToStr(Idx+1);
  result.Parent:=lv;
  result.Tag:=Idx;
  result.Margins.Top:=1;
  result.Margins.Bottom:=10;
  result.Align:=TAlignLayout.Top;
  result.OnGetValue:=columns.OnGetValue;//заполнение клеток
  result.OnCellDblClick:=columns.OnSellClick;//на случай активации функции отключения каких то результатов
  result.OnDrawColumnCell:=columns.OnDrawColumnCell;//Перерисовка
  result.Options:=result.Options+[TGridOption.RowSelect,TGridOption.AlwaysShowSelection];
  result.Options:=result.Options-[TGridOption.Editing, TGridOption.AlwaysShowEditor,TGridOption.ColumnResize,TGridOption.ColumnMove];
  result.RowCount:=columns.RowCount;
  result.RowHeight:=columns.RowHeight;
  result.Height:=(columns.RowCount+1)*(result.RowHeight+2)+5;
  //столбцы
  //первый столбец, всегда номер записи
  for I := 1 to Length(columns.Columns) do
  begin
     if columns.Columns[i-1].IsInteger then
     begin
        ic:=TIntegerColumn.Create(result);
        ic.Parent:=Result;
        ic.HorzAlign:=TTextAlign.Center;
        ic.HeaderSettings.TextSettings.HorzAlign:=TTextAlign.Center;
        ic.Width:=columns.Columns[i-1].width;
        ic.Header:=columns.Columns[i-1].Header;
        ic.Tag:=Idx;
        if i=1 then begin
          ic.Enabled:=False;
          ic.Locked:=True;
        end;
     end
     else begin
        fc:=TFloatColumn.Create(result);
        fc.Parent:=Result;
        fc.HorzAlign:=TTextAlign.Center;
        fc.HeaderSettings.TextSettings.HorzAlign:=TTextAlign.Center;
        fc.Width:=columns.Columns[i-1].width;
        fc.Header:=columns.Columns[i-1].Header;
        fc.Tag:=Idx;
        if i=1 then fc.Enabled:=False;
     end;
  end;
  //Добавляем заголовок
  header:=TText.Create(lv);
  header.Margins.Top:=5;
  header.Margins.Bottom:=1;
  header.Text:=AHeader;
  header.Height:=14;
  header.Parent:=lv;
  header.Align:=TAlignLayout.Top;
  header.TextSettings.Font.Style:=[TFontStyle.fsBold];
  header.TextSettings.HorzAlign:=TTextAlign.Leading;
end;


function AddTextToScrollBox(lv: TScrollBox;Idx:integer;aCaption:String;aValue:String):TText;
var
  txt: TText;
  Offset: Single;
  la:TLayout;
begin
  //объединение
  la:=TLayout.Create(lv);
  la.Parent:=lv;
  la.Align:=TAlignLayout.Top;
  la.Height:=20;
  la.Padding.Top:=2;
  la.Padding.Bottom:=2;
  la.Margins.Top:=1;
  la.Margins.Bottom:=1;

  // Значение справа
  result:=TText.Create(la);
  result.Parent:=la;
  result.Align:=TAlignLayout.Right;
  result.Text:=aValue;
  result.TextSettings.HorzAlign:=TTextAlign.Trailing;
  result.Width:=150;
  result.Tag:=Idx;

  // Название слева
  txt:=TText.Create(la);
  txt.Parent:=la;
  txt.Align:=TAlignLayout.Client;
  txt.Text:=aCaption;
  txt.TextSettings.HorzAlign:=TTextAlign.Leading;

end;

procedure ClearTextAndGridsFromScrollBox(lv: TScrollBox);
var i:integer;
begin
  for I := lv.ComponentCount downto 1 do
  begin
    if lv.Components[i-1] is TGrid then
       lv.Components[i-1].Free
    else if lv.Components[i-1] is TLayout then
       lv.Components[i-1].Free
    else if lv.Components[i-1] is TText then
       lv.Components[i-1].Free;
  end;
end;

end.
