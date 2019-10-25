object DBConfig: TDBConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #25968#25454#24211#37197#32622
  ClientHeight = 495
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    832
    495)
  PixelsPerInch = 96
  TextHeight = 13
  object btnSave: TButton
    Left = 728
    Top = 451
    Width = 92
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = #20445#23384
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 616
    Top = 451
    Width = 92
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object pgcAll: TPageControl
    Left = 8
    Top = 8
    Width = 812
    Height = 437
    ActivePage = ts1
    TabHeight = 35
    TabOrder = 2
    TabWidth = 89
    object ts1: TTabSheet
      Caption = #36830#25509
      ExplicitTop = 46
      ExplicitHeight = 387
    end
    object ts2: TTabSheet
      Caption = #21019#24314
      ImageIndex = 1
    end
    object ts7: TTabSheet
      Caption = #30331#24405
      ImageIndex = 6
    end
    object ts3: TTabSheet
      Caption = #21319#32423
      ImageIndex = 2
    end
    object ts4: TTabSheet
      Caption = #25910#32553
      ImageIndex = 3
    end
    object ts5: TTabSheet
      Caption = #22791#20221
      ImageIndex = 4
    end
    object ts6: TTabSheet
      Caption = #36824#21407
      ImageIndex = 5
    end
    object ts8: TTabSheet
      Caption = #23450#26399#28165#38500#25968#25454
      ImageIndex = 7
    end
    object ts9: TTabSheet
      Caption = #23450#26399#22791#20221#25968#25454
      ImageIndex = 8
    end
  end
end
