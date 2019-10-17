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
    { ɨ����Ŀ¼ }
    procedure ScanPlugins;
    { ����ģ��˵� }
    procedure CreateModuleMenu(const strDllFileName: string);
    { ����˵� }
    procedure OnMenuItemClick(Sender: TObject);
    { ������һ�δ����� Dll ���� }
    procedure DestoryPreDllForm;
    procedure FreeDllForm;
    { �����µ� Dll ���� }
    procedure CreateDllForm;
    { ���� DLL/EXE ���� }
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

{ ��� dll �У��� Dll �����ȡ���㣬�������ɷǼ���״̬ }
function NewDllFormProc(hWnd: THandle; msg: UINT; wParam: Cardinal; lParam: Cardinal): Integer; stdcall;
begin
  { ����Ӵ����ȡ����ʱ������������ }
  if msg = WM_ACTIVATE then
  begin
    if Application.MainForm <> nil then
    begin
      SendMessage(Application.MainForm.Handle, WM_NCACTIVATE, Integer(True), 0);
    end;
  end;

  { ��ֹ�����ƶ� }
  if msg = WM_SYSCOMMAND then
  begin
    if wParam = SC_MOVE + 2 then
    begin
      wParam := 0;
    end;
  end;

  { ����ԭ���Ļص����� }
  Result := CallWindowProc(g_OldWndProc, hWnd, msg, wParam, lParam);
end;

function _CreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (CompareText(lpClassName, g_StrVCDialogDllClassName) = 0) and (CompareText(lpWindowName, g_StrVCDialogDllWindowName) = 0) then
  begin
    { ���� VC Dlll ���� }
    frmPBox.rzpgcntrlAll.ActivePageIndex := 2;
    Result                               := g_Old_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    g_hVCDllFormWnd                      := Result;                                                                                                         // ������ VC Dll ������
    Winapi.Windows.SetParent(Result, frmPBox.rztbshtDllForm.Handle);                                                                                        // ���ø�����Ϊ TabSheet <��� DLL ���� TAB �������õ�����>
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                                             // ɾ���ƶ��˵�
    SetWindowPos(Result, frmPBox.rztbshtDllForm.Handle, 0, 0, frmPBox.rztbshtDllForm.Width, frmPBox.rztbshtDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
    g_OldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                                                            // ��� DLL �����ȡ����ʱ�������嶪ʧ���������
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                                                           // ���� DLL ������Ϣ
    PostMessage(frmPBox.Handle, WM_NCACTIVATE, 1, 0);                                                                                                       // ����������
    UnHook(@g_Old_CreateWindowExW);                                                                                                                         // UNHOOK
    g_Old_CreateWindowExW := nil;                                                                                                                           // UNHOOK
  end
  else
  begin
    Result := g_Old_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

{ ���� VC Dialog Dll ���� }
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

  { ��ȡ���� }
  hDll := LoadLibrary(PChar(FstrCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(Handle, PChar(Format('���� %s ���������ļ��Ƿ��������߱�ռ��', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  if not Assigned(ShowDllForm) then
  begin
    MessageBox(Handle, PChar(Format('���� %s �ĵ������� %s ���������ļ��Ƿ���ڻ��߱�ռ��', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
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

  { ���� Dll ���� }
  hDll := LoadLibrary(PChar(FstrCreateDllFileName));
  if hDll = 0 then
  begin
    MessageBox(Handle, PChar(Format('���� %s ���������ļ��Ƿ��������߱�ռ��', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
    if not Assigned(ShowDllForm) then
    begin
      MessageBox(Handle, PChar(Format('���� %s �ĵ������� %s ���������ļ��Ƿ���ڻ��߱�ռ��', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
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
    MessageBox(Handle, PChar(Format('���� %s ���������ļ��Ƿ��������߱�ռ��', [FstrCreateDllFileName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  if not Assigned(ShowDllForm) then
  begin
    MessageBox(Handle, PChar(Format('���� %s �ĵ������� %s ���������ļ��Ƿ���ڻ��߱�ռ��', [FstrCreateDllFileName, c_strDllExportName])), c_strMsgTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
  finally
    FreeLibrary(hDll);
  end;

  { ���� DLL/EXE �ļ����͵Ĳ�ͬ������ DLL/EXE ���� }
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

{ �����µ� Dll ���� }
procedure TfrmPBox.CreateDllForm;
begin
  PostMessage(Handle, WM_CREATENEWDLLFORM, 0, 0);
end;

procedure TfrmPBox.FreeDllForm;
begin
  { �ر���һ�δ����� Dll ���� }
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

{ ������һ�δ����� Dll ���� }
procedure TfrmPBox.DestoryPreDllForm;
begin
  FreeDllForm;
end;

{ ����˵� }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
begin
  lblInfo.Caption := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { ������һ�δ����� Dll ���� }
  DestoryPreDllForm;

  { �����µ� Dll ���� }
  FstrCreateDllFileName := FlstAllDll.Strings[TMenuItem(Sender).Tag];
  CreateDllForm;
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
    ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
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

procedure TfrmPBox.FormCreate(Sender: TObject);
var
  strDllModulePath: string;
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
  strDllModulePath := ExtractFilePath(ParamStr(0)) + 'plugins';
  SetDllDirectory(PChar(strDllModulePath));
  ScanPlugins;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { ��󻯴��� }
  pnlDBLClick(nil);
end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FlstAllDll.Free;
end;

end.
