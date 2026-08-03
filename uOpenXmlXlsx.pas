unit uOpenXmlXlsx;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Zip,
  System.DateUtils, System.Math;

type
  TXlsxCellKind = (xckString, xckNumber, xckDate, xckBoolean);
  TXlsxStyle = (xsText, xsHeader, xsNumber, xsFlow, xsError, xsDateTime,
    xsBooleanStatus, xsUuid);

  { Stores one typed value and its fixed workbook style. }
  TOpenXmlCell = class
  public
    Column: Integer;
    Kind: TXlsxCellKind;
    Style: TXlsxStyle;
    TextValue: string;
    NumberValue: Double;
    BooleanValue: Boolean;
  end;

  { Owns the cells belonging to one worksheet row. }
  TOpenXmlRow = class
  private
    FCells: TObjectList<TOpenXmlCell>;
  public
    constructor Create;
    destructor Destroy; override;
    property Cells: TObjectList<TOpenXmlCell> read FCells;
  end;

  { Deduplicates text while retaining insertion-order indices. }
  TOpenXmlSharedStrings = class
  private
    FIndex: TDictionary<string, Integer>;
    FValues: TList<string>;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AValue: string): Integer;
    function ToXml: string;
    property Count: Integer read FCount;
    function UniqueCount: Integer;
  end;

  { Supplies the small, reusable style catalogue used by result exports. }
  TOpenXmlStyleTable = class
  public
    class function StyleIndex(AStyle: TXlsxStyle): Integer; static;
    class function ToXml: string; static;
  end;

  { Builds a typed worksheet without exposing OpenXML details to callers. }
  TOpenXmlWorksheet = class
  private
    FName: string;
    FRows: TObjectList<TOpenXmlRow>;
    FWidths: TDictionary<Integer, Double>;
    FFreezeFirstRow: Boolean;
    FAutoFilter: Boolean;
    function AddCell(ARow, AColumn: Integer; AKind: TXlsxCellKind;
      AStyle: TXlsxStyle): TOpenXmlCell;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    procedure WriteString(ARow, AColumn: Integer; const AValue: string;
      AStyle: TXlsxStyle = xsText);
    procedure WriteNumber(ARow, AColumn: Integer; AValue: Double;
      AStyle: TXlsxStyle = xsNumber);
    procedure WriteDateTime(ARow, AColumn: Integer; AValue: TDateTime);
    procedure WriteBoolean(ARow, AColumn: Integer; AValue: Boolean);
    procedure SetColumnWidth(AColumn: Integer; AWidth: Double);
    procedure FreezeFirstRow;
    procedure EnableAutoFilter;
    property Name: string read FName;
    property Rows: TObjectList<TOpenXmlRow> read FRows;
    property Widths: TDictionary<Integer, Double> read FWidths;
    property IsFirstRowFrozen: Boolean read FFreezeFirstRow;
    property HasAutoFilter: Boolean read FAutoFilter;
  end;

  TOpenXmlWorkbook = class;

  { Serializes workbook parts and commits the ZIP only after it is complete. }
  TOpenXmlPackageWriter = class
  public
    class procedure Save(AWorkbook: TOpenXmlWorkbook; const AFileName: string); static;
  end;

  { Owns sheets and provides the top-level API for creating a new XLSX file. }
  TOpenXmlWorkbook = class
  private
    FSheets: TObjectList<TOpenXmlWorksheet>;
    FSharedStrings: TOpenXmlSharedStrings;
  public
    constructor Create;
    destructor Destroy; override;
    function AddWorksheet(const AName: string): TOpenXmlWorksheet;
    procedure SaveToFile(const AFileName: string);
    property Worksheets: TObjectList<TOpenXmlWorksheet> read FSheets;
    property SharedStrings: TOpenXmlSharedStrings read FSharedStrings;
  end;

function XmlEscape(const AValue: string): string;
function ExcelColumnName(AColumn: Integer): string;
function ExcelDateValue(AValue: TDateTime): Double;
function ValidWorksheetName(const AName: string): Boolean;

