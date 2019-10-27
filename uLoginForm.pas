unit uLoginForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Data.DB, Data.Win.ADODB, uCommon, Vcl.ExtCtrls;

type
  TfrmLogin = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    edtUserName: TEdit;
    edtUserPass: TEdit;
    btnSave: TButton;
    btnCancel: TButton;
    imgLogo: TImage;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edtUserPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtUserNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FbResult: Boolean;
  public
    { Public declarations }
  end;

procedure CheckLoginForm;

implementation

{$R *.dfm}

var
  g_ADOCNN       : TADOConnection = nil;
  g_strLoginTable: string         = '';
  g_strLoginName : string         = '';
  g_strLoginPass : String         = '';

procedure CheckLoginForm;
var
  strLinkDB: String;
begin
  g_ADOCNN := TADOConnection.Create(nil);
  try
    with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    begin
      strLinkDB       := DecryptString(ReadString(c_strIniDBSection, 'Name', ''), c_strAESKey);
      g_strLoginTable := ReadString(c_strIniDBSection, 'LoginTable', '');
      g_strLoginName  := ReadString(c_strIniDBSection, 'LoginNameField', '');
      g_strLoginPass  := ReadString(c_strIniDBSection, 'LoginPassField', '');
      if TryLinkDataBase(strLinkDB, g_ADOCNN) then
      begin
        if (strLinkDB <> '') and (g_strLoginTable <> '') and (g_strLoginName <> '') and (g_strLoginPass <> '') then
        begin
          with TfrmLogin.Create(nil) do
          begin
            FbResult             := False;
            imgLogo.Picture.Icon := Application.Icon;
            Position             := poScreenCenter;
            ShowModal;
            if not FbResult then
              Halt(0);
            Free;
          end
        end;
      end;
      Free;
    end;
  finally
    g_ADOCNN.Free;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  FbResult := False;
  Close;
end;

procedure TfrmLogin.btnSaveClick(Sender: TObject);
var
  strSQL: String;
  qry   : TADOQuery;
begin
  if Trim(edtUserName.Text) = '' then
  begin
    MessageBox(Handle, '用户名称不能为空，请输入', '系统提示：', MB_OK OR MB_ICONERROR);
    edtUserName.SetFocus;
    Exit;
  end;

  if Trim(edtUserPass.Text) = '' then
  begin
    MessageBox(Handle, '用户密码不能为空，请输入', '系统提示：', MB_OK OR MB_ICONERROR);
    edtUserPass.SetFocus;
    Exit;
  end;

  if (g_ADOCNN.Connected) and (g_strLoginTable <> '') and (g_strLoginName <> '') and (g_strLoginPass <> '') then
  begin
    strSQL         := Format('select * from %s where %s=%s and %s=%s', [g_strLoginTable, g_strLoginName, QuotedStr(edtUserName.Text), g_strLoginPass, QuotedStr(edtUserPass.Text)]);
    qry            := TADOQuery.Create(nil);
    qry.Connection := g_ADOCNN;
    qry.SQL.Text   := strSQL;
    qry.Open;
    if qry.RecordCount > 0 then
    begin
      FbResult := True;
      try
        UpdateDataBaseScript(g_ADOCNN, True);
      except

      end;
      Close;
    end
    else
    begin
      MessageBox(Handle, '用户不存在或密码错误，请重新输入', '系统提示：', MB_OK OR MB_ICONERROR);
    end;
    qry.Free;
  end;
end;

procedure TfrmLogin.edtUserNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    edtUserPass.SetFocus;
end;

procedure TfrmLogin.edtUserPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnSave.Click;
end;

end.
