//---------------------------------------------------------------------------

#ifndef TFlowMeterH
#define TFlowMeterH

#include "TMeterDevice.h"

//---------------------------------------------------------------------------

#define CHANNEL 2
#define XMLVERFLOWMETERS "5.0"





class TFlowMeter : public TMeterDevice
{
  public:

         TFlowMeter(TFlowMeter* Meter);
    TFlowMeter(THscDevice* HSCDevice, TFlowMeter* EtalonMeter);

    TFlowMeter(THscDevice* HSCDevice, int ID_Order, bool IsEtalon);
    TFlowMeter(THscDevice* HSCDevice, bool IsEtalon);
    TFlowMeter(THscDevice* HSCDevice, bool IsEtalon, int hash);
    TFlowMeter(bool IsEtalon);
     __fastcall ~TFlowMeter();

    void SetHSC(THscDevice* HSCDevice)
    {
        HSCDevice = this->HSCDevice;
    };

	TFlowMeterType* Type;

	void SetType(TFlowMeterType* Type);
	bool SetType(int typeHash);

	void SetCopy(TFlowMeter* Meter) ;

    int Hash =0;
    int DeviceHash;
    int TypeHash;
    int OrderHash;

    bool IsEtalon;
    int Active;
    static int ActiveEtalonHash;
	static int ActiveFlowMeterHash;

    void SetActiveEtalon();
    void SetActiveEtalon(TFlowMeter* FlowMeter);
    void SetActiveTestMeter();
    int CheckType;

    int Status = 0; // 0 - Создан , 1 - Есть данные, 1 - Есть данные, не годен,
		// 2 - Есть данные, годен,

	UnicodeString GetStatus();
	void SetStatus(UnicodeString);


	int SendStatus = 0; // 0 - не отправлен 1- отправляется  2- отправлен
    UnicodeString GetSendStatus();

    void SetSendStatus(UnicodeString text);

	UnicodeString Name;


	UnicodeString FlowTypeName;


	// Тип поверяемого устройства
    UnicodeString DeviceType;
	UnicodeString Modifications;
    UnicodeString Modification;
    int ID_Order;
    int VerificationInterval;
    UnicodeString miOwner;
    //
    // Серийный номер поверяемого устройства
    UnicodeString SerialNum;
    //
    // Номер ГРСИ поверяемого устройства
    UnicodeString CertificateNum;

    UnicodeString DN;
    UnicodeString docTitle;

    UnicodeString Adress;

    UnicodeString doc_number;
    static UnicodeString sign_cipher;
    static UnicodeString porveritel_fio;

    UnicodeString means;

    UnicodeString year_production;

    UnicodeString K1, P1, K2, P2;

    UnicodeString tempWater, temperature, pressure, hymidity;

    UnicodeString vrfDate;
    UnicodeString validDate;

    UnicodeString Data1, Data2, Data3;

    UnicodeString Date1, Date2;

    UnicodeString Result = "-";

    TDateTime DateTime; //дата и время измерения

    UnicodeString ModifidedDateTime;

    //
    // Коэффициент преобразования
    double Kp;
    double FactoryKp;
    double FreqMax;
    //
    // Калибровочные коэфициенты
    double K[100];
    double Q[100];

    //Настройки прибора

	double FlowMax;
    double FlowMin;
     //Qmax
    double QuantityMax;
	double QuantityMin;


    double Error;
    //Текущий расход
    double Flow(void); // Расход с поправками
	double GetRawFlow(void); // Расход без поправок

	//Текущий объем
    float Volume(void);

    //

    uint8_t GetChannel(void);
    void SetChannel(uint8_t Channel);

	double GetImpKoef(void)
    {
        return Kp;
    };
    float GetImpCoef(void)
    {
        return Kp;
    };
    float GetKoef(void)
    {
        return Kp;
    };

    void SetImpCoef(double K);

    UnicodeString GetKoefStr(void)
    {
        return FloatToStr(Kp);
    };
    void SetKoef(float K)
    {
        Kp = K;
    };

    void SaveCoef(void);
    //void UpdateCoefs();

    void SetImpKoef(float K)
    {
        SetImpKoef((double)K);
    };

    void SetImpCoef(float K)
    {
        Kp = K;
    };

    bool SetImpCoef(UnicodeString);

    float GetVolume(void);
    float GetFlow(void);
    float GetTime(void);
    float GetTotalImp(void);

    float GetRawWidthFlow(void);
    float GetWidthFlow(void);
    float GetWidthFlowVolume(void);

    float GetFinalVolume(void);
    float GetFinalRawVolume(void);

