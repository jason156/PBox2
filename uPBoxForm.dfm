object frmPBox: TfrmPBox
  Left = 0
  Top = 0
  Caption = 'PBox '#24037#20855#31665' v2.0'
  ClientHeight = 650
  ClientWidth = 1004
  Color = clBtnFace
  Constraints.MinHeight = 649
  Constraints.MinWidth = 1020
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 625
    Width = 1004
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'pnlBottom'
    Color = 15109422
    Ctl3D = False
    ParentBackground = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 0
    object pnlInfo: TPanel
      Left = 439
      Top = 0
      Width = 213
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      Caption = 'pnlInfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 0
      object lblInfo: TLabel
        Left = 4
        Top = 4
        Width = 8
        Height = 15
        Font.Charset = GB2312_CHARSET
        Font.Color = clWhite
        Font.Height = -15
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object bvlModule: TBevel
        Left = 211
        Top = 0
        Width = 2
        Height = 25
        Align = alRight
        ExplicitLeft = 163
      end
    end
    object pnlTime: TPanel
      Left = 780
      Top = 0
      Width = 224
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      Caption = 'pnlInfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 1
      object lblTime: TLabel
        Left = 8
        Top = 4
        Width = 8
        Height = 16
        Font.Charset = GB2312_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlIP: TPanel
      Left = 652
      Top = 0
      Width = 128
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      Caption = 'pnlInfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 2
      object lblIP: TLabel
        Left = 4
        Top = 4
        Width = 8
        Height = 16
        Font.Charset = GB2312_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object bvlIP: TBevel
        Left = 126
        Top = 0
        Width = 2
        Height = 25
        Align = alRight
        ExplicitLeft = 118
      end
    end
    object pnlDownUp: TPanel
      Left = 226
      Top = 0
      Width = 213
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      Caption = 'pnlInfo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 3
      object lblDownUp: TLabel
        Left = 4
        Top = 4
        Width = 8
        Height = 15
        Font.Charset = GB2312_CHARSET
        Font.Color = clWhite
        Font.Height = -15
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
      object bvlDownUP: TBevel
        Left = 211
        Top = 0
        Width = 2
        Height = 25
        Align = alRight
        ExplicitLeft = 163
      end
    end
  end
  object clbrModuleMenu: TCoolBar
    Left = 0
    Top = 0
    Width = 1004
    Height = 28
    AutoSize = True
    Bands = <
      item
        Control = tlbMenu
        ImageIndex = -1
        MinHeight = 24
        Width = 998
      end>
    object tlbMenu: TToolBar
      Left = 11
      Top = 0
      Width = 989
      Height = 24
      Caption = 'tlbMenu'
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
    end
  end
  object rzpgcntrlAll: TPageControl
    Left = 0
    Top = 28
    Width = 1004
    Height = 597
    ActivePage = tsButton
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 2
    ExplicitTop = 34
    ExplicitWidth = 1002
    ExplicitHeight = 589
    object tsButton: TTabSheet
      Caption = 'tsButton'
      ExplicitWidth = 994
      ExplicitHeight = 495
      object imgButtonBack: TImage
        Left = 0
        Top = 0
        Width = 996
        Height = 569
        Align = alClient
        Stretch = True
        ExplicitLeft = 272
        ExplicitTop = 128
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
    end
    object tsList: TTabSheet
      Caption = 'tsList'
      ExplicitWidth = 994
      ExplicitHeight = 495
      object imgListBack: TImage
        Left = 0
        Top = 0
        Width = 996
        Height = 569
        Align = alClient
        Stretch = True
        ExplicitLeft = 272
        ExplicitTop = 128
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
    end
    object tsDll: TTabSheet
      Caption = 'tsDll'
      ExplicitWidth = 994
      ExplicitHeight = 495
      object imgDllFormBack: TImage
        Left = 0
        Top = 0
        Width = 996
        Height = 569
        Align = alClient
        Stretch = True
        ExplicitLeft = 272
        ExplicitTop = 128
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
    end
  end
  object ilMainMenu: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 109
    Top = 194
  end
  object mmMainMenu: TMainMenu
    AutoHotkeys = maManual
    AutoMerge = True
    Images = ilMainMenu
    Left = 104
    Top = 260
  end
  object tmrDateTime: TTimer
    OnTimer = tmrDateTimeTimer
    Left = 112
    Top = 332
  end
  object pmTray: TPopupMenu
    AutoHotkeys = maManual
    Left = 264
    Top = 80
    object mniTrayShowForm: TMenuItem
      Caption = #26174#31034
      OnClick = mniTrayShowFormClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mniTrayExit: TMenuItem
      Caption = #36864#20986
      OnClick = mniTrayExitClick
    end
  end
end
