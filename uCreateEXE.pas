unit uCreateEXE;

interface

uses Winapi.Windows, Winapi.ShellAPI, System.SysUtils, Vcl.Forms, Vcl.ComCtrls, uCommon, HookUtils;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; frmMain: TForm; pg: TPageControl; ts: TTabSheet);

implementation

var
  g_strEXEFormClassName  : string  = '';
  g_strEXEFormTitleName  : string  = '';
  g_OldEXEWndProc        : Pointer = nil;
  g_OldEXE_CreateProcessW: function(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
  g_frmMain              : TForm;
  g_PageControl          : TPageControl;
  g_Tabsheet             : TTabSheet;

function _EXE_CreateProcessW(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
var
  hEXEFormHandle: THandle;
begin
  Result          := g_OldEXE_CreateProcessW(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);
  g_hEXEProcessID := lpProcessInformation.dwProcessId;

  while True do
  begin
    hEXEFormHandle := FindWindow(PChar(g_strEXEFormClassName), PChar(g_strEXEFormTitleName));
    if hEXEFormHandle <> 0 then
      Break;
  end;

  SetWindowPos(hEXEFormHandle, g_Tabsheet.Handle, 0, 0, g_Tabsheet.Width, g_Tabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(hEXEFormHandle, g_Tabsheet.Handle);                                                                // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                         // 删除移动菜单
  SetWindowLong(hEXEFormHandle, GWL_STYLE, $96C80000);                                                                        // $96000000
  SetWindowLong(hEXEFormHandle, GWL_EXSTYLE, $00010000);                                                                      // $00010101
  ShowWindow(hEXEFormHandle, SW_SHOWNORMAL);
  g_frmMain.Height         := g_frmMain.Height + 1;
  g_frmMain.Height         := g_frmMain.Height - 1;
  g_PageControl.ActivePage := g_Tabsheet;
end;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; frmMain: TForm; pg: TPageControl; ts: TTabSheet);
begin
  g_frmMain     := frmMain;
  g_PageControl := pg;
  g_Tabsheet    := ts;

  g_strEXEFormClassName := strFileValue.Split([','])[2];
  g_strEXEFormTitleName := strFileValue.Split([','])[3];

  if @g_OldEXE_CreateProcessW = nil then
    @g_OldEXE_CreateProcessW := HookProcInModule(kernel32, 'CreateProcessW', @_EXE_CreateProcessW);

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(frmMain.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

end.
