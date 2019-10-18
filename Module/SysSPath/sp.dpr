library sp;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  untSysSearch in 'untSysSearch.pas' {frmSysSearch};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin
end.
