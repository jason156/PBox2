unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, Vcl.Forms, System.SysUtils, System.IniFiles, IdIPWatch;

{ 只允许运行一个实例 }
procedure OnlyOneRunInstance;

{ 提升权限 }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ 升级数据库---执行脚本 }
function UpdateDataBaseScript: Boolean;

{ 获取本机IP }
function GetNativeIP: String;

type
  { 界面显示方式：菜单、按钮对话框、列表 }
  TShowStyle = (ssMenu, ssButton, ssList);

  { 界面视图方式：单文档、多文档 }
  TViewStyle = (vsSingle, vsMulti);

  { 支持的文件类型 }
  TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

  {
    Dll 的标准输出函数
    函数名称：db_ShowDllForm
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
  TShowDllForm = procedure(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

const
  c_strTitle                                  = '基于 DLL 的模块化开发平台 v2.0';
  c_strUIStyle: array [0 .. 2] of ShortString = ('菜单式', '按钮式', '分栏式');
  c_strIniUISection                           = 'UI';
  c_strIniFormStyleSection                    = 'FormStyle';
  c_strIniModuleSection                       = 'Module';
  c_strMsgTitle: PChar                        = '系统提示：';
  c_strAESKey                                 = 'dbyoung@sina.com';
  c_strDllExportName                          = 'db_ShowDllForm_Plugins';

  WM_DESTORYPREDLLFORM = WM_USER + 1000;
  WM_CREATENEWDLLFORM  = WM_USER + 1001;

var
  g_intVCDialogDllFormHandle: THandle = 0;
  g_strCreateDllFileName    : string  = '';
  g_bExitProgram            : Boolean = False;

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

{ 升级数据库---执行脚本 }
function UpdateDataBaseScript: Boolean;
begin
  Result := True;
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

end.
