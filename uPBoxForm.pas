unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.ImageList, System.IOUtils, System.Types, System.Diagnostics,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls, RzTabs,
  uCommon, uBaseForm, HookUtils;

const
  WM_CREATENEWDLLFORM = WM_USER + 1000;

type
  TfrmPBox = class(TUIBaseForm)
    ilMain: TImageList;
    pnlBottom: TPanel;
    mmMain: TMainMenu;
    clbr1: TCoolBar;
    tlbMenu: TToolBar;
    pnlInfo: TPanel;
    lblInfo: TLabel;
    pnlTime: TPanel;
    lblTime: TLabel;
    tmrDateTime: TTimer;
    rzpgcntrlAll: TRzPageControl;
    rztbshtCenter: TRzTabSheet;
    rztbshtConfig: TRzTabSheet;
    pnlIP: TPanel;
    lblIP: TLabel;
    bvlIP: TBevel;
    bvlModule: TBevel;
    pnlDownUp: TPanel;
    lblDownUp: TLabel;
    bvlDownUP: TBevel;
    rztbshtDllForm: TRzTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
  private
    FlstAllDll           : TStringList;
    FUIShowStyle         : TShowStyle;
    FUIViewStyle         : TViewStyle;
    FstrCreateDllFileName: String;
    procedure ShowPageTabView(const bShow: Boolean = False);
    { 扫描插件目录 }
    procedure ScanPlugins;
    { 创建模块菜单 }
    procedure CreateModuleMenu(const strDllFileName: string);
    { 点击菜单 }
    procedure OnMenuItemClick(Sender: TObject);
    { 销毁上一次创建的 Dll 窗体 }
    procedure DestoryPreDllForm;
    procedure FreeDllForm;
    { 创建新的 Dll 窗体 }
    procedure CreateDllForm;
    { 创建 DLL/EXE 窗体 }
    function PBoxRun_DelphiDll: Boolean;
    function PBoxRun_VC_DLGDll: Boolean;
    function PBoxRun_VC_MFCDll: Boolean;
    function PBoxRun_QT_GUIDll: Boolean;
    function PBoxRun_IMAGE_EXE: Boolean;
  protected
    procedure WMCREATENEWDLLFORM(var msg: TMessage); message WM_CREATENEWDLLFORM;
  end;

var
  frmPBox: TfrmPBox;

implementation

{$R *.dfm}

var
  g_StrVCDialogDllClassName : String;
  g_StrVCDialogDllWindowName: String;
  g_hVCDllFormWnd           : THandle;
  g_OldWndProc              : Pointer = nil;
  g_Old_CreateWindowExW     : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;

function TfrmPBox.PBoxRun_VC_MFCDll: Boolean;
begin
  Result := True;
end;

function TfrmPBox.PBoxRun_QT_GUIDll: Boolean;
begin
  Result := True;
end;

function TfrmPBox.PBoxRun_IMAGE_EXE: Boolean;
begin
  Result := True;
end;

function TfrmPBox.PBoxRun_DelphiDll: Boolean;
begin
  Result := True;
end;

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
  if (lpClassName <> nil) and (lpWindowName <> nil) and (CompareText(lpClassName, g_StrVCDialogDllClassName) = 0) and (CompareText(lpWindowName, g_StrVCDialogDllWindowName) = 0) then
  begin
    { 创建 VC Dlll 窗体 }
    frmPBox.rzpgcntrlAll.ActivePageIndex := 2;
    Result                               := g_Old_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    g_hVCDllFormWnd                      := Result;                                                                                                         // 保存下 VC Dll 窗体句柄
    Winapi.Windows.SetParent(Result, frmPBox.rztbshtDllForm.Handle);                                                                                        // 设置父窗体为 TabSheet <解决 DLL 窗体 TAB 键不能用的问题>
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // 删除移动菜单
    SetWindowPos(Result, frmPBox.rztbshtDllForm.Handle, 0, 0, frmPBox.rztbshtDllForm.Width, frmPBox.rztbshtDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
    g_OldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                                                            // 解决 DLL 窗体获取焦点时，主窗体丢失焦点的问题
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                                                           // 拦截 DLL 窗体消息
    PostMessage(frmPBox.Handle, WM_NCACTIVATE, 1, 0);                                                                                                       // 激活主窗体
    UnHook(@g_Old_CreateWindowExW);                                                                                                                         // UNHOOK
    g_Old_CreateWindowExW := nil;                                                                                                                           // UNHOOK
  end
  else
  begin
    Result := g_Old_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

{ 创建 VC Dialog Dll 窗体 }
function TfrmPBox.PBoxRun_VC_DLGDll;
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  ft                               : TSPFileType;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
begin
  Result := True;

  { 获取参数 }
  hDll := LoadLibrary(PChar(FstrCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(Handle, PChar(Format('加载 %s 出错，请检查文件是否完整或者被占用', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  if not Assigned(ShowDllForm) then
  begin
    MessageBox(Handle, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
    g_StrVCDialogDllClassName  := string(strClassName);
    g_StrVCDialogDllWindowName := string(strWindowName);
    @g_Old_CreateWindowExW     := HookProcInModule(user32, 'CreateWindowExW', @_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { 加载 Dll 窗体 }
  hDll := LoadLibrary(PChar(FstrCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(Handle, PChar(Format('加载 %s 出错，请检查文件是否完整或者被占用', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    if not Assigned(ShowDllForm) then
    begin
      MessageBox(Handle, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
      Exit;
    end;

    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, True);
  finally
    FreeLibrary(hDll);
    g_hVCDllFormWnd         := 0;
    frmPBox.lblInfo.Caption := '';
  end;
end;

procedure TfrmPBox.WMCREATENEWDLLFORM(var msg: TMessage);
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  ft                               : TSPFileType;
begin
  hDll := LoadLibrary(PChar(FstrCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(Handle, PChar(Format('加载 %s 出错，请检查文件是否完整或者被占用', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  if not Assigned(ShowDllForm) then
  begin
    MessageBox(Handle, PChar(Format('加载 %s 的导出函数 %s 出错，请检查文件是否存在或者被占用', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { 根据 DLL/EXE 文件类型的不同，创建 DLL/EXE 窗体 }
  case ft of
    ftDelphiDll:
      PBoxRun_DelphiDll;
    ftVCDialogDll:
      PBoxRun_VC_DLGDll;
    ftVCMFCDll:
      PBoxRun_VC_MFCDll;
    ftQTDll:
      PBoxRun_QT_GUIDll;
    ftEXE:
      PBoxRun_IMAGE_EXE;
  end;
end;

{ 创建新的 Dll 窗体 }
procedure TfrmPBox.CreateDllForm;
begin
  PostMessage(Handle, WM_CREATENEWDLLFORM, 0, 0);
end;

procedure TfrmPBox.FreeDllForm;
begin
  { 关闭上一次创建的 Dll 窗体 }
  SetWindowLong(g_hVCDllFormWnd, GWL_WNDPROC, LongInt(g_OldWndProc));
  PostMessage(g_hVCDllFormWnd, WM_SYSCOMMAND, SC_CLOSE, 0);

  while True do
  begin
    Application.ProcessMessages;
    if FindWindow(PChar(g_StrVCDialogDllClassName), PChar(g_StrVCDialogDllWindowName)) = 0 then
    begin
      g_StrVCDialogDllClassName  := '';
      g_StrVCDialogDllWindowName := '';
      g_hVCDllFormWnd            := 0;
      Break;
    end;
  end;
end;

{ 销毁上一次创建的 Dll 窗体 }
procedure TfrmPBox.DestoryPreDllForm;
begin
  FreeDllForm;
end;

{ 点击菜单 }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { 销毁上一次创建的 Dll 窗体 }
  DestoryPreDllForm;

  { 创建新的 Dll 窗体 }
  FstrCreateDllFileName := FlstAllDll.Strings[TMenuItem(Sender).Tag];
  CreateDllForm;
end;

{ 创建模块菜单 }
procedure TfrmPBox.CreateModuleMenu(const strDllFileName: string);
var
  hDll                              : HMODULE;
  ShowDllForm                       : TShowDllForm;
  frm                               : TFormClass;
  strParentModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName       : PAnsiChar;
  strIconFileName                   : PAnsiChar;
  mmPM                              : TMenuItem;
  mmSM                              : TMenuItem;
  intIndex                          : Integer;
  ft                                : TSPFileType;
begin
  hDll := LoadLibrary(PChar(strDllFileName));
  if hDll = 0 then
    Exit;

  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    if not Assigned(ShowDllForm) then
      Exit;

    { 获取 Dll 参数 }
    ShowDllForm(frm, ft, strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
    intIndex := FlstAllDll.Add(strDllFileName);

    { 如果父菜单不存在，创建父菜单 }
    mmPM := mmMain.Items.Find(string(strParentModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMain);
      mmPM.Caption := string((strParentModuleName));
      mmMain.Items.Add(mmPM);
    end;

    { 创建子菜单 }
    mmSM         := TMenuItem.Create(mmPM);
    mmSM.Caption := string((strModuleName));
    mmSM.Tag     := intIndex;
    mmSM.OnClick := OnMenuItemClick;
    mmPM.Add(mmSM);

  finally
    FreeLibrary(hDll)
  end;
end;

{ 扫描插件目录 }
procedure TfrmPBox.ScanPlugins;
var
  arrDllFile    : TStringDynArray;
  strDllFileName: String;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  mmMain.Items.Clear;
  mmMain.AutoMerge := False;
  try
    { 扫描 Dll 文件，仅限于插件目录(plugins) }
    arrDllFile := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)) + 'plugins', '*.dll');
    if Length(arrDllFile) > 0 then
    begin
      for strDllFileName in arrDllFile do
      begin
        { 创建模块菜单 }
        CreateModuleMenu(strDllFileName);
      end;
    end;

    { 扫描 EXE 文件，读取配置文件 }

  finally
    if FUIShowStyle = ssMenu then
    begin
      tlbMenu.Menu     := mmMain;
      mmMain.AutoMerge := True;
    end;
  end;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日');
begin
  lblTime.Caption := FormatDateTime('YYYY-MM-DD hh:mm:ss', Now) + ' ' + WeekDay[DayOfWeek(Now) - 1];
end;

procedure TfrmPBox.ShowPageTabView(const bShow: Boolean);
var
  I: Integer;
begin
  for I := 0 to rzpgcntrlAll.PageCount - 1 do
  begin
    rzpgcntrlAll.Pages[I].TabVisible := bShow;
  end;
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
var
  strDllModulePath: string;
begin
  { 初始化界面 }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := rztbshtCenter;

  { 显示 时间 }
  tmrDateTime.OnTimer(nil);

  { 显示 IP }
  lblIP.Caption := GetNativeIP;
  lblIP.Left    := (lblIP.Parent.Width - lblIP.Width) div 2;

  { 初始化参数 }
  FUIShowStyle := ssMenu;
  FUIViewStyle := vsSingle;
  FlstAllDll   := TStringList.Create;

  { 扫描插件目录 }
  strDllModulePath := ExtractFilePath(ParamStr(0)) + 'plugins';
  SetDllDirectory(PChar(strDllModulePath));
  ScanPlugins;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { 最大化窗体 }
  pnlDBLClick(nil);
end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FlstAllDll.Free;
end;

end.
