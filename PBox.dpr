program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Vcl.Forms,
  uBaseForm in 'uBaseForm.pas',
  uCommon in 'uCommon.pas',
  uCreateVCDialogDll in 'uCreateVCDialogDll.pas',
  uCreateDelphiDll in 'uCreateDelphiDll.pas',
  uCreateEXE in 'uCreateEXE.pas',
  uPBoxForm in 'uPBoxForm.pas' {frmPBox} ,
  uConfigForm in 'uConfigForm.pas' {frmConfig} ,
  uDBConfig in 'uDBConfig.pas' {DBConfig} ,
  uAddEXE in 'uAddEXE.pas' {frmAddEXE};

{$R *.res}

begin
  OnlyOneRunInstance;
  UpdateDataBaseScript;
  Application.Initialize;
  ReportMemoryLeaksOnShutdown   := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPBox, frmPBox);
  Application.Run;

end.
