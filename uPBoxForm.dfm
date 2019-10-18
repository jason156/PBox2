object frmPBox: TfrmPBox
  Left = 0
  Top = 0
  Caption = 'PBox '#24037#20855#31665' v2.0'
  ClientHeight = 610
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 585
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
      Left = 431
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
      Left = 772
      Top = 0
      Width = 232
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
      Left = 644
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
      Left = 218
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
  object clbr1: TCoolBar
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
  object rzpgcntrlAll: TRzPageControl
    Left = 2
    Top = 100
    Width = 1002
    Height = 483
    Hint = ''
    ActivePage = rztbshtDllForm
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabIndex = 2
    TabOrder = 2
    FixedDimension = 19
    object rztbshtCenter: TRzTabSheet
      Caption = 'rztbshtCenter'
    end
    object rztbshtConfig: TRzTabSheet
      Caption = 'rztbshtConfig'
    end
    object rztbshtDllForm: TRzTabSheet
      Caption = 'rztbshtDllForm'
    end
  end
  object ilMain: TImageList
    Left = 109
    Top = 194
    Bitmap = {
      494C010101001C00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000D8CCBCFFD7CBBBFFD7CAB9FF1130
      AFFF0C00A0FF050871FF050E5CFF044336FF05453AFF094648FF08432AFF053F
      0FFF053E0AFF053E0AFF05400CFF053F0AFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DED4C7FFDED3C5FFC9B1C5FF0E01
      B7FF0D00ABFF070480FF050966FF043143FF03411FFF074012FF063F0CFF053F
      0AFF053E0AFF053E0AFF05400CFF05400BFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E4DDD1FFE3DBD0FF853ECFFF0E00
      BCFF0D00AFFF0A0195FF050870FF041B4DFF023F0CFF043F0DFF053F0BFF053F
      0AFF053E0AFF053F0BFF05400CFF05400BFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E9E3DBFFBD9ADBFF6606D6FF0E00
      C0FF0E00B4FF0C00A5FF06067AFF040B39FF023A0CFF013E0BFF053F0BFF053F
      0BFF053E0AFF053F0BFF05400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EFEAE3FFDFCFE2FF853CDBFF0E00
      C3FF0E00B8FF0D00ACFF09028CFF040A17FF03270CFF003E0AFF033E0BFF053F
      0BFF053F0AFF053F0BFF05400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F3F0ECFFF3F0EAFFF0EAE8FF1239
      D1FF0E01BCFF0D00B0FF0B0577FF040A0EFF02120BFF003E0AFF023E0AFF053F
      0BFF053F0AFF06400CFF05400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F8F5F2FFF7F5F1FFF6F4F0FF1879
      E1FF155AD7FF0F0DB8FF0B0846FF050A0FFF000A09FF003209FF003E0AFF053F
      0BFF053F0BFF06400DFF05400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FAFAF8FFFAF9F7FFFAF8F6FF187B
      E7FF187AE4FF166BCFFF0C1917FF060A0EFF000A0AFF001F0AFF003E0AFF033E
      0AFF053F0BFF06400DFF06400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDFDFCFFFDFDFCFFF8F9FAFF4498
      EEFF187CE9FF15638EFF103D17FF0A1E0DFF010A0AFF000D09FF003D0AFF013E
      0AFF063F0CFF06400DFF06400CFF05400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFEFFFEFEFEFFFEFD
      FDFFD0E5F8FF596A44FF173B13FF0C300FFF07250DFF010E0AFF002C0AFF003E
      0AFF063F0CFF07400DFF06400DFF06400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF3E9D5FFAA771CFF665C13FF454B11FF1D370FFF05270CFF01230AFF003E
      0AFF033F0CFF07400DFF06400DFF06400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFD7B87FFFA3751CFF685D13FF665B13FF645812FF174910FF0B370EFF044E
      0DFF02400CFF07400DFF06400DFF06400CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFDFC
      FAFFBE8B30FFB77D1FFF826817FF675C13FF665912FF365211FF134B10FF1063
      11FF0D7213FF0C4C0EFF07400DFF06400DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFDFC
      FAFFF5EEDEFFF1E6CEFFE2D8B9FF859C52FF7D9348FF698740FF156D2FFF1675
      32FF129729FF228D1FFF336B1AFF12420DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFC9E0BBFF8EBE72FF8DBB6FFF30A967FF1FB8
      91FF1AD380FF18CE67FF61E381FF56B66EFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFAFF9FC786FF8DBB70FF5DB16BFF21C3
      A9FF1FCF9EFF23D571FF55DF7DFF67DF7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object mmMain: TMainMenu
    AutoHotkeys = maManual
    AutoMerge = True
    Left = 112
    Top = 260
  end
  object tmrDateTime: TTimer
    OnTimer = tmrDateTimeTimer
    Left = 112
    Top = 332
  end
end
