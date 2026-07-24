// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsTimeList.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsTimeListHPP
#define OverbyteIcsTimeListHPP

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

//-- user supplied -----------------------------------------------------------

namespace Overbyteicstimelist
{
//-- forward type declarations -----------------------------------------------
struct TTimeRec;
class DELPHICLASS TTimeList;
//-- type declarations -------------------------------------------------------
typedef void __fastcall (*TTimeRecFreeFct)(void * &P);

struct DECLSPEC_DRECORD TTimeRec
{
public:
	System::UnicodeString Value;
	System::TDateTime TimeMark;
	int Count;
	void *Data;
	TTimeRecFreeFct FreeFct;
};


typedef TTimeRec *PTimeRec;

typedef void __fastcall (__closure *TTimeListDeleteEvent)(System::TObject* Sender, PTimeRec PItem);

class PASCALIMPLEMENTATION TTimeList : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
public:
	PTimeRec operator[](int Index) { return this->Items[Index]; }
	
private:
	System::Classes::TList* FData;
	int FMaxItems;
	int FVersion;
	int FMaxAge;
	System::Classes::TNotifyEvent FOnChange;
	TTimeListDeleteEvent FOnDelete;
	int __fastcall GetCount();
	PTimeRec __fastcall GetItems(int Index);
	void __fastcall SetMaxItems(const int Value);
	void __fastcall SetMaxAge(const int Value);
	virtual void __fastcall TriggerChange();
	virtual void __fastcall TriggerDelete(PTimeRec PItem);
	
public:
	__fastcall virtual TTimeList(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TTimeList();
	virtual PTimeRec __fastcall Add(const System::UnicodeString Value);
	virtual PTimeRec __fastcall AddWithData(const System::UnicodeString Value, void * Data, TTimeRecFreeFct FreeFct);
	virtual int __fastcall Delete(const System::UnicodeString Value);
	virtual void __fastcall DeleteItem(int Index);
	int __fastcall IndexOf(const System::UnicodeString Value);
	virtual void __fastcall RemoveAged();
	virtual bool __fastcall RemoveItemIfAged(int Index);
	virtual void __fastcall Clear();
	__property int Count = {read=GetCount, nodefault};
	__property PTimeRec Items[int Index] = {read=GetItems/*, default*/};
	__property int Version = {read=FVersion, nodefault};
	
__published:
	__property int MaxItems = {read=FMaxItems, write=SetMaxItems, nodefault};
	__property int MaxAge = {read=FMaxAge, write=SetMaxAge, nodefault};
	__property System::Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property TTimeListDeleteEvent OnDelete = {read=FOnDelete, write=FOnDelete};
};


//-- var, const, procedure ---------------------------------------------------
}	/* namespace Overbyteicstimelist */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSTIMELIST)
using namespace Overbyteicstimelist;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsTimeListHPP
