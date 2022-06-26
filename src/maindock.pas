unit MainDock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LCLType, LCLIntf,
  ExtCtrls, BCPanel, BCButton, BCListBox, qt5, qtwidgets, KiranaWindows,
  x, XWindowUtils, BGRABitmap, DockLauncher, Menus, BCTypes, xatom, xlib, ctypes;

type


  // to-do: grab active window information
  TDockWindow = class(TWindowData)
  public
    DockButton: TBCButton;
    DockPopup: TPopupMenu;
    procedure DockButtonClick(Sender: TObject);
    constructor Create(AXWindowList: TXWindowManager; AWindow: TWindow); override;
    procedure DoActiveChange(IsActive: boolean); override;
    procedure DockMaximizeWindow(Sender: TObject);
    procedure DockMinimizeWindow(Sender: TObject);
    procedure DockCloseWindow(Sender: TObject);
    destructor Destroy; override;
  end;

  { TfrDock }

  TfrDock = class(TForm)
    btLaunch: TBCButton;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Separator1: TMenuItem;
    pnDock: TPanel;
    pnCol: TBCPanel;
    pnContainer: TPanel;
    mnDock: TPopupMenu;
    Timer1: TTimer;
    procedure btLaunchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure pnColResize(Sender: TObject);
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
    procedure pnContainerResize(Sender: TObject);
    procedure pnDockClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ffff: Integer;
    mouseHandled: boolean;
    mouseX: integer;
    mouseY: integer;
    formX: integer;
    formY: integer;

  public
    WindowList: TWindowList;
    procedure RePosition;
  end;

var
  frDock: TfrDock;

implementation
uses initdock;
{$R *.lfm}

constructor TDockWindow.Create(AXWindowList: TXWindowManager; AWindow: TWindow);
var
  bmp: TBGRABitmap;
  Item: TMenuItem;
begin
  inherited Create(AXWindowList, AWindow);

  //frDock.pnDock.AutoSize := False;
  DockButton := TBCButton.Create(nil);
  DockButton.AutoSize := False;
  DockButton.Parent := frDock.pnDock;
  DockButton.Constraints.MinWidth := frDock.btLaunch.Height;
  DockButton.StateNormal.Background.ColorOpacity := 0;
  DockButton.StateNormal.Background.Color := clBlue;
  DockButton.OnClick := @DockButtonClick;
  DockButton.ShowHint := True;
  DockButton.Hint := Name + ' (' + ExtractFileName(Command) + ')';
  DockButton.BorderSpacing.Around := 5;

  DockPopup := TPopupMenu.Create(nil);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := 'New Window';
  //Item.OnClick := @DockMaximizeWindow;
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := 'Recent Files';
  //Item.OnClick := @DockMaximizeWindow;
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := '-';
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := 'Maximize/Restore';
  Item.OnClick := @DockMaximizeWindow;
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := 'Minimize';
  Item.OnClick := @DockMinimizeWindow;
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := '-';
  DockPopup.Items.Add(Item);

  Item := TMenuItem.Create(DockPopup);
  Item.Caption := 'Close';
  Item.OnClick := @DockCloseWindow;
  DockPopup.Items.Add(Item);

  DockButton.Assign(frDock.btLaunch);
  bmp := GetIcon;
  if Assigned(bmp) then
    DockButton.Glyph.Assign(bmp.Bitmap)
  else
    DockButton.Glyph.Assign(frLauncher.btLaunch.Glyph);
  DockButton.PopupMenu := DockPopup;
  bmp.Free;
  { forget about IconGeometry, no idea how it works. Just causing fullscreen glitch }
  //SetIconGeometry(frDock.Top,
  //  frDock.Left, DockButton.Width, DockButton.Height);
  // LCL's autosize doesn't work properly?
  frDock.Constraints.MinWidth := frDock.pnContainer.Width;
  frDock.RePosition;
end;

destructor TDockWindow.Destroy;
begin
  // LCL's autosize doesn't work properly?
  FreeAndNil(DockPopup);
  FreeAndNil(DockButton);
  frDock.RePosition;
  inherited Destroy;
end;

procedure TDockWindow.DoActiveChange(IsActive: boolean);
begin
  if IsActive and (State <> 'Iconic') then
    DockButton.StateNormal.Background.ColorOpacity := 50
  else
    DockButton.StateNormal.Background.ColorOpacity := 0;


end;

procedure TDockWindow.DockMaximizeWindow(Sender: TObject);
begin
  MaximizeWindow;
end;

procedure TDockWindow.DockMinimizeWindow(Sender: TObject);
begin

  if State = 'Iconic' then
    ActivateWindow
  else
    MinimizeWindow;
end;

procedure TDockWindow.DockCloseWindow(Sender: TObject);
begin
  CloseWindow;
end;

