unit uCreateDelphiDll;
{
  创建 Delphi DLL窗体
}

interface

uses Vcl.Forms, Winapi.Windows, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, uCommon;

procedure PBoxRun_DelphiDll(var DllForm: TForm; Page: TPageControl; tsDllForm: TTabSheet; OnDelphiDllFormClose: TCloseEvent);

implementation

procedure PBoxRun_DelphiDll(var DllForm: TForm; Page: TPageControl; tsDllForm: TTabSheet; OnDelphiDllFormClose: TCloseEvent);
var
  hDll                             : HMODULE;
  ShowDllForm                      : TShowDllForm;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
  ft                               : TSPFileType;
begin
  hDll        := LoadLibrary(PChar(g_strCreateDllFileName));
  ShowDllForm := GetProcAddress(hDll, c_strDllExportName);
  ShowDllForm(frm, ft, strParamModuleName, strModuleName, strClassName, strWindowName, strIconFileName, False);
  DllForm             := frm.Create(nil);
  DllForm.BorderIcons := [biSystemMenu];
  DllForm.Position    := poDesigned;
  DllForm.Caption     := string(strModuleName);
  DllForm.BorderStyle := bsDialog;
  DllForm.Color       := clWhite;
  DllForm.Anchors     := [akLeft, akTop, akRight, akBottom];
  DllForm.Tag         := hDll;
  DllForm.OnClose     := OnDelphiDllFormClose;                                                                             // 将 hDll 放在 DllForm 的 tag 中，卸载时需要用到
  SetWindowPos(DllForm.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(DllForm.Handle, tsDllForm.Handle);                                                              // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除移动菜单
  DllForm.Show;                                                                                                            // 显示 Dll 子窗体
  Page.ActivePage := tsDllForm;
end;

end.
