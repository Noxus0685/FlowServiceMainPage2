// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsLogger.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsLoggerHPP
#define OverbyteIcsLoggerHPP

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
#include <System.SyncObjs.hpp>
#include <OverbyteIcsUtils.hpp>
#include <OverbyteIcsTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicslogger
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS ELoggerException;
class DELPHICLASS TIcsLogger;
//-- type declarations -------------------------------------------------------
#pragma pack(push,4)
class PASCALIMPLEMENTATION ELoggerException : public System::Sysutils::Exception
{
	typedef System::Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall ELoggerException(const System::UnicodeString Msg) : System::Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall ELoggerException(const System::UnicodeString Msg, const System::TVarRec *Args, const System::NativeInt Args_High) : System::Sysutils::Exception(Msg, Args, Args_High) { }
	/* Exception.CreateRes */ inline __fastcall ELoggerException(System::NativeUInt Ident)/* overload */ : System::Sysutils::Exception(Ident) { }
	/* Exception.CreateRes */ inline __fastcall ELoggerException(System::PResStringRec ResStringRec)/* overload */ : System::Sysutils::Exception(ResStringRec) { }
	/* Exception.CreateResFmt */ inline __fastcall ELoggerException(System::NativeUInt Ident, const System::TVarRec *Args, const System::NativeInt Args_High)/* overload */ : System::Sysutils::Exception(Ident, Args, Args_High) { }
	/* Exception.CreateResFmt */ inline __fastcall ELoggerException(System::PResStringRec ResStringRec, const System::TVarRec *Args, const System::NativeInt Args_High)/* overload */ : System::Sysutils::Exception(ResStringRec, Args, Args_High) { }
	/* Exception.CreateHelp */ inline __fastcall ELoggerException(const System::UnicodeString Msg, int AHelpContext) : System::Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall ELoggerException(const System::UnicodeString Msg, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext) : System::Sysutils::Exception(Msg, Args, Args_High, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall ELoggerException(System::NativeUInt Ident, int AHelpContext)/* overload */ : System::Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall ELoggerException(System::PResStringRec ResStringRec, int AHelpContext)/* overload */ : System::Sysutils::Exception(ResStringRec, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall ELoggerException(System::PResStringRec ResStringRec, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext)/* overload */ : System::Sysutils::Exception(ResStringRec, Args, Args_High, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall ELoggerException(System::NativeUInt Ident, const System::TVarRec *Args, const System::NativeInt Args_High, int AHelpContext)/* overload */ : System::Sysutils::Exception(Ident, Args, Args_High, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~ELoggerException() { }
	
};

#pragma pack(pop)

typedef void __fastcall (__closure *TIcsLogEvent)(System::TObject* Sender, Overbyteicstypes::TLogOption LogOption, const System::UnicodeString Msg);

class PASCALIMPLEMENTATION TIcsLogger : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
protected:
	Overbyteicstypes::TLogOptions FLogOptions;
	TIcsLogEvent FOnIcsLogEvent;
	System::UnicodeString FLogFileName;
	System::Classes::TFileStream* FLogFile;
	Overbyteicstypes::TLogFileOption FLogFileOption;
	System::UnicodeString FTimeStampFormatString;
	System::UnicodeString FTimeStampSeparator;
	Overbyteicstypes::TLogFileEncoding FLogFileEncoding;
	Overbyteicstypes::TLogFileEncoding FLogFileInternalEnc;
	System::Syncobjs::TCriticalSection* FLock;
	void __fastcall Lock();
	void __fastcall UnLock();
	void __fastcall WriteToLogFile(const System::UnicodeString S);
	void __fastcall SetLogFileOption(const Overbyteicstypes::TLogFileOption Value);
	void __fastcall SetLogOptions(const Overbyteicstypes::TLogOptions Value);
	void __fastcall SetLogFileName(const System::UnicodeString Value);
	void __fastcall SetOnIcsLogEvent(const TIcsLogEvent Value);
	void __fastcall InternalOpenLogFile();
	void __fastcall InternalCloseLogFile();
	System::UnicodeString __fastcall AddTimeStamp();
	
public:
	__fastcall virtual TIcsLogger(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TIcsLogger();
	void __fastcall OpenLogFile();
	void __fastcall CloseLogFile();
	void __fastcall DoDebugLog(System::TObject* Sender, Overbyteicstypes::TLogOption LogOption, const System::UnicodeString Msg);
	HIDESBASE void __fastcall FreeNotification(System::Classes::TComponent* AComponent);
	HIDESBASE void __fastcall RemoveFreeNotification(System::Classes::TComponent* AComponent);
	
__published:
	__property System::UnicodeString TimeStampFormatString = {read=FTimeStampFormatString, write=FTimeStampFormatString};
	__property System::UnicodeString TimeStampSeparator = {read=FTimeStampSeparator, write=FTimeStampSeparator};
	__property Overbyteicstypes::TLogFileOption LogFileOption = {read=FLogFileOption, write=SetLogFileOption, nodefault};
	__property Overbyteicstypes::TLogFileEncoding LogFileEncoding = {read=FLogFileEncoding, write=FLogFileEncoding, nodefault};
	__property System::UnicodeString LogFileName = {read=FLogFileName, write=SetLogFileName};
	__property Overbyteicstypes::TLogOptions LogOptions = {read=FLogOptions, write=SetLogOptions, nodefault};
	__property TIcsLogEvent OnIcsLogEvent = {read=FOnIcsLogEvent, write=SetOnIcsLogEvent};
};


//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word TIcsLoggerVersion = System::Word(0x3e8);
extern DELPHI_PACKAGE System::UnicodeString CopyRight;
}	/* namespace Overbyteicslogger */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSLOGGER)
using namespace Overbyteicslogger;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsLoggerHPP
