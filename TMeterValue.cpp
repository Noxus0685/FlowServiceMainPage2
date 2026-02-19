                                       // ---------------------------------------------------------------------------

#pragma hdrstop

// ---------------------------------------------------------------------------
#pragma package(smart_init)

#include <System.JSON.hpp>
#include "TFlowMeterType.h"
#include <System.Math.hpp>

#include <time.h>
#include <System.DateUtils.hpp >

#include <vector>

#include "TOrderClass.h"
#include "TMeterValue.h"

#include <REST.Client.hpp>
#include <REST.Response.Adapter.hpp>
#include <REST.Types.hpp>
#include <System.Bindings.Outputs.hpp>
#include <System.Rtti.hpp>
#include "UserRoutines.h"

#include "TSettingsClass.h"

 TXMLDocument *TMeterValue::XmlDoc = nullptr;
_di_IXMLNode TMeterValue::rootNode = nullptr;
_di_IXMLNode TMeterValue::sampleNode = nullptr;
_di_IXMLNode TMeterValue::sampleNode2 = nullptr;
_di_IXMLNode TMeterValue::sampleNode3 = nullptr;
UnicodeString TMeterValue::dirName = "";
UnicodeString TMeterValue::fname = "";

 vector<TMeterValue*> TMeterValue::MeterValues;
 vector<TMeterValue*> TMeterValue::MeterValuesSaves;

bool TMeterValue::FinalValue = false;

TMeterValue* TMeterValue::GetMeterValue(int Hash)
{
    if (Hash == 0) {
     return nullptr;
    }

    if (MeterValues.size() > 0)
        for (int j = 0; j < MeterValues.size(); j++) {
            if (MeterValues[j]->Hash == Hash) {
                 return MeterValues[j];
            }
        }

    return nullptr;// (new  TMeterValue(HashOwner, Name));
}

TMeterValue*  TMeterValue::GetNewMeterValue(int hash) {

    TMeterValue *NewMeterValue;
    TMeterValue *MeterValue = GetMeterValue(hash);

    if (hash == 0) {
         return nullptr;
    }

    if (MeterValue!=NULL) {

       NewMeterValue = new TMeterValue(hash);
       NewMeterValue->SetCopy(MeterValue);
       MeterValues.push_back(NewMeterValue);
       return NewMeterValue;
    }  else
    {
       NewMeterValue = new TMeterValue();
       return NewMeterValue;
    }

}

TMeterValue* TMeterValue::GetExistedMeterValueBool(int &hash, int &IsExisted, int hashOwner, UnicodeString nameOwner)
{
    TMeterValue* MeterValue = GetMeterValue(hash);

    if (MeterValue != NULL) {
        IsExisted = 1;
        if (MeterValue->HashOwner==0) {
        MeterValue->HashOwner =  hashOwner;
        MeterValue->NameOwner =  nameOwner;
        }

        return MeterValue;
    } else {
        MeterValue = new TMeterValue(hashOwner, nameOwner);
        IsExisted = 0;
        hash = MeterValue->Hash;
        return MeterValue;
    }
}
 /*
bool TMeterValue::GetExistedMeterValue(TMeterValue* meterValue, int &hash, int hashOwner, UnicodeString nameOwner)
{
    TMeterValue* MeterValue = GetMeterValue(hash);

    if (MeterValue != NULL) {
        return 1;
    } else {
        MeterValue = new TMeterValue(hashOwner, nameOwner);
        meterValue =  MeterValue;
        hash =  meterValue->Hash;

        hash = MeterValue->Hash;
        return 0;
    }
}
 */
void TMeterValue::SetToSave(bool isToSave)
{
    TMeterValue* MeterValue = GetMeterValue(Hash);

    if (isToSave) {

    if (MeterValue == NULL) {
       MeterValues.push_back(this);
    }

    IsToSave = true;

    } else
    {

    if (MeterValue != NULL) {

      DeleteFromVector();

    }
     IsToSave = false;
    }

}

TMeterValue*  TMeterValue::GetNewMeterValueBool(int hash, int &IsExisted ,int HashOwner, UnicodeString Name)
{

    TMeterValue *NewMeterValue;
    TMeterValue *MeterValue = GetMeterValue(hash);

    if (MeterValue!=NULL) {

       NewMeterValue = new TMeterValue(hash);
       NewMeterValue->SetCopy(MeterValue);
       MeterValues.push_back(NewMeterValue);
       IsExisted = 1;
       return NewMeterValue;
    }  else
     {
       NewMeterValue = new TMeterValue(HashOwner, Name);
    //   MeterValues.push_back(NewMeterValue);
       IsExisted = 0;
       return NewMeterValue;
     }

}

TMeterValue*  TMeterValue::GetCopyMeterValueBool(int &hash, int &IsExisted) {

    TMeterValue *NewMeterValue;
    TMeterValue *MeterValue = GetMeterValue(hash);
  //  if (hash == 0) {
 //        IsExisted = 3;
 //        return nullptr;
 //   }
    if (MeterValue!=NULL) {

       NewMeterValue = new TMeterValue(hash);
       NewMeterValue->SetCopy(MeterValue);
       hash = NewMeterValue->Hash;
       MeterValues.push_back(NewMeterValue);
       IsExisted = 1;
       return NewMeterValue;
    }  else
     {
       NewMeterValue = new TMeterValue();
       hash = NewMeterValue->Hash;
    //   MeterValues.push_back(NewMeterValue);
       IsExisted = 0;
       return NewMeterValue;
     }

}

TMeterValue* TMeterValue::GetMeterValue(int hash, int HashOwner, UnicodeString Name){

   TMeterValue* MeterValue;

    for (int i = 0; i <  MeterValues.size(); i++)
    {
		if (hash == MeterValues[i]->Hash)
        {
			return MeterValues[i];
		}
	}

    MeterValue = new  TMeterValue(HashOwner, Name);

    return  MeterValue;
}

TMeterValue::TMeterValue() {

   Hash = GetNewHash();
    MeterValues.push_back(this);

}

TMeterValue::TMeterValue(int hash, UnicodeString name) {

   Hash = GetNewHash();
   HashOwner = hash;
   NameOwner = name;
    MeterValues.push_back(this);

}

TMeterValue::TMeterValue(TMeterValue *MeterValue) {

   Hash = GetNewHash();

   SetCopy(MeterValue);

   MeterValues.push_back(this);

}

TMeterValue::TMeterValue(int hash) {

   Hash = GetNewHash();

    TMeterValue *MeterValue = GetMeterValue(hash);

    if (MeterValue!=NULL) {
       SetCopy(MeterValue);
       MeterValues.push_back(this);
    }

}

