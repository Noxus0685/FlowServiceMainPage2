unit FmxFPDeviceManager;

uses System.SysUtils, FmxFPModule,FmxFPModuleManager;
Êëàññ îòâå÷àåò çà ñîçäàíèå ìîäóëåé è íàçíà÷åíèå èõ óñòðîéñòâàì.
}

interface

uses FmxFPModule,FmxFPModuleManager;
const
  cBooleanName:array[boolean] of String=('Íåò','Äà');
  cSimpleBooleanName:array[boolean] of String=('0','1');
type
//============================================================================================================

  // Çàïèñü, ïðåäñòàâëÿþùàÿ èñïîëüçóåìûé ìîäóëü.
  TUsedModule = record
    // Óêàçàòåëü íà èñïîëüçóåìûé ìîäóëü.
    Module: TFmxModule;
  end;

  //==========================================================================================================

  TFmxDeviceManager = class

  private

    FModuleManager: TFmxModuleManager;

    // Äèíàìè÷åñêèé ìàññèâ èñïîëüçóåìûõ ìîäóëåé.
//    UsedModules: array of TUsedModule;
    FModbusTCPPort: word;
    FModbusTCPHost: string;
    function GetModulesCount: integer;
    function GetModule(Idx: integer): TFmxModule;
    function GetNameOfTypeModule(Idx: integer): String;
    function GetCurrentModule: Integer;
    procedure SetModbusTCPHost(const Value: string);
    procedure SetModbusTCPPort(const Value: word);

  public

    // Èñïîëüçóåìûé ìåíåäæåð ìîäóëåé.
    property ModuleManager: TFmxModuleManager read FModuleManager;

    constructor Create(AHost:String;APort:Word);
    destructor Destroy; override;

    { ===== DetermineModule =====
    Îïðåäåëÿåò (íàçíà÷àåò) èñïîëüçóåìûé óñòðîéñòâîì ìîäóëü.
    Ïðèíèìàåìûå ïàðàìåòðû:
    module_type - òèï èñïîëüçóåìîãî ìîäóëÿ;
    module_identifier - èäåíòèôèêàòîð èñïîëüçóåìîãî ìîäóëÿ (îäèíàêîâûé äëÿ óñòðîéñòâ, èñïîëüçóþùèõ îäèí
                        ìîäóëü); åñëè èñïîëüçóåòñÿ ìîäóëü ñ àäðåñîì, òî ýòîò àäðåñ ïåðåäàåòñÿ â êà÷åñòâå
                        èäåíòèôèêàòîðà.
    Åñëè ìîäóëÿ òàêîãî òèïà åùå íå ñîçäàíî èëè ñðåäè ñîçäàííûõ íåò ñ òàêèì æå èäåíòèôèêàòîðîì, òî ñîçäàåò
    íîâûé è âîçâðàùàåò óêàçàòåëü íà íåãî. Èíà÷å âîçâðàùàåò óêàçàòåëü íà óæå ñîçäàííûé.
    }
    function DetermineModule(port:integer;module_type: TFmxModuleType; BR: Cardinal; addr: integer; _typeOfProtocol:TTypeOfProtocol=tpProprietary;AInputRegister:Word=0;AOutputRegister:word=0): TFmxModule;

    property ModulesCount:integer read GetModulesCount;

    property Module[Idx:integer]:TFmxModule read GetModule;

    property NameOfTypeModule[Idx:integer]:String read GetNameOfTypeModule;

    property CurrentModule:Integer read GetCurrentModule;

    property ModbusTCPHost:string read FModbusTCPHost write SetModbusTCPHost;

    property ModbusTCPPort:word read FModbusTCPPort write SetModbusTCPPort;
  end;
//const
//  cModuleTypeNames:Array [TFmxModuleType] of String = ('Ñ÷åò÷èêè', 'Íîâûå ñ÷åò÷èêè','ÓÏÏ(1)', 'ÓÏÏ(2)', 'Prover', 'Âåñû','Âåñû Òîëåäî',
//    'Ïíåâìàòèêà', 'Òåìïåðàòóðà', 'Òåìïåðàòóðà(2)', 'Òåìïåðàòóðà(6)', 'Íàïðÿæåíèå/Òîê',
//    'Íàïðÿæåíèå/Òîê(Old)', 'Ýëåêòðîçàäâèæêè','×àñò. Danfoss','×àñò. Schneider','ÖÀÏ I702X','Warm',
//    'DigitalUnit','FastWell', 'Virt', 'ÈÂÄÃ', 'Heat', 'Àãàò','Îòêëþ÷àòåëü','Òåêñò','ÊÌ5','ÐÒ2',
//    'Danfoss(Modbus)','LogoDAC(Modbus)','Vacon(Modbus)','Hsc_Ctrl(Modbus)','Hsc_IMP(Modbus)',
//    'HSC_FCD(Modbus)','BIO2','Modbus(D)','Modbus(A)','LTA-K(USB)','Âåñû AD103Ñ','Âåñû RADWAG','×àñò. ABB','???');

