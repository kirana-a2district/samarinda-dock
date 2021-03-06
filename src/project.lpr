program project;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, initdock, MainDock, DockLauncher, DockSettings
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrInit, frInit);
  Application.CreateForm(TfrDock, frDock);
  Application.CreateForm(TfrLauncher, frLauncher);
  Application.CreateForm(TfrDockSettings, frDockSettings);
  Application.Run;
end.

