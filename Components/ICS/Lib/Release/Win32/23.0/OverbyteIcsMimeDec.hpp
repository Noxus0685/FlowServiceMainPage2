// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsMimeDec.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsMimeDecHPP
#define OverbyteIcsMimeDecHPP

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
#include <System.AnsiStrings.hpp>
#include <OverbyteIcsTypes.hpp>
#include <OverbyteIcsUtils.hpp>
#include <OverbyteIcsMimeUtils.hpp>
#include <OverbyteIcsCharsetUtils.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsmimedec
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TMimeDecode;
class DELPHICLASS TMimeDecodeW;
struct TPartInfo;
class DELPHICLASS TMimeDecodeEx;
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TMimeDecodePartLine)(System::TObject* Sender, void * Data, int DataLen);

typedef void __fastcall (__closure *TInlineDecodeBegin)(System::TObject* Sender, System::AnsiString Filename);

typedef void __fastcall (__closure *TInlineDecodeLine)(System::TObject* Sender, void * Line, int Len);

typedef void __fastcall (__closure *TInlineDecodeEnd)(System::TObject* Sender, System::AnsiString Filename);

class PASCALIMPLEMENTATION TMimeDecode : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
protected:
	System::AnsiString FFrom;
	System::AnsiString FDest;
	System::AnsiString FCc;
	System::AnsiString FSubject;
	System::AnsiString FDate;
	System::AnsiString FReturnPath;
	System::AnsiString FEncoding;
	System::AnsiString FCharSet;
	System::LongWord FCodePage;
	System::AnsiString FContentType;
	System::AnsiString FMimeVersion;
	System::AnsiString FHeaderName;
	System::AnsiString FDisposition;
	System::AnsiString FFileName;
	System::AnsiString FFormat;
	System::Classes::TStrings* FHeaderLines;
	bool FIsMultipart;
	bool FIsTextpart;
	bool FEndOfMime;
	System::AnsiString FPartContentType;
	System::AnsiString FPartEncoding;
	int FPartNumber;
	bool FPartHeaderBeginSignaled;
	System::AnsiString FPartName;
	System::AnsiString FPartDisposition;
	System::AnsiString FPartContentID;
	System::AnsiString FPartFileName;
	System::AnsiString FPartFormat;
	System::AnsiString FPartCharset;
	System::LongWord FPartCodePage;
	System::AnsiString FApplicationType;
	bool FPartOpened;
	bool FHeaderFlag;
	int FLineNum;
	char *FBuffer;
	int FBufferSize;
	char *FCurrentData;
	System::AnsiString FBoundary;
	bool FBoundaryFound;
	bool FBoundaryParts;
	bool FLooseRFC;
	int FPartLevel;
	bool FUUProcessFlag;
	bool FProcessFlagYBegin;
	int FSizeFileY;
	int FSizeBlocY;
	int FSizeLeftY;
	void __fastcall (__closure *FNext)();
	System::Classes::TStream* FDestStream;
	System::AnsiString cUUFilename;
	System::Classes::TStringList* FEmbeddedBoundary;
	bool cIsEmbedded;
	System::Classes::TNotifyEvent FOnHeaderBegin;
	System::Classes::TNotifyEvent FOnHeaderLine;
	System::Classes::TNotifyEvent FOnHeaderEnd;
	System::Classes::TNotifyEvent FOnPartHeaderBegin;
	System::Classes::TNotifyEvent FOnPartHeaderLine;
	System::Classes::TNotifyEvent FOnPartHeaderEnd;
	System::Classes::TNotifyEvent FOnPartBegin;
	TMimeDecodePartLine FOnPartLine;
	System::Classes::TNotifyEvent FOnPartEnd;
	System::Classes::TNotifyEvent FOnMessageEnd;
	TInlineDecodeBegin FOnInlineDecodeBegin;
	TInlineDecodeLine FOnInlineDecodeLine;
	TInlineDecodeEnd FOnInlineDecodeEnd;
	bool FInlineDecodeLine;
	int FLengthHeader;
	bool FPartFirstLine;
	System::LongWord FDefaultCodePage;
	void __fastcall SetDefaultCodePage(const System::LongWord Value);
	virtual void __fastcall TriggerHeaderBegin();
	virtual void __fastcall TriggerHeaderLine();
	virtual void __fastcall TriggerHeaderEnd();
	virtual void __fastcall TriggerPartHeaderBegin();
	virtual void __fastcall TriggerPartHeaderLine();
	virtual void __fastcall TriggerPartHeaderEnd();
	virtual void __fastcall TriggerPartBegin();
	virtual void __fastcall TriggerPartLine(void * Data, int DataLen);
	virtual void __fastcall TriggerPartEnd();
	virtual void __fastcall TriggerMessageEnd();
	virtual void __fastcall TriggerInlineDecodeBegin(const System::AnsiString Filename);
	virtual void __fastcall TriggerInlineDecodeLine(void * Line, int Len);
	virtual void __fastcall TriggerInlineDecodeEnd(const System::AnsiString Filename);
	void __fastcall ProcessLineUUDecode();
	bool __fastcall UUProcessLine(char * FCurrentData);
	void __fastcall ProcessHeaderLine();
	void __fastcall ProcessPartHeaderLine();
	void __fastcall ProcessPartLine();
	void __fastcall ProcessWaitBoundary();
	void __fastcall ProcessMessageLine();
	void __fastcall PreparePart();
	void __fastcall PrepareNextPart();
	void __fastcall ProcessDecodedLine(void * Line, int Len);
	void __fastcall InternalDecodeStream(System::Classes::TStream* aStream);
	void __fastcall MessageBegin();
	void __fastcall MessageEnd();
	void __fastcall ParseYBegin(const System::AnsiString Ch);
	
