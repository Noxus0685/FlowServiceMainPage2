unit FmxFlowmetersPanel;

{ ===== Компонент FmxFlowmetersPanel =====
  Визуальный компонент панели подключения поверяемых приборов
}

interface

uses
  System.SysUtils, System.Classes, FMX.Controls, FMX.Graphics, FMX.Types,
  FMX.StdCtrls, FMX.Forms,
  FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Edit,
  System.UITypes, // TMouseButton
  // System.Types,
  System.Rtti, // TValue
  System.Types, // TRectF
  FMX.Grid, FMX.Styles,
  FMX.Controls.Presentation,
  FMX.ListBox, FMX.Grid.Style,
  FmxParamsFrm, // Форма ручного ввода параметров
  FmxFPDevice,
  FmxFPDevices,
  uFmxStrConsts,
  FmxFPModule,
  uProcedureOfObject,
  FPCustomControl,
  FMXDeviceCustomControl,
  uErrorIndicator,
  FmxFlowmetersTypes,
  FmxFPModuleManager,
  FmxFPDeviceManager, uCardItem;

const
  cFlowmetersPanelStyle = 'flowmeterpanelstyle';
  cFlowmetersPanelGridStyle = 'flowmeterspanelgrid';
  cCardContainerStyle = 'CardContainerStyle';
  cMainBodyStyle = 'background';
  cTopPnlStyle = 'toppnl';
  cFlowmetersPanelSettingsButtonStyle = 'settignsbuttonstyle';
  cViewModeComboBoxStyle = 'viewmodecombobox';
  cMaxChannels = 255;

  cFlowmetersPanelPropertyCount = 16;
  cFlowmetersPanelPropertys: array [0 .. cFlowmetersPanelPropertyCount - 1]
    of string = (cHeader, cHint, cLeft, cTop, cWidth, cHeight, cConfig_F,
    cConfig_I, cConfig_U, cRowHeight, cAngle, cVisible, cModulePriority,
    cDigits, cScale, cView);

  cFlowmetersPanelPropertysType: array [0 .. cFlowmetersPanelPropertyCount - 1]
    of TParameterType = (ptText, ptText, ptFloat, ptFloat, ptFloat, ptFloat,
    ptText, ptText, ptText, ptFloat, ptFloat, ptComboBox, ptNumber, ptNumber,
    ptFloat, ptComboBox);

  cFlowmetersPanelPropertyComboItems
    : array [0 .. cFlowmetersPanelPropertyCount - 1] of TArray<string> = ([],
    [], [], [], [], [], [], [], [], [], [], [cNo, cYes], [], [], [],
    [cStandart, cOtherView]);


type
  TFlowmetersPanelViewMode = (fpvmAll, fpvmSpillAll, fpvmSpillMedium,
    fpvmSpillShort, fpvmConfigUnit);
  TFmxFlowmetersPanelColumnsType = (fpctNun, fpctChannel, fpctTypeOfConnection,
    fpctUnitName, fpctUnitNumber, fpctRawValue, fpctOutlay, fpctVolume,
    fpctError, fpctMin, fpctMax, fpctTopOutlay, fpctKoeff, fpctMinOutlay,
    fpctMaxOutlay, fpctRawSumm, fpctRawAwerage);

const
  FlowmetersPanelViewModeNames: array [TFlowmetersPanelViewMode]
    of String = ('Все', 'Все по измерениям', 'Расширенные по измерениям',
    'Сокращенные по измерениям', 'Конфигурационные');
  OutputTypeNames: Array [TFmxOutputType] of String = ('Нет', 'Напряжение',
    'Ток', 'Частота', 'Визуально', 'RS485');
  ShortOutputTypeNames: Array [TFmxOutputType] of String = ('?', 'U', 'I', 'F',
    'V', 'D');

  FmxFlowmetersPanelColumnsName: Array [TFmxFlowmetersPanelColumnsType]
    of String = ('№п.п.', 'Канал', 'Тип подключения', 'Тип прибора',
    'Заводской номер', 'Значение', 'Расход, м3/ч', 'Объем, л', 'Погрешность, %',
    'Мин.(КИ)', 'Макс.(КИ)', 'Макс. расход (КИ), м3/ч', 'Коэфф.',
    'Изм.мин.расход, м3/ч', 'Изм.макс.расход, м3/ч', 'Изм.Сумма (КИ)',
    'Изм.ср.расход, м3/ч');
  SetfpvmAll: set of TFmxFlowmetersPanelColumnsType =
    [fpctUnitName .. fpctRawAwerage];
  SetfpvmSpillAll: set of TFmxFlowmetersPanelColumnsType = [fpctUnitName,
    fpctRawValue, fpctOutlay, fpctVolume, fpctError, fpctMinOutlay,
    fpctMaxOutlay, fpctRawSumm, fpctRawAwerage];
  SetfpvmSpillMedium: set of TFmxFlowmetersPanelColumnsType = [fpctUnitName,
    fpctRawValue, fpctOutlay, fpctVolume, fpctError, fpctRawSumm];
  SetfpvmSpillShort: set of TFmxFlowmetersPanelColumnsType = [fpctRawValue,
    fpctOutlay, fpctVolume, fpctError];
  SetfpvmConfigUnit: set of TFmxFlowmetersPanelColumnsType =
    [fpctTypeOfConnection, fpctUnitName, fpctUnitNumber, fpctMin, fpctMax,
    fpctTopOutlay, fpctKoeff];

