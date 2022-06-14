unit initdock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, MainDock, DockLauncher;

type

  { TfrInit }

  TfrInit = class(TForm)
    DockApp: TApplicationProperties;
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
  frLauncher.Close;
end;

end.

