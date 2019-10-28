unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Forms, Vcl.Graphics, Data.Win.ADODB, IdIPWatch,
  FlyUtils.CnXXX.Common, FlyUtils.AES,
  IdHashMessageDigest, IdHashCRC, IdHashSHA, IdSSLOpenSSLHeaders;

type
  { ������ʾ��ʽ���˵�����ť�Ի����б� }
  TShowStyle = (ssMenu, ssButton, ssList);

  { ������ͼ��ʽ�����ĵ������ĵ� }
  TViewStyle = (vsSingle, vsMulti);

  { ֧�ֵ��ļ����� }
  TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

  {
    Dll �ı�׼�������
    �������ƣ�db_ShowDllForm_Plugins
    ����˵��:
    frm              : ��������    ��TSPFileType �� ftDelphiDll ʱ���ſ��ã�Delphiר�ã�Delphi Dll ���������������������ÿգ�NULL��
    ft               : �ļ�����    ��TSPFileType
    strPModuleName   : ��ģ������  ��
    strSModuleName   : ��ģ������  ��
    strFormClassName : ��������    ��TSPFileType �� ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE �Ż��õ��� Delphi Dll ʱ���ÿգ�
    strFormTitleName : ���������  ��TSPFileType �� ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE �Ż��õ��� Delphi Dll ʱ���ÿգ�
    strIconFileName  : ͼ���ļ�    �����û��ָ������DLL/EXE��ȡͼ�ꣻ
    bShowForm        : �Ƿ���ʾ���壻ɨ�� DLL ʱ��������ʾ DLL ���壬ֻ�ǻ�ȡ������ִ��ʱ������ʾ DLL ���壻
  }
  Tdb_ShowDllForm_Plugins = procedure(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

const
  c_strTitle                                  = '���� DLL ��ģ�黯����ƽ̨ v2.0';
  c_strUIStyle: array [0 .. 2] of ShortString = ('�˵�ʽ', '��ťʽ', '����ʽ');
  c_strIniUISection                           = 'UI';
  c_strIniFormStyleSection                    = 'FormStyle';
  c_strIniModuleSection                       = 'Module';
  c_strIniDBSection                           = 'DB';
  c_strMsgTitle: PChar                        = 'ϵͳ��ʾ��';
  c_strAESKey                                 = 'dbyoung@sina.com';
  c_strDllExportName                          = 'db_ShowDllForm_Plugins';
  WM_DESTORYPREDLLFORM                        = WM_USER + 1000;
  WM_CREATENEWDLLFORM                         = WM_USER + 1001;

  { ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ ��ȡ����IP }
function GetNativeIP: String;

{ ����ģ�� }
procedure SortModuleList(var lstModuleList: THashedStringList);

{ �������Ŀ¼����� Dll �ļ�����ӵ��б� }
procedure SearchPlugInsDllFile(var lstDll: TStringList);

function GetShowStyle: TShowStyle;

{ ִ�� Sql �ű���ִ�гɹ����Ƿ�ɾ���ļ� }
function ExeSql(const strFileName: string; ADOCNN: TADOConnection; const bDeleteFileOnSuccess: Boolean = False): Boolean;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript(const iniFile: TIniFile; const ADOCNN: TADOConnection; const bDeleteFile: Boolean = False): Boolean;

{ ��ȡ���ݿ���� }
function GetDBLibraryName(const strLinkDB: string): String;

{ ��ȡ������ǰ��¼�û����� }
function GetCurrentLoginUserName: String;

{ �������ݿ⣬֧��Զ�̱��� }
function BackupDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strSaveFileName: String): Boolean;

{ �ָ����ݿ⣬֧��Զ�ָ̻� }
function RestoreDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strDBFileName: String; var strErr: String): Boolean;

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;

{ �������ݿ����� }
function TryLinkDataBase(const strLinkDB: string; var ADOCNN: TADOConnection): Boolean;

{ �� .msc �ļ��л�ȡͼ�� }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);

