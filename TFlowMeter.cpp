//---------------------------------------------------------------------------

#pragma hdrstop

#include "TFlowMeter.h"



int TFlowMeter::ActiveEtalonHash = 0;
int TFlowMeter::ActiveFlowMeterHash = 0;

//UnicodeString TFlowMeter::email = " ";
UnicodeString TFlowMeter::sign_cipher = " ";
UnicodeString TFlowMeter::porveritel_fio = " ";

vector<TFlowMeter*> TFlowMeter::FlowMeters;
vector<TFlowMeter*> TFlowMeter::Etalons;

std::vector<tPoint>::iterator TFlowMeter::it;

THscDevice* TFlowMeter::sHSC = nullptr;
TFlowMeter* TFlowMeter::ActiveFlowMeter = nullptr;
TFlowMeter* TFlowMeter::ActiveEtalon = nullptr;

TJSONArray* TFlowMeter::jArray = new TJSONArray();
TJSONObject* TFlowMeter::jObject = new TJSONObject();

TFlowMeter* TFlowMeter::EtalonMeter= nullptr;

TOnChanged TFlowMeter::OnChangedTestMeter= nullptr;

//---------------------------------------------------------------------------

TFlowMeter::TFlowMeter(THscDevice* HSCDev, int orderHash, bool isEtalon)
{
    Init();

    IsEtalon = isEtalon;
   // InitValues();

    OrderHash = orderHash;

    HSCDevice = HSCDev;
    HSC = HSCDevice;

    if (HSCDev!=nullptr) {

    }  else
    {

    }
}

TFlowMeter::TFlowMeter(TFlowMeter* Meter)
{
    IsEtalon = Meter->IsEtalon;


	Init();

	HSCDevice = Meter->HSCDevice;
	HSC = HSCDevice;
	// HSC->SetOnConfigRead(OnConfigRead);
    SetEtalon(Meter->EtalonMeter);
    CopyValues(Meter);
   	SetCopy(Meter);


	if (TOrderClass::ActiveOrder != nullptr) {
		OrderHash = TOrderClass::ActiveOrder->Hash;
	} else {
		OrderHash = 800;
	}
}

TFlowMeter::TFlowMeter(THscDevice* HSCDev, TFlowMeter* EtalonMeter)
{
	HSCDevice = HSCDev;
	HSC = HSCDevice;
	// HSC->SetOnConfigRead(OnConfigRead);
	IsEtalon = false;
    Init();
    SetEtalon(EtalonMeter);

     //   InitValues();


	if (TOrderClass::ActiveOrder != nullptr) {
		OrderHash = TOrderClass::ActiveOrder->Hash;
	} else {
		OrderHash = 800;
	}
}

TFlowMeter::TFlowMeter(THscDevice* HSCDev, bool isEtalon)
{
    HSCDevice = HSCDev;
    HSC = HSCDevice;
    // HSC->SetOnConfigRead(OnConfigRead);
    IsEtalon = isEtalon;
    Init();
    //    InitValues();
    if (TOrderClass::ActiveOrder != nullptr) {
        OrderHash = TOrderClass::ActiveOrder->Hash;
    } else {
        OrderHash= 800;
    }
}

TFlowMeter::TFlowMeter(THscDevice* HSCDev, bool isEtalon, int hash)
{
    Hash = hash;
    HSCDevice = HSCDev;
    HSC = HSCDevice;
    // HSC->SetOnConfigRead(OnConfigRead);
    IsEtalon = isEtalon;
    Init();
    //     InitValues();
    if (TOrderClass::ActiveOrder != nullptr) {
        OrderHash = TOrderClass::ActiveOrder->Hash;
    } else {
        OrderHash= 800;
    }
}

TFlowMeter::TFlowMeter(bool isEtalon)
{
    IsEtalon = isEtalon;
    HSCDevice = sHSC;
    HSC = HSCDevice;
    Init();
    //    InitValues();
    if (TOrderClass::ActiveOrder != nullptr) {
        OrderHash = TOrderClass::ActiveOrder->Hash;
    } else {
        OrderHash = 800;
    }
}

void TFlowMeter::InitValues()
{
/*     int  IsExisted= -1;

    ValueTime = TMeterValue::GetExistedMeterValueBool(HashValueTime, IsExisted, Hash, Name);
     if (IsExisted==0) ValueTime->SetAsTime();

    ValuePressure = TMeterValue::GetExistedMeterValueBool(HashValuePressure, IsExisted, Hash, Name);
    if (IsExisted==0) ValuePressure->SetAsPressure();

    ValueTemperture = TMeterValue::GetExistedMeterValueBool(HashValueTemperture, IsExisted, Hash, Name);
    if (IsExisted==0) ValueTemperture->SetAsTemp();

    ValueDensity = TMeterValue::GetExistedMeterValueBool(HashValueDensity, IsExisted, Hash, Name);
    if (IsExisted==0) ValueDensity->SetAsDensity();

    ValueDensity->ValueBaseMultiplier = ValueTemperture;
    ValueDensity->ValueBaseDevider = ValuePressure;
    ValueDensity->ValueRate = nullptr;
	ValueDensity->ValueEtalon = nullptr;

    ValueAirPressure = TMeterValue::GetExistedMeterValueBool(HashValueAirPressure, IsExisted, Hash, Name);
    if (IsExisted==0)  ValueAirPressure->SetAsAirPressure();

    ValueAirTemperture = TMeterValue::GetExistedMeterValueBool(HashValueAirTemperture, IsExisted, Hash, Name);
    if (IsExisted==0) ValueAirTemperture->SetAsTemp();

    ValueHumidity = TMeterValue::GetExistedMeterValueBool(HashValueHumidity, IsExisted, Hash, Name);
    if (IsExisted==0) ValueHumidity->SetAsHumidity();

    ValueImp = TMeterValue::GetExistedMeterValueBool(HashValueImp, IsExisted, Hash, Name);
    if (IsExisted==0) ValueImp->SetAsImp();

    ValueImpTotal = TMeterValue::GetExistedMeterValueBool(HashValueImpTotal, IsExisted, Hash, Name);
    if (IsExisted==0) ValueImpTotal->SetAsImp();

    ValueCoef = TMeterValue::GetExistedMeterValueBool(HashValueCoef, IsExisted, Hash, Name);

    ValueVolumeCoef = TMeterValue::GetExistedMeterValueBool(HashValueVolumeCoef, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeCoef->SetAsVolumeCoef();

    ValueMassCoef = TMeterValue::GetExistedMeterValueBool(HashValueMassCoef, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassCoef->SetAsMassCoef();

    // MassFlow
    ValueMassFlow = TMeterValue::GetExistedMeterValueBool(HashValueMassFlow, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassFlow->SetAsMassFlow();
    //	ValueMassFlow->MaxValue = FlowMax;
    //	ValueMassFlow->MinValue = FlowMin;

    ValueMassFlow->ValueCorrection = nullptr;
    ValueMassFlow->ValueBaseMultiplier = ValueImp;
    ValueMassFlow->ValueBaseDevider = ValueMassCoef;
    ValueMassFlow->ValueRate = nullptr;
	ValueMassFlow->ValueEtalon = nullptr;

    ValueVolumeFlow = TMeterValue::GetExistedMeterValueBool(HashValueVolumeFlow, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeFlow->SetAsVolumeFlow();
    //	ValueVolumeFlow->MaxValue = FlowMax;
    //	ValueVolumeFlow->MinValue = FlowMin;

    ValueVolumeFlow->ValueCorrection = nullptr;
    ValueVolumeFlow->ValueBaseMultiplier = ValueImp;
    ValueVolumeFlow->ValueBaseDevider = ValueVolumeCoef;
    ValueVolumeFlow->ValueRate = nullptr;
    ValueVolumeFlow->ValueEtalon = nullptr;
    //Volume

    ValueVolume = TMeterValue::GetExistedMeterValueBool(HashValueVolume, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolume->SetAsVolume();

    ValueVolume->ValueCorrection = ValueVolumeFlow;
	ValueVolume->ValueBaseMultiplier = ValueImpTotal;
    ValueVolume->ValueBaseDevider = ValueVolumeCoef;
	ValueVolume->ValueRate = nullptr;
    ValueVolume->ValueEtalon = nullptr;
    //

    ValueMass = TMeterValue::GetExistedMeterValueBool(HashValueMass, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMass->SetAsMass();

    ValueMass->ValueCorrection = ValueMassFlow;
    ValueMass->ValueBaseMultiplier = ValueImpTotal;
    ValueMass->ValueBaseDevider = ValueMassCoef;
    ValueMass->ValueRate = nullptr;
    ValueMass->ValueEtalon = nullptr;
    //

    ValueMassMeter = TMeterValue::GetExistedMeterValueBool(HashValueMassMeter, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassMeter->SetAsMass();

    ValueVolumeMeter = TMeterValue::GetExistedMeterValueBool(HashValueVolumeMeter, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeMeter->SetAsVolume();

    ValueVolumeError = TMeterValue::GetExistedMeterValueBool(HashValueVolumeError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeError->SetAsVolumeError();

    if (EtalonMeter != nullptr) {
        ValueVolumeError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueVolumeError->ValueBaseMultiplier = ValueVolume;

    ValueMassError = TMeterValue::GetExistedMeterValueBool(HashValueMassError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassError->SetAsMassError();

    if (EtalonMeter != nullptr) {
        ValueMassError->ValueEtalon = EtalonMeter->ValueMass;
    }

    ValueMassError->ValueBaseMultiplier = ValueMass;

    ValueError = TMeterValue::GetExistedMeterValueBool(HashValueError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueError->SetAsError();

    if (EtalonMeter != nullptr) {
        ValueError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueError->ValueBaseMultiplier = ValueVolumeMeter;

       SetMeterFlowType(MeterFlowType);

        if (!IsEtalon) {
        ValueFlow->Accuracy = 4;
        ValueImp->Accuracy = 0;
        //	ValueFlow->Error = 5;
    } else {
		ValueFlow->Accuracy = 4;
        		if (TSettingsClass::EtalonCHNum != 0) {
		SetChannel(TSettingsClass::EtalonCHNum);

        ValueVolume->UpdateType = ONLINE_TYPE;
        ValueMass->UpdateType   = ONLINE_TYPE;
	}
    }


   	SetInitalDim();
    */
}

void TFlowMeter::InitHashValues()
{

HashValueTime= TMeterValue::GetHashToSave(ValueTime);
HashValuePressure=  TMeterValue::GetHashToSave(ValuePressure);
HashValueTemperture=  TMeterValue::GetHashToSave(ValueTemperture);
HashValueDensity = TMeterValue::GetHashToSave(ValueDensity);
HashValueAirPressure = TMeterValue::GetHashToSave(ValueAirPressure);
HashValueAirTemperture = TMeterValue::GetHashToSave(ValueAirTemperture);
HashValueHumidity = TMeterValue::GetHashToSave(ValueHumidity);
HashValueImp = TMeterValue::GetHashToSave(ValueImp);
HashValueImpTotal = TMeterValue::GetHashToSave(ValueImpTotal);
HashValueCoef = TMeterValue::GetHashToSave(ValueCoef);
HashValueVolumeCoef = TMeterValue::GetHashToSave(ValueVolumeCoef);
HashValueMassCoef = TMeterValue::GetHashToSave(ValueMassCoef);
HashValueMassFlow = TMeterValue::GetHashToSave(ValueMassFlow);
HashValueVolumeFlow = TMeterValue::GetHashToSave(ValueVolumeFlow);
HashValueVolume = TMeterValue::GetHashToSave(ValueVolume);
HashValueMass = TMeterValue::GetHashToSave(ValueMass);
HashValueMassMeter = TMeterValue::GetHashToSave(ValueMassMeter);
HashValueVolumeMeter = TMeterValue::GetHashToSave(ValueVolumeMeter);
HashValueVolumeError = TMeterValue::GetHashToSave(ValueVolumeError);
HashValueMassError = TMeterValue::GetHashToSave(ValueMassError);
HashValueError = TMeterValue::GetHashToSave(ValueError);

}

void TFlowMeter::CopyValues(TFlowMeter* EtalonMeter)
{
     int  IsExisted= -1;

    ValueTime = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueTime, IsExisted);
     if (IsExisted==0) ValueTime->SetAsTime();

    ValuePressure = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValuePressure, IsExisted);
    if (IsExisted==0) ValuePressure->SetAsPressure();

    ValueTemperture = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueTemperture, IsExisted);
    if (IsExisted==0) ValueTemperture->SetAsTemp();

    ValueDensity = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueDensity, IsExisted);
    if (IsExisted==0) ValueDensity->SetAsDensity();

    ValueDensity->ValueBaseMultiplier = ValueTemperture;
    ValueDensity->ValueBaseDevider = ValuePressure;
    ValueDensity->ValueRate = nullptr;
	ValueDensity->ValueEtalon = nullptr;

    ValueAirPressure = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueAirPressure, IsExisted);
    if (IsExisted==0) ValueAirPressure->SetAsAirPressure();

    ValueAirTemperture = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueAirTemperture, IsExisted);
    if (IsExisted==0) ValueAirTemperture->SetAsTemp();

    ValueHumidity = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueHumidity, IsExisted);
    if (IsExisted==0) ValueHumidity->SetAsHumidity();

    ValueImp = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueImp, IsExisted);
    if (IsExisted==0) ValueImp->SetAsImp();

    ValueImpTotal = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueImpTotal, IsExisted);
    if (IsExisted==0) ValueImpTotal->SetAsImp();

    ValueCoef = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueCoef, IsExisted);

    ValueVolumeCoef = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueVolumeCoef, IsExisted);
    if (IsExisted==0) ValueVolumeCoef->SetAsVolumeCoef();
    if (IsExisted==0) ValueVolumeCoef->SetValue(Kp);

    ValueMassCoef = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueMassCoef, IsExisted);
    if (IsExisted==0) ValueMassCoef->SetAsMassCoef();
    if (IsExisted==0) ValueMassCoef->SetValue(Kp);

    // MassFlow
    ValueMassFlow = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueMassFlow, IsExisted);
    if (IsExisted==0) ValueMassFlow->SetAsMassFlow();
    //	ValueMassFlow->MaxValue = FlowMax;
    //	ValueMassFlow->MinValue = FlowMin;

    ValueMassFlow->ValueCorrection = nullptr;
    ValueMassFlow->ValueBaseMultiplier = ValueImp;
    ValueMassFlow->ValueBaseDevider = ValueMassCoef;
    ValueMassFlow->ValueRate = nullptr;
	ValueMassFlow->ValueEtalon = nullptr;

    ValueVolumeFlow = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueVolumeFlow, IsExisted);
    if (IsExisted==0) ValueVolumeFlow->SetAsVolumeFlow();
    //	ValueVolumeFlow->MaxValue = FlowMax;
    //	ValueVolumeFlow->MinValue = FlowMin;

    ValueVolumeFlow->ValueCorrection = nullptr;
    ValueVolumeFlow->ValueBaseMultiplier = ValueImp;
    ValueVolumeFlow->ValueBaseDevider = ValueVolumeCoef;
    ValueVolumeFlow->ValueRate = nullptr;
    ValueVolumeFlow->ValueEtalon = nullptr;
    //Volume

    ValueVolume = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueVolume, IsExisted);
    if (IsExisted==0) ValueVolume->SetAsVolume();

    ValueVolume->ValueCorrection = ValueVolumeFlow;
	ValueVolume->ValueBaseMultiplier = ValueImpTotal;
    ValueVolume->ValueBaseDevider = ValueVolumeCoef;
	ValueVolume->ValueRate = nullptr;
    ValueVolume->ValueEtalon = nullptr;
    //

    ValueMass = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueMass, IsExisted);
    if (IsExisted==0) ValueMass->SetAsMass();

    ValueMass->ValueCorrection = ValueMassFlow;
    ValueMass->ValueBaseMultiplier = ValueImpTotal;
    ValueMass->ValueBaseDevider = ValueMassCoef;
    ValueMass->ValueRate = nullptr;
    ValueMass->ValueEtalon = nullptr;
    //

    ValueMassMeter = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueMassMeter, IsExisted);
    if (IsExisted==0) ValueMassMeter->SetAsMass();

    ValueVolumeMeter = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueVolumeMeter, IsExisted);
    if (IsExisted==0) ValueVolumeMeter->SetAsVolume();

    ValueVolumeError = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueVolumeError, IsExisted);
    if (IsExisted==0) ValueVolumeError->SetAsVolumeError();

    if (EtalonMeter != nullptr) {
        ValueVolumeError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueVolumeError->ValueBaseMultiplier = ValueVolume;

    ValueMassError = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueMassError, IsExisted);
    if (IsExisted==0) ValueMassError->SetAsMassError();

    if (EtalonMeter != nullptr) {
        ValueMassError->ValueEtalon = EtalonMeter->ValueMass;
    }

    ValueMassError->ValueBaseMultiplier = ValueMass;

    ValueError = TMeterValue::GetCopyMeterValueBool(EtalonMeter->HashValueError, IsExisted);
    if (IsExisted==0) ValueError->SetAsError();

    if (EtalonMeter != nullptr) {
        ValueError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueError->ValueBaseMultiplier = ValueVolumeMeter;

       SetMeterFlowType(MeterFlowType);

        if (!IsEtalon) {

        ValueFlow->Accuracy = 4;
        ValueImp->Accuracy = 0;
        //	ValueFlow->Error = 5;
    } else {
		ValueFlow->Accuracy = 4;

        if (TSettingsClass::EtalonCHNum != 0) {
		SetChannel(TSettingsClass::EtalonCHNum);
	}
    }


   	SetInitalDim();
}

