unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IOUtils, System.Types, System.ImageList, System.IniFiles, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ImgList, Vcl.ToolWin, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  uCommon, uBaseForm, HookUtils, uCreateDelphiDll, uCreateVCDialogDll, uCreateEXE;

type
  TfrmPBox = class(TUIBaseForm)
    ilMainMenu: TImageList;
    pnlBottom: TPanel;
    mmMainMenu: TMainMenu;
    clbrPModule: TCoolBar;
    tlbPModule: TToolBar;
    pnlInfo: TPanel;
    lblInfo: TLabel;
    pnlTime: TPanel;
    lblTime: TLabel;
    tmrDateTime: TTimer;
    rzpgcntrlAll: TPageControl;
    tsButton: TTabSheet;
    tsList: TTabSheet;
    tsDll: TTabSheet;
    pnlIP: TPanel;
    lblIP: TLabel;
    bvlIP: TBevel;
    bvlModule: TBevel;
    pnlDownUp: TPanel;
    lblDownUp: TLabel;
    bvlDownUP: TBevel;
    pmTray: TPopupMenu;
    mniTrayShowForm: TMenuItem;
    N2: TMenuItem;
    mniTrayExit: TMenuItem;
    imgDllFormBack: TImage;
    imgButtonBack: TImage;
    imgListBack: TImage;
    ilPModule: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniTrayExitClick(Sender: TObject);
    procedure mniTrayShowFormClick(Sender: TObject);
  private
    FlstAllDll    : THashedStringList;
    FUIShowStyle  : TShowStyle;
    FUIViewStyle  : TViewStyle;
    FbMaxForm     : Boolean;
    FDelphiDllForm: TForm;
    procedure ShowPageTabView(const bShow: Boolean = False);
    procedure ReadConfigUI;
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
    { 待实现 }
    function PBoxRun_VC_MFCDll: Boolean;
    function PBoxRun_QT_GUIDll: Boolean;
    { 系统配置 }
    procedure OnSysConfig(Sender: TObject);
    { Delphi Dll Form 窗体关闭事件 }
    procedure OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
    { 获取 EXE 文件的图标 }
    function GetExeFileIcon(const strFileName: String): Integer; overload;
    function GetExeFileIcon(const strEXEInfo, strFileName: string): Integer; overload;
    { 获取 Dll 文件的图标 }
    function GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
    function ReadDllIconFromConfig(const strPModule, strSModule: string): Integer;
    procedure ReCreate;
    { 界面显示风格 }
    procedure ChangeUI;
    { 菜单式 }
    procedure ChangeUI_Menu;
    { 按钮式 }
    procedure ChangeUI_Button;
    { 列表式 }
    procedure ChangeUI_List;
    { 父模块排序 }
    procedure SortPModuleList(var lstPModuleList: TStringList);
    { 参数置空，恢复默认值 }
    procedure FillParamBlank;
  protected
    procedure WMDESTORYPREDLLFORM(var msg: TMessage); message WM_DESTORYPREDLLFORM;
    procedure WMCREATENEWDLLFORM(var msg: TMessage); message WM_CREATENEWDLLFORM;
  end;

var
  frmPBox: TfrmPBox;

implementation

uses uConfigForm;

{$R *.dfm}

{ 待实现 }
function TfrmPBox.PBoxRun_VC_MFCDll: Boolean;
begin
  Result := True;
end;

{ 待实现 }
function TfrmPBox.PBoxRun_QT_GUIDll: Boolean;
begin
  Result := True;
end;

{ 系统配置 }
procedure TfrmPBox.OnSysConfig(Sender: TObject);
begin
  if ShowConfigForm(FlstAllDll) then
  begin
    Hide;
    SendMessage(Handle, WM_DESTORYPREDLLFORM, 0, 0);
    ReCreate;
    Show;
  end;
end;

{ Delphi Dll Form 窗体关闭事件 }
procedure TfrmPBox.OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FDelphiDllForm <> nil then
  begin
    FDelphiDllForm         := nil;
    g_strCreateDllFileName := '';
    lblInfo.Caption        := '';
  end;
end;

