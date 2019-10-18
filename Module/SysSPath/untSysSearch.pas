unit untSysSearch;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, System.StrUtils, Variants, Classes, Graphics, Vcl.Controls, Vcl.Forms, System.Win.Registry, System.IniFiles, System.Types, Dialogs, System.IOUtils, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls;

type
  TfrmSysSearch = class(TForm)
    lst1: TListBox;
    btnSysSearchAdd: TButton;
    btnSysSearchModify: TButton;
    btnSysSearchUp: TButton;
    btnSysSearchDown: TButton;
    btnSysSearchUpTop: TButton;
    btnSysSearchDownBottom: TButton;
    btnSysSearchBackup: TButton;
    btnSysSearchRestore: TButton;
    btnSysSearchDel: TButton;
    btnInputSysSearch: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSysSearchAddClick(Sender: TObject);
    procedure btnSysSearchDelClick(Sender: TObject);
    procedure btnSysSearchModifyClick(Sender: TObject);
    procedure btnSysSearchUpClick(Sender: TObject);
    procedure btnSysSearchDownClick(Sender: TObject);
    procedure btnSysSearchUpTopClick(Sender: TObject);
    procedure btnSysSearchDownBottomClick(Sender: TObject);
    procedure btnSysSearchBackupClick(Sender: TObject);
    procedure btnSysSearchRestoreClick(Sender: TObject);
    procedure btnInputSysSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  { 支持的文件类型 }
  TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;
begin
  frm                 := TfrmSysSearch;
  ft                  := ftDelphiDll;
  strParentModuleName := '系统管理';
  strModuleName       := '系统搜索路径';
  strIconFileName     := '';
  strClassName        := '';
  strWindowName       := '';
end;

function GetSysSearchPath: TStringDynArray;
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', False);
    Result := SplitString(ReadString('Path'), ';');
    Free;
  end;
end;

procedure ModifySysSearchPath(const strsList: TStrings);
var
  strSearchPath: String;
  III          : Integer;
  rv           : DWORD_PTR;
begin
  strSearchPath := '';
  for III       := 0 to strsList.Count - 1 do
  begin
    if (Trim(strsList.Strings[III]) <> '') and (strsList.Strings[III] <> ';') then
    begin
      // if SysUtils.DirectoryExists(strsList.Strings[III]) then
      // begin
      strSearchPath := strSearchPath + ';' + strsList.Strings[III];
      // end
      // else
      // begin
      // ShowMessage(Format('%s 文件夹不存在', [strsList.Strings[III]]));
      // end;
    end;
  end;
  strSearchPath := RightStr(strSearchPath, Length(strSearchPath) - 1);

  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', False);
    if (Win32MajorVersion >= 6) and (Win32MinorVersion >= 1) then
      WriteExpandString('Path', strSearchPath)
    else
      WriteString('Path', strSearchPath);

    SystemParametersInfo(SPI_SETCURSORS, 0, nil, SPIF_SENDCHANGE);
    SendMessageTimeout(HWND_BROADCAST, WM_WININICHANGE, $2A, LParam(PChar('Environment')), SMTO_NORMAL or SMTO_ABORTIFHUNG or SMTO_BLOCK, 5000, @rv);

    CloseKey;
    Free;
  end;
end;

function FindMainFormHandle: THandle;
var
  strTitle      : string;
  strBuffer     : array [0 .. 255] of Char;
  strIniFileName: String;
begin
  GetModuleFileName(0, strBuffer, 256);
  strIniFileName := strBuffer;
  strIniFileName := ChangeFileExt(strIniFileName, '.ini');
  with TIniFile.Create(string(strIniFileName)) do
  begin
    strTitle := ReadString('UI', 'Title', '程序员工具箱 v2.0');
    Free;
  end;
  Result := FindWindow('TfrmMain', PChar(strTitle));
end;

function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            { 短跳转 $E8 }
    Offset: Integer;       { CalcJmpOffset(Instance, @Block^.Code); }
    Next: PObjectInstance; { MainWndProc 地址 }
    Self: Pointer;         { 控件对象地址 }
  end;
var
  wc: PObjectInstance;
begin
  Result := nil;
  wc     := Pointer(GetWindowLong(hWnd, GWL_WNDPROC));
  if wc <> nil then
  begin
    Result := wc.Self;
  end;
end;

