unit uCreateEXE;
{
  创建 EXE 窗体
}

interface

uses Winapi.Windows, Winapi.ShellAPI, Winapi.Messages, System.SysUtils, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, Winapi.PsAPI, Winapi.TlHelp32, uCommon, HookUtils;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; pg: TPageControl; ts: TTabSheet; lblInfo: TLabel);

implementation

var
  g_strEXEFormClassName  : string = '';
  g_strEXEFormTitleName  : string = '';
  g_OldEXE_CreateProcessW: function(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
  g_PageControl          : TPageControl;
  g_Tabsheet             : TTabSheet;
  g_lblInfo              : TLabel;

{ 进程是否关闭 }
function CheckProcessExist(const intPID: DWORD): Boolean;
var
  hSnap: THandle;
  vPE  : TProcessEntry32;
begin
  Result     := False;
  hSnap      := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  vPE.dwSize := SizeOf(TProcessEntry32);
  if Process32First(hSnap, vPE) then
  begin
    while Process32Next(hSnap, vPE) do
    begin
      if vPE.th32ProcessID = intPID then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
  CloseHandle(hSnap);
end;

  { 进程关闭后，变量复位 }
procedure EndExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if not CheckProcessExist(g_hEXEProcessID) then
  begin
    g_lblInfo.Caption      := '';
    g_hEXEProcessID        := 0;
    g_strCreateDllFileName := '';
    KillTimer(Application.MainForm.Handle, $2000);
  end;
end;

procedure SearchExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  hEXEFormHandle: THandle;
begin
  hEXEFormHandle := FindWindow(PChar(g_strEXEFormClassName), PChar(g_strEXEFormTitleName));
  if hEXEFormHandle <> 0 then
  begin
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
    Application.MainForm.Height := Application.MainForm.Height + 1;
    Application.MainForm.Height := Application.MainForm.Height - 1;
    g_PageControl.ActivePage    := g_Tabsheet;
    KillTimer(Application.MainForm.Handle, $1000);
    SetTimer(Application.MainForm.Handle, $2000, 100, @EndExeForm);
  end;
end;

function _EXE_CreateProcessW(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
begin
  Result          := g_OldEXE_CreateProcessW(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);
  g_hEXEProcessID := lpProcessInformation.dwProcessId;

  SetTimer(Application.MainForm.Handle, $1000, 100, @SearchExeForm);
end;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; pg: TPageControl; ts: TTabSheet; lblInfo: TLabel);
begin
  // Application.MainForm     := frmMain;
  g_PageControl := pg;
  g_Tabsheet    := ts;
  g_lblInfo     := lblInfo;

  g_strEXEFormClassName := strFileValue.Split([';'])[2];
  g_strEXEFormTitleName := strFileValue.Split([';'])[3];

  if @g_OldEXE_CreateProcessW = nil then
    @g_OldEXE_CreateProcessW := HookProcInModule(kernel32, 'CreateProcessW', @_EXE_CreateProcessW);

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

end.