type
  TGetDeviceEvent = function(Sender: TObject; Idx: integer;
    AOutputType: TFmxOutputType): TFmxDevice of object;

  TFmxFlowmetersPanel = class(TFMXDeviceCustomControl)
  private
    // Карточки
    FCardItems: TArray<TCardItem>;
    FGrid: TGrid; // Классический вид
    FCardContainer: TFlowLayout; // Расширенный
    FSettingsButton: TCornerButton;
    cbViewMode: TComboBox;
    FMainBody: TRectangle;
    FTopPnl: TLayout;

    FNumberColumn: TCustomNumberColumn;
    FPopUpColumn: TPopupColumn;
    FChannelName: TStringColumn;
    StrColumns1: array [fpctUnitName .. fpctVolume] of TStringColumn;
    FErrorColumn: TErrorIndicatorColumn;
    StrColumns2: array [fpctMin .. fpctRawAwerage] of TStringColumn;

    Channels: array of TChannelSettings;

    FF_ChannelsCount: byte;
    FU_ChannelsCount: byte;
    FI_ChannelsCount: byte;
    FConfig_F: string;
    FConfig_I: string;
    FConfig_U: string;
    FInterval: integer;
    FViewMode: TFlowmetersPanelViewMode;
    FCountEnable: boolean;
    FMiniIntegrator: boolean;
    FOnGetDevice: TGetDeviceEvent;
    FEtalonOutlay: Single;
    FEtalonVolume: Single;
    FEtalonStartStopTime: Single;
    FStartStop: boolean;
    FOnSettingsButtonClick: TNotifyEvent;
    FCountWasEnabled: boolean;
    FOnButtonClick: TNotifyEvent;
    FOnCountEnable: TNotifyEvent;
    FInterval_updated: boolean;
    FIntervalStartTick: extended;
    FIntervalStopTick: extended;
    FIntervalStartStopTime: Single;
    FActive: boolean;
    FRowHeight: Single;
    FNextActiveChannelNumber: integer;
    FScale: Single;

    procedure CreateCards;
    procedure UpdateCardData(CardIndex: integer);
    function GetChannelsCount: byte;
    procedure AddStandardColumns;
    procedure GridGetValue(Sender: TObject; const ACol, ARow: integer;
      var Value: TValue);
    procedure GridSetValue(Sender: TObject; const ACol, ARow: integer;
      const Value: TValue);
    function GetF_ChannelsCount: byte;
    function GetU_ChannelsCount: byte;
    function GetI_ChannelsCount: byte;
    function GetDevice_F(Idx: byte): TFmxDeviceCounter;
    function GetDevice_I(Idx: byte): TFmxDeviceVoltmeter;
    function GetDevice_U(Idx: byte): TFmxDeviceVoltmeter;
    procedure GridDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: integer;
      const Value: TValue; const State: TGridDrawStates);
    function GetCellValue(const ACol, ARow: integer): String;
    procedure SetViewMode(const Value: TFlowmetersPanelViewMode);
    procedure UpdateViewMode;
    procedure SetCountEnable(const Value: boolean);
    procedure SetConfig_F(const Value: String);
    procedure SetConfig_I(const Value: String);
    procedure SetConfig_U(const Value: String);
    procedure SetMiniIntegrator(const Value: boolean);
    procedure UpdateChannels;
    procedure SetOnGetDevice(const Value: TGetDeviceEvent);
    function GetRawValue(Idx: integer): Single;
    function GetOutlay(Idx: integer): Single;
    function GetVolume(Idx: integer): Single;
    function GetAverageOutlay(Idx: integer): Single;
    function GetF_Impulses(Idx: integer): Single;
    function GetF_Koeff(Idx: integer): Single;
    function GetMaxOutlay(Idx: integer): Single;
    function GetMinOutlay(Idx: integer): Single;
    procedure SetEtalonOutlay(const Value: Single);
    procedure SetEtalonVolume(const Value: Single);
    procedure SetEtalonStartStopTime(const Value: Single);
    function GetQuality(Idx: integer): TFmxDeviceQuality;
    procedure SetStartStop(const Value: boolean);
    procedure SetOnSettingsButtonClick(const Value: TNotifyEvent);
    procedure UpdateSettingsButtonState;
    function GetActiveChannel(Idx: integer): boolean;
    function GetTypeOfConnection(Idx: integer): TFmxOutputType;
    procedure SetTypeOfConnection(Idx: integer; const Value: TFmxOutputType);
    function GetReportByChannel(Idx: integer): string;
    function GetReportByEtalon: string;
    function GetError(Idx: integer): Single;
    procedure SetCountWasEnabled(const Value: boolean);
    procedure SetOnButtonClick(const Value: TNotifyEvent);
    procedure SetOnCountEnable(const Value: TNotifyEvent);
    function GetUI_Max(Idx: integer): Single;
    function GetUI_Min(Idx: integer): Single;
    function GetUI_TopOutlay(Idx: integer): Single;
    function GetUnitID(Idx: integer): longint;
    function GetDUnitName(Idx: integer): String;
    function GetDUnitNumber(Idx: integer): String;
    procedure SetUnitID(Idx: integer; const Value: longint);
    procedure SetDUnitName(Idx: integer; const Value: String);
    procedure SetDUnitNumber(Idx: integer; const Value: String);
    function GetUnitName(Idx: integer): String;
    function GetUnitNumber(Idx: integer): String;
    procedure SetUnitName(Idx: integer; const Value: String);
    procedure SetUnitNumber(Idx: integer; const Value: String);
    function GetMaxDischarge(Idx: integer): Single;
    function GetMinDischarge(Idx: integer): Single;
    function GetOutputParam1(Idx: integer): Single;
    function GetOutputParam2(Idx: integer): Single;
    function GetOutputParam3(Idx: integer): Single;
    function GetOutputParam4(Idx: integer): Single;
    procedure SetMaxDischarge(Idx: integer; const Value: Single);
    procedure SetMinDischarge(Idx: integer; const Value: Single);
    procedure SetOutputParam1(Idx: integer; const Value: Single);
    procedure SetOutputParam2(Idx: integer; const Value: Single);
    procedure SetOutputParam3(Idx: integer; const Value: Single);
    procedure SetOutputParam4(Idx: integer; const Value: Single);
    function GetMass(Idx: integer): boolean;
    procedure SetMass(Idx: integer; const Value: boolean);
    procedure SetUI_Max(Idx: integer; AValue: Single);
    procedure SetUI_Min(Idx: integer; AValue: Single);
    procedure SetUI_TopOutlay(Idx: integer; AValue: Single);
    procedure SetF_Koeff(Idx: integer; const Value: Single);
    function GetF_ConversionCoefficientInLiterPerImpulse(Idx: integer): boolean;
    procedure SetF_ConversionCoefficientInLiterPerImpulse(Idx: integer;
      const Value: boolean);
    function GetF_TypeOfInput(Idx: integer): byte;
    procedure SetF_TypeOfInput(Idx: integer; const Value: byte);
    function GetActiveChannelsCount: integer;
    function GetTotal_interval_Errors(Idx: integer): double;
    function GetTotal_interval_Impulses(Idx: integer): double;
    function GetTotal_interval_Outlay(Idx: integer): double;
    function GetTotal_interval_RawValue(Idx: integer): double;
    function GetTotal_interval_Volumes(Idx: integer): double;
    function GetTotal_mean_analog_values(Idx: integer): double;
    procedure SetTotal_interval_Volumes(Idx: integer; const Value: double);
    procedure SetTotal_mean_analog_values(Idx: integer; const Value: double);
    procedure SetInterval_updated(const Value: boolean);
    procedure SetIntervalStartTick(const Value: extended);
    procedure SetIntervalStopTick(const Value: extended);
    procedure SetIntervalStartStopTime(const Value: Single);
    procedure SetActive(const Value: boolean);
    function GetComplexChannelName(Idx: integer): string;
    function GetChannelDeviceIndexNumber(Idx: integer): integer;
    procedure SetRowHeight(const Value: Single);
    function GetC_F_ChannelNumber(Idx: integer): byte;
    function GetC_I_ChannelNumber(Idx: integer): byte;
    function GetC_U_ChannelNumber(Idx: integer): byte;
    function GetC_UnitID(Idx: integer): longint;
    function GetInterval_Counter(Idx: integer): longword;
    procedure SetC_F_ChannelNumber(Idx: integer; const Value: byte);
    procedure SetC_I_ChannelNumber(Idx: integer; const Value: byte);
    procedure SetC_U_ChannelNumber(Idx: integer; const Value: byte);
    procedure SetC_UnitID(Idx: integer; const Value: longint);
    function GetC_OutputParam1(Idx: integer): Single;
    function GetC_OutputParam2(Idx: integer): Single;
    function GetC_OutputParam3(Idx: integer): Single;
    function GetC_OutputParam4(Idx: integer): Single;
    procedure SetC_OutputParam1(Idx: integer; const Value: Single);
    procedure SetC_OutputParam2(Idx: integer; const Value: Single);
    procedure SetC_OutputParam3(Idx: integer; const Value: Single);
    procedure SetC_OutputParam4(Idx: integer; const Value: Single);
    function GetС_TypeOfInput(Idx: integer): byte;
    procedure SetС_TypeOfInput(Idx: integer; const Value: byte);
    function GetFirstActiveChannelNumber: integer;
    function GetNextActiveChannelNumber: integer;
    function GetC_UnitTypeID(Idx: integer): longint;
    procedure SetC_UnitTypeID(Idx: integer; const Value: longint);
    function GetC_UnitTypeName(Idx: integer): String;
    procedure SetC_UnitTypeName(Idx: integer; const Value: String);
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    function ErrorIndicatorColumn1GetRowActive(Sender: TObject;
      Row: integer): boolean;
    procedure GridKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure SetScale(const Value: Single);
    procedure FindControlsInStyle;
    procedure ClassicApplyStyle;
    procedure UpdateCardView;
    procedure UpdateGrid;
    procedure ExtendedViewApplyStyle;
    procedure UpdateControls;
    procedure RefreshStyle; override;
    procedure CardSetupButtonClick(Sender: TObject);
    function GetChannelCaption(Idx: byte): String;
  protected
    procedure SetPriority(const Value: integer); override;
    function GetModuleManager: TFmxModuleManager; override;
    function Disguise: boolean; override;
    procedure UpdateStyle; override;
    function GetCurState: String; override;
    procedure ColumnResized(Sender: TObject);
    function GetParamValue(Row: integer): String; override;
    procedure SetParamValue(Row: integer; const Value: String); override;
  public
    watched_channel: integer;
    MeanWaterDischarge: double;
    col_width: array [TFmxFlowmetersPanelColumnsType] of Single;
    procedure CalculateError(Idx: integer);
    procedure ClearDynamicChannelsParams();
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FillParametersList; override;
    procedure DoOnSettingsButtonClick(Sender: TObject);
    procedure DoViewModeChange(Sender: TObject);
    procedure ApplyStyle; override;
    procedure Update; override;

    property ChannelCaption[Idx: byte]: String read GetChannelCaption;

    property Device_F[Idx: byte]: TFmxDeviceCounter read GetDevice_F;
    property Device_I[Idx: byte]: TFmxDeviceVoltmeter read GetDevice_I;
    property Device_U[Idx: byte]: TFmxDeviceVoltmeter read GetDevice_U;
    property ViewMode: TFlowmetersPanelViewMode read FViewMode
      write SetViewMode;

    property Config_F: string read FConfig_F write SetConfig_F;
    property Config_I: string read FConfig_I write SetConfig_I;
    property Config_U: string read FConfig_U write SetConfig_U;
    property ChannelsCount: byte read GetChannelsCount;
    property F_ChannelsCount: byte read FF_ChannelsCount;//Частотных каналов на этом рабочем столе
    property U_ChannelsCount: byte read FU_ChannelsCount;
    property I_ChannelsCount: byte read FI_ChannelsCount;
    property D_ChannelsCount: byte read GetChannelsCount;
    property CountEnable: boolean read FCountEnable write SetCountEnable;
    property OnGetDevice: TGetDeviceEvent read FOnGetDevice
      write SetOnGetDevice;
    property OnSettingsButtonClick: TNotifyEvent read FOnSettingsButtonClick
      write SetOnSettingsButtonClick;
    property ReportByChannel[Idx: integer]: string read GetReportByChannel;
    property ReportByEtalon: string read GetReportByEtalon;
    property Active: boolean read FActive write SetActive;
    property RowHeight: Single read FRowHeight write SetRowHeight;

    property D_UnitName[Idx: integer]: String read GetDUnitName
      write SetDUnitName;
    property D_UnitNumber[Idx: integer]: String read GetDUnitNumber
      write SetDUnitNumber;
    property D_UnitID[Idx: integer]: longint read GetUnitID write SetUnitID;
    property D_RawValue[Idx: integer]: Single read GetRawValue;
    property D_Outlay[Idx: integer]: Single read GetOutlay;
    property D_Volume[Idx: integer]: Single read GetVolume;
    property D_UI_Min[Idx: integer]: Single read GetUI_Min write SetUI_Min;
    property D_UI_Max[Idx: integer]: Single read GetUI_Max write SetUI_Max;
    property D_UI_TopOutlay[Idx: integer]: Single read GetUI_TopOutlay
      write SetUI_TopOutlay;
    property D_F_Koeff[Idx: integer]: Single read GetF_Koeff write SetF_Koeff;
    property D_F_TypeOfInput[Idx: integer]: byte read GetF_TypeOfInput
      write SetF_TypeOfInput;
    property D_F_ConversionCoefficientInLiterPerImpulse[Idx: integer]: boolean
      read GetF_ConversionCoefficientInLiterPerImpulse
      write SetF_ConversionCoefficientInLiterPerImpulse;
    property D_MinOutlay[Idx: integer]: Single read GetMinOutlay;
    property D_MaxOutlay[Idx: integer]: Single read GetMaxOutlay;
    property D_F_Impulses[Idx: integer]: Single read GetF_Impulses;
    property D_Quality[Idx: integer]: TFmxDeviceQuality read GetQuality;
    property D_AverageOutlay[Idx: integer]: Single read GetAverageOutlay;
    property D_OutputParam1[Idx: integer]: Single read GetOutputParam1
      write SetOutputParam1;
    property D_OutputParam2[Idx: integer]: Single read GetOutputParam2
      write SetOutputParam2;
    property D_OutputParam3[Idx: integer]: Single read GetOutputParam3
      write SetOutputParam3;
    property D_OutputParam4[Idx: integer]: Single read GetOutputParam4
      write SetOutputParam4;

    property EtalonOutlay: Single read FEtalonOutlay write SetEtalonOutlay;
    property EtalonVolume: Single read FEtalonVolume write SetEtalonVolume;
    property EtalonStartStopTime: Single read FEtalonStartStopTime
      write SetEtalonStartStopTime;
    property StartStop: boolean read FStartStop write SetStartStop;
    property CountWasEnabled: boolean read FCountWasEnabled
      write SetCountWasEnabled;
    property OnButtonClick: TNotifyEvent read FOnButtonClick
      write SetOnButtonClick;
    property OnCountEnable: TNotifyEvent read FOnCountEnable
      write SetOnCountEnable;

    property CI_Outlay[Idx: integer]: double read GetTotal_interval_Outlay;
    property CI_Error[Idx: integer]: double read GetTotal_interval_Errors;
    property CI_mean_analog_values[Idx: integer]: double
      read GetTotal_mean_analog_values write SetTotal_mean_analog_values;
    property CI_RAW[Idx: integer]: double read GetTotal_interval_RawValue;
    property CI_Volume[Idx: integer]: double read GetTotal_interval_Volumes
      write SetTotal_interval_Volumes;
    property CI_Impulses[Idx: integer]: double read GetTotal_interval_Impulses;
    property CI_Counter[Idx: integer]: longword read GetInterval_Counter;
    property CI_StartStopTime: Single read FIntervalStartStopTime
      write SetIntervalStartStopTime;
    property CI_StartTick: extended read FIntervalStartTick
      write SetIntervalStartTick;
    property CI_StopTick: extended read FIntervalStopTick
      write SetIntervalStopTick;
    property CI_updated: boolean read FInterval_updated
      write SetInterval_updated;

    property ActiveChannelsCount: integer read GetActiveChannelsCount;
    property ActiveChannel[Idx: integer]: boolean read GetActiveChannel;
    property С_TypeOfConnection[Idx: integer]: TFmxOutputType
      read GetTypeOfConnection write SetTypeOfConnection;
    property С_TypeOfInput[Idx: integer]: byte read GetС_TypeOfInput
      write SetС_TypeOfInput;
    property C_ComplexName[Idx: integer]: string read GetComplexChannelName;
    property C_DeviceIndex[Idx: integer]: integer
      read GetChannelDeviceIndexNumber;
    property C_UnitID[Idx: integer]: longint read GetC_UnitID write SetC_UnitID;
    property C_UnitTypeID[Idx: integer]: longint read GetC_UnitTypeID
      write SetC_UnitTypeID;
    property C_UnitName[Idx: integer]: String read GetUnitName
      write SetUnitName;
    property C_UnitTypeName[Idx: integer]: String read GetC_UnitTypeName
      write SetC_UnitTypeName;
    property C_UnitNumber[Idx: integer]: String read GetUnitNumber
      write SetUnitNumber;
    property C_Mass[Idx: integer]: boolean read GetMass write SetMass;
    property C_MaxDischarge[Idx: integer]: Single read GetMaxDischarge
      write SetMaxDischarge;
    property C_MinDischarge[Idx: integer]: Single read GetMinDischarge
      write SetMinDischarge;
    //Индекс частотного канала в общем списке частотных каналов
    //1..3,6,8,9 - F_ChannelsCount = 6 - 0..5   0 - 0, 4 - 7, 5 - 8
    //F1..F12
    //I1..I7
    //U1..U3
    property C_F_ChannelNumber[Idx: integer]: byte read GetC_F_ChannelNumber
      write SetC_F_ChannelNumber;
    property C_I_ChannelNumber[Idx: integer]: byte read GetC_I_ChannelNumber
      write SetC_I_ChannelNumber;
    property C_U_ChannelNumber[Idx: integer]: byte read GetC_U_ChannelNumber
      write SetC_U_ChannelNumber;
    property C_OutputParam1[Idx: integer]: Single read GetC_OutputParam1
      write SetC_OutputParam1;
    property C_OutputParam2[Idx: integer]: Single read GetC_OutputParam2
      write SetC_OutputParam2;
    property C_OutputParam3[Idx: integer]: Single read GetC_OutputParam3
      write SetC_OutputParam3;
    property C_OutputParam4[Idx: integer]: Single read GetC_OutputParam4
      write SetC_OutputParam4;

    property FirstActiveChannel: integer read GetFirstActiveChannelNumber;
    property NextActiveChannel: integer read GetNextActiveChannelNumber;
    property Scale: Single read FScale write SetScale;
  published
    property Align;
    property Anchors;
  end;

