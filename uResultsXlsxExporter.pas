unit uResultsXlsxExporter;

interface

uses
  System.Generics.Collections, uDeviceClass;

type
  TResultsXlsxExporter = class
  private
    class procedure WriteText(ASheet: Pointer; ARow, ACol: Integer;
      const AText: string; AFormat: Pointer); static;
  public
    { Exports domain objects, never visual grid/tree contents. }
    class function Export(const AFileName: string; ADevices: TList<TDevice>;
      out AResultCount: Integer; out ASessionIDs: string): Integer; static;
  end;

implementation

uses
  System.SysUtils, uXlsxWriterApi;

class procedure TResultsXlsxExporter.WriteText(ASheet: Pointer; ARow,
  ACol: Integer; const AText: string; AFormat: Pointer);
var U: UTF8String;
begin
  U := UTF8String(AText);
  worksheet_write_string(ASheet, ARow, ACol, PAnsiChar(U), AFormat);
end;

class function TResultsXlsxExporter.Export(const AFileName: string;
  ADevices: TList<TDevice>; out AResultCount: Integer;
  out ASessionIDs: string): Integer;
const
  Headers: array[0..13] of string = ('Номер', 'Прибор', 'Серийный номер',
    'UUID прибора', 'ID сессии', 'Название точки', 'Расход эталона',
    'Эталон', 'UUID эталона', 'Значение прибора', 'Погрешность', 'Статус',
    'Валидность', 'Дата/время');
var
  Book: Plxw_workbook; SessionsSheet, DevicesSheet, ResultsSheet: Plxw_worksheet;
  HeaderFmt, CellFmt, NumberFmt, ErrorFmt: Plxw_format;
  FileUtf8, SheetUtf8, NumUtf8: UTF8String;
  D: TDevice; S: TSessionSpillage; P: TPointSpillage;
  I, Row, DeviceRow, SessionRow: Integer;
begin
  Result := -1; AResultCount := 0; ASessionIDs := '';
  FileUtf8 := UTF8String(AFileName);
  Book := workbook_new(PAnsiChar(FileUtf8));
  if Book = nil then Exit;
  HeaderFmt := workbook_add_format(Book); CellFmt := workbook_add_format(Book);
  NumberFmt := workbook_add_format(Book); ErrorFmt := workbook_add_format(Book);
  format_set_bold(HeaderFmt); format_set_bg_color(HeaderFmt, $D9EAF7);
  format_set_align(HeaderFmt, LXW_ALIGN_CENTER); format_set_text_wrap(HeaderFmt);
  format_set_border(HeaderFmt, LXW_BORDER_THIN); format_set_border(CellFmt, LXW_BORDER_THIN);
  format_set_border(NumberFmt, LXW_BORDER_THIN); format_set_border(ErrorFmt, LXW_BORDER_THIN);
  NumUtf8 := '0.000'; format_set_num_format(NumberFmt, PAnsiChar(NumUtf8));
  NumUtf8 := '0.000%'; format_set_num_format(ErrorFmt, PAnsiChar(NumUtf8));
  SheetUtf8 := UTF8String('Сессия'); SessionsSheet := workbook_add_worksheet(Book, PAnsiChar(SheetUtf8));
  SheetUtf8 := UTF8String('Приборы'); DevicesSheet := workbook_add_worksheet(Book, PAnsiChar(SheetUtf8));
  SheetUtf8 := UTF8String('Результаты'); ResultsSheet := workbook_add_worksheet(Book, PAnsiChar(SheetUtf8));
  WriteText(SessionsSheet, 0, 0, 'UUID прибора', HeaderFmt); WriteText(SessionsSheet, 0, 1, 'ID сессии', HeaderFmt);
  WriteText(DevicesSheet, 0, 0, 'Прибор', HeaderFmt); WriteText(DevicesSheet, 0, 1, 'Серийный номер', HeaderFmt); WriteText(DevicesSheet, 0, 2, 'UUID прибора', HeaderFmt);
  for I := 0 to High(Headers) do WriteText(ResultsSheet, 0, I, Headers[I], HeaderFmt);
  Row := 1; DeviceRow := 1; SessionRow := 1;
  for D in ADevices do
  begin
    if D = nil then Continue;
    WriteText(DevicesSheet, DeviceRow, 0, D.Name, CellFmt); WriteText(DevicesSheet, DeviceRow, 1, D.SerialNumber, CellFmt); WriteText(DevicesSheet, DeviceRow, 2, D.UUID, CellFmt); Inc(DeviceRow);
    S := D.GetActiveSessionSpillage;
    if S = nil then Continue;
    if ASessionIDs <> '' then ASessionIDs := ASessionIDs + ',';
    ASessionIDs := ASessionIDs + IntToStr(S.ID);
    WriteText(SessionsSheet, SessionRow, 0, D.UUID, CellFmt); worksheet_write_number(SessionsSheet, SessionRow, 1, S.ID, CellFmt); Inc(SessionRow);
    if D.Spillages = nil then Continue;
    for P in D.Spillages do
      if (P <> nil) and (P.SessionID = S.ID) then
      begin
        worksheet_write_number(ResultsSheet, Row, 0, P.Num, CellFmt);
        WriteText(ResultsSheet, Row, 1, D.Name, CellFmt); WriteText(ResultsSheet, Row, 2, D.SerialNumber, CellFmt);
        WriteText(ResultsSheet, Row, 3, D.UUID, CellFmt); worksheet_write_number(ResultsSheet, Row, 4, S.ID, CellFmt);
        WriteText(ResultsSheet, Row, 5, P.Name, CellFmt); worksheet_write_number(ResultsSheet, Row, 6, P.QavgEtalon, NumberFmt);
        WriteText(ResultsSheet, Row, 7, P.EtalonName, CellFmt); WriteText(ResultsSheet, Row, 8, P.EtalonUUID, CellFmt);
        worksheet_write_number(ResultsSheet, Row, 9, P.DeviceVolumeFlow, NumberFmt);
        worksheet_write_number(ResultsSheet, Row, 10, P.Error / 100, ErrorFmt); WriteText(ResultsSheet, Row, 11, P.StatusStr, CellFmt);
        worksheet_write_boolean(ResultsSheet, Row, 12, Ord(P.Valid), CellFmt);
        worksheet_write_number(ResultsSheet, Row, 13, P.DateTime, CellFmt);
        Inc(Row); Inc(AResultCount);
      end;
  end;
  worksheet_freeze_panes(ResultsSheet, 1, 0);
  if Row > 1 then worksheet_autofilter(ResultsSheet, 0, 0, Row - 1, High(Headers));
  worksheet_set_column(ResultsSheet, 0, 0, 9, nil); worksheet_set_column(ResultsSheet, 1, 5, 20, nil);
  worksheet_set_column(ResultsSheet, 6, 13, 18, nil);
  worksheet_freeze_panes(SessionsSheet, 1, 0); worksheet_freeze_panes(DevicesSheet, 1, 0);
  Result := workbook_close(Book);
end;

end.
