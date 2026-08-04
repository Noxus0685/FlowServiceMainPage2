unit uProceedXlsxExporter;

interface

uses System.Generics.Collections, System.SysUtils;

type
  TProceedExportColumn = record
    Key, Header: string;
    Width: Double;
    IsPercent: Boolean;
  end;
  TProceedExportCell = record
    Text: string;
    Number: Double;
    IsNumber: Boolean;
  end;
  TProceedExportRow = class
  public
    Cells: TList<TProceedExportCell>;
    constructor Create;
    destructor Destroy; override;
  end;
  { FMX-independent snapshot consumed by the generic OpenXML writer. }
  TProceedExportSnapshot = class
  public
    Columns: TList<TProceedExportColumn>;
    Rows: TObjectList<TProceedExportRow>;
    constructor Create;
    destructor Destroy; override;
  end;
  TProceedXlsxExporter = class
  public
    class procedure ExportToFile(ASnapshot: TProceedExportSnapshot;
      const AFileName: string); static;
  end;

implementation

uses uOpenXmlXlsx;

constructor TProceedExportRow.Create;
begin inherited; Cells := TList<TProceedExportCell>.Create; end;
destructor TProceedExportRow.Destroy;
begin Cells.Free; inherited; end;
constructor TProceedExportSnapshot.Create;
begin inherited; Columns := TList<TProceedExportColumn>.Create;
  Rows := TObjectList<TProceedExportRow>.Create(True); end;
destructor TProceedExportSnapshot.Destroy;
begin Rows.Free; Columns.Free; inherited; end;

class procedure TProceedXlsxExporter.ExportToFile(
  ASnapshot: TProceedExportSnapshot; const AFileName: string);
var W: TOpenXmlWorkbook; S: TOpenXmlWorksheet; R, C: Integer;
  Cell: TProceedExportCell;
begin
  if ASnapshot = nil then raise EArgumentNilException.Create('ASnapshot');
  W := TOpenXmlWorkbook.Create;
  try
    S := W.AddWorksheet('Обработка'); S.FreezeFirstRow; S.EnableAutoFilter;
    for C := 0 to ASnapshot.Columns.Count - 1 do begin
      S.WriteString(1, C + 1, ASnapshot.Columns[C].Header, xsHeader);
      S.SetColumnWidth(C + 1, ASnapshot.Columns[C].Width);
    end;
    for R := 0 to ASnapshot.Rows.Count - 1 do
      for C := 0 to ASnapshot.Rows[R].Cells.Count - 1 do begin
        Cell := ASnapshot.Rows[R].Cells[C];
        if Cell.IsNumber then
          S.WriteNumber(R + 2, C + 1, Cell.Number,
            xsError)
        else S.WriteString(R + 2, C + 1, Cell.Text);
      end;
    W.SaveToFile(AFileName);
  finally W.Free; end;
end;

end.