procedure Register;

implementation

uses
  FmxFPColors,
  FMXHelper, System.UIConsts,
  FMX.NumberBox;

function Str2OutputType(const Value: String): TFmxOutputType;
var
  i: TFmxOutputType;
begin
  result := fotNone;
  for i := Low(TFmxOutputType) to High(TFmxOutputType) do
    if OutputTypeNames[i] = Value then
    begin
      result := i;
      Break;
    end;
end;

function OutputType2Str(const Value: TFmxOutputType): String;
begin
  if Value in [fotNone .. fotInterface] then
    result := OutputTypeNames[Value]
  else
    result := '';
end;

{ TFmxFlowmetersPanel }

procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxFlowmetersPanel]);
end;

procedure TFmxFlowmetersPanel.GridDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: integer; const Value: TValue; const State: TGridDrawStates);
var
  CellText: string;
  CellRect: TRectF;
  TextColor: TAlphaColor;
  BackgroundColor: TAlphaColor;
begin
  if Column is TErrorIndicatorColumn then
  begin
    CellRect := Bounds;
  end
  else
  begin
    CellText := Value.AsString;
    CellRect := Bounds;
    if Channels[Row].TypeOfConnection = fotNone then
    begin
      BackgroundColor := TAlphaColorRec.White;
      TextColor := TAlphaColorRec.Darkgray;
    end
    else
    begin
      BackgroundColor := TAlphaColorRec.White;
      if D_Quality[Row] = fdqGood then
        TextColor := TAlphaColorRec.Darkgreen
      else if D_Quality[Row] = fdqBad then
        TextColor := TAlphaColorRec.Darkred
      else
        TextColor := TAlphaColorRec.Cadetblue;
    end;
    Canvas.Fill.Color := BackgroundColor;
    Canvas.FillRect(CellRect, 0, 0, [], 1);
    Canvas.Fill.Color := TextColor;
    Canvas.FillText(CellRect, CellText, False, 1, [], TTextAlign.Leading,
      TTextAlign.Center);
  end;
end;

function TFmxFlowmetersPanel.GetActiveChannel(Idx: integer): boolean;
begin
  result := False;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].TypeOfConnection <> fotNone;
end;

function TFmxFlowmetersPanel.GetActiveChannelsCount: integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to ChannelsCount do
    if С_TypeOfConnection[i - 1] <> fotNone then
      Inc(result);
end;

function TFmxFlowmetersPanel.GetAverageOutlay(Idx: integer): Single;
begin
  if EtalonStartStopTime > 0 then
    result := D_Volume[Idx] / EtalonStartStopTime
  else
    result := D_Outlay[Idx];
end;

function TFmxFlowmetersPanel.GetCellValue(const ACol, ARow: integer): String;
begin
  result := '';
  if ACol = 0 then
    result := IntToStr(ARow + 1)
  else if (ARow + 1) in [1 .. ChannelsCount] then
    if ActiveChannel[ARow] then
      case ACol of
        1:
          result:=ChannelCaption[ARow];
//          case Channels[ARow].TypeOfConnection of
//            fotNone:
//              result := '---';
//            fotVoltage:
//              result := 'U' + IntToStr(Channels[ARow].U_ChannelNumber);
//            fotCurrent:
//              result := 'I' + IntToStr(Channels[ARow].I_ChannelNumber);
//            fotFrequency:
//              result := 'F' + IntToStr(Channels[ARow].F_ChannelNumber);
//            fotVisual:
//              result := 'V' + IntToStr(ARow + 1);
//            fotInterface:
//              result := 'R' + IntToStr(ARow + 1);
//          end;
        2:
          result := OutputType2Str(Channels[ARow].TypeOfConnection);
        3:
          result := C_UnitName[ARow];
        4:
          result := C_UnitNumber[ARow];
        5:
          if CountEnable and (not StartStop) then
            result := FloatToStrF(CI_RAW[ARow], ffFixed, 15, 2)
          else
            result := FloatToStrF(D_RawValue[ARow], ffFixed, 15, 2);
        6:
          if CountEnable and (not StartStop) then
            result := FloatToStrF(CI_Outlay[ARow], ffFixed, 15, DecimalDigits)
          else
            result := FloatToStrF(D_Outlay[ARow], ffFixed, 15, DecimalDigits);
        7:
          result := FloatToStrF(D_Volume[ARow], ffFixed, 15, DecimalDigits);
        8:
          result := FloatToStrF(CI_Error[ARow], ffFixed, 15, 3);
        9:
          result := FloatToStrF(D_UI_Min[ARow], ffFixed, 15, 2);
        10:
          result := FloatToStrF(D_UI_Max[ARow], ffFixed, 15, 2);
        11:
          result := FloatToStrF(D_UI_TopOutlay[ARow], ffFixed, 15, 2);
        12:
          result := FloatToStrF(D_F_Koeff[ARow], ffFixed, 15, 5);
        13:
          result := FloatToStrF(D_MinOutlay[ARow], ffFixed, 15, 4);
        14:
          result := FloatToStrF(D_MaxOutlay[ARow], ffFixed, 15, 4);
        15:
          result := FloatToStrF(D_F_Impulses[ARow], ffFixed, 15, 2);
        16:
          result := FloatToStrF(D_AverageOutlay[ARow], ffFixed, 15,
            DecimalDigits);
      end;
