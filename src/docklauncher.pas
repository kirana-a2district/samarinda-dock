unit DockLauncher;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BCPanel, BCButton, BGRASVGImageList, BGRAImageList, qt5, qtwidgets,
  BGRAClasses, SystemAppMonitor, BCTypes, fgl, process, BGRABitmap, BGRASVG,
  IniFiles;

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
    procedure ScrollBox1MouseEnter(Sender: TObject);
    procedure ScrollBox1MouseLeave(Sender: TObject);
  private
    StartRefresh: boolean;
    AppMon: TSystemAppMonitor;
    BCButtons: TBCButtonList;
    procedure OpenApp(Sender: TObject);
    procedure AppMonRefreshed(Sender: TObject);
  public

  end;

var
  frLauncher: TfrLauncher;

implementation
uses MainDock;

{$R *.lfm}

{ TfrLauncher }

function ReadKDEConfig: string;
var
  cfg: TIniFile;
begin
  Result := '';
  //ShowMessage(GetEnvironmentVariable('HOME')+'/.kde/share/config/kdeglobals');
  if FileExists(GetEnvironmentVariable('HOME')+'/.kde/share/config/kdeglobals') then
  begin
    //ShowMessage(GetEnvironmentVariable('HOME')+'/.kde/share/config/kdeglobals');
    cfg := TIniFile.Create(GetEnvironmentVariable('HOME')+'/.kde/share/config/kdeglobals');
    Result := cfg.ReadString('Icons', 'Theme', '');
    cfg.Free;
  end;
end;

function ReadBitmapName(name: string): TBGRABitmap;
var
  bmp, bmpsc: TBGRABitmap;
  bsvg: TBGRASVG;
  paths: TStrings;
  i: integer;
begin
  paths := TStringList.Create;
  Result := nil;
  if ReadKDEConfig <> '' then
  begin
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/64/');
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/48/');
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/32/');
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/24/');
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/22/');
    paths.Add('/usr/share/icons/'+ReadKDEConfig+'/apps/16/');
  end;
  paths.Add('/usr/share/pixmaps/');
  paths.Add('/usr/share/icons/hicolor/256x256/apps/');
  paths.Add('/usr/share/icons/hicolor/192x192/apps/');
  paths.Add('/usr/share/icons/hicolor/128x128/apps/');
  paths.Add('/usr/share/icons/hicolor/96x96/apps/');
  paths.Add('/usr/share/icons/hicolor/72x72/apps/');
  paths.Add('/usr/share/icons/hicolor/64x64/apps/');
  paths.Add('/usr/share/icons/hicolor/48x48/apps/');
  paths.Add('/usr/share/icons/hicolor/36x36/apps/');
  paths.Add('/usr/share/icons/hicolor/32x32/apps/');
  paths.Add('/usr/share/icons/hicolor/24x24/apps/');
  paths.Add('/usr/share/icons/hicolor/22x22/apps/');
  paths.Add('/usr/share/icons/hicolor/16x16/apps/');
  for i := 0 to paths.Count -1 do
  begin
    if FileExists(paths[i] + name +'.png') then
    begin
      if paths[i].Contains('64x64') then
      begin
        bmp := TBGRABitmap.Create(paths[i] + name +'.png');
        Result := bmp;
      end
      else
      begin
        bmp := TBGRABitmap.Create(paths[i] + name +'.png');
        bmpsc := bmp.Resample(64, 64);
        Result := bmpsc;
        bmp.Free;
      end;
      Break;
    end
    else if FileExists(paths[i] + name +'.svg') then
    begin
      { can't read kwrite svg }
      if name = 'kwrite' then
        Break;
      if paths[i].Contains('64') then
      begin
        bsvg := TBGRASVG.Create;
        bsvg.LoadFromFile(paths[i] + name +'.svg');
        bmp := TBGRABitmap.Create(64, 64);
        bsvg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0, 0,
          bmp.Width, bmp.Height);
        bsvg.Free;
        Result := bmp;
      end
      else if paths[i].Contains('48') then
      begin
        bsvg := TBGRASVG.Create;
        bsvg.LoadFromFile(paths[i] + name +'.svg');
        bmp := TBGRABitmap.Create(48, 48);
        bsvg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0, 0,
          bmp.Width, bmp.Height);
        bsvg.Free;
        bmpsc := bmp.Resample(64, 64);
        Result := bmpsc;
        bmp.Free;
      end
      else if paths[i].Contains('32') then
      begin
        bsvg := TBGRASVG.Create;
        bsvg.LoadFromFile(paths[i] + name +'.svg');
        bmp := TBGRABitmap.Create(32, 32);
        bsvg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0, 0,
          bmp.Width, bmp.Height);
        bsvg.Free;
        bmpsc := bmp.Resample(64, 64);
        Result := bmpsc;
        bmp.Free;
      end;
      Break;
    end;
  end;

  paths.Free;
end;

procedure TfrLauncher.AppMonRefreshed(Sender: TObject);
var
  i: integer;
  btn: TBCButton;
  bmp: TBGRABitmap;
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
        //btn.Glyph.Assign(btLaunch.Glyph);
      bmp := ReadBitmapName(AppMon.Items[i].IconName);
      if bmp <> nil then
      begin
        btn.Glyph.Assign(bmp.Bitmap);
        bmp.Free;
      end
      else
        btn.Glyph.Assign(btLaunch.Glyph);
      btn.BorderSpacing.Around := btLaunch.BorderSpacing.Around;
      btn.OnClick := @OpenApp;
      BCButtons.Add(btn);
    end;
  end;
end;

procedure StartDetachedProgram(cmd: string);
var
  Process: TProcess;
  I: Integer;
begin
  Process := TProcess.Create(nil);
  try
    Process.InheritHandles := False;
    Process.Options := [];
    Process.ShowWindow := swoShow;

    // Copy default environment variables including DISPLAY variable for GUI application to work
    for I := 1 to GetEnvironmentVariableCount do
    begin
      Process.Environment.Add(GetEnvironmentString(I));
    end;

    Process.CommandLine := cmd;
    Process.Execute;
  finally
    Process.Free;
  end;
end;

procedure TfrLauncher.OpenApp(Sender: TObject);
var
  i: integer;
  argres: string;
begin
  frDock.WindowList.PauseUpdate;
  for i := 0 to BCButtons.Count -1 do
  begin
    if TBCButton(Sender) = BCButtons[i] then
    begin
      StartDetachedProgram(AppMon.Items[i].Exec + ' ' +AppMon.Items[i].ArgStr);
      //AppMon.Items[i].Exec;
    end;
  end;
  Close;
  frDock.WindowList.ResumeUpdate;
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

procedure TfrLauncher.ScrollBox1MouseEnter(Sender: TObject);
begin
  //ScrollBox1.VertScrollBar.Visible := True;
  //ScrollBox1.HorzScrollBar.Visible := True;
end;

procedure TfrLauncher.ScrollBox1MouseLeave(Sender: TObject);
begin
  //ScrollBox1.VertScrollBar.Visible := False;
  //ScrollBox1.HorzScrollBar.Visible := False;
end;

end.

