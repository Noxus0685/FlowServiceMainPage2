// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsWinnls.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsWinnlsHPP
#define OverbyteIcsWinnlsHPP

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

namespace Overbyteicswinnls
{
//-- forward type declarations -----------------------------------------------
//-- type declarations -------------------------------------------------------
enum DECLSPEC_DENUM _NORM_FORM : unsigned int { NormalizationOther, NormalizationC, NormalizationD, NormalizationKC = 5, NormalizationKD };

typedef _NORM_FORM NORM_FORM;

typedef _NORM_FORM TNormForm;

//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE bool __fastcall LoadNormalizeLib();
extern DELPHI_PACKAGE System::LongBool __stdcall IsNormalizedString(TNormForm NormForm, System::WideChar * lpString, int cwLength);
extern DELPHI_PACKAGE int __stdcall NormalizeString(TNormForm NormForm, System::WideChar * lpSrcString, int cwSrcLength, System::WideChar * lpDstString, int cwDstLength);
}	/* namespace Overbyteicswinnls */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSWINNLS)
using namespace Overbyteicswinnls;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsWinnlsHPP
