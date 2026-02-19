//---------------------------------------------------------------------------

#ifndef TMeterValueH
#define TMeterValueH
//---------------------------------------------------------------------------
#include "UserRoutines.h"
#include <math.h>
// #include <ustring.h>

#include <vector>
#include <deque>

 #include <time.h>
  #include <System.DateUtils.hpp >
#include "TFlowMeterType.h"


//#define ARRAY_SIZE 100

  typedef enum EUPDATETYPE
 {
	 OFFLINE_TYPE = 0,
	 ONLINE_TYPE = 1,
	 HAND_TYPE = 2,
 } eUpdateType;


 typedef enum EVALUETYPE
 {
	 FLOW_TYPE = 0,
	 SUM_TYPE = 1,
	 CONST_TYPE = 2,
	 ERROR_TYPE = 3
 } eValueType;

  typedef enum EDEPTYPE
 {
	 INDEPENDENT = 0,
	 DEPENDENT = 1
 } eDependenceType;

 typedef struct TDimension
 {
     UnicodeString Name;
     int Hash;
     double Rate = 1;
     double Devider = 1;
	 bool Factor = false;
     bool Recip = false;
} Dimension;


typedef struct TCoef
{
    UnicodeString Name;
    int           Index;
    int       Hash;
    double   Value;
    double   Arg;
    double   Q1; //
    double	 Q2;     //
	double   K;     //
    double   b; //
    bool     InUse;

} tCoef;

class TMeterValue
{
	private:

	int filter_order=-1;
	int filter_rd=0;
	int filter_wr=0;
	int filter_cnt=0;



	int average_order=1;

	float LastMean = 0;
	float ShortMean;
    double Rawvalue = 0;

    double factor;
    double devider;
  public:

    double ValueWoCorrection = 0;

    int temp_delta = 3;
    int Short_Mean_index = 3; //Порядок фильтра при резком изменении.

    int Hash;
    int HashOwner;
    UnicodeString NameOwner;

    bool IsToSave = false;

    double Value;
    double Mean;
    int MeanCnt = 0;
    vector<double> Means;

    static TXMLDocument* XmlDoc;
    static _di_IXMLNode rootNode;
    static _di_IXMLNode sampleNode;
    static _di_IXMLNode sampleNode2;
    static _di_IXMLNode sampleNode3;
    static UnicodeString dirName;
    static UnicodeString fname;

    vector<Dimension> Dimensions;

    eValueType ValueType = CONST_TYPE;
    eDependenceType DependenceType = INDEPENDENT;
    eUpdateType UpdateType = OFFLINE_TYPE;

    TMeterValue* ValueRate = nullptr;
    TMeterValue* ValueBaseMultiplier= nullptr;
    TMeterValue* ValueBaseDevider= nullptr;
    TMeterValue* ValueCorrection= nullptr;
    TMeterValue* ValueEtalon= nullptr;

    int HashValueRate;
    int HashValueBaseMultiplier;
    int HashValueBaseDevider;
    int HashValueCorrection;
    int HashValueEtalon;

    int CurrentDimIndex = 0;
    Dimension CurrentDim;

    int filter_short_order = 3;
    float filter_short_delta = 3;

    UnicodeString Name;
    UnicodeString ShrtName;
    UnicodeString Description;

    UnicodeString Type;
    UnicodeString RawValueName;
    UnicodeString RawValueDim;

    TMeterValue();
    TMeterValue(int hash, UnicodeString name);
    TMeterValue(TMeterValue* MeterValue);
    TMeterValue(int hash);

    void SetCopy(TMeterValue* MeterValue);
    static TMeterValue* GetNewMeterValue(int hash);
    static TMeterValue* GetNewMeterValueBool(int hash, int &IsExisted, int HashOwner, UnicodeString Name);
    static TMeterValue* GetCopyMeterValueBool(int &hash, int &IsExisted);
    static TMeterValue* GetExistedMeterValueBool(int &hash, int &IsExisted, int HashOwner, UnicodeString Name);
    //virtual  __fastcall ~TMeterValue();

    uint8_t Accuracy = 5;
    double Error = 5; //Допустиммая погрешность в процентах
    int ARRAY_SIZE = 1000;

    double CoefK = 1, CoefP = 0;

    double MaxValue = MAXDOUBLE;
    double MinValue = MINDOUBLE;

    double MaxNomValue = MAXDOUBLE;
    double MinNomValue = MINDOUBLE;

    void Random();

    float GetFloatValue();
    float GetFloatValue(uint8_t Dim);
    float GetFloatValue(UnicodeString);

    double FilterApply();
    float AverageApply();

    double GetDoubleValue();
    double GetDoubleValue(UnicodeString);
    double GetDoubleValue(uint8_t Dim);
    double  GetDoubleValueDim();

    double GetDoubleMeanValue(UnicodeString DimName);
    double GetDoubleMeanValue(uint8_t dim);
    double GetDoubleMeanValue();

    bool IsStable(int lim);
    UnicodeString GetStrValue();
    UnicodeString GetStringValue();
    UnicodeString GetStringValue_(uint8_t IntSigns, uint8_t FractSigns);
    UnicodeString GetStringValue_(
        uint8_t IntSigns, uint8_t FractSigns, uint8_t Dim);
    UnicodeString GetStringValue_(
        uint8_t IntSigns, uint8_t FractSigns, UnicodeString Dim);

    UnicodeString GetStringValue(uint8_t Dim); //Auto Transform
    UnicodeString GetStringValue(UnicodeString Dim);

    UnicodeString GetStringMeanValue(uint8_t Dim);
    UnicodeString GetStringMeanValue();

    UnicodeString GetStringDimensionsValue(
        uint8_t IntSigns, uint8_t FractSigns);

    UnicodeString GetStrNum(double value);
    UnicodeString GetStrNum(double value, UnicodeString Dim);

    UnicodeString GetStrNumLimits(double value);

    UnicodeString GetStrNum(UnicodeString value, UnicodeString Dim);
	UnicodeString GetStrNum(UnicodeString value);

    UnicodeString GetStringNum(double value);

    void SetFilter(int);
    int GetFilter();

    void SetRawValue(double InputValue);
    void SetRawValue(double InputValue, float Q);

    void SetMainValue(double InputValue, float Q);
    void SetMainValue(double InputValue);

    void SetValue();

    void SetValue(float Value);
    void SetValue(double Value);
    // void SetValue(double Value, double CorrectionValue);
    void SetValue(double Value, uint8_t Dim);
    void SetValue(double Value, UnicodeString Dimensions);

    void SetAddValue(double InputValue);

    void SetDimValue(double value);
    void SetDimValue(UnicodeString str);

    void SetValue(UnicodeString value);

    void SetAsTime();

    double Rate(double Q);
    int8_t UpdateCoefs(vector<tCalibrPoint> CalibrPoints);

    void SetValueCurrnet(double Value);

    void SetDimension(UnicodeString Dimensions, double DimRate);
    void SetDimension(
        UnicodeString Name, double Rate, double Devider, bool Recip);

    void SetDimension(UnicodeString ShrtName, UnicodeString Name, double Rate,
        double Devider, bool Recip);

    double GetDimRate(UnicodeString Name);
    double GetDimRate(int Dim);

    UnicodeString GetShrtName();
    UnicodeString GetDimName();
    UnicodeString GetDimName(int Dim);
    UnicodeString GetDimName(UnicodeString Name);
    bool GetDim(UnicodeString Name, Dimension &Dim);
    int GetDim(UnicodeString Name);
    bool GetDim(int index, Dimension &Dim);
    int GetDim();

    bool SetDim(int Dim);
    bool NextDim();

    UnicodeString GetStrFullName();
    double GetDoubleNum(UnicodeString str);
    double GetDoubleNum(double value, UnicodeString Dim);
    double GetDoubleNum(double value, int Dim);
    double GetDoubleNum(UnicodeString str, int Dim);
    void Reset();

    void SetAsVolume();
    void SetAsMass();
    void SetAsVolumeFlow();
    void SetAsMassFlow();
    void SetAsImp();
    void SetAsError();
    void SetAsCurrent();

    void SetAsVolumeError();
    void SetAsMassError();

    void SetAsMassCoef();
    void SetAsVolumeCoef();

    void SetAsTemp();
    void SetAsPressure();
    void SetAsDensity();
    void SetAsHumidity();

    void SetAsAirPressure();
    void SetAsAirTemp();

    std::deque<double> RawValues;
    std::deque<double> Values;
    std::deque<float> AverValues;

    tCoef Coef;
    vector<tCoef> Coefs;

    static bool FinalValue;

    void SetCalcValue();

    static vector<TMeterValue*> MeterValues;
    static vector<TMeterValue*> MeterValuesSaves;

    int GetNewHash();

    static void SaveToFile(int IsBackUp);
    static void LoadFromFile();

    static TMeterValue* GetMeterValue(int Hash);
    static TMeterValue* GetMeterValue(
        int hash, int HashOwner, UnicodeString Name);



    void SetCoef(tCoef coef);
    int SetCoef(double value, double arg);

    int GetNewHashCoef();
    void CalcCoefs();

    double CalculateTemperature(double Rt, double R0 = 100.0);
    void SortCoefs(bool MaxMin);
    tCoef GetCoef(int hash);

    int GetCoefIndex(int hash);


    void SetToSave(bool isToSave);
    void DeleteFromVector();

     static int GetHashToSave(TMeterValue *MeterValue);

     bool CompareByValueDescending(const tCoef &a, const tCoef &b, bool MaxMin);

     void SortByValueCoefs(bool ascending);
     void SortByArgCoefs(bool ascending);

     UnicodeString  GetRawValueFullName();
};

#endif