end;

procedure TFmxFlowmetersPanel.GridGetValue(Sender: TObject;
  const ACol, ARow: integer; var Value: TValue);
begin
  if not Assigned(FGrid) or (csDestroying in ComponentState) then
    Exit;
  try
    Value := GetCellValue(ACol, ARow);
  except
    on e: exception do
      OutputDebugMessage('Ошибка E:' + e.message);
  end;
end;

procedure TFmxFlowmetersPanel.GridSetValue(Sender: TObject;
  const ACol, ARow: integer; const Value: TValue);
begin
  case ACol of
    2:
      Channels[ARow].TypeOfConnection := Str2OutputType(Value.ToString);
    3:
      C_UnitName[ARow] := Value.AsString;
    4:
      C_UnitNumber[ARow] := Value.AsString;
  end;
end;

procedure TFmxFlowmetersPanel.GridKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    if FGrid.Selected < FGrid.RowCount - 1 then
      FGrid.Selected := FGrid.Selected + 1
    else
      FGrid.Selected := 0;
    Key := 0;
  end;
end;

procedure TFmxFlowmetersPanel.UpdateCardData(CardIndex: integer);
var
  ch: integer;
begin
  if (CardIndex < 0) or (CardIndex >= ChannelsCount) then
    Exit;
  ch := CardIndex;

  //FCardItems[CardIndex].DiagnoseEnabledChain;
  if ActiveChannel[ch] then
  begin
    FCardItems[CardIndex].Active := True;
    FCardItems[CardIndex].Place := ch + 1;
    FCardItems[CardIndex].Hardware := C_UnitNumber[ch];
    FCardItems[CardIndex].Outlay := D_Outlay[ch];
    FCardItems[CardIndex].Volume := D_Volume[ch];
    FCardItems[CardIndex].Error := CI_Error[ch];
  end
  else
  begin
    FCardItems[CardIndex].Active := False;
    FCardItems[CardIndex].Place := ch + 1;
  end;
  // Принудительная перекомпоновка
  FCardContainer.Align := TAlignLayout.None;
  FCardContainer.Align := TAlignLayout.Client;
  FCardContainer.Enabled:=True;
end;

procedure TFmxFlowmetersPanel.UpdateCardView;
var
  i: integer;
begin
  if not Assigned(FCardContainer) then
    Exit;
  if Length(FCardItems) <> ChannelsCount then
    CreateCards;

  for i := 0 to ChannelsCount - 1 do
    UpdateCardData(i);
  if FScale <> FCardContainer.Scale.x then
  begin
    FCardContainer.Scale.x:=Scale;
    FCardContainer.Scale.y:=Scale;
  end;
end;

procedure TFmxFlowmetersPanel.UpdateGrid;
begin
  if Assigned(FGrid) then
  begin
    try
      FGrid.BeginUpdate;
      if FScale <> FGrid.Scale.X then
      begin
        FGrid.Scale.X := FScale;
        FGrid.Scale.Y := FScale;
        FGrid.Align := TAlignLayout.None;
        FGrid.Align := TAlignLayout.Client;
      end;
      FGrid.EndUpdate;
    except
    end;
  end;
end;

procedure TFmxFlowmetersPanel.ExtendedViewApplyStyle;
begin
  if Assigned(FMainBody) then
    FMainBody.Fill.Kind := TBrushKind.None;
  if Assigned(FCardContainer) then
     FCardContainer.Enabled:=True;
end;

procedure TFmxFlowmetersPanel.ApplyStyle;
begin
  inherited;
  FindControlsInStyle;
  if not OtherView then
    ClassicApplyStyle
  else
    ExtendedViewApplyStyle;
  UpdateStyle;
end;

procedure TFmxFlowmetersPanel.ClassicApplyStyle;
var
  i: TFlowmetersPanelViewMode;
begin
  if not Visible or not ParentedVisible then
    Exit;

  if not OtherView then
    if Assigned(FMainBody) then
      FMainBody.Fill.Kind := TBrushKind.Solid;

  if Assigned(FGrid) then
  begin
    FGrid.ClearColumns;
    AddStandardColumns;
    FGrid.RowHeight := RowHeight;
    FGrid.OnGetValue := GridGetValue;
    FGrid.OnKeyDown := GridKeyDown;
    FGrid.OnSetValue := GridSetValue;
    FGrid.OnDrawColumnCell := GridDrawColumnCell;
    FGrid.RowCount := ChannelsCount;
  end;

  if Assigned(FSettingsButton) then
  begin
    FSettingsButton.OnClick := DoOnSettingsButtonClick;
    FSettingsButton.Hint := 'Подключение поверяемых приборов';
    FSettingsButton.ShowHint := True;
    if ControlsEnabled then
    begin
      if Active then
        State := fpsEnabledSelected
      else
        State := fpsEnabled;
    end
    else
    begin
      if Active then
        State := fpsDisabledSelected
      else
        State := fpsDisabled;
    end;
    FSettingsButton.Enabled := (State = fpsEnabledSelected) and
      (not CountEnable);
  end;

  if Assigned(cbViewMode) then
  begin
    cbViewMode.OnChange := DoViewModeChange;
    cbViewMode.Items.Clear;
    if cbViewMode.Items.Count = 0 then
      for i := Low(TFlowmetersPanelViewMode)
        to High(TFlowmetersPanelViewMode) do
        cbViewMode.Items.Add(FlowmetersPanelViewModeNames[i]);
    UpdateViewMode;
  end;

  Update;
end;

procedure TFmxFlowmetersPanel.AddStandardColumns;
var
  i: TFmxFlowmetersPanelColumnsType;
  j: TFmxOutputType;
begin
  if Assigned(FGrid) then
  begin
    FNumberColumn := TCustomNumberColumn.Create(FGrid);
    FNumberColumn.Header := FmxFlowmetersPanelColumnsName[fpctNun];
    if col_width[fpctNun] <> 0 then
      FNumberColumn.Width := col_width[fpctNun]
    else
      FNumberColumn.Width := 40;
    FNumberColumn.Enabled := False;
    FNumberColumn.ReadOnly := True;
    FNumberColumn.OnResized := ColumnResized;
    FNumberColumn.Tag := Ord(fpctNun);
    FGrid.AddObject(FNumberColumn);

    FChannelName := TStringColumn.Create(FGrid);
    FChannelName.Header := FmxFlowmetersPanelColumnsName[fpctChannel];
    FChannelName.ReadOnly := True;
    FChannelName.Enabled := False;
    if col_width[fpctChannel] <> 0 then
      FChannelName.Width := col_width[fpctChannel]
    else
      FChannelName.Width := 40;
    FChannelName.Tag := Ord(fpctChannel);
    FChannelName.OnResized := ColumnResized;
    FGrid.AddObject(FChannelName);

    FPopUpColumn := TPopupColumn.Create(FGrid);
    FPopUpColumn.ReadOnly := True;
    FPopUpColumn.Tag := Ord(fpctTypeOfConnection);
    FPopUpColumn.OnResized := ColumnResized;
    for j := Low(TFmxOutputType) to High(TFmxOutputType) do
      FPopUpColumn.Items.Add(OutputTypeNames[j]);
    FPopUpColumn.Header := FmxFlowmetersPanelColumnsName[fpctTypeOfConnection];
    if col_width[fpctTypeOfConnection] <> 0 then
      FPopUpColumn.Width := col_width[fpctTypeOfConnection]
    else
      FPopUpColumn.Width := 120;
    FGrid.AddObject(FPopUpColumn);

    for i := Low(StrColumns1) to High(StrColumns1) do
    begin
      StrColumns1[i] := TStringColumn.Create(FGrid);
      StrColumns1[i].Tag := Ord(i);
      StrColumns1[i].Header := FmxFlowmetersPanelColumnsName[i];
      StrColumns1[i].Enabled := i in [fpctTypeOfConnection, fpctUnitNumber];
      StrColumns1[i].Width := 120;
      if col_width[i] <> 0 then
        StrColumns1[i].Width := col_width[i];
      StrColumns1[i].OnResized := ColumnResized;
      FGrid.AddObject(StrColumns1[i]);
    end;

    FErrorColumn := TErrorIndicatorColumn.Create(FGrid);
    FErrorColumn.OnGetRowActive := ErrorIndicatorColumn1GetRowActive;
    FErrorColumn.Header := FmxFlowmetersPanelColumnsName[fpctError];
    FErrorColumn.ReadOnly := True;
    FErrorColumn.Enabled := False;
    if col_width[fpctError] <> 0 then
      FErrorColumn.Width := col_width[fpctError]
    else
      FErrorColumn.Width := 120;
    FErrorColumn.Tag := Ord(fpctError);
    FErrorColumn.OnResized := ColumnResized;
    FGrid.AddObject(FErrorColumn);

    for i := Low(StrColumns2) to High(StrColumns2) do
    begin
      StrColumns2[i] := TStringColumn.Create(FGrid);
      StrColumns2[i].Tag := Ord(fpctError) + Ord(i);
      StrColumns2[i].Header := FmxFlowmetersPanelColumnsName[i];
      StrColumns2[i].Enabled := i in [fpctTypeOfConnection, fpctUnitNumber];
      StrColumns2[i].Width := 120;
      if col_width[i] <> 0 then
        StrColumns2[i].Width := col_width[i];
      StrColumns2[i].OnResized := ColumnResized;
      FGrid.AddObject(StrColumns2[i]);
    end;
  end;
end;

procedure TFmxFlowmetersPanel.ClearDynamicChannelsParams;
begin
  CI_updated := False;
end;

procedure TFmxFlowmetersPanel.ColumnResized(Sender: TObject);
var
  i: TFmxFlowmetersPanelColumnsType;
begin
  if Assigned(Sender) and (Sender is TColumn) then
  begin
    i := TFmxFlowmetersPanelColumnsType(TColumn(Sender).Tag);
    if Ord(i) < FGrid.ColumnCount then
      col_width[i] := FGrid.Columns[Ord(i)].Width;
  end;
end;

constructor TFmxFlowmetersPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGrid := nil;
  FScale := 1;
  FActive := False;
  StyleLookup := cFlowmetersPanelStyle;
  ControlType := ctFlowmetersPanel;
  CaptionColor := CL_FMX_WHITE;
  Caption := 'Рабочий стол ' + IntToStr(FIdx + 1);
  Width := 400;
  Height := 200;
  Full := False;
  State := fpsEnabled;
  Config_F := '';
  Config_I := '';
  Config_U := '';
  FViewMode := fpvmConfigUnit;
  FCardContainer := nil;
end;

procedure TFmxFlowmetersPanel.CreateCards;
var
  i: integer;
  Card: TCardItem;
begin
  if not Assigned(FCardContainer) then
    Exit;

  for i := 0 to FCardContainer.ControlsCount - 1 do
    FCardContainer.Controls[i].Free;
  SetLength(FCardItems, 0);

  for i := 0 to ChannelsCount - 1 do
  begin
    Card := TCardItem.Create(FCardContainer);
    Card.Parent := FCardContainer;
    Card.Width := 110;
    Card.Height := 160;
    Card.Margins.Top := 1;
    Card.Margins.Left := 1;
    Card.Margins.Right := 1;
    Card.Margins.Bottom := 1;
    Card.Tag := i;
    Card.Place := i + 1;
    Card.OnSetupClick := CardSetupButtonClick;
    Card.Active:=False;
    SetLength(FCardItems, i + 1);
    Card.HitTest:=True;
    FCardItems[i] := Card;
    Card.Enabled:=True;
    Card.Opacity:=1;
  end;
  FCardContainer.Enabled:=True;
  FCardContainer.Opacity:=1;
end;

destructor TFmxFlowmetersPanel.Destroy;
begin
  inherited;
end;

function TFmxFlowmetersPanel.Disguise: boolean;
begin
  result := True;
  if (F_ChannelsCount > 0) and Assigned(Device_F[0]) then
    result := Device_F[0].Disguise
  else if (I_ChannelsCount > 0) and Assigned(Device_I[0]) then
    result := Device_I[0].Disguise
  else if (U_ChannelsCount > 0) and Assigned(Device_U[0]) then
    result := Device_U[0].Disguise;
end;

procedure TFmxFlowmetersPanel.DoOnSettingsButtonClick(Sender: TObject);
begin
  if Assigned(OnSettingsButtonClick) then
    OnSettingsButtonClick(Self);
end;

procedure TFmxFlowmetersPanel.DoViewModeChange(Sender: TObject);
begin
  if Assigned(cbViewMode) then
  begin
    if cbViewMode.ItemIndex >= 0 then
      ViewMode := TFlowmetersPanelViewMode(cbViewMode.ItemIndex)
    else
      cbViewMode.ItemIndex := Ord(ViewMode);
  end;
end;

procedure TFmxFlowmetersPanel.FillParametersList;
var
  i: integer;
begin
  inherited;
  SetLength(FParameters, cFlowmetersPanelPropertyCount);
  for i := 0 to cFlowmetersPanelPropertyCount - 1 do
  begin
    FParameters[i].Name := cFlowmetersPanelPropertys[i];
    FParameters[i].ParamType := cFlowmetersPanelPropertysType[i];
    FParameters[i].Items := cFlowmetersPanelPropertyComboItems[i];
  end;
end;

procedure TFmxFlowmetersPanel.FindControlsInStyle;
begin
  if not Visible or not ParentedVisible then
    Exit;
  if (csDestroying in ComponentState) or (csLoading in ComponentState) then
    Exit;

  FGrid := TGrid(FindStyleResource(cFlowmetersPanelGridStyle));
  FCardContainer := TFlowLayout(FindStyleResource(cCardContainerStyle));
  FSettingsButton := TCornerButton
    (FindStyleResource(cFlowmetersPanelSettingsButtonStyle));
  FMainBody := TRectangle(FindStyleResource(cMainBodyStyle));
  FTopPnl := TLayout(FindStyleResource(cTopPnlStyle));
  cbViewMode := TComboBox(FindStyleResource(cViewModeComboBoxStyle));
end;

function TFmxFlowmetersPanel.GetComplexChannelName(Idx: integer): string;
begin
  result := '';
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    result := ShortOutputTypeNames[Channels[Idx].TypeOfConnection];
    case Channels[Idx].TypeOfConnection of
      fotVoltage:
        result := result + IntToStr(Channels[Idx].U_ChannelNumber);
      fotCurrent:
        result := result + IntToStr(Channels[Idx].I_ChannelNumber);
      fotFrequency:
        result := result + IntToStr(Channels[Idx].F_ChannelNumber);
    end;
  end;
end;

function TFmxFlowmetersPanel.GetChannelCaption(Idx: byte): String;
begin
          result:='';
          case Channels[Idx].TypeOfConnection of
            fotNone:
              result := '---';
            fotVoltage: begin
              if Assigned(Device_U[Idx]) then
                 result:=Device_U[Idx].Caption;
              if result='' then
                 result := 'U' + IntToStr(Channels[Idx].U_ChannelNumber);
            end;
            fotCurrent: begin
              if Assigned(Device_I[Idx]) then
                 result:=Device_I[Idx].Caption;
              if result='' then
                 result := 'I' + IntToStr(Channels[Idx].I_ChannelNumber);
            end;
            fotFrequency: begin
              if Assigned(Device_F[Idx]) then
                 result:=Device_F[Idx].Caption;
              if result='' then
                 result := 'F' + IntToStr(Channels[Idx].F_ChannelNumber);
            end;
            fotVisual:
              result := 'V' + IntToStr(Idx + 1);
            fotInterface:
              result := 'R' + IntToStr(Idx + 1);
          end;

end;

function TFmxFlowmetersPanel.GetChannelDeviceIndexNumber(Idx: integer): integer;
begin
  result := Idx;
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    case Channels[Idx].TypeOfConnection of
      fotVoltage:
        result := Channels[Idx].U_ChannelNumber;
      fotCurrent:
        result := Channels[Idx].I_ChannelNumber;
      fotFrequency:
        result := Channels[Idx].F_ChannelNumber;
    end;
  end;
end;

function TFmxFlowmetersPanel.GetChannelsCount: byte;
var
  F, i, U: byte;
begin
  F := F_ChannelsCount;
  i := I_ChannelsCount;
  U := U_ChannelsCount;
  if (F > i) and (F > U) then
    result := F
  else if i > U then
    result := i
  else
    result := U;
end;

function TFmxFlowmetersPanel.GetCurState: String;
begin
  result := inherited GetCurState;
end;

function TFmxFlowmetersPanel.GetC_UnitTypeID(Idx: integer): longint;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].UnitTypeID;
end;

function TFmxFlowmetersPanel.GetC_UnitTypeName(Idx: integer): String;
begin
  result := UnitName;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].UnitTypeName;
end;

function TFmxFlowmetersPanel.GetC_F_ChannelNumber(Idx: integer): byte;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].F_ChannelNumber;
end;

function TFmxFlowmetersPanel.GetC_I_ChannelNumber(Idx: integer): byte;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].I_ChannelNumber;
end;

function TFmxFlowmetersPanel.GetC_OutputParam1(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].OutputParam1;
end;

function TFmxFlowmetersPanel.GetC_OutputParam2(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].OutputParam2;
end;

function TFmxFlowmetersPanel.GetC_OutputParam3(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].OutputParam3;
end;

function TFmxFlowmetersPanel.GetC_OutputParam4(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].OutputParam4;
end;

function TFmxFlowmetersPanel.GetC_UnitID(Idx: integer): longint;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].UnitID;
end;

function TFmxFlowmetersPanel.GetC_U_ChannelNumber(Idx: integer): byte;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].U_ChannelNumber;
end;


function TFmxFlowmetersPanel.GetDevice_F(Idx: byte): TFmxDeviceCounter;
begin
  result := nil;
  if Assigned(FOnGetDevice) then
    result := TFmxDeviceCounter(OnGetDevice(Self, Channels[Idx].F_ChannelNumber
      - 1, fotFrequency));
end;

function TFmxFlowmetersPanel.GetDevice_I(Idx: byte): TFmxDeviceVoltmeter;
begin
  result := nil;
  if Assigned(FOnGetDevice) then
    result := TFmxDeviceVoltmeter(OnGetDevice(Self,
      Channels[Idx].I_ChannelNumber - 1, fotCurrent));
end;

function TFmxFlowmetersPanel.GetDevice_U(Idx: byte): TFmxDeviceVoltmeter;
begin
  result := nil;
  if Assigned(FOnGetDevice) then
    result := TFmxDeviceVoltmeter(OnGetDevice(Self,
      Channels[Idx].U_ChannelNumber - 1, fotVoltage));
end;

function TFmxFlowmetersPanel.GetError(Idx: integer): Single;
begin
  result := CI_Error[Idx];
end;

procedure TFmxFlowmetersPanel.CalculateError(Idx: integer);
begin
  if ActiveChannel[Idx] then
  begin
    if (EtalonVolume > 0) and CountEnable then
    begin
      case С_TypeOfConnection[Idx] of
        fotFrequency:
          if Assigned(Device_F[Idx]) then
          begin
            Channels[Idx].Interval_Volume := Device_F[Idx].Volume;
            Channels[Idx].Interval_Impulses := Device_F[Idx].Impulses;
            if EtalonStartStopTime > 0 then
            begin
              Channels[Idx].Interval_Outlay := Device_F[Idx].Volume /
                EtalonStartStopTime * 3.6;
              Channels[Idx].Interval_Raw := Channels[Idx].Interval_Impulses /
                EtalonStartStopTime;
            end;
          end;
        fotVoltage:
          if Assigned(Device_U[Idx]) then
          begin
            Channels[Idx].Interval_Volume := Device_U[Idx].Volume;
            if EtalonStartStopTime > 0 then
              Channels[Idx].Interval_Outlay := Channels[Idx].Interval_Volume /
                EtalonStartStopTime * 3.6;
          end;
        fotCurrent:
          if Assigned(Device_I[Idx]) then
          begin
            Channels[Idx].Interval_Volume := Device_I[Idx].Volume;
            if EtalonStartStopTime > 0 then
              Channels[Idx].Interval_Outlay := Channels[Idx].Interval_Volume /
                EtalonStartStopTime * 3.6;
          end;
      end;
      Channels[Idx].Interval_Error :=
        ((D_Volume[Idx] - EtalonVolume) / EtalonVolume) * 100;
    end
    else
    begin
      if EtalonOutlay > 0 then
        Channels[Idx].Interval_Error :=
          ((D_Outlay[Idx] - EtalonOutlay) / EtalonOutlay) * 100
      else
        Channels[Idx].Interval_Error := 0;
    end;
  end;
end;

function TFmxFlowmetersPanel.GetUI_Max(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].MaxPhysicalValue;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].MaxPhysicalValue;
    fotFrequency:
      result := 0;
  end;
end;

procedure TFmxFlowmetersPanel.SetUI_Max(Idx: integer; AValue: Single);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].MaxPhysicalValue := AValue;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].MaxPhysicalValue := AValue;
  end;
end;

procedure TFmxFlowmetersPanel.SetUI_Min(Idx: integer; AValue: Single);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].MinPhysicalValue := AValue;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].MinPhysicalValue := AValue;
  end;
end;

function TFmxFlowmetersPanel.GetUI_Min(Idx: integer): Single;
var
  di: integer;
begin
  di := C_DeviceIndex[Idx];
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[di].MinPhysicalValue;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[di].MinPhysicalValue;
    fotFrequency:
      result := 0;
  end;
end;

function TFmxFlowmetersPanel.GetUI_TopOutlay(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].TopOutlay;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].TopOutlay;
    fotFrequency:
      result := 0;
  end;
end;

procedure TFmxFlowmetersPanel.SetUI_TopOutlay(Idx: integer; AValue: Single);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].TopOutlay := AValue;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].TopOutlay := AValue;
  end;
end;

function TFmxFlowmetersPanel.GetUnitID(Idx: integer): longint;
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].UnitID;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].UnitID;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].UnitID;
  end;
end;

function TFmxFlowmetersPanel.GetUnitName(Idx: integer): String;
begin
  result := '';
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    if Channels[Idx].UnitTypeID > 0 then
    begin
      result := Channels[Idx].UnitTypeName;
      if result = '' then
        result := Channels[Idx].UnitName;
    end
    else
      result := Channels[Idx].UnitName;
  end;
end;

function TFmxFlowmetersPanel.GetUnitNumber(Idx: integer): String;
begin
  result := '';
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].UnitNumber;
end;

function TFmxFlowmetersPanel.GetDUnitName(Idx: integer): String;
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].UnitName;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].UnitName;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].UnitName;
  else
    result := Channels[Idx].UnitName;
  end;
end;

function TFmxFlowmetersPanel.GetDUnitNumber(Idx: integer): String;
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].UnitNumber;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].UnitNumber;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].UnitNumber;
  else
    result := Channels[Idx].UnitNumber;
  end;
end;

function TFmxFlowmetersPanel.GetU_ChannelsCount: byte;
var
  i: integer;
begin
  result := 0;
  for i := 1 to cMaxChannels do
    if IsValueInRange(FConfig_U, i) then
      Inc(result);
end;

function TFmxFlowmetersPanel.GetFirstActiveChannelNumber: integer;
var
  i: integer;
  found: boolean;
begin
  result := 0;
  found := False;
  for i := 1 to ChannelsCount do
    if С_TypeOfConnection[i - 1] <> fotNone then
    begin
      FNextActiveChannelNumber := i;
      found := True;
      Break;
    end;
  if found then
  begin
    result := FNextActiveChannelNumber;
    Inc(FNextActiveChannelNumber);
  end;
end;

function TFmxFlowmetersPanel.GetF_ChannelsCount: byte;
var
  i: integer;
begin
  result := 0;
  for i := 1 to cMaxChannels do
    if IsValueInRange(FConfig_F, i) then
      Inc(result);
end;

function TFmxFlowmetersPanel.GetF_ConversionCoefficientInLiterPerImpulse
  (Idx: integer): boolean;
begin
  result := False;
  case Channels[Idx].TypeOfConnection of
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].ConversionCoefficientInLiterPerImpulse;
  end;
end;

function TFmxFlowmetersPanel.GetF_Impulses(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage, fotCurrent:
      result := 0;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].Impulses;
  end;
end;

function TFmxFlowmetersPanel.GetF_Koeff(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage, fotCurrent:
      result := 1;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].ImpulseWeights;
  end;
end;

function TFmxFlowmetersPanel.GetF_TypeOfInput(Idx: integer): byte;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].TypeOfInput;
  end;
end;

function TFmxFlowmetersPanel.GetInterval_Counter(Idx: integer): longword;
begin
  result := 10;
end;

function TFmxFlowmetersPanel.GetI_ChannelsCount: byte;
var
  i: integer;
begin
  result := 0;
  for i := 1 to cMaxChannels do
    if IsValueInRange(FConfig_I, i) then
      Inc(result);
end;

function TFmxFlowmetersPanel.GetMass(Idx: integer): boolean;
begin
  result := False;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].Mass;
end;

function TFmxFlowmetersPanel.GetMaxDischarge(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].MaxDischarge;
end;

function TFmxFlowmetersPanel.GetMaxOutlay(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].MaxOutlay;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].MaxOutlay;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].MaxOutlay;
  end;
end;

function TFmxFlowmetersPanel.GetMinDischarge(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].MinDischarge;
end;

function TFmxFlowmetersPanel.GetMinOutlay(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].MinOutlay;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].MinOutlay;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].MinOutlay;
  end;
end;

function TFmxFlowmetersPanel.GetModuleManager: TFmxModuleManager;
begin
  result := nil;
  if (F_ChannelsCount > 0) and Assigned(Device_F[0]) then
    result := Device_F[0].ModuleManager
  else if (I_ChannelsCount > 0) and Assigned(Device_I[0]) then
    result := Device_I[0].ModuleManager
  else if (U_ChannelsCount > 0) and Assigned(Device_U[0]) then
    result := Device_U[0].ModuleManager;
end;

function TFmxFlowmetersPanel.GetNextActiveChannelNumber: integer;
var
  i: integer;
  found: boolean;
begin
  result := 0;
  found := False;
  for i := FNextActiveChannelNumber to ChannelsCount do
    if С_TypeOfConnection[i - 1] <> fotNone then
    begin
      FNextActiveChannelNumber := i;
      found := True;
      Break;
    end;
  if found then
  begin
    result := FNextActiveChannelNumber;
    Inc(FNextActiveChannelNumber);
  end;
end;

function TFmxFlowmetersPanel.GetOutlay(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].Outlay;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].Outlay;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].Outlay;
  end;
end;

function TFmxFlowmetersPanel.GetOutputParam1(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        result := D_UI_Min[Idx];
      fotFrequency:
        result := D_F_Koeff[Idx];
    end;
end;

function TFmxFlowmetersPanel.GetOutputParam2(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        result := D_UI_Max[Idx];
      fotFrequency:
        if D_F_ConversionCoefficientInLiterPerImpulse[Idx] then
          result := 1
        else
          result := 0;
    end;
end;

function TFmxFlowmetersPanel.GetOutputParam3(Idx: integer): Single;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        result := D_UI_TopOutlay[Idx];
      fotFrequency:
        result := D_F_TypeOfInput[Idx];
    end;
end;

function TFmxFlowmetersPanel.GetOutputParam4(Idx: integer): Single;
begin
  result := 0;
end;

function TFmxFlowmetersPanel.GetTypeOfConnection(Idx: integer): TFmxOutputType;
begin
  result := fotNone;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].TypeOfConnection;
end;

function TFmxFlowmetersPanel.GetParamValue(Row: integer): String;
begin
  case Row of
    0:
      result := Caption;
    1:
      result := Hint;
    2:
      result := FloatToStr(Left + ShiftL);
    3:
      result := FloatToStr(Top + ShiftT);
    4:
      result := FloatToStr(Width);
    5:
      result := FloatToStr(Height);
    6:
      result := Config_F;
    7:
      result := Config_I;
    8:
      result := Config_U;
    9:
      result := FloatToStr(RowHeight);
    10:
      result := FloatToStr(RotationAngle);
    11:
      result := cBooleanName[Visible];
    12:
      result := IntToStr(ModulePriority);
    13:
      result := IntToStr(DecimalDigits);
    14:
      result := FormatFloat('#.##', Scale * 100.0);
    15:
      result := cOtherViewName[OtherView];
  else
    result := '';
  end;
end;

function TFmxFlowmetersPanel.GetQuality(Idx: integer): TFmxDeviceQuality;
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].Quality;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].Quality;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].Quality;
  end;