var
  g_intVCDialogDllFormHandle: THandle = 0;
  g_strCreateDllFileName    : string  = '';
  g_bExitProgram            : Boolean = False;
  g_hEXEProcessID           : DWORD   = 0;

implementation

{ ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;
var
  hMainForm       : THandle;
  strTitle        : String;
  bOnlyOneInstance: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strTitle         := ReadString(c_strIniUISection, 'Title', c_strTitle);
    bOnlyOneInstance := ReadBool(c_strIniUISection, 'OnlyOneInstance', False);
    Free;
  end;

  if not bOnlyOneInstance then
    Exit;

  hMainForm := FindWindow('TfrmPBox', PChar(strTitle));
  if hMainForm <> 0 then
  begin
    MessageBox(0, '�����Ѿ����У������ظ�����', 'ϵͳ��ʾ��', MB_OK OR MB_ICONERROR);
    if IsIconic(hMainForm) then
      PostMessage(hMainForm, WM_SYSCOMMAND, SC_RESTORE, 0);
    BringWindowToTop(hMainForm);
    SetForegroundWindow(hMainForm);
    Halt;
    Exit;
  end;
end;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
var
  TP    : Winapi.Windows.TOKEN_PRIVILEGES;
  Dummy : Cardinal;
  hToken: THandle;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken);
  TP.PrivilegeCount := 1;
  LookupPrivilegeValue(nil, PChar(PrivName), TP.Privileges[0].Luid);
  if CanDebug then
    TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
  else
    TP.Privileges[0].Attributes := 0;
  Result                        := AdjustTokenPrivileges(hToken, False, TP, SizeOf(TP), nil, Dummy);
  hToken                        := 0;
end;

{ ��ȡ����IP }
function GetNativeIP: String;
var
  IdIPWatch: TIdIPWatch;
begin
  IdIPWatch := TIdIPWatch.Create(nil);
  try
    IdIPWatch.HistoryEnabled := False;
    Result                   := IdIPWatch.LocalIP;
  finally
    IdIPWatch.Free;
  end;
end;

{ ����ģ�� }
procedure SortModuleParent(var lstModuleList: THashedStringList; const strPModuleList: String);
var
  lstTemp           : THashedStringList;
  I, J              : Integer;
  strPModuleName    : String;
  strOrderModuleName: String;
begin
  lstTemp := THashedStringList.Create;
  try
    for J := 0 to Length(strPModuleList.Split([';'])) - 1 do
    begin
      for I := lstModuleList.Count - 1 downto 0 do
      begin
        strPModuleName     := lstModuleList.ValueFromIndex[I].Split([';'])[0];
        strOrderModuleName := strPModuleList.Split([';'])[J];
        if CompareText(strOrderModuleName, strPModuleName) = 0 then
        begin
          lstTemp.Add(lstModuleList.Strings[I]);
          lstModuleList.Delete(I);
        end;
      end;
    end;

    { �п��ܻ���ʣ�µģ�����ӵ���ģ��(��ģ��)����δ����֮ǰ���ǲ��������б��е� }
    if lstModuleList.Count > 0 then
    begin
      for I := 0 to lstModuleList.Count - 1 do
      begin
        lstTemp.Add(lstModuleList.Strings[I]);
      end;
    end;

    lstModuleList.Clear;
    lstModuleList.Assign(lstTemp);
  finally
    lstTemp.Free;
  end;
end;

{ ����λ�� }
procedure SwapPosHashStringList(var lstModuleList: THashedStringList; const I, J: Integer);
var
  strTemp: String;
begin
  strTemp                  := lstModuleList.Strings[I];
  lstModuleList.Strings[I] := lstModuleList.Strings[J];
  lstModuleList.Strings[J] := strTemp;
end;

{ ��ѯָ��ģ���λ�� }
function FindSubModuleIndex(const lstModuleList: THashedStringList; const strPModuleName, strSModuleName: String): Integer;
var
  I                  : Integer;
  strParentModuleName: String;
  strSubModuleName   : String;