void TMeterValue::SetCopy(TMeterValue *MeterValue)
{
     if (MeterValue==NULL) {return;}

                Name=  MeterValue->Name;
                ShrtName= MeterValue->ShrtName;
                Description=MeterValue->Description;
                IsToSave = MeterValue->IsToSave;

                HashValueRate=MeterValue->HashValueRate;
                HashValueBaseMultiplier=MeterValue->HashValueBaseMultiplier;
                HashValueBaseDevider=MeterValue->HashValueBaseDevider;
                HashValueCorrection=MeterValue->HashValueCorrection;
                HashValueEtalon=MeterValue->HashValueEtalon;

                ValueRate=           GetMeterValue(HashValueRate, Hash, Name);
                ValueBaseMultiplier= GetMeterValue(HashValueBaseMultiplier, Hash, Name);
                ValueBaseDevider=    GetMeterValue(HashValueBaseDevider, Hash, Name);
                ValueCorrection=     GetMeterValue(HashValueCorrection, Hash, Name);
                ValueEtalon=         GetMeterValue(HashValueEtalon, Hash, Name);


                filter_order=MeterValue->filter_order;

                Accuracy=MeterValue->Accuracy;

                Error=MeterValue->Error;

                MaxValue=MeterValue->MaxValue;
                MinValue=MeterValue->MinValue;
                MaxNomValue=MeterValue->MaxNomValue;
                MinNomValue=MeterValue->MinNomValue;

                CurrentDimIndex=MeterValue->CurrentDimIndex;

                Dimensions.clear();

                if (!MeterValue->Dimensions.empty()) {
                    for (int i = 0; i < MeterValue->Dimensions.size(); i++) {

                        Dimension Dim;

                        Dim.Name=MeterValue->Dimensions[i].Name;
                        Dim.Hash=MeterValue->Dimensions[i].Hash;
                        Dim.Rate=MeterValue->Dimensions[i].Rate ;
                        Dim.Devider=MeterValue->Dimensions[i].Devider ;
                        Dim.Factor=MeterValue->Dimensions[i].Factor;
                        Dim.Recip=MeterValue->Dimensions[i].Recip;

                        Dimensions.push_back(Dim);
                    }
                }

                Coefs.clear();

                                if (!MeterValue->Coefs.empty()) {
                    for (int i = 0; i < MeterValue->Coefs.size(); i++) {

                         tCoef Coef;
					   //	SetAttribute("Name",sampleNode2,MeterValue->Dimensions[i].Name);
                        Coef.Name=MeterValue->Coefs[i].Name;
                        Coef.Hash=MeterValue->Coefs[i].Hash ;
                        Coef.Index=MeterValue->Coefs[i].Hash ;

                        Coef.Value=MeterValue->Coefs[i].Value;
                        Coef.Arg=MeterValue->Coefs[i].Arg;
                        Coef.Q1=MeterValue->Coefs[i].Q1 ;
                        Coef.Q2=MeterValue->Coefs[i].Q2  ;
                        Coef.K=MeterValue->Coefs[i].K   ;
                        Coef.b=MeterValue->Coefs[i].b   ;

                        Coef.InUse=MeterValue->Coefs[i].InUse;

						//SetIntAttribute("IsRageFree",sampleNode2,MeterValues[j]->Dimensions[i].IsRageFree);
                        Coefs.push_back(Coef);
                    }
                }


 }

float TMeterValue::AverageApply() {
  return  0;
}

double TMeterValue::FilterApply() {
	double flt, val, limit, mean = 0;
	int delta, pos;
	bool nulls;

	if (filter_order > 0) {

		if (Values.size() > filter_order) {
			delta = filter_order;

		}
		else {
			delta = Values.size();

			if (temp_delta > delta) {
				temp_delta = delta;
			}

		}

		if (temp_delta < filter_order) {

			if (temp_delta < delta) {
				delta = temp_delta;
				temp_delta++;
			}
		}
		else {
			// temp_delta = delta;
		}

		nulls = false;

		for (int i = 0; i < delta; i++) {
			val = Values[i];
			mean = mean + val;

			if (val == 0) {
				nulls = true;
			}

			if (i == filter_short_order-1) {
				ShortMean = mean / filter_short_order;

				if ((LastMean != 0) && (!nulls)) {

					limit = ((ShortMean /** filter_short_delta */* Error) / 100);

					if ((fabs(LastMean - ShortMean)) >
						((ShortMean */* filter_short_delta */ Error) / 100)) {
						delta = filter_short_order;
						temp_delta = filter_short_order;
					}

					else {

					}
				}
			}

		}

		Mean = mean / delta;
		LastMean = Mean;
		flt = Mean;
	}
	else {
		Mean = flt;
		flt = (float)Value;
	}

	AverValues.push_front(Mean);

	if (AverValues.size() > ARRAY_SIZE) {
		AverValues.pop_back();
	}

	return flt;

}

float TMeterValue::GetFloatValue() {
	return Value;
}

double TMeterValue::GetDoubleValue() {

 //  value = Rate(Value);
	return Value;

}

double TMeterValue::GetDoubleValue(UnicodeString DimName) {

   uint8_t  Dim =  GetDim(DimName);
	return GetDoubleValue(Dim);
}

double TMeterValue::GetDoubleValueDim()
{
	return GetDoubleValue(CurrentDimIndex);
}

// Основная функция
double TMeterValue::GetDoubleValue(uint8_t dim) {
	double dbl=0;
	double value=Value;
	double rt;

	Dimension Dim;

	if (GetDim(dim, Dim))
	{
	  rt = Dim.Rate;

	  if (Dim.Recip) {
		dbl =   rt / GetDoubleValue();
	  }   else
	  {
		  dbl =   rt * GetDoubleValue();
	  }

	  if ((Dim.Devider!=0)&&(Dim.Devider!=1)) {
		  dbl =  dbl / Dim.Devider;
	  }

		return dbl;

	} else
	{
		return dbl;
	}
}

double TMeterValue::GetDoubleMeanValue()
{
 int i;
 int size = Values.size();
 double result;
 double value;

    for (i = 0; i < size; i++) {

    value = Values[i];
    result += (value/size);

    }
   return result;
}

double TMeterValue::GetDoubleMeanValue(uint8_t dim)
{
 	double dbl=0;
	double value=Value;
	double rt;

	Dimension Dim;

	if (GetDim(dim, Dim))
	{
	  rt = Dim.Rate;

	  if (Dim.Recip) {
		dbl =   rt / GetDoubleMeanValue();
	  }   else
	  {
		  dbl =   rt * GetDoubleMeanValue();
	  }

	  if ((Dim.Devider!=0)&&(Dim.Devider!=1)) {
		  dbl =  dbl / Dim.Devider;
	  }

		return dbl;

	} else
	{
		return dbl;
	}

}


double TMeterValue::GetDoubleMeanValue(UnicodeString DimName) {

   uint8_t  Dim =  GetDim(DimName);
	return GetDoubleMeanValue(Dim);

}

float TMeterValue::GetFloatValue(uint8_t Dim) {
	return GetDoubleValue() * GetDimRate(Dim);
}

float TMeterValue::GetFloatValue(UnicodeString DimName) {
	float flt = GetFloatValue() * GetDimRate(DimName);

	return flt;
}

UnicodeString TMeterValue::GetStringValue_(uint8_t IntSigns, uint8_t FractSigns)
{
	return FloatToStrF(GetFloatValue(), ffNumber, IntSigns, FractSigns);
}

UnicodeString TMeterValue::GetStringValue_(uint8_t IntSigns, uint8_t FractSigns,
	uint8_t Dim) {
	float flt;
	flt = GetFloatValue() * GetDimRate(Dim);
	return FloatToStrF(flt, ffNumber, IntSigns, FractSigns);

}

UnicodeString TMeterValue::GetStringValue_(uint8_t IntSigns, uint8_t FractSigns,
	UnicodeString Dim) {
	float flt;

	flt = GetFloatValue() * GetDimRate(Dim);
	return FloatToStrF(flt, ffNumber, IntSigns, FractSigns);

}

UnicodeString TMeterValue::GetStringDimensionsValue(uint8_t IntSigns,
	uint8_t FractSigns) {
	for (int i = 0; i < Dimensions.size(); i++) {
		if (Dimensions[i].Rate == 1) {

			return FloatToStrF(GetFloatValue(), ffNumber, IntSigns, FractSigns)
				+ Dimensions[i].Name;
		}
	}

	return FloatToStrF(GetFloatValue(), ffNumber, IntSigns, FractSigns);
}

void TMeterValue::SetFilter(int i) {
	filter_order = i;
}

int TMeterValue::GetFilter() {
	return filter_order;
}

void TMeterValue::SetValueCurrnet(double Value)
{
	SetValue(Value);

}

int8_t TMeterValue::UpdateCoefs(vector <tCalibrPoint>  CalibrPoints)
 {

 tCoef coef;

 float Qtest1, Qetl1, Qtest2, Qetl2;
 float k,b;

	Coefs.clear();
	if (!CalibrPoints.empty())
	{
	   if ( CalibrPoints[0].Qtest !=0)
	   {
	   Qtest1 =  	CalibrPoints[0].Qtest;
	   Qetl1 =  	CalibrPoints[0].Q;


	   k = Qetl1 / Qtest1;

	   coef.Q1 =  0;
	   coef.Q2 =  Qtest1;
	   coef.K =   k;
	   coef.b =   0;



       Coefs.push_back(coef);
       }


    for (int i=1;i<CalibrPoints.size();i++)
    {

       Qtest1 =  	CalibrPoints[i-1].Qtest;
       Qetl1 =  	CalibrPoints[i-1].Q;
       Qtest2 =  	CalibrPoints[i].Qtest;
       Qetl2 =  	CalibrPoints[i].Q;

       if ((Qtest1- Qtest2)!=0)
       {
       k =  (Qetl1- Qetl2) / (Qtest1- Qtest2);
       } else
	   {
       k = 0;
       }

       b =  Qetl1- k*Qtest1;

       coef.Q1 =  Qtest1;
       coef.Q2 =  Qtest2;
       coef.K =  k;
	   coef.b =  b;

	   Coefs.push_back(coef);
	}

	}

	else
	{

	  return 0;
    }

	return 1;
 }

double  TMeterValue::Rate(double Q)
{
	float temp,k,b;
	float Qetl=0;
	float rate;

    if (Q == 0) return 1;


	if (!Coefs.empty())
    {
	for (int i=0;i<Coefs.size();i++)
    {
	k = Coefs[i].K;
    b = Coefs[i].b;

     if ((Q>= Coefs[i].Q1)&&(Q< Coefs[i].Q2))
     {

        Qetl = k*Q+ b;
        rate=Qetl/Q;
        return rate;
     }
    }

    if (Qetl == 0)
    {
        Qetl= k*Q+ b;
        rate=Qetl/Q;
        return rate;
    }


    }
    else
    {
     return 1;
    }
    return 1;
}

//
void TMeterValue::SetMainValue(double InputValue, float Q)
{

 double value=0;

	 value = ( Coefs.size()>0 ? InputValue * Rate(Q) : InputValue);

   SetValue(value) ;
}

void TMeterValue::SetMainValue(double InputValue) {

 double value=0;

	 value = ( Coefs.size()>0 ? InputValue * Rate(InputValue) : InputValue);

   SetValue(value) ;

}

/*
void TMeterValue::SetSumValue(double InputValue)
{
	double value = 0;

	value = (RateValue!=nullptr?InputValue * RateValue->GetDoubleValue():InputValue );
	SetValue(value);
}
  */


void TMeterValue::SetRawValue(double InputValue)
{
	double value = 0;
    double rate=0;
    double result=0;

    //if (Rawvalue!=0) {
		 RawValues.push_front(Rawvalue);
	//}

	if (RawValues.size() > ARRAY_SIZE) {
            RawValues.pop_back();
	}

	if (UpdateType != HAND_TYPE)
	{
	UpdateType = ONLINE_TYPE;

    if (ValueRate!=nullptr) {
     value =  InputValue * ValueRate->GetDoubleValue();
    } else
    {
     value =  InputValue;
    }


    if (Type=="PT100") {

      value = CalculateTemperature(value);

    }  else
    {
       value = value * CoefK + CoefP;
    }

    ValueWoCorrection = value;

    rate =  Rate(value);
    result = rate*value;

	SetValue(result);
	}
}

void TMeterValue::SetRawValue(double InputValue, float Q)
{
	double value = 0;

 	if (UpdateType != HAND_TYPE)
	{
	UpdateType = ONLINE_TYPE;
	value = (ValueRate!=nullptr?InputValue * ValueRate->GetDoubleValue():InputValue );
	value = value * CoefK + CoefP;
	SetValue(value, Q);
	}
}

void TMeterValue::SetValue(UnicodeString Value)
{
    double flt;
	if (TryStrToDouble_(Value, flt)) {
		SetValue(flt);
	}
}

void TMeterValue::SetValue(float Value) {
	SetValue((double) Value);

}

void TMeterValue::SetValue()
{
    double value = 0;

    if (UpdateType != HAND_TYPE) {
        if (ValueEtalon != nullptr) {
            if (ValueType == ERROR_TYPE) {
                value = ValueBaseMultiplier->Value - ValueEtalon->Value;

                if (ValueEtalon->Value != 0) {
                    value = value * 100;
                    value = value / ValueEtalon->Value;
                } else {
                    value = -101;
                }

                SetValue(value);
            } else {
                value = 0;
            }
        } else if ((ValueBaseMultiplier != nullptr) ||
                   (ValueBaseDevider != nullptr)) {
            if (ValueBaseMultiplier != nullptr) {
                value = ValueBaseMultiplier->Value;
            } else {
                value = 1;
            }

            if (ValueRate != nullptr) {
                value = value * ValueRate->Value;
            }

            if (ValueBaseDevider != nullptr) {
                value = value / ValueBaseDevider->Value;
            }

            ValueWoCorrection = value;

            if (ValueCorrection != nullptr) {
                float Q = ValueCorrection->Value;
                value = (Coefs.size() > 0 ? value * Rate(Q) : value);
            } else {
                value = (Coefs.size() > 0 ? value * Rate(value) : value);
            }

            SetValue(value);
        }
    }  else
    {

    }
}

void TMeterValue::SetValue(double InputValue)
{
    //	if ((ARRAY_SIZE > 0)||(FinalValue))

    if (ARRAY_SIZE > 0) {

    Values.push_front(InputValue);

    if (Values.size() > ARRAY_SIZE) {
        Values.pop_back();
    }

        if ((filter_order != -1) && (!FinalValue)) {
            Value = FilterApply();
        } else {
            Value = InputValue;
        }
    } else {
        Value = InputValue;
    }
}

void TMeterValue::SetDimValue(double value)
{
		SetValue(value, CurrentDimIndex);
}

void TMeterValue::SetDimValue(UnicodeString str)
{
   double dbl;
	   if (TryStrToDouble_(str,dbl)) {

		   SetValue(dbl, CurrentDimIndex);

	   } else
	   {
		   SetValue(0, CurrentDimIndex);
	   }
}

void TMeterValue::SetValue(double value, uint8_t Dim) {
	double dbl;
	double val;

	if (Dimensions[Dim].Recip) {
		val = (1 / value);
    } else {
		val = value;
    }

	if ((Dimensions[Dim].Devider!=1)&&(Dimensions[Dim].Devider!=0)) {
		val =  val * Dimensions[Dim].Devider;
	}

		if ((Dimensions[Dim].Rate!=1)&&(Dimensions[Dim].Rate!=0)) {
		dbl = val / Dimensions[Dim].Rate;
	}   else
	{
		dbl = val;
	}
	SetValue(dbl);
}

void TMeterValue::SetValue(double Value, UnicodeString Dim)
{
    double dbl;

	SetValue(Value, GetDim(Dim));
}

void TMeterValue::SetAddValue(double InputValue)
{
	SetValue(Value+InputValue);
}

double TMeterValue::GetDimRate(UnicodeString Name) {
	UnicodeString DimName;
	for (int i = 0; i < (Dimensions.size()); i++) {
		DimName = Dimensions[i].Name;
		if (Name.CompareIC(DimName) == 0)
			// (StringCompare(Name,DimName))//(Name.CompareIC(DimName)==0)
		{
			return (Dimensions[i].Rate/Dimensions[i].Devider);
		}
	}

	return 1;

}

double TMeterValue::GetDimRate(int Dim) {
   double rt=0;
	if (Dim <  Dimensions.size()) {
		rt = (Dimensions[Dim].Rate/Dimensions[Dim].Devider);
		return rt;
	}

	return 1;
}

UnicodeString TMeterValue::GetDimName() {

	return	CurrentDim.Name;

}

UnicodeString TMeterValue::GetShrtName()
{
	return	ShrtName;
}

UnicodeString TMeterValue::GetDimName(int Dim)
{
	if (Dim <  Dimensions.size()) {
		return Dimensions[Dim].Name;
	}

	return L" ";
}

bool TMeterValue::GetDim(int index, Dimension &Dim) {
	if (index < Dimensions.size()) {
		Dim = Dimensions[index];
		return true;
	}
	return false;
}

bool TMeterValue::GetDim(UnicodeString Name, Dimension &Dim) {
	for (int i = 0; i < Dimensions.size(); i++) {
		if (Name == Dimensions[i].Name) {
			Dim = Dimensions[i];
			return true;
		}
	}

	return false;
}

int TMeterValue::GetDim(UnicodeString Name) {
	for (int i = 0; i <  Dimensions.size(); i++) {
		if (Name == Dimensions[i].Name) {
			return i;
		}
	}

	return -1;
}

int TMeterValue::GetDim() {

	return CurrentDimIndex;
}

void TMeterValue::SetDimension(UnicodeString Name, double Rate) {
	Dimension Dim;
	Dim.Rate = Rate;
	Dim.Devider = 1;
	Dim.Recip = false;
	Dim.Name = Name;
	Dimensions.push_back(Dim);
}

 void TMeterValue::SetDimension(UnicodeString Name, double Rate, double Devider, bool Recip) {
	//
	Dimension Dim;
	//
	Dim.Rate 	= Rate;
	Dim.Name 	= Name;
	Dim.Devider = Devider;
	Dim.Recip 	= Recip;
	//
	Dimensions.push_back(Dim);
}

void TMeterValue::SetAsVolume()
{
	ValueType = SUM_TYPE;
	Name = "Объем";
	SetFilter(-1);
	Accuracy = 6;
	Value = 0;
 	ShrtName = "V";
	SetDimension("л", 1);
	SetDimension("м3", 1, 1000, false);
	SetDim(0);

	MaxValue = MAXDOUBLE;
	MinValue = 0;

	Error = 0.01;

}

void TMeterValue::SetAsMass()
{
	ValueType = SUM_TYPE;
	Name = "Масса";
	ShrtName = "M";
	SetFilter(-1);
	Accuracy = 6;
	Value = 0;

	SetDimension("кг", 1, 1, false);
	SetDimension("т", 1, 1000, false);
		SetDim(0);

	MaxValue = MAXDOUBLE;
	MinValue = 0;

	Error = 0.01;

}

void TMeterValue::SetAsVolumeFlow()
{
	ValueType = FLOW_TYPE;
	Name = "Объемный расход";
		ShrtName = "Qv";
	SetFilter(8);
	Accuracy = 4;
	Value = 0;

	SetDimension("л/с"		, 1		, 1		, false);
	SetDimension("л/мин"	,60   	, 1	, false);
	SetDimension("л/ч"		,3600   ,1 	, false);
	SetDimension("м3/мин"	,60 	,1000		, false);
	SetDimension("м3/ч"		,3600 	,1000	, false);

	SetDim(4);

	MaxValue = MAXDOUBLE;
	MinValue = 0;

	Error = 0.01;

}

void TMeterValue::SetAsMassFlow()
{
	ValueType = FLOW_TYPE;
	Name = "Массовый расход";
	ShrtName = "Qm";
	SetFilter(8);
	Accuracy = 4;
	Value = 0;
	SetDimension("кг/с"		, 1		, 1		, false);
	SetDimension("кг/мин"	, 60	, 1	, false);
	SetDimension("кг/ч"		, 3600		,1 	, false);
	SetDimension("т/мин"	, 60	,1000 	, false);
	SetDimension("т/ч"		, 3600	,1000 	, false);

	SetDim(4);

	MaxValue = MAXDOUBLE;
	MinValue = 0;

	Error = 0.01;

}

void TMeterValue::SetAsImp()
{
	ValueType = FLOW_TYPE;
	Value = 0;
	SetFilter(-1);
	Accuracy = 5;
	Name = "Импульсы";
	ShrtName = "N";
	SetDimension("имп", 1, 1, false);
	SetDim(0);

	MaxValue = MAXDOUBLE;
	MinValue = 0;

	Error = 0.001;

	Reset();
}

void TMeterValue::SetAsError()
{
	ValueType = ERROR_TYPE;
	Value = 0;
	SetFilter(-1);
	Accuracy = 4;
	Error = 0.0;
	ShrtName = "δ";
	Name = "Погрешность";

	SetDimension("%", 1);
	SetDim(0);

	MaxValue = 100;
	MinValue = -100;

	MaxNomValue = 0.1;
	MinNomValue = -0.1;

}

void TMeterValue::SetAsMassError()
{
	ValueType = ERROR_TYPE;
	Value = 0;
	SetFilter(-1);
	Accuracy = 4;
    Error = 0;
	Name = "Погрешность по массе";
	ShrtName = "δm";

	SetDimension("%", 1);
	SetDim(0);

	MaxValue = 100;
	MinValue = -100 ;

	MaxNomValue = 0.1;
	MinNomValue = -0.1;

}

void TMeterValue::SetAsVolumeError()
{
	ValueType = ERROR_TYPE;
	Value = 0;
	SetFilter(-1);
	Accuracy = 4;
    Error = 0;

	Name = "Погрешность по объему";
	ShrtName = "δv";
	SetDimension("%", 1);
	SetDim(0);

	MaxValue = 100;
	MinValue = -100;

	MaxNomValue = 0.1;
	MinNomValue = -0.1;

}

void TMeterValue::SetAsDensity()
{
	ValueType = CONST_TYPE;
	Value = 998.1;
	SetFilter(-1);
	Accuracy = 5;
	Name = "Плотность";

	ShrtName = "ρ";
	SetDimension("кг/л", 1);
	SetDimension("кг/м3", 1000);
	SetDimension("т/л", 1,1000,false);
	SetDimension("т/м3", 1);
	SetDim(0);

	MaxValue = 1.1100;
	MinValue = 0.900;

	MaxNomValue = 0.999;
	MinNomValue = 0.997;

	Error = 0.01;

	SetValue((double)0.9982);
}

void TMeterValue::SetAsTemp()
{
	ValueType = CONST_TYPE;
	Value = 21.3;
	SetFilter(-1);
	Accuracy = 4;
	Name = "Температура";
    Type = "PT100";
    RawValueName = "Сопротивление";
    RawValueDim = "Ом";

	ShrtName = "t";
	SetDimension("°C", 1);
	SetDimension("град. С", 1);
	SetDim(0);
	SetValue((double)20);

	MaxValue = 100;
	MinValue = 0;

	MaxNomValue = 25;
	MinNomValue = 15;

	Error = 0.5;
    SetValue((double)21.3);
}

