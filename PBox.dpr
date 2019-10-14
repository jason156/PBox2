program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Vcl.Forms,
  uPBoxForm in 'uPBoxForm.pas' {frmPBox},
  uCommon in 'uCommon.pas';

{$R *.res}

begin
  OnlyOneRunInstance;
  UpdateDataBaseScript;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPBox, frmPBox);
  Application.Run;

end.
