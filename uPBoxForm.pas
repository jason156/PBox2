unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IOUtils, System.Types, System.ImageList,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ImgList, Vcl.ToolWin,
  uCommon, uBaseForm, uCreateVCDialogDll;

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
    FlstAllDll    : TStringList;
    FUIShowStyle  : TShowStyle;
    FUIViewStyle  : TViewStyle;
    FDelphiDllForm: TForm;
    procedure ShowPageTabView(const bShow: Boolean = False);
    { 扫描插件目录 }
    procedure ScanPlugins;
    { 创建模块菜单 }
    procedure CreateModuleMenu(const strDllFileName: string);
    { 点击菜单 }
    procedure OnMenuItemClick(Sender: TObject);
    { 创建新的 Dll 窗体 }
    procedure CreateDllForm;
    { 创建 DLL/EXE 窗体 }
    procedure PBoxRun_DelphiDll;
    function PBoxRun_VC_MFCDll: Boolean;
    function PBoxRun_QT_GUIDll: Boolean;
    function PBoxRun_IMAGE_EXE: Boolean;
    procedure OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
  protected
    procedure WMDESTORYPREDLLFORM(var msg: TMessage); message WM_DESTORYPREDLLFORM;
    procedure WMCREATENEWDLLFORM(var msg: TMessage); message WM_CREATENEWDLLFORM;
  end;

var
  frmPBox: TfrmPBox;

implementation

{$R *.dfm}

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

procedure TfrmPBox.PBoxRun_DelphiDll;
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  ft                               : TSPFileType;
begin
  hDll        := LoadLibrary(PChar(g_strCreateDllFileName));
  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
  FDelphiDllForm             := frm.Create(nil);
  FDelphiDllForm.BorderIcons := [biSystemMenu];
  FDelphiDllForm.Position    := poDesigned;
  FDelphiDllForm.Caption     := string(strModuleName);
  FDelphiDllForm.BorderStyle := bsDialog;
  FDelphiDllForm.Color       := clWhite;
  FDelphiDllForm.Anchors     := [akLeft, akTop, akRight, akBottom];
  FDelphiDllForm.Tag         := hDll;
  FDelphiDllForm.OnClose     := OnDelphiDllFormClose;                                                                                            // 将主窗体句柄放在 DllForm 的 tag 中，方便 Dll Form 获取主窗体句柄。注意：Dll Form 使用此句柄，必须等到 Dll Form 的 FormCreate 之后，才能使用此句柄
  SetWindowPos(FDelphiDllForm.Handle, rztbshtDllForm.Handle, 0, 0, rztbshtDllForm.Width, rztbshtDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(FDelphiDllForm.Handle, rztbshtDllForm.Handle);                                                                        // 设置父窗体为 TabSheet <解决 DLL 窗体 TAB 键不能用的问题>
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                                     // 删除移动菜单
  FDelphiDllForm.Show;                                                                                                                           // 显示 Dll 子窗体
  rzpgcntrlAll.ActivePage := rztbshtDllForm;
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
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { 根据 DLL/EXE 文件类型的不同，创建 DLL/EXE 窗体 }
  case ft of
    ftDelphiDll:
      PBoxRun_DelphiDll;
    ftVCDialogDll:
      PBoxRun_VC_DLGDll(Handle, rzpgcntrlAll, rztbshtDllForm, lblInfo);
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

  { 如果已经创建了，就不在重新创建了 }
  if (g_strCreateDllFileName <> '') and (g_strCreateDllFileName = FlstAllDll.Strings[TMenuItem(Sender).Tag]) then
    Exit;

  g_strCreateDllFileName := FlstAllDll.Strings[TMenuItem(Sender).Tag];

  { 销毁上一次创建的 Dll 窗体 }
  PostMessage(Handle, WM_DESTORYPREDLLFORM, 0, 0);
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
    FreeLibrary(hDll);
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
    if Length(arrDllFile) <= 0 then
      Exit;

    for strDllFileName in arrDllFile do
    begin
      { 创建模块菜单 }
      CreateModuleMenu(strDllFileName);
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
  FlstAllDll             := TStringList.Create;
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