implementation

function XmlEscape(const AValue: string): string;
begin
  Result := StringReplace(AValue, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

function ExcelColumnName(AColumn: Integer): string;
begin
  if AColumn < 1 then raise EArgumentOutOfRangeException.Create('Column must be positive');
  Result := '';
  while AColumn > 0 do begin Dec(AColumn); Result := Chr(Ord('A') + AColumn mod 26) + Result; AColumn := AColumn div 26; end;
end;

function ExcelDateValue(AValue: TDateTime): Double;
begin
  Result := AValue;
  if AValue < EncodeDate(1900, 3, 1) then Result := Result - 1; // Excel's fictitious 1900-02-29.
end;

function ValidWorksheetName(const AName: string): Boolean;
var C: Char;
begin
  Result := (AName <> '') and (Length(AName) <= 31);
  for C in AName do Result := Result and not CharInSet(C, ['\', '/', '?', '*', '[', ']', ':']);
end;

constructor TOpenXmlRow.Create; begin inherited; FCells := TObjectList<TOpenXmlCell>.Create; end;
destructor TOpenXmlRow.Destroy; begin FCells.Free; inherited; end;

constructor TOpenXmlSharedStrings.Create;
begin inherited; FIndex := TDictionary<string,Integer>.Create; FValues := TList<string>.Create; end;
destructor TOpenXmlSharedStrings.Destroy; begin FValues.Free; FIndex.Free; inherited; end;
function TOpenXmlSharedStrings.Add(const AValue: string): Integer;
begin
  Inc(FCount);
  if not FIndex.TryGetValue(AValue, Result) then begin Result := FValues.Count; FValues.Add(AValue); FIndex.Add(AValue, Result); end;
end;
function TOpenXmlSharedStrings.UniqueCount: Integer; begin Result := FValues.Count; end;
function TOpenXmlSharedStrings.ToXml: string;
var S, Space: string;
begin
  Result := Format('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="%d" uniqueCount="%d">',[FCount,FValues.Count]);
  for S in FValues do begin Space := ''; if (S <> Trim(S)) then Space := ' xml:space="preserve"'; Result := Result + '<si><t' + Space + '>' + XmlEscape(S) + '</t></si>'; end;
  Result := Result + '</sst>';
end;

class function TOpenXmlStyleTable.StyleIndex(AStyle: TXlsxStyle): Integer; begin Result := Ord(AStyle); end;
class function TOpenXmlStyleTable.ToXml: string;
begin
  Result := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'+
    '<numFmts count="3"><numFmt numFmtId="164" formatCode="0.000000"/><numFmt numFmtId="165" formatCode="0.0000%"/><numFmt numFmtId="166" formatCode="yyyy-mm-dd hh:mm:ss"/></numFmts>'+
    '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'+
    '<fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FFD9EAF7"/><bgColor indexed="64"/></patternFill></fill></fills>'+
    '<borders count="2"><border/><border><left style="thin"/><right style="thin"/><top style="thin"/><bottom style="thin"/></border></borders>'+
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="8">'+
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'+
    '<xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>'+
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0"/><xf numFmtId="164" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1"/>'+
    '<xf numFmtId="165" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1"/><xf numFmtId="166" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1"/>'+
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyAlignment="1"><alignment wrapText="1"/></xf></cellXfs></styleSheet>';
end;

constructor TOpenXmlWorksheet.Create(const AName: string);
begin inherited Create; FName:=AName; FRows:=TObjectList<TOpenXmlRow>.Create; FWidths:=TDictionary<Integer,Double>.Create; end;
destructor TOpenXmlWorksheet.Destroy; begin FWidths.Free; FRows.Free; inherited; end;
function TOpenXmlWorksheet.AddCell(ARow,AColumn:Integer; AKind:TXlsxCellKind; AStyle:TXlsxStyle):TOpenXmlCell;
begin while FRows.Count < ARow do FRows.Add(TOpenXmlRow.Create); Result:=TOpenXmlCell.Create; Result.Column:=AColumn; Result.Kind:=AKind; Result.Style:=AStyle; FRows[ARow-1].Cells.Add(Result); end;
procedure TOpenXmlWorksheet.WriteString(ARow,AColumn:Integer;const AValue:string;AStyle:TXlsxStyle); begin AddCell(ARow,AColumn,xckString,AStyle).TextValue:=AValue; end;
procedure TOpenXmlWorksheet.WriteNumber(ARow,AColumn:Integer;AValue:Double;AStyle:TXlsxStyle); begin AddCell(ARow,AColumn,xckNumber,AStyle).NumberValue:=AValue; end;
procedure TOpenXmlWorksheet.WriteDateTime(ARow,AColumn:Integer;AValue:TDateTime); begin AddCell(ARow,AColumn,xckDate,xsDateTime).NumberValue:=ExcelDateValue(AValue); end;
procedure TOpenXmlWorksheet.WriteBoolean(ARow,AColumn:Integer;AValue:Boolean); begin AddCell(ARow,AColumn,xckBoolean,xsBooleanStatus).BooleanValue:=AValue; end;
procedure TOpenXmlWorksheet.SetColumnWidth(AColumn:Integer;AWidth:Double); begin FWidths.AddOrSetValue(AColumn,AWidth); end;
procedure TOpenXmlWorksheet.FreezeFirstRow; begin FFreezeFirstRow:=True; end;
procedure TOpenXmlWorksheet.EnableAutoFilter; begin FAutoFilter:=True; end;

constructor TOpenXmlWorkbook.Create; begin inherited; FSheets:=TObjectList<TOpenXmlWorksheet>.Create; FSharedStrings:=TOpenXmlSharedStrings.Create; end;
destructor TOpenXmlWorkbook.Destroy; begin FSharedStrings.Free; FSheets.Free; inherited; end;
function TOpenXmlWorkbook.AddWorksheet(const AName:string):TOpenXmlWorksheet;
var S: TOpenXmlWorksheet;
begin if not ValidWorksheetName(AName) then raise EArgumentException.CreateFmt('Invalid worksheet name: %s',[AName]); for S in FSheets do if SameText(S.Name,AName) then raise EArgumentException.CreateFmt('Duplicate worksheet name: %s',[AName]); Result:=TOpenXmlWorksheet.Create(AName); FSheets.Add(Result); end;
procedure TOpenXmlWorkbook.SaveToFile(const AFileName:string); begin TOpenXmlPackageWriter.Save(Self,AFileName); end;

function InvFloat(AValue:Double):string;
var FS:TFormatSettings;
begin FS:=TFormatSettings.Create; FS.DecimalSeparator:='.'; FS.ThousandSeparator:=#0; Result:=FloatToStr(AValue,FS); end;
procedure AddText(AZip:TZipFile;const AName,AData:string);
var M:TMemoryStream; B:TBytes;
begin M:=TMemoryStream.Create; try B:=TEncoding.UTF8.GetBytes(AData); if Length(B)>0 then M.WriteBuffer(B[0],Length(B)); M.Position:=0; AZip.Add(M,StringReplace(AName,'\','/',[rfReplaceAll])); finally M.Free; end; end;

class procedure TOpenXmlPackageWriter.Save(AWorkbook:TOpenXmlWorkbook;const AFileName:string);
var Z:TZipFile; Temp,Xml,Types,WB,Rels:string; I,R,C,MaxCol:Integer; Sh:TOpenXmlWorksheet; Row:TOpenXmlRow; Cell:TOpenXmlCell; K:Integer;
begin
  Temp:=AFileName+'.tmp-'+FormatDateTime('yyyymmddhhnnsszzz',Now);
  Z:=TZipFile.Create;
  try
    Z.Open(Temp,zmWrite);
    Types:='<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/><Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/><Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>';
    WB:='<?xml version="1.0" encoding="UTF-8"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>';
    Rels:='<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
    for I:=0 to AWorkbook.Worksheets.Count-1 do begin Sh:=AWorkbook.Worksheets[I]; Types:=Types+Format('<Override PartName="/xl/worksheets/sheet%d.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',[I+1]); WB:=WB+Format('<sheet name="%s" sheetId="%d" r:id="rId%d"/>',[XmlEscape(Sh.Name),I+1,I+1]); Rels:=Rels+Format('<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet%d.xml"/>',[I+1,I+1]); end;
    K:=AWorkbook.Worksheets.Count+1; Rels:=Rels+Format('<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/></Relationships>',[K,K+1]);
    Types:=Types+'</Types>'; WB:=WB+'</sheets></workbook>';
    AddText(Z,'[Content_Types].xml',Types); AddText(Z,'_rels/.rels','<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/></Relationships>');
    AddText(Z,'docProps/app.xml','<?xml version="1.0" encoding="UTF-8"?><Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Application>FlowService</Application></Properties>');
    AddText(Z,'docProps/core.xml','<?xml version="1.0" encoding="UTF-8"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:creator>FlowService</dc:creator></cp:coreProperties>'); AddText(Z,'xl/workbook.xml',WB); AddText(Z,'xl/_rels/workbook.xml.rels',Rels); AddText(Z,'xl/styles.xml',TOpenXmlStyleTable.ToXml);
    for I:=0 to AWorkbook.Worksheets.Count-1 do begin Sh:=AWorkbook.Worksheets[I]; MaxCol:=1; for Row in Sh.Rows do for Cell in Row.Cells do MaxCol:=Max(MaxCol,Cell.Column); Xml:=Format('<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="A1:%s%d"/><sheetViews><sheetView workbookViewId="0">',[ExcelColumnName(MaxCol),Max(1,Sh.Rows.Count)]); if Sh.IsFirstRowFrozen then Xml:=Xml+'<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>'; Xml:=Xml+'</sheetView></sheetViews>';
      if Sh.Widths.Count>0 then begin Xml:=Xml+'<cols>'; for C in Sh.Widths.Keys do Xml:=Xml+Format('<col min="%d" max="%d" width="%s" customWidth="1"/>',[C,C,InvFloat(Sh.Widths[C])]); Xml:=Xml+'</cols>'; end; Xml:=Xml+'<sheetData>';
      for R:=0 to Sh.Rows.Count-1 do begin Row:=Sh.Rows[R]; Xml:=Xml+Format('<row r="%d">',[R+1]); for Cell in Row.Cells do begin Xml:=Xml+Format('<c r="%s%d" s="%d"',[ExcelColumnName(Cell.Column),R+1,Ord(Cell.Style)]); case Cell.Kind of xckString: begin K:=AWorkbook.SharedStrings.Add(Cell.TextValue); Xml:=Xml+Format(' t="s"><v>%d</v></c>',[K]); end; xckBoolean: if Cell.BooleanValue then Xml:=Xml+' t="b"><v>1</v></c>' else Xml:=Xml+' t="b"><v>0</v></c>'; else Xml:=Xml+'><v>'+InvFloat(Cell.NumberValue)+'</v></c>'; end; end; Xml:=Xml+'</row>'; end; Xml:=Xml+'</sheetData>'; if Sh.HasAutoFilter and (Sh.Rows.Count>0) then Xml:=Xml+Format('<autoFilter ref="A1:%s%d"/>',[ExcelColumnName(MaxCol),Sh.Rows.Count]); Xml:=Xml+'</worksheet>'; AddText(Z,Format('xl/worksheets/sheet%d.xml',[I+1]),Xml); end;
    AddText(Z,'xl/sharedStrings.xml',AWorkbook.SharedStrings.ToXml); Z.Close; Z.Free; Z:=nil;
    if FileExists(AFileName) and not DeleteFile(AFileName) then raise EInOutError.CreateFmt('Cannot replace %s',[AFileName]); if not RenameFile(Temp,AFileName) then raise EInOutError.CreateFmt('Cannot commit %s',[AFileName]);
  except
    if Assigned(Z) then begin try Z.Close except end; Z.Free; end; if FileExists(Temp) then DeleteFile(Temp); raise;
  end;
end;

end.