//============================================================================================================
//============================================================================================================
function StrToModuleType(Value:String):TFmxModuleType;
function myStrToBool(Value:String):boolean;

implementation

uses
  FmxFPModules;

(*
     cModuleName:array[TModuleType]of String=('mtCounter','mtCounterEx','mtFCD',
   'mtFCD2','mtProver','mtScales','mtSuperBIO','mtT','mtTemp2','mtTemp6','mtUI',
   'mtOldUI','mtValve','mtVLT6000','mtWarm','mtPrem','mtFastwelUI','mtVirt',
   'mtIVDG','mtHeat', 'mtAgat');

 *)
function StrToModuleType(Value:String):TFmxModuleType;
var i:integer;
begin
   result:=mtCounterEx;
   for I := ord(mtCounter) to ord(mtNone)-1 do
   begin
     if cModuleTypeNames[TFmxModuleType(I)]=Value then
     begin
       result:=TFmxModuleType(I);
       break;
     end;
   end;
end;

function myStrToBool(Value:String):boolean;
begin
   result:=false;
   if (cBooleanName[true]=Value) or (cSimpleBooleanName[true]=Value) then
     result:=true;
end;



//============================================================================================================

constructor TFmxDeviceManager.Create(AHost:String;APort:Word);
begin
  FModuleManager := TFmxModuleManager.Create(AHost,APort);
end;

//============================================================================================================

destructor TFmxDeviceManager.Destroy;
var
  i: integer;
begin
  if Assigned(FModuleManager) then
  begin
    FModuleManager.StopAndWait;
    for i := 0 to FModuleManager.ModulesCount - 1 do
    begin
      FModuleManager.Module[i].Free;
      FModuleManager.Module[i] := nil;
    end;
  end;
  FreeAndNil(FModuleManager);
  inherited Destroy;
end;

//============================================================================================================

function TFmxDeviceManager.DetermineModule(port:integer;module_type: TFmxModuleType;BR: Cardinal;  addr: integer; _typeOfProtocol:TTypeOfProtocol=tpProprietary;AInputRegister:Word=0;AOutputRegister:word=0): TFmxModule;
var
  i,len: integer;
begin

  // Ïîèñê ñðåäè ñîçäàííûõ ìîäóëåé.
  Result := nil;
  if not Assigned(ModuleManager) then Exit;

  len:=ModuleManager.ModulesCount;
  for i:=1 to len do
    if (ModuleManager.Module[i-1].ModuleType = module_type) and
       (ModuleManager.Module[i-1].Protocol = _typeOfProtocol) and
       (ModuleManager.Module[i-1].Address = addr) and
       (ModuleManager.Module[i-1].PortNumber = port) and
       (
         (ModuleManager.Module[i-1].Protocol=tpProprietary) or
         (
          (ModuleManager.Module[i-1].InputRegister = AInputRegister) and
          (ModuleManager.Module[i-1].OutputRegister = AOutputRegister)
         )
       )
 then
      Result := ModuleManager.Module[i-1];

  // Ñîçäàíèå íîâîãî ìîäóëÿ, åñëè ïîèñê íå ïðèíåñ ðåçóëüòàòîâ.
  if Result = nil then
  begin
    //ModuleManager.ModulesCount:=ModuleManager.ModulesCount+1;
