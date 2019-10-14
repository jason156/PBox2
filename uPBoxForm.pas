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
    procedure FreeDllForm(const strDllFileName: string);
  public
    {
      strFileName      : �ļ���
      ft               : �ļ�����
      strPModuleName   : ��ģ������
      strSModuleName   : ��ģ������
      strFormClassName : ��������
      strFormTitleName : ���������
      strIconFileName  : ͼ��
      bShowForm        : �Ƿ���ʾ����
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

{ ���� Dll ���� }
procedure TfrmPBox.FreeDllForm(const strDllFileName: string);
begin

end;

{ ������һ�δ����� Dll ���� }
procedure TfrmPBox.DestoryPreDllForm;
begin
  if FstrActiveDllFileName = '' then
    Exit;

  { ���� Dll ���� }
  FreeDllForm(FstrActiveDllFileName);
end;

{ �����µ� Dll ���� }
procedure TfrmPBox.CreateDllForm(const strFileName: string);
begin
  FstrActiveDllFileName := strFileName;
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

    { ��ȡ Dll ���� }
    ShowDllForm(frm, strParentModuleName, strModuleName, strClassName, strWindowName, False);
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
    if FUIShowStyle = uisMenu then
    begin
      tlbMenu.Menu     := mmMain;
      mmMain.AutoMerge := True;
    end;
  end;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('����һ', '���ڶ�', '������', '������', '������', '������', '������');
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
  { ��ʼ������ }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := rztbshtCenter;

  { ��ʾ ʱ�� }
  tmrDateTime.OnTimer(nil);

  { ��ʾ IP }
  lblIP.Caption := GetNativeIP;
  lblIP.Left    := (lblIP.Parent.Width - lblIP.Width) div 2;

  { ��ʼ������ }
  FUIShowStyle          := uisMenu;
  FUIViewStyle          := 0;
  FlstAllDll            := TStringList.Create;
  FstrActiveDllFileName := '';

  { ɨ����Ŀ¼ }
  ScanPlugins;
end;

end.
