// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsMimeUtils.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsMimeUtilsHPP
#define OverbyteIcsMimeUtilsHPP

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
#include <System.Win.Registry.hpp>
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <System.IniFiles.hpp>
#include <System.Math.hpp>
#include <System.AnsiStrings.hpp>
#include <OverbyteIcsTypes.hpp>
#include <OverbyteIcsUtils.hpp>
#include <OverbyteIcsCsc.hpp>
#include <OverbyteIcsCharsetUtils.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsmimeutils
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TTransparentStream;
class DELPHICLASS TMimeTypesList;
//-- type declarations -------------------------------------------------------
#pragma pack(push,4)
class PASCALIMPLEMENTATION TTransparentStream : public System::Classes::TStream
{
	typedef System::Classes::TStream inherited;
	
protected:
	virtual void __fastcall SetSize(System::LongInt NewSize)/* overload */;
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	System::Classes::TStream* FStream;
	__fastcall TTransparentStream(System::Classes::TStream* AOriginalStream);
	virtual System::LongInt __fastcall Read(void *Buffer, System::LongInt Count)/* overload */;
	virtual System::LongInt __fastcall Write(const void *Buffer, System::LongInt Count)/* overload */;
	virtual System::LongInt __fastcall Seek(System::LongInt Offset, System::Word Origin)/* overload */;
	virtual __int64 __fastcall Seek(const __int64 Offset, System::Classes::TSeekOrigin Origin)/* overload */;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TTransparentStream() { }
	
	/* Hoisted overloads: */
	
public:
	inline System::LongInt __fastcall  Read(System::Sysutils::TBytes Buffer, System::LongInt Offset, System::LongInt Count){ return System::Classes::TStream::Read(Buffer, Offset, Count); }
	inline System::LongInt __fastcall  Read(System::Sysutils::TBytes &Buffer, System::LongInt Count){ return System::Classes::TStream::Read(Buffer, Count); }
	inline System::LongInt __fastcall  Write(const System::Sysutils::TBytes Buffer, System::LongInt Offset, System::LongInt Count){ return System::Classes::TStream::Write(Buffer, Offset, Count); }
	inline System::LongInt __fastcall  Write(const System::Sysutils::TBytes Buffer, System::LongInt Count){ return System::Classes::TStream::Write(Buffer, Count); }
	inline __int64 __fastcall  Seek(const __int64 Offset, System::Word Origin){ return System::Classes::TStream::Seek(Offset, Origin); }
	
};

#pragma pack(pop)

enum DECLSPEC_DENUM TMimeTypeSrc : unsigned char { MTypeList, MTypeOS, MTypeMimeFile, MTypeKeyFile, MTypeRes };

class PASCALIMPLEMENTATION TMimeTypesList : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
private:
	System::Inifiles::THashedStringList* FContentList;
	System::Inifiles::THashedStringList* FExtensionList;
	System::Classes::TStringList* FDefaultTypes;
	System::Classes::TStringList* FStndTypes;
	System::UnicodeString FUnknownType;
	System::UnicodeString FMimeTypesFile;
	bool FLoadOSonDemand;
	bool FLoaded;
	TMimeTypeSrc FMimeTypeSrc;
	void __fastcall SetDefaultTypes(System::Classes::TStringList* Value);
	
public:
	__fastcall virtual TMimeTypesList(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TMimeTypesList();
	bool __fastcall LoadTypeList();
	void __fastcall Clear();
	int __fastcall CountExtn();
	int __fastcall CountContent();
	bool __fastcall AddContentType(const System::UnicodeString AExtn, const System::UnicodeString AContent, bool IgnoreDup = false);
	bool __fastcall LoadWinReg();
	bool __fastcall LoadFromOS();
	bool __fastcall LoadFromList();
	bool __fastcall LoadMimeFile(const System::UnicodeString AFileName);
	bool __fastcall LoadFromResource(const System::UnicodeString AResName);
	bool __fastcall LoadFromFile(const System::UnicodeString AFileName);
	bool __fastcall SaveToFile(const System::UnicodeString AFileName);
	void __fastcall LoadContentTypes(System::Classes::TStrings* AList);
	void __fastcall AddContentTypes(System::Classes::TStrings* AList, bool IgnoreDup = false);
	void __fastcall GetContentTypes(System::Classes::TStrings* AList);
	System::UnicodeString __fastcall TypeFromExtn(const System::UnicodeString AExtn);
	System::UnicodeString __fastcall TypeFromFile(const System::UnicodeString AFileName);
	System::UnicodeString __fastcall TypeGetExtn(const System::UnicodeString AContent);
	
__published:
	__property bool LoadOSonDemand = {read=FLoadOSonDemand, write=FLoadOSonDemand, nodefault};
	__property System::UnicodeString MimeTypesFile = {read=FMimeTypesFile, write=FMimeTypesFile};
	__property System::Classes::TStringList* DefaultTypes = {read=FDefaultTypes, write=SetDefaultTypes};
	__property TMimeTypeSrc MimeTypeSrc = {read=FMimeTypeSrc, write=FMimeTypeSrc, nodefault};
	__property System::UnicodeString UnknownType = {read=FUnknownType, write=FUnknownType};
};