public:
	__fastcall virtual TMimeDecode(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TMimeDecode();
	void __fastcall DecodeFile(const System::UnicodeString FileName);
	void __fastcall DecodeStream(System::Classes::TStream* aStream);
	void __fastcall ProcessLineBase64();
	void __fastcall ProcessLineQuotedPrintable();
	__property System::AnsiString From = {read=FFrom};
	__property System::AnsiString Dest = {read=FDest};
	__property System::AnsiString Cc = {read=FCc};
	__property System::AnsiString Subject = {read=FSubject};
	__property System::AnsiString Date = {read=FDate};
	__property System::AnsiString ReturnPath = {read=FReturnPath};
	__property System::AnsiString ContentType = {read=FContentType};
	__property System::AnsiString Encoding = {read=FEncoding};
	__property System::AnsiString Charset = {read=FCharSet};
	__property System::LongWord CodePage = {read=FCodePage, nodefault};
	__property System::AnsiString MimeVersion = {read=FMimeVersion};
	__property System::AnsiString HeaderName = {read=FHeaderName};
	__property System::AnsiString Disposition = {read=FDisposition};
	__property System::AnsiString FileName = {read=FFileName};
	__property System::AnsiString Format = {read=FFormat};
	__property System::Classes::TStrings* HeaderLines = {read=FHeaderLines};
	__property bool IsMultipart = {read=FIsMultipart, nodefault};
	__property bool IsTextpart = {read=FIsTextpart, nodefault};
	__property bool EndOfMime = {read=FEndOfMime, nodefault};
	__property System::AnsiString PartContentType = {read=FPartContentType};
	__property System::AnsiString PartEncoding = {read=FPartEncoding};
	__property System::AnsiString PartName = {read=FPartName};
	__property System::AnsiString PartDisposition = {read=FPartDisposition};
	__property System::AnsiString PartContentID = {read=FPartContentID};
	__property System::AnsiString PartFileName = {read=FPartFileName};
	__property System::AnsiString PartFormat = {read=FPartFormat};
	__property System::AnsiString PartCharset = {read=FPartCharset};
	__property System::LongWord PartCodePage = {read=FPartCodePage, write=FPartCodePage, nodefault};
	__property System::AnsiString ApplicationType = {read=FApplicationType};
	__property int PartNumber = {read=FPartNumber, nodefault};
	__property int PartLevel = {read=FPartLevel, nodefault};
	__property char * CurrentData = {read=FCurrentData, write=FCurrentData};
	__property System::Classes::TStream* DestStream = {read=FDestStream, write=FDestStream};
	__property bool InlineDecodeLine = {read=FInlineDecodeLine, write=FInlineDecodeLine, default=0};
	__property int LengthHeader = {read=FLengthHeader, nodefault};
	__property System::LongWord DefaultCodePage = {read=FDefaultCodePage, write=SetDefaultCodePage, nodefault};
	
__published:
	__property bool LooseRFC = {read=FLooseRFC, write=FLooseRFC, nodefault};
	__property System::Classes::TNotifyEvent OnHeaderBegin = {read=FOnHeaderBegin, write=FOnHeaderBegin};
	__property System::Classes::TNotifyEvent OnHeaderLine = {read=FOnHeaderLine, write=FOnHeaderLine};
	__property System::Classes::TNotifyEvent OnHeaderEnd = {read=FOnHeaderEnd, write=FOnHeaderEnd};
	__property System::Classes::TNotifyEvent OnPartHeaderBegin = {read=FOnPartHeaderBegin, write=FOnPartHeaderBegin};
	__property System::Classes::TNotifyEvent OnPartHeaderLine = {read=FOnPartHeaderLine, write=FOnPartHeaderLine};
	__property System::Classes::TNotifyEvent OnPartHeaderEnd = {read=FOnPartHeaderEnd, write=FOnPartHeaderEnd};
	__property System::Classes::TNotifyEvent OnPartBegin = {read=FOnPartBegin, write=FOnPartBegin};
	__property TMimeDecodePartLine OnPartLine = {read=FOnPartLine, write=FOnPartLine};
	__property System::Classes::TNotifyEvent OnPartEnd = {read=FOnPartEnd, write=FOnPartEnd};
	__property System::Classes::TNotifyEvent OnMessageEnd = {read=FOnMessageEnd, write=FOnMessageEnd};
	__property TInlineDecodeBegin OnInlineDecodeBegin = {read=FOnInlineDecodeBegin, write=FOnInlineDecodeBegin};
	__property TInlineDecodeLine OnInlineDecodeLine = {read=FOnInlineDecodeLine, write=FOnInlineDecodeLine};
	__property TInlineDecodeEnd OnInlineDecodeEnd = {read=FOnInlineDecodeEnd, write=FOnInlineDecodeEnd};
};


class PASCALIMPLEMENTATION TMimeDecodeW : public TMimeDecode
{
	typedef TMimeDecode inherited;
	
private:
	System::UnicodeString __fastcall GetCcW();
	System::UnicodeString __fastcall GetDestW();
	System::UnicodeString __fastcall GetFileNameW();
	System::UnicodeString __fastcall GetFromW();
	System::UnicodeString __fastcall GetPartFileNameW();
	System::UnicodeString __fastcall GetPartNameW();
	System::UnicodeString __fastcall GetSubjectW();
	System::UnicodeString __fastcall GetDateW();
	System::UnicodeString __fastcall GetReturnPathW();
	System::UnicodeString __fastcall GetContentTypeW();
	System::UnicodeString __fastcall GetEncodingW();
	System::UnicodeString __fastcall GetCharsetW();
	
protected:
	virtual void __fastcall TriggerPartBegin();
	
public:
	__property System::UnicodeString FromW = {read=GetFromW};
	__property System::UnicodeString DestW = {read=GetDestW};
	__property System::UnicodeString CcW = {read=GetCcW};
	__property System::UnicodeString SubjectW = {read=GetSubjectW};
	__property System::UnicodeString FileNameW = {read=GetFileNameW};
	__property System::UnicodeString PartNameW = {read=GetPartNameW};
	__property System::UnicodeString PartFileNameW = {read=GetPartFileNameW};
	__property System::UnicodeString DateW = {read=GetDateW};
	__property System::UnicodeString ReturnPathW = {read=GetReturnPathW};
	__property System::UnicodeString ContentTypeW = {read=GetContentTypeW};
	__property System::UnicodeString EncodingW = {read=GetEncodingW};
	__property System::UnicodeString CharsetW = {read=GetCharsetW};
public:
	/* TMimeDecode.Create */ inline __fastcall virtual TMimeDecodeW(System::Classes::TComponent* AOwner) : TMimeDecode(AOwner) { }
	/* TMimeDecode.Destroy */ inline __fastcall virtual ~TMimeDecodeW() { }
	
};


struct DECLSPEC_DRECORD TPartInfo
{
public:
	System::AnsiString PContentType;
	System::AnsiString PCharset;
	System::AnsiString PApplType;
	System::UnicodeString PName;
	System::AnsiString PEncoding;
	System::AnsiString PDisposition;
	System::AnsiString PContentId;
	System::UnicodeString PFileName;
	System::Classes::TMemoryStream* PartStream;
	int PSize;
	System::LongWord PCodePage;
	bool PIsTextpart;
	int PLevel;
	System::UnicodeString PInfo;
};


class PASCALIMPLEMENTATION TMimeDecodeEx : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
	
private:
	typedef System::DynamicArray<System::UnicodeString> _TMimeDecodeEx__1;
	
	typedef System::DynamicArray<TPartInfo> _TMimeDecodeEx__2;
	
	