end;

function TFmxFlowmetersPanel.GetRawValue(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].Value;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].Value;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].Frequencies;
  end;
end;

function TFmxFlowmetersPanel.GetReportByChannel(Idx: integer): string;
begin
  result := '';
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Format('№ %d Q:%f м3/ч, V:%f E:%f %%',
      [Idx + 1, D_Outlay[Idx], D_Volume[Idx], CI_Error[Idx]]);
end;

function TFmxFlowmetersPanel.GetReportByEtalon: string;
begin
  result := Format('Q:%f м3/ч, V:%f л., T:%f сек.', [EtalonOutlay, EtalonVolume,
    EtalonStartStopTime]);
end;

function TFmxFlowmetersPanel.GetTotal_interval_Errors(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    if CountEnable then
    begin
      if (EtalonVolume > 0) and (not StartStop) then
      begin
        case Channels[Idx].TypeOfConnection of
          fotVoltage:
            if Assigned(Device_U[Idx]) then
              result := ((Device_U[Idx].Volume - EtalonVolume) /
                EtalonVolume) * 100;
          fotCurrent:
            if Assigned(Device_I[Idx]) then
              result := ((Device_I[Idx].Volume - EtalonVolume) /
                EtalonVolume) * 100;
          fotFrequency:
            if Assigned(Device_F[Idx]) then
              result := ((Device_F[Idx].Volume - EtalonVolume) /
                EtalonVolume) * 100;
          fotVisual:
            result := Channels[Idx].Interval_Error;
        end;
        Channels[Idx].Interval_Error := result;
      end
      else
        result := Channels[Idx].Interval_Error;
    end
    else
    begin
      if EtalonOutlay > 0 then
      begin
        case Channels[Idx].TypeOfConnection of
          fotVoltage:
            if Assigned(Device_U[Idx]) then
              result := ((Device_U[Idx].Outlay - EtalonOutlay) /
                EtalonOutlay) * 100;
          fotCurrent:
            if Assigned(Device_I[Idx]) then
              result := ((Device_I[Idx].Outlay - EtalonOutlay) /
                EtalonOutlay) * 100;
          fotFrequency:
            if Assigned(Device_F[Idx]) then
              result := ((Device_F[Idx].Outlay - EtalonOutlay) /
                EtalonOutlay) * 100;
          fotVisual:
            result := Channels[Idx].Interval_Error;
        end;
        Channels[Idx].Interval_Error := result;
      end;
    end;
  end;
end;

function TFmxFlowmetersPanel.GetTotal_interval_Impulses(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].Interval_Impulses;
end;

function TFmxFlowmetersPanel.GetTotal_interval_Outlay(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].Interval_Outlay;
end;

function TFmxFlowmetersPanel.GetTotal_interval_RawValue(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].Interval_Raw;
end;

function TFmxFlowmetersPanel.GetTotal_interval_Volumes(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Channels[Idx].Interval_Volume;
end;

function TFmxFlowmetersPanel.GetTotal_mean_analog_values(Idx: integer): double;
begin
  result := 0;
  if (Idx + 1) in [1 .. ChannelsCount] then
    if Channels[Idx].Interval_Counter > 0 then
      result := Channels[Idx].Interval_Impulses / Channels[Idx]
        .Interval_Counter;
end;

procedure TFmxFlowmetersPanel.Update;
begin
  inherited;
  UpdateControls;
end;

procedure TFmxFlowmetersPanel.UpdateChannels;
var
  i, len: byte;
begin
  ClearDynamicChannelsParams;
  len := ChannelsCount;
  SetLength(Channels, len);
  if Assigned(FGrid) then
    FGrid.RowCount := len;
  for i := Low(Channels) to High(Channels) do
  begin
    Channels[i].F_ChannelNumber := GetElementByIndex(FConfig_F, i);
    Channels[i].I_ChannelNumber := GetElementByIndex(FConfig_I, i);
    Channels[i].U_ChannelNumber := GetElementByIndex(FConfig_U, i);
  end;
end;

procedure TFmxFlowmetersPanel.SetActive(const Value: boolean);
begin
  FActive := Value;
  if Value then
  begin
    BringToFront;
    State:=fpsEnabledSelected;
    Opacity := 1;
  end
  else begin
    State:=fpsEnabled;
    Opacity := 0.1;
  end;
  ApplyStyle;
end;

procedure TFmxFlowmetersPanel.SetConfig_F(const Value: String);
begin
  if FConfig_F <> Value then
  begin
    FConfig_F := Value;
    FF_ChannelsCount := GetF_ChannelsCount;
    UpdateChannels;
  end;
end;

procedure TFmxFlowmetersPanel.SetConfig_I(const Value: String);
begin
  if FConfig_I <> Value then
  begin
    FConfig_I := Value;
    FI_ChannelsCount := GetI_ChannelsCount;
    UpdateChannels;
  end;
end;

procedure TFmxFlowmetersPanel.SetConfig_U(const Value: String);
begin
  if FConfig_U <> Value then
  begin
    FConfig_U := Value;
    FU_ChannelsCount := GetU_ChannelsCount;
    UpdateChannels;
  end;
end;

procedure TFmxFlowmetersPanel.SetCountEnable(const Value: boolean);
begin
  FCountEnable := Value;
  if Assigned(OnCountEnable) then
    OnCountEnable(Self);
end;

procedure TFmxFlowmetersPanel.SetEtalonOutlay(const Value: Single);
var
  i: integer;
begin
  FEtalonOutlay := Value;
  if not CountEnable then
    for i := 1 to ChannelsCount do
      CalculateError(i - 1);
end;

procedure TFmxFlowmetersPanel.SetEtalonStartStopTime(const Value: Single);
begin
  if FEtalonStartStopTime <> Value then
  begin
    FEtalonStartStopTime := Value;
    if (CountEnable or StartStop) or (Value > InputValue) then
      InputValue := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetEtalonVolume(const Value: Single);
begin
  if FEtalonVolume <> Value then
    FEtalonVolume := Value;
end;

procedure TFmxFlowmetersPanel.SetF_ConversionCoefficientInLiterPerImpulse
  (Idx: integer; const Value: boolean);
begin
  case Channels[Idx].TypeOfConnection of
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].ConversionCoefficientInLiterPerImpulse := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetF_Koeff(Idx: integer; const Value: Single);
begin
  case Channels[Idx].TypeOfConnection of
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].ImpulseWeights := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetF_TypeOfInput(Idx: integer; const Value: byte);
begin
  case Channels[Idx].TypeOfConnection of
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].TypeOfInput := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetCountWasEnabled(const Value: boolean);
begin
  FCountWasEnabled := Value;
end;

procedure TFmxFlowmetersPanel.SetC_UnitTypeID(Idx: integer;
  const Value: longint);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].UnitTypeID := Value;
end;

procedure TFmxFlowmetersPanel.SetC_UnitTypeName(Idx: integer;
  const Value: String);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].UnitTypeName := Value;
end;

procedure TFmxFlowmetersPanel.SetC_F_ChannelNumber(Idx: integer;
  const Value: byte);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].F_ChannelNumber := Value;
end;

procedure TFmxFlowmetersPanel.SetC_I_ChannelNumber(Idx: integer;
  const Value: byte);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].I_ChannelNumber := Value;
end;

