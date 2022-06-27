unit DockSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IniFiles;

type

  { TfrDockSettings }

  TfrDockSettings = class(TForm)
    btApply: TButton;
    cbAutoHide: TCheckBox;
    procedure btApplyClick(Sender: TObject);
    procedure cbAutoHideChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frDockSettings: TfrDockSettings;

implementation
uses
  DockLauncher, MainDock;

{$R *.lfm}

{ TfrDockSettings }

procedure TfrDockSettings.cbAutoHideChange(Sender: TObject);
begin
  btApply.Enabled := True;
end;

procedure TfrDockSettings.FormShow(Sender: TObject);
begin
  if frDock.DockMode = 'autohide' then
    cbAutoHide.Checked := True
  else
    cbAutoHide.Checked := False;
end;

procedure TfrDockSettings.btApplyClick(Sender: TObject);
var
  cfg: TIniFile;
begin
  cfg := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'dock.cfg');
  if cbAutoHide.Checked then
    cfg.WriteString('Dock', 'mode', 'autohide')
  else
    cfg.WriteString('Dock', 'mode', 'normal');
  cfg.Free;
  StartDetachedProgram(Application.ExeName);
  Application.Terminate;
end;

end.