void TMeterValue::SetAsAirTemp()
{
	ValueType = CONST_TYPE;
	Value = 21.3;
	SetFilter(-1);
	Accuracy = 4;
	Name = "Температура атм";
    Type = "ИВТМ";
    RawValueName = "";
    RawValueDim = "";

	ShrtName = "t";
	SetDimension("°C", 1);
	SetDimension("град. С", 1);
	SetDim(0);
	SetValue((double)20);

	MaxValue = 100;
	MinValue = 0;

	MaxNomValue = 25;
	MinNomValue = 15;

	Error = 0.5;
    SetValue((double)21.3);
}

double TMeterValue::CalculateTemperature(double Rt, double R0) {
    const double A = 3.9083e-3;
    const double B = -5.775e-7;
    // Решаем квадратное уравнение At^2 + Bt + (1 - Rt/R0) = 0
    double delta = A * A - 4 * B * (1 - Rt / R0);
    if (delta < 0) {
       // throw std::runtime_error("Invalid resistance value, no real solution exists.");
       return -1;
    }
    double temperature = (-A + std::sqrt(delta)) / (2 * B);
    return temperature;
}

void TMeterValue::SetAsTime()
{
	ValueType = CONST_TYPE;
	Value = 0;
	SetFilter(-1);
	Accuracy = 0;
	Error = 0.001;

	Name = "Время";
	ShrtName = "T";
	SetDimension("сек", 1);
	SetDimension("мин", 1, 60, false);
	SetDimension("час", 1, 3600, false);
	SetDim(0);

	SetValue((double)0);

	MaxValue = 99999999;
	MinValue = 0;
	MaxNomValue = 3600;
	MinNomValue = 0;

	// Error = 0.001;
}

void TMeterValue::SetAsPressure()
{
	ValueType = CONST_TYPE;
	Value = 98;
	SetFilter(-1);
	Accuracy = 4;

		Name = "Давление";
       Type = "Датчик";

    RawValueName = "Ток";
    RawValueDim = "мА";

		ShrtName = "P";
	SetDimension("Па", 1);
	SetDimension("гПа", 1, 100, false );
	SetDimension("кПа", 1, 1000, false);
	SetDimension("bar", 1, 100000, false);
	SetDimension("МПа", 1, 1000000, false);
	SetDim(3);

	MaxValue = 1600000;
	MinValue = -10000;

	MaxNomValue = 100000;
	MinNomValue = 0;

	Error = 0.5;

    CoefK = 100000;
    CoefP = -400000;

    SetValue((double)98);
}

void TMeterValue::SetAsCurrent()
{
	ValueType = CONST_TYPE;
	Value = 4;
	SetFilter(-1);
	Accuracy = 4;

		Name = "Ток";

		ShrtName = "I";
	SetDimension("мА", 1);
	SetDim(0);

	MaxValue = 20;
	MinValue = 0;

	MaxNomValue = 20;
	MinNomValue = 4;

	Error = 0.02;

    CoefK = 1;
    CoefP = 0;

    SetValue((double)4);
}

void TMeterValue::SetAsAirPressure()
{
	ValueType = CONST_TYPE;
	Value = 102124.64;
	SetFilter(-1);
	Accuracy = 4;

		Name = "Давление атм";
		ShrtName = "Pатм";
	SetDimension("Па", 1);
	SetDimension("гПа", 1, 100, false );
	SetDimension("мм.рт.ст.", 1, 133.32239023154, false );
	SetDimension("кПа", 1, 1000, false);

	SetDim(1);

	MaxValue = 1000000;
	MinValue = -10000;

	MaxNomValue = 103000;
	MinNomValue = 101000;

    CoefK = 10000;
    CoefP = -40000;


	Error = 0.1;
        SetValue((double)102124.64);
}

void TMeterValue::SetAsMassCoef()
{
	ValueType = CONST_TYPE;
	Value = 100;
	SetFilter(-1);
	Accuracy = 5;
	ShrtName = "Km";
	Name = "Коэфициент по массе";
	SetDimension("имп/кг", 1);
	SetDimension("кг/имп", 1, 1, true);

	SetDim(0);
	Error = 0.01;
	MaxValue = MAXDOUBLE;
	MinValue = 0.00000000001;
}

void TMeterValue::SetAsVolumeCoef()
{
	ValueType = CONST_TYPE;
	Value = 100;
	SetFilter(-1);
	Accuracy = 5;
	Error = 0.01;
	ShrtName = "Kv";
	Name = "Коэфициент по объему";

	SetDimension("имп/л", 1, 1, false);
	SetDimension("л/имп", 1, 1, true);
	SetDim(0);

	MaxValue = MAXDOUBLE;
	MinValue = 0.00000000001;


	}

void TMeterValue::SetAsHumidity(){
	ValueType = CONST_TYPE;
	Value = 35;
	SetFilter(-1);
	Accuracy = 4;
	Name = "Влажность";
	ShrtName = "φ атм";
	SetDimension("%", 1);
	SetDim(0);

	MaxValue = 100;
	MinValue = 0;

	MaxNomValue = 60;
	MinNomValue = 20;

	}

UnicodeString TMeterValue::GetStringValue(uint8_t Dim)
{
    double value = GetDoubleValue(Dim);

	if (Value<MinValue) {
	   return "-";
	}

	if (Value>MaxValue) {
	   return "+NAN";
	}

    return FormatValue(value, Accuracy, Error);

}

UnicodeString TMeterValue::GetStringMeanValue(uint8_t Dim) {

	 double value = GetDoubleMeanValue(Dim);

	if (Value<MinValue) {
	   return "-";
	}

	if (Value>MaxValue) {
	   return "+NAN";
	}

    return FormatValue(value, Accuracy, Error);
}

UnicodeString TMeterValue::GetStringMeanValue() {
   return GetStringMeanValue(0);
}

UnicodeString TMeterValue::GetStringValue(UnicodeString Dim) {

	return GetStringValue(GetDim(Dim));
}

UnicodeString TMeterValue::GetStringValue() {

	return GetStringValue(0);
}

UnicodeString TMeterValue::GetStrValue() {

	return GetStringValue(CurrentDimIndex);
}

UnicodeString TMeterValue::GetStringNum(double value) {
	double temp = Value;
	UnicodeString str;
	 Value = value;

	 str = GetStringValue();

	 Value = temp;

	return str;
}

UnicodeString TMeterValue::GetStrNumLimits(double value) {
	double temp = Value;
	UnicodeString str;
	 Value = value;

	 str = GetStringValue(CurrentDimIndex);

	 Value = temp;

	return str;
}

UnicodeString TMeterValue::GetStrNum(double value) {

	double temp = Value;
	UnicodeString str;
	 Value = value;

    double dbl = GetDoubleValue(CurrentDimIndex);

	 str = FormatValue(dbl, Accuracy, Error);

	 Value = temp;

	return str;
}

UnicodeString TMeterValue::GetStrNum(UnicodeString strvalue, UnicodeString Dim) {
	double temp = Value;
	UnicodeString str;
	double value;

    TryStrToDouble_(strvalue, value);

	 Value = value;

	 str = GetStringValue(Dim);

	 Value = temp;

	return str;
}

UnicodeString TMeterValue::GetStrNum(UnicodeString strvalue) {
	double temp = Value;
	UnicodeString str;
	double value;

    TryStrToDouble_(strvalue, value);

	 Value = value;

	 str = GetStringValue();

	 Value = temp;

	return str;
}

UnicodeString TMeterValue::GetStrNum(double value, UnicodeString Dim) {
	double temp = Value;
	UnicodeString str;
	 Value = value;

	 str = GetStringValue(Dim);

	 Value = temp;

	return str;
}

double TMeterValue::GetDoubleNum(UnicodeString str) {

	double temp = Value;

	 double value;

	 int fo =  filter_order ;
	  filter_order = -1  ;

	 SetDimValue(str);


	 filter_order = fo;

	 value = Value;

	 Value = temp;

	return value;
}