procedure TFmxFlowmetersPanel.SetC_OutputParam1(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    Channels[Idx].OutputParam1 := Value;
    D_OutputParam1[Idx] := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetC_OutputParam2(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    Channels[Idx].OutputParam2 := Value;
    D_OutputParam2[Idx] := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetC_OutputParam3(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    Channels[Idx].OutputParam3 := Value;
    D_OutputParam3[Idx] := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetC_OutputParam4(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
  begin
    Channels[Idx].OutputParam4 := Value;
    D_OutputParam4[Idx] := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetC_UnitID(Idx: integer; const Value: longint);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].UnitID := Value;
end;

procedure TFmxFlowmetersPanel.SetC_U_ChannelNumber(Idx: integer;
  const Value: byte);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].U_ChannelNumber := Value;
end;

procedure TFmxFlowmetersPanel.SetIntervalStartStopTime(const Value: Single);
begin
  FIntervalStartStopTime := Value;
end;

procedure TFmxFlowmetersPanel.SetIntervalStartTick(const Value: extended);
begin
  FIntervalStartTick := Value;
end;

procedure TFmxFlowmetersPanel.SetIntervalStopTick(const Value: extended);
begin
  FIntervalStopTick := Value;
  CI_StartStopTime := (FIntervalStopTick - FIntervalStartTick) / 1000.0;
end;

procedure TFmxFlowmetersPanel.SetInterval_updated(const Value: boolean);
begin
  FInterval_updated := Value;
end;

procedure TFmxFlowmetersPanel.SetMass(Idx: integer; const Value: boolean);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].Mass := Value;
end;

procedure TFmxFlowmetersPanel.SetMaxDischarge(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].MaxDischarge := Value;
end;

procedure TFmxFlowmetersPanel.SetMinDischarge(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].MinDischarge := Value;
end;

procedure TFmxFlowmetersPanel.SetMiniIntegrator(const Value: boolean);
begin
  FMiniIntegrator := Value;
end;

procedure TFmxFlowmetersPanel.SetOnButtonClick(const Value: TNotifyEvent);
begin
  FOnButtonClick := Value;
end;

procedure TFmxFlowmetersPanel.SetOnCountEnable(const Value: TNotifyEvent);
begin
  FOnCountEnable := Value;
end;

procedure TFmxFlowmetersPanel.SetOnGetDevice(const Value: TGetDeviceEvent);
begin
  FOnGetDevice := Value;
end;

procedure TFmxFlowmetersPanel.SetOnSettingsButtonClick
  (const Value: TNotifyEvent);
begin
  FOnSettingsButtonClick := Value;
end;

procedure TFmxFlowmetersPanel.SetOutputParam1(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        D_UI_Min[Idx] := Value;
      fotFrequency:
        D_F_Koeff[Idx] := Value;
    end;
end;

procedure TFmxFlowmetersPanel.SetOutputParam2(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        D_UI_Max[Idx] := Value;
      fotFrequency:
        D_F_ConversionCoefficientInLiterPerImpulse[Idx] := Value > 0;
    end;
end;

procedure TFmxFlowmetersPanel.SetOutputParam3(Idx: integer;
  const Value: Single);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    case Channels[Idx].TypeOfConnection of
      fotVoltage, fotCurrent:
        D_UI_TopOutlay[Idx] := Value;
      fotFrequency:
        D_F_TypeOfInput[Idx] := Trunc(Value);
    end;
end;

procedure TFmxFlowmetersPanel.SetOutputParam4(Idx: integer;
  const Value: Single);
begin
  // резерв
end;

procedure TFmxFlowmetersPanel.SetTypeOfConnection(Idx: integer;
  const Value: TFmxOutputType);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].TypeOfConnection := Value;
end;

procedure TFmxFlowmetersPanel.SetParamValue(Row: integer; const Value: String);
begin
  case Row of
    0:
      Caption := Value;
    1:
      Hint := Value;
    2:
      Left := StrToFloatDef(CP(Value), Left) - ShiftL;
    3:
      Top := StrToFloatDef(CP(Value), Top) - ShiftT;
    4:
      Width := StrToFloatDef(CP(Value), Width);
    5:
      Height := StrToFloatDef(CP(Value), Height);
    6:
      Config_F := Value;
    7:
      Config_I := Value;
    8:
      Config_U := Value;
    9:
      RowHeight := StrToFloatDef(CP(Value), RowHeight);
    10:
      RotationAngle := StrToFloatDef(CP(Value), RotationAngle);
    11:
      Visible := myStrToBool(Value);
    12:
      ModulePriority := StrToIntDef(Value, ModulePriority);
    13:
      DecimalDigits := StrToIntDef(Value, DecimalDigits);
    14:
      Scale := StrToFloatDef(CP(Value), Scale * 100.0) / 100.0;
    15:
      OtherView := myStrToOtherView(Value);
  end;
end;

procedure TFmxFlowmetersPanel.SetPriority(const Value: integer);
var
  i: integer;
begin
  inherited;
  for i := 1 to F_ChannelsCount do
    if Assigned(Device_F[i]) then
      Device_F[i].ModulePriority := Value;
  for i := 1 to I_ChannelsCount do
    if Assigned(Device_I[i]) then
      Device_I[i].ModulePriority := Value;
  for i := 1 to U_ChannelsCount do
    if Assigned(Device_U[i]) then
      Device_U[i].ModulePriority := Value;
end;

procedure TFmxFlowmetersPanel.SetRowHeight(const Value: Single);
begin
  FRowHeight := Value;
  if Assigned(FGrid) then
  begin
    FGrid.RowHeight := FRowHeight;
    FGrid.TextSettings.Font.Size := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetScale(const Value: Single);
begin
  FScale := Value;
  Update;
end;

procedure TFmxFlowmetersPanel.SetStartStop(const Value: boolean);
begin
  if FStartStop <> Value then
  begin
    FStartStop := Value;
    UpdateSettingsButtonState;
  end;
end;

procedure TFmxFlowmetersPanel.SetTotal_interval_Volumes(Idx: integer;
  const Value: double);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].Interval_Volume := Value;
end;

procedure TFmxFlowmetersPanel.SetTotal_mean_analog_values(Idx: integer;
  const Value: double);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    if Value <> 0 then
    begin
      Channels[Idx].Interval_Raw := Channels[Idx].Interval_Raw + Value;
      Channels[Idx].Interval_Counter := Channels[Idx].Interval_Counter + 1;
      Channels[Idx].Interval_Impulses := Channels[Idx].Interval_Raw /
        Channels[Idx].Interval_Counter;
    end
    else
      Channels[Idx].Interval_Counter := 0;
end;

procedure TFmxFlowmetersPanel.SetUnitID(Idx: integer; const Value: longint);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].UnitID := Value;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].UnitID := Value;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].UnitID := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetUnitName(Idx: integer; const Value: String);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].UnitName := Value;
end;

procedure TFmxFlowmetersPanel.SetUnitNumber(Idx: integer; const Value: String);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].UnitNumber := Value;
end;

procedure TFmxFlowmetersPanel.SetDUnitName(Idx: integer; const Value: String);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].UnitName := Value;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].UnitName := Value;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].UnitName := Value;
  else
    Channels[Idx].UnitName := Value;
  end;
end;

procedure TFmxFlowmetersPanel.SetDUnitNumber(Idx: integer; const Value: String);
begin
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        Device_U[Idx].UnitNumber := Value;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        Device_I[Idx].UnitNumber := Value;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        Device_F[Idx].UnitNumber := Value;
  end;
end;

procedure TFmxFlowmetersPanel.UpdateViewMode;
var
  i: integer;
  MySet: set of TFmxFlowmetersPanelColumnsType;
begin
  if not Assigned(FGrid) or (csDestroying in ComponentState) then
    Exit;
  if Assigned(FGrid) then
  begin
    case FViewMode of
      fpvmAll:
        MySet := SetfpvmAll;
      fpvmSpillAll:
        MySet := SetfpvmSpillAll;
      fpvmSpillMedium:
        MySet := SetfpvmSpillMedium;
      fpvmSpillShort:
        MySet := SetfpvmSpillShort;
      fpvmConfigUnit:
        MySet := SetfpvmConfigUnit;
    end;
    for i := 2 to FGrid.ColumnCount - 1 do
      FGrid.Columns[i].Visible := TFmxFlowmetersPanelColumnsType(i) in MySet;
    if not Assigned(cbViewMode) or (csDestroying in ComponentState) then
      Exit;
    if Assigned(cbViewMode) then
    begin
      if cbViewMode.ItemIndex <> Ord(FViewMode) then
      begin
        cbViewMode.OnChange := nil;
        cbViewMode.ItemIndex := 0;
        cbViewMode.ItemIndex := Ord(FViewMode);
        cbViewMode.OnChange := DoViewModeChange;
      end;
    end;
  end;
end;

procedure TFmxFlowmetersPanel.SetViewMode(const Value
  : TFlowmetersPanelViewMode);
begin
  if FViewMode <> Value then
  begin
    FViewMode := Value;
    UpdateViewMode;
  end;
end;

procedure TFmxFlowmetersPanel.SetС_TypeOfInput(Idx: integer; const Value: byte);
begin
  if (Idx + 1) in [1 .. ChannelsCount] then
    Channels[Idx].TypeOfInput := Value;
end;

function TFmxFlowmetersPanel.GetVolume(Idx: integer): Single;
begin
  result := 0;
  case Channels[Idx].TypeOfConnection of
    fotVoltage:
      if Assigned(Device_U[Idx]) then
        result := Device_U[Idx].Volume;
    fotCurrent:
      if Assigned(Device_I[Idx]) then
        result := Device_I[Idx].Volume;
    fotFrequency:
      if Assigned(Device_F[Idx]) then
        result := Device_F[Idx].Volume;
  end;
end;

function TFmxFlowmetersPanel.GetС_TypeOfInput(Idx: integer): byte;
begin
  result := 1;
  if (Idx + 1) in [1 .. ChannelsCount] then
    result := Trunc(Channels[Idx].OutputParam3);
end;

procedure TFmxFlowmetersPanel.UpdateSettingsButtonState;
begin
  if Assigned(FSettingsButton) then
    FSettingsButton.Enabled := Assigned(OnSettingsButtonClick) and
      (not CountEnable);
end;

procedure TFmxFlowmetersPanel.UpdateControls;
begin
  if OtherView then
    UpdateCardView
  else
    UpdateGrid;
end;

procedure TFmxFlowmetersPanel.RefreshStyle;
begin
  StyleLookup := '';
  StyleLookup := cFlowmetersPanelStyle;
end;

procedure TFmxFlowmetersPanel.UpdateStyle;
begin
  inherited;
  UpdateSettingsButtonState;
  StylesData['information.visible'] := Full;
  ControlPanelEnabled := State in [fpsEnabledSelected];
  if Assigned(FGrid) then
    FGrid.Visible := not OtherView;
  if Assigned(cbViewMode) then
    cbViewMode.Visible := not OtherView;
  if Assigned(FCardContainer) then
    FCardContainer.Visible := OtherView;
  if Assigned(FTopPnl) then
    FTopPnl.Visible := not OtherView;
  UpdateControls;
end;

procedure TFmxFlowmetersPanel.DoOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  if DesignMode then
    DoOnClick(Sender)
  else
    Full := not Full;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
end;

function TFmxFlowmetersPanel.ErrorIndicatorColumn1GetRowActive(Sender: TObject;
  Row: integer): boolean;
begin
  result := Channels[Row].TypeOfConnection <> fotNone;
end;

procedure TFmxFlowmetersPanel.CardSetupButtonClick(Sender: TObject);
var
  i: integer;
begin
  if Sender is TCardItem then
    for i := 0 to High(FCardItems) do
      if FCardItems[i] = Sender then
      begin
        if Assigned(OnSettingsButtonClick) then
          OnSettingsButtonClick(Self);
        Break;
      end;
end;

end.
