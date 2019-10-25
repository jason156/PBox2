unit uDBConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Buttons, Vcl.ComCtrls, Data.Win.ADOConEd, Data.DB, Data.Win.ADODB, uCommon;

type
  TDBConfig = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    pgcAll: TPageControl;
    tsCreateDBLink: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    ts4: TTabSheet;
    ts5: TTabSheet;
    ts6: TTabSheet;
    ts7: TTabSheet;
    ts8: TTabSheet;
    ts9: TTabSheet;
    btnCreateDBLink: TButton;
    adoCNN: TADOConnection;
    btnCreateDB: TButton;
    btnZoomOut: TButton;
    btnSelectUpdataDB: TButton;
    btnBackupDatabase: TButton;
    lblLoginName: TLabel;
    lblLoginPass: TLabel;
    edtLoginPass1: TEdit;
    edtLoginName1: TEdit;
    lblTip: TLabel;
    btnRestoreDatabase: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edtLoginPass2: TEdit;
    edtLoginName2: TEdit;
    Label3: TLabel;
    chkAutoUpdateDB: TCheckBox;
    lblAutoUpdateDBSQLScriptFileNameDelete: TLabel;
    edtUpdateDBSqlScriptFileName: TEdit;
    lblAutoUpdateDBSQLScriptFileName: TLabel;
    grpEffectLogin: TGroupBox;
    lblLoginTable: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    cbbLoginTable: TComboBox;
    cbbLoginName: TComboBox;
    cbbLoginPass: TComboBox;
    chk1: TCheckBox;
    pnlDesEnc: TPanel;
    lbl4: TLabel;
    lbl3: TLabel;
    cbb3: TComboBox;
    edt3: TEdit;
    btnTestAES: TButton;
    grpDllDesFunc: TGroupBox;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    cbb4: TComboBox;
    SearchBox1: TSearchBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCreateDBLinkClick(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnSelectUpdataDBClick(Sender: TObject);
    procedure btnBackupDatabaseClick(Sender: TObject);
    procedure btnRestoreDatabaseClick(Sender: TObject);
    procedure chkAutoUpdateDBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FmemIni: TMemIniFile;
    function CheckLinkDB: Boolean;
    procedure ReadConfigFillUI;
    procedure LinkDBFromUDLFile(const strLinkDB: string);
    procedure LinkDBFromString(const strLinkDB: string);
    procedure CreateDataBase(adoCNN: TADOConnection);
    { ����¼���� }
    procedure FillLoginConfig;
  public
    { Public declarations }
  end;

function ShowDBConfigForm(var memIni: TMemIniFile): Boolean;

implementation

{$R *.dfm}

function ShowDBConfigForm(var memIni: TMemIniFile): Boolean;
begin
  Result := True;
  with TDBConfig.Create(nil) do
  begin
    FmemIni := memIni;
    ReadConfigFillUI;
    ShowModal;
    Free;
  end;
end;

procedure TDBConfig.LinkDBFromString(const strLinkDB: string);
begin
  adoCNN.ConnectionString := strLinkDB;
end;

procedure TDBConfig.LinkDBFromUDLFile(const strLinkDB: string);
var
  strFileName: String;
  intIndex   : Integer;
begin
  intIndex    := Pos('FILE NAME=', strLinkDB);
  strFileName := RightStr(strLinkDB, Length(strLinkDB) - intIndex - 9);

  adoCNN.ConnectionString := strLinkDB;
  adoCNN.Provider         := strFileName;
end;

{ �������ݿ� }
procedure TDBConfig.btnCreateDBLinkClick(Sender: TObject);
var
  strLinkDB: String;
  intIndex : Integer;
begin
  CheckLinkDB;

  { �Ͽ����ݿ����� }
  adoCNN.Connected := False;
  if not EditConnectionString(adoCNN) then
  begin
    { ���½������ݿ����� }
    CheckLinkDB;
    Exit;
  end;

  strLinkDB := adoCNN.ConnectionString;
  intIndex  := Pos('FILE NAME=', strLinkDB);
  if intIndex > 0 then
  begin
    LinkDBFromUDLFile(strLinkDB);
    FmemIni.WriteString(c_strIniDBSection, 'Name', EncryptString(adoCNN.Provider, c_strAESKey));
  end
  else
  begin
    LinkDBFromString(strLinkDB);
    FmemIni.WriteString(c_strIniDBSection, 'Name', EncryptString(strLinkDB, c_strAESKey));
  end;

  adoCNN.Connected := True;
  FillLoginConfig;
end;

{ ��ԭ���ݿ� }
procedure TDBConfig.btnRestoreDatabaseClick(Sender: TObject);
var
  strErr: String;
begin
  if Trim(edtLoginPass2.Text) = '' then
  begin
    edtLoginPass2.SetFocus;
    MessageBox(Handle, '��¼���뱾��Ϊ�գ�', c_strTitle, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  with TOpenDialog.Create(nil) do
  begin
    Filter := 'BACKUP(*.bak)|*.bak';
    if not Execute(Handle) then
    begin
      Free;
      Exit;
    end;

    { ��ԭ���ݿ� }
    if RestoreDataBase(adoCNN, edtLoginName2.Text, edtLoginPass2.Text, FileName, strErr) then
      MessageBox(Handle, '���ݿ⻹ԭ�ɹ���', c_strTitle, MB_OK or MB_ICONINFORMATION)
    else
      MessageBox(Handle, PChar('���ݿ⻹ԭʧ�ܣ�' + strErr + '��'), c_strTitle, MB_OK or MB_ICONERROR);
    Free;
  end;
end;

{ �������ݿ� }
procedure TDBConfig.btnCreateDBClick(Sender: TObject);
var
  strConnection: String;
  strTemp      : String;
  I, J         : Integer;
  adoCNNTemp   : TADOConnection;
begin
  strConnection := LowerCase(adoCNN.ConnectionString);
  if Pos('initial catalog=', strConnection) > 0 then
  begin
    I       := Pos('initial catalog=', strConnection);
    strTemp := RightStr(strConnection, Length(strConnection) - I - 16 + 1);
    J       := Pos(';', strTemp);
    if J = 0 then
    begin
      strTemp := LeftStr(strConnection, I - 1);
    end
    else
    begin
      strTemp := LeftStr(strConnection, I - 1);
      strTemp := strTemp + RightStr(strConnection, Length(strConnection) - I - 16 - J + 1);
    end;
    adoCNNTemp := TADOConnection.Create(nil);
    try
      adoCNNTemp.LoginPrompt      := False;
      adoCNNTemp.KeepConnection   := True;
      adoCNNTemp.ConnectionString := strTemp;
      adoCNNTemp.Connected        := True;
      CreateDataBase(adoCNNTemp);
    finally
      adoCNNTemp.Free;
    end;
  end
  else
  begin
    CreateDataBase(adoCNN);
  end;
end;

{ �������ݿ� }
procedure TDBConfig.btnBackupDatabaseClick(Sender: TObject);
var
  strSaveFileName: String;
begin
  if Trim(edtLoginPass1.Text) = '' then
  begin
    edtLoginPass1.SetFocus;
    MessageBox(Handle, '��¼���뱾��Ϊ�գ�', c_strTitle, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  with TSaveDialog.Create(nil) do
  begin
    if not Execute(Handle) then
    begin
      Free;
      Exit;
    end;

    strSaveFileName := FileName;
    if LowerCase(ExtractFileExt(strSaveFileName)) <> '.bak' then
    begin
      strSaveFileName := strSaveFileName + '.bak';
    end;

    Free;
  end;

  { �������ݿ� }
  if BackupDataBase(adoCNN, edtLoginName1.Text, edtLoginPass1.Text, strSaveFileName) then
    MessageBox(Handle, '���ݿⱸ�ݳɹ���', c_strTitle, MB_OK or MB_ICONINFORMATION)
  else
    MessageBox(Handle, '���ݿⱸ��ʧ�ܣ�����ϵ����Ա��', c_strTitle, MB_OK or MB_ICONERROR);
end;

procedure TDBConfig.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDBConfig.btnSaveClick(Sender: TObject);
begin
  if (chkAutoUpdateDB.Checked) and (Trim(edtUpdateDBSqlScriptFileName.Text) = '') then
  begin
    MessageBox(Handle, '�����ű��ļ�������Ϊ��', c_strTitle, MB_OK or MB_ICONINFORMATION);
    edtUpdateDBSqlScriptFileName.SetFocus;
    Exit;
  end;

  if (not chkAutoUpdateDB.Checked) then
  begin
    FmemIni.WriteString(c_strIniDBSection, 'AutoUpdate', '');
  end;

  if (chkAutoUpdateDB.Checked) and (Trim(edtUpdateDBSqlScriptFileName.Text) <> '') then
  begin
    FmemIni.WriteString(c_strIniDBSection, 'AutoUpdate', edtUpdateDBSqlScriptFileName.Text);
  end;

  FmemIni.WriteInteger(c_strIniDBSection, 'ActivePageIndex', pgcAll.ActivePageIndex);
  FmemIni.UpdateFile;
  Close;
end;

{ ѡ�������ű� }
procedure TDBConfig.btnSelectUpdataDBClick(Sender: TObject);
begin
  CreateDataBase(adoCNN);
end;

{ ����/ѹ�����ݿ� }
procedure TDBConfig.btnZoomOutClick(Sender: TObject);
var
  strDBLibraryName: String;
begin
  strDBLibraryName := GetDBLibraryName(adoCNN.ConnectionString);
  if Trim(strDBLibraryName) <> '' then
  begin
    with TADOQuery.Create(nil) do
    begin
      Connection := adoCNN;
      sql.Add('DBCC SHRINKDATABASE (' + strDBLibraryName + ')');
      sql.Add('DBCC SHRINKFILE (' + strDBLibraryName + ',0,TRUNCATEONLY)');
      try
        ExecSQL;
        MessageBox(Handle, '���ݿ������ɹ���', c_strTitle, MB_OK or MB_ICONINFORMATION);
      except
        MessageBox(Handle, '���ݿ�����ʧ�ܣ�', c_strTitle, MB_OK or MB_ICONERROR);
      end;
      Free;
    end;
  end;
end;

{ �������ݿ� }
function TDBConfig.CheckLinkDB: Boolean;
var
  strLinkDB: String;
begin
  Result := True;
  try
    strLinkDB := DecryptString(FmemIni.ReadString(c_strIniDBSection, 'Name', ''), c_strAESKey);
    if Pos('.udl', LowerCase(strLinkDB)) > 0 then
    begin
      adoCNN.ConnectionString := 'FILE NAME=' + strLinkDB;
      adoCNN.Provider         := strLinkDB;
    end
    else
    begin
      adoCNN.ConnectionString := strLinkDB;
    end;
    adoCNN.Connected := True;
  except
    Result := False;
  end;
end;

procedure TDBConfig.chkAutoUpdateDBClick(Sender: TObject);
begin
  edtUpdateDBSqlScriptFileName.Visible           := chkAutoUpdateDB.Checked;
  lblAutoUpdateDBSQLScriptFileName.Visible       := chkAutoUpdateDB.Checked;
  lblAutoUpdateDBSQLScriptFileNameDelete.Visible := chkAutoUpdateDB.Checked;
end;

procedure TDBConfig.CreateDataBase(adoCNN: TADOConnection);
begin
  if not adoCNN.Connected then
  begin
    MessageBox(Application.MainForm.Handle, '�ȴ������ݿ����ӣ����ܽ��д������ݿ�', c_strTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  with TOpenDialog.Create(nil) do
  begin
    Filter := 'SQL�ű�(*.sql)|*.sql';
    if Execute(Application.MainForm.Handle) then
    begin
      if ExeSql(FileName, adoCNN) then
        MessageBox(Application.MainForm.Handle, '�������ݿ�ɹ�', c_strTitle, MB_OK or MB_ICONINFORMATION)
      else
        MessageBox(Application.MainForm.Handle, '�������ݿ�ʧ��', c_strTitle, MB_OK or MB_ICONERROR);
    end;
    Free;
  end;
end;

procedure TDBConfig.FillLoginConfig;
var
  lstTables: TStringList;
begin
  if not adoCNN.Connected then
    Exit;

  cbbLoginTable.Items.Clear;
  cbbLoginName.Items.Clear;
  cbbLoginPass.Items.Clear;
  lstTables := TStringList.Create;
  try
    adoCNN.GetTableNames(lstTables);
    cbbLoginTable.Items.AddStrings(lstTables);
  finally
    lstTables.Free;
  end;
end;

procedure TDBConfig.FormShow(Sender: TObject);
var
  strAutoUpdateDBSQLFileName: String;
begin
  { �������ݿ� }
  CheckLinkDB;

  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    pgcAll.ActivePageIndex     := ReadInteger(c_strIniDBSection, 'ActivePageIndex', 0);
    strAutoUpdateDBSQLFileName := ReadString(c_strIniDBSection, 'AutoUpdate', '');
    Free;
  end;

  { �Զ������ű� }
  if Trim(strAutoUpdateDBSQLFileName) <> '' then
  begin
    chkAutoUpdateDB.Checked           := True;
    edtUpdateDBSqlScriptFileName.Text := strAutoUpdateDBSQLFileName;
  end;

  edtLoginName1.Text := GetCurrentLoginUserName;
  edtLoginName2.Text := GetCurrentLoginUserName;

  FillLoginConfig;
end;

procedure TDBConfig.ReadConfigFillUI;
begin
  //
end;

end.
