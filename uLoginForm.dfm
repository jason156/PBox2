object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #29992#25143#30331#24405
  ClientHeight = 205
  ClientWidth = 461
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    461
    205)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 68
    Top = 44
    Width = 75
    Height = 15
    Caption = #29992#25143#21517#31216#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 68
    Top = 80
    Width = 75
    Height = 15
    Caption = #29992#25143#23494#30721#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object imgLogo: TImage
    Left = 16
    Top = 15
    Width = 32
    Height = 32
    AutoSize = True
  end
  object edtUserName: TEdit
    Left = 156
    Top = 41
    Width = 221
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnKeyDown = edtUserNameKeyDown
  end
  object edtUserPass: TEdit
    Left = 156
    Top = 77
    Width = 221
    Height = 23
    Font.Charset = SYMBOL_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    PasswordChar = 'l'
    TabOrder = 1
    OnKeyDown = edtUserPassKeyDown
  end
  object btnSave: TButton
    Left = 276
    Top = 153
    Width = 101
    Height = 32
    Anchors = [akLeft, akBottom]
    Caption = #30331#24405
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnSaveClick
    ExplicitTop = 111
  end
  object btnCancel: TButton
    Left = 156
    Top = 153
    Width = 105
    Height = 32
    Anchors = [akLeft, akBottom]
    Caption = #21462#28040
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = btnCancelClick
    ExplicitTop = 111
  end
end
