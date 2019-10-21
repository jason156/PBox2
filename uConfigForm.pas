unit uConfigForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Buttons;

type
  TfrmConfig = class(TForm)
    lbl2: TLabel;
    lbl3: TLabel;
    lbl1: TLabel;
    btnDatabaseConfig: TSpeedButton;
    grpUI: TGroupBox;
    lblTitle: TLabel;
    edtTitle: TEdit;
    chkShowTwoScreen: TCheckBox;
    chkTopForm: TCheckBox;
    chkCloseMini: TCheckBox;
    srchbxBackImage: TSearchBox;
    chkBackImage: TCheckBox;
    chkAutorun: TCheckBox;
    chkOnlyOneInstance: TCheckBox;
    btnSave: TButton;
    btnCancel: TButton;
    rgShowStyle: TRadioGroup;
    grpModuleSort: TGroupBox;
    imgPModuleIcon: TImage;
    imgSModuleIcon: TImage;
    lblPModule: TLabel;
    lblSModule: TLabel;
    lstParentModule: TListBox;
    lstSubModule: TListBox;
    btnParentUp: TButton;
    btnParentDown: TButton;
    btnSubUp: TButton;
    btnSubDown: TButton;
    btnSubModuleIcon: TButton;
    chkGray: TCheckBox;
    btnPModuleIcon: TButton;
    chkShowCloseButton: TCheckBox;
    chkFullScreen: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDatabaseConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FmemIni      : TMemIniFile;
    FlstModuleAll: THashedStringList;
    procedure ReadConfigFillUI;
  public
    { Public declarations }
  end;

function ShowConfigForm(var lstModuleAll: THashedStringList): Boolean;

implementation

uses uDBConfig;

{$R *.dfm}

function ShowConfigForm(var lstModuleAll: THashedStringList): Boolean;
begin
  Result := True;
  with TfrmConfig.Create(nil) do
  begin
    FlstModuleAll := lstModuleAll;
    ReadConfigFillUI;
    ShowModal;
    Free;
  end;
end;

procedure TfrmConfig.btnDatabaseConfigClick(Sender: TObject);
begin
  ShowDBConfigForm(FmemIni);
end;

procedure TfrmConfig.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfig.btnSaveClick(Sender: TObject);
begin
  FmemIni.UpdateFile;
  Close;
end;

procedure TfrmConfig.FormShow(Sender: TObject);
begin
  FmemIni := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
end;

procedure TfrmConfig.ReadConfigFillUI;
begin
  //
end;

procedure TfrmConfig.FormDestroy(Sender: TObject);
begin
  FmemIni.Free;
end;

end.
