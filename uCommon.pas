unit uCommon;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.IniFiles, IdIPWatch;

{ ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript: Boolean;

function GetNativeIP: String;

type
  TUIStyle = (uisMenu, uisButton, uisList);

const
  c_strTitle                                  = '����Ա������ v4.0';
  c_strUIStyle: array [0 .. 2] of ShortString = ('�˵�ʽ', '��ťʽ', '����ʽ');
  c_strIniUISection                           = 'UI';
  c_strIniFormStyleSection                    = 'FormStyle';
  c_strIniModuleSection                       = 'Module';
  c_strMsgTitle: PChar                        = 'ϵͳ��ʾ��';
  c_strAESKey                                 = 'dbyoung@sina.com';

implementation

{ ֻ��������һ��ʵ�� }
procedure OnlyOneRunInstance;
var
  hMainForm       : THandle;
  strTitle        : String;
  bOnlyOneInstance: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strTitle         := ReadString(c_strIniUISection, 'Title', c_strTitle);
    bOnlyOneInstance := ReadBool(c_strIniUISection, 'OnlyOneInstance', False);
    Free;
  end;

  if not bOnlyOneInstance then
    Exit;

  hMainForm := FindWindow('TfrmPBox', PChar(strTitle));
  if hMainForm <> 0 then
  begin
    MessageBox(0, '�����Ѿ����У������ظ�����', 'ϵͳ��ʾ��', MB_OK OR MB_ICONERROR);
    if IsIconic(hMainForm) then
      PostMessage(hMainForm, WM_SYSCOMMAND, SC_RESTORE, 0);
    BringWindowToTop(hMainForm);
    SetForegroundWindow(hMainForm);
    Halt;
    Exit;
  end;
end;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
var
  TP    : Winapi.Windows.TOKEN_PRIVILEGES;
  Dummy : Cardinal;
  hToken: THandle;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken);
  TP.PrivilegeCount := 1;
  LookupPrivilegeValue(nil, PChar(PrivName), TP.Privileges[0].Luid);
  if CanDebug then
    TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
  else
    TP.Privileges[0].Attributes := 0;
  Result                        := AdjustTokenPrivileges(hToken, False, TP, SizeOf(TP), nil, Dummy);
  hToken                        := 0;
end;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript: Boolean;
begin
  Result := True;
end;

function GetNativeIP: String;
var
  IdIPWatch: TIdIPWatch;
begin
  IdIPWatch := TIdIPWatch.Create(nil);
  try
    IdIPWatch.HistoryEnabled := False;
    Result                   := IdIPWatch.LocalIP;
  finally
    IdIPWatch.Free;
  end;

end;

end.
