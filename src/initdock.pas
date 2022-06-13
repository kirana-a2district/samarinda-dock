unit initdock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, MainDock;

type

  { TfrInit }

  TfrInit = class(TForm)
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

end.

