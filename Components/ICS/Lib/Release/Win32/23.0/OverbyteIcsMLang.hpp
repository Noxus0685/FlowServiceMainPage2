// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsMLang.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsMLangHPP
#define OverbyteIcsMLangHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <Winapi.Windows.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsmlang
{
//-- forward type declarations -----------------------------------------------
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE bool __fastcall Load_MLang();
extern DELPHI_PACKAGE HRESULT __fastcall ConvertINetString(unsigned &lpdwMode, unsigned dwSrcEncoding, unsigned dwDstEncoding, char * lpSrcStr, int &lpnSrcSize, Winapi::Windows::PByte lpDstStr, int &lpnDstSize);
extern DELPHI_PACKAGE HRESULT __fastcall ConvertINetMultibyteToUnicode(unsigned &lpdwMode, unsigned dwSrcEncoding, char * lpSrcStr, int &lpnMultiCharCount, System::WideChar * lpDstStr, int &lpnWideCharCount);
extern DELPHI_PACKAGE HRESULT __fastcall ConvertINetUnicodeToMultibyte(unsigned &lpdwMode, unsigned dwEncoding, System::WideChar * lpSrcStr, int &lpnWideCharCount, char * lpDstStr, int &lpnMultiCharCount);
extern DELPHI_PACKAGE HRESULT __fastcall IsConvertINetStringAvailable(unsigned dwSrcEncoding, unsigned dwDstEncoding);
}	/* namespace Overbyteicsmlang */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSMLANG)
using namespace Overbyteicsmlang;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsMLangHPP
