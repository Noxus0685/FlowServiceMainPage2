@echo off
setlocal EnableDelayedExpansion
set "ROOT=%~dp0"
if not defined VCPKG_ROOT set "VCPKG_ROOT=%ROOT%vcpkg"
if not exist "%VCPKG_ROOT%\vcpkg.exe" (
  echo Set VCPKG_ROOT to an existing vcpkg installation.
  exit /b 1
)
call "%VCPKG_ROOT%\vcpkg.exe" install libxlsxwriter:x86-windows libxlsxwriter:x64-windows || exit /b 1
for %%A in (x86 x64) do (
  if "%%A"=="x86" (set "DEST=Win32") else (set "DEST=Win64")
  if not exist "%ROOT%ThirdParty\libxlsxwriter\!DEST!" mkdir "%ROOT%ThirdParty\libxlsxwriter\!DEST!"
  copy /Y "%VCPKG_ROOT%\installed\%%A-windows\bin\xlsxwriter.dll" "%ROOT%ThirdParty\libxlsxwriter\!DEST!\" || exit /b 1
  copy /Y "%VCPKG_ROOT%\installed\%%A-windows\bin\zlib1.dll" "%ROOT%ThirdParty\libxlsxwriter\!DEST!\" || exit /b 1
)
endlocal