//    SetLength( UsedModules, Length(UsedModules) + 1 );
    case module_type of
      mtModbusD:
        ModuleManager.Module[len] := TFmxModuleModbusD.Create(port,addr,BR,_typeOfProtocol,AInputRegister,AOutputRegister,FModuleManager);
      mtModbusA:
        ModuleManager.Module[len] := TFmxModuleModbusA.Create(port,addr,BR,_typeOfProtocol,AInputRegister,AOutputRegister,FModuleManager);
      mtCounter:
        ModuleManager.Module[len] := TFmxModuleCounter.Create(port,addr,BR, FModuleManager);
      mtHSC_IMP:
        ModuleManager.Module[len] := TFmxModuleHSC_IMP.Create(port,addr,BR, FModuleManager);
      mtHSC_CTRL:
        ModuleManager.Module[len] := TFmxModuleHsc_Ctrl.Create(port,addr,BR, FModuleManager);
      mtHSC_FCD:
        ModuleManager.Module[len] := TFmxModuleHSC_FCD.Create(port,addr,BR, FModuleManager);
{!}   mtCounterEx:
        ModuleManager.Module[len] := TFmxModuleCounterEx.Create(port,addr,BR, FModuleManager);
      mtFCD:
        ModuleManager.Module[len] := TFmxModuleFCD.Create(port,addr,BR, FModuleManager);
      mtFCD2:
        ModuleManager.Module[len] := TFmxModuleFCD2.Create(port,addr,BR, FModuleManager);
      mtProver:
        ModuleManager.Module[len] := TFmxModuleProver.Create(port,addr,BR, FModuleManager);
      mtScales:
        ModuleManager.Module[len] := TFmxModuleScales.Create(port,addr,BR, FModuleManager);
      mtScalesMT:
        ModuleManager.Module[len] := TFmxModuleScalesMT.Create(port,addr,BR, FModuleManager);
      mtScalesAD103:
        ModuleManager.Module[len] := TFmxModuleScalesAD103.Create(port,addr,BR, FModuleManager);
      mtScalesRADWAG:
        ModuleManager.Module[len] := TFmxModuleScalesRADWAG.Create(port,addr,BR, FModuleManager);
      mtSuperBIO:
        ModuleManager.Module[len] := TFmxModuleSuperBIO.Create(port,addr,BR, FModuleManager);
      mtBIO:
        ModuleManager.Module[len] := TFmxModuleBIO.Create(port,addr,BR, FModuleManager);
      mtT:
        ModuleManager.Module[len] := TFmxModuleT.Create(port,addr,BR, FModuleManager);
      mtTemp2:
        ModuleManager.Module[len] := TFmxModuleTemp2.Create(port,addr,BR, FModuleManager);
      mtTemp6:
        ModuleManager.Module[len] := TFmxModuleTemp6.Create(port,addr,BR, FModuleManager);
      mtIVTM:
        ModuleManager.Module[len] := TFmxModuleIVTM.Create(port,addr,BR,FModuleManager);
      mtUI:
        ModuleManager.Module[len] := TFmxModuleUI.Create(port,addr,BR, FModuleManager);
      mtOldUI:
        ModuleManager.Module[len] := TFmxModuleOldUI.Create(port,addr,BR, FModuleManager);
      mtValve:
        ModuleManager.Module[len] := TFmxModuleValve.Create(port,addr,BR, FModuleManager);
      mtVLT6000:
        ModuleManager.Module[len] := TFmxModuleVLT6000.Create(port,addr,BR, FModuleManager);
      mtABBModbus:
        ModuleManager.Module[len] := TFmxModuleABBModbus.Create(port,addr,BR, FModuleManager);
      mtDeltaModbus:
        ModuleManager.Module[len] := TFmxModuleDeltaModbus.Create(port,addr,BR, FModuleManager);
      mtVLTModbus:
        ModuleManager.Module[len] := TFmxModuleVLTModbus.Create(port,addr,BR, FModuleManager);
      mtATV312:
        ModuleManager.Module[len] := TFmxModuleATV312.Create(port,addr,BR, FModuleManager);
      mtWarm:
        ModuleManager.Module[len] := TFmxModuleWarm.Create(port,addr,BR, FModuleManager);
      mtFastwelUI:
        ModuleManager.Module[len] := TFmxModuleFastwelUI.Create(port,addr,BR, FModuleManager);
      mtAgat:
        ModuleManager.Module[len] := TFmxModuleAgat.Create(port,addr,BR, FModuleManager);
      mtKM5:
        ModuleManager.Module[len] := TFmxModuleKM5.Create(port,addr,BR, FModuleManager);
      mtRT2:
        ModuleManager.Module[len] := TFmxModuleRT2.Create(port,addr,BR, FModuleManager);
      mtDAC_I702X:
        ModuleManager.Module[len] := TFmxModuleDAC_I702X.Create(port,addr,BR,FModuleManager);
      mtADC_I70XX:
        ModuleManager.Module[len] := TFmxModuleADC_I70XX.Create(port,addr,BR,FModuleManager);
      mtLogoDAC:
        ModuleManager.Module[len] := TFmxModuleLogoDAC.Create(port,addr,BR,FModuleManager);
      mtVaconModbus:
        ModuleManager.Module[len] := TFmxModuleVaconModbus.Create(port,addr,BR,FModuleManager);
    end;
    Result := ModuleManager.Module[len];
  end
  else
    Result.DevicesCount:=Result.DevicesCount+1;
end;

//============================================================================================================

function TFmxDeviceManager.GetCurrentModule: Integer;
begin
   if Assigned(FModuleManager) then
      result:=FModuleManager.CurrentModule
   else
      result:=0;
end;

function TFmxDeviceManager.GetModule(Idx: integer): TFmxModule;
begin
   result:=nil;
   if not Assigned(ModuleManager) then Exit;
   if (Idx<=(ModuleManager.ModulesCount)) and (Idx>0) then
      result:=ModuleManager.Module[Idx-1];
end;

function TFmxDeviceManager.GetModulesCount: integer;
begin
   if not Assigned(ModuleManager) then result:=0
   else
     result:=ModuleManager.ModulesCount;
end;


function TFmxDeviceManager.GetNameOfTypeModule(Idx: integer): String;
begin
   if (Idx<=(ModuleManager.ModulesCount)) and (Idx>0) then
      result:=cModuleTypeNames[ModuleManager.Module[Idx-1].ModuleType]
   else
      result:='???';
end;

procedure TFmxDeviceManager.SetModbusTCPHost(const Value: string);
begin
  FModbusTCPHost := Value;
  if Assigned(FModuleManager) then
     FModuleManager.ModbusTCPHost:=Value;
end;

procedure TFmxDeviceManager.SetModbusTCPPort(const Value: word);
begin
  FModbusTCPPort := Value;
  if Assigned(FModuleManager) then
     FModuleManager.ModbusTCPPort:=Value;
end;

end.