begin
  Result := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    strSubModuleName    := lstModuleList.ValueFromIndex[I].Split([';'])[1];
    if (CompareText(strParentModuleName, strPModuleName) = 0) and (CompareText(strSubModuleName, strSModuleName) = 0) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ ��ѯָ����ģ���ָ��λ�õ������� }
function FindSubModulePos(const lstModuleList: THashedStringList; const strPModuleName: String; const intIndex: Integer): Integer;
var
  I, K               : Integer;
  strParentModuleName: String;
begin
  Result := -1;
  K      := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    if CompareText(strParentModuleName, strPModuleName) = 0 then
    begin
      Inc(K);
      if K = intIndex then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

{ ������ģ�� }
procedure SortSubModule_Proc(var lstModuleList: THashedStringList; const strPModuleName: String; const strSModuleOrder: string);
var
  I               : Integer;
  intNewIndex     : Integer;
  intOldIndex     : Integer;
  strSubModuleName: String;
begin
  for I := 0 to Length(strSModuleOrder.Split([';'])) - 1 do
  begin
    strSubModuleName := strSModuleOrder.Split([';'])[I];
    intNewIndex      := FindSubModuleIndex(lstModuleList, strPModuleName, strSubModuleName);
    intOldIndex      := FindSubModulePos(lstModuleList, strPModuleName, I);
    if (intNewIndex <> intOldIndex) and (intNewIndex > -1) and (intOldIndex > -1) then
    begin
      SwapPosHashStringList(lstModuleList, intNewIndex, intOldIndex);
    end;
  end;
end;

{ ������ģ�� }
procedure SortSubModule(var lstModuleList: THashedStringList; const strPModuleOrder: String; const iniModule: TIniFile);
var
  I, Count       : Integer;
  strPModuleName : String;
  strSModuleOrder: String;
begin
  Count := Length(strPModuleOrder.Split([';']));
  for I := 0 to Count - 1 do
  begin
    strPModuleName  := strPModuleOrder.Split([';'])[I];
    strSModuleOrder := iniModule.ReadString(c_strIniModuleSection, strPModuleName, '');
    if Trim(strSModuleOrder) <> '' then
    begin
      SortSubModule_Proc(lstModuleList, strPModuleName, strSModuleOrder);
    end;
  end;
end;

{ ����ģ�� }
procedure SortModuleList(var lstModuleList: THashedStringList);
var
  strPModuleOrder: String;
  iniModule      : TIniFile;
begin
  iniModule := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    { ����ģ�� }
    strPModuleOrder := iniModule.ReadString(c_strIniModuleSection, 'Order', '');
    if Trim(strPModuleOrder) <> '' then
      SortModuleParent(lstModuleList, strPModuleOrder);

    { ������ģ�� }
    SortSubModule(lstModuleList, strPModuleOrder, iniModule);
  finally
    iniModule.Free;
  end;
end;

{ �������Ŀ¼����� Dll �ļ�����ӵ��б� }
procedure SearchPlugInsDllFile(var lstDll: TStringList);
var
  strPlugInsPath: String;
  sr            : TSearchRec;
  intFind       : Integer;
