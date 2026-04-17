object DM: TDM
  Height = 480
  Width = 640
  object TypesConnection: TFDConnection
    Params.Strings = (
      'Database='
      'DriverID=SQLite')
    Left = 224
    Top = 115
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 384
    Top = 24
  end
  object Types: TFDTable
    Connection = TypesConnection
    TableName = 'DeviceType'
    Left = 224
    Top = 184
  end
  object Diameters: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'Diabeters'
    TableName = 'Diameters'
    Left = 224
    Top = 304
  end
  object TypePoints: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'TypePoints'
    TableName = 'TypePoints'
    Left = 224
    Top = 360
  end
  object DevicesConnection: TFDConnection
    Params.Strings = (
      'Database='
      'DriverID=SQLite')
    Left = 72
    Top = 24
  end
  object Devices: TFDTable
    Connection = DevicesConnection
    TableName = 'Devices'
    Left = 72
    Top = 88
  end
  object DevicePoints: TFDTable
    Connection = DevicesConnection
    TableName = 'DevicePoints'
    Left = 72
    Top = 152
  end
  object SpillagePoints: TFDTable
    Connection = DevicesConnection
    TableName = 'SpillagePoints'
    Left = 72
    Top = 224
  end
  object Categories: TFDTable
    Connection = TypesConnection
    UpdateOptions.UpdateTableName = 'Diabeters'
    TableName = 'DeviceCategory'
    Left = 219
    Top = 245
  end
end
