unit DockLauncher;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BCPanel, BCButton, BGRASVGImageList, BGRAImageList, qt5, qtwidgets,
  BGRAClasses, SystemAppMonitor, BCTypes, fgl;

type

  TBCButtonList = specialize TFPGObjectList<TBCButton>;

  { TfrLauncher }

  TfrLauncher = class(TForm)
    btLaunch: TBCButton;
    imglist: TBGRAImageList;
    ScrollBox1: TScrollBox;
    svglist: TBGRASVGImageList;
    btLaunchHelper: TBCButton;
    Panel1: TPanel;
    pnLauncher: TBCPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    StartRefresh: boolean;
    AppMon: TSystemAppMonitor;
    BCButtons: TBCButtonList;
    procedure AppMonRefreshed(Sender: TObject);
  public

  end;

var
  frLauncher: TfrLauncher;

implementation
uses MainDock;

{$R *.lfm}

{ TfrLauncher }

procedure TfrLauncher.AppMonRefreshed(Sender: TObject);
var
  i: integer;
  btn: TBCButton;
begin
  if Visible then
  begin
    BCButtons.Clear;
    for i := 0 to AppMon.Items.Count -1 do
    begin
      btn := TBCButton.Create(nil);
      btn.Assign(btLaunch);
      btn.Parent := ScrollBox1;
      btn.Visible := True;
      btn.GlyphAlignment := bcaCenterTop;
      btn.GlyphOldPlacement := false;
      btn.Constraints.MinWidth := btLaunch.Width;
      btn.Constraints.MinHeight := btLaunch.Height;
      btn.Constraints.MaxWidth := btLaunch.Width;
      btn.Caption := AppMon.Items[i].Name;
      //if FileExists(AppMon.Items[i].IconName) then
        btn.Glyph.Assign(btLaunch.Glyph);
      btn.BorderSpacing.Around := btLaunch.BorderSpacing.Around;
      BCButtons.Add(btn);
    end;
  end;
end;

procedure TfrLauncher.FormDeactivate(Sender: TObject);
begin

end;

procedure TfrLauncher.FormDestroy(Sender: TObject);
begin
  AppMon.Free;
  BCButtons.Free;
end;

procedure TfrLauncher.FormResize(Sender: TObject);
begin
  ScrollBox1.ChildSizing.ControlsPerLine := ScrollBox1.Width div
    (btLaunch.Width + (btLaunch.BorderSpacing.Around));
end;

procedure TfrLauncher.FormActivate(Sender: TObject);
begin

end;

procedure TfrLauncher.FormCreate(Sender: TObject);
begin
  StartRefresh := False;
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  svglist.PopulateImageList(imglist, [btLaunchHelper.Glyph.Height]);
  imglist.GetBitmap(1, frDock.btLaunch.Glyph);
  AppMon := TSystemAppMonitor.Create(self);
  AppMon.OnRefreshed := @AppMonRefreshed;
  BCButtons := TBCButtonList.Create;
end;



procedure TfrLauncher.FormShow(Sender: TObject);
begin
  Top := frDock.Top - Height - 10;
  Left := (frDock.Left + (frDock.btLaunch.Width div 2)) - (Width div 2);
  imglist.GetBitmap(0, btLaunchHelper.Glyph);
  if not StartRefresh then
  begin
    AppMon.Refresh(Self);
    StartRefresh := True;
  end;
end;

end.