double TMeterValue::GetDoubleNum(double value, UnicodeString Dim) {

	double temp = Value;
	double dbl;
	 Value = value;

     	 int fo =  filter_order ;
	  filter_order = -1  ;

	 dbl = GetDoubleValue(Dim);

	 Value = temp;
     filter_order = fo;

	return dbl;
}

double TMeterValue::GetDoubleNum(UnicodeString str, int Dim) {

	double temp = Value;
	double dbl;

     SetDimValue(str);

	 dbl = GetDoubleValue(Dim);

	 Value = temp;

	return dbl;
}

UnicodeString  TMeterValue::GetStrFullName()
{
	return Name + ", " + GetDimName();
}

void TMeterValue::Reset() {

	filter_rd = 0;
	filter_wr = 0;
	filter_cnt = 0;
	LastMean = 0;

    temp_delta = 0;

	Values.clear();
	RawValues.clear();
	AverValues.clear();

    Value = 0;

}

bool TMeterValue::IsStable(int lim) {

	float flt, limit, val, mean = 0;
	int delta, start_pos = 0, pos;
	bool nulls;

	if (filter_order > 0) {

		if (AverValues.size() > filter_order) {
			delta = filter_order;
		}
		else {
			return false;
		}

		nulls = false;

		limit = ((Mean * lim) / 100);

		for (int i = 0; i < filter_order; i++) {
			val = AverValues[i];
			if ((fabs(Mean - val)) > limit) {
				return false;
			}
		}
	}
	return true;
}

bool TMeterValue::SetDim(int Dim) {

	if (Dim<Dimensions.size()) {
		if (GetDim(Dim, CurrentDim)) {
		 CurrentDimIndex = Dim;
            return true;
        }
    }
	return false;
}


bool TMeterValue::NextDim() {

  int dim =  CurrentDimIndex+1;


	if (dim<Dimensions.size())
	{
		SetDim(dim) ;
		return true;
	} else
	{
		SetDim(0);
		return false;
	}
}

void TMeterValue::Random()
{

double addvalue;
double value;
double temp;
double error;
double err = Error;

	temp = ((rand() % 100) - 50);
	temp = temp / 100;

	error = (Value * err)/100;

	addvalue = error *  temp;


	value = Value + addvalue;

	if (value > MaxNomValue) {
		Value = MaxNomValue - abs(addvalue);
	}

	else if (value < MinNomValue) {
		Value = MinNomValue + abs(addvalue);
	}

	else
	{
	   Value = value;
    }
}

/*
double   TMeterValue:: do_calc (double x, double y, double z)
{
  double result;

 if (Name == "Плотность") {
  // x - temp , y - pressure, z - плотность разница

  result =(999.9744*((1-((x+(-3.983035))^2)*(x+301.797)/(522528.9*(x+69.34881))))+(-4.612*10^(-3)+0.106*10^(-3)*x))+y+(z/0.02*0.01)
 }   else
 {

     return  x*y;

 }



}
 */
void TMeterValue::SetCalcValue()
{
    double result;
	double value=0;
     double t, P, Dens;
   double dens , d, d2, t3, t2, t4, d5, p;



  if (Name == "Плотность") {
  // x - temp , y - pressure, z - плотность разница
    if ((ValueBaseMultiplier != nullptr)||(ValueBaseDevider != nullptr))
	{
    t = ValueBaseMultiplier->Value;
    P = ValueBaseDevider->Value;
    Dens =  (TSettingsClass::InitDensity*1000 - 998.204) + 1.7675;

    p = (P / 20000 * 0.01);
    t2 = pow((t + (-3.983035)), 2);
    t3=    (522528.9 * (t + 69.34881));
    t4 = (-4.612 * pow(10, -3) + 0.106 * pow(10, -3) * t);

    d2 = (1 - t2 * (t + 301.797) / t3 );
    d = (998.204 * d2) + t4;
    result = d + Dens + p;

    SetValue(result/1000);

    }
 }   else
   {

   }
}

int TMeterValue::GetHashToSave(TMeterValue *MeterValue)
{

   if (MeterValue==nullptr) {
    return 0;
   }

     for (int j = 0; j < MeterValues.size(); j++)
           {
                  if (MeterValues[j]->Hash==MeterValue->Hash)
               {
                  if (MeterValue->IsToSave) {
                     return MeterValue->Hash;
                  } else
                  {
                      return 0;
                  }

               }
           }

 return 0;
}

int TMeterValue::GetNewHash()
{
 int  maxHash = 0;

     for (int j = 0; j < MeterValues.size(); j++)
           {
                  if (MeterValues[j]->Hash>maxHash)
               {
                    maxHash = MeterValues[j]->Hash;
               }
           }

 return maxHash + 1;
}

int TMeterValue::GetNewHashCoef()
{
 int  maxHash = 0;

     for (int j = 0; j < Coefs.size(); j++)
           {
                  if (Coefs[j].Hash>maxHash)
               {
                    maxHash = Coefs[j].Hash;
               }
           }

 return maxHash + 1;
}

 void TMeterValue::DeleteFromVector()
 {
    int index;

        for (int i = 0; i <  MeterValues.size(); i++)
    {
		if (Hash == MeterValues[i]->Hash)
        {
           index = i;
			break;
		}
	}

    TMeterValue::MeterValues.erase(
                    TMeterValue::MeterValues.begin() + index);
 }


