unit uBaseForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.iniFiles,
  Vcl.Menus, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, uCommon;

type
  TUIBaseForm = class(TForm)
  private
    FpnlTitle           : TPanel;
    FbtnClose           : TImage;
    FbtnMax             : TImage;
    FbtnMin             : TImage;
    FbtnConfig          : TImage;
    FbMouseDown         : Boolean;
    FPT                 : TPoint;
    FbOnlyRunOneInstance: Boolean;
    FOnConfig           : TNotifyEvent;
    FTitleString        : string;
    FMulScreenPos       : Boolean;
    FbCloseToTray       : Boolean;
    FTrayIcon           : TTrayIcon;
    FTrayIconPMenu      : TPopupMenu;
    procedure OnCloseClick(Sender: TObject);
    procedure OnMaxClick(Sender: TObject);
    procedure OnMinClick(Sender: TObject);
    procedure OnConfigClick(Sender: TObject);
    { 提升权限 }
    function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
    procedure SetTitleString(const Value: string);
    procedure SetMulScreenPos(const Value: Boolean);
    function GetCloseToTray: Boolean;
    procedure SetCloseToTray(const Value: Boolean);
    procedure TrayIconDblClick(Sender: TObject);
    function GetTrayIconPMenu: TPopupMenu;
    procedure SetTrayIconPMenu(const Value: TPopupMenu);
    procedure LoadButtonBmp(img: TImage; const strResName: String; const intState: Integer);
    procedure OnSysButtonCloseMouseEnter(Sender: TObject);
    procedure OnSysButtonCloseMouseLeave(Sender: TObject);
    procedure OnSysButtonMaxMouseEnter(Sender: TObject);
    procedure OnSysButtonMaxMouseLeave(Sender: TObject);
    procedure OnSysButtonMinMouseEnter(Sender: TObject);
    procedure OnSysButtonMinMouseLeave(Sender: TObject);
    procedure OnSysButtonConfigMouseEnter(Sender: TObject);
    procedure OnSysButtonConfigMouseLeave(Sender: TObject);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure pnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlDBLClick(Sender: TObject);
    procedure InitSysButton;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnConfig: TNotifyEvent read FOnConfig write FOnConfig;
    property TitleString: string Read FTitleString write SetTitleString;
    property MulScreenPos: Boolean read FMulScreenPos write SetMulScreenPos;
    property CloseToTray: Boolean read GetCloseToTray write SetCloseToTray;
    property TrayIconPMenu: TPopupMenu read GetTrayIconPMenu write SetTrayIconPMenu;
    property MainTrayIcon: TTrayIcon read FTrayIcon;
  end;

const
  c_intIconSize     = 30;
  c_strIniUISection = 'UI';
  c_strTitle        = '程序员工具箱 v2.0';

{$R *.res}

implementation

{ TUIBaseForm }

procedure TUIBaseForm.LoadButtonBmp(img: TImage; const strResName: String; const intState: Integer);
var
  bmp      : TBitmap;
  bmpButton: TBitmap;
  memBMP   : TResourceStream;
begin
  memBMP    := TResourceStream.Create(HInstance, 'SYSBUTTON_' + strResName, RT_RCDATA);
  bmp       := TBitmap.Create;
  bmpButton := TBitmap.Create;
  try
    bmp.LoadFromStream(memBMP);;
    bmpButton.Width  := bmp.Width div 3;
    bmpButton.Height := bmp.Height;
    bmpButton.Canvas.CopyRect(bmpButton.Canvas.ClipRect, bmp.Canvas, Rect(c_intIconSize * intState, 0, c_intIconSize * intState + bmpButton.Width, bmpButton.Height));
    img.Picture.Bitmap.Assign(bmpButton);
  finally
    memBMP.Free;
    bmpButton.Free;
    bmp.Free;
  end;
end;

procedure TUIBaseForm.OnSysButtonCloseMouseEnter(Sender: TObject);
begin
  LoadButtonBmp(FbtnClose, 'CLOSE', 1);
