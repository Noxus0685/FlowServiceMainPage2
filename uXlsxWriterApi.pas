unit uXlsxWriterApi;

interface

const
  XLSXWRITER_DLL = 'xlsxwriter.dll';
  LXW_ALIGN_CENTER = 2;
  LXW_BORDER_THIN = 1;

type
  Plxw_workbook = Pointer;
  Plxw_worksheet = Pointer;
  Plxw_format = Pointer;
  lxw_error = Integer;
  lxw_row_t = Cardinal;
  lxw_col_t = Word;

{ Creates a real OOXML workbook. }
function workbook_new(filename: PAnsiChar): Plxw_workbook; cdecl; external XLSXWRITER_DLL;
{ Adds a worksheet; nil uses the library default name. }
function workbook_add_worksheet(workbook: Plxw_workbook; sheetname: PAnsiChar): Plxw_worksheet; cdecl; external XLSXWRITER_DLL;
{ Allocates a workbook-owned cell format. }
function workbook_add_format(workbook: Plxw_workbook): Plxw_format; cdecl; external XLSXWRITER_DLL;
{ Finalizes the ZIP package and returns an lxw_error code. }
function workbook_close(workbook: Plxw_workbook): lxw_error; cdecl; external XLSXWRITER_DLL;
function worksheet_write_string(worksheet: Plxw_worksheet; row: lxw_row_t; col: lxw_col_t; value: PAnsiChar; format: Plxw_format): lxw_error; cdecl; external XLSXWRITER_DLL;
function worksheet_write_number(worksheet: Plxw_worksheet; row: lxw_row_t; col: lxw_col_t; value: Double; format: Plxw_format): lxw_error; cdecl; external XLSXWRITER_DLL;
function worksheet_write_boolean(worksheet: Plxw_worksheet; row: lxw_row_t; col: lxw_col_t; value: Integer; format: Plxw_format): lxw_error; cdecl; external XLSXWRITER_DLL;
function worksheet_write_formula(worksheet: Plxw_worksheet; row: lxw_row_t; col: lxw_col_t; formula: PAnsiChar; format: Plxw_format): lxw_error; cdecl; external XLSXWRITER_DLL;
function worksheet_set_column(worksheet: Plxw_worksheet; first_col, last_col: lxw_col_t; width: Double; format: Plxw_format): lxw_error; cdecl; external XLSXWRITER_DLL;
procedure worksheet_freeze_panes(worksheet: Plxw_worksheet; row: lxw_row_t; col: lxw_col_t); cdecl; external XLSXWRITER_DLL;
function worksheet_autofilter(worksheet: Plxw_worksheet; first_row: lxw_row_t; first_col: lxw_col_t; last_row: lxw_row_t; last_col: lxw_col_t): lxw_error; cdecl; external XLSXWRITER_DLL;
procedure format_set_bold(format: Plxw_format); cdecl; external XLSXWRITER_DLL;
procedure format_set_num_format(format: Plxw_format; num_format: PAnsiChar); cdecl; external XLSXWRITER_DLL;
procedure format_set_align(format: Plxw_format; alignment: Byte); cdecl; external XLSXWRITER_DLL;
procedure format_set_text_wrap(format: Plxw_format); cdecl; external XLSXWRITER_DLL;
procedure format_set_border(format: Plxw_format; border: Byte); cdecl; external XLSXWRITER_DLL;
procedure format_set_bg_color(format: Plxw_format; color: Cardinal); cdecl; external XLSXWRITER_DLL;

implementation

end.