void TMeterValue::SaveToFile(int IsBackUp)
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

    rootNode = XmlDoc->AddChild("MeterValues");

    // CheckStoragePermission_(this);

    MeterValuesSaves.clear();

    if (!MeterValues.empty()) {
        rootNode->SetAttribute("VER", "1.0");

        k = MeterValues.size();


        for (int j = 0; j < MeterValues.size(); j++) {
          if (MeterValues[j]->IsToSave == true)
            {
             MeterValuesSaves.push_back(MeterValues[j]);
            }


      //  while (l < MeterValues.size()) {

      //          TMeterValue::MeterValues.erase(
      //              TMeterValue::MeterValues.begin() + l);
       //     } else {
       //         l = l + 1;
       //     }
        }

        rootNode->SetAttribute("ValuesCount", IntToStr((int)MeterValuesSaves.size()));

        for (int j = 0; j < MeterValuesSaves.size(); j++) {
            sampleNode = rootNode->AddChild("MeterValue" + IntToStr(j));

            {
                sampleNode->SetAttribute("Hash", MeterValuesSaves[j]->Hash);



                SetBoolAttribute("IsToSave", sampleNode, MeterValuesSaves[j]->IsToSave);

                SetIntAttribute("HashOwner", sampleNode, MeterValuesSaves[j]->HashOwner);
                sampleNode->SetAttribute("NameOwner", MeterValuesSaves[j]->NameOwner);

				SetAttribute("Name",sampleNode,MeterValuesSaves[j]->Name);
                SetAttribute("ShrtName",sampleNode,  MeterValuesSaves[j]->ShrtName);
                SetAttribute("Description",sampleNode ,MeterValuesSaves[j]->Description);

                SetAttribute("Type",sampleNode ,MeterValuesSaves[j]->Type);

                SetAttribute("RawValueName",sampleNode ,MeterValuesSaves[j]->RawValueName);
                SetAttribute("RawValueDim",sampleNode ,MeterValuesSaves[j]->RawValueDim);

                SetIntAttribute("HashValueRate", sampleNode, MeterValuesSaves[j]->HashValueRate);
                SetIntAttribute("HashValueBaseMultiplier", sampleNode, MeterValuesSaves[j]->HashValueBaseMultiplier);
                SetIntAttribute("HashValueBaseDevider", sampleNode, MeterValuesSaves[j]->HashValueBaseDevider);
                SetIntAttribute("HashValueCorrection", sampleNode, MeterValuesSaves[j]->HashValueCorrection);
                SetIntAttribute("HashValueEtalon", sampleNode, MeterValuesSaves[j]->HashValueEtalon);


                SetIntAttribute("filter_order", sampleNode, MeterValuesSaves[j]->filter_order);

                SetIntAttribute("Accuracy", sampleNode, MeterValuesSaves[j]->Accuracy);

				SetDoubleAttribute("FlowMax", sampleNode, MeterValuesSaves[j]->MaxValue);

                SetDoubleAttribute("Error", sampleNode, MeterValuesSaves[j]->Error);

                SetDoubleAttribute("MaxValue", sampleNode, MeterValuesSaves[j]->MaxValue);
                SetDoubleAttribute("MinValue", sampleNode, MeterValuesSaves[j]->MinValue);
                SetDoubleAttribute("MaxNomValue", sampleNode, MeterValuesSaves[j]->MaxNomValue);
                SetDoubleAttribute("MinNomValue", sampleNode, MeterValuesSaves[j]->MinNomValue);

                SetDoubleAttribute("CoefK", sampleNode, MeterValuesSaves[j]->CoefK);
                SetDoubleAttribute("CoefP", sampleNode, MeterValuesSaves[j]->CoefP);



                SetIntAttribute("CurrentDimIndex", sampleNode, MeterValuesSaves[j]->CurrentDimIndex);

                sampleNode2 = sampleNode->AddChild("Dimensions");
                sampleNode2->SetAttribute(
                    "DimensionsCount", IntToStr((int)MeterValuesSaves[j]->Dimensions.size()));

                if (!MeterValuesSaves[j]->Dimensions.empty()) {
                    for (int i = 0; i < MeterValuesSaves[j]->Dimensions.size(); i++) {

                    sampleNode2 =
                            sampleNode->AddChild("Dimension" + IntToStr(i));

					   //	SetAttribute("Name",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Name);
                        SetAttribute("Name",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Name);
                        SetAttribute("Hash",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Hash);
                        SetDoubleAttribute("Rate",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Rate);
                        SetDoubleAttribute("Devider",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Devider);
                        SetBoolAttribute("Factor",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Factor);
                        SetBoolAttribute("Recip",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Recip);
						//SetIntAttribute("IsRageFree",sampleNode2,MeterValuesSaves[j]->Dimensions[i].IsRageFree);

                    }
                }
                sampleNode2 = sampleNode->AddChild("Coefs");
                sampleNode2->SetAttribute(
                "CoefsCount", IntToStr((int)MeterValuesSaves[j]->Coefs.size()));

                                if (!MeterValuesSaves[j]->Coefs.empty()) {
                    for (int i = 0; i < MeterValuesSaves[j]->Coefs.size(); i++) {

                         sampleNode2 =
                            sampleNode->AddChild("Coef" + IntToStr(i));

					   //	SetAttribute("Name",sampleNode2,MeterValuesSaves[j]->Dimensions[i].Name);
                        SetAttribute("Name",sampleNode2,MeterValuesSaves[j]->Coefs[i].Name);
                        SetIntAttribute("Hash",sampleNode2,MeterValuesSaves[j]->Coefs[i].Hash);
                        SetIntAttribute("Index",sampleNode2,MeterValuesSaves[j]->Coefs[i].Index);

                        SetDoubleAttribute("Value",sampleNode2,MeterValuesSaves[j]->Coefs[i].Value);
                        SetDoubleAttribute("Arg",sampleNode2,MeterValuesSaves[j]->Coefs[i].Arg);
                        SetDoubleAttribute("Q1",sampleNode2,MeterValuesSaves[j]->Coefs[i].Q1);
                        SetDoubleAttribute("Q2",sampleNode2,MeterValuesSaves[j]->Coefs[i].Q2);
                        SetDoubleAttribute("K",sampleNode2,MeterValuesSaves[j]->Coefs[i].K);
                        SetDoubleAttribute("b",sampleNode2,MeterValuesSaves[j]->Coefs[i].b);

                        SetBoolAttribute("InUse",sampleNode2,MeterValuesSaves[j]->Coefs[i].InUse);

						//SetIntAttribute("IsRageFree",sampleNode2,MeterValuesSaves[j]->Dimensions[i].IsRageFree);

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
                System::Ioutils::TPath::DirectorySeparatorChar + "MeterValues" +
				System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
        XmlDoc->SaveToFile(fname);

    } else {
        fname = TSettingsClass::Dir +
				System::Ioutils::TPath::DirectorySeparatorChar +
                "MeterValuesBackUp" + IntToStr(IsBackUp) +
				System::Ioutils::TPath::ExtensionSeparatorChar + "xml";
    }

    // XmlDoc->L
    XmlDoc->Active = false;
}


void TMeterValue::LoadFromFile()
{

    bool success = true;

    XmlDoc = nullptr;
    rootNode = nullptr;
    sampleNode = nullptr;

    TMeterValue *MeterValue;

    String str;

    int Size;
    int DimensionsSize;
    int CoefsSize;
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
            System::Ioutils::TPath::DirectorySeparatorChar + "MeterValues" +
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
        SaveToFile(0);
    }

    document = LoadXMLDocument(fname);

    if (document == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    TMeterValue::MeterValues.clear();

    rootNode = document->ChildNodes->FindNode("MeterValues");

    if (rootNode == NULL) {
        Result = "Файл пустой или поврежден";
        throw Exception(Result);
    }

    VER = rootNode->Attributes["VER"];

    Size = GetIntAttribute("ValuesCount", rootNode, 0);

    for (int j = 0; j < Size; j++) {
        sampleNode = rootNode->ChildNodes->FindNode("MeterValue" + IntToStr(j));

        if (sampleNode != NULL) {
        /*    if (sHSC == nullptr) {
               MeterValue = new TMeterValue();
            } else {
                MeterValue = new TFlowMeter();
            }
          */

             MeterValue = new TMeterValue();

			MeterValue->Hash = 	GetIntAttribute("Hash", sampleNode);
			MeterValue->Name = 	GetAttribute("Name", sampleNode);

            MeterValue->HashOwner = 	GetIntAttribute("HashOwner", sampleNode);
            MeterValue->NameOwner = 	GetAttribute("NameOwner", sampleNode);

            MeterValue->ShrtName  =   GetAttribute("ShrtName",sampleNode);
            MeterValue->Description = GetAttribute("Description",sampleNode);
            MeterValue->Type = GetAttribute("Type",sampleNode);

            MeterValue->RawValueName = GetAttribute("RawValueName",sampleNode);
            MeterValue->RawValueDim = GetAttribute("RawValueDim",sampleNode);

            MeterValue->IsToSave= GetBoolAttribute("IsToSave", sampleNode, false);

            MeterValue->HashValueRate= GetIntAttribute("HashValueRate", sampleNode, 0);
            MeterValue->HashValueBaseMultiplier= GetIntAttribute("HashValueBaseMultiplier", sampleNode, 0);
            MeterValue->HashValueBaseDevider= GetIntAttribute("HashValueBaseDevider", sampleNode, 0);
            MeterValue->HashValueCorrection= GetIntAttribute("HashValueCorrection", sampleNode, 0);
            MeterValue->HashValueEtalon= GetIntAttribute("HashValueEtalon", sampleNode, 0);
            MeterValue->filter_order =  GetIntAttribute("filter_order", sampleNode, 0);

            MeterValue->Accuracy  =  GetIntAttribute("Accuracy", sampleNode, 0);

            MeterValue->MaxValue =  GetDoubleAttribute("MaxValue", sampleNode, 0);
            MeterValue->MinValue  = GetDoubleAttribute("MinValue", sampleNode, 0);
            MeterValue->MaxNomValue = GetDoubleAttribute("MaxNomValue", sampleNode, 0);
            MeterValue->MinNomValue  = GetDoubleAttribute("MinNomValue", sampleNode, 0);

            MeterValue->CoefK  = GetDoubleAttribute("CoefK", sampleNode, 1);
            MeterValue->CoefP  = GetDoubleAttribute("CoefP", sampleNode, 0);

            MeterValue->Error =  GetDoubleAttribute("Error", sampleNode, 0);

            MeterValue->CurrentDimIndex  = GetIntAttribute("CurrentDimIndex", sampleNode, 0);

      // MeterValue->FlowMax = GetDoubleAttribute("FlowMax", sampleNode,0);

        sampleNode2 = sampleNode->ChildNodes->FindNode("Dimensions");

        DimensionsSize = sampleNode2->Attributes["DimensionsCount"];

        if (DimensionsSize > 0) {
            MeterValue->Dimensions.clear();

            for (int i = 0; i < DimensionsSize; i++) {

                sampleNode2 =
                    sampleNode->ChildNodes->FindNode("Dimension" + IntToStr(i));

				if (sampleNode2 != NULL) {

                  	Dimension Dim;

                   Dim.Name=     GetAttribute("Name",sampleNode2);
                   Dim.Hash=     GetIntAttribute("Hash",sampleNode2);
                   Dim.Rate=     GetDoubleAttribute("Rate",sampleNode2,0);
                   Dim.Devider=     GetDoubleAttribute("Devider",sampleNode2,0);
                   Dim.Factor=     GetBoolAttribute("Factor",sampleNode2);
                   Dim.Recip=     GetBoolAttribute("Recip",sampleNode2);

                   MeterValue->Dimensions.push_back(Dim);
                }


            }




        }

        sampleNode2 =  sampleNode->ChildNodes->FindNode("Coefs");

        CoefsSize = sampleNode2->Attributes["CoefsCount"];

        if (CoefsSize > 0) {
            MeterValue->Coefs.clear();

            for (int i = 0; i < CoefsSize; i++) {

                sampleNode2 =
                    sampleNode->ChildNodes->FindNode("Coef" + IntToStr(i));

				if (sampleNode2 != NULL) {

                       tCoef coef;

                        coef.Name= GetAttribute("Name",sampleNode2);
                        coef.Hash= GetIntAttribute("Hash",sampleNode2,0);
                        coef.Index= GetIntAttribute("Index",sampleNode2,0);

                        coef.Value=GetDoubleAttribute("Value",sampleNode2,0);
                        coef.Arg=GetDoubleAttribute("Arg",sampleNode2,0);
                        coef.Q1=GetDoubleAttribute("Q1",sampleNode2,0);
                        coef.Q2=GetDoubleAttribute("Q2",sampleNode2,0);
                        coef.K=GetDoubleAttribute("K",sampleNode2,0);
                        coef.b=GetDoubleAttribute("b",sampleNode2,0);

                        coef.InUse=GetBoolAttribute("InUse",sampleNode2);

                       MeterValue->Coefs.push_back(coef);
                  }
            }
        }



       } else {
            Result = "Файл пустой или поврежден";
            throw Exception(Result);
        }


    }

    /* }	else
	{

				Result = "Версия не может быть обработана";
				throw Exception(Result);
 *///	}
}

 int TMeterValue::SetCoef(double value, double arg)
  {
     tCoef coef;

     coef.Value = value;
     coef.Arg = value;


      SetCoef(coef);

      return   coef.Hash;
  }



 void TMeterValue::SetCoef(tCoef coef)
{
   coef.Hash = GetNewHashCoef();
   Coefs.push_back(coef);
}

 void TMeterValue::CalcCoefs()
{
    double K, P;
    double k1, k2;
    tCoef *coef1;
    tCoef *coef2;

   //coef.Hash = GetNewHashCoef();
   //Coefs.push_back(coef);

    SortCoefs(true);


    if (Coefs.size()== 0) {
        return;
    }

    else if ( Coefs.size()== 1) {


          coef1 = &Coefs[0];

          K = coef1->Arg/coef1->Value;

          P = 0;

          coef1->K = K;
          coef1->b = P;

          coef1->Q1 = MinValue;
          coef1->Q2 = MaxValue;

    }
    else
    {

   for (int i = 1; i < Coefs.size(); i++)
   {

    coef1 = &Coefs[i-1];
    coef2 = &Coefs[i];

    k1 = coef1->Arg - coef2->Arg;
    k2 = coef1->Value - coef2->Value;

    K = k2/k1;

    P =  coef2->Value - K * coef2->Arg;

    if (i==1) {

      coef1->Q1 = (coef1->Arg>MinValue)? MinValue:coef1->Arg;
      coef1->Q2 = coef1->Arg;
      coef1->K = K;
      coef1->b = P;

    }

    coef2->Q1 = coef1->Q2;
    coef2->Q2 = coef2->Arg;

    coef2->K = K;
    coef2->b = P;

    }

     coef2 = &Coefs[Coefs.size()-1];
     coef2->Q2 = (coef2->Arg<MaxValue)? MaxValue:coef2->Arg;
     }


}


void TMeterValue::SortCoefs(bool ascending)
{
    // Сортировка вектора по свойству DN
   //	std::sort(Coefs.begin(), Coefs.end(),
	 //	[](tCoef a, tCoef b) { return a.Value < b.Value; });
    auto compare = [ascending](const tCoef &a, const tCoef &b) {
        return ascending ? (a.Value < b.Value) : (a.Value > b.Value);
    };

    std::sort(Coefs.begin(), Coefs.end(), compare);
}

void TMeterValue::SortByValueCoefs(bool ascending)
{
    // Сортировка вектора по свойству DN
   //	std::sort(Coefs.begin(), Coefs.end(),
	 //	[](tCoef a, tCoef b) { return a.Value < b.Value; });
    auto compare = [ascending](const tCoef &a, const tCoef &b) {
        return ascending ? (a.Value < b.Value) : (a.Value > b.Value);
    };

    std::sort(Coefs.begin(), Coefs.end(), compare);
}

void TMeterValue::SortByArgCoefs(bool ascending)
{
    // Сортировка вектора по свойству DN
   //	std::sort(Coefs.begin(), Coefs.end(),
	 //	[](tCoef a, tCoef b) { return a.Value < b.Value; });
    auto compare = [ascending](const tCoef &a, const tCoef &b) {
        return ascending ? (a.Arg < b.Arg) : (a.Arg > b.Arg);
    };

    std::sort(Coefs.begin(), Coefs.end(), compare);
}



tCoef TMeterValue::GetCoef(int hash)
{


     for (int i = 0; i < Coefs.size(); i++)
   {
      if (Coefs[i].Hash== hash) {
          return  Coefs[i];
      }
   }

   return Coefs[0];
}


int TMeterValue::GetCoefIndex(int hash)
{


     for (int i = 0; i < Coefs.size(); i++)
   {
      if (Coefs[i].Hash== hash) {
          return  i;
      }
   }

   return 0;
}


bool TMeterValue::CompareByValueDescending(const tCoef &a, const tCoef &b, bool MaxMin)
{
     if (MaxMin) {
    return a.Value < b.Value;
     }  else
     {
    return a.Value > b.Value;
     }
}

UnicodeString  TMeterValue::GetRawValueFullName()
{
	return RawValueName + ", " + RawValueDim;
}






































