procedure TfrmPBox.WMCREATENEWDLLFORM(var msg: TMessage);
var
  hDll                              : HMODULE;
  ShowDllForm                       : Tdb_ShowDllForm_Plugins;
  frm                               : TFormClass;
  strParamModuleName, strModuleName : PAnsiChar;
  strFormClassName, strFormTitleName: PAnsiChar;
  strIconFileName                   : PAnsiChar;
  ft                                : TSPFileType;
  strFileValue                      : String;
begin
  if g_strCreateDllFileName = '' then
    Exit;

  { exe 文件 }
  if CompareText(ExtractFileExt(g_strCreateDllFileName), '.exe') = 0 then
  begin
    strFileValue := FlstAllDll.Values[g_strCreateDllFileName];
    PBoxRun_IMAGE_EXE(g_strCreateDllFileName, strFileValue, rzpgcntrlAll, tsDll, lblInfo);
    Exit;
  end;

  { Dll 文件，获取文件类型 }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strFormClassName, strFormTitleName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { 根据 DLL 文件类型的不同，创建 DLL 窗体 }
  case ft of
    ftDelphiDll:
      PBoxRun_DelphiDll(FDelphiDllForm, rzpgcntrlAll, tsDll, OnDelphiDllFormClose);
    ftVCDialogDll:
      PBoxRun_VC_DLGDll(rzpgcntrlAll, tsDll, lblInfo);
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

{ 销毁上一次创建的 Dll 窗体 }
procedure TfrmPBox.WMDESTORYPREDLLFORM(var msg: TMessage);
var
  hDll    : HMODULE;
  hProcess: Cardinal;
begin
  if g_hEXEProcessID <> 0 then
  begin
    hProcess := OpenProcess(PROCESS_TERMINATE, False, g_hEXEProcessID);
    TerminateProcess(hProcess, 0);
    g_hEXEProcessID := 0;
    if Visible then
      CreateDllForm;
    Exit;
  end;

  if FDelphiDllForm <> nil then
  begin
    hDll := FDelphiDllForm.Tag;
    FDelphiDllForm.Free;
    FDelphiDllForm := nil;
    FreeLibrary(hDll);
    if Visible then
      CreateDllForm;
    Exit;
  end;

  if g_intVCDialogDllFormHandle = 0 then
  begin
    { 创建新的 Dll 窗体 }
    if Visible then
      CreateDllForm;
  end
  else
  begin
    { 销毁 VC Dialog Dll 窗体消息 }
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

function TfrmPBox.GetExeFileIcon(const strFileName: String): Integer;
var
  IcoExe: TIcon;
begin
  Result := -1;
  if ExtractIcon(HInstance, PChar(strFileName), $FFFFFFFF) > 0 then
  begin
    IcoExe := TIcon.Create;
    try
      IcoExe.Handle := ExtractIcon(HInstance, PChar(strFileName), 0);
      Result        := ilMainMenu.AddIcon(IcoExe);
    finally
      IcoExe.Free;
    end;
  end;
end;

{ 获取 EXE 文件的图标 }
function TfrmPBox.GetExeFileIcon(const strEXEInfo, strFileName: string): Integer;
var
  strIconFileName    : String;
  IcoExe             : TIcon;
  strCurrIconFileName: String;
begin
  strIconFileName := strEXEInfo.Split([';'])[4];
  if Trim(strIconFileName) = '' then
  begin
    Result := GetExeFileIcon(strFileName);
  end
  else
  begin
    if FileExists(strIconFileName) then
    begin
      strCurrIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + ExtractFileName(strIconFileName);

      if not DirectoryExists(ExtractFilePath(strCurrIconFileName)) then
        ForceDirectories(ExtractFilePath(strCurrIconFileName));

      if not FileExists(strCurrIconFileName) then
        CopyFile(PChar(strIconFileName), PChar(strCurrIconFileName), False);

      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strCurrIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end
    else
    begin
      Result := GetExeFileIcon(strFileName);
    end;
  end;
end;