private:
	void __fastcall MimeDecodeHeaderLine(System::TObject* Sender);
	void __fastcall MimeDecodePartBegin(System::TObject* Sender);
	void __fastcall MimeDecodePartEnd(System::TObject* Sender);
	bool __fastcall GetLooseRFC();
	void __fastcall SetLooseRFC(bool Value);
	
protected:
	TMimeDecodeW* FDecodeW;
	int FMaxParts;
	int FTotParts;
	int FDecParts;
	int FTotHeaders;
	System::AnsiString FHeaderCharset;
	bool FSkipBlankParts;
	TPartInfo __fastcall GetPartInfo(int Index);
	System::UnicodeString __fastcall GetCcW();
	System::UnicodeString __fastcall GetDestW();
	System::UnicodeString __fastcall GetFileNameW();
	System::UnicodeString __fastcall GetFromW();
	System::UnicodeString __fastcall GetPartFileNameW();
	System::UnicodeString __fastcall GetPartNameW();
	System::UnicodeString __fastcall GetSubjectW();
	System::UnicodeString __fastcall GetDateW();
	System::UnicodeString __fastcall GetReturnPathW();
	System::UnicodeString __fastcall GetContentTypeW();
	System::UnicodeString __fastcall GetEncodingW();
	System::UnicodeString __fastcall GetCharsetW();
	
public:
	System::Classes::TStrings* FHeaderLines;
	_TMimeDecodeEx__1 WideHeaders;
	_TMimeDecodeEx__2 PartInfos;
	__fastcall virtual TMimeDecodeEx(System::Classes::TComponent* Aowner);
	__fastcall virtual ~TMimeDecodeEx();
	void __fastcall Initialise();
	void __fastcall Reset();
	void __fastcall Finalise();
	void __fastcall DecodeFileEx(const System::UnicodeString FileName);
	void __fastcall DecodeStreamEx(System::Classes::TStream* aStream);
	
__published:
	__property TMimeDecodeW* DecodeW = {read=FDecodeW};
	__property System::Classes::TStrings* HeaderLines = {read=FHeaderLines};
	__property int MaxParts = {read=FMaxParts, write=FMaxParts, nodefault};
	__property int TotParts = {read=FTotParts, nodefault};
	__property int DecParts = {read=FDecParts, nodefault};
	__property int TotHeaders = {read=FTotHeaders, nodefault};
	__property System::AnsiString HeaderCharset = {read=FHeaderCharset};
	__property bool SkipBlankParts = {read=FSkipBlankParts, write=FSkipBlankParts, nodefault};
	__property System::UnicodeString FromW = {read=GetFromW};
	__property System::UnicodeString DestW = {read=GetDestW};
	__property System::UnicodeString CcW = {read=GetCcW};
	__property System::UnicodeString SubjectW = {read=GetSubjectW};
	__property System::UnicodeString FileNameW = {read=GetFileNameW};
	__property System::UnicodeString PartNameW = {read=GetPartNameW};
	__property System::UnicodeString PartFileNameW = {read=GetPartFileNameW};
	__property System::UnicodeString DateW = {read=GetDateW};
	__property System::UnicodeString ReturnPathW = {read=GetReturnPathW};
	__property System::UnicodeString ContentTypeW = {read=GetContentTypeW};
	__property System::UnicodeString EncodingW = {read=GetEncodingW};
	__property System::UnicodeString CharsetW = {read=GetCharsetW};
	__property bool LooseRFC = {read=GetLooseRFC, write=SetLooseRFC, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word MimeDecodeVersion = System::Word(0x3e8);
extern DELPHI_PACKAGE System::UnicodeString CopyRight;
extern DELPHI_PACKAGE System::AnsiString __fastcall UnfoldHdrValue(const char * Value)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall UnfoldHdrValue(const System::AnsiString Value)/* overload */;
extern DELPHI_PACKAGE char * __fastcall GetToken(char * Src, System::AnsiString &Dst, char &Delim);
extern DELPHI_PACKAGE bool __fastcall IsCrLf1Char(char Ch);
extern DELPHI_PACKAGE bool __fastcall IsCrLf1OrSpaceChar(char Ch);
extern DELPHI_PACKAGE System::UnicodeString __fastcall DecodeMimeInlineValue(const System::AnsiString Value);
extern DELPHI_PACKAGE System::UnicodeString __fastcall DecodeMimeInlineValueEx(const System::AnsiString Value, System::AnsiString &CharSet);
}	/* namespace Overbyteicsmimedec */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSMIMEDEC)
using namespace Overbyteicsmimedec;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsMimeDecHPP
