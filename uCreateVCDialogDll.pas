unit uCreateVCDialogDll;
{
  创建 VC Dialog Dll 窗体
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, uCommon, HookUtils;

{ 创建 VC Dialog Dll 窗体 }
procedure PBoxRun_VC_DLGDll(Page: TPageControl; const TabDllForm: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle);

{ 销毁 VC Dialog Dll 窗体消息 }
procedure FreeVCDialogDllForm;

implementation

var
  g_Page                    : TPageControl;
  g_TabDllForm              : TTabSheet;
  g_UIShowStyle             : TShowStyle;
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
    g_Page.ActivePageIndex     := 2;
    Result                     := g_Old_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    g_intVCDialogDllFormHandle := Result;                                                                                     // 保存下 VC Dll 窗体句柄
    Winapi.Windows.SetParent(Result, g_TabDllForm.Handle);                                                                    // 设置父窗体为 TabSheet
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                               // 删除移动菜单
    SetWindowPos(Result, g_TabDllForm.Handle, 0, 0, g_TabDllForm.Width, g_TabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
    g_OldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                              // 解决 DLL 窗体获取焦点时，主窗体丢失焦点的问题
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                             // 拦截 DLL 窗体消息
    PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                            // 激活主窗体
    UnHook(@g_Old_CreateWindowExW);                                                                                           // UNHOOK
    g_Old_CreateWindowExW := nil;                                                                                             // UNHOOK
  end
  else
  begin
    Result := g_Old_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

{ 创建 VC Dialog Dll 窗体 }
procedure PBoxRun_VC_DLGDll(Page: TPageControl; const TabDllForm: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle);
var
  hDll                             : HMODULE;
  ShowDllForm                      : Tdb_ShowDllForm_Plugins;
  frm                              : TFormClass;
  ft                               : TSPFileType;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  strBakDllFileName                : String;
begin
  g_Page        := Page;
  g_TabDllForm  := TabDllForm;
  g_UIShowStyle := uiShowStyle;

  { 获取参数 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
    g_strVCDialogDllClassName  := string(strClassName);
    g_strVCDialogDllWindowName := string(strWindowName);
    @g_Old_CreateWindowExW     := HookProcInModule(user32, 'CreateWindowExW', @_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { 加载 Dll 窗体 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    if not Assigned(ShowDllForm) then
    begin
      MessageBox(Application.MainForm.Handle, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [g_strCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
      Exit;
    end;

    strBakDllFileName := g_strCreateDllFileName;
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, True);
  finally
    FreeLibrary(hDll);
    g_intVCDialogDllFormHandle := 0;
    g_strVCDialogDllClassName  := '';
    g_strVCDialogDllWindowName := '';

    if g_bExitProgram then
    begin
      Application.MainForm.Close;
    end
    else
    begin
      if CompareText(strBakDllFileName, g_strCreateDllFileName) = 0 then
      begin
        { 如果销毁的 Dll，正是先前备份的 Dll，表示没有 Dll Form 需要创建； }
        g_strCreateDllFileName := '';
        lblInfo.Caption        := '';
        if g_UIShowStyle = ssButton then
          g_Page.ActivePageIndex := 0
        else if g_UIShowStyle = ssList then
          g_Page.ActivePageIndex := 1;
      end
      else
      begin
        { 如果不是先前备份的，说明新的 Dll Form 创建来了 }
        PostMessage(Application.MainForm.Handle, WM_CREATENEWDLLFORM, 0, 0);
      end;
    end;
  end;
end;

{ 销毁 VC Dialog Dll 窗体消息 }
procedure FreeVCDialogDllForm;
begin
  if g_intVCDialogDllFormHandle = 0 then
    Exit;

  SetWindowLong(g_intVCDialogDllFormHandle, GWL_WNDPROC, LongInt(g_OldWndProc));
  PostMessage(g_intVCDialogDllFormHandle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