procedure TDockWindow.DockButtonClick(Sender: TObject);
begin
  // Do not do anything if TDockWindow is gone
  if Assigned(Sender) then
  begin
    frDock.WindowList.PauseUpdate;
    if State = 'Iconic' then
    begin
      ActivateWindow;
    end
    else
    begin
      if Self = frDock.WindowList[frDock.WindowList.ActiveIndex] then
      begin
        MinimizeWindow
      end
      else
      begin
        ActivateWindow;
      end;
        //MaximizeWindow;
    end;

    frDock.WindowList.ResumeUpdate;
  end;
end;

{ TfrDock }

procedure TfrDock.FormCreate(Sender: TObject);
begin
  //AutoSize := True;
  ffff := 0;
  //QWidget_setVisible(TQtMainWindow(Self.Handle).GetContainerWidget, false);
  //TQtWidget(pnCol.Handle).setParent(TQtMainWindow(Self.Handle).Widget);

  QWidget_setAttribute(TQtMainWindow(Self.Handle).Widget, QtWA_TranslucentBackground);
  QWidget_setAttribute(TQtMainWindow(Self.Handle).GetContainerWidget, QtWA_TranslucentBackground);
  //pnContainer.Align:=alClient;
  {$ifdef LCLQT5}
    Caption:= 'Samarinda Dock';
  {$endif}

  FormStyle := fsStayOnTop;
end;

procedure TfrDock.Button1Click(Sender: TObject);
begin

end;

procedure TfrDock.pnColResize(Sender: TObject);
begin

end;

procedure TfrDock.FormDestroy(Sender: TObject);
begin
  FreeAndNil(WindowList);
end;

procedure TfrDock.MenuItem3Click(Sender: TObject);
begin
  if MessageDlg('Confirmation',
    'This action will destroy Samarinda Dock process.'
    +#10'Are you sure still want to proceed?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes
  then Application.Terminate;
end;

procedure TfrDock.btLaunchClick(Sender: TObject);
begin
  //frLauncher.Panel1.Caption :=
  //
  //QWidget_winId(TQtMainWindow(Self.Handle).Widget).ToString;
  //WindowList.XWindowListData.SetDockedMode(QWidget_winId(TQtMainWindow(Self.Handle).Widget));
  if frLauncher.Visible then
  begin
    frLauncher.Close;
    btLaunch.StateNormal.Background.ColorOpacity := 0;
  end
  else
  begin
    frLauncher.Show;
    btLaunch.StateNormal.Background.ColorOpacity := 50;
    //frLauncher.SetFocus;
  end;
  //WindowList.UpdateDataList;
  //pnCol.Caption := WindowList.Count.ToString;
end;

procedure TfrDock.FormActivate(Sender: TObject);
begin

end;

procedure TfrDock.FormChangeBounds(Sender: TObject);
begin



  //XMoveWindow(WindowList.XWindowListData.Display, QWidget_winId(
  //  TQtMainWindow(Self.Handle).Widget), (Screen.Width div 2) -
  //  (Width div 2), Screen.Height - Height);
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
  {broken}
  //RePosition;
  //ffff += 1;
  //frLauncher.Panel1.Caption := Top.ToString + '; ' + Left.ToString + ': ' + ffff.ToString;
end;

//procedure TfrDock.WMWindowPosChanged(var Message: TLMWindowPosChanged);
//begin
//  Caption := IntToStr(StrToInt(Caption)+ 1);
//end;

procedure TfrDock.FormShow(Sender: TObject);
var
  rgn: HRGN;
  rgnn: TRegion;
  SelfWindow: TWindow;
begin
  mouseHandled:=false;

  SelfWindow := QWidget_winId(TQtMainWindow(Self.Handle).Widget);
  Self.FormStyle := fsSystemStayOnTop;



  btLaunch.Constraints.MinWidth := btLaunch.Height;
  RePosition;

  Self.ShowInTaskBar := stNever;
  if not Assigned(WindowList) then
  begin
    WindowList := TWindowList.Create(TDockWindow);
    ExcludeWindow := SelfWindow;
    WindowList.XWindowListData.SetDockedMode(SelfWindow);
    WindowList.XWindowListData.SetStrut(SelfWindow, Width, Height, 1);
    WindowList.XWindowListData.ActivateWindow(SelfWindow);
  end;
end;

procedure TfrDock.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouseX:= x;
  mouseY:= Y;
  formX := Left;
  formY := Top;
  mouseHandled:=true;
  //btLaunchClick(self);
  //Top := Top - 10;
  //XMoveWindow(WindowList.XWindowListData.Display,
  //QWidget_winId(TQtMainWindow(Self.Handle).Widget), Left, Top+10);
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

procedure TfrDock.pnContainerResize(Sender: TObject);
begin

end;

procedure TfrDock.pnDockClick(Sender: TObject);
begin

end;

procedure TfrDock.Timer1Timer(Sender: TObject);
begin
  WindowList.UpdateDataList;
end;

procedure TfrDock.RePosition;
var
  SelfWindow: TWindow;
begin
  SelfWindow := QWidget_winId(TQtMainWindow(Self.Handle).Widget);
  Top := Screen.Height - Height;
  Left := (Screen.Width div 2) - (pnContainer.Width div 2);
  Width := pnContainer.Width;
end;

end.