void TFlowMeter::RestoreValues()
{
     int  IsExisted= -1;

    ValueTime = TMeterValue::GetExistedMeterValueBool(HashValueTime, IsExisted, Hash, Name);
     if (IsExisted==0) ValueTime->SetAsTime();

    ValuePressure = TMeterValue::GetExistedMeterValueBool(HashValuePressure, IsExisted, Hash, Name);
    if (IsExisted==0) ValuePressure->SetAsPressure();

    ValueTemperture = TMeterValue::GetExistedMeterValueBool(HashValueTemperture, IsExisted, Hash, Name);
    if (IsExisted==0) ValueTemperture->SetAsTemp();

    ValueDensity = TMeterValue::GetExistedMeterValueBool(HashValueDensity, IsExisted, Hash, Name);
    if (IsExisted==0) ValueDensity->SetAsDensity();

    ValueDensity->ValueBaseMultiplier = ValueTemperture;
    ValueDensity->ValueBaseDevider = ValuePressure;
    ValueDensity->ValueRate = nullptr;
	ValueDensity->ValueEtalon = nullptr;

    ValueAirPressure = TMeterValue::GetExistedMeterValueBool(HashValueAirPressure, IsExisted, Hash, Name);
    if (IsExisted==0) ValueAirPressure->SetAsAirPressure();

    ValueAirTemperture = TMeterValue::GetExistedMeterValueBool(HashValueAirTemperture, IsExisted, Hash, Name);
    if (IsExisted==0) ValueAirTemperture->SetAsAirTemp();

    ValueHumidity = TMeterValue::GetExistedMeterValueBool(HashValueHumidity, IsExisted, Hash, Name);
    if (IsExisted==0) ValueHumidity->SetAsHumidity();

    ValueImp = TMeterValue::GetExistedMeterValueBool(HashValueImp, IsExisted, Hash, Name);
    if (IsExisted==0) ValueImp->SetAsImp();

    ValueImpTotal = TMeterValue::GetExistedMeterValueBool(HashValueImpTotal, IsExisted, Hash, Name);
    if (IsExisted==0) ValueImpTotal->SetAsImp();

    ValueCoef = TMeterValue::GetExistedMeterValueBool(HashValueCoef, IsExisted, Hash, Name);

    ValueVolumeCoef = TMeterValue::GetExistedMeterValueBool(HashValueVolumeCoef, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeCoef->SetAsVolumeCoef();
    if (IsExisted==0) ValueVolumeCoef->SetValue(Kp);

    ValueMassCoef = TMeterValue::GetExistedMeterValueBool(HashValueMassCoef, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassCoef->SetAsMassCoef();
    if (IsExisted==0) ValueMassCoef->SetValue(Kp);

    // MassFlow
    ValueMassFlow = TMeterValue::GetExistedMeterValueBool(HashValueMassFlow, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassFlow->SetAsMassFlow();
    //	ValueMassFlow->MaxValue = FlowMax;
    //	ValueMassFlow->MinValue = FlowMin;

    ValueMassFlow->ValueCorrection = nullptr;
    ValueMassFlow->ValueBaseMultiplier = ValueImp;
    ValueMassFlow->ValueBaseDevider = ValueMassCoef;
    ValueMassFlow->ValueRate = nullptr;
	ValueMassFlow->ValueEtalon = nullptr;

    ValueVolumeFlow = TMeterValue::GetExistedMeterValueBool(HashValueVolumeFlow, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeFlow->SetAsVolumeFlow();
    //	ValueVolumeFlow->MaxValue = FlowMax;
    //	ValueVolumeFlow->MinValue = FlowMin;

    ValueVolumeFlow->ValueCorrection = nullptr;
    ValueVolumeFlow->ValueBaseMultiplier = ValueImp;
    ValueVolumeFlow->ValueBaseDevider = ValueVolumeCoef;
    ValueVolumeFlow->ValueRate = nullptr;
    ValueVolumeFlow->ValueEtalon = nullptr;
    //Volume

    ValueVolume = TMeterValue::GetExistedMeterValueBool(HashValueVolume, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolume->SetAsVolume();

    ValueVolume->ValueCorrection = ValueVolumeFlow;
	ValueVolume->ValueBaseMultiplier = ValueImpTotal;
    ValueVolume->ValueBaseDevider = ValueVolumeCoef;
	ValueVolume->ValueRate = nullptr;
    ValueVolume->ValueEtalon = nullptr;

    if (true) {

    }
    //

    ValueMass = TMeterValue::GetExistedMeterValueBool(HashValueMass, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMass->SetAsMass();

    ValueMass->ValueCorrection = ValueMassFlow;
    ValueMass->ValueBaseMultiplier = ValueImpTotal;
    ValueMass->ValueBaseDevider = ValueMassCoef;
    ValueMass->ValueRate = nullptr;
    ValueMass->ValueEtalon = nullptr;
    //

    ValueMassMeter = TMeterValue::GetExistedMeterValueBool(HashValueMassMeter, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassMeter->SetAsMass();

    ValueVolumeMeter = TMeterValue::GetExistedMeterValueBool(HashValueVolumeMeter, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeMeter->SetAsVolume();

    ValueVolumeError = TMeterValue::GetExistedMeterValueBool(HashValueVolumeError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueVolumeError->SetAsVolumeError();

    if (EtalonMeter != nullptr) {
        ValueVolumeError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueVolumeError->ValueBaseMultiplier = ValueVolume;

    ValueMassError = TMeterValue::GetExistedMeterValueBool(HashValueMassError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueMassError->SetAsMassError();

    if (EtalonMeter != nullptr) {
        ValueMassError->ValueEtalon = EtalonMeter->ValueMass;
    }

    ValueMassError->ValueBaseMultiplier = ValueMass;

    ValueError = TMeterValue::GetExistedMeterValueBool(HashValueError, IsExisted, Hash, Name);
    if (IsExisted==0) ValueError->SetAsError();

    if (EtalonMeter != nullptr) {
        ValueError->ValueEtalon = EtalonMeter->ValueVolume;
    }

    ValueError->ValueBaseMultiplier = ValueVolumeMeter;

    SetMeterFlowType(MeterFlowType);

        if (!IsEtalon) {

        ValueFlow->Accuracy = 4;
        ValueImp->Accuracy = 0;
        //	ValueFlow->Error = 5;
    } else {
		ValueFlow->Accuracy = 4;

        if (TSettingsClass::EtalonCHNum != 0) {
		SetChannel(TSettingsClass::EtalonCHNum);

        ValueVolume->UpdateType = ONLINE_TYPE;
        ValueMass->UpdateType   = ONLINE_TYPE;
	}
    }


   	SetInitalDim();
}

void TFlowMeter::Init()
{
     Hash?0:Hash = GetNewHash();

     Name = IntToStr(GetHashCode());

     CheckType = 1;

	 int size =   Points.size();

    TDateTime Date;

    TDateTime dt;
    /*Point;
	 tDataPoint 			DataPoint;
	 tCalibrPoint           CalibrPoint;
	 tCoef                  Coef; */

    tPoint Pnt;


    Kp = 100;
    FlowMax = 3000;
    Points.clear();

    Pnt.Qrate = 0.1; //Часть от FlowMax
    Pnt.Mrate = 0.1; //Часть от FlowMax
    Pnt.Q = 0.06;

    Pnt.Name = "Q1";
    Pnt.Q = 60;
	Pnt.Num = 3; //Кол-во измерений
    Pnt.State = 0; //<Состоние
	Pnt.Time = 120; //Время измерения
    Pnt.Volume = 0;
    Pnt.Imp = 0;
    Pnt.Accuracy = 10; //Точность выхода на расход
	Pnt.Error = 0.1; //Погрешность допустимая измерениы
    Pnt.RagePlus = 10;
    Pnt.RageMinus = 10;
    Pnt.IsRageFree = 0;

	AddPoint(Pnt);

	size =   Points.size();

    Pnt.Qrate = 0.5; //Часть от FlowMax
    Pnt.Mrate = 0.5; //Часть от FlowMax
    Pnt.Q = 150;
    Pnt.Name = "Q2";
    Pnt.Num = 1; //Кол-во измерений
    Pnt.State = 0; //<Состоние
	Pnt.Time = 120; //Время измерения
    Pnt.Volume = 0;
    Pnt.Imp = 0;
    Pnt.Accuracy = 10; //Точность выхода на расход
	Pnt.Error = 0.1; //Погрешность допустимая измерениы
    Pnt.RagePlus = 10;
    Pnt.RageMinus = 10;
    Pnt.IsRageFree = 0;
	AddPoint(Pnt);

    Pnt.Qrate = 1; //Часть от FlowMax
    Pnt.Mrate = 1; //Часть от FlowMax
    Pnt.Q = 1500;
	Pnt.Name = "Q3";
    Pnt.Num = 1; //Кол-во измерений
    Pnt.State = 0; //<Состоние
    Pnt.Time = 120; //Время измерения
    Pnt.Volume = 0;
    Pnt.Imp = 0;
    Pnt.Accuracy = 10; //Точность выхода на расход
	Pnt.Error = 0.1; //Погрешность допустимая измерениы
    Pnt.RagePlus = 10;
    Pnt.RageMinus = 10;
    Pnt.IsRageFree = 1;
	AddPoint(Pnt);

	size =   Points.size();

    DataPoints.clear();
    CalibrPoints.clear();
    //	 Coefs.clear();
    // IsEtalon = false;
    SetChannel(CHANNEL);










        //	ValueFlow->Error = 1;


    miOwner = "Физ. лицо";
    //
    // Серийный номер поверяемого устройства
    SerialNum = "";
    //
    // Номер ГРСИ поверяемого устройства
    CertificateNum = "";

    DN = "15";
    docTitle = "1592-2015";

    means = "60661.15.3Р.00540801";

    year_production = "";

    K1 = "";
    P1 = "";
    K2 = "";
    P2 = "";

    tempWater = "18,75";
    temperature = "22,4 град. С";
    pressure = "99,2 кПа";
    hymidity = "51,30%";

    vrfDate = DateToISO8601(Today(), false); //DateToStr();//ToDayFGISFormat();

    vrfDate = vrfDate.SubString(0, 9) + vrfDate.SubString(23, 29);

    Date = IncYear(Today(), 6);

    validDate = DateToISO8601(
        Date, false); //IncYear(vrfDate, 6);// IncDateFGISFormat(6);

    validDate = validDate.SubString(0, 9) + validDate.SubString(23, 29);

    Result = "Годен";

    VerificationInterval = 6;

	ModifidedDateTime = DateToISO8601(Today(), false);

        AddToList();
}

void __fastcall TFlowMeter::OnConfigRead(TObject* Sender)
{
    //Kp =

    for (int i = 0; i < 20; i++) {
        //  AddCalibrData(HSCDevice->cEtlVolume[i], HSCDevi ce->cTime[i], HSCDevice->cImp[i], HSCDevice->cCoef[i]);
    }
}

void TFlowMeter::ReadPIN(void) {}

void TFlowMeter::SavePIN(uint8_t pin)
{
    HSCDevice->Save_PIN(pin);
}

void TFlowMeter::Write_Channel_State(uint16_t State)
{
    HSCDevice->Write_Channel_State(Channel, State);
}

void TFlowMeter::Write_Channel_Settings()
{
    HSCDevice->Write_Channel_Settings(Channel);
}

void TFlowMeter::WritePIN(uint8_t pin)
{
    HSCDevice->Write_PIN(pin);
}

__fastcall TFlowMeter::~TFlowMeter() {}

double TFlowMeter::Flow(void)
{
	double flw, K, P;

    flw = HSCDevice->GetAvrImpulses(GetChannel()) / Kp;

    // 	K = koef_K(flw);
    //  P = koef_K(flw);

    //  Q = flw*K + P;

    return flw;
}

UnicodeString TFlowMeter::GetSendStatus()
{
    UnicodeString text = "-";

    if (SendStatus == 0) {
        text = "-";

    } else if (SendStatus == 1) {
        text = "Отправляется";
    } else {
        text = "Отправлен";
    }

    return text;
}

void TFlowMeter::SetSendStatus(UnicodeString text)
{
    if (text == "-") {
        SendStatus = 0;
    } else if (text == "Отправляется") {
        SendStatus = 1;
    }

    else if (text == "Отправлен")
    {
        SendStatus = 2;
    }

    else
    {
        SendStatus = 0;
    }
}

UnicodeString TFlowMeter::GetStatus()
{
    UnicodeString text = "-";

    if (IsEtalon) {

    if (Status == 0) {
        text = "В работе";
     }
     else if (Status == 1) {
        text = "Не годен";
    } else if (Status == 2) {
        text = "Отсутствует";
    }



    } else
    {

     if (Status == 1) {
        text = "Не Годен";
    } else if (Status == 2) {
        text = "Годен";
    }

    }

    return text;
}

void TFlowMeter::SetStatus(UnicodeString status)
{
    UnicodeString text = "-";
	if (status == "-")
	{
		Status = 0;
	} else if (status == "Не Годен")
	{
        Status = 1;
	}
	else if (status == "Годен")
    {
        Status = 2;
	}
    else
	{
	   Status = 0;
    }
}

uint8_t TFlowMeter::GetChannel(void)
{
    return Channel;
}

void TFlowMeter::SetChannel(uint8_t CH)
{
    //if (CH < HSCDevice->GetMaxChannel())
    {
        Channel = CH;
    }
}

void TFlowMeter::IncImpSumMonitor(void)
{
    ImpSum = ImpSum + (HSCDevice->GetSecImp(Channel));
}

void TFlowMeter::ResetTest(void)
{
    VolSum = 0;
    ImpSum = 0;

      ValueFlow -> Reset();
    ValueFlow->ARRAY_SIZE = 100;
    ValueFlow->SetFilter(8);

    ValueTime->Reset();

    ValueImp->Reset();
    ValueImpTotal->Reset();

    ValueTime->Reset();

    ValueVolume->Reset();
    ValueMass->Reset();
}

void TFlowMeter::SetMonitorValues(void)
{
    TMeterValue::FinalValue = false;

   // ValueImpTotal->SetValue((float)GetTotalImp());
   ValueImpTotal->SetValue(ImpSum);
    ValueImp->SetValue(HSCDevice->GetSecImp(Channel));

    ValueTime->SetAddValue(1);

    ValueFlow->SetValue();
    ValueVolume->SetValue();

    ValueVolumeCoef->SetValue();
    ValueMassCoef->SetValue();

    ValueVolumeFlow->SetValue();
    ValueMassFlow->SetValue();

    ValueVolume->SetValue();
    ValueMass->SetValue();

    ValueVolumeError->SetValue((float)GetVolumeError());
}

void TFlowMeter::SetValues(void)
{
    TMeterValue::FinalValue = false;

    ValueTime->SetValue(HSCDevice->GetTime());

    ValueImp->SetValue(HSCDevice->GetSecImp(Channel));
    ValueImpTotal->SetValue((float)GetTotalImp());

    ValueVolumeCoef->SetValue();
    ValueMassCoef->SetValue();

    ValueVolume->SetValue();
    ValueMass->SetValue();

    ValueVolumeFlow->SetValue();
    ValueMassFlow->SetValue();

    if (ValueMass->UpdateType != HAND_TYPE) {
       ValueMassError->SetValue(GetMassError());
    }

    if (ValueVolume->UpdateType != HAND_TYPE) {
       ValueVolumeError->SetValue(GetVolumeError());
    }




	if (MeterFlowType == EMETERFLOWTYPE::WEIGHTS_TYPE) {
        // ValueFlow -> SetValue((float)GetFlow());
        //	 ValueVolume -> SetValue((float)GetVolume());
        //	 ValueImp -> SetValue((float)GetTotalImp());
        //	 ValueVolumeError -> SetValue((float)GetVolumeError());

	} else if (MeterFlowType == EMETERFLOWTYPE::WEIGHTS_TYPE) {
    }
}

void TFlowMeter::SetFinalValues(void)
{
    TMeterValue::FinalValue = true;

    ValueTime->SetValue(HSCDevice->GetFinalTime());

    ValueImp->SetValue(GetFinalMeanImp());
    ValueImpTotal->SetValue(GetFinalImp());

    if (true) {

    }

    ValueVolume->SetValue();
    ValueMass->SetValue();

    ValueVolumeCoef->SetValue();
    ValueMassCoef->SetValue();

    ValueVolumeFlow->SetValue();
    ValueMassFlow->SetValue();

    ValueVolume->SetValue();
    ValueMass->SetValue();

    ValueVolumeError->SetValue(GetVolumeError());
    ValueMassError->SetValue(GetMassError());
}

float TFlowMeter::GetFlowVolume(void)
{
    float Vol, flow, CalibrVol;
    float calibr_flow, rate;

    Vol = ImpSum / Kp;

    flow = GetRawFlow();
    //rate = Rate(flow);

    CalibrVol = /*Rate(flow)* */ Vol;

    return CalibrVol;
}

float TFlowMeter::GetWidthFlowVolume(void)
{
    float Vol, flow, CalibrVol;
    float calibr_flow, rate;

    CalibrVol = 0; //GetWidthFlow() * time;

    return CalibrVol;
}

float TFlowMeter::GetTotalImp(void)
{
    return HSCDevice->GetTotalImp(Channel);
}

float TFlowMeter::GetVolume(void)
{
    float Vol, flow, CalibrVol;

    Vol = HSCDevice->GetTotalImp(Channel) / Kp;
    flow = GetRawFlow();
    //	CalibrVol = Rate(flow) * Vol;

    return CalibrVol;
}

float TFlowMeter::GetFinalRawVolume(void)
{
    float Vol;

    Vol = HSCDevice->GetFinalImp(Channel) / Kp;

    return Vol;
}

float TFlowMeter::GetFinalVolume(void)
{
    float Vol, flow, CalibrVol;

    Vol = HSCDevice->GetFinalImp(Channel) / Kp;

    flow = GetFinalRawFlow();
    //   CalibrVol = Rate(flow) * Vol;

    return CalibrVol;
}

float TFlowMeter::GetFinalMass(void)
{
    float Vol, flow, CalibrVol;

    Vol = HSCDevice->GetFinalImp(Channel) / Kp;

    flow = GetFinalRawFlow();
    //  CalibrVol = Rate(flow) * Vol;

    return CalibrVol;
}

double TFlowMeter::GetRawFlow(void)
{
    float flow, calibr_flow, rate;

    flow = (HSCDevice->GetSecImp(Channel) * 3600) / Kp;

    return flow;
}

int TFlowMeter::GetRawSecImp(void)
{
    return HSCDevice->GetSecImp(Channel);
}

float TFlowMeter::GetRawWidthFlow(void)
{
    float flow, calibr_flow, rate;

    flow = 3.6 / (Kp * HSCDevice->GetWidth(Channel));

    return flow;
}

float TFlowMeter::GetWidthFlow(void)
{
    float flow, calibr_flow, rate;

    flow = GetRawWidthFlow();
    //  rate = Rate(flow);

    calibr_flow = flow * rate;

    return calibr_flow;
}

float TFlowMeter::GetFlow(void)
{
    float flow, calibr_flow, rate;

    flow = GetRawFlow();
    //   rate = Rate(flow);

    calibr_flow = flow * rate;

    return calibr_flow;
}

float TFlowMeter::GetFinalRawFlow(void)
{
    float flow;

    flow = ((HSCDevice->GetFinalImp(Channel) * 3600) / Kp) /
           HSCDevice->GetFinalTime();

    return flow;
}

float TFlowMeter::GetFinalImp(void)
{
    double dbl;

    dbl = HSCDevice->GetFinalImp(Channel);

    return (float)dbl;
}

float TFlowMeter::GetFinalMeanImp(void)
{
    double dbl, time, imp;

    time = HSCDevice->GetFinalTime();
    imp = HSCDevice->GetFinalImp(Channel);
    dbl = imp / time;

    return dbl;
}

float TFlowMeter::GetFinalFlow(void)
{
    float flow, calibr_flow, rate;

    flow = ((HSCDevice->GetFinalImp(Channel) * 3600) / Kp) /
           HSCDevice->GetFinalTime();
    //	rate = Rate(flow);
    calibr_flow = flow * rate;

    return calibr_flow;
}

bool TFlowMeter::SaveDataPoint()
{
     UnicodeString Qt;

    if (EtalonMeter == nullptr) {
        return false;
    }
    try {
        DataPoint.Date = FormatDateTime("dd.mm.yyyy hh:nn", Now());
        DataPoint.DateTime = Today();


        Qt = ValueVolumeFlow->GetStrNum(Point.Q, "м3/ч");
        DataPoint.Qt = RemoveTrailingZeros(Qt);


        DataPoint.Name = Point.Name;
        DataPoint.EtlName = EtalonMeter->Name;

        DataPoint.Q = EtalonMeter->ValueFlow->GetStringValue();

         DataPoint.EtlCoef = EtalonMeter->ValueCoef->GetStringValue();

        DataPoint.EtlTime = EtalonMeter->ValueTime->GetStringValue();

        DataPoint.EtlVolume = EtalonMeter->ValueVolume->GetStringValue();
        DataPoint.EtlMass = EtalonMeter->ValueMass->GetStringValue();
        DataPoint.EtlImp = EtalonMeter->ValueImpTotal->GetStringValue();

        DataPoint.EtlTemp = EtalonMeter->ValueTemperture->GetStringValue();
        DataPoint.EtlPres =
            EtalonMeter->ValuePressure->GetStringValue(); //Давление
        DataPoint.EtlTempAir =
            EtalonMeter->ValueAirTemperture->GetStringValue();
        DataPoint.EtlPresAir =
            EtalonMeter->ValueAirPressure->GetStringValue(); //Давление
        DataPoint.EtlHumidity = EtalonMeter->ValueHumidity->GetStringValue();

        DataPoint.EtlDensity =  EtalonMeter->ValueDensity->GetStringValue();


        DataPoint.Time = ValueTime->GetStringValue();

        DataPoint.Volume = ValueVolume->GetStringValue();
        DataPoint.Imp = ValueImpTotal->GetStringValue();
        DataPoint.Mass = ValueMass->GetStringValue();

        DataPoint.VolumeMeter = ValueVolumeMeter->GetStringValue();
        DataPoint.MassMeter = ValueMassMeter->GetStringValue();

        DataPoint.Temp = ValueTemperture->GetStringValue();
        DataPoint.Pres = ValuePressure->GetStringValue(); //Давление
        DataPoint.TempAir = ValueAirTemperture->GetStringValue();
        DataPoint.PresAir = ValueAirPressure->GetStringValue(); //Давление
        DataPoint.Humidity = ValueHumidity->GetStringValue();
        DataPoint.Density = ValueDensity->GetStringValue();

       if ((MeterFlowType==WEIGHTS_TYPE)||(MeterFlowType==WEIGHTS_VOLUME_FLOWMETER_TYPE)||
       (MeterFlowType==WEIGHTS_MASS_FLOWMETER_TYPE)) {

          DataPoint.Error = ValueMassError->GetStringValue();

       } else if (MeterFlowType==MASS_FLOWMETER_TYPE)
       {

          DataPoint.Error = ValueMassError->GetStringValue();

       } else if (MeterFlowType==VOLUME_FLOWMETER_TYPE)
       {

         DataPoint.Error = ValueVolumeError->GetStringValue();

       } else
       {

         DataPoint.Error = ValueMassError->GetStringValue();

       }


       if (MeterFlowType==WEIGHTS_VOLUME_FLOWMETER_TYPE)
       {
          DataPoint.ErrorMeter =    ValueError->GetStringValue();
       } else if (MeterFlowType==WEIGHTS_MASS_FLOWMETER_TYPE)
       {
          DataPoint.ErrorMeter =   ValueError->GetStringValue();
       }else
       {
          DataPoint.ErrorMeter =   ValueError->GetStringValue();
       }




        DataPoint.Comment = Comment;

        if (CheckType == EMESUREMETHOD::IMPULSE) {
        } else if (CheckType == EMESUREMETHOD::PHOTOCAPTURE) {
        } else if (CheckType == EMESUREMETHOD::OPTO) {
        } else if (CheckType == EMESUREMETHOD::HAND) {
        } else if (CheckType == EMESUREMETHOD::PHOTOFIX) {
        }

        DataPoints.push_back(DataPoint);
        CheckFullStatus();
        SaveToFile(this, 0);
        return true;

    } catch (...) {
        return false;
    }
}

bool TFlowMeter::GetPointUseFlow(float Q, tPoint &point)
{
    float Qp;
    tPoint pnt;

    for (int i = 0; i < Points.size(); i++) {
        // Вычисляем расход для данной калибровочной точки
        if (Points[i].Time > 0) {
            Qp = Points[i].Q;
            pnt = Points[i];

            if (IsFlowInPoint(Q, pnt)) {
                point = pnt;
                return true;
            }
        }
    }

    return false;
}

bool TFlowMeter::IsDataPointGood(tDataPoint &dataPoint, tPoint point)
{
    double e1, e2;
    double Q = 0;
    double Error;
    double time;
    double volume;


    TryStrToDouble_(dataPoint.Q, Q);
    TryStrToDouble_(dataPoint.Error, Error);
    TryStrToDouble_(dataPoint.Volume, volume);
    TryStrToDouble_(dataPoint.Time, time);

    double Qp = point.Q;



    // проверка расхода
    if (IsFlowInPoint(Q, point)) {
        dataPoint.Name = point.Name;
        e1 = abs(point.Error);
        e2 = abs(Error);
        // проверка обьема
         if ((time >= point.Time-1) ||
         (volume >= point.Volume) )
         {
            // dataPoint.IsUsed = 1;
            // проверка погрешности
            if (e1 > e2)
            {
                dataPoint.State = 4;
                //return 4;
                return true;
            } else {
                dataPoint.State = 3;
                // return 3;
                return false;
            }

        } else {
            dataPoint.State = 2;
            return false;
        }
    } else {
        dataPoint.Name = "-";
    }

    return false;
}

int TFlowMeter::CheckStatus()
{
    tPoint temp, temp1;
    double Q, Q1, Q2, Qd = 0, e1, e2;
    double Error;
    int status = 0;
    int statusPoint = 0;
    int statusPoints = 1;
    int previousStatus = Status;

    tPoint point;

    UnicodeString text = "";
    ;

    std::vector<tPoint>::iterator it;

    it = Points.begin();

    if (!Points.empty()) {
        for (int i = 0; i < Points.size(); i++) {
            // Вычисляем расход для данной калибровочной точки
            if (Points[i].Time > 0) {
                Q = Points[i].Q;
                point = Points[i];
            } else {
                Status = 0;
                Result = "-";
                return 0;
            }

            statusPoint = 0;

            for (int j = 0; j < DataPoints.size(); j++) {
                TryStrToDouble_(DataPoints[j].Q, Qd);

                Q1 = Q * 1.1;
                Q2 = Q * 0.90;

                if ((Q2 < Qd) && (Qd < Q1)) {
                    DataPoints[j].Name = Points[i].Name;
                    e1 = Points[i].Error;

                    TryStrToDouble_(DataPoints[j].Error, e2);

                    if (Points[i].Error > DataPoints[j].Error) {
                        statusPoint = 1;
                        DataPoints[j].IsUsed = 1;
                        j = DataPoints.size();
                    } else {
                        Status = 1;
                        Result = "Не годен";
                        return 1; //не годен
                    }
                }
            }

            if (statusPoint == 1) {
                statusPoints = statusPoints;
            } else {
                statusPoints = 0;
            }
        }

        if (statusPoints == 1) {
            Status = 2;
            Result = "Годен";
            Status = 2;
            return 2; //годен

        } else {
            Status = 0;
            Result = "-";
            return 0; // не достаточно данных
        }
    }
    Result = "-";

    Status = 0;
    return 0;
}

int TFlowMeter::CheckFullStatus()
{
    float Q, Q1, Q2, Qd, e1, e2;

    int status = 0;
    int statusPoint = 0;
    int statusPoints = 5;
    int previousStatus = Status;

    UnicodeString text = "";

    UsedDataPoints.clear();

    std::vector<tPoint>::iterator it;

    for (int j = 0; j < DataPoints.size(); j++) {
        DataPoints[j].State = 0;
    }

    if ((!Points.empty()) && (!DataPoints.empty())) {
        for (int i = 0; i < Points.size(); i++) {
            UsedDataPoints.push_back(DataPoints[0]);
            // Вычисляем расход для данной калибровочной точки
            if (Points[i].Time > 0) {
                Q = Points[i].Q;
                Points[i].State = 0; //Обнуляем состояние
            } else {
                Status = 0;
                Result = "-";
                return 0;
            }

            statusPoint = 0;

            for (int j = 0; j < DataPoints.size(); j++) {
                if (DataPoints[j].State < 2) {
                    if (IsDataPointGood(DataPoints[j], Points[i]))
                    {
                        if ((Points[i].State == 0) || (Points[i].State == 3))
                        {
                            Points[i].State = 5;
                            DataPoints[j].State = 5;
                            DataPoints[j].Point = &Points[i];
                            UsedDataPoints[i] = DataPoints[j];
                        }
                        // j = DataPoints.size();
                    } else {
                        if (DataPoints[j].State == 3) {
                            Status = 1;
                            if (Points[i].State != 5) {
                                Points[i].State = 3;
                                DataPoints[j].Point = &Points[i];
                                UsedDataPoints[i] = DataPoints[j];
                            }

                            // Result = "Не годен";
                            // return 1; //не годен
                        }
                    }
                }
            }

            if (Points[i].State != 5) {
                if (Points[i].State == 3) {
                    statusPoints = 3;
                } else {
                    statusPoints = 0;
                }
            } else {
            }
        }

        if (statusPoints == 5) {
            Status = 2;
            Result = "Годен";
            return 2; //годен

        } else {
            if (statusPoints == 3) {
                Result = "Не годен";
                return 1; //не годен
            }

            Status = 0;
            Result = "Нет всех измерений";
            return 0; // не достаточно данных
        }
    }
    Result = "Нет всех измерений";

    Status = 0;
    return 0;
}

vector<tDataPoint> TFlowMeter::SortDataVector(
    vector<tDataPoint> vect, int State, int State2, int maxmin = 0)
{
    float Q = MAXFLOAT;
    double FlowMax = 0;

    int index = 0;
    vector<tDataPoint> dataPoints;
    vector<tDataPoint> dataPoints1;

    dataPoints.clear();

    while (index != -1) {
        index = -1;

        for (int i = 0; i < vect.size(); i++) {
            if ((vect[i].State == State2) || (vect[i].State == State) ||
                (State == -1))
                if ((FlowMax <= vect[i].Q) && (vect[i].Q < Q)) {
                    index = i;
                    TryStrToDouble_(vect[i].Q, FlowMax);
                    //FlowMax = vect[i].Q;
                }
        }

        if (index != -1) {
            for (int i = 0; i < vect.size(); i++) {
                if ((vect[i].State == State) || (State == -1))
                    if (FlowMax == vect[i].Q) {
                        dataPoints.push_back(vect[i]);
                    }
            }
            Q = FlowMax;
            FlowMax = 0;
        }
    }

    dataPoints1.clear();

    if (maxmin == 1) {
        for (int i = 0; i < dataPoints.size(); i++) {
            //if (DataPoints[i].State==5)

            dataPoints1.push_back(dataPoints[i]);
        }
    } else {
        for (int i = dataPoints.size() - 1; i >= 0; i--) {
            //if (DataPoints[i].State==5)

            dataPoints1.push_back(dataPoints[i]);
        }
    }

    return dataPoints1;
}

void TFlowMeter::SortDataPoints(int maxmin)
{
    float Q = FLT_MAX;
    double FlowMax = 0;

    int index = 0;

    vector<tDataPoint> dataPoints;

    dataPoints.clear();

    while (index != -1) {
        index = -1;

        for (int i = 0; i < DataPoints.size(); i++) {
            //if (DataPoints[i].State==5)
            if ((FlowMax <= DataPoints[i].Q) && (DataPoints[i].Q < Q)) {
                index = i;
                TryStrToDouble_(DataPoints[i].Q, FlowMax);
                //FlowMax = DataPoints[i].Q;
            }
        }

        if (index != -1) {
            for (int i = 0; i < DataPoints.size(); i++) {
                //if (DataPoints[i].State==5)
                if (FlowMax == DataPoints[i].Q) {
                    dataPoints.push_back(DataPoints[i]);
                }
            }
            Q = FlowMax;
            FlowMax = 0;
        }
    }

    DataPoints.clear();
    if (maxmin == 1) {
        for (int i = 0; i < dataPoints.size(); i++) {
            //if (DataPoints[i].State==5)

            DataPoints.push_back(dataPoints[i]);
        }
    } else {
        for (int i = dataPoints.size() - 1; i >= 0; i--) {
            //if (DataPoints[i].State==5)

            DataPoints.push_back(dataPoints[i]);
        }
    }
}

uint8_t TFlowMeter::AddPointData(UnicodeString Name, float Qrate, float Q,
    float Volume, float vTime, float Error, float RagePlus, float RageMinus)
{
    tPoint Pnt;
    uint8_t error;

    Pnt.Name = Name;
    /*
	if (vTime == 0) { return 2; }
	if (vTime < 1) { return 3; }
	if (vTime > 100000) { return 4; }

     #ifndef __ANDROID__
    if (!_finite(vTime)) { return 5; }

        #endif
    */
    if ((!IsNan(Qrate)) && (!IsInfinite(Qrate))) {
        if ((Qrate > 0) && (FlowMax > 0)) {
            Pnt.Q = FlowMax * Qrate;
            Pnt.Qrate = Qrate;
        } else if (Q > 0) {
            Pnt.Q = Q;
            if (FlowMax > 0) {
                Pnt.Qrate = Pnt.Q / FlowMax;
            }

        } else {
            return 6;
        }

    } else {
        return 7;
    }

    if ((!IsNan(Volume)) && (!IsInfinite(vTime))) {
        if (Volume > 0) {
            Pnt.Volume = Volume;
        } else {
            Pnt.Volume = 0;
        }

        if (vTime > 1) {
            Pnt.Time = vTime;
        } else {
            Pnt.Time = 3600;
        }

    } else {
        return 8;
    }

    if (!IsNan(Error)) {
        Pnt.Error = Error;
    }

    if (!IsNan(RageMinus)) {
        Pnt.RageMinus = RageMinus;
    }

    if (!IsNan(RagePlus)) {
        Pnt.RagePlus = RagePlus;
    }

    /*Pnt.Volume = 	Pnt.Imp / Pnt.Coef;
    Pnt.Q = 		(Pnt.EtlVolume/Pnt.Time)*3600;
    Pnt.Qtest  =  	(Pnt.Volume/Pnt.Time)*3600;

    Pnt.Error =   	((Pnt.Volume - Pnt.EtlVolume)*100)/Pnt.EtlVolume;
    Pnt.Rate  =   	Pnt.Volume/Pnt.EtlVolume; */

    AddCurrPoint(Pnt);

    return 1;
}

void TFlowMeter::AddCurrPoint(tPoint Pnt)
{
    Point = Pnt;
    Points.push_back(Point);
}

void TFlowMeter::SetType(TFlowMeterType* type)
{
    int i, i1, i2;

    Type = type;
    if (Type != nullptr) {
        TypeHash = Type->Hash;
        DeviceType = Type->DeviceName;
        //	SerialNum= Type->SerialNum;
        CertificateNum = Type->CertificateNum;
        Modifications = Type->Modification;
        Modification = Type->Modification;
        docTitle = Type->VerificationNum;
        DN = Type->DN;
        Date1 = Type->Date1;
        Date2 = Type->Date2;
        if (TryStrToInt_(Type->VerificationInterval1, i1)) {
            if (TryStrToInt_(Type->VerificationInterval2, i2)) {
                if (i1 == i2) {
                    VerificationInterval = i1;
                } else {
                    VerificationInterval = 0;
                }
            } else {
                VerificationInterval = i1;
            }
        } else {
            VerificationInterval = 0;
        }
        Kp = Type->Kp;
        FlowMax = Type->Qmax;

        Points.clear();

        for (int i = 0; i < Type->Points.size(); i++) {
            Points.push_back(Type->Points[i]);
        }
    } else {
    }
}


void TFlowMeter::SetCopy(TFlowMeter* Meter)
{
	int i, i1, i2;

	Type = Meter->Type;

		Name = Meter->Name;
		SerialNum = Meter->SerialNum;

//      Meter->InitHashValues();
//
//      HashValueImp=Meter->HashValueImp;
//
//      ValueImp =  TMeterValue::GetNewMeterValue(HashValueImp);
//
//
//      //    ValueTime = TMeterValue::GetExistedMeterValueBool(HashValueTime, IsExisted);
//
//      HashValueImpTotal=Meter->HashValueImpTotal;
//
//      ValueImpTotal= TMeterValue::GetNewMeterValue(HashValueImpTotal);
//
//      HashValueCoef=Meter->HashValueCoef;
//
//      ValueCoef=  TMeterValue::TMeterValue::GetNewMeterValue(HashValueCoef);
//
//      HashValueMassCoef=Meter->HashValueMassCoef;
//
//      ValueMassCoef= TMeterValue::TMeterValue::GetNewMeterValue(HashValueMassCoef);
//
//      HashValueVolumeCoef=Meter->HashValueVolumeCoef;
//
//      ValueVolumeCoef=  TMeterValue::GetNewMeterValue(HashValueVolumeCoef);
//
//      HashValueVolume=Meter->HashValueVolume;
//
//      ValueVolume=   TMeterValue::GetNewMeterValue(HashValueVolume);
//
//      HashValueMass=Meter-> HashValueMass;
//
//      ValueMass= TMeterValue::GetNewMeterValue(HashValueMass);
//
//      HashValueVolumeMeter=Meter->HashValueVolumeMeter;
//
//      ValueVolumeMeter=  TMeterValue::GetNewMeterValue(HashValueVolumeMeter);
//
//      HashValueMassMeter=Meter->HashValueMassMeter;
//
//      ValueMassMeter=  TMeterValue::GetNewMeterValue(HashValueMassMeter);
//
//      HashValueMassFlow=Meter->HashValueMassFlow;
//
//       ValueMassFlow=  TMeterValue::GetNewMeterValue(HashValueMassFlow);
//
//
//      HashValueVolumeFlow=Meter->HashValueVolumeFlow;
//
//      ValueVolumeFlow= TMeterValue::GetNewMeterValue(HashValueVolumeFlow);
//
//      HashValueQuantity=Meter->HashValueQuantity;
//
//      ValueQuantity=  TMeterValue::GetNewMeterValue(HashValueQuantity);
//
//      HashValueFlow=Meter->HashValueFlow;
//
//      ValueFlow= TMeterValue::GetNewMeterValue(HashValueFlow);
//
//      HashValueError=Meter->HashValueError;
//
//      ValueError= TMeterValue::GetNewMeterValue(HashValueError);
//
//      HashValueVolumeError=Meter->HashValueVolumeError;
//
//      ValueVolumeError=  TMeterValue::GetNewMeterValue(HashValueVolumeError);
//
//
//      HashValueMassError=Meter->HashValueMassError;
//
//      ValueMassError= TMeterValue::GetNewMeterValue(HashValueMassError);
//
//      HashValueDensity=Meter->HashValueDensity;
//
//      ValueDensity=  TMeterValue::GetNewMeterValue(HashValueDensity);
//
//      HashValuePressure=Meter->HashValuePressure;
//
//      ValuePressure=  TMeterValue::GetNewMeterValue(HashValuePressure);
//
//      HashValueTemperture=Meter-> HashValueTemperture;
//
//       ValueTemperture=  TMeterValue::GetNewMeterValue(HashValueTemperture);
//
//
//
//      HashValueAirPressure=Meter->HashValueAirPressure;
//
//       ValueAirPressure= TMeterValue::GetNewMeterValue(HashValueAirPressure);
//
//      HashValueAirTemperture=Meter->HashValueAirTemperture;
//
//      ValueAirTemperture =    TMeterValue::GetNewMeterValue(HashValueAirTemperture);
//
//      HashValueHumidity=Meter->HashValueHumidity;
//
//      ValueHumidity =  TMeterValue::GetNewMeterValue(HashValueHumidity);
//
//      HashValueCurrent=Meter->HashValueCurrent;
//
//      ValueCurrent=   TMeterValue::GetNewMeterValue(HashValueCurrent);
//
//      HashValueTime =Meter->HashValueTime;
//
//      ValueTime =   TMeterValue::GetNewMeterValue(HashValueTime);
//



        FactoryKp = Meter->FactoryKp;
		SetMeterFlowType(Meter->MeterFlowType);

	   //	TypeHash = Meter->Type->Hash;
	   //	DeviceType = Meter->Type->DeviceName;
		//	SerialNum= Type->SerialNum;
		CertificateNum = Meter->CertificateNum;
		Modifications = Meter->Modification;
		Modification = Meter->Modification;
		docTitle = Meter->docTitle ;
		DN = Meter->DN;
		Date1 = Meter->Date1;
		Date2 = Meter->Date2;

		VerificationInterval = Meter-> VerificationInterval;

		Kp = Meter->Kp;
		FlowMax = Meter->FlowMax;
        QuantityMax =   Meter-> QuantityMax;
        Points.clear();

		for (int i = 0; i < Meter->Points.size(); i++) {
			Points.push_back(Meter->Points[i]);
        }

}

bool TFlowMeter::InitType(TFlowMeter* FlowMeter)
{
    if (FlowMeter->TypeHash != 0) {
        FlowMeter->Type = (TFlowMeterType::Get(FlowMeter->TypeHash));

        if (FlowMeter->Type != nullptr) {
            FlowMeter->SetType(FlowMeter->Type);
            return true;
        }
    } else {
        for (int j = 0; j < TFlowMeterType::MeterTypes.size(); j++) {
            if (FlowMeter->DeviceType ==
                TFlowMeterType::MeterTypes[j]->DeviceType) {
                FlowMeter->Type = (TFlowMeterType::MeterTypes[j]);

                if (FlowMeter->Type != nullptr) {
                    FlowMeter->SetType(FlowMeter->Type);
                    return true;
                }
            }
        }
    }
    return false;
}

bool TFlowMeter::SetType(int typeHash)
{
	SetType(TFlowMeterType::Get(typeHash));

    return true;
}

int TFlowMeter::GetNewPointHash()
{
     int  maxHash = 0;

    for (int j = 0; j < Points.size(); j++) {

        if (Points[j].Hash>maxHash)
        {
           maxHash = Points[j].Hash;
        }
    }

     return maxHash + 1;
}

void TFlowMeter::AddPoint(tPoint Pnt)
{
	tPoint temp, temp1;
    float Q1, Q2;
    int hash = GetNewPointHash();

	std::vector<tPoint>::iterator it;

    it = Points.begin();

    Pnt.Hash =  hash;

    if (!Points.empty()) {
        temp = Pnt;

        for (int i = 0; i < Points.size(); i++) {
			// Вычисляем расход для данной калибровочной точки
            temp1 = Points[i];
			if (Points[i].Time > 0)
			{
				Q1 = Points[i].Q;
			}
			else
			{
				return;
            }

			if (Pnt.Time > 0)
			{
				Q2 = Pnt.Q;
			} else
			{
				return;
            }

            if (Q2 >= Q1) {
				Points.insert(it + i, Pnt);
                return;
            }
        }

        Points.push_back(Pnt);
        return;

    } else {
        Points.push_back(Pnt);
        return;
	}
}

void TFlowMeter::AddEmptyPoint(tPoint Pnt)
{
	tPoint temp, temp1;
    float Q1, Q2;

	std::vector<tPoint>::iterator it;

    it = Points.begin();

   int hash = GetNewPointHash();

    Pnt.Hash = hash;

    if (!Points.empty()) {
        temp = Pnt;

        for (int i = 0; i < Points.size(); i++) {
			// Вычисляем расход для данной калибровочной точки
            temp1 = Points[i];
		 //	if (Points[i].Time > 0)
			{
				Q1 = Points[i].Q;
			}
		///	else
			{
		//		return;
            }

		//	if (Pnt.Time > 0)
			{
				Q2 = Pnt.Q;
			}

			//else
			{
		 //		return;
			}

            if (Q2 >= Q1) {
				Points.insert(it + i, Pnt);
                return;
            }
        }

        Points.push_back(Pnt);
        return;

    } else {
        Points.push_back(Pnt);
        return;
	}
}

void TFlowMeter::AddDataPoint(tPoint Pnt)
{
    Point = Pnt;
    Points.push_back(Point);
}

void TFlowMeter::AddDataCalibrPoint(void)
{
    AddCalibrPoint(CalibrPoint);
}

void TFlowMeter::LoadCalibrData(void)
{
    HSC->Read_ConfigData();
}

void TFlowMeter::SaveCalibrData(void)
{
    tCalibrPoint Pnt;
    float cEtlVolume[20], cTime[20], cImp[20], cCoefs[20];
    int size;

    if (!CalibrPoints.empty()) {
        size = CalibrPoints.size();
    } else {
        size = 0;
    }

    for (int i = 0; i < 20; i++) {
        // Вычисляем расход для данной калибровочной точки
        if (i < size) {
            Pnt = CalibrPoints[i];

            cEtlVolume[i] = Pnt.EtlValue;
            cTime[i] = Pnt.Time;
            cImp[i] = Pnt.RawValue;
            cCoefs[i] = Pnt.Coef;
        } else {
            cEtlVolume[i] = 0;
            cTime[i] = 0;
            cImp[i] = 0;
            cCoefs[i] = 0;
        }
    }

    HSC->Save_CalibrData(cEtlVolume, cTime, cImp, cCoefs);
}

void TFlowMeter::SaveCoef()
{
    HSC->Write_Coef(Kp);
}

int8_t TFlowMeter::UpdateCoefs()
{
	if ((int)MeterFlowType<	(int)VOLUME_FLOWMETER_TYPE) {
        return ValueMassFlow->UpdateCoefs(CalibrPoints);
    } else {
		return ValueVolume->UpdateCoefs(CalibrPoints);
    }
}

int8_t TFlowMeter::AddCalibrData(
    float vEtlVolume, float vTime, float vImp, float vCoef)
{
    tCalibrPoint Pnt;

    if (vCoef == 0) {
        return -1;
    }
    if (vTime == 0) {
        return -2;
    }
    if (vTime < 1) {
        return -3;
    }
    if (vTime > 100000) {
        return -4;
    }

    if (IsInfinite(vTime)) {
        return -5;
    }
    if (IsInfinite(vCoef)) {
        return -5;
    }
    if (IsInfinite(vImp)) {
        return -5;
    }

    if (IsNan(vTime)) {
        return -5;
    }
    if (IsNan(vCoef)) {
        return -5;
    }
    if (IsNan(vImp)) {
        return -5;
    }

    Pnt.EtlValue = vEtlVolume;
    Pnt.Time = vTime;
    Pnt.RawValue = vImp;
    Pnt.Coef = vCoef;

    Pnt.Value = Pnt.RawValue / Pnt.Coef;
    Pnt.Q = (Pnt.EtlValue / Pnt.Time) * 3600;
    Pnt.Qtest = (Pnt.Value / Pnt.Time) * 3600;

    Pnt.Error = ((Pnt.Value - Pnt.EtlValue) * 100) / Pnt.EtlValue;
    Pnt.Rate = Pnt.Value / Pnt.EtlValue;
    Pnt.CoefPoint = Pnt.Coef * Pnt.Rate;
    AddCalibrPoint(Pnt);

    return 1;
}

void TFlowMeter::ClearPoints(void)
{
    Points.clear();
}

void TFlowMeter::ClearCalibraion(void)
{
    CalibrPoints.clear();
    ValueMassFlow->Coefs.clear();
    ValueVolume->Coefs.clear();
}

void TFlowMeter::AddCurrentCalibrPoint(void)
{
    AddCalibrPoint(CalibrPoint);
}

int8_t TFlowMeter::AddCalibrPoint(tCalibrPoint Pnt)
{
    tCalibrPoint temp, temp1;
    float Q1, Q2;
    std::vector<tCalibrPoint>::iterator it;

    it = CalibrPoints.begin();

    if (!CalibrPoints.empty()) {
        temp = Pnt;

        for (int i = 0; i < CalibrPoints.size(); i++) {
            // Вычисляем расход для данной калибровочной точки
            temp1 = CalibrPoints[i];
            if (CalibrPoints[i].Time > 0) {
                Q1 = CalibrPoints[i].EtlValue / CalibrPoints[i].Time;
            } else {
                return -1;
            }

            if (Pnt.Time > 0) {
                Q2 = Pnt.EtlValue / Pnt.Time;
            } else {
                return -1;
            }

            if (Q2 <= Q1) {
                CalibrPoints.insert(it + i, Pnt);
                return 1;
            }
        }

        CalibrPoints.push_back(Pnt);
        return 2;

    } else {
        CalibrPoints.push_back(Pnt);
        return 3;
    }
}

tPoint TFlowMeter::GetCurrentPoint()
{
    return Point;
}

tPoint TFlowMeter::GetPoint(int hash)
{

       int index = -1;
       int j;


     for (int i = 0; i < Points.size(); i++)
     {
        j =  Points[i].Hash;

	 	if (j == hash) {
            return  Points[i];
        }
    }

           return  Points[0];
}

tPoint TFlowMeter::SetNextPoint()
{
    int index = -1;
    int hash;
    /*
    float eps = 0.01;

    for (int i = 0; i < Points.size(); i++) {
		if (SameValue((float)Point.Q, (float)Points[i].Q, eps)) {
            index = i;
        }
    }
     */

     for (int i = 0; i < Points.size(); i++)
     {
        hash =  Points[i].Hash;

	 	if (Point.Hash == hash) {
            index = i;
        }
    }



    if (index >= 0) {
        if (index + 1 < Points.size()) {
            Point = Points[index + 1];
        } else {
            // Point = Points[0];
        }

    } else
    {
      Point = Points[Points.size()-1];
    }

    return Point;
}

tPoint TFlowMeter::SetPreviousPoint()
{
    int index = -1;
    int hash;
  /*  float eps = 0.001;

    for (int i = 0; i < Points.size(); i++) {
		if (SameValue((float)Point.Q, (float)Points[i].Q, eps)) {
            index = i;
        }
    }

     */

        for (int i = 0; i < Points.size(); i++)
     {
        hash =  Points[i].Hash;

	 	if (Point.Hash == hash) {
            index = i;
        }
    }


	if (index != -1) {
		if ((index) > 0) {
            Point = Points[index - 1];
        } else {
            Point = Points[0];
        }
    } else
    {
        Point = Points[0];
    }



    return Point;
}

void TFlowMeter::SetEtalonPoint(tPoint point)
{
     Point = point;
     ValueCoef->SetValue(Point.Coef);
}

void TFlowMeter::SetEtalonPoint(int hash)
{
     Point = GetPoint(hash);
     ValueCoef->SetValue(Point.Coef);
}

void TFlowMeter::SetEtalonPoint(UnicodeString hash)
{
     int i;
     if (TryStrToInt_(hash, i))
     {
        SetEtalonPoint(i);
     }
}

void TFlowMeter::RestoreTypePoints(void)
{
 //   Points.clear();

    for (int i = 0; i < Type->Points.size(); i++) {
  //      Points.push_back(Type->Points[i]);
    }
}

void TFlowMeter::SaveToFile(TFlowMeter* AFlowMeter, int IsBackUp)
{
    SaveTestMetersToFile(AFlowMeter, IsBackUp);
    SaveEtalonsToFile(IsBackUp);
}

void TFlowMeter::SaveTestMetersToFile(TFlowMeter* AFlowMeter, int IsBackUp)
{
    bool success = true;
    int k = 0, l = 0;
    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    int hash;

    XmlDoc = new TXMLDocument(NULL);

	//XmlDoc->DOMVendor = DOMVendors->Vendors[0];
    // < OMNI XML кроссплатформенный вендор
    XmlDoc->XML->Clear();
    XmlDoc->FileName = "";
    XmlDoc->Active = true;
    //
    // Создадим главную ветку и добавим узел об устройстве

    rootNode = XmlDoc->AddChild("Devices");

    // CheckStoragePermission_(this);

    if (!FlowMeters.empty()) {
        rootNode->SetAttribute("VER", XMLVERFLOWMETERS);

        k = FlowMeters.size();

        /*
        while (l < FlowMeters.size()) {
            if ((FlowMeters[l]->SerialNum == "") &&
                (FlowMeters[l]->DataPoints.empty())) {
                TFlowMeter::FlowMeters.erase(
                    TFlowMeter::FlowMeters.begin() + l);

            } else {
                l = l + 1;
            }
        }
        */
        rootNode->SetAttribute("DeviceCount", IntToStr((int)FlowMeters.size()));

        for (int j = 0; j < FlowMeters.size(); j++) {
            sampleNode = rootNode->AddChild("Device" + IntToStr(j));

            {
                hash = FlowMeters[j]->Hash;

                sampleNode->SetAttribute("Hash", FlowMeters[j]->Hash);

                sampleNode->SetAttribute("ID_Order", FlowMeters[j]->ID_Order);

                sampleNode->SetAttribute(
                    "OrderHash", IntToStr(FlowMeters[j]->OrderHash));

                sampleNode->SetAttribute("DN", FlowMeters[j]->DN);

                sampleNode->SetAttribute(
                    "Name", FlowMeters[j]->Name);

                sampleNode->SetAttribute(
                    "Active", IntToStr(FlowMeters[j]->Active));

                if (FlowMeters[j]->Active==1) {
                   FlowMeters[j]->Active = FlowMeters[j]->Active;
                }



                sampleNode->SetAttribute(
                    "IsEtalon", FlowMeters[j]->GetEtalonState());
                sampleNode->SetAttribute(
                    "DeviceType", FlowMeters[j]->DeviceType);
                sampleNode->SetAttribute(
                    "Modification", FlowMeters[j]->Modification);

                sampleNode->SetAttribute(
                    "Modifications", FlowMeters[j]->Modifications);

                sampleNode->SetAttribute(
                    "TypeHash", IntToStr(FlowMeters[j]->TypeHash));

                sampleNode->SetAttribute("SerialNum", FlowMeters[j]->SerialNum);
                sampleNode->SetAttribute(
                    "YearOfProduction", FlowMeters[j]->year_production);

                sampleNode->SetAttribute(
                    "CertificateNum", FlowMeters[j]->CertificateNum);

                sampleNode->SetAttribute(
                    "CheckType", IntToStr(FlowMeters[j]->CheckType));
                sampleNode->SetAttribute("VerificationInterva",
                    IntToStr(FlowMeters[j]->VerificationInterval));

                sampleNode->SetAttribute("Kp", FloatToStr(FlowMeters[j]->Kp));

                sampleNode->SetAttribute(
					"FactoryKp", FloatToStr(FlowMeters[j]->FactoryKp));
                SetDoubleAttribute(
                    "FlowMax", sampleNode, FlowMeters[j]->FlowMax);
				SetDoubleAttribute(
                    "FlowMin", sampleNode, FlowMeters[j]->FlowMin);
                SetDoubleAttribute(
                    "QuantityMax", sampleNode, FlowMeters[j]->QuantityMax);
				SetDoubleAttribute(
					"QuantityMin", sampleNode, FlowMeters[j]->QuantityMin);



				SetDoubleAttribute(
                    "Error", sampleNode, FlowMeters[j]->Error);

                sampleNode->SetAttribute(
                    "Status", IntToStr(FlowMeters[j]->Status));

                sampleNode->SetAttribute(
                    "SendStatus", IntToStr(FlowMeters[j]->SendStatus));

                sampleNode->SetAttribute("Adress", FlowMeters[j]->Adress);
                sampleNode->SetAttribute(
                    "doc_number", FlowMeters[j]->doc_number);

                sampleNode->SetAttribute(
                    "ModifidedDateTime", FlowMeters[j]->ModifidedDateTime);

                SetIntAttribute(
                    "MeterFlowType", sampleNode, (int)FlowMeters[j]->MeterFlowType);

                SetIntAttribute(
                    "PointHash", sampleNode, FlowMeters[j]->Point.Hash);




                FlowMeters[j]->InitHashValues();

                SetIntAttribute(
                    "HashValueImp", sampleNode, FlowMeters[j]->HashValueImp);
                SetIntAttribute("HashValueImpTotal", sampleNode,
                    FlowMeters[j]->HashValueImpTotal);
                SetIntAttribute(
                    "HashValueCoef", sampleNode, FlowMeters[j]->HashValueCoef);
                SetIntAttribute("HashValueMassCoef", sampleNode,
                    FlowMeters[j]->HashValueMassCoef);
                SetIntAttribute("HashValueVolumeCoef", sampleNode,
                    FlowMeters[j]->HashValueVolumeCoef);
                SetIntAttribute("HashValueVolume", sampleNode,
                    FlowMeters[j]->HashValueVolume);
                SetIntAttribute(
                    "HashValueMass", sampleNode, FlowMeters[j]->HashValueMass);
                SetIntAttribute("HashValueVolumeMeter", sampleNode,
                    FlowMeters[j]->HashValueVolumeMeter);
                SetIntAttribute("HashValueMassMeter", sampleNode,
                    FlowMeters[j]->HashValueMassMeter);
                SetIntAttribute("HashValueMassFlow", sampleNode,
                    FlowMeters[j]->HashValueMassFlow);
                SetIntAttribute("HashValueVolumeFlow", sampleNode,
                    FlowMeters[j]->HashValueVolumeFlow);
                SetIntAttribute("HashValueQuantity", sampleNode,
                    FlowMeters[j]->HashValueQuantity);
                SetIntAttribute(
                    "HashValueFlow", sampleNode, FlowMeters[j]->HashValueFlow);
                SetIntAttribute("HashValueError", sampleNode,
                    FlowMeters[j]->HashValueError);
                SetIntAttribute("HashValueVolumeError", sampleNode,
                    FlowMeters[j]->HashValueVolumeError);
                SetIntAttribute("HashValueMassError", sampleNode,
                    FlowMeters[j]->HashValueMassError);
                SetIntAttribute("HashValueDensity", sampleNode,
                    FlowMeters[j]->HashValueDensity);
                SetIntAttribute("HashValuePressure", sampleNode,
                    FlowMeters[j]->HashValuePressure);
                SetIntAttribute("HashValueTemperture", sampleNode,
                    FlowMeters[j]->HashValueTemperture);

                SetIntAttribute("HashValueAirPressure", sampleNode,
                    FlowMeters[j]->HashValueAirPressure);
                SetIntAttribute("HashValueAirTemperture", sampleNode,
                    FlowMeters[j]->HashValueAirTemperture);
                SetIntAttribute("HashValueHumidity", sampleNode,
                    FlowMeters[j]->HashValueHumidity);
                SetIntAttribute("HashValueCurrent", sampleNode,
                    FlowMeters[j]->HashValueCurrent);
                SetIntAttribute(
                    "HashValueTime", sampleNode, FlowMeters[j]->HashValueTime);

                sampleNode2 = sampleNode->AddChild("Points");

                sampleNode2->SetAttribute(
                    "PointsCount", IntToStr((int)FlowMeters[j]->Points.size()));

                if (!FlowMeters[j]->Points.empty()) {
                    for (int i = 0; i < FlowMeters[j]->Points.size(); i++) {
                        sampleNode2 =
                            sampleNode->AddChild("Point" + IntToStr(i));

                        sampleNode2->SetAttribute(
                            "Name", FlowMeters[j]->Points[i].Name);

                        SetIntAttribute(
                            "Hash", sampleNode2, FlowMeters[j]->Points[i].Hash);

                        SetDoubleAttribute(
                            "Q", sampleNode2, FlowMeters[j]->Points[i].Q);

                        SetDoubleAttribute("Qrate", sampleNode2,
                            FlowMeters[j]->Points[i].Qrate);

                        SetDoubleAttribute("Mrate", sampleNode2,
                            FlowMeters[j]->Points[i].Mrate);

                        SetDoubleAttribute("Volume", sampleNode2,
                            FlowMeters[j]->Points[i].Volume);

                        SetIntAttribute(
                            "Time", sampleNode2, FlowMeters[j]->Points[i].Time);

                        SetDoubleAttribute("Error", sampleNode2,
                            FlowMeters[j]->Points[i].Error);



                        SetDoubleAttribute("RagePlus", sampleNode2,
                            FlowMeters[j]->Points[i].RagePlus);

                        SetDoubleAttribute("RageMinus", sampleNode2,
                            FlowMeters[j]->Points[i].RageMinus);

                        SetIntAttribute("IsRageFree", sampleNode2,
                            FlowMeters[j]->Points[i].IsRageFree);

                        SetIntAttribute("Series", sampleNode2,
                            FlowMeters[j]->Points[i].Series);

                        /*
						sampleNode2->SetAttribute(
							"Q", FloatToStrF(FlowMeters[j]->Points[i].Q,
                                     ffNumber, 10, 2));
						sampleNode2->SetAttribute("Volume",
                            FloatToStrF(FlowMeters[j]->Points[i].Volume,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute(
							"Time", FloatToStrF(FlowMeters[j]->Points[i].Time,
                                        ffNumber, 10, 2));
                        sampleNode2->SetAttribute(
							"Error", FloatToStrF(FlowMeters[j]->Points[i].Error,
                                         ffNumber, 10, 2));
						sampleNode2->SetAttribute("RagePlus",
                            FloatToStrF(FlowMeters[j]->Points[i].RagePlus,
                                ffNumber, 3, 1));
						sampleNode2->SetAttribute("RageMinus",
                            FloatToStrF(FlowMeters[j]->Points[i].RageMinus,
								ffNumber, 3, 1));
						sampleNode2->SetAttribute("IsRageFree",
                            IntToStr(FlowMeters[j]->Points[i].IsRageFree));
						sampleNode2->SetAttribute("Series",
							IntToStr(FlowMeters[j]->Points[i].Series));   */
                    }
                }

                sampleNode2 = sampleNode->AddChild("DataPoints");

                sampleNode2->SetAttribute("DataPointsCount",
                    IntToStr((int)FlowMeters[j]->DataPoints.size()));

                if (!FlowMeters[j]->DataPoints.empty()) {
                    for (int i = 0; i < FlowMeters[j]->DataPoints.size(); i++) {
                        sampleNode2 =
                            sampleNode->AddChild("DataPoint" + IntToStr(i));
                        sampleNode2->SetAttribute(
                            "Name", FlowMeters[j]->DataPoints[i].Name);

                        sampleNode2->SetAttribute(
                            "EtlName", FlowMeters[j]->DataPoints[i].EtlName);

                        sampleNode2->SetAttribute(
                            "Date", FlowMeters[j]->DataPoints[i].Date);

                        sampleNode2->SetAttribute(
                            "Comment", FlowMeters[j]->DataPoints[i].Comment);
                        /*	sampleNode2->SetAttribute("Qrate",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Q, ffNumber,
						10, 2));   */

                        sampleNode2->SetAttribute(
                            "EtlCoef", FlowMeters[j]->DataPoints[i].EtlCoef);

                        sampleNode2->SetAttribute(
                            "Qt", FlowMeters[j]->DataPoints[i].Qt);
                        sampleNode2->SetAttribute(
                            "Q", FlowMeters[j]->DataPoints[i].Q);

                        sampleNode2->SetAttribute(
                            "EtlTime", FlowMeters[j]->DataPoints[i].EtlTime);
                        sampleNode2->SetAttribute("EtlVolume",
                            FlowMeters[j]->DataPoints[i].EtlVolume);
                        sampleNode2->SetAttribute(
                            "EtlMass", FlowMeters[j]->DataPoints[i].EtlMass);
                        sampleNode2->SetAttribute(
                            "EtlImp", FlowMeters[j]->DataPoints[i].EtlImp);
                        sampleNode2->SetAttribute(
                            "EtlTemp", FlowMeters[j]->DataPoints[i].EtlTemp);
                        sampleNode2->SetAttribute(
                            "EtlPres", FlowMeters[j]->DataPoints[i].EtlPres);
                        sampleNode2->SetAttribute("EtlTempAir",
                            FlowMeters[j]->DataPoints[i].EtlTempAir);
                        sampleNode2->SetAttribute("EtlPresAir",
                            FlowMeters[j]->DataPoints[i].EtlPresAir);
                        sampleNode2->SetAttribute("EtlHumidity",
                            FlowMeters[j]->DataPoints[i].EtlHumidity);
                        sampleNode2->SetAttribute(
                            "Time", FlowMeters[j]->DataPoints[i].Time);
                        sampleNode2->SetAttribute(
                            "Volume", FlowMeters[j]->DataPoints[i].Volume);
                        sampleNode2->SetAttribute(
                            "Imp", FlowMeters[j]->DataPoints[i].Imp);
                        sampleNode2->SetAttribute(
                            "Mass", FlowMeters[j]->DataPoints[i].Mass);
                        sampleNode2->SetAttribute("VolumeMeter",
                            FlowMeters[j]->DataPoints[i].VolumeMeter);
                        sampleNode2->SetAttribute("MassMeter",
                            FlowMeters[j]->DataPoints[i].MassMeter);
                        sampleNode2->SetAttribute(
                            "Temp", FlowMeters[j]->DataPoints[i].Temp);
                        sampleNode2->SetAttribute(
                            "Pres", FlowMeters[j]->DataPoints[i].Pres);
                        sampleNode2->SetAttribute(
                            "TempAir", FlowMeters[j]->DataPoints[i].TempAir);
                        sampleNode2->SetAttribute(
                            "PresAir", FlowMeters[j]->DataPoints[i].PresAir);
                        sampleNode2->SetAttribute(
                            "Humidity", FlowMeters[j]->DataPoints[i].Humidity);

                        sampleNode2->SetAttribute(
                            "Density", FlowMeters[j]->DataPoints[i].Density);
                        sampleNode2->SetAttribute("EtlDensity",
                            FlowMeters[j]->DataPoints[i].EtlDensity);

                        sampleNode2->SetAttribute(
                            "Error", FlowMeters[j]->DataPoints[i].Error);

                       sampleNode2->SetAttribute(
                            "ErrorMeter", FlowMeters[j]->DataPoints[i].ErrorMeter);
                    }
                }
            }
        }
    } else {
        rootNode->SetAttribute("VER", XMLVER);
        rootNode->SetAttribute("DeviceCount", "0");
    }

    if (IsBackUp == 0) {
        fname = TSettingsClass::Dir +
                System::Ioutils::TPath::DirectorySeparatorChar + "TestMeters" +
                System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
        XmlDoc->SaveToFile(fname);

    } else {
        fname = TSettingsClass::Dir +
                System::Ioutils::TPath::DirectorySeparatorChar +
                "TestMetersBackUp" + IntToStr(IsBackUp) +
                System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
    }

    // XmlDoc->L
    XmlDoc->Active = false;
}

void TFlowMeter::SaveEtalonsToFile(int IsBackUp)
{
    bool success = true;
    int k = 0, l = 0;
    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    XmlDoc = new TXMLDocument(NULL);

	//XmlDoc->DOMVendor = DOMVendors->Vendors[0];
    // < OMNI XML кроссплатформенный вендор
	XmlDoc->XML->Clear();
    XmlDoc->FileName = "";
    XmlDoc->Active = true;
    //
    // Создадим главную ветку и добавим узел об устройстве

    rootNode = XmlDoc->AddChild("Devices");

    // CheckStoragePermission_(this);

    if (!Etalons.empty()) {
        rootNode->SetAttribute("VER", XMLVERFLOWMETERS);
        /*
			k=  Etalons.size();
			while (l < Etalons.size())
			{
			if ((Etalons[l]->SerialNum=="")&&(Etalons[l]->DataPoints.empty()))
			{

				  TFlowMeter::Etalons.erase(TFlowMeter::Etalons.begin()+l);

			}   else
			{
				 l=l+1;
			}

			}

             */

        rootNode->SetAttribute("DeviceCount", IntToStr((int)Etalons.size()));

        SetIntAttribute("ActiveEtalonHash",rootNode, ActiveEtalonHash);

        for (int j = 0; j < Etalons.size(); j++) {
            TFlowMeter* Etalon = Etalons[j];
            sampleNode = rootNode->AddChild("Device" + IntToStr(j));

            {

               try {


                sampleNode->SetAttribute("Hash", Etalons[j]->Hash);
                sampleNode->SetAttribute("DN", Etalons[j]->DN);
                sampleNode->SetAttribute("Name", Etalons[j]->Name);
                sampleNode->SetAttribute("ID_Order", Etalons[j]->ID_Order);

                sampleNode->SetAttribute(
                    "Active", IntToStr(Etalons[j]->Active));
                sampleNode->SetAttribute(
                    "IsEtalon", Etalons[j]->GetEtalonState());
                sampleNode->SetAttribute("DeviceType", Etalons[j]->DeviceType);
                sampleNode->SetAttribute(
                    "Modification", Etalons[j]->Modification);
                sampleNode->SetAttribute(
                    "Modifications", Etalons[j]->Modifications);
                sampleNode->SetAttribute(
                    "TypeHash", IntToStr(Etalons[j]->TypeHash));



				sampleNode->SetAttribute("SerialNum", Etalons[j]->SerialNum);



                sampleNode->SetAttribute(
                    "YearOfProduction", Etalons[j]->year_production);

                sampleNode->SetAttribute(
                    "CertificateNum", Etalons[j]->CertificateNum);

                SetIntAttribute("CheckType", sampleNode, Etalons[j]->CheckType);


                SetIntAttribute("VerificationInterva", sampleNode,
                    Etalons[j]->VerificationInterval);



                SetDoubleAttribute("Kp", sampleNode, Etalons[j]->Kp);

                SetDoubleAttribute("FactoryKp", sampleNode, Etalons[j]->FactoryKp);



                SetDoubleAttribute("FlowMax", sampleNode, Etalons[j]->FlowMax);

                SetDoubleAttribute("FlowMin", sampleNode, Etalons[j]->FlowMin);

                SetDoubleAttribute("QuantityMax", sampleNode, Etalons[j]->QuantityMax);

				SetDoubleAttribute("QuantityMin", sampleNode, Etalons[j]->QuantityMin);



                SetIntAttribute("Status",sampleNode, Etalons[j]->Status);
                SetIntAttribute("SendStatus", sampleNode, Etalons[j]->SendStatus);

                sampleNode->SetAttribute("Adress", Etalons[j]->Adress);
                sampleNode->SetAttribute("doc_number", Etalons[j]->doc_number);

                sampleNode->SetAttribute(
                    "ModifidedDateTime", Etalons[j]->ModifidedDateTime);


                SetIntAttribute(
					"MeterFlowType", sampleNode, (int)Etalons[j]->MeterFlowType);

               Etalons[j]->InitHashValues();

               SetIntAttribute("HashValueImp", sampleNode,Etalons[j]->HashValueImp );
               SetIntAttribute("HashValueImpTotal", sampleNode,Etalons[j]->HashValueImpTotal);
               SetIntAttribute("HashValueCoef", sampleNode,Etalons[j]->HashValueCoef);
               SetIntAttribute("HashValueMassCoef", sampleNode,Etalons[j]->HashValueMassCoef);
               SetIntAttribute("HashValueVolumeCoef", sampleNode,Etalons[j]->HashValueVolumeCoef);
               SetIntAttribute("HashValueVolume", sampleNode,Etalons[j]->HashValueVolume);
               SetIntAttribute("HashValueMass", sampleNode, Etalons[j]->HashValueMass);
               SetIntAttribute("HashValueVolumeMeter", sampleNode,Etalons[j]->HashValueVolumeMeter);
               SetIntAttribute("HashValueMassMeter", sampleNode,Etalons[j]->HashValueMassMeter);
               SetIntAttribute("HashValueMassFlow", sampleNode,Etalons[j]->HashValueMassFlow);
               SetIntAttribute("HashValueVolumeFlow", sampleNode,Etalons[j]->HashValueVolumeFlow);
               SetIntAttribute("HashValueQuantity", sampleNode,Etalons[j]->HashValueQuantity);
               SetIntAttribute("HashValueFlow", sampleNode,Etalons[j]->HashValueFlow);
               SetIntAttribute("HashValueError", sampleNode,Etalons[j]->HashValueError);
               SetIntAttribute("HashValueVolumeError", sampleNode,Etalons[j]->HashValueVolumeError);
               SetIntAttribute("HashValueMassError", sampleNode,Etalons[j]->HashValueMassError);
               SetIntAttribute("HashValueDensity", sampleNode,Etalons[j]->HashValueDensity);
               SetIntAttribute("HashValuePressure", sampleNode,Etalons[j]->HashValuePressure);
               SetIntAttribute("HashValueTemperture", sampleNode,Etalons[j]->HashValueTemperture);

               SetIntAttribute("HashValueAirPressure", sampleNode, Etalons[j]->HashValueAirPressure);
               SetIntAttribute("HashValueAirTemperture", sampleNode,Etalons[j]->HashValueAirTemperture);
               SetIntAttribute("HashValueHumidity", sampleNode,Etalons[j]->HashValueHumidity);
               SetIntAttribute("HashValueCurrent", sampleNode,Etalons[j]->HashValueCurrent);
               SetIntAttribute("HashValueTime", sampleNode,Etalons[j]->HashValueTime);

               SetIntAttribute(
                    "PointHash", sampleNode, Etalons[j]->Point.Hash);

                sampleNode2 = sampleNode->AddChild("Points");

                sampleNode2->SetAttribute(
                    "PointsCount", IntToStr((int)Etalons[j]->Points.size()));

                if (!Etalons[j]->Points.empty()) {
					for (int i = 0; i < Etalons[j]->Points.size(); i++) {

					tPoint Pnt = Etalons[j]->Points[i];

						sampleNode2 =
                            sampleNode->AddChild("Point" + IntToStr(i));

						SetStrAttribute("Name",sampleNode2,  Etalons[j]->Points[i].Name);

						SetIntAttribute("Hash",sampleNode2,Etalons[j]->Points[i].Hash);

						SetDoubleAttribute("Qrate", sampleNode2,Etalons[j]->Points[i].Qrate);
                        SetDoubleAttribute("Mrate", sampleNode2,Etalons[j]->Points[i].Mrate);


						 sampleNode2->SetAttribute("Imp",
						   EtalonMeter-> ValueImpTotal->GetStringNum(Etalons[j]->Points[i].Imp));


						SetDoubleAttribute("Q", sampleNode2,Etalons[j]->Points[i].Q);

						SetDoubleAttribute("Volume", sampleNode2,Etalons[j]->Points[i].Volume);

					   //	sampleNode2->SetAttribute("Volume",
						//  EtalonMeter-> ValueQuantity->GetStringNum(Etalons[j]->Points[i].Volume));

						sampleNode2->SetAttribute("Time",
						FloatToStrF(Etalons[j]->Points[i].Time, ffNumber, 10, 2));

						sampleNode2->SetAttribute("Error",
						EtalonMeter-> ValueError->GetStringNum(Etalons[j]->Points[i].Error));

						sampleNode2->SetAttribute("RagePlus",
							FloatToStrF(Etalons[j]->Points[i].RagePlus,
								ffNumber, 3, 1));

						sampleNode2->SetAttribute("RageMinus",
                            FloatToStrF(Etalons[j]->Points[i].RageMinus,
								ffNumber, 3, 1));

						sampleNode2->SetAttribute("IsRageFree",
							IntToStr(Etalons[j]->Points[i].IsRageFree));

						 sampleNode2->SetAttribute("Series",
							IntToStr(Etalons[j]->Points[i].Series));

					  //	 sampleNode2->SetAttribute("Coef",
					  //	EtalonMeter->ValueCoef->GetStrNum(Etalons[j]->Points[i].Coef));


					   SetDoubleAttribute("Coef", sampleNode2,Etalons[j]->Points[i].Coef);


					 //	 sampleNode2->SetAttribute("Uncertainty",
					 //	FloatToStrF(Etalons[j]->Points[i].Uncertainty, ffNumber, 10, 4));

						SetDoubleAttribute("Uncertainty", sampleNode2,Etalons[j]->Points[i].Uncertainty);
					}
                }

                sampleNode2 = sampleNode->AddChild("DataPoints");

                sampleNode2->SetAttribute("DataPointsCount",
                    IntToStr((int)Etalons[j]->DataPoints.size()));

                if (!Etalons[j]->DataPoints.empty()) {
                    for (int i = 0; i < Etalons[j]->DataPoints.size(); i++) {
                        sampleNode2 =
                            sampleNode->AddChild("DataPoint" + IntToStr(i));
                        sampleNode2->SetAttribute(
                            "Name", Etalons[j]->DataPoints[i].Name);
                        sampleNode2->SetAttribute(
                            "Comment", Etalons[j]->DataPoints[i].Comment);
                        /*	sampleNode2->SetAttribute("Qrate",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Q, ffNumber,
						10, 2));   */

                        /*
					sampleNode2->SetAttribute("Q",
						FloatToStrF(Etalons[j]->DataPoints[i].Q, ffNumber,
						10, 2));
					sampleNode2->SetAttribute("Time",
						FloatToStrF(Etalons[j]->DataPoints[i].Time, ffNumber,
						10, 2));
					sampleNode2->SetAttribute("Imp",
						FloatToStrF(Etalons[j]->DataPoints[i].Imp, ffNumber,
						10, 2));
					sampleNode2->SetAttribute("EtlVolume",
						FloatToStrF(Etalons[j]->DataPoints[i].EtlVolume,
						ffNumber, 10, 2));
					sampleNode2->SetAttribute("Volume",
						FloatToStrF(Etalons[j]->DataPoints[i].Volume,
						ffNumber, 10, 2));
					sampleNode2->SetAttribute("VolumeBefore",
						FloatToStrF((float)Etalons[j]->DataPoints[i].VolumeBefore,
						ffNumber, 10,5));
					sampleNode2->SetAttribute("VolumeAfter",
						FloatToStrF((float)Etalons[j]->DataPoints[i].VolumeAfter,
						ffNumber, 10, 5));


					sampleNode2->SetAttribute("Temp",
						FloatToStrF(Etalons[j]->DataPoints[i].Temp, ffNumber,
						10, 2));

					 sampleNode2->SetAttribute("Pres",
						FloatToStrF(Etalons[j]->DataPoints[i].Pres, ffNumber,
						10, 2));

					 sampleNode2->SetAttribute("Data",
						Etalons[j]->DataPoints[i].Date);
						//FlowMeters[j]->

					sampleNode2->SetAttribute("Error",
						FloatToStrF(Etalons[j]->DataPoints[i].Error, ffNumber,
						10, 2));
					  */
                    }
                }

                sampleNode2 = sampleNode->AddChild("CalibrPoints");
                sampleNode2->SetAttribute("CalibrPointsCount",
                    IntToStr((int)Etalons[j]->CalibrPoints.size()));

                if (!Etalons[j]->CalibrPoints.empty()) {
                    for (int i = 0; i < Etalons[j]->CalibrPoints.size(); i++) {
                        sampleNode2 =
                            sampleNode->AddChild("CalibrPoint" + IntToStr(i));

                        sampleNode2->SetAttribute(
                            "Q", FloatToStrF(Etalons[j]->CalibrPoints[i].Q,
                                     ffNumber, 10, 2));
                        sampleNode2->SetAttribute("Time",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].Time,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute("Imp",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].RawValue,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute("EtlVolume",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].EtlValue,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute("Volume",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].Value,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute("PointHash",
                            IntToStr(Etalons[j]->CalibrPoints[i].PointHash));
                        sampleNode2->SetAttribute("Rate",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].Rate,
                                ffNumber, 10, 2));
                        sampleNode2->SetAttribute("Coef",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].Coef,
                                ffNumber, 10, 4));
                        sampleNode2->SetAttribute(
                            "Data", Etalons[j]->CalibrPoints[i].Date);
                        //FlowMeters[j]->

                        sampleNode2->SetAttribute("Error",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].Error,
                                ffNumber, 10, 2));

                        sampleNode2->SetAttribute("CoefPoint",
                            FloatToStrF(Etalons[j]->CalibrPoints[i].CoefPoint,
                                ffNumber, 10, 4));
                    }
                }


               }
               catch (...)
               {
                    ShowMessage("Ошибка сохранения данных");
               }

            }
        }
    } else {
        rootNode->SetAttribute("VER", XMLVER);
        rootNode->SetAttribute("DeviceCount", "0");
    }

    if (IsBackUp == 0) {
        fname = TSettingsClass::Dir +
                System::Ioutils::TPath::DirectorySeparatorChar + "Etalons" +
				System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
        XmlDoc->SaveToFile(fname);

    } else {
        fname = TSettingsClass::Dir +
                System::Ioutils::TPath::DirectorySeparatorChar +
                "EtalonsBackUp" + IntToStr(IsBackUp) +
				System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
    }

    // XmlDoc->L
    XmlDoc->Active = false;
}

UnicodeString TFlowMeter::StringStreamConvert()
{
    TStringList* str = new TStringList();
    UnicodeString STR;
    TStringStream* REST_parameters; // =  new TStringStream(str1);

    str->Add("{");
    str->Add("\"order_id\": " + IntToStr(ID_Order) + ",");
    str->Add("\"mi_owner\": \"" + miOwner + "\",");
    str->Add("\"active\": \"" + IntToStr(Active) + "\",");
    str->Add("\"device_type\": \"" + DeviceType + "\",");
    str->Add("\"manufacture_num\": \"" + SerialNum + "\",");
    str->Add("\"mitype_number\": \"" + CertificateNum + "\",");
    str->Add("\"doc_title\": \"" + docTitle + "\",");
    str->Add("\"means\": \"" + means + "\",");
    str->Add("\"modification\": \"" + Modification + "\",");
    str->Add("\"dn\":\"" + DN + "\",");
    str->Add("\"next_verification\":\"" + validDate + "\",");
    str->Add("\"vrf_date\":\"" + vrfDate + "\",");
    str->Add("\"check_type\":\"" + IntToStr(CheckType) + "\",");
    str->Add("\"kp\":\"" + FloatToStr(Kp) + "\",");
    str->Add("\"q_max\":\"" + FloatToStr(FlowMax) + "\",");
    str->Add("\"temperature\":\"" + temperature + "\",");
    str->Add("\"temp_water\":\"" + tempWater + "\",");
    str->Add("\"pressure\":\"" + pressure + "\",");
    str->Add("\"hymidity\":\"" + hymidity + "\",");
    ;
    str->Add("\"result\":\"" + Result + "\",");
    str->Add("\"year_production\":\"" + year_production + "\",");
    str->Add("\"data1\":\"\",");
    str->Add("\"data2\":\"\",");
    str->Add("\"data3\":\"\",");
    str->Add("\"data_points\": [");

    // CheckStoragePermission_(this);

    if (!DataPoints.empty()) {
        for (int i = 0; i < DataPoints.size(); i++) {
            if (i == 0) {
                str->Add("{");
            } else {
                str->Add(",");
                str->Add("{");
            }
            /*
					  str->Add("\"q\":\""+FloatToStrF(DataPoints[i].Q, ffNumber,
						10, 2)+"\",");
					  str->Add("\"time\":\""+FloatToStrF(DataPoints[i].Time, ffNumber,
						10, 0)+"\",");
					  str->Add("\"imp\":\""+FloatToStrF(DataPoints[i].Imp, ffNumber,
						10, 0)+"\",");
					  str->Add("\"etl_volume\":\""+FloatToStrF(DataPoints[i].EtlVolume, ffNumber,
						10, 0)+"\",");
					  str->Add("\"volume\":\""+FloatToStrF(DataPoints[i].Volume, ffNumber,
						10, 0)+"\",");
					  str->Add("\"volume_before\":\""+FloatToStrF(DataPoints[i].VolumeBefore, ffNumber,
						10, 0)+"\",");
					  str->Add("\"volume_after\":\""+FloatToStrF(DataPoints[i].VolumeAfter, ffNumber,
						10, 0)+"\",");

					  str->Add("\"temp\":\""+FloatToStrF(DataPoints[i].Temp, ffNumber,
						10, 0)+"\",");

						str->Add("\"pres\":\""+FloatToStrF(DataPoints[i].Pres, ffNumber,
						10, 0)+"\",");
						str->Add("\"point_humidity\":\""+FloatToStrF(DataPoints[i].Humidity, ffNumber,
						10, 0)+"\",");
						str->Add("\"temp_air\":\""+FloatToStrF(DataPoints[i].TempAir, ffNumber,
						10, 0)+"\",");
						str->Add("\"data\":\"\",");
						str->Add("\"error\":\""+FloatToStrF(DataPoints[i].Error, ffNumber,
						10, 0)+"\"");

						str->Add("}");
						  */
        }
    }
    str->Add("]");

    str->Add("}");
    STR = str->Text;

    return STR;
}

TFlowMeter* TFlowMeter::LoadFromFile()
{
    LoadEtalonsFromFile();
    return LoadTestMetersFromFile();
}

TFlowMeter* TFlowMeter::LoadEtalonsFromFile()
{
    bool success = true;

    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TFlowMeter* FlowMeter;

    String str;

    int Size;
    int PointsSize;
    int PointHash;
    int index1 = 0;
    int index2 = 0;
    int size;
    float fl;

    _di_IXMLNode rootNode1;

    _di_IXMLDocument document =
        interface_cast<Xmlintf::IXMLDocument>(new TXMLDocument(NULL));

    UnicodeString SerialNum;
    UnicodeString dDir, FileName;
    UnicodeString VER;
    UnicodeString S;
    UnicodeString Result;

    _di_IXMLNodeList nodeList;

    // CheckStoragePermission_(this);

    XmlDoc = new TXMLDocument(NULL);

    fname = TSettingsClass::Dir +
            System::Ioutils::TPath::DirectorySeparatorChar + "Etalons" +
			System::Ioutils::TPath::ExtensionSeparatorChar + "xml";

    /*
	if (!DirectoryExists(TSettingsClass::Dir)) {
		Result = "Файл устройств не существует";
		throw Exception("Файл устройств не существует");
	}

	FileName = ExtractFileName(fname);
	 */
    if (!FileExists(fname)) {
        Result = "Файл устройств не существует";
        //	throw Exception("Файл типов не существует");
        ShowMessage(Format("Файл '%s' не существует. Создан новый файл.",
            ARRAYOFCONST((fname))));
        SaveToFile(nullptr, 0);
    }

    document = LoadXMLDocument(fname);

    if (document == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    TFlowMeter::Etalons.clear();

    rootNode = document->ChildNodes->FindNode("Devices");

    if (rootNode == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    VER = rootNode->Attributes["VER"];

    Size = rootNode->Attributes["DeviceCount"];

    ActiveEtalonHash = GetIntAttribute("ActiveEtalonHash", rootNode);

    for (int j = 0; j < Size; j++) {
        sampleNode = rootNode->ChildNodes->FindNode("Device" + IntToStr(j));

        if (sampleNode != NULL)
         {
            if (sHSC == nullptr) {
                FlowMeter = new TFlowMeter(true);
            } else {
                FlowMeter = new TFlowMeter(sHSC, true);
            }

            FlowMeter->ID_Order = sampleNode->Attributes["ID_Order"];

            FlowMeter->Active = StrToInt(sampleNode->Attributes["Active"]);



            FlowMeter->SetEtalonState(GetAttribute("IsEtalon", sampleNode));
            FlowMeter->Hash = GetIntAttribute("Hash", sampleNode);
            FlowMeter->Name = GetAttribute("Name", sampleNode);
            FlowMeter->DN = GetAttribute("DN", sampleNode);

            FlowMeter->DeviceType = sampleNode->Attributes["DeviceType"];

            FlowMeter->TypeHash = StrToInt(sampleNode->Attributes["TypeHash"]);
            InitType(FlowMeter);
            FlowMeter->Modification = (sampleNode->Attributes["Modification"]);

            FlowMeter->Modifications =
                GetAttribute("Modifications", sampleNode);

			FlowMeter->SerialNum =  GetAttribute("SerialNum", sampleNode);



            FlowMeter->CertificateNum =
                sampleNode->Attributes["CertificateNum"];
            FlowMeter->VerificationInterval =
                StrToInt(sampleNode->Attributes["VerificationInterva"]);
            FlowMeter->CheckType =
                StrToInt(sampleNode->Attributes["CheckType"]);
            FlowMeter->year_production =
                sampleNode->Attributes["YearOfProduction"];

			FlowMeter->Adress = GetAttribute("Adress", sampleNode);

            FlowMeter->FlowMax = GetDoubleAttribute("FlowMax", sampleNode,0);
            FlowMeter->FlowMin = GetDoubleAttribute("FlowMin", sampleNode,0);
            FlowMeter->QuantityMax = GetDoubleAttribute("QuantityMax", sampleNode,0);
			FlowMeter->QuantityMin = GetDoubleAttribute("QuantityMin", sampleNode,0);



			FlowMeter->Kp = GetDoubleAttribute("Kp", sampleNode,0);




            FlowMeter->FactoryKp = GetDoubleAttribute("FactoryKp", sampleNode,0);
            FlowMeter->Status = StrToInt(sampleNode->Attributes["Status"]);
            FlowMeter->SendStatus =
                StrToInt(sampleNode->Attributes["SendStatus"]);

            FlowMeter->ModifidedDateTime =
                GetAttribute("ModifidedDateTime", sampleNode);

            FlowMeter->MeterFlowType =
                (eMeterFlowType)GetIntAttribute("MeterFlowType", sampleNode, 0);

        //    FlowMeter->SetMeterFlowType((eMeterFlowType)GetIntAttribute("MeterFlowType", sampleNode, 0));

            FlowMeter->MeterFlowType = MASS_FLOWMETER_TYPE;

                               FlowMeter->HashValueImp = GetIntAttribute("HashValueImp", sampleNode,0);
               FlowMeter->HashValueImpTotal = GetIntAttribute("HashValueImpTotal", sampleNode,0);
               FlowMeter->HashValueCoef = GetIntAttribute("HashValueCoef", sampleNode,0);
               FlowMeter->HashValueMassCoef = GetIntAttribute("HashValueMassCoef", sampleNode,0);
               FlowMeter->HashValueVolumeCoef = GetIntAttribute("HashValueVolumeCoef", sampleNode,0);
               FlowMeter->HashValueVolume = GetIntAttribute("HashValueVolume", sampleNode,0);
               FlowMeter->HashValueMass = GetIntAttribute("HashValueMass", sampleNode,0);
               FlowMeter->HashValueVolumeMeter = GetIntAttribute("HashValueVolumeMeter", sampleNode,0);
               FlowMeter->HashValueMassMeter = GetIntAttribute("HashValueMassMeter", sampleNode,0);
               FlowMeter->HashValueMassFlow = GetIntAttribute("HashValueMassFlow", sampleNode,0);
               FlowMeter->HashValueVolumeFlow = GetIntAttribute("HashValueVolumeFlow", sampleNode,0);
               FlowMeter->HashValueQuantity = GetIntAttribute("HashValueQuantity", sampleNode,0);
               FlowMeter->HashValueFlow = GetIntAttribute("HashValueFlow", sampleNode,0);
               FlowMeter->HashValueError = GetIntAttribute("HashValueError", sampleNode,0);
               FlowMeter->HashValueVolumeError = GetIntAttribute("HashValueVolumeError", sampleNode,0);
               FlowMeter->HashValueMassError = GetIntAttribute("HashValueMassError", sampleNode,0);
               FlowMeter->HashValueDensity = GetIntAttribute("HashValueDensity", sampleNode,0);

               FlowMeter->HashValuePressure = GetIntAttribute("HashValuePressure", sampleNode,0);
               FlowMeter->HashValueTemperture = GetIntAttribute("HashValueTemperture", sampleNode,0);

               FlowMeter->HashValueAirPressure = GetIntAttribute("HashValueAirPressure", sampleNode,0);
               FlowMeter->HashValueAirTemperture = GetIntAttribute("HashValueAirTemperture", sampleNode,0);
               FlowMeter->HashValueHumidity = GetIntAttribute("HashValueHumidity", sampleNode,0);
               FlowMeter->HashValueCurrent = GetIntAttribute("HashValueCurrent", sampleNode,0);
               FlowMeter->HashValueTime = GetIntAttribute("HashValueTime", sampleNode,0);

               //
               FlowMeter->HashValuePressure = TSettingsClass::HashValuePressure;
               FlowMeter->HashValueTemperture = TSettingsClass::HashValueTemperture;
               FlowMeter->HashValueDensity = TSettingsClass::HashValueDensity;

               FlowMeter->HashValueAirPressure = TSettingsClass::HashValueAirPressure;
               FlowMeter->HashValueAirTemperture = TSettingsClass::HashValueAirTemperture;
               FlowMeter->HashValueHumidity = TSettingsClass::HashValueHumidity;
               //
               FlowMeter->RestoreValues();

        PointHash = GetIntAttribute("PointHash", sampleNode,0);

        sampleNode2 = sampleNode->ChildNodes->FindNode("Points");

        if (sampleNode2!=NULL) {

        PointsSize = sampleNode2->Attributes["PointsCount"];
        if (PointsSize > 0) {
            FlowMeter->Points.clear();

            for (int i = 0; i < PointsSize; i++) {
                sampleNode2 =
                    sampleNode->ChildNodes->FindNode("Point" + IntToStr(i));

                if (sampleNode != NULL) {
					FlowMeter->Point.Name =
					sampleNode2->Attributes["Name"];

					FlowMeter->Point.Hash =
						GetIntAttribute("Hash", sampleNode2, 0);


					FlowMeter->Point.Qrate =
						GetDoubleAttribute("Qrate", sampleNode2, 0);
					FlowMeter->Point.Q =
						 GetDoubleAttribute("Q", sampleNode2, 0);
					FlowMeter->Point.Volume =
						GetDoubleAttribute("Volume", sampleNode2, 0);
					FlowMeter->Point.Time =
						GetDoubleAttribute("Time", sampleNode2, 0);
					FlowMeter->Point.Error =
						GetDoubleAttribute("Error", sampleNode2, 0.05);
					FlowMeter->Point.Accuracy =
						GetDoubleAttribute("Accuracy", sampleNode2, 10.0);
                    /*
					   if (FlowMeter->Point.Name == "FlowMax") {
						   FlowMeter->Point.RagePlus =    10;
						   FlowMeter->Point.RageMinus =  90;

					   }   else
					   {
					   FlowMeter->Point.RagePlus = 10;
					   FlowMeter->Point.RageMinus = 10;
					   }     */

					FlowMeter->Point.RagePlus =
						GetDoubleAttribute("RagePlus", sampleNode2, 10);

                    if (FlowMeter->Point.Name == "FlowMax") {
						//FlowMeter->Point.RageMinus =
                        //	StrToFloat_(GetAttribute("RageMinus",sampleNode2,"90"));
                        FlowMeter->Point.RageMinus = 10;

                    } else {
						FlowMeter->Point.RageMinus =
							GetDoubleAttribute("RageMinus", sampleNode2, 10);
                    }

					FlowMeter->Point.IsRageFree =
						GetIntAttribute("IsRageFree", sampleNode2, 0);

					 FlowMeter->Point.Series =
						GetIntAttribute("Series", sampleNode2, 1.0);

					 FlowMeter->Point.Coef =
						GetDoubleAttribute("Coef", sampleNode2, 1.0);

					 FlowMeter->Point.Uncertainty =
						GetDoubleAttribute("Uncertainty", sampleNode2, 0.001);

					FlowMeter->AddEmptyPoint(FlowMeter->Point);
                }
            }
        }
        }
        sampleNode2 = sampleNode->ChildNodes->FindNode("CalibrPoints");
        if (sampleNode2 != NULL) {
            PointsSize = sampleNode2->Attributes["CalibrPointsCount"];

            for (int i = 0; i < PointsSize; i++) {
                sampleNode2 = sampleNode->ChildNodes->FindNode(
                    "CalibrPoint" + IntToStr(i));

                if (sampleNode2 != NULL) {
                    FlowMeter->CalibrPoint.Q =
                        StrToFloat_(sampleNode2->Attributes["Q"]);
                    FlowMeter->CalibrPoint.Time =
                        StrToFloat_(sampleNode2->Attributes["Time"]);
                    FlowMeter->CalibrPoint.RawValue =
                        StrToFloat_(sampleNode2->Attributes["Imp"]);
                    FlowMeter->CalibrPoint.EtlValue =
                        StrToFloat_(sampleNode2->Attributes["EtlVolume"]);

                    FlowMeter->CalibrPoint.Value =
                        StrToFloat_(sampleNode2->Attributes["Volume"]);

                    FlowMeter->CalibrPoint.EtlValue =
                        StrToFloat_(sampleNode2->Attributes["EtlMass"]);

                    str = sampleNode2->Attributes["Error"];
                    FlowMeter->CalibrPoint.Error =
                        StrToFloat_(sampleNode2->Attributes["Error"]);

                    FlowMeter->CalibrPoint.CoefPoint =
                        GetFloatAttribute("CoefPoint", sampleNode2, 1);

                    FlowMeter->CalibrPoint.Rate =
                        GetFloatAttribute("Rate", sampleNode2, 1);

                    FlowMeter->CalibrPoints.push_back(FlowMeter->CalibrPoint);
                }
            }
        }


        if (FlowMeter->Active==1) {
               FlowMeter->SetActiveEtalon();
        }

         FlowMeter->Point = FlowMeter->GetPoint(PointHash);

        //   TFlowMeter::FlowMeters.push_back(FlowMeter);
      }
    }

    /* }	else
	{

				Result = "Версия не может быть обработана";
				throw Exception(Result);
 *///	}

    {
        return ActiveEtalon;
    }
}

TFlowMeter* TFlowMeter::LoadTestMetersFromFile()
{
    bool success = true;

    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TFlowMeter* FlowMeter;
           tPoint pnt ;
    String str;

    int PointHash;

    int Size;
    int PointsSize;
    int index1 = 0;
    int index2 = 0;
    int size;
    int hash = 0;
    float fl;

    _di_IXMLNode rootNode1;

    _di_IXMLDocument document =
        interface_cast<Xmlintf::IXMLDocument>(new TXMLDocument(NULL));

    UnicodeString SerialNum;
    UnicodeString dDir, FileName;
    UnicodeString VER;
    UnicodeString S;
    UnicodeString Result;

    _di_IXMLNodeList nodeList;

    // CheckStoragePermission_(this);

    XmlDoc = new TXMLDocument(NULL);

    fname = TSettingsClass::Dir +
            System::Ioutils::TPath::DirectorySeparatorChar + "TestMeters" +
			System::Ioutils::TPath::ExtensionSeparatorChar + "xml";

    /*
	if (!DirectoryExists(TSettingsClass::Dir)) {
		Result = "Файл устройств не существует";
		throw Exception("Файл устройств не существует");
	}

	FileName = ExtractFileName(fname);
	 */
	if (!FileExists(fname)) {
        Result = "Файл устройств не существует";
        //	throw Exception("Файл типов не существует");
        ShowMessage(Format("Файл '%s' не существует. Создан новый файл.",
            ARRAYOFCONST((fname))));
        SaveToFile(nullptr, 0);
    }

    document = LoadXMLDocument(fname);

    if (document == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    TFlowMeter::FlowMeters.clear();

    rootNode = document->ChildNodes->FindNode("Devices");

    if (rootNode == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    VER = rootNode->Attributes["VER"];

    Size = rootNode->Attributes["DeviceCount"];

    for (int j = 0; j < Size; j++) {
        sampleNode = rootNode->ChildNodes->FindNode("Device" + IntToStr(j));

        if (sampleNode != NULL) {

          hash = 0;//GetIntAttribute("Hash", sampleNode);

            if (sHSC == nullptr) {
                FlowMeter = new TFlowMeter(false);
            } else {
                FlowMeter = new TFlowMeter(sHSC, false, hash);
            }

		 //	FlowMeter->Hash =  hash;


			FlowMeter->Name = 	GetAttribute("Name", sampleNode);
			FlowMeter->DN 	= 	GetAttribute("DN", sampleNode);

			FlowMeter->ID_Order = sampleNode->Attributes["ID_Order"];
             FlowMeter->OrderHash =  GetIntAttribute("OrderHash", sampleNode, 800);


			FlowMeter->Active = StrToInt(sampleNode->Attributes["Active"]);

			FlowMeter->SetEtalonState("false");
			FlowMeter->IsEtalon = false;
		   //	FlowMeter->SetEtalonState(GetAttribute("IsEtalon", sampleNode));



		 //   if ((FlowMeter->Active == 1) && (FlowMeter->IsEtalon = true)) {
		 //       ActiveEtalon = FlowMeter;
		 //   }

			FlowMeter->DeviceType = sampleNode->Attributes["DeviceType"];
            FlowMeter->TypeHash = StrToInt(sampleNode->Attributes["TypeHash"]);
            InitType(FlowMeter);
            FlowMeter->Modification = (sampleNode->Attributes["Modification"]);

            FlowMeter->Modifications =
                GetAttribute("Modifications", sampleNode);

           FlowMeter->SerialNum =     GetAttribute("SerialNum", sampleNode);

            FlowMeter->CertificateNum =
                sampleNode->Attributes["CertificateNum"];
            FlowMeter->VerificationInterval =
                StrToInt(sampleNode->Attributes["VerificationInterva"]);
            FlowMeter->CheckType =
                StrToInt(sampleNode->Attributes["CheckType"]);
            FlowMeter->year_production =
                sampleNode->Attributes["YearOfProduction"];

            FlowMeter->Adress = GetAttribute("Adress", sampleNode);

			FlowMeter->Kp = sampleNode->Attributes["Kp"];
            FlowMeter->FactoryKp = GetDoubleAttribute("FactoryKp", sampleNode,0);

            FlowMeter->FlowMax = GetDoubleAttribute("FlowMax", sampleNode,0);
            FlowMeter->FlowMin = GetDoubleAttribute("FlowMin", sampleNode,0);
			FlowMeter->QuantityMax = GetDoubleAttribute("QuantityMax", sampleNode,0);
			FlowMeter->QuantityMin = GetDoubleAttribute("QuantityMin", sampleNode,0);


            FlowMeter->Error = GetDoubleAttribute("Error", sampleNode,0.1);

            FlowMeter->Status = StrToInt(sampleNode->Attributes["Status"]);
            FlowMeter->SendStatus =
                StrToInt(sampleNode->Attributes["SendStatus"]);

            FlowMeter->ModifidedDateTime =
                GetAttribute("ModifidedDateTime", sampleNode);

            FlowMeter->MeterFlowType =
               (eMeterFlowType) GetIntAttribute("MeterFlowType", sampleNode, 1);

        //   FlowMeter->SetMeterFlowType(
        //   (eMeterFlowType)GetIntAttribute("MeterFlowType", sampleNode, 0));


               FlowMeter->HashValueImp = GetIntAttribute("HashValueImp", sampleNode,0);
               FlowMeter->HashValueImpTotal = GetIntAttribute("HashValueImpTotal", sampleNode,0);
               FlowMeter->HashValueCoef = GetIntAttribute("HashValueCoef", sampleNode,0);
               FlowMeter->HashValueMassCoef = GetIntAttribute("HashValueMassCoef", sampleNode,0);
               FlowMeter->HashValueVolumeCoef = GetIntAttribute("HashValueVolumeCoef", sampleNode,0);
               FlowMeter->HashValueVolume = GetIntAttribute("HashValueVolume", sampleNode,0);
               FlowMeter->HashValueMass = GetIntAttribute("HashValueMass", sampleNode,0);
               FlowMeter->HashValueVolumeMeter = GetIntAttribute("HashValueVolumeMeter", sampleNode,0);
               FlowMeter->HashValueMassMeter = GetIntAttribute("HashValueMassMeter", sampleNode,0);
               FlowMeter->HashValueMassFlow = GetIntAttribute("HashValueMassFlow", sampleNode,0);
               FlowMeter->HashValueVolumeFlow = GetIntAttribute("HashValueVolumeFlow", sampleNode,0);
               FlowMeter->HashValueQuantity = GetIntAttribute("HashValueQuantity", sampleNode,0);
               FlowMeter->HashValueFlow = GetIntAttribute("HashValueFlow", sampleNode,0);
               FlowMeter->HashValueError = GetIntAttribute("HashValueError", sampleNode,0);
               FlowMeter->HashValueVolumeError = GetIntAttribute("HashValueVolumeError", sampleNode,0);
               FlowMeter->HashValueMassError = GetIntAttribute("HashValueMassError", sampleNode,0);
               FlowMeter->HashValueDensity = GetIntAttribute("HashValueDensity", sampleNode,0);
               FlowMeter->HashValuePressure = GetIntAttribute("HashValuePressure", sampleNode,0);
               FlowMeter->HashValueTemperture = GetIntAttribute("HashValueTemperture", sampleNode,0);

               FlowMeter->HashValueAirPressure = GetIntAttribute("HashValueAirPressure", sampleNode,0);
               FlowMeter->HashValueAirTemperture = GetIntAttribute("HashValueAirTemperture", sampleNode,0);
               FlowMeter->HashValueHumidity = GetIntAttribute("HashValueHumidity", sampleNode,0);
               FlowMeter->HashValueCurrent = GetIntAttribute("HashValueCurrent", sampleNode,0);
               FlowMeter->HashValueTime = GetIntAttribute("HashValueTime", sampleNode,0);




        PointHash = GetIntAttribute("PointHash", sampleNode,0);


        sampleNode2 = sampleNode->ChildNodes->FindNode("Points");

        PointsSize = sampleNode2->Attributes["PointsCount"];

        if (PointsSize > 0) {
            FlowMeter->Points.clear();

            for (int i = 0; i < PointsSize; i++) {
                sampleNode2 =
                    sampleNode->ChildNodes->FindNode("Point" + IntToStr(i));

				if (sampleNode2 != NULL) {

					FlowMeter->Point.Name = //sampleNode2->Attributes["Name"];
						  GetAttribute("Name",sampleNode2,"-") ;
					FlowMeter->Point.Qrate =
                         GetDoubleAttribute("Qrate",sampleNode2,1);

                    FlowMeter->Point.Hash =
                          GetDoubleAttribute("Hash",sampleNode2,0);



                    FlowMeter->Point.Mrate =
						 GetDoubleAttribute("Mrate",sampleNode2,1);

					FlowMeter->Point.Q =
						GetDoubleAttribute("Q",sampleNode2,0);
					FlowMeter->Point.Volume =
						GetDoubleAttribute("Volume",sampleNode2,0);
					FlowMeter->Point.Time =
						GetIntAttribute("Time",sampleNode2,0);


					FlowMeter->Point.Error =
						GetDoubleAttribute("Error",sampleNode2,0.1);

                    FlowMeter->Point.Accuracy = StrToFloat_(
						GetAttribute("Accuracy", sampleNode2, "10"));
                    /*
					   if (FlowMeter->Point.Name == "FlowMax") {
						   FlowMeter->Point.RagePlus =    10;
						   FlowMeter->Point.RageMinus =  90;

					   }   else
					   {
					   FlowMeter->Point.RagePlus = 10;
					   FlowMeter->Point.RageMinus = 10;
					   }     */

					FlowMeter->Point.RagePlus =
						GetDoubleAttribute("RagePlus",sampleNode2,10);

                    if (FlowMeter->Point.Name == "FlowMax") {
                        //FlowMeter->Point.RageMinus =
						//	StrToFloat_(GetAttribute("RageMinus",sampleNode2,"90"));
						FlowMeter->Point.RageMinus = 10;

                    } else {
						FlowMeter->Point.RageMinus =
							GetDoubleAttribute("RageMinus",sampleNode2,10);
                    }

                    FlowMeter->Point.IsRageFree =
						GetIntAttribute("IsRageFree", sampleNode2, 0);

                    FlowMeter->Point.Series =
						GetIntAttribute("Series", sampleNode2, 2);

                    GetAttribute("ProtocolNumTitle", rootNode);

                    if (FlowMeter->Point.Hash == PointHash) {
                        pnt =  FlowMeter->Point;
                    }

					FlowMeter->AddEmptyPoint(FlowMeter->Point);
                }


            }


              FlowMeter->Point = FlowMeter->GetPoint(PointHash);

        }
        sampleNode2 = sampleNode->ChildNodes->FindNode("DataPoints");

        PointsSize = sampleNode2->Attributes["DataPointsCount"];

        for (int i = 0; i < PointsSize; i++) {
            sampleNode2 =
                sampleNode->ChildNodes->FindNode("DataPoint" + IntToStr(i));

            if (sampleNode2 != NULL) {
                FlowMeter->DataPoint.Name = GetAttribute("Name", sampleNode2);
                FlowMeter->DataPoint.EtlName = GetAttribute("EtlName", sampleNode2);

                FlowMeter->DataPoint.Date = GetAttribute("Date", sampleNode2);
                FlowMeter->DataPoint.Comment =
                    GetAttribute("Comment", sampleNode2);

                FlowMeter->DataPoint.Qt = GetAttribute("Qt", sampleNode2);

                FlowMeter->DataPoint.Q = GetAttribute("Q", sampleNode2);

                FlowMeter->DataPoint.EtlCoef =
                    GetAttribute("EtlCoef", sampleNode2);

                FlowMeter->DataPoint.EtlTime =
                    GetAttribute("EtlTime", sampleNode2);

                FlowMeter->DataPoint.EtlVolume =
                    GetAttribute("EtlVolume", sampleNode2);

                FlowMeter->DataPoint.EtlMass =
                    GetAttribute("EtlMass", sampleNode2);

                FlowMeter->DataPoint.EtlImp =
                    GetAttribute("EtlImp", sampleNode2);

                FlowMeter->DataPoint.EtlTemp =
                    GetAttribute("EtlTemp", sampleNode2);

                FlowMeter->DataPoint.EtlPres =
                    GetAttribute("EtlPres", sampleNode2);

                FlowMeter->DataPoint.EtlTempAir =
                    GetAttribute("EtlTempAir", sampleNode2);

                FlowMeter->DataPoint.EtlTempAir =
                    GetAttribute("EtlTempAir", sampleNode2);

                FlowMeter->DataPoint.EtlPresAir =
                    GetAttribute("EtlPresAir", sampleNode2);

                FlowMeter->DataPoint.EtlHumidity =
                    GetAttribute("EtlHumidity", sampleNode2);

                FlowMeter->DataPoint.Time = GetAttribute("Time", sampleNode2);

                FlowMeter->DataPoint.Volume =
                    GetAttribute("Volume", sampleNode2);

                FlowMeter->DataPoint.Imp = GetAttribute("Imp", sampleNode2);

                FlowMeter->DataPoint.Mass = GetAttribute("Mass", sampleNode2);



                FlowMeter->DataPoint.VolumeMeter =
                    GetAttribute("VolumeMeter", sampleNode2);

                FlowMeter->DataPoint.MassMeter =
                    GetAttribute("MassMeter", sampleNode2);

                FlowMeter->DataPoint.Temp = GetAttribute("Temp", sampleNode2);

                FlowMeter->DataPoint.Pres = GetAttribute("Pres", sampleNode2);

                FlowMeter->DataPoint.TempAir =
                    GetAttribute("TempAir", sampleNode2);

                FlowMeter->DataPoint.PresAir =
                    GetAttribute("PresAir", sampleNode2);

                FlowMeter->DataPoint.Humidity =
                    GetAttribute("Humidity", sampleNode2);


                FlowMeter->DataPoint.Density =
                    GetAttribute("Density", sampleNode2);

                FlowMeter->DataPoint.EtlDensity =
                    GetAttribute("EtlDensity", sampleNode2);

                FlowMeter->DataPoint.Error = GetAttribute("Error", sampleNode2);

                FlowMeter->DataPoint.ErrorMeter = GetAttribute("ErrorMeter", sampleNode2);

                FlowMeter->DataPoints.push_back(FlowMeter->DataPoint);
            }
        }

       } else {
            Result = "Файл пустой или поврежден";
            throw Exception(Result);
        }

        if (FlowMeter->Active == 1)
        {
		   FlowMeter->SetActiveTestMeter();
        }
    }

    /* }	else
	{

				Result = "Версия не может быть обработана";
				throw Exception(Result);
 *///	}

    {
        return ActiveFlowMeter;
    }
}

void TFlowMeter::SortEtalons()
{
    // Сортировка вектора по свойству DN
    std::sort(Etalons.begin(), Etalons.end(),
		[](TFlowMeter* a, TFlowMeter* b) { return a->FlowMax < b->FlowMax; });
}

void TFlowMeter::SortPoints()
{
    // Сортировка вектора по свойству расход
    std::sort(Points.begin(), Points.end(),
		[](tPoint a, tPoint b) { return a.Q < b.Q; });
}

void TFlowMeter::SortFlowMeters()
{
    // Сортировка вектора по свойству DN
	std::sort(FlowMeters.begin(), FlowMeters.end(),
		[](TFlowMeter* a, TFlowMeter* b) { return a->FlowMax < b->FlowMax; });
}

void TFlowMeter::AddToList()
{
    if (IsEtalon) {
        //Etalons.insert(Etalons.begin(), this);
          	 Etalons.push_back(this);

    } else {
       // FlowMeters.insert(FlowMeters.begin(), this);
        FlowMeters.push_back(this);
    }
}

void TFlowMeter::StaticInit(THscDevice* HSCDev)
{
    FlowMeters.clear();
    sHSC = HSCDev;
}

bool TFlowMeter::GetTestMeter(int Hash, TFlowMeter*& OutFlowMeter)
{
    for (int j = 0; j < FlowMeters.size(); j++) {
        if (FlowMeters[j]->Hash == Hash) {
            OutFlowMeter = FlowMeters[j];
            return true;
        }
    }

    return false;
}

TFlowMeter* TFlowMeter::GetEtalon(int Hash)
{

    if (Etalons.size() > 0) {
        for (int j = 0; j < Etalons.size(); j++) {
            if (Etalons[j]->Hash == Hash) {
                return Etalons[j];
            }
        }
    }

    return nullptr;
}

void TFlowMeter::SetActiveEtalon()
{
       if (ActiveEtalon!=nullptr) {
          ActiveEtalon->Active = 0;
          //UnRestoreValues();
       }


        if (Hash != 0) {
			ActiveEtalonHash = Hash;
			ActiveEtalon = this;
            Active = 1;
            RestoreValues();
          //  SetInitalDim();
            SetEtalonPoint(Point);
		}
}

void TFlowMeter::SetActiveEtalon(TFlowMeter* FlowMeter)
{
       if (ActiveEtalon!=nullptr) {
          ActiveEtalon->Active = 0;
        //  FlowMeter->UnRestoreValues();
       }

        if (FlowMeter->Hash != 0) {
			ActiveEtalonHash = FlowMeter->Hash;
			ActiveEtalon = FlowMeter;
            FlowMeter->Active = 1;
            FlowMeter->RestoreValues();
          //  FlowMeter->SetInitalDim();
            FlowMeter->SetEtalonPoint(Point);
		}

}

void TFlowMeter::SetActiveTestMeter()
{
      if (ActiveFlowMeter!=nullptr) {
         ActiveFlowMeter->Active = 0;
          //UnRestoreValues();
      }

		if (Hash != 0) {
			ActiveFlowMeterHash = Hash;
			ActiveFlowMeter = this;
            Active = 1;
            RestoreValues();
           // SetInitalDim();
            SetEtalonPoint(Point);
		}


 //  SetInitalDim();

   if (OnChangedTestMeter!=nullptr) {
		OnChangedTestMeter();
   }

}

TFlowMeter* TFlowMeter::GetActiveEtalon()
{
    if (ActiveEtalon != nullptr) {
        return ActiveEtalon;
    }
    if (ActiveEtalonHash != 0) {
        for (int j = 0; j < Etalons.size(); j++) {
            if (Etalons[j]->Hash == ActiveEtalonHash) {
                ActiveEtalon = Etalons[j];
                return Etalons[j];
            }
        }
        ActiveEtalonHash = 0;
    }

    if (Etalons.size() > 0) {
        ActiveEtalon = Etalons[0];
        ActiveEtalonHash = Etalons[0]->Hash;
        return ActiveEtalon;
    } else {
        ActiveEtalon = new TFlowMeter(sHSC, true);
        ActiveEtalonHash = ActiveEtalon->Hash;
        return ActiveEtalon;
    }

    return nullptr;
}

TFlowMeter* TFlowMeter::GetActiveFlowMeter()
{
    for (int j = 0; j < FlowMeters.size(); j++) {
        if (FlowMeters[j]->Hash == ActiveFlowMeter->Hash) {
            return FlowMeters[j];
        }
    }

    return nullptr;
}

double TFlowMeter::GetVolumeError(void)
{
    double error = 0;

    if (EtalonMeter != nullptr) {

    double etlValue = EtalonMeter->ValueVolume->GetDoubleValue();
    double testValue = ValueVolume->GetDoubleValue();

    error =   RelativeError(etlValue, testValue);
    }

    return error;
}

double TFlowMeter::GetMassError(void)
{
    double error = 0;

    if (EtalonMeter != nullptr) {

    double etlValue = EtalonMeter->ValueMass->GetDoubleValue();
    double testValue = ValueMass->GetDoubleValue();

    error =   RelativeError(etlValue, testValue);

    }

    return error;
}

void TFlowMeter::SetEtalon(TFlowMeter* Etalon)
{

    if (Etalon != nullptr) {
    EtalonMeter = Etalon;
        if (ValueVolumeError != nullptr) {
            ValueVolumeError->ValueEtalon = EtalonMeter->ValueVolume;
            ValueMassError->ValueEtalon = EtalonMeter->ValueMass;
            ValueError->ValueEtalon = EtalonMeter->ValueVolume;
        }
    }
}

void TFlowMeter::SetMeterFlowType(eMeterFlowType meterFlowType)
{
    MeterFlowType = meterFlowType;

  //  	WEIGHTS_TYPE = 0,    //Весовое устройство
  //	WEIGHTS_VOLUME_FLOWMETER_TYPE = 1, //Весовое устройство + ОР
  //	WEIGHTS_MASS_FLOWMETER_TYPE = 2, // Весовое устройство + МР
  //	MASS_FLOWMETER_TYPE = 3, //Массовый расходомер
 //	VOLUME_FLOWMETER_TYPE = 4, //Объемный расходомер
  //	TANK_TYPE = 5, // Мерник


	if (MeterFlowType == WEIGHTS_TYPE)
	{
		FlowTypeName =   "Весовое устройство";

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = ValueMassCoef;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = ValueDensity;

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = nullptr;
		ValueMassCoef->ValueBaseDevider = nullptr;
		ValueMassCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::INDEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::DEPENDENT;

		ValueCoef = ValueMassCoef;

		ValueQuantity = ValueMass;
		ValueFlow = ValueMassFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}

		else if (MeterFlowType == WEIGHTS_VOLUME_FLOWMETER_TYPE)
	{
				FlowTypeName =   "Весовое устройство + ОР";
		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = ValueMassCoef;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = ValueDensity;

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = nullptr;
		ValueMassCoef->ValueBaseDevider = nullptr;
		ValueMassCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::INDEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::DEPENDENT;

		ValueCoef = ValueMassCoef;

		ValueQuantity = ValueMass;
		ValueFlow = ValueMassFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}

	else if (MeterFlowType == WEIGHTS_MASS_FLOWMETER_TYPE) {

		FlowTypeName =   "Весовое устройство + МР";

		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = ValueMassCoef;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = ValueDensity;

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = nullptr;
		ValueMassCoef->ValueBaseDevider = nullptr;
		ValueMassCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::INDEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::DEPENDENT;

		ValueCoef = ValueMassCoef;


		ValueQuantity = ValueMass;
		ValueFlow = ValueMassFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}
		else if (MeterFlowType == MASS_FLOWMETER_TYPE) {

		FlowTypeName =   "Массовый расходомер";


		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = ValueMassCoef;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = ValueDensity;

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = nullptr;
		ValueMassCoef->ValueBaseDevider = nullptr;
		ValueMassCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::INDEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::DEPENDENT;

		ValueCoef = ValueMassCoef;


		ValueQuantity = ValueMass;
		ValueFlow = ValueMassFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}

	else if (MeterFlowType == VOLUME_FLOWMETER_TYPE)
	{
				FlowTypeName =   "Объемный расходомер";

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = ValueVolumeCoef;
		ValueMassCoef->ValueBaseDevider = ValueDensity;
		ValueMassCoef->ValueRate = nullptr;

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = nullptr;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::DEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::INDEPENDENT;

		ValueVolumeCoef->ValueType = CONST_TYPE;
		ValueMassCoef->ValueType = CONST_TYPE;

		ValueCoef = ValueVolumeCoef;

		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}

		else if (MeterFlowType == 	TANK_TYPE)
	{
				FlowTypeName =   "Мерник";

		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

		ValueMassCoef->ValueCorrection = nullptr;
		ValueMassCoef->ValueBaseMultiplier = ValueVolumeCoef;
		ValueMassCoef->ValueBaseDevider = ValueDensity;
		ValueMassCoef->ValueRate = nullptr;

		ValueVolumeCoef->ValueCorrection = nullptr;
		ValueVolumeCoef->ValueBaseMultiplier = nullptr;
		ValueVolumeCoef->ValueBaseDevider = nullptr;
		ValueVolumeCoef->ValueRate = nullptr;

		ValueMassCoef->DependenceType = EDEPTYPE::DEPENDENT;
		ValueVolumeCoef->DependenceType = EDEPTYPE::INDEPENDENT;

		ValueVolumeCoef->ValueType = CONST_TYPE;
		ValueMassCoef->ValueType = CONST_TYPE;

		ValueCoef = ValueVolumeCoef;

		ValueQuantity = ValueVolume;
		ValueFlow = ValueVolumeFlow;

        ValueVolume->UpdateType = HAND_TYPE;
        ValueMass->UpdateType   = HAND_TYPE;
	}

    if (IsEtalon) {
       ValueVolume->UpdateType = ONLINE_TYPE;
       ValueMass->UpdateType   = ONLINE_TYPE;
    }


}

void TFlowMeter::SetMeterFlowType(UnicodeString meterFlowType)
{


  //  	WEIGHTS_TYPE = 0,    //Весовое устройство
  //	WEIGHTS_VOLUME_FLOWMETER_TYPE = 1, //Весовое устройство + ОР
  //	WEIGHTS_MASS_FLOWMETER_TYPE = 2, // Весовое устройство + МР
  //	MASS_FLOWMETER_TYPE = 3, //Массовый расходомер
 //	VOLUME_FLOWMETER_TYPE = 4, //Объемный расходомер
  //	TANK_TYPE = 5, // Мерник


	if (meterFlowType == "Весовое устройство")
	{
        SetMeterFlowType(WEIGHTS_TYPE);
	}

		else if (meterFlowType == "Весовое устройство + ОР")
	{
        SetMeterFlowType(WEIGHTS_VOLUME_FLOWMETER_TYPE);
	}

	else if (meterFlowType == "Весовое устройство + МР") {

        SetMeterFlowType(WEIGHTS_MASS_FLOWMETER_TYPE);
	}
		else if (meterFlowType == "Массовый расходомер") {

        SetMeterFlowType(MASS_FLOWMETER_TYPE);
	}

	else if (meterFlowType == "Объемный расходомер")
	{
        SetMeterFlowType(VOLUME_FLOWMETER_TYPE);

	}

		else if (meterFlowType == 	"Мерник")
	{
        SetMeterFlowType(TANK_TYPE);
	}
}

UnicodeString TFlowMeter::GetMeterFlowType()
	{
       return FlowTypeName;
    }

void TFlowMeter::SetAsEtalon()
{
    if (TSettingsClass::EtalonCHNum > 0) {
        EtalonMeter->SetChannel(TSettingsClass::EtalonCHNum);
    } else {
        EtalonMeter->SetChannel(3);
    }

    EtalonMeter->Name = "Etalon";
    EtalonMeter->IsEtalon = true;

	EtalonMeter->SetMeterFlowType(MASS_FLOWMETER_TYPE);

    EtalonMeter->SetKoef(100);
}
// Расчёт времени до достижения предела по объему в мс
int TFlowMeter::TimeToEndVolumeLimit(
    float pointVolume, float DelayCoef, float TimeCoef)
{
    float add_volume = 0, volume = 0, add_time = 0, flow;

    flow = ValueFlow->GetFloatValue("л/с"); //Получаем л/с
    volume = ValueVolume->GetFloatValue();
    //Прогноз по объему на следующую секунду в л
    add_volume = volume + flow;
    pointVolume = pointVolume - DelayCoef * flow;

    if ((add_volume > pointVolume) && (pointVolume > 0)) {
        add_time = ((pointVolume - volume) / flow);
        if (add_time < 0) {
            return 1;
        }
        add_time = add_time * 1000;
        add_time = add_time * TimeCoef;
        return add_time;
    }

    return 0;
}

UnicodeString TFlowMeter::JSonConvert(TFlowMeter* AFlowMeter)
{
    bool success = true;
    int k = 0, l = 0;
    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TJSONArray* jDevices;
    TJSONArray* jPoints;

    TJSONArray* jDataPoints;
    TJSONObject* jDevice;
    TJSONObject* jObject;

    // TJSONObject *jObject = new TJSONObject();
    jObject = new TJSONObject();

    TJSONObject* jPoint = new TJSONObject();
    TJSONObject* jDataPoint;
    //
    // Создадим главную ветку и добавим узел об устройстве

    jObject->AddPair("VER", XMLVER);

    // CheckStoragePermission_(this);

    if (!FlowMeters.empty()) {
        k = FlowMeters.size();
        while (l < FlowMeters.size()) {
            if ((FlowMeters[l]->SerialNum == "") &&
                (FlowMeters[l]->DataPoints.empty())) {
                TFlowMeter::FlowMeters.erase(
                    TFlowMeter::FlowMeters.begin() + l);

            } else {
                l = l + 1;
            }
        }

        jObject->AddPair(
            new TJSONPair("DeviceCount", IntToStr((int)FlowMeters.size())));

        jDevices = new TJSONArray();
        jObject->AddPair("Devices", jDevices);

        for (int j = 0; j < FlowMeters.size(); j++) {
            jDevice = new TJSONObject();
            jDevice->AddPair(new TJSONPair("Device Num", IntToStr(j)));

            {
                jDevice->AddPair(
                    new TJSONPair("ID_Device", FlowMeters[j]->Hash));
                jDevice->AddPair(
                    new TJSONPair("ID_Order", FlowMeters[j]->ID_Order));
                jDevice->AddPair(
                    new TJSONPair("miOwner", FlowMeters[j]->miOwner));

                if (AFlowMeter == nullptr) {
                    FlowMeters[j]->Active = 0;
                } else if (AFlowMeter->Hash == FlowMeters[j]->Hash) {
                    FlowMeters[j]->Active = 1;
                } else {
                    FlowMeters[j]->Active = 0;
                }

                jDevice->AddPair(
                    new TJSONPair("Active", IntToStr(FlowMeters[j]->Active)));
                jDevice->AddPair(
                    new TJSONPair("DeviceType", FlowMeters[j]->DeviceType));
                jDevice->AddPair(
                    new TJSONPair("manufactureNum", FlowMeters[j]->SerialNum));
                jDevice->AddPair(new TJSONPair(
                    "mitypeNumber", FlowMeters[j]->CertificateNum));
                jDevice->AddPair(
                    new TJSONPair("docTitle", FlowMeters[j]->docTitle));
                jDevice->AddPair(new TJSONPair("means", FlowMeters[j]->means));

                jDevice->AddPair(
                    new TJSONPair("Modification", FlowMeters[j]->Modification));

                jDevice->AddPair(new TJSONPair(
                    "CheckType", IntToStr(FlowMeters[j]->CheckType)));
                jDevice->AddPair(new TJSONPair("DN", FlowMeters[j]->DN));

                jDevice->AddPair(
                    new TJSONPair("validDate", FlowMeters[j]->validDate));

                jDevice->AddPair(
                    new TJSONPair("Kp", FloatToStr(FlowMeters[j]->Kp)));
                jDevice->AddPair(
                    new TJSONPair("FlowMax", FloatToStr(FlowMeters[j]->FlowMax)));

                jDevice->AddPair(
                    new TJSONPair("temperature", FlowMeters[j]->temperature));
                jDevice->AddPair(
                    new TJSONPair("pressure", FlowMeters[j]->pressure));
                jDevice->AddPair(
                    new TJSONPair("hymidity", FlowMeters[j]->hymidity));
                jDevice->AddPair(
                    new TJSONPair("validDate", FlowMeters[j]->validDate));
                jDevice->AddPair(
                    new TJSONPair("validDate", FlowMeters[j]->validDate));

                jDevice->AddPair(
                    new TJSONPair("Result", FlowMeters[j]->Result));

                jDevice->AddPair(new TJSONPair("Data1", ""));
                jDevice->AddPair(new TJSONPair("Data2", ""));
                jDevice->AddPair(new TJSONPair("Data3", ""));

                jPoints = new TJSONArray();

                jDevice->AddPair(
                    "PointsCount", IntToStr((int)FlowMeters[j]->Points.size()));
                jDevice->AddPair("Points", jPoints);

                if (!FlowMeters[j]->Points.empty()) {
                    for (int i = 0; i < FlowMeters[j]->Points.size(); i++) {
                        jPoint = new TJSONObject();

                        jPoint->AddPair("Point Num", IntToStr(i));

                        jPoint->AddPair("Name", FlowMeters[j]->Points[i].Name);
                        jPoint->AddPair(
                            "Qrate", FloatToStrF(FlowMeters[j]->Points[i].Qrate,
                                         ffNumber, 10, 2));
                        jPoint->AddPair(
                            "Q", FloatToStrF(FlowMeters[j]->Points[i].Q,
                                     ffNumber, 10, 2));
                        jPoint->AddPair("Volume",
                            FloatToStrF(FlowMeters[j]->Points[i].Volume,
                                ffNumber, 10, 2));
                        jPoint->AddPair(
                            "Time", FloatToStrF(FlowMeters[j]->Points[i].Time,
                                        ffNumber, 10, 0));
                        jPoint->AddPair(
                            "Error", FloatToStrF(FlowMeters[j]->Points[i].Error,
                                         ffNumber, 10, 2));

                        jPoints->AddElement(jPoint);
                    }
                }

                jDataPoints = new TJSONArray();
                jDevice->AddPair("DataPointsCount",
                    IntToStr((int)FlowMeters[j]->DataPoints.size()));
                jDevice->AddPair("DataPoints", jDataPoints);

                if (!FlowMeters[j]->DataPoints.empty()) {
                    for (int i = 0; i < FlowMeters[j]->DataPoints.size(); i++) {
                        jDataPoint = new TJSONObject();

                        jDataPoint->AddPair("DataPoint", IntToStr(i));

                        jDataPoint->AddPair(
                            "Comment", FlowMeters[j]->DataPoints[i].Comment);
                        /*
					jDataPoint->AddPair("Q",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Q, ffNumber,
						10, 2));
					jDataPoint->AddPair("Time",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Time, ffNumber,
						10, 0));
					jDataPoint->AddPair("Imp",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Imp, ffNumber,
						10, 2));
					jDataPoint->AddPair("EtlVolume",
						FloatToStrF(FlowMeters[j]->DataPoints[i].EtlVolume,
						ffNumber, 10, 2));
					jDataPoint->AddPair("Volume",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Volume,
						ffNumber, 10, 2));
					jDataPoint->AddPair("VolumeBefore",
						FloatToStrF(FlowMeters[j]->DataPoints[i].VolumeBefore,
						ffNumber, 10, 2));
					jDataPoint->AddPair("VolumeAfter",
						FloatToStrF(FlowMeters[j]->DataPoints[i].VolumeAfter,
						ffNumber, 10, 2));


					jDataPoint->AddPair("Temp",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Temp, ffNumber,
						10, 2));

					 jDataPoint->AddPair("Pres",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Pres, ffNumber,
						10, 2));

					 jDataPoint->AddPair("TempAir",
						FloatToStrF(FlowMeters[j]->DataPoints[i].TempAir, ffNumber,
						10, 2));

					 jDataPoint->AddPair("PresAir",
						FloatToStrF(FlowMeters[j]->DataPoints[i].PresAir, ffNumber,
						10, 2));

					 jDataPoint->AddPair("Humidity",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Humidity, ffNumber,
						10, 2));

					 jDataPoint->AddPair("Data",
						FlowMeters[j]->DataPoints[i].Date);
						//FlowMeters[j]->

					jDataPoint->AddPair("Error",
						FloatToStrF(FlowMeters[j]->DataPoints[i].Error, ffNumber,
						10, 2));
						 */
                        jDataPoints->AddElement(jDataPoint);
                    }
                }
            }

            jDevices->AddElement(jDevice);
        }

    } else {
    }

    return jObject->ToString();
}

void TFlowMeter::ApiSent()
{
    int k = 0, l = 0;

    if (!FlowMeters.empty()) {
        k = FlowMeters.size();
        while (l < FlowMeters.size()) {
            if (FlowMeters[l]->SendStatus == 1) //"Отправляется")
            {
                FlowMeters[l]->SendStatus = 2; //"Отправлен";
            }
            l = l + 1;
        }
    }
}

int TFlowMeter::ApiCheckResult()
{
    float fl = 0;
    bool success = false;
    int k = 0, l = 0;

    if (!FlowMeters.empty()) {
        k = FlowMeters.size();
        while (l < FlowMeters.size()) {
            if ((FlowMeters[l]->SerialNum == "") &&
                (FlowMeters[l]->DataPoints.empty())) {
                TFlowMeter::FlowMeters.erase(
                    TFlowMeter::FlowMeters.begin() + l);

            } else {
                l = l + 1;
            }
        }

        for (int j = 0; j < FlowMeters.size(); j++) {
            int st = FlowMeters[j]->SendStatus;
            System::UnicodeString res = FlowMeters[j]->Result;

            if ((res == "Годен") && (st != 2)) {
                success = true;
            } else if ((FlowMeters[j]->Result == "Не годен") &&
                       (FlowMeters[j]->SendStatus != 2))
            {
                return 1;

            } else {
            }
        }
    } else {
        return -1;
    }

    if (success != true) {
        return -1;
    }

    return 0;
}

UnicodeString TFlowMeter::ApiConvert()
{
    float fl = 0;
    bool success = true;
    int k = 0, l = 0;
    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TJSONArray* jDevices;
    TJSONArray* jPoints;
    TJSONArray* jDataPoints;

    TJSONObject* jDevice;
    TJSONObject* jObject;

    // TJSONObject *jObject = new TJSONObject();
    jObject = new TJSONObject();

    TJSONObject* jPoint = new TJSONObject();
    TJSONObject* jDataPoint;
    //
    // Создадим главную ветку и добавим узел об устройстве

    // CheckStoragePermission_(this);

    if (!FlowMeters.empty()) {
        k = FlowMeters.size();
        while (l < FlowMeters.size()) {
            if ((FlowMeters[l]->SerialNum == "") &&
                (FlowMeters[l]->DataPoints.empty())) {
                TFlowMeter::FlowMeters.erase(
                    TFlowMeter::FlowMeters.begin() + l);

            } else {
                l = l + 1;
            }
        }

        jObject->AddPair("emai", TSettingsClass::eMail);

        jDevices = new TJSONArray();
        jObject->AddPair("poverkas", jDevices);

        for (int j = 0; j < FlowMeters.size(); j++) {
            if (TSettingsClass::DataDestination == 4) {
                FlowMeters[j]->Data1 = TSettingsClass::TempData;
            }

            if (((FlowMeters[j]->Result == "Годен") ||
                    (FlowMeters[j]->Result == "Не годен")) &&
                (FlowMeters[j]->SendStatus != 2))
            {
                FlowMeters[j]->SendStatus = 1;

                // TJSONObject *jObject = new TJSONObject();
                jDevice = new TJSONObject();

                TJSONObject* jPoint = new TJSONObject();
                TJSONObject* jDataPoint;
                //
                // Создадим главную ветку и добавим узел об устройстве

                jDevice->AddPair(new TJSONPair("order_id",
                    new TJSONNumber(StrToInt_(FlowMeters[j]->ID_Order))));
                //	  jDevice->AddPair(new TJSONPair("order_id", new TJSONNumber(900)));

                jDevice->AddPair("mi_owner", FlowMeters[j]->miOwner);
                jDevice->AddPair("active", IntToStr(FlowMeters[j]->Active));
                jDevice->AddPair("device_type", FlowMeters[j]->DeviceType);
                jDevice->AddPair("manufacture_num", FlowMeters[j]->SerialNum);
                jDevice->AddPair(
                    "mitype_number", FlowMeters[j]->CertificateNum);

                jDevice->AddPair("Title", TSettingsClass::Title);

                jDevice->AddPair("doc_title", FlowMeters[j]->docTitle);
                jDevice->AddPair("Adress", FlowMeters[j]->Adress);
                jDevice->AddPair("AllMeans", TSettingsClass::AllMeans);

                //!!!Верное	jDevice->AddPair("ProtocolNum", TSettingsClass::ProtocolNumTitle+IntToStr(TSettingsClass::ProtocolNum++));
                jDevice->AddPair("ProtocolNum",
                    new TJSONNumber(TSettingsClass::ProtocolNum++));

                jDevice->AddPair("means", TSettingsClass::Means);

                jDevice->AddPair("modification", FlowMeters[j]->Modification);
                jDevice->AddPair(new TJSONPair(
                    "dn", new TJSONNumber(StrToInt_(FlowMeters[j]->DN))));
                jDevice->AddPair("next_verification", FlowMeters[j]->validDate);
                jDevice->AddPair("vrf_date", FlowMeters[j]->vrfDate);
                jDevice->AddPair(
                    "check_type", "2"); //IntToStr(FlowMeters[j]->CheckType));
                jDevice->AddPair("kp", FloatToStr(FlowMeters[j]->Kp));
                jDevice->AddPair("q_max", FloatToStr(FlowMeters[j]->FlowMax));
                jDevice->AddPair("temperature", FlowMeters[j]->temperature);
                jDevice->AddPair("temp_water", FlowMeters[j]->tempWater);
                jDevice->AddPair("pressure", FlowMeters[j]->pressure);
                jDevice->AddPair("hymidity", FlowMeters[j]->hymidity);
                jDevice->AddPair("result", FlowMeters[j]->Result);
                jDevice->AddPair(
                    "year_production", FlowMeters[j]->year_production);
                jDevice->AddPair("data1", FlowMeters[j]->Data1);
                jDevice->AddPair("data2", FlowMeters[j]->Data2);
                jDevice->AddPair("data3", FlowMeters[j]->Data3);
                jDevice->AddPair(new TJSONPair("doc_number",
                    new TJSONNumber(StrToInt_(FlowMeters[j]->doc_number))));
                jDevice->AddPair("sign_cipher", TSettingsClass::SignCipher);
                jDevice->AddPair("porveritel_fio", TSettingsClass::Performer);

                jPoints = new TJSONArray();

                //jDevice->AddPair("data_points",IntToStr((int) Points.size()));
                jDevice->AddPair("data_points", jPoints);

                if (!FlowMeters[j]->DataPoints.empty()) {
                    vector<tDataPoint> dataPoints;

                    dataPoints = FlowMeters[j]->SortDataVector(
                        FlowMeters[j]->UsedDataPoints, -1, 0, 0);

                    for (int i = 0; i < dataPoints.size(); i++) {
                        jPoint = new TJSONObject();

                        fl = dataPoints[i].Q / 1000;
                        jPoint->AddPair("q", FloatToStrF(fl, ffNumber, 10, 5));
                        /*
					jPoint->AddPair("time",
						FloatToStrF(dataPoints[i].Time, ffNumber,
						10, 0));
					jPoint->AddPair("imp",
						FloatToStrF(dataPoints[i].Imp, ffNumber,
						10, 0));
					 */
                        jPoint->AddPair("time", dataPoints[i].Time);
                        jPoint->AddPair("imp", dataPoints[i].Imp);

                        fl = dataPoints[i].EtlVolume / 1000;

                        jPoint->AddPair(
                            "etl_volume", FloatToStrF(fl, ffNumber, 10, 5));

                        fl = dataPoints[i].Volume / 1000;

                        jPoint->AddPair(
                            "volume", FloatToStrF(fl, ffNumber, 10, 5));
                        /*
					jPoint->AddPair("volume_before",
						FloatToStrF(dataPoints[i].VolumeBefore, ffNumber,
						10, 5));
					jPoint->AddPair("volume_after",
						FloatToStrF(dataPoints[i].VolumeAfter, ffNumber,
						10, 5));



					jPoint->AddPair("temp",
						FloatToStrF(dataPoints[i].Temp, ffNumber,
						10, 2));
					jPoint->AddPair("pres",
						FloatToStrF(dataPoints[i].Pres, ffNumber,
						10, 2));
					jPoint->AddPair("point_humidity",
						FloatToStrF(dataPoints[i].Humidity, ffNumber,
						10, 2));
					jPoint->AddPair("temp_air",
						FloatToStrF(dataPoints[i].TempAir, ffNumber,
						10, 2));
					jPoint->AddPair("data",
						" ");
					jPoint->AddPair("error",
						FloatToStrF(dataPoints[i].Error, ffNumber,
						10, 2));   */

                        jPoints->AddElement(jPoint);
                    }
                }

                jDevices->AddElement(jDevice);
            }
        }

    } else {
    }

    return jObject->ToString();
}

UnicodeString TFlowMeter::JSonConvert()
{
    bool success = true;
    int k = 0, l = 0;
    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TJSONArray* jDevices;
    TJSONArray* jPoints;

    TJSONArray* jDataPoints;
    TJSONObject* jDevice;
    TJSONObject* jObject;

    // TJSONObject *jObject = new TJSONObject();
    jObject = new TJSONObject();

    TJSONObject* jPoint = new TJSONObject();
    TJSONObject* jDataPoint;
    //
    // Создадим главную ветку и добавим узел об устройстве
    jObject->AddPair("emai", TSettingsClass::eMail);
    jObject->AddPair(
        new TJSONPair("order_id", new TJSONNumber(StrToInt_(ID_Order))));
    jObject->AddPair("mi_owner", miOwner);
    jObject->AddPair("active", IntToStr(Active));
    jObject->AddPair("device_type", DeviceType);
    jObject->AddPair("manufacture_num", SerialNum);
    jObject->AddPair("mitype_number", CertificateNum);
    jObject->AddPair("doc_title", docTitle);
    jObject->AddPair("means", means);
    jObject->AddPair("modification", Modification);
    jObject->AddPair(new TJSONPair("dn", new TJSONNumber(StrToInt_(DN))));
    jObject->AddPair("next_verification", validDate);
    jObject->AddPair("vrf_date", vrfDate);
    jObject->AddPair("check_type", IntToStr(CheckType));
    jObject->AddPair("kp", FloatToStr(Kp));
    jObject->AddPair("q_max", FloatToStr(FlowMax));
    jObject->AddPair("temperature", temperature);
    jObject->AddPair("temp_water", tempWater);
    jObject->AddPair("pressure", pressure);
    jObject->AddPair("hymidity", hymidity);
    jObject->AddPair("result", Result);
    jObject->AddPair("year_production", year_production);
    jObject->AddPair("data1", year_production);
    jObject->AddPair("data2", year_production);
    jObject->AddPair("data3", year_production);
    jObject->AddPair("doc_number", doc_number);
    jObject->AddPair("sign_cipher", sign_cipher);
    jObject->AddPair("porveritel_fio", porveritel_fio);

    jPoints = new TJSONArray();

    //jDevice->AddPair("data_points",IntToStr((int) Points.size()));
    jObject->AddPair("data_points", jPoints);

    if (!DataPoints.empty()) {
        for (int i = 0; i < Points.size(); i++) {
            jPoint = new TJSONObject();
            /*
				   jPoint->AddPair("q", FloatToStrF(DataPoints[i].Q, ffNumber,
						10, 2));

					jPoint->AddPair("time",
						FloatToStrF(DataPoints[i].Time, ffNumber,
						10, 0));
					jPoint->AddPair("imp",
						FloatToStrF(DataPoints[i].Imp, ffNumber,
						10, 0));
					jPoint->AddPair("etl_volume",
						FloatToStrF(DataPoints[i].EtlVolume, ffNumber,
						10, 0));
					jPoint->AddPair("volume",
					FloatToStrF(DataPoints[i].Volume, ffNumber,
						10, 0));
					jPoint->AddPair("volume_before",
						FloatToStrF(DataPoints[i].VolumeBefore, ffNumber,
						10, 0));
					jPoint->AddPair("volume_after",
						FloatToStrF(DataPoints[i].VolumeAfter, ffNumber,
						10, 0));
					jPoint->AddPair("temp",
						FloatToStrF(DataPoints[i].Temp, ffNumber,
						10, 0));
					jPoint->AddPair("pres",
						FloatToStrF(DataPoints[i].Pres, ffNumber,
						10, 0));
					jPoint->AddPair("point_humidity",
						FloatToStrF(DataPoints[i].Humidity, ffNumber,
						10, 0));
					jPoint->AddPair("temp_air",
						FloatToStrF(DataPoints[i].TempAir, ffNumber,
						10, 0));
					jPoint->AddPair("data",
						" ");
					jPoint->AddPair("error",
						FloatToStrF(DataPoints[i].Error, ffNumber,
						10, 0));
						 */
            jPoints->AddElement(jPoint);
        }
    }

    return jObject->ToString();
}

int TFlowMeter::GetCountInOrder(int iD_Order)
{
    int i = 0;

    for (int j = 0; j < FlowMeters.size(); j++) {
        if (FlowMeters[j]->ID_Order == iD_Order) {
            i = i + 1;
        }
    }

    return i;
}

bool TFlowMeter::IsFlowInPoint()
{
   return IsFlowInPoint((double)ValueFlow->GetDoubleValue());
}

bool TFlowMeter::IsFlowInPoint(tPoint point)
{
    return (IsFlowInPoint((double)ValueFlow->GetDoubleValue(), point));
}

bool TFlowMeter::IsFlowInPoint(TMeterValue* Value)
{
    return (IsFlowInPoint((double)Value->GetDoubleValue(), Point));
}

bool TFlowMeter::IsFlowInPoint(float Q)
{
    return (IsFlowInPoint(Q, Point));
}

bool TFlowMeter::IsFlowInPoint(double Q, tPoint point)
{
    double Qp, Q1, Q2;
    tPoint pnt = point;
    Qp = pnt.Q;

	if ((pnt.RageMinus >100)&&(pnt.RagePlus != 0)) {

	if ((Qp + Qp * (pnt.RagePlus / 100)) > Q)
	{
		return true;
	} else
	{
		return false;
	}

	}
	else if ((pnt.RageMinus!= 0)&&(pnt.RagePlus>100 )) {

	if ((Qp - Qp * (pnt.RageMinus / 100)) < Q)
	{
		return true;
	} else
	{
		return false;
	}

	}


	else if ((pnt.RageMinus != 0)&&(pnt.RagePlus != 0)) {
		Q1 = Qp - Qp * (pnt.RageMinus / 100);
		Q2 = Qp + Qp * (pnt.RagePlus / 100);

	}
	else if (pnt.Accuracy != 0) {
		Q1 = Qp - Qp * (pnt.Accuracy / 100);
		Q2 = Qp + Qp * (pnt.Accuracy / 100);
    } else {
        Q1 = Qp - Qp * 0.1;
        Q2 = Qp + Qp * 0.1;
    }

	if ((Q1 < Q) && (Q2 > Q)) {
		return true;
	} else {
        return false;
	}
}

UnicodeString TFlowMeter::GetEtalonState(void)
{
    if (IsEtalon) {
        return "true";
    } else {
        return "false";
    }
}

void TFlowMeter::SetEtalonState(UnicodeString state)
{
    if (state == "true") {
        IsEtalon = true;
    } else {
        IsEtalon = false;
    }
}

void TFlowMeter::Delete()
{
    int size, i = 0;
    size = FlowMeters.size();
    while (i < FlowMeters.size()) {
        if (FlowMeters[i]->Hash == Hash) {
            TFlowMeter::FlowMeters.erase(TFlowMeter::FlowMeters.begin() + i);
            return;
        } else {
            i = i + 1;
        }
    }

    //delete *this;
}

void TFlowMeter::DeleteHash(int Hash)
{
    int size, i = 0;
    int h1 = 0, h2 = 0;

    size = Etalons.size();
    if (size > 0)
        while (i < Etalons.size()) {
            h1 = Etalons[i]->Hash;

            if (h1 == Hash) {
                TFlowMeter::Etalons.erase(TFlowMeter::Etalons.begin() + i);
                return;
            } else {
                i = i + 1;
            }
		}

	i = 0;
    size = FlowMeters.size();
    if (size > 0)
        while (i < FlowMeters.size()) {
            h1 = FlowMeters[i]->Hash;

            if (h1 == Hash) {
                TFlowMeter::FlowMeters.erase(
                    TFlowMeter::FlowMeters.begin() + i);
                return;
            } else {
                i = i + 1;
            }
        }
}

void TFlowMeter::DeleteEtalonHash(int Hash)
{
    int size, i = 0;
    int h1 = 0, h2 = 0;

    size = Etalons.size();
    if (size > 0)
        while (i < Etalons.size()) {
            h1 = Etalons[i]->Hash;

            if (h1 == Hash) {
                TFlowMeter::Etalons.erase(TFlowMeter::Etalons.begin() + i);
                return;
            } else {
                i = i + 1;
            }
		}
}

bool TFlowMeter::SetImpCoef(UnicodeString K)
{
    float Kf = 0;

    if (TryStrToFloat_(K, Kf)) {
        if (Kf > 0) {
            SetImpCoef((double)Kf);
            return true;
        }
	}

    return false;
}

void TFlowMeter::SetImpCoef(double K)
{
      Kp = K;
}

void  TFlowMeter::SetInitalDim()
	{

	ValueVolumeFlow->SetDim(TSettingsClass::UnitsFlowRate);
	ValueMassFlow->SetDim(TSettingsClass::UnitsFlowRate);
	ValueMass->SetDim(TSettingsClass::UnitsMass);
	ValueVolume->SetDim(TSettingsClass::UnitsVolume);
	ValueMassCoef->SetDim(TSettingsClass::UnitsCoef);
	ValueVolumeCoef->SetDim(TSettingsClass::UnitsCoef);

	ValuePressure->SetDim(TSettingsClass::UnitsPress);
	ValueAirPressure->SetDim(TSettingsClass::UnitsAirPress);

	}

void TFlowMeter::SetOnChangedTestMeter(TOnChanged onChangedTestMeter)
	{
	  OnChangedTestMeter =  onChangedTestMeter;

    }

void TFlowMeter::CopyOrderDevices(int orderHash, int newOrderHash)
    {
        TFlowMeter* Meter;
        TFlowMeter* TestMeter;
        int size = TFlowMeter::FlowMeters.size();

        for (int j = 0; j < size; j++) {
            if (TFlowMeter::FlowMeters[j]->OrderHash == orderHash) {
                Meter = TFlowMeter::FlowMeters[j];
                TestMeter = new TFlowMeter(Meter);
                TestMeter->OrderHash = newOrderHash;
            }
        }
    }

int TFlowMeter::GetNewHash()
{
 int  maxHash = 0;

  if (IsEtalon) {

        for (int j = 0; j < Etalons.size(); j++)
           {
                  if (Etalons[j]->Hash>maxHash)
               {
                    maxHash = Etalons[j]->Hash;
               }
           }


  }  else
  {

     for (int j = 0; j < FlowMeters.size(); j++)
           {
                  if (FlowMeters[j]->Hash>maxHash)
               {
                    maxHash = FlowMeters[j]->Hash;
               }
           }
  }
           return maxHash + 1;
}

TFlowMeter*  TFlowMeter::FindEtalonPoint()
{
  tPoint pnt;
  tPoint pntLast;
  double Q = 0;
  double Qp = 0;
  double Q1 = 0;
  double diff1 = 0;
  double diff2 = 0;
  bool firstPoint = true;

  double Qpnt = Point.Q ;


   SortEtalons();

 for (int j = 0; j < Etalons.size(); j++)
 {
     if (Etalons[j]->Status!=0) {
        continue;
     }

     Etalons[j]->SortPoints();

      firstPoint = true;

    for (int i = 0; i < Etalons[j]->Points.size(); i++)
    {


        pnt = Etalons[j]->Points[i];
        Qp = pnt.Q;


        if ((Q < Qpnt )&&( Qpnt <= Qp))
        {

        if (!firstPoint) {

        diff1 = fabs(Q - Qpnt);
        diff2 = fabs(Qp - Qpnt);

           if (diff1<diff2) {
             pnt =  pntLast;
           }
        }

             SetActiveEtalon(Etalons[j]);
             Etalons[j]->SetEtalonPoint(pnt);
             return Etalons[j];

        }

        Q =  pnt.Q;
        pntLast = pnt;
        firstPoint = false;

    }

 }

     SetActiveEtalon(Etalons[Etalons.size()-1]);
     Etalons[Etalons.size()-1]->SetEtalonPoint(pnt);

     return  Etalons[Etalons.size()-1];

}

void TFlowMeter::ReCalcPointsFlowMax()
{
   double Flow, Time, Qrate, flow;

         for (int i = 0; i < Points.size(); i++)
     {
        flow = EtalonMeter->Points[i].Q ;

        Qrate = Points[i].Qrate;
        Flow = FlowMax * Qrate;
        Time = Points[i].Volume / Flow;

        Points[i].Q = Flow;
        Points[i].Time =  Time;
     }

}

void TFlowMeter::ReCalcPointsFactoryKp()
{
   double Flow, Time, Qrate;

         for (int i = 0; i < Points.size(); i++)
     {

        Points[i].Coef = FactoryKp;

     }

}

void TFlowMeter::SetFactoryKp(double factoryKp)
{
    if (FactoryKp == factoryKp) {
        return;
    }

    FactoryKp = factoryKp;
    SetImpCoef(factoryKp);

    for (int i = 0; i < Points.size(); i++) {
        Points[i].Coef = FactoryKp;
    }
}

void TFlowMeter::AutoFill(TFlowMeter* Meter)
{
    double f, Q;
    double Volume, Mass, Imp;
    double Qmetl, Qm, error, etlImp ;

    tDataPoint DataPoint;
    tPoint     Point;

      for (int i = 0; i < Meter->Points.size(); i++)
      {

	   Point =  Meter->Points[i];
       EtalonMeter = Meter->FindEtalonPoint();

      for (int j = 0; j <  Meter->Point.Series; j++) {

        DataPoint.DateTime = Now();
        DataPoint.Date  = FormatDateTime("dd.mm.yyyy hh:nn", Now());

        DataPoint.Qt =  Meter->ValueVolumeFlow->GetStrNum(Point.Q, "м3/ч");

        DataPoint.Q = RandStr(Point.Q, Point.Error/2);

         DataPoint.EtlCoef = EtalonMeter->Point.Coef;

        DataPoint.EtlTime = Point.Time;





        Mass =   Point.Q * Point.Time;
        Volume = Mass * EtalonMeter->ValueDensity->GetDoubleValue();

        DataPoint.EtlMass = FormatValue(Mass,0,Point.Error/2);
        DataPoint.EtlVolume = FormatValue(Volume,0,Point.Error/2);


        etlImp = Multiply(DataPoint.EtlMass, DataPoint.EtlCoef);

        DataPoint.EtlImp = FormatValue(etlImp,0,Point.Error);

        DataPoint.EtlTemp = RandStr(EtalonMeter->ValueTemperture->GetDoubleValue()+(i*0.5), 0.1);
        DataPoint.EtlPres =
            RandStr(EtalonMeter->ValuePressure->GetDoubleValue(), 0.2); //Давление
        DataPoint.EtlTempAir =
            RandStr(EtalonMeter->ValueAirTemperture->GetDoubleValue(), 0.2);
        DataPoint.EtlPresAir =
            RandStr(EtalonMeter->ValueAirPressure->GetDoubleValue(), 0.2); //Давление
        DataPoint.EtlHumidity =
           RandStr(EtalonMeter->ValueHumidity->GetDoubleValue(), 0.2);

        DataPoint.EtlDensity =  EtalonMeter->ValueDensity->GetStringValue();


        DataPoint.Time = RandStr(Point.Time, 0.01);



        DataPoint.Volume = RandStr(Volume, Point.Error/2);
        DataPoint.Imp = RandStr(etlImp, Point.Error/2);
        DataPoint.Mass = RandStr(Mass, Point.Error/2);

        DataPoint.VolumeMeter = RandStr(Volume, Point.Error/2);
        DataPoint.MassMeter = RandStr(Mass, Point.Error/2);

        DataPoint.Temp = RandStr(EtalonMeter->ValueTemperture->GetDoubleValue()+(i*0.5), 0.1);
        DataPoint.Pres = RandStr(EtalonMeter->ValuePressure->GetDoubleValue(), 0.2);
        DataPoint.TempAir =  RandStr(EtalonMeter->ValueAirTemperture->GetDoubleValue(), 0.2);
        DataPoint.PresAir = RandStr(EtalonMeter->ValueAirPressure->GetDoubleValue(), 0.2); //Давление
        DataPoint.Humidity = RandStr(EtalonMeter->ValueHumidity->GetDoubleValue(), 0.2);
        DataPoint.Density = RandStr(EtalonMeter->ValueDensity->GetDoubleValue(), 0.2);

        Qmetl = Relative(DataPoint.EtlMass, DataPoint.EtlTime);
        Qm = Relative(DataPoint.Mass, DataPoint.Time);
        error = RelativeError(Qmetl, Qm);


        DataPoint.Error = error;

        DataPoint.Comment = "AUTO";

        Meter->DataPoints.push_back(DataPoint);
           }
      }

        Meter->CheckFullStatus();
        SaveToFile(Meter, 0);

}

void TFlowMeter::SetFinalValuesHandle(double time, double imptotal, double coef)
{
    double imp, mass;

    TMeterValue::FinalValue = true;

    ValueTime->SetValue(time);

    if (time!=0) {
       imp = imptotal/time;
       ValueImp->SetValue(imp);
    }

    ValueImpTotal->SetValue(imptotal);

  //  mass =   imptotal / coef;

    if (ValueImpTotal->UpdateType != HAND_TYPE) {
     //ValueMass->SetValue(imptotal);
     //ValueMass->SetValue();
    } else
    {
    //  ValueMass->SetValue(mass);
      if (EtalonMeter!=nullptr){
        ValueImpTotal->SetValue(EtalonMeter->ValueImpTotal->GetDoubleValue());
      }
    }


    ValueCoef->SetValue(coef);

    ValueVolumeCoef->SetValue();
    ValueMassCoef->SetValue();

    ValueVolumeFlow->SetValue();
    ValueMassFlow->SetValue();

    if (ValueVolume->UpdateType != HAND_TYPE) {
      ValueVolume->SetValue();
    } else
    {
      if (EtalonMeter!=nullptr){
        ValueVolume->SetValue(EtalonMeter->ValueVolume->GetDoubleValue());
      }
    }

    if (ValueMass->UpdateType != HAND_TYPE) {
     ValueMass->SetValue();
    } else
    {
      if (EtalonMeter!=nullptr){
        ValueMass->SetValue(EtalonMeter->ValueMass->GetDoubleValue());
      }
    }





    ValueVolumeError->SetValue(GetVolumeError());
    ValueMassError->SetValue(GetMassError());

}

void TFlowMeter::SetFinalValuesHandle(double time, double imptotal)
{
    double imp, mass, volme, coefmass, coefvalue;

    TMeterValue::FinalValue = true;

    ValueTime->SetValue(time);

    if (time!=0) {
       imp = imptotal/time;
       ValueImp->SetValue(imp);
    }  else
    {
        return;
    }

    ValueImpTotal->SetValue(imptotal);

   //     coef = EtalonMeter->ValueMassCoef->GetDoubleValue();

  //  mass = volume * EtalonMeter->ValueDensity->GetDoubleValue();
  //  imptotal = coef * mass;

  //  mass =   imptotal / coef;

  /*  if (ValueImpTotal->UpdateType != HAND_TYPE) {
     //ValueMass->SetValue(imptotal);
     //ValueMass->SetValue();
    } else
    {
    //  ValueMass->SetValue(mass);
      if (EtalonMeter!=nullptr){
        ValueImpTotal->SetValue(EtalonMeter->ValueImpTotal->GetDoubleValue());
      }
    }


    ValueCoef->SetValue(coef);
    */

    ValueVolumeCoef->SetValue();
    ValueMassCoef->SetValue();

    ValueVolumeFlow->SetValue();
    ValueMassFlow->SetValue();
    ValueVolume->SetValue();
    ValueMass->SetValue();


  /*  if (ValueVolume->UpdateType != HAND_TYPE) {

    } else
    {
      if (EtalonMeter!=nullptr){
        ValueVolume->SetValue(EtalonMeter->ValueVolume->GetDoubleValue());
      }
    }

    if (ValueMass->UpdateType != HAND_TYPE) {

    } else
    {
      if (EtalonMeter!=nullptr){
        ValueMass->SetValue(EtalonMeter->ValueMass->GetDoubleValue());
      }
    }



    */

    ValueVolumeError->SetValue(GetVolumeError());
    ValueMassError->SetValue(GetMassError());

}

void TFlowMeter::SetFinalValuesByEtalon()
{

	ValueTime->SetValue(EtalonMeter->ValueTime->GetDoubleValue());
	ValueImpTotal->SetValue(EtalonMeter->ValueImpTotal->GetDoubleValue());

    ValueQuantity->SetValue(EtalonMeter->ValueQuantity->GetDoubleValue());

	ValueVolume->SetValue(EtalonMeter->ValueVolume->GetDoubleValue());
	ValueMass->SetValue(EtalonMeter->ValueMass->GetDoubleValue());

	ValueImp->SetValue(EtalonMeter->ValueImp->GetDoubleValue());



		if (GetMeterFlowType() == "Весовое устройство")
	{
		ValueVolumeMeter->SetValue((double)-1);
		ValueMassMeter->SetValue((double)-1);
	}

		else if (GetMeterFlowType() == "Весовое устройство + ОР")
	{
		ValueVolumeMeter->SetValue(EtalonMeter->ValueVolume->GetDoubleValue());
		ValueMassMeter->SetValue((double)-1);
	}

	else if (GetMeterFlowType()== "Весовое устройство + МР") {

		ValueVolumeMeter->SetValue((double)-1);
		ValueMassMeter->SetValue(EtalonMeter->ValueMass->GetDoubleValue());
	}
		else if (GetMeterFlowType() == "Массовый расходомер") {

		ValueVolumeMeter->SetValue((double)-1);
		ValueMassMeter->SetValue(EtalonMeter->ValueMass->GetDoubleValue());
	}

	else if (GetMeterFlowType() == "Объемный расходомер")
	{
			ValueVolumeMeter->SetValue(EtalonMeter->ValueVolume->GetDoubleValue());
			ValueMassMeter->SetValue((double)-1);
	}

		else if (GetMeterFlowType() == 	"Мерник")
	{
		ValueVolumeMeter->SetValue((double)-1);
		ValueMassMeter->SetValue((double)-1);
	}




    ValueDensity->SetValue(EtalonMeter->ValueDensity->GetDoubleValue());
    ValuePressure->SetValue(EtalonMeter->ValuePressure->GetDoubleValue());
    ValueTemperture->SetValue(EtalonMeter->ValueTemperture->GetDoubleValue());

    ValueAirPressure->SetValue(EtalonMeter->ValueAirPressure->GetDoubleValue());
    ValueAirTemperture->SetValue(EtalonMeter->ValueAirTemperture->GetDoubleValue());
    ValueHumidity->SetValue(EtalonMeter->ValueHumidity->GetDoubleValue());

    ValueError->SetValue(GetVolumeError());
	ValueVolumeError->SetValue(GetVolumeError());
	ValueMassError->SetValue(GetMassError());
}

void TFlowMeter::SortDataPointsFlow(int MinMax )
{
    // Сортировка по Qt от большего к меньшему
    if (MinMax == 0) {
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToFloatDef(a.Qt, 0.0) > StrToFloatDef(b.Qt, 0.0);
        });
    } else
    {
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToFloatDef(a.Qt, 0.0) < StrToFloatDef(b.Qt, 0.0);
        });
    }

}

void TFlowMeter::SortDataPointsDate(int MinMax )
{
if (MinMax == 1) {
    // Сортировка по Date от меньшего к большему
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToDateTimeDef(a.Date, TDateTime(0)) < StrToDateTimeDef(b.Date, TDateTime(0));
        });
} else
{
    // Сортировка по Date от большему к меньшего
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToDateTimeDef(a.Date, TDateTime(0)) > StrToDateTimeDef(b.Date, TDateTime(0));
        });
}

 }

 void TFlowMeter::SortDataPointsName(int MinMax )
{
if (MinMax == 1) {
    // Сортировка по Date от меньшего к большему
 std::sort(DataPoints.begin(), DataPoints.end(),
    [](const tDataPoint& a, const tDataPoint& b) {
        return a.Name < b.Name;
    });
} else
{
    // Сортировка по Date от большему к меньшего
 std::sort(DataPoints.begin(), DataPoints.end(),
    [](const tDataPoint& a, const tDataPoint& b) {
        return a.Name > b.Name;
    });
}

 }

 void TFlowMeter::SortDataPointsError(int MinMax )
{
    // Сортировка по Qt от большего к меньшему
    if (MinMax == 0) {
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToFloatDef(a.Error, 0.0) >
            StrToFloatDef(b.Error, 0.0);
        });
    } else
    {
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToFloatDef(a.Error, 0.0) <
            StrToFloatDef(b.Error, 0.0);
        });
    }

 }

 void TFlowMeter::SortDataPointsErrorMeter(int MinMax )
{
    // Сортировка по Qt от большего к меньшему
    if (MinMax == 0) {
    std::sort(DataPoints.begin(), DataPoints.end(),
        [](const tDataPoint& a, const tDataPoint& b) {
            return StrToFloatDef(a.ErrorMeter, 0.00) >
            StrToFloatDef(b.ErrorMeter, 0.00);
		});
	} else
	{
	std::sort(DataPoints.begin(), DataPoints.end(),
		[](const tDataPoint& a, const tDataPoint& b) {
			return StrToFloatDef(a.ErrorMeter, 0.00) <
			StrToFloatDef(b.ErrorMeter, 0.00);
		});
	}

 }


