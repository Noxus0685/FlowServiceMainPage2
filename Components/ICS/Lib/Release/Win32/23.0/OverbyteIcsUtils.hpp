// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsUtils.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsUtilsHPP
#define OverbyteIcsUtilsHPP

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
#include <OverbyteIcsWinnls.hpp>
#include <System.Win.Registry.hpp>
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.RTLConsts.hpp>
#include <System.SysConst.hpp>
#include <System.TypInfo.hpp>
#include <System.DateUtils.hpp>
#include <System.Types.hpp>
#include <System.SyncObjs.hpp>
#include <System.IOUtils.hpp>
#include <System.TimeSpan.hpp>
#include <System.AnsiStrings.hpp>
#include <OverbyteIcsMD5.hpp>
#include <OverbyteIcsTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsutils
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS EIcsStringConvertError;
struct TUnicode_String;
class DELPHICLASS TIcsIntegerList;
class DELPHICLASS TIcsCriticalSection;
struct WINTRUST_FILE_INFO_;
struct _WINTRUST_DATA;
class DELPHICLASS TIcsFindList;
class DELPHICLASS TIcsStringBuild;
//-- type declarations -------------------------------------------------------
typedef System::Sysutils::TSysCharSet TIcsDbcsLeadBytes;

#pragma pack(push,4)
class PASCALIMPLEMENTATION EIcsStringConvertError : public System::Sysutils::Exception
{
	typedef System::Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EIcsStringConvertError(const System::UnicodeString Msg) : System::Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EIcsStringConvertError(const System::UnicodeString Msg, const System::TVarRec *Args, const System::NativeInt Args_High) : System::Sysutils::Exception(Msg, Args, Args_High) { }
	/* Exception.CreateRes */ inline __fastcall EIcsStringConvertError(System::NativeUInt Ident)/* overload */ : System::Sysutils::Exception(Ident) { }
	/* Exception.CreateRes */ inline __fastcall EIcsStringConvertError(System::PResStringRec ResStringRec)/* overload */ : System::Sysutils::Exception(ResStringRec) { }
	/* Exception.CreateResFmt */ inline __fastcall EIcsStringConvertError(System::NativeUInt Ident, const System::TVarRec *Args, const System::NativeInt Args_High)/* overload */ : System::Sysutils::Exception(Ident, Args, Args_High) { }
	/* Exception.CreateResFmt */ inline __fastcall EIcsStringConvertError(System::PResStringRec ResStringRec, const System::TVarRec *Args, const System::NativeInt Args_High)/* overload */ : System::Sysutils::Exception(ResStringRec, Args, Args_High) { }
	/* Exception.CreateHelp */ inline __fastcall EIcsStringConvertError(const System::UnicodeString Msg, int AHelpContext) : System::Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EIcsStringConvertError(const System::UnicodeString Msg, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext) : System::Sysutils::Exception(Msg, Args, Args_High, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EIcsStringConvertError(System::NativeUInt Ident, int AHelpContext)/* overload */ : System::Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EIcsStringConvertError(System::PResStringRec ResStringRec, int AHelpContext)/* overload */ : System::Sysutils::Exception(ResStringRec, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EIcsStringConvertError(System::PResStringRec ResStringRec, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext)/* overload */ : System::Sysutils::Exception(ResStringRec, Args, Args_High, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EIcsStringConvertError(System::NativeUInt Ident, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext)/* overload */ : System::Sysutils::Exception(Ident, Args, Args_High, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EIcsStringConvertError() { }
	
};

#pragma pack(pop)

enum DECLSPEC_DENUM TCharsetDetectResult : unsigned char { cdrAscii, cdrUtf8, cdrUnknown };

enum DECLSPEC_DENUM TIcsNormForm : unsigned char { icsNormalizationOther, icsNormalizationC, icsNormalizationD, icsNormalizationKC = 5, icsNormalizationKD };

typedef System::Sysutils::TSearchRec TIcsSearchRecW;

struct DECLSPEC_DRECORD TUnicode_String
{
public:
	System::Word Length;
	System::Word MaximumLength;
	System::WideChar *Buffer;
};


typedef TUnicode_String *PUnicode_String;

typedef int __stdcall (*TRtlCompareUnicodeString)(PUnicode_String String1, PUnicode_String String2, bool CaseInSensitive);

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsIntegerList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int operator[](int Index) { return this->Items[Index]; }
	
private:
	System::Classes::TList* FList;
	int __fastcall GetCount();
	int __fastcall GetFirst();
	int __fastcall GetLast();
	int __fastcall GetItem(int Index);
	void __fastcall SetItem(int Index, const int Value);
	
public:
	__fastcall virtual TIcsIntegerList();
	__fastcall virtual ~TIcsIntegerList();
	int __fastcall IndexOf(int Item);
	virtual int __fastcall Add(int Item);
	virtual void __fastcall Assign(TIcsIntegerList* Source);
	virtual void __fastcall Clear();
	virtual void __fastcall Delete(int Index);
	__property int Count = {read=GetCount, nodefault};
	__property int First = {read=GetFirst, nodefault};
	__property int Last = {read=GetLast, nodefault};
	__property int Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
};

#pragma pack(pop)

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsCriticalSection : public System::TObject
{
	typedef System::TObject inherited;
	
protected:
	Winapi::Windows::TRTLCriticalSection FSection;
	
public:
	__fastcall TIcsCriticalSection();
	__fastcall virtual ~TIcsCriticalSection();
	void __fastcall Enter();
	void __fastcall Leave();
	bool __fastcall TryEnter();
};

#pragma pack(pop)

struct DECLSPEC_DRECORD WINTRUST_FILE_INFO_
{
public:
	unsigned cbStruct;
	System::WideChar *pcwszFilePath;
	Winapi::Windows::THandle hFile;
	GUID *pgKnownSubject;
};


typedef WINTRUST_FILE_INFO_ TWinTrustFileInfo;

typedef WINTRUST_FILE_INFO_ *PWinTrustFileInfo;

struct DECLSPEC_DRECORD _WINTRUST_DATA
{
	
private:
	struct DECLSPEC_DRECORD __WINTRUST_DATA__1
	{
		union
		{
			struct 
			{
				PWinTrustFileInfo pFile;
			};
			
		};
	};
	
	
	
public:
	unsigned cbStruct;
	void *pPolicyCallbackData;
	void *pSIPClientData;
	unsigned dwUIChoice;
	unsigned fdwRevocationChecks;
	unsigned dwUnionChoice;
	__WINTRUST_DATA__1 Info;
	unsigned dwStateAction;
	Winapi::Windows::THandle hWVTStateData;
	System::WideChar *pwszURLReference;
	unsigned dwProvFlags;
	unsigned dwUIContext;
};


typedef _WINTRUST_DATA TWinTrustData;

typedef _WINTRUST_DATA *PWinTrustData;

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsFindList : public System::Classes::TList
{
	typedef System::Classes::TList inherited;
	
public:
	bool Sorted;
	virtual int __fastcall AddSorted(const void * Item2, System::Classes::TListSortCompare Compare);
	virtual bool __fastcall Find(const void * Item2, System::Classes::TListSortCompare Compare, int &index);
public:
	/* TList.Destroy */ inline __fastcall virtual ~TIcsFindList() { }
	
public:
	/* TObject.Create */ inline __fastcall TIcsFindList() : System::Classes::TList() { }
	
};

#pragma pack(pop)

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsStringBuild : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FBuffMax;
	int FBuffSize;
	int FIndex;
	Overbyteicstypes::TBytes FBuffer;
	int FCharSize;
	void __fastcall ExpandBuffer();
	
public:
	__fastcall TIcsStringBuild(int ABufferSize, bool Wide);
	__fastcall virtual ~TIcsStringBuild();
	void __fastcall AppendBuf(const System::UnicodeString AString);
	void __fastcall AppendBufA(const System::AnsiString AString);
	void __fastcall AppendBufW(const System::UnicodeString AString);
	void __fastcall AppendLine(const System::UnicodeString AString);
	void __fastcall AppendLineA(const System::AnsiString AString);
	void __fastcall AppendLineW(const System::UnicodeString AString);
	void __fastcall Clear();
	System::AnsiString __fastcall GetAString();
	System::UnicodeString __fastcall GetWString();
	System::UnicodeString __fastcall GetString();
	void __fastcall Capacity(int ABufferSize);
	__property int Len = {read=FIndex, nodefault};
	__property Overbyteicstypes::TBytes Buffer = {read=FBuffer};
	__property int CharSize = {read=FCharSize, write=FCharSize, nodefault};
};

#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_932;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_936_949_950;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_1361;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_10001;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_10002;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_10003;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_10008;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20000;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20001;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20002;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20003;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20004;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20005;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20261;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20932;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_20936;
extern DELPHI_PACKAGE TIcsDbcsLeadBytes ICS_LEAD_BYTES_51949;
static _DELPHI_CONST System::Word CP_UTF16 = System::Word(0x4b0);
static _DELPHI_CONST System::Word CP_UTF16Be = System::Word(0x4b1);
static _DELPHI_CONST System::Word CP_UTF32 = System::Word(0x2ee0);
static _DELPHI_CONST System::Word CP_UTF32Be = System::Word(0x2ee1);
extern DELPHI_PACKAGE System::Sysutils::TFormatSettings IcsFormatSettings;
extern DELPHI_PACKAGE Winapi::Windows::THandle WinTrustHandle;
extern DELPHI_PACKAGE unsigned __stdcall (*WinVerifyTrust)(HWND hwnd, GUID &pgActionID, void * pWVTData);
extern DELPHI_PACKAGE unsigned hSHFolderDLL;
extern DELPHI_PACKAGE HRESULT __stdcall (*f_SHGetFolderPath)(HWND hwndOwner, int nFolder, Winapi::Windows::THandle hToken, unsigned dwFlags, System::WideChar * pszPath);
extern DELPHI_PACKAGE System::StaticArray<char, 65> Base64OutA;
extern DELPHI_PACKAGE System::StaticArray<System::Byte, 128> Base64In;
extern DELPHI_PACKAGE System::LongWord GSeed32;
extern DELPHI_PACKAGE System::WideChar __fastcall IcsGetDefaultWindowsUnicodeChar(System::LongWord CodePage);
extern DELPHI_PACKAGE char __fastcall IcsGetDefaultWindowsAnsiChar(System::LongWord CodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsValidAnsiCodePage(const System::LongWord CP);
extern DELPHI_PACKAGE void __fastcall IcsCharLowerA(char &ACh);
extern DELPHI_PACKAGE System::TThreadID __fastcall IcsGetCurrentThreadID();
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetTickCount();
extern DELPHI_PACKAGE __int64 __fastcall IcsGetFreeDiskSpace(const System::UnicodeString APath);
extern DELPHI_PACKAGE int __fastcall IcsGetLocalTimeZoneBias();
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsGetLocalTZBiasStr();
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsDateTimeToUTC(System::TDateTime dtDT);
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsUTCToDateTime(System::TDateTime dtDT);
extern DELPHI_PACKAGE System::UnicodeString __fastcall RFC1123_Date(System::TDateTime aDate, bool AddTZ = false);
extern DELPHI_PACKAGE System::UnicodeString __fastcall RFC1123_UtcDate(System::TDateTime aDate);
extern DELPHI_PACKAGE System::TDateTime __fastcall RFC1123_StrToDate(System::UnicodeString aDate, bool UseTZ = false);
extern DELPHI_PACKAGE System::TDateTime __fastcall RFC3339_StrToDate(System::UnicodeString aDate, bool UseTZ = false);
extern DELPHI_PACKAGE System::UnicodeString __fastcall RFC3339_DateToStr(System::TDateTime DT, bool AddTZ = false);
extern DELPHI_PACKAGE System::UnicodeString __fastcall RFC3339_DateToUtcStr(System::TDateTime DT);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsDateTimeToAStr(const System::TDateTime DateTime);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsDateToAStr(const System::TDateTime DateTime);
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsGetUTCTime();
extern DELPHI_PACKAGE bool __fastcall IcsSetUTCTime(System::TDateTime DateTime);
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsGetNewTime(System::TDateTime DateTime, System::TDateTime Difference);
extern DELPHI_PACKAGE bool __fastcall IcsChangeSystemTime(System::TDateTime Difference);
extern DELPHI_PACKAGE __int64 __fastcall IcsGetUnixTime();
extern DELPHI_PACKAGE int __fastcall IcsWcToMb(System::LongWord CodePage, unsigned Flags, System::WideChar * WStr, int WStrLen, char * MbStr, int MbStrLen, char * DefaultChar, System::PLongBool UsedDefaultChar);
extern DELPHI_PACKAGE int __fastcall IcsMbToWc(System::LongWord CodePage, unsigned Flags, char * MbStr, int MbStrLen, System::WideChar * WStr, int WStrLen);
extern DELPHI_PACKAGE void __fastcall IcsGetAcp(System::LongWord &CodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsDBCSCodePage(System::LongWord CodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsDBCSLeadByte(char Ch, System::LongWord CodePage);
extern DELPHI_PACKAGE TIcsDbcsLeadBytes __fastcall IcsGetLeadBytes(System::LongWord CodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsMBCSCodePage(System::LongWord CodePage);
extern DELPHI_PACKAGE bool __fastcall IcsIsSBCSCodePage(System::LongWord CodePage);
extern DELPHI_PACKAGE bool __fastcall IsUsAscii(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsUsAscii(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall UnicodeToUsAscii(const System::UnicodeString Str, char FailCh)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall UnicodeToUsAscii(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall UnicodeToAnsi(const System::UnicodeString Str, System::LongWord ACodePage, bool SetCodePage = false)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall UnicodeToAnsi(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall AnsiToUnicode(const void *Buffer, int BufferSize, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall AnsiToUnicode(const char * Str, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall UnicodeToAnsi(const System::WideChar * Str, System::LongWord ACodePage, bool SetCodePage = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall AnsiToUnicode(const System::RawByteString Str, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall AnsiToUnicode(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall UsAsciiToUnicode(const System::RawByteString Str, char FailCh)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall UsAsciiToUnicode(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE System::Word __fastcall IcsSwap16(System::Word Value);
extern DELPHI_PACKAGE void __fastcall IcsSwap16Buf(PWORD Src, PWORD Dst, int WordCount);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsSwap32(System::LongWord Value);
extern DELPHI_PACKAGE void __fastcall IcsSwap32Buf(System::PLongWord Src, System::PLongWord Dst, int LongWordCount);
extern DELPHI_PACKAGE __int64 __fastcall IcsSwap64(__int64 Value);
extern DELPHI_PACKAGE void __fastcall IcsSwap64Buf(System::PInt64 Src, System::PInt64 Dst, int QuadWordCount);
extern DELPHI_PACKAGE int __fastcall IcsGetWideCharCount(const void *Buffer, int BufferSize, System::LongWord BufferCodePage, /* out */ int &InvalidEndByteCount);
extern DELPHI_PACKAGE int __fastcall IcsGetWideChars(const void *Buffer, int BufferSize, System::LongWord BufferCodePage, System::WideChar * Chars, int CharCount);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBufferToUnicode(const void *Buffer, int BufferSize, System::LongWord BufferCodePage, /* out */ int &FailedByteCount)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBufferToUnicode(const void *Buffer, int BufferSize, System::LongWord BufferCodePage, bool RaiseFailedBytes = false)/* overload */;
extern DELPHI_PACKAGE void __fastcall IcsAppendStr(System::RawByteString &Dest, const System::RawByteString Src);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsGetBomBytes(System::LongWord ACodePage);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetBufferCodepage(char * Buf, int ByteCount)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsGetBufferCodepage(char * Buf, int ByteCount, /* out */ int &BOMSize)/* overload */;
extern DELPHI_PACKAGE int __fastcall StreamWriteString(System::Classes::TStream* AStream, System::WideChar * Str, int cLen, System::LongWord ACodePage, bool WriteBOM)/* overload */;
extern DELPHI_PACKAGE int __fastcall StreamWriteString(System::Classes::TStream* AStream, System::WideChar * Str, int cLen, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE int __fastcall StreamWriteString(System::Classes::TStream* AStream, const System::UnicodeString Str, System::LongWord ACodePage, bool WriteBOM)/* overload */;
extern DELPHI_PACKAGE int __fastcall StreamWriteString(System::Classes::TStream* AStream, const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE int __fastcall StreamWriteString(System::Classes::TStream* AStream, const System::UnicodeString Str, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE int __fastcall atoi(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE int __fastcall atoi(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE __int64 __fastcall atoi64(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE __int64 __fastcall atoi64(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE System::LongWord __fastcall IcsCalcTickDiff(const System::LongWord StartTick, const System::LongWord EndTick);
extern DELPHI_PACKAGE System::RawByteString __fastcall StringToUtf8(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall StringToUtf8TB(const System::UnicodeString Str);
extern DELPHI_PACKAGE System::RawByteString __fastcall ConvertCodepage(const System::RawByteString Str, System::LongWord SrcCodePage, System::LongWord DstCodePage = (unsigned)(0x0));
extern DELPHI_PACKAGE System::RawByteString __fastcall StringToUtf8(const System::RawByteString Str, System::LongWord ACodePage = (unsigned)(0x0))/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Utf8ToStringW(const System::RawByteString Str);
extern DELPHI_PACKAGE System::UnicodeString __fastcall Utf8ToStringTB(const Overbyteicstypes::TBytes Str);
extern DELPHI_PACKAGE System::AnsiString __fastcall Utf8ToStringA(const System::RawByteString Str, System::LongWord ACodePage = (unsigned)(0x0));
extern DELPHI_PACKAGE bool __fastcall CheckUnicodeToAnsi(const System::UnicodeString Str, System::LongWord ACodePage = (unsigned)(0x0));
extern DELPHI_PACKAGE int __fastcall IcsUtf8Size(const System::Byte LeadByte);
extern DELPHI_PACKAGE bool __fastcall IsUtf8LeadByte(const System::Byte B);
extern DELPHI_PACKAGE bool __fastcall IsUtf8TrailByte(const System::Byte B);
extern DELPHI_PACKAGE TCharsetDetectResult __fastcall CharsetDetect(const void * Buf, int Len)/* overload */;
extern DELPHI_PACKAGE TCharsetDetectResult __fastcall CharsetDetect(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsUtf8Valid(const System::RawByteString Str)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsUtf8Valid(const void * Buf, int Len)/* overload */;
extern DELPHI_PACKAGE char * __fastcall IcsCharPrevUtf8(const char * Start, const char * Current);
extern DELPHI_PACKAGE char * __fastcall IcsCharNextUtf8(const char * Str);
extern DELPHI_PACKAGE char * __fastcall IcsStrNextChar(const char * Str, System::LongWord ACodePage = (unsigned)(0x0));
extern DELPHI_PACKAGE char * __fastcall IcsStrPrevChar(const char * Start, const char * Current, System::LongWord ACodePage = (unsigned)(0x0));
extern DELPHI_PACKAGE int __fastcall IcsStrCharLength(const char * Str, System::LongWord ACodePage = (unsigned)(0x0))/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsNextCharIndex(const System::RawByteString S, int Index, System::LongWord ACodePage = (unsigned)(0x0))/* overload */;
extern DELPHI_PACKAGE int __fastcall XDigit(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE int __fastcall XDigit(char Ch)/* overload */;
extern DELPHI_PACKAGE int __fastcall XDigit2(System::WideChar * S);
extern DELPHI_PACKAGE bool __fastcall IsXDigit(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsXDigit(char Ch)/* overload */;
extern DELPHI_PACKAGE int __fastcall htoin(System::WideChar * Value, int Len)/* overload */;
extern DELPHI_PACKAGE int __fastcall htoin(char * Value, int Len)/* overload */;
extern DELPHI_PACKAGE int __fastcall htoi2(System::WideChar * value)/* overload */;
extern DELPHI_PACKAGE int __fastcall htoi2(char * value)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBufferToHex(const void *Buf, int Size, System::WideChar Separator)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBufferToHex(const void *Buf, int Size)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBufferToHex(const System::AnsiString BufStr)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTBToHex(const Overbyteicstypes::TBytes BufTB)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsHexToBin(const System::AnsiString HexBuf);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsFormatHexStr(const System::UnicodeString HexStr, int GroupLen = 0x8, int LineLen = 0x40);
extern DELPHI_PACKAGE bool __fastcall IsCharInSysCharSet(System::WideChar Ch, const System::Sysutils::TSysCharSet &ASet)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsCharInSysCharSet(char Ch, const System::Sysutils::TSysCharSet &ASet)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsDigit(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsDigit(char Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsSpace(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsSpace(char Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsCRLF(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsCRLF(char Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsSpaceOrCRLF(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsSpaceOrCRLF(char Ch)/* overload */;
extern DELPHI_PACKAGE System::WideChar * __fastcall stpblk(System::WideChar * PValue)/* overload */;
extern DELPHI_PACKAGE char * __fastcall stpblk(char * PValue)/* overload */;
extern DELPHI_PACKAGE void __fastcall IcsNameThreadForDebugging(System::AnsiString AThreadName, System::TThreadID AThreadID = (unsigned)(0xffffffff));
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsNormalizeString(const System::UnicodeString S, TIcsNormForm NormForm);
extern DELPHI_PACKAGE bool __fastcall IcsCryptGenRandom(void *Buf, int BufSize);
extern DELPHI_PACKAGE int __fastcall IcsRandomInt(const int ARange);
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsFileUtcModified(const System::UnicodeString FileName);
extern DELPHI_PACKAGE void * __fastcall IcsInterlockedCompareExchange(void * &Destination, void * Exchange, void * Comperand);
extern DELPHI_PACKAGE void __fastcall IcsFindCloseW(TIcsSearchRecW &F);
extern DELPHI_PACKAGE int __fastcall IcsFindNextW(TIcsSearchRecW &F);
extern DELPHI_PACKAGE int __fastcall IcsFindFirstW(const System::UnicodeString Path, int Attr, TIcsSearchRecW &F)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFindFirstW(const System::UTF8String Utf8Path, int Attr, TIcsSearchRecW &F)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsCreateDirW(const System::UnicodeString Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsCreateDirW(const System::UTF8String Utf8Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsForceDirectoriesW(System::UnicodeString Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsForceDirectoriesW(System::UTF8String Utf8Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsDirExists(const System::UnicodeString FileName);
extern DELPHI_PACKAGE bool __fastcall IcsDirExistsW(const System::WideChar * FileName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsDirExistsW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsDirExistsW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE int __stdcall RtlCompareUnicodeString(PUnicode_String String1, PUnicode_String String2, bool CaseInsensitive);
extern DELPHI_PACKAGE int __fastcall IcsStrCompOrdinalW(System::WideChar * Str1, int Str1Length, System::WideChar * Str2, int Str2Length, bool IgnoreCase);
extern DELPHI_PACKAGE int __fastcall IcsAnsiCompareFileNameW(const System::UnicodeString S1, const System::UnicodeString S2)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsAnsiCompareFileNameW(const System::UTF8String Utf8S1, const System::UTF8String Utf8S2)/* overload */;
extern DELPHI_PACKAGE System::WideChar * __fastcall IcsStrAllocW(unsigned Len);
extern DELPHI_PACKAGE System::WideChar * __fastcall IcsStrScanW(const System::WideChar * Str, System::WideChar Ch);
extern DELPHI_PACKAGE __int64 __fastcall IcsMakeLongLong(System::LongWord L, System::LongWord H);
extern DELPHI_PACKAGE int __fastcall IcsMakeLong(System::Word L, System::Word H);
extern DELPHI_PACKAGE System::Word __fastcall IcsMakeWord(System::Byte L, System::Byte H);
extern DELPHI_PACKAGE System::Word __fastcall IcsHiWord(System::LongWord LW);
extern DELPHI_PACKAGE System::Word __fastcall IcsLoWord(System::LongWord LW);
extern DELPHI_PACKAGE System::Byte __fastcall IcsHiByte(System::Word W);
extern DELPHI_PACKAGE System::Byte __fastcall IcsLoByte(System::Word W);
extern DELPHI_PACKAGE void __fastcall IcsCheckOSError(int ALastError);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsIntToStrA(int N);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsIntToHexA(int N, System::Byte Digits);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsTrimA(const System::AnsiString Str);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsTrim(const System::AnsiString Str)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTrim(const System::UnicodeString Str)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsLowerCaseA(const System::AnsiString S);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsLowerCase(const System::AnsiString S)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsLowerCase(const System::UnicodeString S)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsUpperCaseA(const System::AnsiString S);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsUpperCase(const System::AnsiString S)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsUpperCase(const System::UnicodeString S)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsSameTextA(const System::AnsiString S1, const System::AnsiString S2);
extern DELPHI_PACKAGE int __fastcall IcsCompareTextA(const System::AnsiString S1, const System::AnsiString S2);
extern DELPHI_PACKAGE int __fastcall IcsCompareText(const System::AnsiString S1, const System::AnsiString S2)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsCompareText(const System::UnicodeString S1, const System::UnicodeString S2)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsCompareStr(const System::AnsiString S1, const System::AnsiString S2)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsCompareStr(const System::UnicodeString S1, const System::UnicodeString S2)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsStrLen(const char * Str)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsStrLen(const System::WideChar * Str)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsStrPas(const char * Str)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStrPas(const System::WideChar * Str)/* overload */;
extern DELPHI_PACKAGE char * __fastcall IcsStrCopy(char * Dest, const char * Source)/* overload */;
extern DELPHI_PACKAGE System::WideChar * __fastcall IcsStrCopy(System::WideChar * Dest, const System::WideChar * Source)/* overload */;
extern DELPHI_PACKAGE System::WideChar * __fastcall IcsStrPCopy(System::WideChar * Dest, const System::UnicodeString Source)/* overload */;
extern DELPHI_PACKAGE char * __fastcall IcsStrPCopy(char * Dest, const System::AnsiString Source)/* overload */;
extern DELPHI_PACKAGE System::WideChar * __fastcall IcsStrPLCopy(System::WideChar * Dest, const System::UnicodeString Source, unsigned MaxLen)/* overload */;
extern DELPHI_PACKAGE char * __fastcall IcsStrPLCopy(char * Dest, const System::AnsiString Source, unsigned MaxLen)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractFilePathW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractFileDirW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractFileDriveW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractFileNameW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractFileExtW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractNameOnlyW(System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsChangeFileExtW(const System::UnicodeString FileName, const System::UnicodeString Extension);
extern DELPHI_PACKAGE unsigned __fastcall IcsStrLenW(System::WideChar * Str);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExpandFileNameW(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIncludeTrailingPathDelimiterW(const System::UnicodeString S);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExcludeTrailingPathDelimiterW(const System::UnicodeString S);
extern DELPHI_PACKAGE bool __fastcall IcsDeleteFileW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall IcsExtractLastDir(const System::RawByteString Path)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractLastDir(const System::UnicodeString Path)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsDeleteFileW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileGetAttrW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileGetAttrW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileSetAttrW(const System::UnicodeString FileName, int Attr)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileSetAttrW(const System::UTF8String Utf8FileName, int Attr)/* overload */;
extern DELPHI_PACKAGE Winapi::Windows::THandle __fastcall IcsFileCreateW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsFileCreateW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsFileCreateW(const System::UnicodeString FileName, System::LongWord Rights)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsFileCreateW(const System::UTF8String Utf8FileName, System::LongWord Rights)/* overload */;
extern DELPHI_PACKAGE Winapi::Windows::THandle __fastcall IcsFileOpenW(const System::UnicodeString FileName, System::LongWord Mode)/* overload */;
extern DELPHI_PACKAGE unsigned __fastcall IcsFileOpenW(const System::UTF8String Utf8FileName, System::LongWord Mode)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsRemoveDirW(const System::UnicodeString Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsRemoveDirW(const System::UTF8String Utf8Dir)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsRenameFileW(const System::UnicodeString OldName, const System::UnicodeString NewName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsRenameFileW(const System::UTF8String Utf8OldName, const System::UTF8String Utf8NewName)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileAgeW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsFileAgeW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsFileExistsW(const System::UnicodeString FileName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsFileExistsW(const System::UTF8String Utf8FileName)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsGetUAgeSizeFile(const System::UnicodeString filename, System::TDateTime &FileUDT, __int64 &FSize);
extern DELPHI_PACKAGE __int64 __fastcall IcsGetFileSize(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::TDateTime __fastcall IcsGetFileUAge(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsAnsiLowerCaseW(const System::UnicodeString S);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsAnsiUpperCaseW(const System::UnicodeString S);
extern DELPHI_PACKAGE bool __fastcall IcsGetFileVerInfo(const System::UnicodeString AppName, /* out */ System::UnicodeString &FileVersion, /* out */ System::UnicodeString &FileDescription);
extern DELPHI_PACKAGE int __fastcall IcsVerifyTrust(const System::UnicodeString Fname, const bool HashOnly, const bool Expired, System::UnicodeString &Response);
extern DELPHI_PACKAGE bool __fastcall IcsCheckTrueFalse(const System::UnicodeString Value);
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytesToString(const Overbyteicstypes::TBytes Buffer, int OffsetFrom, System::UnicodeString &Dest, int OffsetTo, int Count)/* overload */;
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytesToString(const Overbyteicstypes::TBytes Buffer, int OffsetFrom, System::AnsiString &Dest, int OffsetTo, int Count)/* overload */;
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytesToString(const Overbyteicstypes::TBytes Buffer, int OffsetFrom, System::UnicodeString &Dest, int OffsetTo, int Count, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytesToString(const Overbyteicstypes::TBytes Buffer, int OffsetFrom, System::AnsiString &Dest, int OffsetTo, int Count, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTBytesToString(const Overbyteicstypes::TBytes Buffer, int Count = 0x0, System::LongWord ACodePage = (unsigned)(0xfde9));
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsTBytesToStringA(const Overbyteicstypes::TBytes Buffer, int Count = 0x0);
extern DELPHI_PACKAGE int __fastcall IcsMoveStringToTBytes(const System::UnicodeString Source, Overbyteicstypes::TBytes &Buffer, int Count)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsMoveStringToTBytes(const System::AnsiString Source, Overbyteicstypes::TBytes &Buffer, int Count)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsMoveStringToTBytes(const System::UnicodeString Source, Overbyteicstypes::TBytes &Buffer, int Count, System::LongWord ACodePage, bool Bom = false)/* overload */;
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsStringToTBytes(const System::UnicodeString Source, System::LongWord ACodePage = (unsigned)(0xfde9));
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsStringAToTBytes(const System::AnsiString Source);
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytes(Overbyteicstypes::TBytes &Buffer, int OffsetFrom, int OffsetTo, int Count);
extern DELPHI_PACKAGE void __fastcall IcsMoveTBytesEx(const Overbyteicstypes::TBytes BufferFrom, Overbyteicstypes::TBytes &BufferTo, int OffsetFrom, int OffsetTo, int Count);
extern DELPHI_PACKAGE int __fastcall IcsTBytesPos(const System::UnicodeString Substr, const Overbyteicstypes::TBytes S, int Offset, int Count);
extern DELPHI_PACKAGE bool __fastcall IcsTBytesStarts(const Overbyteicstypes::TBytes Source, char * Find);
extern DELPHI_PACKAGE bool __fastcall IcsTBytesContains(const Overbyteicstypes::TBytes Source, char * Find);
extern DELPHI_PACKAGE bool __fastcall IcsTBytesCompare(const Overbyteicstypes::TBytes Input1, const Overbyteicstypes::TBytes Input2);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsFmtIpv6Addr(const System::UnicodeString Addr);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsFmtIpv6AddrPort(const System::UnicodeString Addr, const System::UnicodeString Port);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStripIpv6Addr(const System::UnicodeString Addr);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IntToKbyte(__int64 Value, bool Bytes = false);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetTickCountX();
extern DELPHI_PACKAGE System::LongWord __fastcall IcsDiffTicks(const System::LongWord StartTick, const System::LongWord EndTick);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsElapsedMsecs(const System::LongWord StartTick);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsElapsedTicks(const System::LongWord StartTick);
extern DELPHI_PACKAGE int __fastcall IcsElapsedSecs(const System::LongWord StartTick);
extern DELPHI_PACKAGE int __fastcall IcsWaitingSecs(const System::LongWord EndTick);
extern DELPHI_PACKAGE int __fastcall IcsElapsedMins(const System::LongWord StartTick);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsAddTrgMsecs(const System::LongWord TickCount, const System::LongWord MilliSecs);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsAddTrgSecs(const int TickCount, const int DurSecs);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetTrgMSecs(const int MilliSecs);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetTrgSecs(const int DurSecs);
extern DELPHI_PACKAGE System::LongWord __fastcall IcsGetTrgMins(const int DurMins);
extern DELPHI_PACKAGE bool __fastcall IcsTestTrgTick(const System::LongWord TrgTick);
extern DELPHI_PACKAGE int __fastcall IcsWireFmtToStrList(const Overbyteicstypes::TBytes Buffer, int Len, System::Classes::TStrings* SList);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsWireFmtToCSV(const Overbyteicstypes::TBytes Buffer, int Len);
extern DELPHI_PACKAGE int __fastcall IcsStrListToWireFmt(System::Classes::TStrings* SList, Overbyteicstypes::TBytes &Buffer);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsEscapeCRLF(const System::UnicodeString Value);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsUnEscapeCRLF(const System::UnicodeString Value);
extern DELPHI_PACKAGE int __fastcall IcsSetToInt(const void *aSet, const int aSize);
extern DELPHI_PACKAGE void __fastcall IcsIntToSet(const int Value, void *aSet, const int aSize);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsSetToStr(System::Typinfo::PTypeInfo TypInfo, const void *aSet, const int aSize);
extern DELPHI_PACKAGE void __fastcall IcsStrToSet(System::Typinfo::PTypeInfo TypInfo, const System::UnicodeString Values, void *aSet, const int aSize);
extern DELPHI_PACKAGE bool __fastcall IsPathSep(System::WideChar Ch)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IsPathSep(char Ch)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsExtractNameOnly(const System::UnicodeString FileName);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsGetCompName();
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsGetExceptMess(System::TObject* ExceptObject);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsAddThouSeps(const System::UnicodeString S);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIntToCStr(const int N);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsInt64ToCStr(const __int64 N);
extern DELPHI_PACKAGE int __fastcall CompareGTMem(void * P1, void * P2, int Length);
extern DELPHI_PACKAGE int __fastcall IcsDeleteFile(const System::UnicodeString Fname, const bool ReadOnly);
extern DELPHI_PACKAGE int __fastcall IcsRenameFile(const System::UnicodeString OldName, const System::UnicodeString NewName, const bool Replace, const bool ReadOnly)/* overload */;
extern DELPHI_PACKAGE bool __fastcall IcsForceDirsEx(const System::UnicodeString Dir);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall GetBomFromCodePage(System::LongWord ACodePage);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTransChar(const System::UnicodeString S, System::WideChar FromChar, System::WideChar ToChar);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPathUnixToDos(const System::UnicodeString Path);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPathDosToUnix(const System::UnicodeString Path);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTransCharW(const System::UnicodeString S, System::WideChar FromChar, System::WideChar ToChar);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPathUnixToDosW(const System::UnicodeString Path);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPathDosToUnixW(const System::UnicodeString Path);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsSecsToStr(int Seconds);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsGetTempPath();
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyDecode(const System::UnicodeString Input, bool &ErrFlag);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyEncode(const System::UnicodeString Input, bool &ErrFlag);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyToASCII(const System::UnicodeString Input, bool UseSTD3AsciiRules, bool &ErrFlag)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIDNAToASCII(const System::UnicodeString Input, bool UseSTD3AsciiRules, bool &ErrFlag)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyToASCII(const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIDNAToASCII(const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyToUnicode(const System::UnicodeString Input, bool &ErrFlag)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIDNAToUnicode(const System::UnicodeString Input, bool &ErrFlag)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsPunyToUnicode(const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsIDNAToUnicode(const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE int __fastcall IcsAnsiPosEx(const System::AnsiString SubStr, const System::AnsiString Str, int Offset = 0x1);
extern DELPHI_PACKAGE int __fastcall IcsPosEx(const System::UnicodeString SubStr, const System::UnicodeString Str, int Offset = 0x1);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsGetShellPath(int CSIDL);
extern DELPHI_PACKAGE System::AnsiString __fastcall Base64Encode _DEPRECATED_ATTRIBUTE0 (const System::AnsiString Input)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall Base64Encode _DEPRECATED_ATTRIBUTE0 (const char * Input, int Len)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64Encode _DEPRECATED_ATTRIBUTE0 (const System::UnicodeString Input, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64Encode _DEPRECATED_ATTRIBUTE0 (const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall Base64Decode _DEPRECATED_ATTRIBUTE0 (const System::AnsiString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64Decode _DEPRECATED_ATTRIBUTE0 (const System::UnicodeString Input, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64Decode _DEPRECATED_ATTRIBUTE0 (const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64EncodeTB _DEPRECATED_ATTRIBUTE0 (Overbyteicstypes::TBytes Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall Base64EncodeA _DEPRECATED_ATTRIBUTE0 (const System::AnsiString Input);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall Base64DecodeTB _DEPRECATED_ATTRIBUTE0 (const System::AnsiString Input)/* overload */;
extern DELPHI_PACKAGE System::DynamicArray<System::Byte> __fastcall Base64DecodeTB _DEPRECATED_ATTRIBUTE0 (const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64EncodeTB(const Overbyteicstypes::TBytes Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64EncodeAC(const char * Input, int Len);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64EncodeA(const System::AnsiString Input);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64Encode(const System::UnicodeString Input);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsBase64DecodeTB(const System::AnsiString Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64DecodeA(const System::AnsiString Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64Decode(const System::UnicodeString Input);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64DecodeU(const System::UnicodeString Input, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64DecodeU(const System::UnicodeString Input)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsJsonPair(const System::UnicodeString S1, const System::UnicodeString S2);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsBase64UrlDecodeATB(const System::AnsiString Input);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsBase64UrlDecodeTB(const System::UnicodeString Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64UrlEncodeATB(const Overbyteicstypes::TBytes Input);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64UrlEncodeTB(const Overbyteicstypes::TBytes Input);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64UrlDecode(const System::UnicodeString Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64UrlDecodeA(const System::AnsiString Input);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsBase64UrlEncodeA(const System::AnsiString Input);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBase64UrlEncode(const System::UnicodeString Input);
extern DELPHI_PACKAGE bool __fastcall IcsFileInUse(System::UnicodeString FileName);
extern DELPHI_PACKAGE __int64 __fastcall IcsTruncateFile(const System::UnicodeString FName, __int64 NewSize);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsAddLongPath(const System::UnicodeString S);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBuiltWith();
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsBuiltWithEx();
extern DELPHI_PACKAGE bool __fastcall IcsTextOnStart(const System::UnicodeString ATextOnStart, const System::UnicodeString AText);
extern DELPHI_PACKAGE bool __fastcall IcsTextOnStartA(const System::AnsiString ATextOnStart, const System::AnsiString AText);
extern DELPHI_PACKAGE bool __fastcall IcsIsProgAdmin();
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStrRemCntls(const System::UnicodeString S, bool LeaveCRLF = true);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStrRemCntlsA(const System::AnsiString S, bool LeaveCRLF = true);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStrRemCntlsTB(const Overbyteicstypes::TBytes TB, bool LeaveCRLF = true);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsStrBeakup(const System::UnicodeString S, int MaxLine = 0x84);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsTimeToZStr(const System::TDateTime DT);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsResourceGetTB(const System::UnicodeString ResName, const System::WideChar * ResType = (System::WideChar *)(0xa));
extern DELPHI_PACKAGE int __fastcall IcsResourceSaveFile(const System::UnicodeString ResName, const System::UnicodeString FileName, bool Replace = false);
extern DELPHI_PACKAGE bool __fastcall IcsDataSaveFile(const Overbyteicstypes::TBytes Data, const System::UnicodeString FileName, bool Replace = false);
extern DELPHI_PACKAGE Overbyteicstypes::TBytes __fastcall IcsDataLoadFile(const System::UnicodeString FileName, int MaxLen = 0x9c4000);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsAbsolutisePath(const System::UnicodeString Path);
extern DELPHI_PACKAGE bool __fastcall WSocketIsDottedIP(const System::AnsiString S)/* overload */;
extern DELPHI_PACKAGE bool __fastcall WSocketIsDottedIP(const System::UnicodeString S)/* overload */;
extern DELPHI_PACKAGE bool __fastcall WSocketIsIPv4(const System::UnicodeString S);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketIPv4ToStr(const Overbyteicstypes::TIcsIPv4Address AIcsIPv4Addr);
extern DELPHI_PACKAGE Overbyteicstypes::TIcsIPv4Address __fastcall WSocketStrToIPv4(const System::UnicodeString S, /* out */ bool &Success);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketIPv6ToStr(const Overbyteicstypes::TIcsIPv6Address &AIcsIPv6Addr)/* overload */;
extern DELPHI_PACKAGE bool __fastcall WSocketIPv6Same(const Overbyteicstypes::TIcsIPv6Address &IP1, const Overbyteicstypes::TIcsIPv6Address &IP2);
extern DELPHI_PACKAGE Overbyteicstypes::TIcsIPv6Address __fastcall WSocketStrToIPv6(const System::UnicodeString S, /* out */ bool &Success)/* overload */;
extern DELPHI_PACKAGE Overbyteicstypes::TIcsIPv6Address __fastcall WSocketStrToIPv6(const System::UnicodeString S, /* out */ bool &Success, /* out */ unsigned &ScopeID)/* overload */;
extern DELPHI_PACKAGE bool __fastcall WSocketIsIP(const System::UnicodeString S, /* out */ Overbyteicstypes::TSocketFamily &ASocketFamily);
extern DELPHI_PACKAGE bool __fastcall WSocketIsIPEx(const System::UnicodeString S, /* out */ Overbyteicstypes::TSocketFamily &ASocketFamily);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsReverseIP(const System::UnicodeString IP);
extern DELPHI_PACKAGE System::AnsiString __fastcall IcsReverseIPv6(const System::UnicodeString IPv6);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketIPv6ToStr(const Overbyteicstypes::PSockAddrIn6 AIn6)/* overload */;
extern DELPHI_PACKAGE Overbyteicstypes::TSockAddrIn6 __fastcall WSocketIPv4ToSocAddr(int IPv4)/* overload */;
extern DELPHI_PACKAGE sockaddr_in6 __fastcall WSocketIPv4ToSocAddr(unsigned IPv4)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketSockAddrToStr(const Overbyteicstypes::TSockAddrIn6 &ASockAddr);
extern DELPHI_PACKAGE Overbyteicstypes::TIcsIPv6Address __fastcall IcsIPv6AddrFromAddrInfo(Overbyteicstypes::PAddrInfo AddrInfo);
extern DELPHI_PACKAGE int __fastcall WSocketFamilyToAF(Overbyteicstypes::TSocketFamily AFamily);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketSocksErrorDesc(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketHttpTunnelErrorDesc(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketProxyErrorDesc(int ErrCode);
extern DELPHI_PACKAGE bool __fastcall WSocketIsProxyErrorCode(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketErrorMsgFromErrorCode(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketGetErrorMsgFromErrorCode(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall WSocketErrorDesc(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall GetWinsockErr(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall GetWindowsErr(int ErrCode);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsParseEmail(System::UnicodeString FriendlyEmail, System::UnicodeString &FriendlyName);
extern DELPHI_PACKAGE void __fastcall IcsSimpleLogging(const System::UnicodeString FNameMask, const System::UnicodeString Msg);
extern DELPHI_PACKAGE void __fastcall IcsOutputDebugStr(const System::UnicodeString AMsg);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsMaskIpv4Addr(const System::UnicodeString IpStr, const System::UnicodeString IpMask);
}	/* namespace Overbyteicsutils */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSUTILS)
using namespace Overbyteicsutils;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsUtilsHPP
