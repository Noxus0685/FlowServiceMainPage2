object TableDM: TTableDM
  Height = 1080
  Width = 1440
  PixelsPerInch = 216
  object TypesConnection: TFDConnection
    Params.Strings = (
      'Database='
      'DriverID=SQLite')
    Left = 504
    Top = 259
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 864
    Top = 54
  end
  object Types: TFDTable
    Connection = TypesConnection
    TableName = 'DeviceType'
    Left = 504
    Top = 414
  end
  object Diameters: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'Diabeters'
    TableName = 'Diameters'
    Left = 504
    Top = 684
  end
  object TypePoints: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'TypePoints'
    TableName = 'TypePoints'
    Left = 504
    Top = 810
  end
  object DevicesConnection: TFDConnection
    Params.Strings = (
      'Database='
      'DriverID=SQLite')
    Left = 162
    Top = 54
  end
  object Devices: TFDTable
    Connection = DevicesConnection
    TableName = 'Devices'
    Left = 162
    Top = 198
  end
  object DevicePoints: TFDTable
    Connection = DevicesConnection
    TableName = 'DevicePoints'
    Left = 162
    Top = 342
  end
  object SpillagePoints: TFDTable
    Connection = DevicesConnection
    TableName = 'SpillagePoints'
    Left = 162
    Top = 504
  end
  object Categories: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'Diabeters'
    TableName = 'DeviceCategory'
    Left = 493
    Top = 551
  end
end
