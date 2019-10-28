unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Forms, Vcl.Graphics, Data.Win.ADODB, IdIPWatch,
  FlyUtils.CnXXX.Common, FlyUtils.AES,
  IdHashMessageDigest, IdHashCRC, IdHashSHA, IdSSLOpenSSLHeaders;

type
  { 界面显示方式：菜单、按钮对话框、列表 }
  TShowStyle = (ssMenu, ssButton, ssList);

  { 界面视图方式：单文档、多文档 }
  TViewStyle = (vsSingle, vsMulti);

  { 支持的文件类型 }
  TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

  {
    Dll 的标准输出函数
    函数名称：db_ShowDllForm_Plugins
    参数说明:
    frm              : 窗体类名    ；TSPFileType 是 ftDelphiDll 时，才可用；Delphi专用，Delphi Dll 主窗体类名；其它语言置空，NULL；
    ft               : 文件类型    ；TSPFileType
    strPModuleName   : 父模块名称  ；
    strSModuleName   : 子模块名称  ；
    strFormClassName : 窗体类名    ；TSPFileType 是 ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE 才会用到， Delphi Dll 时，置空；
    strFormTitleName : 窗体标题名  ；TSPFileType 是 ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE 才会用到， Delphi Dll 时，置空；
    strIconFileName  : 图标文件    ；如果没有指定，从DLL/EXE获取图标；
    bShowForm        : 是否显示窗体；扫描 DLL 时，不用显示 DLL 窗体，只是获取参数；执行时，才显示 DLL 窗体；
  }
  Tdb_ShowDllForm_Plugins = procedure(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

const
  c_strTitle                                  = '基于 DLL 的模块化开发平台 v2.0';
  c_strUIStyle: array [0 .. 2] of ShortString = ('菜单式', '按钮式', '分栏式');
  c_strIniUISection                           = 'UI';
  c_strIniFormStyleSection                    = 'FormStyle';
  c_strIniModuleSection                       = 'Module';
  c_strIniDBSection                           = 'DB';
  c_strMsgTitle: PChar                        = '系统提示：';
  c_strAESKey                                 = 'dbyoung@sina.com';
  c_strDllExportName                          = 'db_ShowDllForm_Plugins';
  WM_DESTORYPREDLLFORM                        = WM_USER + 1000;
  WM_CREATENEWDLLFORM                         = WM_USER + 1001;

  { 只允许运行一个实例 }
procedure OnlyOneRunInstance;

{ 提升权限 }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ 获取本机IP }
function GetNativeIP: String;

{ 排序模块 }
procedure SortModuleList(var lstModuleList: THashedStringList);

{ 搜索插件目录下面的 Dll 文件，添加到列表 }
procedure SearchPlugInsDllFile(var lstDll: TStringList);

function GetShowStyle: TShowStyle;

{ 执行 Sql 脚本，执行成功，是否删除文件 }
function ExeSql(const strFileName: string; ADOCNN: TADOConnection; const bDeleteFileOnSuccess: Boolean = False): Boolean;

{ 升级数据库---执行脚本 }
function UpdateDataBaseScript(const iniFile: TIniFile; const ADOCNN: TADOConnection; const bDeleteFile: Boolean = False): Boolean;

{ 获取数据库库名 }
function GetDBLibraryName(const strLinkDB: string): String;

{ 获取本机当前登录用户名称 }
function GetCurrentLoginUserName: String;

{ 备份数据库，支持远程备份 }
function BackupDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strSaveFileName: String): Boolean;

{ 恢复数据库，支持远程恢复 }
function RestoreDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strDBFileName: String; var strErr: String): Boolean;

{ 加密字符串 }
function EncryptString(const strTemp, strKey: string): String;

{ 解密字符串 }
function DecryptString(const strTemp, strKey: string): String;

{ 建立数据库连接 }
function TryLinkDataBase(const strLinkDB: string; var ADOCNN: TADOConnection): Boolean;

{ 从 .msc 文件中获取图标 }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);

var
  g_intVCDialogDllFormHandle: THandle = 0;
  g_strCreateDllFileName    : string  = '';
  g_bExitProgram            : Boolean = False;
  g_hEXEProcessID           : DWORD   = 0;

implementation

{ 只允许运行一个实例 }
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
    MessageBox(0, '程序已经运行，无需重复运行', '系统提示：', MB_OK OR MB_ICONERROR);
    if IsIconic(hMainForm) then
      PostMessage(hMainForm, WM_SYSCOMMAND, SC_RESTORE, 0);
    BringWindowToTop(hMainForm);
    SetForegroundWindow(hMainForm);
    Halt;
    Exit;
  end;
end;

{ 提升权限 }
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

{ 获取本机IP }
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

{ 排序父模块 }
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

    { 有可能会有剩下的；后添加的新模块(父模块)，在未排序之前，是不在排序列表中的 }
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

{ 交换位置 }
procedure SwapPosHashStringList(var lstModuleList: THashedStringList; const I, J: Integer);
var
  strTemp: String;
begin
  strTemp                  := lstModuleList.Strings[I];
  lstModuleList.Strings[I] := lstModuleList.Strings[J];
  lstModuleList.Strings[J] := strTemp;
end;

{ 查询指定模块的位置 }
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

{ 查询指定子模块的指定位置的索引号 }
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

{ 排序子模块 }
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

{ 排序子模块 }
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

{ 排序模块 }
procedure SortModuleList(var lstModuleList: THashedStringList);
var
  strPModuleOrder: String;
  iniModule      : TIniFile;
begin
  iniModule := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    { 排序父模块 }
    strPModuleOrder := iniModule.ReadString(c_strIniModuleSection, 'Order', '');
    if Trim(strPModuleOrder) <> '' then
      SortModuleParent(lstModuleList, strPModuleOrder);

    { 排序子模块 }
    SortSubModule(lstModuleList, strPModuleOrder, iniModule);
  finally
    iniModule.Free;
  end;
end;

{ 搜索插件目录下面的 Dll 文件，添加到列表 }
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

{ 执行 Sql 脚本，执行成功，是否删除文件 }
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

{ 升级数据库---执行脚本 }
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

{ 获取数据库库名 }
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

{ 获取本机当前登录用户名称 }
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

{ 获取本机计算机名称 }
function GetNativePCName: string;
var
  chrPCName: array [0 .. 255] of Char;
  intLen   : Cardinal;
begin
  intLen := 256;
  GetComputerName(@chrPCName[0], intLen);
  Result := chrPCName;
end;

{ 备份数据库，支持远程备份 }
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
      { 移动备份文件到指定位置 }
      Result := MoveFile(PChar('c:\temp.bak'), PChar(strSaveFileName));
    except
      Result := False;
    end;
    Free;
  end;
end;

{ 恢复数据库，支持远程恢复 }
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

  { 删除临时文件 }
  DeleteFile('c:\temp.bak');
  strDBLibraryName := GetDBLibraryName(ADOCNN.ConnectionString);
  strNativePCName  := GetNativePCName;

  if Trim(strDBLibraryName) = '' then
    strDBLibraryName := 'RestoreTemp';

  { 复制文件到网络邻居目录中 }
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

{ 加密字符串 }
function EncryptString(const strTemp, strKey: string): String;
begin
  Result := AESEncryptStrToHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ 解密字符串 }
function DecryptString(const strTemp, strKey: string): String;
begin
  Result := AESDecryptStrFromHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ 建立数据库连接 }
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

{ 从 .msc 文件中获取图标 }
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
