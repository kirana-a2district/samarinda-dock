unit initdock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, UniqueInstance,
  MainDock, DockLauncher;

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
begin
  frDock.Show;
  Hide;
end;

procedure TfrInit.DockAppDeactivate(Sender: TObject);
begin
  frDock.btLaunch.StateNormal.Background.ColorOpacity := 0;
  frLauncher.Close;
end;

end.

