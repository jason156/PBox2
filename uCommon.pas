unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, Vcl.Forms, System.SysUtils, System.IniFiles, IdIPWatch;

{ ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript: Boolean;

{ ��ȡ����IP }
function GetNativeIP: String;

type
  { ������ʾ��ʽ���˵�����ť�Ի����б� }
  TShowStyle = (ssMenu, ssButton, ssList);

  { ������ͼ��ʽ�����ĵ������ĵ� }
  TViewStyle = (vsSingle, vsMulti);

  { ֧�ֵ��ļ����� }
  TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

  {
    Dll �ı�׼�������
    �������ƣ�db_ShowDllForm
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
  TShowDllForm = procedure(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

const
  c_strTitle                                  = '���� DLL ��ģ�黯����ƽ̨ v2.0';
  c_strUIStyle: array [0 .. 2] of ShortString = ('�˵�ʽ', '��ťʽ', '����ʽ');
  c_strIniUISection                           = 'UI';
  c_strIniFormStyleSection                    = 'FormStyle';
  c_strIniModuleSection                       = 'Module';
  c_strMsgTitle: PChar                        = 'ϵͳ��ʾ��';
  c_strAESKey                                 = 'dbyoung@sina.com';
  c_strDllExportName                          = 'db_ShowDllForm_Plugins';

  WM_DESTORYPREDLLFORM = WM_USER + 1000;
  WM_CREATENEWDLLFORM  = WM_USER + 1001;

var
  g_intVCDialogDllFormHandle: THandle = 0;
  g_strCreateDllFileName    : string  = '';
  g_bExitProgram            : Boolean = False;

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

end.
