unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.ImageList, System.IOUtils, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls, uCommon, uBaseForm,
  RzTabs;

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
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
  private
    FlstAllDll  : TStringList;
    FUIShowStyle: TShowStyle;
    FUIViewStyle: TViewStyle;
    procedure ShowPageTabView(const bShow: Boolean = False);
    { 扫描插件目录 }
    procedure ScanPlugins;
    { 创建模块菜单 }
    procedure CreateModuleMenu(const strDllFileName: string);
    { 点击菜单 }
    procedure OnMenuItemClick(Sender: TObject);
    { 销毁上一次创建的 Dll 窗体 }
    procedure DestoryPreDllForm;
    { 创建新的 Dll 窗体 }
    procedure CreateDllForm(const strFileName: string);
    { 销毁 Dll 窗体 }
    procedure FreeDllForm;
    { 创建 DLL/EXE 窗体 }
    function PBoxRun_DelphiDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_VC_DLGDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_VC_MFCDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_QT_GUIDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_IMAGE_EXE(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
  end;

var
  frmPBox: TfrmPBox;

implementation

{$R *.dfm}

function TfrmPBox.PBoxRun_DelphiDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_VC_DLGDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_VC_MFCDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_QT_GUIDll(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_IMAGE_EXE(const strFileName: String; const frm: TFormClass; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FlstAllDll.Free;
end;

{ 销毁 Dll 窗体 }
procedure TfrmPBox.FreeDllForm;
begin

end;

{ 销毁上一次创建的 Dll 窗体 }
procedure TfrmPBox.DestoryPreDllForm;
begin
  FreeDllForm;
end;

{ 创建新的 Dll 窗体 }
procedure TfrmPBox.CreateDllForm(const strFileName: string);
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  ft                               : TSPFileType;
begin
  hDll := LoadLibrary(PChar(strFileName));
  if hDll = 0 then
    Exit;

  ShowDllForm := GetProcAddress(hDll, c_srDllExportName);
  if not Assigned(ShowDllForm) then
    Exit;

  { 获取参数 }
  ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);

  { 根据 DLL/EXE 文件类型的不同，创建 DLL/EXE 窗体 }
  case ft of
    ftDelphiDll:
      PBoxRun_DelphiDll(strFileName, frm, string(PChar(strParamModuleName)), string(PChar(strModuleName)), string(PChar(strClassName)), string(PChar(strWindowName)), string(PChar(strIconFileName)), True);
    ftVCDialogDll:
      PBoxRun_VC_DLGDll(strFileName, nil, string(PChar(strParamModuleName)), string(PChar(strModuleName)), string(PChar(strClassName)), string(PChar(strWindowName)), string(PChar(strIconFileName)), True);
    ftVCMFCDll:
      PBoxRun_VC_MFCDll(strFileName, nil, string(PChar(strParamModuleName)), string(PChar(strModuleName)), string(PChar(strClassName)), string(PChar(strWindowName)), string(PChar(strIconFileName)), True);
    ftQTDll:
      PBoxRun_QT_GUIDll(strFileName, nil, string(PChar(strParamModuleName)), string(PChar(strModuleName)), string(PChar(strClassName)), string(PChar(strWindowName)), string(PChar(strIconFileName)), True);
    ftEXE:
      PBoxRun_IMAGE_EXE(strFileName, nil, string(PChar(strParamModuleName)), string(PChar(strModuleName)), string(PChar(strClassName)), string(PChar(strWindowName)), string(PChar(strIconFileName)), True);
  end;
end;

{ 点击菜单 }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { 销毁上一次创建的 Dll 窗体 }
  DestoryPreDllForm;

  { 创建新的 Dll 窗体 }
  CreateDllForm((FlstAllDll.Strings[TMenuItem(Sender).Tag]));
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
    ShowDllForm := GetProcAddress(hDll, c_srDllExportName);
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

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { 最大化窗体 }
  pnlDBLClick(nil);
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
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
  ScanPlugins;
end;

end.