{ 扫描 EXE 文件，读取配置文件 }
procedure TfrmPBox.ScanPlugins_EXE;
var
  lstEXE      : TStringList;
  I           : Integer;
  strEXEInfo  : String;
  strFileName : String;
  intIconIndex: Integer;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    lstEXE := TStringList.Create;
    try
      ReadSection('EXE', lstEXE);
      for I := 0 to lstEXE.Count - 1 do
      begin
        strFileName  := lstEXE.Strings[I];
        strEXEInfo   := ReadString('EXE', strFileName, '');
        intIconIndex := GetExeFileIcon(strEXEInfo, strFileName);
        if strEXEInfo.CountChar(';') = 4 then
          strEXEInfo := strEXEInfo + ';' + IntToStr(intIconIndex)
        else
          strEXEInfo := strEXEInfo + ';;' + IntToStr(intIconIndex);
        FlstAllDll.Add(Format('%s=%s', [strFileName, strEXEInfo]));
      end;
    finally
      lstEXE.Free;
    end;
    Free;
  end;
end;

function TfrmPBox.ReadDllIconFromConfig(const strPModule, strSModule: string): Integer;
var
  strIconFilePath: String;
  strIconFileName: String;
  IcoExe         : TIcon;
begin
  Result := -1;
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strIconFilePath := ReadString(c_strIniModuleSection, Format('%s_%s_ICON', [strPModule, strSModule]), '');
    strIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + strIconFilePath;
    if FileExists(strIconFileName) then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
    Free;
  end;
end;

{ 获取 Dll 文件的图标 }
function TfrmPBox.GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
var
  strCurrIconFileName: String;
  IcoExe             : TIcon;
begin
  if Trim(strIconFileName) = '' then
  begin
    { 从配置文件中读取图标信息 }
    Result := ReadDllIconFromConfig(strPModuleName, strSModuleName);
  end
  else
  begin
    if FileExists(strIconFileName) then
    begin
      strCurrIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + ExtractFileName(strIconFileName);
      if not DirectoryExists(ExtractFilePath(strCurrIconFileName)) then
        ForceDirectories(ExtractFilePath(strCurrIconFileName));
      if not FileExists(strCurrIconFileName) then
        CopyFile(PChar(strIconFileName), PChar(strCurrIconFileName), False);

      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strCurrIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end
    else
    begin
      { 从配置文件中读取图标信息 }
      Result := ReadDllIconFromConfig(strPModuleName, strSModuleName);
    end;
  end;
end;

procedure TfrmPBox.ScanPlugins_Dll;
var
  hDll                          : HMODULE;
  ShowDllForm                   : Tdb_ShowDllForm_Plugins;
  frm                           : TFormClass;
  strPModuleName, strSModuleName: PAnsiChar;
  strClassName, strWindowName   : PAnsiChar;
  strIconFileName               : PAnsiChar;
  ft                            : TSPFileType;
  strDllFileName                : String;
  strInfo                       : string;
  I, Count                      : Integer;
  lstTemp                       : TStringList;
  intIconIndex                  : Integer;
begin
  lstTemp := TStringList.Create;
  try
    { 扫描 Dll 文件，仅限于插件目录(plugins) }
    SearchPlugInsDllFile(lstTemp);
    Count := lstTemp.Count;
    if Count <= 0 then
      Exit;

    for I := 0 to Count - 1 do
    begin
      strDllFileName := lstTemp.Strings[I];
      hDll           := LoadLibrary(PChar(strDllFileName));
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
        intIconIndex := GetDllFileIcon(string(strPModuleName), string(strSModuleName), string(strIconFileName));
        strInfo      := strDllFileName + '=' + string(strPModuleName) + ';' + string(strSModuleName) + ';' + string(strClassName) + ';' + string(strWindowName) + ';' + string(strIconFileName) + ';' + IntToStr(intIconIndex);
        FlstAllDll.Add(strInfo);
      finally
        FreeLibrary(hDll);
      end;
    end;
  finally
    lstTemp.Free;
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
  intIconIndex  : Integer;
begin
  for I := 0 to FlstAllDll.Count - 1 do
  begin
    strInfo        := FlstAllDll.ValueFromIndex[I];
    strPModuleName := strInfo.Split([';'])[0];
    strSModuleName := strInfo.Split([';'])[1];
    intIconIndex   := StrToInt(strInfo.Split([';'])[5]);

    { 如果父菜单不存在，创建父菜单 }
    mmPM := mmMainMenu.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMainMenu);
      mmPM.Caption := string((strPModuleName));
      mmMainMenu.Items.Add(mmPM);
    end;

    { 创建子菜单 }
    mmSM            := TMenuItem.Create(mmPM);
    mmSM.Caption    := string((strSModuleName));
    mmSM.Tag        := I;
    mmSM.ImageIndex := intIconIndex;
    mmSM.OnClick    := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ 扫描插件目录 }