end;

procedure TUIBaseForm.OnSysButtonCloseMouseLeave(Sender: TObject);
begin
  LoadButtonBmp(FbtnClose, 'CLOSE', 0);
end;

procedure TUIBaseForm.OnSysButtonMaxMouseEnter(Sender: TObject);
begin
  if WindowState = wsMaximized then
    LoadButtonBmp(FbtnMax, 'RESTORE', 1)
  else
    LoadButtonBmp(FbtnMax, 'MAX', 1);
end;

procedure TUIBaseForm.OnSysButtonMaxMouseLeave(Sender: TObject);
begin
  if WindowState = wsMaximized then
    LoadButtonBmp(FbtnMax, 'RESTORE', 0)
  else
    LoadButtonBmp(FbtnMax, 'MAX', 0);
end;

procedure TUIBaseForm.OnSysButtonMinMouseEnter(Sender: TObject);
begin
  LoadButtonBmp(FbtnMin, 'MINI', 1);
end;

procedure TUIBaseForm.OnSysButtonMinMouseLeave(Sender: TObject);
begin
  LoadButtonBmp(FbtnMin, 'MINI', 0);
end;

procedure TUIBaseForm.OnSysButtonConfigMouseEnter(Sender: TObject);
begin
  LoadButtonBmp(FbtnConfig, 'CONFIG', 1);
end;

procedure TUIBaseForm.OnSysButtonConfigMouseLeave(Sender: TObject);
begin
  LoadButtonBmp(FbtnConfig, 'CONFIG', 0);
end;