    float GetFinalFlow(void);
    float GetFinalRawFlow(void);
    float GetFinalMass(void);

    int GetRawSecImp(void);

    void ResetTest(void);
    float GetFlowVolume(void);

    float GetFinalImp(void);
    float GetFinalMeanImp(void);

    void ReadPIN(void);
    void SavePIN(uint8_t pin);

    void RestoreTypePoints(void);

    void WritePIN(uint8_t pin);

    void Write_Channel_State(uint16_t State);
    void Write_Channel_Settings();

    uint8_t AddPointData(UnicodeString Name, float Qrate, float Q, float Volume,
        float vTime, float Error, float RageMinus, float RagePlus);

	void AddPoint(tPoint Pnt);
    void AddEmptyPoint(tPoint Pnt);

    void AddCurrPoint(tPoint Pnt);
    void ClearPoints(void);

    tPoint GetCurrentPoint();
    tPoint SetNextPoint();
    tPoint SetPreviousPoint();

    void SetEtalonPoint(tPoint point);
    void SetEtalonPoint(int hash);
    void SetEtalonPoint(UnicodeString hash);

     bool SaveDataPoint();
    tDataPoint GetDataPoint(void)
    {
        return DataPoint;
    }
    void AddDataPoint(tPoint Pnt);

    int8_t AddCalibrPoint(tCalibrPoint Pnt);
    void ClearCalibrPoint(tCalibrPoint Pnt);
    void AddCurrentCalibrPoint(void);
    void AddDataCalibrPoint(void);

    void ClearCalibraion(void);

    void SaveCalibrData(void);
    void LoadCalibrData(void);

    int8_t UpdateCoefs(void);

    int8_t AddCalibrData(
        float vEtlVolume, float vTime, float vImp, float vCoef);
    int8_t AddCalibrMassData(
        float vEtlMass, float vTime, float vImp, float vCoef);

    tPoint Point;
    tDataPoint DataPoint;
    tCalibrPoint CalibrPoint;

    vector<tPoint> Points;
    vector<tDataPoint> DataPoints;
    vector<tDataPoint> UsedDataPoints;
    vector<tCalibrPoint> CalibrPoints;

    // Обратные функции обновления состояния

    void __fastcall OnConfigRead(TObject* Sender);

    int PointIndex;

    UnicodeString Comment;

//    static TXMLDocument* XmlDoc;
//    static _di_IXMLNode rootNode;
//    static _di_IXMLNode sampleNode;
//    static _di_IXMLNode sampleNode2;
//    static _di_IXMLNode sampleNode3;
//    static UnicodeString dirName;
//    static System::UnicodeString fname;

    static TJSONValue* jValue;
    static TJSONArray* jArray;
    static TJSONObject* jObject;

    static void SaveToFile(TFlowMeter* FlowMeter, int IsBackUp);
    static void SaveTestMetersToFile(TFlowMeter* FlowMeter, int IsBackUp);
    static void SaveEtalonsToFile(int IsBackUp);

    static TFlowMeter* LoadFromFile(void);
    static TFlowMeter* LoadEtalonsFromFile(void);
    static TFlowMeter* LoadFromFile(THscDevice* HSCDevice);
    static TFlowMeter* LoadTestMetersFromFile();

    static TFlowMeter* GetEtalon(int Hash);
    static bool GetTestMeter(int Hash, TFlowMeter*& OutFlowMeter);
    static TFlowMeter* GetActiveEtalon();
    static TFlowMeter* GetActiveFlowMeter();

    static UnicodeString JSonConvert(TFlowMeter* AFlowMeter);

    static UnicodeString ApiConvert();

    static void ApiSent();
    static int ApiCheckResult();

	UnicodeString JSonConvert();

	UnicodeString StringStreamConvert();

    void AddToList(void);

    static vector<TFlowMeter*> FlowMeters;
    static vector<TFlowMeter*> Etalons;

	static void SortEtalons();
    static void SortFlowMeters();
    void SortPoints();

    static std::vector<tPoint>::iterator it;

    void Delete();
    static void DeleteHash(int Hash);
    static void DeleteEtalonHash(int Hash);

    static void StaticInit(THscDevice* HSCDev);
    static THscDevice* sHSC;

	static TFlowMeter* ActiveFlowMeter;
    static TFlowMeter* ActiveEtalon;

    TFlowMeter*   FindEtalonPoint();

    static bool InitType(TFlowMeter* FM);

    static int GetCountInOrder(int iD_Order);

	eMeterFlowType MeterFlowType = WEIGHTS_TYPE;

	void SetMeterFlowType(eMeterFlowType meterFlowType);
	void SetMeterFlowType(UnicodeString meterFlowType);
    UnicodeString GetMeterFlowType();