procedure TfrmPBox.ScanPlugins;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  try
    { 扫描 Dll 文件，添加到列表；当前插件目录 (plugins) }
    ScanPlugins_Dll;

    { 扫描 EXE 文件，添加到列表；读取配置文件 }
    ScanPlugins_EXE;

    { 排序模块 }
    SortModuleList(FlstAllDll);

    { 创建模块菜单 }
    CreateModuleMenu;
  finally
    if FUIShowStyle = ssMenu then
    begin
    end;
  end;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六');
begin
  lblTime.Caption := FormatDateTime('YYYY-MM-DD hh:mm:ss', Now) + ' ' + WeekDay[DayOfWeek(Now)];
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

procedure TfrmPBox.ReadConfigUI;
var
  bShowImage  : Boolean;
  strImageBack: String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Caption      := ReadString(c_strIniUISection, 'Title', c_strTitle);
    MulScreenPos := ReadBool(c_strIniUISection, 'MulScreen', False);
    FbMaxForm    := ReadBool(c_strIniUISection, 'MAXSIZE', False);
    FormStyle    := TFormStyle(Integer(ReadBool(c_strIniUISection, 'OnTop', False)) * 3);
    CloseToTray  := ReadBool(c_strIniUISection, 'CloseMini', False);
    bShowImage   := ReadBool(c_strIniUISection, 'showbackimage', False);
    strImageBack := ReadString(c_strIniUISection, 'filebackimage', '');
    if (bShowImage) and (Trim(strImageBack) <> '') and (FileExists(strImageBack)) then
    begin
      imgDllFormBack.Picture.LoadFromFile(strImageBack);
      imgButtonBack.Picture.LoadFromFile(strImageBack);
      imgListBack.Picture.LoadFromFile(strImageBack);
    end
    else
    begin
      imgDllFormBack.Picture.Assign(nil);
      imgButtonBack.Picture.Assign(nil);
      imgListBack.Picture.Assign(nil);
    end;
    Free;
  end;
end;

{ 参数置空，恢复默认值 }
procedure TfrmPBox.FillParamBlank;
var
  I, J: Integer;
begin
  g_intVCDialogDllFormHandle := 0;
  g_strCreateDllFileName     := '';
  g_bExitProgram             := False;
  g_hEXEProcessID            := 0;
  FUIShowStyle               := GetShowStyle;
  FUIViewStyle               := vsSingle;
  FDelphiDllForm             := nil;
  OnConfig                   := OnSysConfig;
  TrayIconPMenu              := pmTray;
  clbrPModule.Visible        := False;
  ilMainMenu.Clear;
  ilPModule.Clear;

  tlbPModule.Images := nil;
  tlbPModule.Height := 30;
  tlbPModule.Menu   := nil;

  for I := tlbPModule.ButtonCount - 1 downto 0 do
  begin
    tlbPModule.Buttons[I].Free;
  end;

  mmMainMenu.AutoMerge := False;
  for I                := mmMainMenu.Items.Count - 1 downto 0 do
  begin
    for J := mmMainMenu.Items.Items[I].Count - 1 downto 0 do
    begin
      mmMainMenu.Items.Items[I].Items[J].Free;
    end;
    mmMainMenu.Items.Items[I].Free;
  end;
  mmMainMenu.Items.Clear;

  if FlstAllDll = nil then
    FlstAllDll := THashedStringList.Create
  else
    FlstAllDll.Clear;
end;

procedure TfrmPBox.ReCreate;
var
  strDllModulePath: string;
begin
  { 初始化参数 }
  FillParamBlank;

  { 初始化界面 }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := tsDll;
  ReadConfigUI;

  { 显示 时间 }
  tmrDateTime.OnTimer(nil);

  { 显示 IP }
  lblIP.Caption := GetNativeIP;
  lblIP.Left    := (lblIP.Parent.Width - lblIP.Width) div 2;

  { 扫描插件目录 }
  strDllModulePath := ExtractFilePath(ParamStr(0)) + 'plugins';
  SetDllDirectory(PChar(strDllModulePath));
  ScanPlugins;

  { 界面显示风格 }
  ChangeUI;
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
begin
  ReCreate;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { 最大化窗体 }
  if FbMaxForm then
    pnlDBLClick(nil);
