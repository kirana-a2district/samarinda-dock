unit DockLauncher;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BCPanel, BCButton, BGRASVGImageList, BGRAImageList, qt5, qtwidgets,
  BGRAClasses;

type

  { TfrLauncher }

  TfrLauncher = class(TForm)
    imglist: TBGRAImageList;
    svglist: TBGRASVGImageList;
    btLaunch: TBCButton;
    Panel1: TPanel;
    pnLauncher: TBCPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frLauncher: TfrLauncher;

implementation
uses MainDock;

{$R *.lfm}

{ TfrLauncher }

procedure TfrLauncher.FormDeactivate(Sender: TObject);
begin

end;

procedure TfrLauncher.FormActivate(Sender: TObject);
begin

end;

procedure TfrLauncher.FormCreate(Sender: TObject);
begin
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  svglist.PopulateImageList(imglist, [btLaunch.Glyph.Height]);
end;



procedure TfrLauncher.FormShow(Sender: TObject);
begin
  Top := frDock.Top - Height - 10;
  Left := (frDock.Left + (frDock.btLaunch.Width div 2)) - (Width div 2);
  imglist.GetBitmap(0, btLaunch.Glyph);

end;

end.

