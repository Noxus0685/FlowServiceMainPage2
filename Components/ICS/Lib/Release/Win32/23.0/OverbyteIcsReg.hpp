// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'OverbyteIcsReg.pas' rev: 36.00 (Windows)

#ifndef OverbyteIcsRegHPP
#define OverbyteIcsRegHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <OverbyteIcsMimeDec.hpp>
#include <OverbyteIcsMimeUtils.hpp>
#include <OverbyteIcsTimeList.hpp>
#include <OverbyteIcsLogger.hpp>
#include <System.SysUtils.hpp>
#include <System.Classes.hpp>
#include <DesignIntf.hpp>
#include <DesignEditors.hpp>
#include <OverbyteIcsTypes.hpp>

//-- user supplied -----------------------------------------------------------

namespace Overbyteicsreg
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TIcsTypesSelEdt;
class DELPHICLASS TIcsSslTypesSelEdt;
//-- type declarations -------------------------------------------------------
#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsTypesSelEdt : public Designeditors::TSelectionEditor
{
	typedef Designeditors::TSelectionEditor inherited;
	
public:
	virtual void __fastcall RequiresUnits(System::Classes::TGetStrProc Proc);
public:
	/* TSelectionEditor.Create */ inline __fastcall virtual TIcsTypesSelEdt(const Designintf::_di_IDesigner ADesigner) : Designeditors::TSelectionEditor(ADesigner) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TIcsTypesSelEdt() { }
	
};

#pragma pack(pop)

#pragma pack(push,4)
class PASCALIMPLEMENTATION TIcsSslTypesSelEdt : public Designeditors::TSelectionEditor
{
	typedef Designeditors::TSelectionEditor inherited;
	
public:
	virtual void __fastcall RequiresUnits(System::Classes::TGetStrProc Proc);
public:
	/* TSelectionEditor.Create */ inline __fastcall virtual TIcsSslTypesSelEdt(const Designintf::_di_IDesigner ADesigner) : Designeditors::TSelectionEditor(ADesigner) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TIcsSslTypesSelEdt() { }
	
};

#pragma pack(pop)

//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE void __fastcall Register();
}	/* namespace Overbyteicsreg */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_OVERBYTEICSREG)
using namespace Overbyteicsreg;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// OverbyteIcsRegHPP
