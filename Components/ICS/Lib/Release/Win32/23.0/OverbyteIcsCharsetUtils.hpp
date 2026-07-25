// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsCharsetUtils.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsCharsetUtilsHPP
#define OverbyteIcsCharsetUtilsHPP

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
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <System.Contnrs.hpp>
#include <OverbyteIcsUtils.hpp>
#include <OverbyteIcsTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicscharsetutils
{
//-- forward type declarations -----------------------------------------------
struct TCharsetInfo;
class DELPHICLASS TCodePageObj;
//-- type declarations -------------------------------------------------------
typedef System::UnicodeString CsuString;

enum DECLSPEC_DENUM TMimeCharset : unsigned char { CS_DEFAULT, CS_NOTMAPPED, UTF_8, WIN_1250, WIN_1251, WIN_1252, WIN_1253, WIN_1254, WIN_1255, WIN_1256, WIN_1257, WIN_1258, ISO_8859_1, ISO_8859_2, ISO_8859_3, ISO_8859_4, ISO_8859_5, ISO_8859_6, ISO_8859_7, ISO_8859_8, ISO_8859_8_i, ISO_8859_9, ISO_8859_13, ISO_8859_15, ISO_2022_JP, ISO_2022_JP_1, ISO_2022_JP_2, ISO_2022_KR, ISO_2022_CN, X_CP50227, EUC_JP, GB_2312_80, GB_2312, HZ_GB_2312, GB_18030, EUC_CN, KOI8_R, KOI8_U, UTF_16LE, UTF_16BE, UTF_7, SHIFT_JIS, BIG_5, KOREAN_HANGUL, EUC_KR, WIN_874, IBM_037, IBM_437, IBM_500, IBM_850, IBM_852, IBM_855, IBM_857, IBM_00858, IBM_860, IBM_861, IBM_862, IBM_863, IBM_864, IBM_865, IBM_866, IBM_869, IBM_870, IBM_1026, IBM_01047, IBM_01140, IBM_01141, IBM_01142, 
	IBM_01143, IBM_01144, IBM_01145, IBM_01146, IBM_01147, IBM_01148, IBM_01149, MACINTOSH, UTF_32LE, UTF_32BE, US_ASCII, T_61, CS_LAST_ITEM };

typedef System::Set<TMimeCharset, TMimeCharset::CS_DEFAULT, TMimeCharset::CS_LAST_ITEM> TMimeCharsets;

typedef TCharsetInfo *PCharsetInfo;

struct DECLSPEC_DRECORD TCharsetInfo
{
public:
	TMimeCharset MimeCharset;
	System::LongWord CodePage;
	CsuString MimeName;
	System::UnicodeString FriendlyName;
};


typedef System::DynamicArray<TCharsetInfo> TCharsetInfos;

#pragma pack(push,4)
class PASCALIMPLEMENTATION TCodePageObj : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::LongWord FCodePage;
	System::UnicodeString FCodePageName;
	
public:
	__property System::LongWord CodePage = {read=FCodePage, nodefault};
	__property System::UnicodeString CodePageName = {read=FCodePageName};
public:
	/* TObject.Create */ inline __fastcall TCodePageObj() : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TCodePageObj() { }
	
};

#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word MAX_CODEPAGE = System::Word(0xffff);
static _DELPHI_CONST int ERR_CP_NOTMAPPED = int(0x10000);
static _DELPHI_CONST int ERR_CP_NOTAVAILABLE = int(0x10001);
static _DELPHI_CONST System::Word CP_US_ASCII = System::Word(0x4e9f);
extern DELPHI_PACKAGE int IcsSystemMaxCharSize;
extern DELPHI_PACKAGE bool IcsSystemIsSingleByte;
extern DELPHI_PACKAGE void __fastcall GetFriendlyCharsetList(System::Classes::TStrings* Items, const TMimeCharsets &IncludeList, bool ClearItems = true);
extern DELPHI_PACKAGE void __fastcall GetMimeCharsetList(System::Classes::TStrings* Items, const TMimeCharsets &IncludeList, bool ClearItems = true);
extern DELPHI_PACKAGE bool __fastcall IsValidAnsiCodePage(System::LongWord ACodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsValidCodePageID(System::LongWord ACodePage);
extern DELPHI_PACKAGE bool __fastcall IsSingleByteCodePage(System::LongWord ACodePage);
extern DELPHI_PACKAGE System::LongWord __fastcall AnsiCodePageFromLocale(unsigned ALcid);
extern DELPHI_PACKAGE System::LongWord __fastcall OemCodePageFromLocale(unsigned ALcid);
extern DELPHI_PACKAGE System::LongWord __fastcall GetUserDefaultAnsiCodePage();
extern DELPHI_PACKAGE System::LongWord __fastcall GetThreadAnsiCodePage();
extern DELPHI_PACKAGE System::LongWord __fastcall GetUserDefaultOemCodePage();
extern DELPHI_PACKAGE System::LongWord __fastcall GetThreadOemCodePage();
extern DELPHI_PACKAGE void __fastcall GetSystemCodePageList(System::Contnrs::TObjectList* AOwnsObjectList);
extern DELPHI_PACKAGE TMimeCharset __fastcall CodePageToMimeCharset(System::LongWord ACodePage);
extern DELPHI_PACKAGE CsuString __fastcall CodePageToMimeCharsetString(System::LongWord ACodePage);
extern DELPHI_PACKAGE PCharsetInfo __fastcall GetMimeInfo(TMimeCharset AMimeCharSet)/* overload */;
extern DELPHI_PACKAGE PCharsetInfo __fastcall GetMimeInfo(System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE PCharsetInfo __fastcall GetMimeInfo(const CsuString AMimeCharSetString)/* overload */;
extern DELPHI_PACKAGE System::LongWord __fastcall MimeCharsetToCodePage(TMimeCharset AMimeCharSet)/* overload */;
extern DELPHI_PACKAGE bool __fastcall MimeCharsetToCodePage(const CsuString AMimeCharSetString, /* out */ System::LongWord &ACodePage)/* overload */;
extern DELPHI_PACKAGE System::LongWord __fastcall MimeCharsetToCodePageDef(const CsuString AMimeCharSetString);
extern DELPHI_PACKAGE bool __fastcall MimeCharsetToCodePageEx(const CsuString AMimeCharSetString, /* out */ System::LongWord &ACodePage)/* overload */;
extern DELPHI_PACKAGE System::LongWord __fastcall MimeCharsetToCodePageExDef(const CsuString AMimeCharSetString);
extern DELPHI_PACKAGE CsuString __fastcall MimeCharsetToCharsetString(TMimeCharset AMimeCharSet);
extern DELPHI_PACKAGE CsuString __fastcall ExtractMimeName(PCharsetInfo PInfo);
}	/* namespace Overbyteicscharsetutils */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSCHARSETUTILS)
using namespace Overbyteicscharsetutils;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsCharsetUtilsHPP
