unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IOUtils, System.Types, System.ImageList, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ImgList, Vcl.ToolWin,
  uCommon, uBaseForm, HookUtils, uCreateDelphiDll, uCreateVCDialogDll;

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
    rzpgcntrlAll: TPageControl;
    rztbshtCenter: TTabSheet;
    rztbshtConfig: TTabSheet;
    rztbshtDllForm: TTabSheet;
    pnlIP: TPanel;
    lblIP: TLabel;
    bvlIP: TBevel;
    bvlModule: TBevel;
    pnlDownUp: TPanel;
    lblDownUp: TLabel;
    bvlDownUP: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FlstAllDll    : THashedStringList;
    FUIShowStyle  : TShowStyle;
    FUIViewStyle  : TViewStyle;
    FDelphiDllForm: TForm;
    procedure ShowPageTabView(const bShow: Boolean = False);
    { 扫描 EXE 文件，读取配置文件 }
    procedure ScanPlugins_EXE;
    { 扫描 Dll 文件，仅限于插件目录(plugins) }
    procedure ScanPlugins_Dll;
    { 扫描插件目录 }
    procedure ScanPlugins;
    { 创建模块菜单 }
    procedure CreateModuleMenu;
    { 点击菜单 }
    procedure OnMenuItemClick(Sender: TObject);
    { 创建新的 Dll 窗体 }
    procedure CreateDllForm;

    function PBoxRun_VC_MFCDll: Boolean;
    function PBoxRun_QT_GUIDll: Boolean;
    procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String);
    procedure OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
  protected
    procedure WMDESTORYPREDLLFORM(var msg: TMessage); message WM_DESTORYPREDLLFORM;
    procedure WMCREATENEWDLLFORM(var msg: TMessage); message WM_CREATENEWDLLFORM;
  end;

var
  frmPBox: TfrmPBox;

implementation

{$R *.dfm}

var
  g_strEXEFormClassName  : string  = '';
  g_strEXEFormTitleName  : string  = '';
  g_OldEXEWndProc        : Pointer = nil;
  g_OldEXE_CreateProcessW: function(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
  FhWnd                  : THandle;

function TfrmPBox.PBoxRun_VC_MFCDll: Boolean;
begin
  Result := True;
end;

function TfrmPBox.PBoxRun_QT_GUIDll: Boolean;
begin
  Result := True;
end;

function _EXE_CreateProcessW(lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR; lpProcessAttributes, lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: LPCWSTR; const lpStartupInfo: TStartupInfoW; var lpProcessInformation: TProcessInformation): BOOL; stdcall;
begin
  Result := g_OldEXE_CreateProcessW(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);

  while True do
  begin
    FhWnd := FindWindow(PChar(g_strEXEFormClassName), PChar(g_strEXEFormTitleName));
    if FhWnd <> 0 then
      Break;
  end;

  SetWindowPos(FhWnd, frmPBox.rztbshtDllForm.Handle, 0, 0, frmPBox.rztbshtDllForm.Width, frmPBox.rztbshtDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(FhWnd, frmPBox.rztbshtDllForm.Handle);                                                                                        // 设置父窗体为 TabSheet
  // SetWindowLong(FhWnd, GWL_STYLE, $96000000);
  // SetWindowLong(FhWnd, GWL_EXSTYLE, $00010101);
  SetWindowLong(FhWnd, GWL_STYLE, $96C80000);
  SetWindowLong(FhWnd, GWL_EXSTYLE, $00010000);
  ShowWindow(FhWnd, SW_SHOWNORMAL);
  frmPBox.Height := frmPBox.Height + 1;
  frmPBox.Height := frmPBox.Height - 1;
end;

procedure TfrmPBox.PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String);
begin
  g_strEXEFormClassName := strFileValue.Split([','])[2];
  g_strEXEFormTitleName := strFileValue.Split([','])[3];

  if TOSVersion.Major = 7 then
  begin
    { 如果是 WINDOWS7 系统 }
    if @g_OldEXE_CreateProcessW = nil then
      @g_OldEXE_CreateProcessW := HookProcInModule(kernel32, 'CreateProcessW', @_EXE_CreateProcessW);
  end;

  if TOSVersion.Major = 7 then
  begin
    { 如果是 WINDOWS10 系统 }

  end;

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

procedure TfrmPBox.WMCREATENEWDLLFORM(var msg: TMessage);
var
  hDll                              : HMODULE;
  ShowDllForm                       : TShowDllForm;
  frm                               : TFormClass;
  strParamModuleName, strModuleName : PAnsiChar;
  strFormClassName, strFormTitleName: PAnsiChar;
  strIconFileName                   : PAnsiChar;
  ft                                : TSPFileType;
  strFileValue                      : String;
begin
  { exe 文件 }
  if CompareText(ExtractFileExt(g_strCreateDllFileName), '.exe') = 0 then
  begin
    strFileValue := FlstAllDll.Values[g_strCreateDllFileName];
    PBoxRun_IMAGE_EXE(g_strCreateDllFileName, strFileValue);
    Exit;
  end;

  { Dll 文件 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strFormClassName, strFormTitleName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { 根据 DLL/EXE 文件类型的不同，创建 DLL/EXE 窗体 }
  case ft of
    ftDelphiDll:
      PBoxRun_DelphiDll(FDelphiDllForm, rzpgcntrlAll, rztbshtDllForm, OnDelphiDllFormClose);
    ftVCDialogDll:
      PBoxRun_VC_DLGDll(Handle, rzpgcntrlAll, rztbshtDllForm, lblInfo);
    ftVCMFCDll:
      PBoxRun_VC_MFCDll;
    ftQTDll:
      PBoxRun_QT_GUIDll;
  end;
end;

{ 创建新的 Dll 窗体 }
procedure TfrmPBox.CreateDllForm;
begin
  PostMessage(Handle, WM_CREATENEWDLLFORM, 0, 0);
end;

procedure TfrmPBox.OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FDelphiDllForm <> nil then
  begin
    FDelphiDllForm         := nil;
    g_strCreateDllFileName := '';
    lblInfo.Caption        := '';
  end;
end;

{ 销毁上一次创建的 Dll 窗体 }
procedure TfrmPBox.WMDESTORYPREDLLFORM(var msg: TMessage);
var
  hDll: HMODULE;
begin
  if FDelphiDllForm <> nil then
  begin
    hDll := FDelphiDllForm.Tag;
    FDelphiDllForm.Free;
    FDelphiDllForm := nil;
    FreeLibrary(hDll);
    CreateDllForm;
    Exit;
  end;

  if g_intVCDialogDllFormHandle = 0 then
  begin
    { 创建新的 Dll 窗体 }
    CreateDllForm;
  end
  else
  begin
    FreeVCDialogDllForm;
  end;
end;

{ 点击菜单 }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { 如果已经创建了，就不在重复创建了 }
  if (g_strCreateDllFileName <> '') and (g_strCreateDllFileName = FlstAllDll.Names[TMenuItem(Sender).Tag]) then
    Exit;

  g_strCreateDllFileName := FlstAllDll.Names[TMenuItem(Sender).Tag];

  { 销毁上一次创建的 Dll 窗体 }
  PostMessage(Handle, WM_DESTORYPREDLLFORM, 0, 0);
end;

{ 扫描 EXE 文件，读取配置文件 }
procedure TfrmPBox.ScanPlugins_EXE;
var
  lstEXE     : TStringList;
  I          : Integer;
  strEXEInfo : String;
  strFileName: String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    lstEXE := TStringList.Create;
    try
      ReadSection('EXE', lstEXE);
      for I := 0 to lstEXE.Count - 1 do
      begin
        strFileName := lstEXE.Strings[I];
        strEXEInfo  := ReadString('EXE', strFileName, '');
        FlstAllDll.Add(Format('%s=%s', [strFileName, strEXEInfo]));
      end;
    finally
      lstEXE.Free;
    end;
    Free;
  end;
end;

procedure TfrmPBox.ScanPlugins_Dll;
var
  hDll                          : HMODULE;
  ShowDllForm                   : TShowDllForm;
  frm                           : TFormClass;
  strPModuleName, strSModuleName: PAnsiChar;
  strClassName, strWindowName   : PAnsiChar;
  strIconFileName               : PAnsiChar;
  arrDllFile                    : TStringDynArray;
  ft                            : TSPFileType;
  strDllFileName                : String;
  strInfo                       : string;
begin
  { 扫描 Dll 文件，仅限于插件目录(plugins) }
  arrDllFile := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)) + 'plugins', '*.dll');
  if Length(arrDllFile) <= 0 then
    Exit;

  for strDllFileName in arrDllFile do
  begin
    hDll := LoadLibrary(PChar(strDllFileName));
    if hDll = 0 then
      Continue;

    try
      ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
      if not Assigned(ShowDllForm) then
      begin
        FreeLibrary(hDll);
        Continue;
      end;

      { 获取 Dll 参数 }
      ShowDllForm(frm, ft, strPModuleName, strSModuleName, strClassName, strWindowName, strIconFileName, False);
      strInfo := strDllFileName + '=' + string(strPModuleName) + ',' + string(strSModuleName) + ',' + string(strClassName) + ',' + string(strWindowName) + ',' + string(strIconFileName);
      FlstAllDll.Add(strInfo);
    finally
      FreeLibrary(hDll);
    end;
  end;
end;

{ 创建模块菜单 }
procedure TfrmPBox.CreateModuleMenu;
var
  I             : Integer;
  strInfo       : String;
  strPModuleName: String;
  strSModuleName: String;
  mmPM          : TMenuItem;
  mmSM          : TMenuItem;
begin
  for I := 0 to FlstAllDll.Count - 1 do
  begin
    strInfo        := FlstAllDll.ValueFromIndex[I];
    strPModuleName := strInfo.Split([','])[0];
    strSModuleName := strInfo.Split([','])[1];

    { 如果父菜单不存在，创建父菜单 }
    mmPM := mmMain.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMain);
      mmPM.Caption := string((strPModuleName));
      mmMain.Items.Add(mmPM);
    end;

    { 创建子菜单 }
    mmSM         := TMenuItem.Create(mmPM);
    mmSM.Caption := string((strSModuleName));
    mmSM.Tag     := I;
    mmSM.OnClick := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ 扫描插件目录 }
procedure TfrmPBox.ScanPlugins;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  mmMain.Items.Clear;
  mmMain.AutoMerge := False;
  try
    { 扫描 Dll 文件，添加到列表；当前插件目录 (plugins) }
    ScanPlugins_Dll;

    { 扫描 EXE 文件，添加到列表；读取配置文件 }
    ScanPlugins_EXE;

    { 创建模块菜单 }
    CreateModuleMenu;
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

procedure TfrmPBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  g_bExitProgram := True;
  FreeVCDialogDllForm;
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
  FUIShowStyle           := ssMenu;
  FUIViewStyle           := vsSingle;
  FlstAllDll             := THashedStringList.Create;
  g_strCreateDllFileName := '';
  FDelphiDllForm         := nil;

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

function EnumChildFunc(hDllForm: THandle; hParentHandle: THandle): Boolean; stdcall;
var
  rctClient: TRect;
begin
  { 判断是否是 Dll 的窗体句柄 }
  if GetParent(hDllForm) = 0 then
  begin
    { 更改 Dll 窗体大小 }
    GetWindowRect(hParentHandle, rctClient);
    SetWindowPos(hDllForm, hParentHandle, 0, 0, rctClient.Width, rctClient.Height, SWP_NOZORDER + SWP_NOACTIVATE);
  end;
  Result := True;
end;

procedure TfrmPBox.FormResize(Sender: TObject);
begin
  { 更改 Dll 窗体大小 }
  EnumChildWindows(Handle, @EnumChildFunc, rztbshtDllForm.Handle);
end;

end.
