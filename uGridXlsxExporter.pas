unit uGridXlsxExporter;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Classes, System.Math,
  uOpenXmlXlsx;

type
  TGridXlsxColumn = record
    Caption: string;
    Width: Single;
  end;

  TGridXlsxTable = class
  private
    FColumns: TList<TGridXlsxColumn>;
    FRows: TObjectList<TStringList>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddColumn(const ACaption: string; const AWidth: Single);
    function AddRow: TStringList;
    property Columns: TList<TGridXlsxColumn> read FColumns;
    property Rows: TObjectList<TStringList> read FRows;
  end;

  { Shared tabular exporter. Forms only prepare a table; OpenXML stays here. }
  TGridXlsxExporter = class
  public
    class procedure ExportToFile(ATable: TGridXlsxTable;
      const AFileName, ASheetName: string); static;
  end;

implementation

constructor TGridXlsxTable.Create;
begin
  inherited;
  FColumns := TList<TGridXlsxColumn>.Create;
  FRows := TObjectList<TStringList>.Create(True);
end;

destructor TGridXlsxTable.Destroy;
begin
  FRows.Free;
  FColumns.Free;
  inherited;
end;

procedure TGridXlsxTable.AddColumn(const ACaption: string; const AWidth: Single);
var C: TGridXlsxColumn;
begin
  C.Caption := ACaption;
  C.Width := AWidth;
  FColumns.Add(C);
end;

function TGridXlsxTable.AddRow: TStringList;
begin
  Result := TStringList.Create;
  FRows.Add(Result);
end;

class procedure TGridXlsxExporter.ExportToFile(ATable: TGridXlsxTable;
  const AFileName, ASheetName: string);
var W: TOpenXmlWorkbook; S: TOpenXmlWorksheet; R, C: Integer;
begin
  if ATable = nil then Exit;
  W := TOpenXmlWorkbook.Create;
  try
    S := W.AddWorksheet(ASheetName);
    S.FreezeFirstRow;
    S.EnableAutoFilter;
    for C := 0 to ATable.Columns.Count - 1 do
    begin
      S.WriteString(1, C + 1, ATable.Columns[C].Caption, xsHeader);
      S.SetColumnWidth(C + 1, Max(10, ATable.Columns[C].Width / 7));
    end;
    for R := 0 to ATable.Rows.Count - 1 do
      for C := 0 to ATable.Columns.Count - 1 do
        if C < ATable.Rows[R].Count then
          S.WriteString(R + 2, C + 1, ATable.Rows[R][C]);
    W.SaveToFile(AFileName);
  finally
    W.Free;
  end;
end;

end.
