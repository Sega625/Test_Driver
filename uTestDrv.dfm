object Form1: TForm1
  Left = 251
  Top = 218
  Width = 1442
  Height = 525
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 599
    Top = 138
    Width = 7
    Height = 17
    Caption = '$'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label20: TLabel
    Left = 786
    Top = 16
    Width = 7
    Height = 17
    Caption = '$'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object InstallStatLab: TLabel
    Left = 149
    Top = 40
    Width = 48
    Height = 24
    Caption = 'Error'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object RemoveStatLab: TLabel
    Left = 149
    Top = 162
    Width = 48
    Height = 24
    Caption = 'Error'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object OpenStatLab: TLabel
    Left = 149
    Top = 81
    Width = 48
    Height = 24
    Caption = 'Error'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object PortLab: TLabel
    Left = 628
    Top = 8
    Width = 32
    Height = 17
    Caption = #1055#1086#1088#1090
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object InstallDRVBtn: TButton
    Left = 56
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Install'
    Enabled = False
    TabOrder = 0
    OnClick = InstallDRVBtnClick
  end
  object RemoveDRVBtn: TButton
    Left = 56
    Top = 163
    Width = 75
    Height = 25
    Caption = 'Remove'
    Enabled = False
    TabOrder = 1
    OnClick = RemoveDRVBtnClick
  end
  object OpenDRVBtn: TButton
    Left = 56
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Open'
    Enabled = False
    TabOrder = 2
    OnClick = OpenDRVBtnClick
  end
  object GroupBox1: TGroupBox
    Left = 230
    Top = 24
    Width = 329
    Height = 167
    Caption = ' IO PORT '
    TabOrder = 3
    object ReadByteEdit: TEdit
      Left = 11
      Top = 111
      Width = 73
      Height = 21
      TabOrder = 0
    end
    object ReadByteBtn: TButton
      Left = 9
      Top = 131
      Width = 75
      Height = 25
      Caption = 'Read byte'
      TabOrder = 1
      OnClick = ReadByteBtnClick
    end
    object WriteByteEdit: TEdit
      Left = 11
      Top = 34
      Width = 73
      Height = 21
      TabOrder = 2
      Text = '$55'
    end
    object WriteByteBtn: TButton
      Left = 9
      Top = 53
      Width = 75
      Height = 25
      Caption = 'Write byte'
      TabOrder = 3
      OnClick = WriteByteBtnClick
    end
    object WriteWORDEdit: TEdit
      Left = 119
      Top = 34
      Width = 73
      Height = 21
      TabOrder = 4
      Text = '$5555'
    end
    object WriteWORDBtn: TButton
      Left = 117
      Top = 53
      Width = 75
      Height = 25
      Caption = 'Write WORD'
      TabOrder = 5
      OnClick = WriteWORDBtnClick
    end
    object WriteDWORDEdit: TEdit
      Left = 226
      Top = 34
      Width = 85
      Height = 21
      TabOrder = 6
      Text = '$55555555'
    end
    object WriteDWORDBtn: TButton
      Left = 224
      Top = 53
      Width = 87
      Height = 25
      Caption = 'Write DWORD'
      TabOrder = 7
      OnClick = WriteDWORDBtnClick
    end
    object ReadWORDBtn: TButton
      Left = 120
      Top = 131
      Width = 75
      Height = 25
      Caption = 'Read WORD'
      TabOrder = 8
      OnClick = ReadWORDBtnClick
    end
    object ReadWORDEdit: TEdit
      Left = 122
      Top = 111
      Width = 73
      Height = 21
      TabOrder = 9
    end
    object ReadDWORDBtn: TButton
      Left = 223
      Top = 131
      Width = 87
      Height = 25
      Caption = 'Read DWORD'
      TabOrder = 10
      OnClick = ReadDWORDBtnClick
    end
    object ReadDWORDEdit: TEdit
      Left = 225
      Top = 111
      Width = 85
      Height = 21
      TabOrder = 11
    end
  end
  object WriteBARBtn: TButton
    Left = 610
    Top = 158
    Width = 87
    Height = 25
    Caption = 'Write BAR'
    TabOrder = 4
    OnClick = WriteBARBtnClick
  end
  object ReadBARBtn: TButton
    Left = 794
    Top = 37
    Width = 87
    Height = 25
    Caption = 'Read BAR'
    TabOrder = 5
    OnClick = ReadBARBtnClick
  end
  object WAddrEdit: TEdit
    Left = 609
    Top = 136
    Width = 91
    Height = 21
    TabOrder = 6
    Text = '00000CF8'
  end
  object All0Btn: TButton
    Left = 798
    Top = 136
    Width = 38
    Height = 25
    Caption = 'All 0'
    TabOrder = 7
    OnClick = All0BtnClick
  end
  object All1Btn: TButton
    Left = 842
    Top = 136
    Width = 38
    Height = 25
    Caption = 'All 1'
    TabOrder = 8
    OnClick = All1BtnClick
  end
  object MemLV: TListView
    Left = 886
    Top = 12
    Width = 527
    Height = 173
    BevelInner = bvNone
    BevelKind = bkTile
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'N'
      end
      item
        Caption = #1040#1076#1088#1077#1089
      end
      item
        Caption = '1-'#1081' '#1073#1072#1081#1090
      end
      item
        Caption = '2-'#1081' '#1073#1072#1081#1090
      end
      item
        Caption = '3-'#1081' '#1073#1072#1081#1090
      end
      item
        Caption = '4-'#1081' '#1073#1072#1081#1090
      end
      item
        Caption = #1057#1090#1088#1086#1082#1072
      end>
    ColumnClick = False
    Ctl3D = False
    DragMode = dmAutomatic
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 9
    ViewStyle = vsReport
  end
  object RAddrEdit: TEdit
    Left = 794
    Top = 15
    Width = 87
    Height = 21
    TabOrder = 10
    Text = '00000CFC'
  end
  object sRegLV: TListView
    Left = 887
    Top = 199
    Width = 388
    Height = 274
    BevelInner = bvNone
    BevelKind = bkTile
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Offset'
      end
      item
        Caption = 'Name'
      end
      item
        Caption = 'Value'
      end>
    ColumnClick = False
    Ctl3D = False
    DragMode = dmAutomatic
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 11
    ViewStyle = vsReport
  end
  object ReadPCIBtn: TButton
    Left = 794
    Top = 417
    Width = 87
    Height = 25
    Caption = 'Read PCI'
    TabOrder = 12
    OnClick = ReadPCIBtnClick
  end
  object LPTPortsCB: TComboBox
    Left = 600
    Top = 28
    Width = 94
    Height = 24
    BevelInner = bvLowered
    BevelKind = bkFlat
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 13
    OnChange = LPTPortsCBChange
  end
  object ReadPCI2Btn: TButton
    Left = 794
    Top = 445
    Width = 87
    Height = 25
    Caption = 'Read PCI 2'
    TabOrder = 14
    OnClick = ReadPCI2BtnClick
  end
end
