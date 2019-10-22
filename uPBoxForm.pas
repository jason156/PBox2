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
    clbr1: TCoolBar;
    tlbMenu: TToolBar;
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
    { ɨ�� EXE �ļ�����ȡ�����ļ� }
    procedure ScanPlugins_EXE;
    { ɨ�� Dll �ļ��������ڲ��Ŀ¼(plugins) }
    procedure ScanPlugins_Dll;
    { ɨ����Ŀ¼ }
    procedure ScanPlugins;
    { ����ģ��˵� }
    procedure CreateModuleMenu;
    { ����˵� }
    procedure OnMenuItemClick(Sender: TObject);
    { �����µ� Dll ���� }
    procedure CreateDllForm;
    { ��ʵ�� }
    function PBoxRun_VC_MFCDll: Boolean;
    function PBoxRun_QT_GUIDll: Boolean;
    procedure OnSysConfig(Sender: TObject);
    procedure OnDelphiDllFormClose(Sender: TObject; var Action: TCloseAction);
    { ��ȡ EXE �ļ���ͼ�� }
    function GetExeFileIcon(const strFileName: String): Integer; overload;
    function GetExeFileIcon(const strEXEInfo, strFileName: string): Integer; overload;
    { ��ȡ Dll �ļ���ͼ�� }
    function GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
    function ReadDllIconFromConfig(const strPModule, strSModule: string): Integer;
  protected
    procedure WMDESTORYPREDLLFORM(var msg: TMessage); message WM_DESTORYPREDLLFORM;
    procedure WMCREATENEWDLLFORM(var msg: TMessage); message WM_CREATENEWDLLFORM;
  end;

var
  frmPBox: TfrmPBox;

implementation

uses uConfigForm;

{$R *.dfm}

function TfrmPBox.PBoxRun_VC_MFCDll: Boolean;
begin
  Result := True;
end;

function TfrmPBox.PBoxRun_QT_GUIDll: Boolean;
begin
  Result := True;
end;

procedure TfrmPBox.OnSysConfig(Sender: TObject);
begin
  ShowConfigForm(FlstAllDll);
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
  if g_strCreateDllFileName = '' then
    Exit;

  { exe �ļ� }
  if CompareText(ExtractFileExt(g_strCreateDllFileName), '.exe') = 0 then
  begin
    strFileValue := FlstAllDll.Values[g_strCreateDllFileName];
    PBoxRun_IMAGE_EXE(g_strCreateDllFileName, strFileValue, rzpgcntrlAll, tsDll, lblInfo);
    Exit;
  end;

  { Dll �ļ�����ȡ�ļ����� }
  hDll := LoadLibrary(PChar(g_strCreateDllFileName));
  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strFormClassName, strFormTitleName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { ���� DLL �ļ����͵Ĳ�ͬ������ DLL ���� }
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

{ �����µ� Dll ���� }
procedure TfrmPBox.CreateDllForm;
begin
  PostMessage(Handle, WM_CREATENEWDLLFORM, 0, 0);
end;

{ ������һ�δ����� Dll ���� }
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
    CreateDllForm;
    Exit;
  end;

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
    { �����µ� Dll ���� }
    CreateDllForm;
  end
  else
  begin
    { ���� VC Dialog Dll ������Ϣ }
    FreeVCDialogDllForm;
  end;
end;

{ ����˵� }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { ����Ѿ������ˣ��Ͳ����ظ������� }
  if (g_strCreateDllFileName <> '') and (g_strCreateDllFileName = FlstAllDll.Names[TMenuItem(Sender).Tag]) then
    Exit;

  g_strCreateDllFileName := FlstAllDll.Names[TMenuItem(Sender).Tag];

  { ������һ�δ����� Dll ���� }
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

{ ��ȡ EXE �ļ���ͼ�� }
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

{ ɨ�� EXE �ļ�����ȡ�����ļ� }
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

{ ��ȡ Dll �ļ���ͼ�� }
function TfrmPBox.GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
var
  strCurrIconFileName: String;
  IcoExe             : TIcon;
begin
  if Trim(strIconFileName) = '' then
  begin
    { �������ļ��ж�ȡͼ����Ϣ }
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
      { �������ļ��ж�ȡͼ����Ϣ }
      Result := ReadDllIconFromConfig(strPModuleName, strSModuleName);
    end;
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
  ft                            : TSPFileType;
  strDllFileName                : String;
  strInfo                       : string;
  I, Count                      : Integer;
  lstTemp                       : TStringList;
  intIconIndex                  : Integer;
begin
  lstTemp := TStringList.Create;
  try
    { ɨ�� Dll �ļ��������ڲ��Ŀ¼(plugins) }
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

        { ��ȡ Dll ���� }
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

{ ����ģ��˵� }
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

    { ������˵������ڣ��������˵� }
    mmPM := mmMainMenu.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMainMenu);
      mmPM.Caption := string((strPModuleName));
      mmMainMenu.Items.Add(mmPM);
    end;

    { �����Ӳ˵� }
    mmSM            := TMenuItem.Create(mmPM);
    mmSM.Caption    := string((strSModuleName));
    mmSM.Tag        := I;
    mmSM.ImageIndex := intIconIndex;
    mmSM.OnClick    := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ ɨ����Ŀ¼ }
procedure TfrmPBox.ScanPlugins;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  mmMainMenu.Items.Clear;
  mmMainMenu.AutoMerge := False;
  try
    { ɨ�� Dll �ļ�����ӵ��б���ǰ���Ŀ¼ (plugins) }
    ScanPlugins_Dll;

    { ɨ�� EXE �ļ�����ӵ��б���ȡ�����ļ� }
    ScanPlugins_EXE;

    { ����ģ�� }
    SortModuleList(FlstAllDll);

    { ����ģ��˵� }
    CreateModuleMenu;
  finally
    if FUIShowStyle = ssMenu then
    begin
      tlbMenu.Menu         := mmMainMenu;
      mmMainMenu.AutoMerge := True;
    end;
  end;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('������', '����һ', '���ڶ�', '������', '������', '������', '������');
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

procedure TfrmPBox.FormCreate(Sender: TObject);
var
  strDllModulePath: string;
begin
  { ��ʼ������ }
  FUIShowStyle           := ssMenu;
  FUIViewStyle           := vsSingle;
  FlstAllDll             := THashedStringList.Create;
  g_strCreateDllFileName := '';
  FDelphiDllForm         := nil;
  OnConfig               := OnSysConfig;
  TrayIconPMenu          := pmTray;

  { ��ʼ������ }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := tsDll;
  ReadConfigUI;

  { ��ʾ ʱ�� }
  tmrDateTime.OnTimer(nil);

  { ��ʾ IP }
  lblIP.Caption := GetNativeIP;
  lblIP.Left    := (lblIP.Parent.Width - lblIP.Width) div 2;

  { ɨ����Ŀ¼ }
  strDllModulePath := ExtractFilePath(ParamStr(0)) + 'plugins';
  SetDllDirectory(PChar(strDllModulePath));
  ScanPlugins;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { ��󻯴��� }
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
  { �ж��Ƿ��� Dll �Ĵ����� }
  if GetParent(hDllForm) = 0 then
  begin
    { ���� Dll �����С }
    GetWindowRect(hParentHandle, rctClient);
    SetWindowPos(hDllForm, hParentHandle, 0, 0, rctClient.Width, rctClient.Height, SWP_NOZORDER + SWP_NOACTIVATE);
  end;
  Result := True;
end;

procedure TfrmPBox.FormResize(Sender: TObject);
begin
  { ���� Dll �����С }
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

end.