{ 初始化系统按钮 }
procedure TUIBaseForm.InitSysButton;
begin
  FpnlTitle                  := TPanel.Create(Self);
  FpnlTitle.Parent           := Self;
  FpnlTitle.Width            := Width;
  FpnlTitle.Height           := 70;
  FpnlTitle.Align            := alTop;
  FpnlTitle.Caption          := Caption;
  FpnlTitle.Font.Name        := '微软雅黑';
  FpnlTitle.Font.Style       := [fsBold];
  FpnlTitle.Font.Size        := 26;
  FpnlTitle.Font.Color       := clWhite;
  FpnlTitle.ParentBackground := False;
  FpnlTitle.ParentColor      := False;
  FpnlTitle.Color            := RGB(46, 141, 230);
  FpnlTitle.BevelOuter       := bvNone;
  FpnlTitle.OnMouseDown      := pnlMouseDown;
  FpnlTitle.OnMouseUp        := pnlMouseUp;
  FpnlTitle.OnMouseMove      := pnlMouseMove;
  FpnlTitle.OnDblClick       := pnlDBLClick;

  FbtnClose         := TImage.Create(FpnlTitle);
  FbtnMax           := TImage.Create(FpnlTitle);
  FbtnMin           := TImage.Create(FpnlTitle);
  FbtnConfig        := TImage.Create(FpnlTitle);
  FbtnClose.Parent  := FpnlTitle;
  FbtnMax.Parent    := FpnlTitle;
  FbtnMin.Parent    := FpnlTitle;
  FbtnConfig.Parent := FpnlTitle;

  FbtnClose.Transparent  := False;
  FbtnClose.Width        := c_intIconSize;
  FbtnClose.Height       := c_intIconSize;
  FbtnClose.Left         := Width - c_intIconSize - 1;
  FbtnClose.Top          := 1;
  FbtnClose.AutoSize     := True;
  FbtnClose.Stretch      := False;
  FbtnClose.Hint         := '关闭';
  FbtnClose.ShowHint     := True;
  FbtnClose.OnClick      := OnCloseClick;
  FbtnClose.Anchors      := [akTop, akRight];
  FbtnClose.OnMouseEnter := OnSysButtonCloseMouseEnter;
  FbtnClose.OnMouseLeave := OnSysButtonCloseMouseLeave;

  FbtnMax.Transparent  := False;
  FbtnMax.Width        := c_intIconSize;
  FbtnMax.Height       := c_intIconSize;
  FbtnMax.Left         := Width - c_intIconSize * 2;
  FbtnMax.Top          := 1;
  FbtnMax.AutoSize     := True;
  FbtnMax.Stretch      := False;
  FbtnMax.Hint         := '最大化';
  FbtnMax.ShowHint     := True;
  FbtnMax.OnClick      := OnMaxClick;
  FbtnMax.Anchors      := [akTop, akRight];
  FbtnMax.OnMouseEnter := OnSysButtonMaxMouseEnter;
  FbtnMax.OnMouseLeave := OnSysButtonMaxMouseLeave;

  FbtnMin.Transparent  := False;
  FbtnMin.Width        := c_intIconSize;
  FbtnMin.Height       := c_intIconSize;
  FbtnMin.Left         := Width - c_intIconSize * 3;
  FbtnMin.Top          := 1;
  FbtnMin.AutoSize     := True;
  FbtnMin.Stretch      := False;
  FbtnMin.Hint         := '最小化';
  FbtnMin.ShowHint     := True;
  FbtnMin.OnClick      := OnMinClick;
  FbtnMin.Anchors      := [akTop, akRight];
  FbtnMin.OnMouseEnter := OnSysButtonMinMouseEnter;
  FbtnMin.OnMouseLeave := OnSysButtonMinMouseLeave;

  FbtnConfig.Transparent  := False;
  FbtnConfig.Width        := c_intIconSize;
  FbtnConfig.Height       := c_intIconSize;
  FbtnConfig.Left         := Width - c_intIconSize * 4 - 2;
  FbtnConfig.Top          := 1;
  FbtnConfig.AutoSize     := True;
  FbtnConfig.Stretch      := False;
  FbtnConfig.Hint         := '配置';
  FbtnConfig.ShowHint     := True;
  FbtnConfig.OnClick      := OnConfigClick;
  FbtnConfig.Anchors      := [akTop, akRight];
  FbtnConfig.OnMouseEnter := OnSysButtonConfigMouseEnter;
  FbtnConfig.OnMouseLeave := OnSysButtonConfigMouseLeave;

  LoadButtonBmp(FbtnClose, 'CLOSE', 0);
  LoadButtonBmp(FbtnMax, 'MAX', 0);
  LoadButtonBmp(FbtnMin, 'MINI', 0);
  LoadButtonBmp(FbtnConfig, 'CONFIG', 0);
end;

constructor TUIBaseForm.Create(AOwner: TComponent);
var
  strIniFileName: String;
begin
  inherited;

  { 提升权限 }
  EnableDebugPrivilege('SeDebugPrivilege', True);
  EnableDebugPrivilege('SeSecurityPrivilege', True);

  { 窗体风格 }
  BorderStyle := bsNone;
  Color       := clWhite;

  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    Caption := ReadString(c_strIniUISection, 'Title', c_strTitle);
    Free;
  end;

  { 初始化成员变量 }
  FbOnlyRunOneInstance := False;
  FbMouseDown          := False;
  FbCloseToTray        := False;
  FTrayIcon            := TTrayIcon.Create(nil);
  FTrayIcon.Visible    := True;
  FTrayIcon.Hint       := Caption;
  FTrayIcon.Icon       := Application.Icon;
  FTrayIcon.OnDblClick := TrayIconDblClick;

  { 初始化系统按钮 }
  InitSysButton;
end;

destructor TUIBaseForm.Destroy;
begin
  FbtnClose.Free;
  FbtnMax.Free;
  FbtnMin.Free;
  FpnlTitle.Free;
  FTrayIcon.Free;

  inherited;
end;

{ 提升权限 }
function TUIBaseForm.EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
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

function TUIBaseForm.GetCloseToTray: Boolean;
begin
  Result := FbCloseToTray;