begin
  strPlugInsPath := ExtractFilePath(ParamStr(0)) + 'plugins';
  intFind        := FindFirst(strPlugInsPath + '\*.dll', faAnyFile, sr);
  if not DirectoryExists(strPlugInsPath) then
    Exit;

  while intFind = 0 do
  begin
    if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr <> faDirectory) then
      lstDll.Add(strPlugInsPath + '\' + sr.Name);
    intFind := FindNext(sr);
  end;
end;

function GetShowStyle: TShowStyle;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := TShowStyle(ReadInteger(c_strIniFormStyleSection, 'index', 0) mod 3);
    Free;
  end;
end;

{ ִ�� Sql �ű���ִ�гɹ����Ƿ�ɾ���ļ� }
function ExeSql(const strFileName: string; ADOCNN: TADOConnection; const bDeleteFileOnSuccess: Boolean = False): Boolean;
var
  strTemp: String;
  I      : Integer;
  qry    : TADOQuery;
begin
  Result := False;
  if not FileExists(strFileName) then
    Exit;

  try
    with TStringList.Create do
    begin
      qry := TADOQuery.Create(nil);
      try
        qry.Connection := ADOCNN;
        LoadFromFile(strFileName);
        strTemp := '';
        for I   := 0 to Count - 1 do
        begin
          if SameText(Trim(Strings[I]), 'GO') then
          begin
            qry.Close;
            qry.SQL.Clear;
            qry.SQL.Text := strTemp;
            qry.ExecSQL;
            strTemp := '';
          end
          else
          begin
            strTemp := strTemp + Strings[I] + #13#10;
          end;
        end;

        if strTemp <> '' then
        begin
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Text := strTemp;
          qry.ExecSQL;
        end;
      finally
        Result := True;
        if bDeleteFileOnSuccess then
          DeleteFile(strFileName);
        qry.Free;
        Free;
      end;
    end;
  except
    Result := False;
  end;
end;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript(const iniFile: TIniFile; const ADOCNN: TADOConnection; const bDeleteFile: Boolean = False): Boolean;
var
  strSQLFileName: String;
begin
  Result := False;
  if iniFile.ReadBool(c_strIniDBSection, 'AutoUpdate', False) then
  begin
    strSQLFileName := iniFile.ReadString(c_strIniDBSection, 'AutoUpdateFile', '');
    if (Trim(strSQLFileName) <> '') and (FileExists(strSQLFileName)) then
    begin
      Result := ExeSql(ExtractFilePath(ParamStr(0)) + strSQLFileName, ADOCNN, bDeleteFile);
    end;
  end;
end;

{ ��ȡ���ݿ���� }
function GetDBLibraryName(const strLinkDB: string): String;
var
  I, J   : Integer;
  strTemp: String;
begin
  Result := '';
  I      := Pos('initial catalog=', LowerCase(strLinkDB));
  if I > 0 then
  begin
    strTemp := RightStr(strLinkDB, Length(strLinkDB) - I - Length('Initial Catalog=') + 1);
    J       := Pos(';', strTemp);
    Result  := LeftStr(strTemp, J - 1);
  end;
end;

{ ��ȡ������ǰ��¼�û����� }
function GetCurrentLoginUserName: String;
var
  Buffer: array [0 .. 255] of Char;
  Count : Cardinal;
begin
  Result := '';
  Count  := 256;
  if GetUserName(Buffer, Count) then
  begin
    Result := Buffer;
  end;
end;

{ ��ȡ������������� }
function GetNativePCName: string;
var
  chrPCName: array [0 .. 255] of Char;
  intLen   : Cardinal;
begin
  intLen := 256;
  GetComputerName(@chrPCName[0], intLen);
  Result := chrPCName;
end;

{ �������ݿ⣬֧��Զ�̱��� }
function BackupDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strSaveFileName: String): Boolean;
const
  c_strbackupDataBase =                                                    //
    ' exec master..xp_cmdshell ''net use z: \\%s\c$ "%s" /user:%s\%s'' ' + //
    ' backup database %s to disk = ''z:\temp.bak''' +                      //
    ' exec master..xp_cmdshell ''net use z: /delete''';
var
  strDBLibraryName: string;
  strNativePCName : string;
begin
  Result := False;
  if not ADOCNN.Connected then
    Exit;

  strDBLibraryName := GetDBLibraryName(ADOCNN.ConnectionString);
  strNativePCName  := GetNativePCName;

  with TADOQuery.Create(nil) do
  begin
    Connection := ADOCNN;
    SQL.Text   := Format(c_strbackupDataBase, [strNativePCName, strNativePCLoginPassword, strNativePCName, strNativePCLoginName, strDBLibraryName]);
    try
      DeleteFile('c:\temp.bak');
      ExecSQL;
      { �ƶ������ļ���ָ��λ�� }
      Result := MoveFile(PChar('c:\temp.bak'), PChar(strSaveFileName));
    except
      Result := False;
    end;
    Free;
  end;
end;