void TFlowMeter::DataPointsCalc()
{
		double std;
		double nsp;
		double errmass;
		double errvol;

		int size;

		std::vector<double> errmasses;
		std::vector<double> errvolumes;
		std::vector<tDataPoint*> relatedPointsM;
		std::vector<tDataPoint*> relatedPointsV;

		for (tDataPoint& dp : DataPoints)
		{
			 dp.NSPM = "-";
			 dp.NSPV = "-";
			 dp.STDM = "-";
			 dp.STDV = "-";
			 dp.ErrorMass = RelativeErrorStr(dp.EtlMass, dp.Mass);
			 dp.ErrorVolume = RelativeErrorStr(dp.EtlVolume, dp.Volume);
		}

	for (tPoint& point : Points)
	{
		 errmasses.clear();
		 errvolumes.clear();
		 relatedPointsM.clear();
		 relatedPointsV.clear();

		 size = errmasses.size();

		for (tDataPoint& dp : DataPoints)
		{

		double Q;
		if (TryStrToDouble_(dp.Q, Q))
		{
			if (!IsFlowInPoint(Q, point))
				continue;
		}else
		{
			 continue;
		}

		if (TryStrToDouble_(dp.ErrorMass, errmass))
		   {
			errmasses.push_back(errmass);
			relatedPointsM.push_back(&dp); // Сохраняем указатель на оригинальный объект
		   }


		if (TryStrToDouble_(dp.ErrorVolume, errvol))
		   {
			errvolumes.push_back(errvol);
			relatedPointsV.push_back(&dp); // Сохраняем указатель на оригинальный объект
		   }


		}

		if (!errmasses.empty())
		{
				 size = errmasses.size();
		std = CalcSTD(errmasses);

		for (tDataPoint* dp : relatedPointsM)
		{
			nsp = CalcNSP(errmasses, dp->ErrorMass);
			dp->NSPM = FloatToStrF(nsp, ffNumber, 2, 3);
			dp->STDM = FloatToStrF(std, ffNumber, 2, 3);
		}
		}

		if (!errvolumes.empty())
		{

		std = CalcSTD(errvolumes);

		for (tDataPoint* dp : relatedPointsV)
		{
			nsp =  CalcNSP(errvolumes, dp->ErrorVolume);
			dp->NSPV = FloatToStrF(nsp, ffNumber, 2, 3);
			dp->STDV = FloatToStrF(std, ffNumber, 2, 3);
		}
		}


	}
}

#pragma package(smart_init)