end;

procedure TfrmPBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  g_bExitProgram := True;
  FreeVCDialogDllForm;
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
  EnumChildWindows(Handle, @EnumChildFunc, tsDll.Handle);
end;

procedure TfrmPBox.mniTrayShowFormClick(Sender: TObject);
begin
  MainTrayIcon.OnDblClick(nil);
end;

procedure TfrmPBox.mniTrayExitClick(Sender: TObject);
begin
  CloseToTray := False;
  Close;
end;

{ 界面显示风格 }
procedure TfrmPBox.ChangeUI;
begin
  case FUIShowStyle of
    ssMenu:
      ChangeUI_Menu;   // 菜单式
    ssButton:          //
      ChangeUI_Button; // 按钮式
    ssList:            //
      ChangeUI_List;   // 列表式
  end;
end;

{ 菜单式 }
procedure TfrmPBox.ChangeUI_Menu;
begin
  tlbPModule.Menu      := mmMainMenu;
  mmMainMenu.AutoMerge := True;
  clbrPModule.Visible  := True;
end;

{ 父模块排序 }
procedure TfrmPBox.SortPModuleList(var lstPModuleList: TStringList);
var
  strPModuleOrder: String;
  strArrOrder    : TArray<String>;
  I, intIndex    : Integer;
  strTemp        : String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strPModuleOrder := ReadString(c_strIniModuleSection, 'Order', '');
    if Trim(strPModuleOrder) <> '' then
    begin
      strArrOrder := strPModuleOrder.Split([';']);
      for I       := 0 to Length(strArrOrder) - 1 do
      begin
        if CompareText(lstPModuleList.Strings[I], strArrOrder[I]) <> 0 then
        begin
          intIndex                         := lstPModuleList.IndexOf(strArrOrder[I]);
          strTemp                          := lstPModuleList.Strings[intIndex];
          lstPModuleList.Strings[intIndex] := strArrOrder[I];
          lstPModuleList.Strings[I]        := strTemp;
        end;
      end;
    end;
    Free;
  end;
end;

{ 按钮式 }
procedure TfrmPBox.ChangeUI_Button;
var
  tmpTB          : TToolButton;
  I              : Integer;
  lstPModuleList : TStringList;
  strIconFilePath: String;
  strIconFileName: String;
  icoPModule     : TIcon;
begin
  tlbPModule.Images := ilPModule;
  tlbPModule.Height := 58;

  lstPModuleList := TStringList.Create;
  try
    for I := 0 to FlstAllDll.Count - 1 do
    begin
      if lstPModuleList.IndexOf(FlstAllDll.ValueFromIndex[I].Split([';'])[0]) = -1 then
      begin
        lstPModuleList.Add(FlstAllDll.ValueFromIndex[I].Split([';'])[0]);

        with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
        begin
          strIconFilePath := FlstAllDll.ValueFromIndex[I].Split([';'])[0] + '_ICON';
          strIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + ReadString(c_strIniModuleSection, strIconFilePath, '');
          Free;
        end;

        if FileExists(strIconFileName) then
        begin
          icoPModule := TIcon.Create;
          try
            icoPModule.LoadFromFile(strIconFileName);
            ilPModule.AddIcon(icoPModule);
          finally
            icoPModule.Free;
          end;
        end;
      end;
    end;

    if lstPModuleList.Count <= 0 then
      Exit;

    SortPModuleList(lstPModuleList);
    for I := lstPModuleList.Count - 1 downto 0 do
    begin
      tmpTB            := TToolButton.Create(tlbPModule);
      tmpTB.Parent     := tlbPModule;
      tmpTB.Caption    := lstPModuleList.Strings[I];
      tmpTB.ImageIndex := I;
      // tmpTB.OnClick    := OnParentModuleButtonClick;
    end;
    clbrPModule.Visible := True;
  finally
    lstPModuleList.Free;
  end;
end;

{ 列表式 }
procedure TfrmPBox.ChangeUI_List;
begin

end;

end.
