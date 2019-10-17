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
    { ɨ����Ŀ¼ }
    procedure ScanPlugins;
    { ����ģ��˵� }
    procedure CreateModuleMenu(const strDllFileName: string);
    { ����˵� }
    procedure OnMenuItemClick(Sender: TObject);
    { ������һ�δ����� Dll ���� }
    procedure DestoryPreDllForm;
    { �����µ� Dll ���� }
    procedure CreateDllForm(const strFileName: string);
    { ���� Dll ���� }
    procedure FreeDllForm;
    { ���� DLL/EXE ���� }
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

{ ���� Dll ���� }
procedure TfrmPBox.FreeDllForm;
begin

end;

{ ������һ�δ����� Dll ���� }
procedure TfrmPBox.DestoryPreDllForm;
begin
  FreeDllForm;
end;

{ �����µ� Dll ���� }
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

  { ��ȡ���� }
  ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);

  { ���� DLL/EXE �ļ����͵Ĳ�ͬ������ DLL/EXE ���� }
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

{ ����˵� }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { ������һ�δ����� Dll ���� }
  DestoryPreDllForm;

  { �����µ� Dll ���� }
  CreateDllForm((FlstAllDll.Strings[TMenuItem(Sender).Tag]));
end;

{ ����ģ��˵� }
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

    { ��ȡ Dll ���� }
    ShowDllForm(frm, ft, strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
    intIndex := FlstAllDll.Add(strDllFileName);

    { ������˵������ڣ��������˵� }
    mmPM := mmMain.Items.Find(string(strParentModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMain);
      mmPM.Caption := string((strParentModuleName));
      mmMain.Items.Add(mmPM);
    end;

    { �����Ӳ˵� }
    mmSM         := TMenuItem.Create(mmPM);
    mmSM.Caption := string((strModuleName));
    mmSM.Tag     := intIndex;
    mmSM.OnClick := OnMenuItemClick;
    mmPM.Add(mmSM);

  finally
    FreeLibrary(hDll)
  end;
end;

{ ɨ����Ŀ¼ }
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
    { ɨ�� Dll �ļ��������ڲ��Ŀ¼(plugins) }
    arrDllFile := TDirectory.GetFiles(ExtractFilePath(ParamStr(0)) + 'plugins', '*.dll');
    if Length(arrDllFile) > 0 then
    begin
      for strDllFileName in arrDllFile do
      begin
        { ����ģ��˵� }
        CreateModuleMenu(strDllFileName);
      end;
    end;

    { ɨ�� EXE �ļ�����ȡ�����ļ� }

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
  WeekDay: array [1 .. 7] of String = ('����һ', '���ڶ�', '������', '������', '������', '������', '������');
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
  { ��󻯴��� }
  pnlDBLClick(nil);
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
begin
  { ��ʼ������ }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := rztbshtCenter;

  { ��ʾ ʱ�� }
  tmrDateTime.OnTimer(nil);

  { ��ʾ IP }
  lblIP.Caption := GetNativeIP;
  lblIP.Left    := (lblIP.Parent.Width - lblIP.Width) div 2;

  { ��ʼ������ }
  FUIShowStyle := ssMenu;
  FUIViewStyle := vsSingle;
  FlstAllDll   := TStringList.Create;

  { ɨ����Ŀ¼ }
  ScanPlugins;
end;

end.
