unit uCreateVCDialogDll;
{
  创建 VC Dialog Dll 窗体
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, uCommon, HookUtils;

{ 创建 VC Dialog Dll 窗体 }
procedure PBoxRun_VC_DLGDll(const hMainForm: THandle; Page: TPageControl; const TabDllForm: TTabSheet; lblInfo: TLabel);

{ 销毁 VC Dialog Dll 窗体消息 }
procedure FreeVCDialogDllForm;

implementation

var
  g_hMainForm               : THandle = 0;
  g_rzPage                  : TPageControl;
  g_rzTabDllForm            : TTabSheet;
  g_strVCDialogDllClassName : String  = '';
  g_strVCDialogDllWindowName: String  = '';
  g_OldWndProc              : Pointer = nil;
  g_Old_CreateWindowExW     : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;

  { 解决 dll 中，当 Dll 窗体获取焦点，主窗体变成非激活状态 }
function NewDllFormProc(hWnd: THandle; msg: UINT; wParam: Cardinal; lParam: Cardinal): Integer; stdcall;
begin
  { 如果子窗体获取焦点时，激活主窗体 }
  if msg = WM_ACTIVATE then
  begin
    if Application.MainForm <> nil then
    begin
      SendMessage(Application.MainForm.Handle, WM_NCACTIVATE, Integer(True), 0);
    end;
  end;

  { 禁止窗体移动 }
  if msg = WM_SYSCOMMAND then
  begin
    if wParam = SC_MOVE + 2 then
    begin
      wParam := 0;
    end;
  end;

  { 调用原来的回调过程 }
  Result := CallWindowProc(g_OldWndProc, hWnd, msg, wParam, lParam);
end;

function _CreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { 是指定的 VC 窗体 }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (CompareText(lpClassName, g_strVCDialogDllClassName) = 0) and (CompareText(lpWindowName, g_strVCDialogDllWindowName) = 0) then
  begin
    { 创建 VC Dlll 窗体 }
    g_rzPage.ActivePageIndex   := 2;
    Result                     := g_Old_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    g_intVCDialogDllFormHandle := Result;                                                                                           // 保存下 VC Dll 窗体句柄
    Winapi.Windows.SetParent(Result, g_rzTabDllForm.Handle);                                                                        // 设置父窗体为 TabSheet <解决 DLL 窗体 TAB 键不能用的问题>
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
    SetWindowPos(Result, g_rzTabDllForm.Handle, 0, 0, g_rzTabDllForm.Width, g_rzTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
    g_OldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                                    // 解决 DLL 窗体获取焦点时，主窗体丢失焦点的问题
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                                   // 拦截 DLL 窗体消息
    PostMessage(g_hMainForm, WM_NCACTIVATE, 1, 0);                                                                                  // 激活主窗体
    UnHook(@g_Old_CreateWindowExW);                                                                                                 // UNHOOK
    g_Old_CreateWindowExW := nil;                                                                                                   // UNHOOK
  end
  else
  begin
    Result := g_Old_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

{ 创建 VC Dialog Dll 窗体 }
procedure PBoxRun_VC_DLGDll(const hMainForm: THandle; Page: TPageControl; const TabDllForm: TTabSheet; lblInfo: TLabel);
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  ft                               : TSPFileType;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  strBakDllFileName                : String;
begin
  g_hMainForm    := hMainForm;
  g_rzPage       := Page;
  g_rzTabDllForm := TabDllForm;

  { 获取参数 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(hMainForm, PChar(Format('加载 %s 出错，请检查文件是否完整或者被占用', [g_strCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  if not Assigned(ShowDllForm) then
  begin
    MessageBox(hMainForm, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [g_strCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
    g_strVCDialogDllClassName  := string(strClassName);
    g_strVCDialogDllWindowName := string(strWindowName);
    @g_Old_CreateWindowExW     := HookProcInModule(user32, 'CreateWindowExW', @_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { 加载 Dll 窗体 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(hMainForm, PChar(Format('加载 %s 出错，请检查文件是否完整或者被占用', [g_strCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    if not Assigned(ShowDllForm) then
    begin
      MessageBox(hMainForm, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [g_strCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
      Exit;
    end;

    strBakDllFileName := g_strCreateDllFileName;
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, True);
  finally
    FreeLibrary(hDll);
    g_intVCDialogDllFormHandle := 0;
    g_strVCDialogDllClassName  := '';
    g_strVCDialogDllWindowName := '';

    if CompareText(strBakDllFileName, g_strCreateDllFileName) = 0 then
    begin
      { 如果销毁的 Dll，正是先前备份的 Dll，表示没有 Dll Form 需要创建； }
      g_strCreateDllFileName := '';
      lblInfo.Caption        := '';
    end
    else
    begin
      { 如果不是先前备份的，说明新的 Dll Form 创建来了 }
      PostMessage(hMainForm, WM_CREATENEWDLLFORM, 0, 0);
    end;
  end;
end;

{ 销毁 VC Dialog Dll 窗体消息 }
procedure FreeVCDialogDllForm;
begin
  SetWindowLong(g_intVCDialogDllFormHandle, GWL_WNDPROC, LongInt(g_OldWndProc));
  PostMessage(g_intVCDialogDllFormHandle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