procedure TfrmSysSearch.FormCreate(Sender: TObject);
var
  strArr: TStringDynArray;
  III   : Integer;
begin
  strArr  := GetSysSearchPath;
  for III := Low(strArr) to High(strArr) do
  begin
    lst1.Items.Add(strArr[III]);
  end;
end;

procedure TfrmSysSearch.FormShow(Sender: TObject);
begin
  // MessageBox(Handle, PChar(Format('主窗体句柄：%d($%x)', [tag, tag])), '系统提示：', 64);
end;

{ 添加 }
procedure TfrmSysSearch.btnSysSearchAddClick(Sender: TObject);
var
  strSelectDir   : String;
  hMainForm      : THandle;
  hMainFormObject: TWinControl;
begin
  hMainForm       := FindMainFormHandle;
  hMainFormObject := GetInstanceFromhWnd(hMainForm);
  if not SelectDirectory('请选择一个文件夹：', '', strSelectDir, [sdNewUI], hMainFormObject) then
    Exit;

  lst1.Items.Add(strSelectDir);
  ModifySysSearchPath(lst1.Items);
end;

{ 输入 }
procedure TfrmSysSearch.btnInputSysSearchClick(Sender: TObject);
var
  strNewPath: String;
begin
  strNewPath := Clipboard.AsText;
  if not InputQuery('添加路径：', '名称：', strNewPath) then
    Exit;

  lst1.Selected[lst1.Items.Add(strNewPath)] := True;
  ModifySysSearchPath(lst1.Items);
end;

{ 删除 }
procedure TfrmSysSearch.btnSysSearchDelClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  lst1.DeleteSelected;
  ModifySysSearchPath(lst1.Items);
end;

{ 修改 }
procedure TfrmSysSearch.btnSysSearchModifyClick(Sender: TObject);
var
  strNewPath: String;
begin
  if lst1.ItemIndex < 0 then
    Exit;

  strNewPath := lst1.Items.Strings[lst1.ItemIndex];
  if not InputQuery('修改路径', '路径：', strNewPath) then
    Exit;

  lst1.Items.Strings[lst1.ItemIndex] := strNewPath;
  ModifySysSearchPath(lst1.Items);
end;

{ 上移 }
procedure TfrmSysSearch.btnSysSearchUpClick(Sender: TObject);
begin
  if lst1.ItemIndex <= 0 then
    Exit;

  lst1.Items.Exchange(lst1.ItemIndex, lst1.ItemIndex - 1);
  ModifySysSearchPath(lst1.Items);
end;

{ 下移 }
procedure TfrmSysSearch.btnSysSearchDownClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  if lst1.ItemIndex >= lst1.Items.Count - 1 then
    Exit;

  lst1.Items.Exchange(lst1.ItemIndex, lst1.ItemIndex + 1);
  ModifySysSearchPath(lst1.Items);
end;

{ 上移到顶端 }
procedure TfrmSysSearch.btnSysSearchUpTopClick(Sender: TObject);
begin
  if lst1.ItemIndex <= 0 then
    Exit;

  lst1.Items.Move(lst1.ItemIndex, 0);
  ModifySysSearchPath(lst1.Items);
  lst1.Selected[0] := True;
end;

{ 下移到底端 }
procedure TfrmSysSearch.btnSysSearchDownBottomClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  if lst1.ItemIndex >= lst1.Items.Count - 1 then
    Exit;

  lst1.Items.Move(lst1.ItemIndex, lst1.Items.Count - 1);
  ModifySysSearchPath(lst1.Items);
  lst1.Selected[lst1.Items.Count - 1] := True;
end;

{ 备份 }
procedure TfrmSysSearch.btnSysSearchBackupClick(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
  begin
    Filter := '系统搜索路径备份文件(*.SSP)|*.SSP';
    if Execute(FindMainFormHandle) then
    begin
      lst1.Items.SaveToFile(FileName + '.SSP');
    end;
    Free;
  end;
end;

{ 还原 }
procedure TfrmSysSearch.btnSysSearchRestoreClick(Sender: TObject);
begin
  with TOpenDialog.Create(nil) do
  begin
    Filter := '系统搜索路径备份文件(*.SSP)|*.SSP';
    if Execute(FindMainFormHandle) then
    begin
      lst1.Items.LoadFromFile(FileName);
      ModifySysSearchPath(lst1.Items);
    end;
    Free;
  end;
end;

end.