    TMeterValue* ValueImp;
    TMeterValue* ValueImpTotal;

    TMeterValue* ValueCoef;

    TMeterValue* ValueMassCoef;
    TMeterValue* ValueVolumeCoef;

    TMeterValue* ValueVolume;
    TMeterValue* ValueMass;

    TMeterValue* ValueVolumeMeter;
    TMeterValue* ValueMassMeter;

    TMeterValue* ValueMassFlow;
    TMeterValue* ValueVolumeFlow;

    TMeterValue* ValueQuantity;
    TMeterValue* ValueFlow;

    TMeterValue* ValueError;

    TMeterValue* ValueVolumeError;
    TMeterValue* ValueMassError;

    TMeterValue* ValueDensity;
    TMeterValue* ValuePressure;
    TMeterValue* ValueTemperture;

    TMeterValue* ValueAirPressure;
    TMeterValue* ValueAirTemperture;
    TMeterValue* ValueHumidity;

    TMeterValue* ValueCurrent;

    TMeterValue* ValueTime;


    int HashValueImp = 0; //{read =ValueImp->Hash, write= HashValueImp};
    int HashValueImpTotal=0;

    int HashValueCoef=0;

    int HashValueMassCoef=0;
    int HashValueVolumeCoef=0;

    int HashValueVolume=0;
    int HashValueMass=0;

    int HashValueVolumeMeter=0;
    int HashValueMassMeter=0;

    int HashValueMassFlow=0;
    int HashValueVolumeFlow=0;

    int HashValueQuantity=0;
    int HashValueFlow=0;

    int HashValueError=0;

    int HashValueVolumeError=0;
    int HashValueMassError=0;

    int HashValueDensity=0;
    int HashValuePressure=0;
    int HashValueTemperture=0;

    int HashValueAirPressure=0;
    int HashValueAirTemperture=0;
    int HashValueHumidity=0;

    int HashValueCurrent=0;

    int HashValueTime =0;

    void InitHashValues();

    void SetValues(void);
    void SetMonitorValues(void);
    void SetFinalValues(void);

    double GetVolumeError();
    double GetMassError();

    void SetEtalon(TFlowMeter*);
    void SetAsEtalon(void);
    UnicodeString GetEtalonState(void);
	void SetEtalonState(UnicodeString state);

    bool IsFlowInPoint();
    bool IsFlowInPoint(float Q);
    bool IsFlowInPoint(tPoint point);
    bool IsFlowInPoint(TMeterValue* Value);
    bool IsFlowInPoint(double Q, tPoint point);

     bool IsDataPointGood(
        tDataPoint &dataPoint, tPoint point);

    void SortDataPoints(int maxmin);
    vector<tDataPoint> SortDataVector(
    vector<tDataPoint> vect, int State, int State2, int maxmin);

    bool GetPointUseFlow(float Q, tPoint &point);

    int TimeToEndVolumeLimit(
        float pointVolume, float DelayCoef, float TimeCoef);

    int CheckStatus();
    int CheckFullStatus();
	void IncImpSumMonitor(void);

	void SetInitalDim();

	static void SetOnChangedTestMeter(TOnChanged onChangedTestMeter);

    static TOnChanged OnChangedTestMeter;

    static void CopyOrderDevices(int orderHash, int newOrderHash);

    int GetNewHash();
    int GetNewPointHash();

    tPoint GetPoint(int hash);

    static TFlowMeter* EtalonMeter;
    void ReCalcPointsFlowMax();
    void ReCalcPointsFactoryKp();

    void RestoreValues();

    void SetFactoryKp(double factoryKp);
    void static AutoFill(TFlowMeter*);

    void SetFinalValuesHandle(double time, double imptotal, double coef);

     void SetFinalValuesHandle(double time, double imptotal);


    void SetFinalValuesByEtalon();

    void SortDataPointsFlow(int MinMax = 0);
    void SortDataPointsDate(int MinMax = 0);
    void SortDataPointsName(int MinMax = 0);
    void SortDataPointsError(int MinMax=0);
	void SortDataPointsErrorMeter(int MinMax=0 );

    void DataPointsCalc();

     protected :
        private : uint8_t Channel;
    THscDevice *HSCDevice, *HSC;

    //архив последних 100 секунд импульсов
    uint16_t Impulses[100];
    uint8_t wr_imp; // индекс записи в архив
    uint8_t rd_imp; // индекс чтения из архива

    float VolSum, ImpSum;

    void Init();

    void InitValues();

    void CopyValues(TFlowMeter* EtalonMeter);
};

#endif















