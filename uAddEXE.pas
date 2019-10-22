unit uAddEXE;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.IniFiles,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfrmAddEXE = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowAddEXEForm(const strPModuleName: String; var iniFile: TMemIniFile);

implementation

{$R *.dfm}

procedure ShowAddEXEForm(const strPModuleName: String; var iniFile: TMemIniFile);
begin
  with TfrmAddEXE.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;

end.
