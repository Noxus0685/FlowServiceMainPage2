unit WebBrowserHelper;

interface

uses
  System.SysUtils, System.Classes, FMX.WebBrowser, System.IOUtils;

type
  TWebBrowserHelper = class
  private
    class var FLastHTML: string;
  public
    class procedure LoadHTML(AWebBrowser: TWebBrowser; const AHTML: string);
    class function GetHTML(AWebBrowser: TWebBrowser): string;
  end;

implementation

{ TWebBrowserHelper }

class procedure TWebBrowserHelper.LoadHTML(AWebBrowser: TWebBrowser; const AHTML: string);
var
  TempFile: string;
begin
  FLastHTML := AHTML;

  if not Assigned(AWebBrowser) then
    Exit;

  {$IFDEF MSWINDOWS}
  try
    AWebBrowser.LoadFromStrings(AHTML, TEncoding.UTF8,'about:blank');
  except
    // Fallback to file method
    TempFile := TPath.GetTempPath + 'webreport_temp.html';
    TFile.WriteAllText(TempFile, AHTML,TEncoding.UTF8);
    AWebBrowser.Navigate('file://' + TempFile);
  end;
  {$ELSE}
  TempFile := TPath.Combine(TPath.GetTempPath, 'webreport_temp.html');
  TFile.WriteAllText(TempFile, AHTML, TEncoding.UTF8);
  AWebBrowser.Navigate('file://' + TempFile);
  {$ENDIF}
end;

class function TWebBrowserHelper.GetHTML(AWebBrowser: TWebBrowser): string;
begin
  // Всегда возвращаем сохраненный HTML
  Result := FLastHTML;
end;

end.
