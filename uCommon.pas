unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IniFiles, Vcl.Forms, Vcl.Graphics, IdIPWatch;

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
  c_strMsgTitle: PChar                        = 'ϵͳ��ʾ��';
  c_strAESKey                                 = 'dbyoung@sina.com';
  c_strDllExportName                          = 'db_ShowDllForm_Plugins';
  WM_DESTORYPREDLLFORM                        = WM_USER + 1000;
  WM_CREATENEWDLLFORM                         = WM_USER + 1001;

  { ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript: Boolean;

{ ��ȡ����IP }
function GetNativeIP: String;

{ ����ģ�� }
procedure SortModuleList(var lstModuleList: THashedStringList);

{ �������Ŀ¼����� Dll �ļ�����ӵ��б� }
procedure SearchPlugInsDllFile(var lstDll: TStringList);

function GetShowStyle: TShowStyle;

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

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript: Boolean;
begin
  Result := True;
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

end.
