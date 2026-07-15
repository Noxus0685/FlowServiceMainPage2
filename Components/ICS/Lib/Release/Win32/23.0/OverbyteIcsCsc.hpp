// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsCsc.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsCscHPP
#define OverbyteIcsCscHPP

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
#include <OverbyteIcsMLang.hpp>
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <System.Math.hpp>
#include <OverbyteIcsTypes.hpp>
#include <OverbyteIcsUtils.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicscsc
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TIcsCsc;
class DELPHICLASS TIcsCscStr;
//-- type declarations -------------------------------------------------------
enum DECLSPEC_DENUM TIcsCharsetType : unsigned char { ictSbcs, ictDbcs, ictMbcs, ictMbcsUnicode, ictUnicode };

enum DECLSPEC_DENUM Overbyteicscsc__1 : unsigned char { ncfSkipEILSEQ, ncfSkipEINVAL };

typedef System::Set<Overbyteicscsc__1, Overbyteicscsc__1::ncfSkipEILSEQ, Overbyteicscsc__1::ncfSkipEINVAL> TIcsNextCodePointFlags;

typedef int __fastcall (*TIcsCpSizeFunc)(TIcsCsc* Csc, void * Buf, int BufSize);

typedef int __fastcall (*TIcsConvertFunc)(TIcsCsc* Csc, System::LongWord Flags, void * InBuf, int InSize, void * OutBuf, int OutSize);

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsCsc : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::LongWord FCodePage;
	TIcsCharsetType FCharSetType;
	System::WideChar FDefaultUnicodeChar;
	char FDefaultAnsiChar;
	int FMinCpSize;
	Overbyteicsutils::TIcsDbcsLeadBytes FLeadBytes;
	TIcsConvertFunc FToWcFunc;
	TIcsConvertFunc FFromWcFunc;
	TIcsCpSizeFunc FCpSizeFunc;
	
protected:
	System::LongWord FToWcShiftState;
	System::LongWord FFromWcShiftState;
	virtual void __fastcall SetCodePage(const System::LongWord Value);
	virtual void __fastcall Init();
	
public:
	__fastcall virtual TIcsCsc(System::LongWord CodePage);
	__fastcall virtual ~TIcsCsc();
	Overbyteicstypes::TBytes __fastcall GetBomBytes();
	int __fastcall GetBufferEncoding(const void * Buf, int BufSize, bool Detect);
	void __fastcall ClearToWcShiftState();
	void __fastcall ClearFromWcShiftState();
	void __fastcall ClearAllShiftStates();
	int __fastcall GetNextCodePointSize(void * Buf, int BufSize, TIcsNextCodePointFlags Flags = (TIcsNextCodePointFlags() << Overbyteicscsc__1::ncfSkipEILSEQ ));
	void * __fastcall GetNextCodePoint(void * Buf, int BufSize, TIcsNextCodePointFlags Flags = (TIcsNextCodePointFlags() << Overbyteicscsc__1::ncfSkipEILSEQ ));
	virtual int __fastcall FromWc(System::LongWord Flags, void * InBuf, int InSize, void * OutBuf, int OutSize);
	virtual int __fastcall ToWc(System::LongWord Flags, void * InBuf, int InSize, void * OutBuf, int OutSize);
	__property TIcsCharsetType CharSetType = {read=FCharSetType, nodefault};
	__property Overbyteicsutils::TIcsDbcsLeadBytes LeadBytes = {read=FLeadBytes};
	__property System::LongWord CodePage = {read=FCodePage, write=SetCodePage, nodefault};
	__property System::WideChar DefaultUnicodeChar = {read=FDefaultUnicodeChar, nodefault};
	__property char DefaultAnsiChar = {read=FDefaultAnsiChar, nodefault};
	__property int MinCpSize = {read=FMinCpSize, nodefault};
};

#pragma pack(pop)

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsCscStr : public TIcsCsc
{
	typedef TIcsCsc inherited;
	
public:
	int __fastcall GetNextCodePointIndex(const System::RawByteString S, int Index, TIcsNextCodePointFlags Flags = (TIcsNextCodePointFlags() << Overbyteicscsc__1::ncfSkipEILSEQ ))/* overload */;
	int __fastcall GetNextCodePointIndex(const System::UnicodeString S, int Index, TIcsNextCodePointFlags Flags = (TIcsNextCodePointFlags() << Overbyteicscsc__1::ncfSkipEILSEQ ))/* overload */;
public:
	/* TIcsCsc.Create */ inline __fastcall virtual TIcsCscStr(System::LongWord CodePage) : TIcsCsc(CodePage) { }
	/* TIcsCsc.Destroy */ inline __fastcall virtual ~TIcsCscStr() { }
	
};

#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Int8 ICS_ERR_EINVAL = System::Int8(-1);
static _DELPHI_CONST System::Int8 ICS_ERR_E2BIG = System::Int8(-2);
static _DELPHI_CONST System::Int8 ICS_ERR_EILSEQ = System::Int8(-10);
extern DELPHI_PACKAGE int __fastcall IcsCscGetWideCharCount(TIcsCsc* Csc, const void * Buf, int BufSize, /* out */ int &BytesLeft);
extern DELPHI_PACKAGE int __fastcall IcsCscGetWideChars(TIcsCsc* Csc, const void * Buf, int BufSize, System::WideChar * Chars, int WCharCount);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsCscBufferToUnicodeString(TIcsCsc* Csc, const void * Buf, int BufSize, /* out */ int &BytesLeft);
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsCscToWcString(TIcsCsc* Csc, const void * Buf, int BufSize);
}	/* namespace Overbyteicscsc */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSCSC)
using namespace Overbyteicscsc;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsCscHPP
