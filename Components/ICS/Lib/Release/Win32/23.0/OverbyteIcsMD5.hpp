// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsMD5.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsMD5HPP
#define OverbyteIcsMD5HPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <OverbyteIcsTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsmd5
{
//-- forward type declarations -----------------------------------------------
struct TMD5Context;
//-- type declarations -------------------------------------------------------
typedef void __fastcall (*TMD5Progress)(System::TObject* Obj, __int64 Count, bool &Cancel);

typedef System::StaticArray<int, 4> TMD5State;

struct DECLSPEC_DRECORD TMD5Context
{
public:
	TMD5State State;
	System::StaticArray<int, 2> Count;
	
public:
	union
	{
		struct 
		{
			System::StaticArray<int, 16> BufLong;
		};
		struct 
		{
			System::StaticArray<System::Byte, 64> BufChar;
		};
		
	};
};


typedef System::StaticArray<System::Byte, 16> TMD5Digest;

//-- var, const, procedure ---------------------------------------------------
static _DELPHI_CONST System::Word MD5Version = System::Word(0x384);
extern DELPHI_PACKAGE System::UnicodeString CopyRight;
static _DELPHI_CONST System::Int8 DefaultMode = System::Int8(0x20);
extern DELPHI_PACKAGE void __fastcall MD5Init(TMD5Context &MD5Context);
extern DELPHI_PACKAGE void __fastcall MD5Update(TMD5Context &MD5Context, const void *Data, int Len);
extern DELPHI_PACKAGE void __fastcall MD5Final(TMD5Digest &Digest, TMD5Context &MD5Context);
extern DELPHI_PACKAGE void __fastcall MD5Transform(int *Buf, const System::NativeInt Buf_High, const int *Data, const System::NativeInt Data_High);
extern DELPHI_PACKAGE void __fastcall MD5UpdateBuffer(TMD5Context &MD5Context, void * Buffer, int BufSize)/* overload */;
extern DELPHI_PACKAGE void __fastcall MD5UpdateBuffer(TMD5Context &MD5Context, const System::AnsiString Buffer)/* overload */;
extern DELPHI_PACKAGE void __fastcall MD5UpdateBuffer(TMD5Context &MD5Context, const TMD5Digest &Buffer)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall MD5DigestToHex(const TMD5Digest &MD5Digest);
extern DELPHI_PACKAGE System::RawByteString __fastcall MD5DigestToLowerHexA(const TMD5Digest &MD5Digest);
extern DELPHI_PACKAGE System::UnicodeString __fastcall MD5DigestToLowerHex(const TMD5Digest &MD5Digest);
extern DELPHI_PACKAGE void __fastcall HMAC_MD5(const void *Buffer, int BufferSize, const void *Key, int KeySize, /* out */ TMD5Digest &Digest);
extern DELPHI_PACKAGE void __fastcall MD5DigestInit(TMD5Digest &MD5Digest);
extern DELPHI_PACKAGE System::AnsiString __fastcall GetMD5(void * Buffer, int BufSize)/* overload */;
extern DELPHI_PACKAGE System::UnicodeString __fastcall StrMD5(System::UnicodeString Buffer)/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall StrMD5(System::AnsiString Buffer)/* overload */;
extern DELPHI_PACKAGE void __fastcall StreamMD5Context(System::Classes::TStream* Stream, System::TObject* Obj, TMD5Progress ProgressCallback, __int64 StartPos, __int64 EndPos, TMD5Context &MD5Context);
extern DELPHI_PACKAGE System::AnsiString __fastcall StreamMD5(System::Classes::TStream* Stream, System::TObject* Obj, TMD5Progress ProgressCallback, __int64 StartPos, __int64 EndPos);
extern DELPHI_PACKAGE System::AnsiString __fastcall FileMD5(const System::UnicodeString Filename, System::TObject* Obj, TMD5Progress ProgressCallback, __int64 StartPos, __int64 EndPos, System::Word Mode = (System::Word)(0x20))/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall FileMD5(const System::UnicodeString Filename, System::Word Mode = (System::Word)(0x20))/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall FileMD5(const System::UnicodeString Filename, __int64 StartPos, __int64 EndPos, System::Word Mode = (System::Word)(0x20))/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall FileMD5(const System::UnicodeString Filename, System::TObject* Obj, TMD5Progress ProgressCallback, System::Word Mode = (System::Word)(0x20))/* overload */;
extern DELPHI_PACKAGE System::AnsiString __fastcall FileListMD5(System::Classes::TStringList* FileList, System::TObject* Obj, TMD5Progress ProgressCallback, System::Word Mode = (System::Word)(0x20));
extern DELPHI_PACKAGE System::Byte __fastcall MD5GetBufChar(const TMD5Context &MD5Context, int Index);
extern DELPHI_PACKAGE void __fastcall MD5SetBufChar(TMD5Context &MD5Context, int Index, System::Byte Value);
extern DELPHI_PACKAGE void __fastcall MD5MoveToBufChar(TMD5Context &MD5Context, const void *Data, int Offset, int Index, int Len);
extern DELPHI_PACKAGE void __fastcall MD5FillBufChar(TMD5Context &MD5Context, int Index, int Count, System::Byte Value);
extern DELPHI_PACKAGE void __fastcall MD5ContextClear(TMD5Context &MD5Context);
extern DELPHI_PACKAGE void __fastcall MD5MoveStateToDigest(const TMD5State &State, TMD5Digest &Digest);
extern DELPHI_PACKAGE bool __fastcall MD5SameDigest(const TMD5Digest &D1, const TMD5Digest &D2);
}	/* namespace Overbyteicsmd5 */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSMD5)
using namespace Overbyteicsmd5;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsMD5HPP