end;

function TUIBaseForm.GetTrayIconPMenu: TPopupMenu;
begin
  Result := FTrayIconPMenu;
end;

procedure TUIBaseForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if WindowState = wsMaximized then
    Exit;

  if Button = mbLeft then
    FbMouseDown := True;
  GetCursorPos(FPT);
end;

procedure TUIBaseForm.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  inherited;
  if not FbMouseDown then
    Exit;

  GetCursorPos(pt);
  Left := Left + (pt.X - FPT.X);
  Top  := Top + (pt.Y - FPT.Y);
  FPT  := pt;
end;

procedure TUIBaseForm.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FbMouseDown := False;
end;

procedure TUIBaseForm.OnCloseClick(Sender: TObject);
begin
  if FbCloseToTray then
  begin
    Hide;
    FTrayIcon.Visible := True;
    Exit;
  end;

  FTrayIcon.Visible := False;
  Close;
end;

procedure TUIBaseForm.OnConfigClick(Sender: TObject);
begin
  if Assigned(FOnConfig) then
    FOnConfig(Self);
end;

procedure TUIBaseForm.OnMaxClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
  begin
    ShowWindow(Handle, SW_SHOWNORMAL);
    LoadButtonBmp(FbtnMax, 'MAX', 0);
    FbtnMax.Hint := '最大化';
  end
  else
  begin
    ShowWindow(Handle, SW_SHOWMAXIMIZED);
    LoadButtonBmp(FbtnMax, 'Restore', 0);
    FbtnMax.Hint := '还原';
  end;
end;

procedure TUIBaseForm.OnMinClick(Sender: TObject);
begin
  ShowWindow(Handle, SW_SHOWMINIMIZED);
end;

procedure TUIBaseForm.pnlDBLClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
  begin
    ShowWindow(Handle, SW_SHOWNORMAL);
    LoadButtonBmp(FbtnMax, 'MAX', 0);
    FbtnMax.Hint := '最大化';
  end
  else
  begin
    ShowWindow(Handle, SW_SHOWMAXIMIZED);
    LoadButtonBmp(FbtnMax, 'Restore', 0);
    FbtnMax.Hint := '还原';
  end;
end;

procedure TUIBaseForm.pnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  MouseDown(Button, Shift, X, Y);
end;

procedure TUIBaseForm.pnlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  MouseMove(Shift, X, Y);
end;

procedure TUIBaseForm.pnlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  MouseUp(Button, Shift, X, Y);
end;

procedure TUIBaseForm.SetCloseToTray(const Value: Boolean);
begin
  FbCloseToTray := Value;
end;

procedure TUIBaseForm.SetMulScreenPos(const Value: Boolean);
begin
  FMulScreenPos := Value;

  { 多显示屏时，显示在第二个显示器上 }
  if (FMulScreenPos) and (Screen.MonitorCount > 1) then
  begin
    MakeFullyVisible(Screen.Monitors[1]);
    Top  := (Screen.Monitors[1].Height - Height) div 2;
    Left := Screen.Monitors[1].Left + (Screen.Monitors[1].Width - Width) div 2;
  end
  else
  begin
    Position := poScreenCenter;
  end;
end;

procedure TUIBaseForm.SetTitleString(const Value: string);
begin
  FTitleString      := Value;
  Caption           := FTitleString;
  Application.Title := FTitleString;
  FpnlTitle.Caption := FTitleString;
end;

procedure TUIBaseForm.SetTrayIconPMenu(const Value: TPopupMenu);
begin
  FTrayIconPMenu := Value;
  if Assigned(TrayIconPMenu) then
  begin
    FTrayIcon.PopupMenu := TrayIconPMenu;
  end;
end;

procedure TUIBaseForm.TrayIconDblClick(Sender: TObject);
begin
  if not Visible then
    Show;

  if WindowState = wsMinimized then
    ShowWindow(Handle, SW_RESTORE);
end;

end.
