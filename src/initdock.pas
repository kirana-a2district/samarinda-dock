unit initdock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, UniqueInstance,
  MainDock, DockLauncher, IniFiles;

type

  { TfrInit }

  TfrInit = class(TForm)
    DockApp: TApplicationProperties;
    UniqueInstance1: TUniqueInstance;
    procedure DockAppDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frInit: TfrInit;

implementation

{$R *.lfm}

{ TfrInit }

procedure TfrInit.FormShow(Sender: TObject);
var
  cfg: TIniFile;
begin
  cfg := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'dock.cfg');
  frDock.DockMode := cfg.ReadString('Dock', 'mode', 'normal');
  cfg.Free;
  Hide;
  Sleep(1000);
  frDock.Show;
  if frDock.DockMode <> 'normal' then
    frDock.tmrAutoHide.Enabled := True;
end;

procedure TfrInit.DockAppDeactivate(Sender: TObject);
begin
  frDock.btLaunch.StateNormal.Background.ColorOpacity := 0;
  frLauncher.Close;
end;

end.