//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word TMimeUtilsVersion = System::Word(0x388);
extern DELPHI_PACKAGE System::UnicodeString CopyRight;
static _DELPHI_CONST System::Int8 SmtpDefaultLineLength = System::Int8(0x4c);
static _DELPHI_CONST System::Word SMTP_SND_BUF_SIZE = System::Word(0x800);
#define RegContentType L"MIME\\Database\\Content Type"
#define MimeDnsJson L"application/dns-json"
#define MimeDnsMess L"application/dns-message"
#define MimeAppCert L"application/pkix-cert"
#define MimeOcspRequest L"application/ocsp-request"
#define MimeMultipart L"multipart/form-data; boundary="
#define MimeFormData L"multipart/form-data;"
#define MimeAppBinary L"application/binary"
#define MimeAppForm L"application/x-www-form-urlencoded; charset=UTF-8"
#define MimeAppXml L"application/xml; charset=UTF-8"
#define MimeAppJson L"application/json; charset=UTF-8"
extern DELPHI_PACKAGE System::Sysutils::TSysCharSet SpecialsRFC822;
extern DELPHI_PACKAGE System::Sysutils::TSysCharSet CrLfSet;
extern DELPHI_PACKAGE System::Sysutils::TSysCharSet QuotedCharSet;
extern DELPHI_PACKAGE System::Sysutils::TSysCharSet BreakCharsSet;
extern DELPHI_PACKAGE System::StaticArray<System::WideChar, 16> HexTable;
extern DELPHI_PACKAGE System::StaticArray<char, 16> HexTableA;
extern DELPHI_PACKAGE System::UnicodeString __fastcall EncodeQuotedPrintable(const System::RawByteString S, const System::Sysutils::TSysCharSet &Specials = System::Sysutils::TSysCharSet())/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall EncodeQuotedPrintable(const System::UnicodeString S, System::LongWord ACodePage, const System::Sysutils::TSysCharSet &Specials = System::Sysutils::TSysCharSet())/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall EncodeQuotedPrintable(const System::UnicodeString S, const System::Sysutils::TSysCharSet &Specials = System::Sysutils::TSysCharSet())/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall DecodeQuotedPrintable(const System::RawByteString S)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall DecodeQuotedPrintable(const System::UnicodeString S, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall DecodeQuotedPrintable(const System::UnicodeString S)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall SplitQuotedPrintableString(const System::UnicodeString S);
extern DELPHI_PACKAGE void __fastcall DotEscape(System::UnicodeString &S, bool OnlyAfterCrLf = false);
extern DELPHI_PACKAGE System::UnicodeString __fastcall FilenameToContentType(System::UnicodeString FileName);
extern DELPHI_PACKAGE System::Classes::TStream* __fastcall InitFileEncBase64(const System::UnicodeString FileName, System::Word ShareMode);
extern DELPHI_PACKAGE System::Classes::TStream* __fastcall InitStreamEncBase64(System::Classes::TStream* AStream);
extern DELPHI_PACKAGE System::UnicodeString __fastcall DoFileLoadNoEncoding(System::Classes::TStream* &Stream, bool &More);
extern DELPHI_PACKAGE System::AnsiString __fastcall DoTextFileReadNoEncoding(System::Classes::TStream* &Stream, bool &More);
extern DELPHI_PACKAGE System::AnsiString __fastcall DoFileEncQuotedPrintable(System::Classes::TStream* &Stream, bool &More);
extern DELPHI_PACKAGE System::AnsiString __fastcall DoFileEncBase64(System::Classes::TStream* &Stream, bool &More);
extern DELPHI_PACKAGE void __fastcall EndFileEncBase64(System::Classes::TStream* &Stream);
extern DELPHI_PACKAGE System::RawByteString __fastcall Base64EncodeEx(const System::RawByteString Input, int MaxCol, int &cPos, System::LongWord CodePage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64EncodeEx(const System::UnicodeString Input, int MaxCol, int &cPos, System::LongWord ACodePage)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall Base64EncodeEx(const System::UnicodeString Input, int MaxCol, int &cPos)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall IcsWrapTextEx(const System::RawByteString Line, const System::RawByteString BreakStr, const System::Sysutils::TSysCharSet &BreakingChars, int MaxCol, const System::Sysutils::TSysCharSet &QuoteChars, int &cPos, bool ForceBreak = false, System::LongWord ACodePage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall IcsWrapTextEx(const System::UnicodeString Line, const System::UnicodeString BreakStr, const System::Sysutils::TSysCharSet &BreakingChars, int MaxCol, const System::Sysutils::TSysCharSet &QuoteChars, int &cPos, bool ForceBreak = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall UnFoldHdrLine(const System::UnicodeString S);
extern DELPHI_PACKAGE bool __fastcall NeedsEncoding(const System::AnsiString S)/* overload */;
extern DELPHI_PACKAGE bool __fastcall NeedsEncoding(const System::UnicodeString S)/* overload */;
extern DELPHI_PACKAGE bool __fastcall NeedsEncodingPChar(System::WideChar * S);
extern DELPHI_PACKAGE System::RawByteString __fastcall HdrEncodeInLine(const System::RawByteString Input, const System::Sysutils::TSysCharSet &Specials, char EncType, const System::AnsiString CharSet, int MaxCol, bool DoFold, System::LongWord CodePage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall HdrEncodeInLine(const System::UnicodeString Input, const System::Sysutils::TSysCharSet &Specials, System::WideChar EncType, const System::UnicodeString CharSet, int MaxCol, bool DoFold, System::LongWord Codepage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall HdrEncodeInLineEx(const System::UnicodeString Input, const System::Sysutils::TSysCharSet &Specials, System::WideChar EncType, System::LongWord CodePage, int MaxCol, bool DoFold, bool IsMultiByteCP = false);
extern DELPHI_PACKAGE System::UnicodeString __fastcall StrEncodeQP(const System::RawByteString Input, int MaxCol, const System::Sysutils::TSysCharSet &Specials, System::LongWord CodePage = (unsigned)(0x0), bool IsMultibyteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall StrEncodeQP(const System::UnicodeString Input, int MaxCol, const System::Sysutils::TSysCharSet &Specials, System::LongWord ACodePage, bool IsMultibyteCP = false)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall StrEncodeQPEx(const System::RawByteString Buf, int MaxCol, const System::Sysutils::TSysCharSet &Specials, bool ShortSpace, int &cPos, bool DoFold, System::LongWord CodePage = (unsigned)(0x0), bool IsMultibyteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall StrEncodeQPEx(const System::UnicodeString Buf, int MaxCol, const System::Sysutils::TSysCharSet &Specials, bool ShortSpace, int &cPos, bool DoFold)/* overload */;
extern DELPHI_PACKAGE void __fastcall FoldHdrLine(System::Classes::TStrings* HdrLines, const System::UnicodeString HdrLine)/* overload */;
extern DELPHI_PACKAGE void __fastcall FoldHdrLine(System::Classes::TStrings* HdrLines, const System::RawByteString HdrLine, System::LongWord ACodePage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::RawByteString __fastcall FoldString(const System::RawByteString Input, const System::Sysutils::TSysCharSet &BreakCharsSet, int MaxCol, System::LongWord ACodePage = (unsigned)(0x0), bool IsMultiByteCP = false)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall FoldString(const System::UnicodeString Input, const System::Sysutils::TSysCharSet &BreakCharsSet, int MaxCol)/* overload */;
extern DELPHI_PACKAGE __int64 __fastcall CalcBase64AttachmentGrow(__int64 FileSize);
extern DELPHI_PACKAGE System::AnsiString __fastcall EncodeMbcsInline(System::LongWord CodePage, const System::UnicodeString Charset, System::WideChar EncType, System::WideChar * Body, int Len, bool DoFold, int MaxLen)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall EncodeMbcsInline(System::LongWord CodePage, const System::UnicodeString Charset, System::WideChar EncType, char * Body, int Len, bool DoFold, int MaxLen)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall ContentTypeGetExtn(const System::UnicodeString Content, System::UnicodeString &CLSID);
extern DELPHI_PACKAGE System::UnicodeString __fastcall ContentTypeFromExtn(const System::UnicodeString Extension);
}	/* namespace Overbyteicsmimeutils */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSMIMEUTILS)
using namespace Overbyteicsmimeutils;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsMimeUtilsHPP
