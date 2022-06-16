unit MainDock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, LCLIntf,
  ExtCtrls, BCPanel, BCButton, BCListBox, qt5, qtwidgets, WindowListUtils,
  x, xwindowlist, BGRABitmap, DockLauncher;

type


  // to-do: grab active window information
  TDockWindow = class(TWindowData)
  public
    DockButton: TBCButton;
    procedure DockButtonClick(Sender: TObject);
    constructor Create(AXWindowList: TXWindowList; AWindow: TWindow); override;
    destructor Destroy; override;
  end;

  { TfrDock }

  TfrDock = class(TForm)
    btLaunch: TBCButton;
    pnDock: TBCPanel;
    pnContainer: TPanel;
    Timer1: TTimer;
    procedure btLaunchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnDockResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    WindowList: TWindowList;
    mouseHandled: boolean;
    mouseX: integer;
    mouseY: integer;
    formX: integer;
    formY: integer;
    //procedure WMWindowPosChanged(var Message: TLMWindowPosChanged); message
    //  LM_CHECKRESIZE;
  public

  end;

var
  frDock: TfrDock;

implementation

{$R *.lfm}

constructor TDockWindow.Create(AXWindowList: TXWindowList; AWindow: TWindow);
var
  bmp: TBGRABitmap;
begin
  inherited Create(AXWindowList, AWindow);
  DockButton := TBCButton.Create(frDock);
  DockButton.AutoSize := False;
  DockButton.Parent := frDock.pnDock;
  DockButton.Constraints.MinWidth := frDock.btLaunch.Height;
  DockButton.OnClick := @DockButtonClick;
  DockButton.ShowHint := True;
  DockButton.Hint := Name;
  DockButton.BorderSpacing.Around := 5;

  DockButton.Assign(frDock.btLaunch);
  bmp := GetIcon;
  if Assigned(bmp) then
    DockButton.Glyph.Assign(bmp.Bitmap);

  bmp.Free;
end;

destructor TDockWindow.Destroy;
begin
  FreeAndNil(DockButton);
  inherited Destroy;
end;

procedure TDockWindow.DockButtonClick(Sender: TObject);
begin
  frDock.Timer1.Enabled := False;
  //frDock.Focused := False;
  //ShowMessage(currentItem.SubItems[0]);
  if State = 'Iconic' then
  begin
    ActivateWindow;
  end
  else
  begin
    if Self = frDock.WindowList[frDock.WindowList.ActiveIndex] then
      MinimizeWindow
    else
      ActivateWindow;
      //MaximizeWindow;
  end;
  frDock.WindowList.UpdateDataList;
  frDock.Timer1.Enabled := true;
end;

{ TfrDock }

procedure TfrDock.FormCreate(Sender: TObject);
begin
  mouseHandled:=false;
  WindowList := TWindowList.Create(TDockWindow);
  //QWidget_setVisible(TQtMainWindow(Self.Handle).GetContainerWidget, false);
  //TQtWidget(pnDock.Handle).setParent(TQtMainWindow(Self.Handle).Widget);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  pnContainer.Align:=alClient;
  {$ifdef LCLQT5}
    Caption:= 'qt5';
  {$endif}
end;

procedure TfrDock.Button1Click(Sender: TObject);
begin

end;

procedure TfrDock.pnDockResize(Sender: TObject);
begin
  Top := Screen.Height - Height;
  Left := (Screen.Width div 2) - (Width div 2);
end;

procedure TfrDock.FormDestroy(Sender: TObject);
begin
  FreeAndNil(WindowList);
end;

procedure TfrDock.btLaunchClick(Sender: TObject);
begin
  if frLauncher.Visible then
  begin
    frLauncher.Close;
    btLaunch.StateNormal.Background.ColorOpacity := 0;
  end
  else
  begin
    frLauncher.Show;
    btLaunch.StateNormal.Background.ColorOpacity := 20;
    //frLauncher.SetFocus;
  end;
  //WindowList.UpdateDataList;
  //pnDock.Caption := WindowList.Count.ToString;
end;

procedure TfrDock.FormActivate(Sender: TObject);
begin
  //if frLauncher.Visible then
  //begin
  //  frLauncher.Visible := false;
  //end;
  //  frLauncher.Close;
end;

procedure TfrDock.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Timer1.Enabled := False;
  Application.Terminate;
end;

procedure TfrDock.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TfrDock.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

begin

end;

procedure TfrDock.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TfrDock.FormResize(Sender: TObject);
begin
  pnContainer.Height:=Height;
  pnContainer.Width:=Width;

end;

//procedure TfrDock.WMWindowPosChanged(var Message: TLMWindowPosChanged);
//begin
//  Caption := IntToStr(StrToInt(Caption)+ 1);
//end;

procedure TfrDock.FormShow(Sender: TObject);
var
  rgn: HRGN;
  rgnn: TRegion;
begin
  Timer1.Enabled := True;
  //rgn := CreateRoundRectRgn(
  //  0,
  //  1,
  //  ClientWidth,
  //  ClientHeight,
  //  10,
  //  10
  //);
  //SetWindowRgn(Handle, rgn, true);
  //rgnn.Handle:=rgn;
  AutoSize := True;
  btLaunch.Width := btLaunch.Height;
  Top := Screen.WorkAreaHeight - Height;
  Left := (Screen.WorkAreaWidth div 2) - (Width div 2);

  //Form2.Parent := pnDock;
  //Form2.Show;
  //Form2.Align:=alClient;
  //SetShape(rgnn);
  //WindowList.UpdateDataList;
end;

procedure TfrDock.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseX:= x;
  mouseY:= Y;
  formX := Left;
  formY := Top;
  //mouseHandled:=true;
end;

procedure TfrDock.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  currentX: integer;
  currentY: integer;
begin
  currentX := mouseX - formX;
  currentY := mouseY - mouseY;
  if mouseHandled then
  begin
    //Top := Mouse.CursorPos.Y - mouseY;
    //Left := Mouse.CursorPos.X - mouseX;
    SetBounds(Mouse.CursorPos.X - mouseX, Mouse.CursorPos.Y - mouseY, Width, Height);
    //message
  end;


end;

procedure TfrDock.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseHandled:=false;
end;

procedure TfrDock.Timer1Timer(Sender: TObject);
begin
  WindowList.UpdateDataList;
end;

end.

