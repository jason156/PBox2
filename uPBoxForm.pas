unit uPBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.ImageList, System.IOUtils, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls, uCommon, uBaseForm,
  RzTabs;

type
  TFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

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
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
  private
    FlstAllDll           : TStringList;
    FstrActiveDllFileName: String;
    FUIShowStyle         : TUIStyle;
    FUIViewStyle         : Integer;
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
    procedure FreeDllForm(const strDllFileName: string);
  public
    {
      strFileName      : 文件名
      ft               : 文件类型
      strPModuleName   : 父模块名称
      strSModuleName   : 子模块名称
      strFormClassName : 窗体类名
      strFormTitleName : 窗体标题名
      strIconFileName  : 图标
      bShowForm        : 是否显示窗体
    }
    function PBoxRun_DelphiDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_VC_DLGDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_VC_MFCDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_QT_GUIDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_IMAGE_EXE(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
    function PBoxRun_CommonRun(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
  end;

var
  frmPBox: TfrmPBox;

implementation

{$R *.dfm}
{$I PBoxRun.inc}

function TfrmPBox.PBoxRun_DelphiDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_IMAGE_EXE(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_QT_GUIDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_VC_DLGDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

function TfrmPBox.PBoxRun_VC_MFCDll(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean): Boolean;
begin
  Result := True;

end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FlstAllDll.Free;
end;

function TfrmPBox.PBoxRun_CommonRun(const strFileName: String; const ft: TFileType; const strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName: String; const bShowForm: Boolean = True): Boolean;
begin
  Result := True;
  case ft of
    ftDelphiDll:
      Result := PBoxRun_DelphiDll(strFileName, ft, strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName, bShowForm);
    ftVCDialogDll:
      Result := PBoxRun_VC_DLGDll(strFileName, ft, strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName, bShowForm);
    ftVCMFCDll:
      Result := PBoxRun_VC_MFCDll(strFileName, ft, strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName, bShowForm);
    ftQTDll:
      Result := PBoxRun_QT_GUIDll(strFileName, ft, strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName, bShowForm);
    ftEXE:
      Result := PBoxRun_IMAGE_EXE(strFileName, ft, strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strIconFileName, bShowForm);
  end;
end;

{ 销毁 Dll 窗体 }
procedure TfrmPBox.FreeDllForm(const strDllFileName: string);
begin

end;

{ 销毁上一次创建的 Dll 窗体 }
procedure TfrmPBox.DestoryPreDllForm;
begin
  if FstrActiveDllFileName = '' then
    Exit;

  { 销毁 Dll 窗体 }
  FreeDllForm(FstrActiveDllFileName);
end;

{ 创建新的 Dll 窗体 }
procedure TfrmPBox.CreateDllForm(const strFileName: string);
begin
  FstrActiveDllFileName := strFileName;
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
type
  TShowDllForm = procedure(var frm: TFormClass; var strParentModuleName, strModuleName, strClassName, strWindowName: PAnsiChar; const bShow: Boolean = True); stdcall;
var
  hDll                                                           : HMODULE;
  ShowDllForm                                                    : TShowDllForm;
  frm                                                            : TFormClass;
  strParentModuleName, strModuleName, strClassName, strWindowName: PAnsiChar;
  mmPM                                                           : TMenuItem;
  mmSM                                                           : TMenuItem;
  intIndex                                                       : Integer;
begin
  hDll := LoadLibrary(PChar(strDllFileName));
  if hDll = 0 then
    Exit;

  try
    ShowDllForm := GetProcAddress(hDll, 'ShowDllForm');
    if not Assigned(ShowDllForm) then
      Exit;

    { 获取 Dll 参数 }
    ShowDllForm(frm, strParentModuleName, strModuleName, strClassName, strWindowName, False);
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
    if FUIShowStyle = uisMenu then
    begin
      tlbMenu.Menu     := mmMain;
      mmMain.AutoMerge := True;
    end;
  end;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日');
var
  intIndex: Integer;
begin
  intIndex        := DayOfWeek(Now);
  lblTime.Caption := FormatDateTime('YYYY-MM-DD hh:mm:ss', Now) + ' ' + WeekDay[intIndex - 1];
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
  FUIShowStyle          := uisMenu;
  FUIViewStyle          := 0;
  FlstAllDll            := TStringList.Create;
  FstrActiveDllFileName := '';

  { 扫描插件目录 }
  ScanPlugins;
end;

end.
