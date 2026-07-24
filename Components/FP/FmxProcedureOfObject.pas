unit FmxProcedureOfObject;

interface

const
  awlDopInfoSignStart='    <';
  awlDopInfoSignEnd=  '>    ';
  awlHardSign   ='    ~';
  awlFuncSign   ='---- ';
  awlBlockSign  ='==== ';
  awlWarningSign='!    ';
  awlErrorSign  ='!!!  ';

type
  // Тип результата поверки весов на одной точке.
  TScalesCheckingPointResult = record

    // Масса по весам, в кг.
    ScalesMass: Double;

    // Реальная масса, в кг.
    RealMass: Double;

  end;
  TAddToWorkLogLevel=(awlSimple,awlDopInformation,awlError,awlWarning,awlBlock,awlFunc,awlBlockEnd,awlFuncEnd,awlHard,awlModuleManager);
  TProcedureOfObject = procedure of object;

implementation

end.

 