{ �ָ����ݿ⣬֧��Զ�ָ̻� }
function RestoreDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strDBFileName: String; var strErr: String): Boolean;
const
  c_strbackupDataBase =                                                    //
    ' exec master..xp_cmdshell ''net use z: \\%s\c$ "%s" /user:%s\%s'' ' + //
    ' restore database %s from disk = ''z:\temp.bak''' +                   //
    ' exec master..xp_cmdshell ''net use z: /delete''';
var
  strDBLibraryName: String;
  strNativePCName : String;
begin
  Result := False;

  if not ADOCNN.Connected then
    Exit;

  { ɾ����ʱ�ļ� }
  DeleteFile('c:\temp.bak');
  strDBLibraryName := GetDBLibraryName(ADOCNN.ConnectionString);
  strNativePCName  := GetNativePCName;

  if Trim(strDBLibraryName) = '' then
    strDBLibraryName := 'RestoreTemp';

  { �����ļ��������ھ�Ŀ¼�� }
  if CopyFile(PChar(strDBFileName), PChar('c:\temp.bak'), True) then
  begin
    with TADOQuery.Create(nil) do
    begin
      Connection := ADOCNN;
      SQL.Text   := Format(c_strbackupDataBase, [strNativePCName, strNativePCLoginPassword, strNativePCName, strNativePCLoginName, strDBLibraryName]);
      try
        ExecSQL;
        Result := True;
      except
        on E: Exception do
        begin
          strErr := E.Message;
          Result := False;
        end;
      end;
      DeleteFile('c:\temp.bak');
      Free;
    end;
  end;
end;

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;
begin
  Result := AESEncryptStrToHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;
begin
  Result := AESDecryptStrFromHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ �������ݿ����� }
function TryLinkDataBase(const strLinkDB: string; var ADOCNN: TADOConnection): Boolean;
begin
  Result := False;

  if strLinkDB = '' then
    Exit;

  if not Assigned(ADOCNN) then
    Exit;

  ADOCNN.KeepConnection := True;
  ADOCNN.LoginPrompt    := False;
  ADOCNN.Connected      := False;

  if Pos('.udl', LowerCase(strLinkDB)) > 0 then
  begin
    ADOCNN.ConnectionString := 'FILE NAME=' + strLinkDB;
    ADOCNN.Provider         := strLinkDB;
  end
  else
  begin
    ADOCNN.ConnectionString := strLinkDB;
  end;

  try
    ADOCNN.Connected := True;
    Result           := True;
  except
    Result := False;
  end;
end;

function GetSystemPath: String;
var
  Buffer: array [0 .. 255] of Char;
begin
  GetSystemDirectory(Buffer, 256);
  Result := Buffer;
end;

{ �� .msc �ļ��л�ȡͼ�� }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);
var
  strLine       : String;
  strSystemPath : String;
  I, J, intIndex: Integer;
  intIconIndex  : Integer;
  strDllFileName: String;
  strTemp       : String;
begin
  with TStringList.Create do
  begin
    intIndex      := -1;
    strSystemPath := GetSystemPath;
    LoadFromFile(strSystemPath + '\' + strMSCFileName, TEncoding.ASCII);

    for I := 0 to Count - 1 do
    begin
      strLine := Strings[I];
      if strLine <> '' then
      begin
        if Pos('<Icon Index="', strLine) > 0 then
        begin
          intIndex := I;
          Break;
        end;
      end;
    end;

    if intIndex <> -1 then
    begin
      strLine      := Strings[intIndex];
      I            := Pos('"', strLine);
      strTemp      := RightStr(strLine, Length(strLine) - I);
      J            := Pos('"', strTemp);
      intIconIndex := StrToIntDef(MidStr(strLine, I + 1, J - 1), 0);

      I              := Pos('File="', strLine);
      strTemp        := RightStr(strLine, Length(strLine) - I - 5);
      J              := Pos('"', strTemp);
      strDllFileName := MidStr(strTemp, 1, J - 1);

      IcoMSC.Handle := ExtractIcon(HInstance, PChar(strDllFileName), intIconIndex);
    end;

    Free;
  end;
end;

end.
