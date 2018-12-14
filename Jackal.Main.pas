unit Jackal.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Types, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Direct2D, D2D1, Vcl.ExtCtrls, Vcl.StdCtrls, System.Generics.Collections,
  System.ImageList, Vcl.ImgList, PngFunctions, PngImageList, pngimage,
  Vcl.Buttons, sSpeedButton, System.Win.ScktComp, IdCustomTCPServer,
  IdTCPServer, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdContext, IdSocketHandle;

const
  FieldSize = 13;
  CellSize = 100;

type
  TFormMain = class;

  TBGType = (bgNone, bgWater, bgTabel);

  TDirect2DCanvasHelper = class helper for TDirect2DCanvas
   procedure FillRect(const Rect: TRect; Opacity:Single); overload;
   function CreateBrush(Bitmap:ID2D1Bitmap):ID2D1Brush; overload;
  end;

  TFieldDataItem = record
   ImageIndex:Integer;
   MayCount:Integer;
   Field:Boolean;
   Addition:Boolean;
  end;
  TFieldData = TList<TFieldDataItem>;

  TAnimateState = (asClosing, asOpenning);

  TSimpleCell = record
   Hole:Boolean;
   FieldData:ShortInt;
   ArrayPos:TPoint;
   Movement:Boolean;
   Open:Boolean;
   function Check(AFormMain:TFormMain):Boolean;
  end;

  TCell = record
   private
    FOpen:Boolean;
    FNeedOpen:Boolean;
    function GetOpen: Boolean;
    procedure SetOpen(const Value: Boolean);
    function GetSimple: TSimpleCell;
    procedure SetSimple(const Value: TSimpleCell);
   public
    Hole:Boolean;
    FieldData:ShortInt;
    ArrayPos:TPoint;
    Movement:Boolean;
    Animate:TAnimateState;
    FAnimate:Boolean;
    FAnimPercent:Integer;
    function DrawRect(Scale:Single):TRect;
    property Open:Boolean read GetOpen write SetOpen;
    property Simple:TSimpleCell read GetSimple write SetSimple;
    procedure Step;
    procedure Clear;
  end;

  TGameCur = record
   private
    FDrag:Boolean;
    procedure SetDrag(const Value: Boolean);
   public
    Down:Boolean;
    OutOf:Boolean;
    Cell:TCell;
    CellDown:TPoint;
    PosDown:TPoint;
    MovingItem:Boolean;
    ItemUnderCursor:Integer;
    FLastPos:TPoint;
    property Drag:Boolean read FDrag write SetDrag;
  end;

  TBitmaps = TList<ID2D1Bitmap>;

  TField = array[1..FieldSize, 1..FieldSize] of TCell;

  TGameItem = record
   public
    ImageIndex:Integer;
    GUID:string[15];
    Position:TPointF;
    Bounds:TRect;
    function Check(AFormMain:TFormMain):Boolean;
    function GetDrawRect(Scale:Single):TRect;
  end;

  TGameItems = TList<TGameItem>;

  TNetHeadType = (nhFullData, nhItemUpdate, nhSwapField, nhOpenCell, nhServerIsFull);

  TNetHead = record
   HeadType:TNetHeadType;
   DataSize:Integer;
  end;

  TNetGame = class
   private
    FOwner:TFormMain;
    FMem:TMemoryStream;
    FGetting:Boolean;
    FGettingHead:TNetHead;
    procedure SendFullInfo(Socket:TCustomWinSocket);
    function SendData(Socket:TCustomWinSocket; Data:TMemoryStream; RepWait:Integer = 3):Boolean;
    procedure ClientReadSocket(Socket: TCustomWinSocket);
    function GetHead(HeadType:TNetHeadType):TNetHead;
   public
    procedure SendSwapCell(Pos1, Pos2:TPoint); overload;
    procedure SendSwapCell(Socket:TCustomWinSocket; Pos1, Pos2:TPoint); overload;
    procedure SendOpenCell(PosCell:TPoint); overload;
    procedure SendOpenCell(Socket:TCustomWinSocket; PosCell:TPoint); overload;
    procedure SendUpdateGItem(Item:Integer); overload;
    procedure SendUpdateGItem(Socket:TCustomWinSocket; Item:Integer); overload;
    procedure SendServerIsFull(Socket:TCustomWinSocket);
    function CreateServer(APort:Integer):Boolean;
    function Connect(IP:string; Port:Integer):Boolean;
    constructor Create(AOwner:TFormMain);
  end;

  TFormMain = class(TForm)
    TimerFPS: TTimer;
    TimerRepaint: TTimer;
    TimerAnimate: TTimer;
    PngImageListItems: TPngImageList;
    TimerCollision: TTimer;
    ImageList1: TImageList;
    ServerSocket: TServerSocket;
    ClientSocket: TClientSocket;
    TimerNet: TTimer;
    PanelClient: TPanel;
    Label1: TLabel;
    PanelMenu: TPanel;
    Bevel1: TBevel;
    EditIP: TEdit;
    EditPort: TEdit;
    Button2: TButton;
    Button1: TButton;
    sSpeedButton1: TButton;
    SpeedButtonContinue: TButton;
    Panel2: TPanel;
    Button4: TButton;
    ListBox1: TListBox;
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    CheckBoxAdd: TCheckBox;
    Panel3: TPanel;
    SpeedButtonBG0: TsSpeedButton;
    SpeedButtonBG2: TsSpeedButton;
    SpeedButtonBG1: TsSpeedButton;
    ImageList2: TImageList;
    RadioButtonBG0: TRadioButton;
    RadioButtonBG1: TRadioButton;
    RadioButtonBG2: TRadioButton;
    LabelEx1: TLabel;
    LabelEx2: TLabel;
    LabelEx3: TLabel;
    PngImageList1: TPngImageList;
    ListBox2: TListBox;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerFPSTimer(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TimerCollisionTimer(Sender: TObject);
    procedure TimerAnimateTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TimerNetTimer(Sender: TObject);
    procedure ServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure sSpeedButton1Click(Sender: TObject);
    procedure SpeedButtonContinueClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure SpeedButtonBG0Click(Sender: TObject);
   protected
    procedure CreateWnd; override;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
   private
    FCanvas:TDirect2DCanvas;
    BGType:TBGType;
    FPSCounter:Integer;
    FFPS:Integer;
    FScale:Single;
    FField:TField;
    FOffset:TPoint;
    FBorders:TRect;
    FSelCell:TPoint;
    FGameCur:TGameCur;
    FGameItems:TGameItems;
    FFieldData:TFieldData;
    FBitmaps:TBitmaps;
    FItemBitmaps:TBitmaps;
    FCoinBox:TGameItem;
    FNetGame:TNetGame;
    FLoading: Boolean;
    Additions:Boolean;
    procedure DoDraw;
    procedure DrawBG;
    procedure DrawField;
    procedure CreateField;
    procedure SetSimple(X, Y:Integer; Value: TSimpleCell);
    function GetCell(X, Y: Integer): TCell;
    procedure SetCell(X, Y: Integer; const Value: TCell);
    procedure SetFieldScale(const Value: Single);
    procedure SetOffset(const Value: TPoint);
    procedure UpdateBorders;
    procedure CenteredOffset;
    procedure ClickToCell(APos:TPoint);
    function PointInField(Pt: TPoint): Boolean;
    procedure FillFieldData;
    procedure DrawItems;
    procedure ResetGameItems;
    function GetInhCanvas: TCanvas;
    procedure OffsetGameItem(DeltaX, DeltaY: Integer);
    procedure NewGame;
    function NearFreeCell(Cell, TargetCheck: TPoint): Boolean;
    procedure ClearField;
    procedure SetLoading(const Value: Boolean);
    procedure UpdatePlayerPanel;
    procedure EndGame;
    procedure UpdateBGType;
   public
    procedure HideCP;
    procedure ShowCP;
    property Offset:TPoint read FOffset write SetOffset;
    property Canvas:TDirect2DCanvas read FCanvas;
    property InhCanvas:TCanvas read GetInhCanvas;
    property FieldScale:Single read FScale write SetFieldScale;
    property Field[X, Y:Integer]:TCell read GetCell write SetCell;
    property NetGame:TNetGame read FNetGame;
    property Loading:Boolean read FLoading write SetLoading;
  end;


const
  ScrollDelta = 0.03;
  MaxClients = 4;
  DefServPort = 27999;

var
  FormMain:TFormMain;
  PNGTabel:ID2D1Bitmap;
  PNGWater:ID2D1Bitmap;
  GUIDValue:Cardinal = 0;


implementation
 uses Math;

{$R *.dfm}

function Random(ARect:TRect):TPoint; overload;
begin
 Result.X:=RandomRange(ARect.Left, ARect.Right);
 Result.Y:=RandomRange(ARect.Top, ARect.Bottom);
end;

function GetGUID(SubName:string):string;
begin
 Inc(GUIDValue);
 Result:=Format('%s_%d', [SubName, GUIDValue]);
end;

function ImplicitRect(AValue:TRect):D2D_RECT_F;
begin
 Result.top := AValue.Top;
 Result.left := AValue.Left;
 Result.bottom := AValue.Bottom;
 Result.right := AValue.Right;
end;

procedure TFormMain.ClickToCell(APos:TPoint);
var Cell:TCell;
begin
 if Field[APos.X, APos.Y].Movement then
  begin
   FSelCell:=APos;
   Exit;
  end
 else
  begin
   if PointInField(FSelCell) then
    if NearFreeCell(FSelCell, APos) and (Field[APos.X, APos.Y].Hole) then
     begin
      NetGame.SendSwapCell(APos, FSelCell);
      Cell:=Field[APos.X, APos.Y];
      Field[APos.X, APos.Y]:=Field[FSelCell.X, FSelCell.Y];
      Field[FSelCell.X, FSelCell.Y]:=Cell;
     end;
  end;
 FSelCell:=Point(0, 0);
 Cell:=Field[APos.X, APos.Y];
 Cell.Open:=True;
 Field[APos.X, APos.Y]:=Cell;
 NetGame.SendOpenCell(APos);
end;

procedure TFormMain.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 HideCP;
end;

procedure TFormMain.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 EndGame;
end;

procedure TFormMain.EndGame;
begin
 CenteredOffset;
 ClearField;
 SpeedButtonContinue.Enabled:=False;
 ShowCP;
 ClientSocket.Close;
 ServerSocket.Close;
end;

procedure TFormMain.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 ErrorCode:=0;
 case ErrorEvent of
  eeConnect:
   begin
    MessageBox(Application.Handle, 'Сервер не отвечает', '', MB_ICONWARNING or MB_OK);
   end;
  eeDisconnect, eeSend, eeGeneral, eeReceive, eeAccept, eeLookup:
   begin
    MessageBox(Application.Handle, 'Подключение потеряно', '', MB_ICONWARNING or MB_OK);
    EndGame;
   end;
 end;
end;

procedure TFormMain.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
begin
 NetGame.ClientReadSocket(Socket);
end;

function TFormMain.NearFreeCell(Cell:TPoint; TargetCheck:TPoint):Boolean;
var tmp:TPoint;
begin
 Result:=False;

 tmp:=Cell;
 tmp.Offset(-1, 0);
 if tmp = TargetCheck then Exit(True);

 tmp:=Cell;
 tmp.Offset(+1, 0);
 if tmp = TargetCheck then Exit(True);

 tmp:=Cell;
 tmp.Offset(0, +1);
 if tmp = TargetCheck then Exit(True);

 tmp:=Cell;
 tmp.Offset(0, -1);
 if tmp = TargetCheck then Exit(True);
end;

procedure TFormMain.ClearField;
var Y, X: Integer;
    Cell:TCell;
begin
 Cell.Clear;
 for X:=1 to FieldSize do
  for Y:=1 to FieldSize do Field[X, Y]:=Cell;
end;

procedure TFormMain.CreateField;
type TItems = TList<Integer>;
var Y, X, Item: Integer;
    Cell:TCell;
    FieldItems:TItems;
begin
 Cell.Clear;
 ClearField;
 FieldItems:=TItems.Create;
 Item:=0;
 for X:= 0 to FFieldData.Count-1 do if FFieldData[X].Addition then Inc(Item, FFieldData[X].MayCount);

 for X:= 0 to FFieldData.Count-1 do
  begin
   if FFieldData[X].Addition and (not Additions) then Continue;
   for Y:= 1 to FFieldData[X].MayCount do
    begin
     if Additions then
      if Item > 0 then
       begin
        Dec(Item);
        Continue;
       end;
     FieldItems.Add(X);
    end;
  end;

 if FieldItems.Count < ((FieldSize-2) * (FieldSize - 2) - 4) then
  begin
   MessageBox(Application.Handle, 'Количество элементов в базе не достаточно для игрового поля такого размера', '', MB_ICONWARNING or MB_OK);
   Exit;
  end;

 for X:=2 to FieldSize-1 do
  for Y:=2 to FieldSize-1 do
   begin
    if ((X = 2) and (Y = 2)) then Continue;
    if ((X = 2) and (Y = FieldSize-1)) then  Continue;
    if ((X = FieldSize-1) and (Y = 2)) then  Continue;
    if ((X = FieldSize-1) and (Y = FieldSize-1)) then  Continue;

    Cell.Hole:=False;
    Item:=Random(FieldItems.Count-1);
    Cell.FieldData:=FieldItems[Item];
    FieldItems.Delete(Item);
    Field[X, Y]:=Cell;
   end;

 Cell.Clear;
 Field[2, 2]:=Cell;
 Field[FieldSize-1, 2]:=Cell;
 Field[2, FieldSize-1]:=Cell;
 Field[FieldSize-1, FieldSize-1]:=Cell;

 Cell.FAnimPercent:=100;
 Cell.FAnimate:=False;
 Cell.FOpen:=True;
 Cell.FNeedOpen:=True;
 Cell.Hole:=False;
 Cell.Movement:=True;
 Cell.FieldData:=32;
 Field[(FieldSize-1) div 2 + 1, 1]:=Cell;
 Cell.FieldData:=33;
 Field[1, (FieldSize-1)div 2 + 1]:=Cell;
 Cell.FieldData:=34;
 Field[FieldSize, (FieldSize-1) div 2 + 1]:=Cell;
 Cell.FieldData:=35;
 Field[(FieldSize-1) div 2 + 1, FieldSize]:=Cell;

 ResetGameItems;
end;

procedure TFormMain.CreateWnd;
begin
 inherited;
 FCanvas:=TDirect2DCanvas.Create(Handle);
end;

procedure TFormMain.WMSize(var Message: TWMSize);
var D2Size:D2D_SIZE_U;
begin
 inherited;
 if csDestroying in ComponentState then Exit;
 D2Size:=D2D1SizeU(ClientWidth, ClientHeight);
 if Assigned(FCanvas) then ID2D1HwndRenderTarget(FCanvas.RenderTarget).Resize(D2Size);
 CenteredOffset;
end;

procedure TFormMain.FillFieldData;
var Item:TFieldDataItem;
begin
 FFieldData:=TFieldData.Create;

 //Элементы поля
 Item.Field:=True;
 Item.Addition:=False;

 Item.ImageIndex:=0;
 Item.MayCount:=0;
 FFieldData.Add(Item);

 Item.ImageIndex:=1;
 Item.MayCount:=10;
 FFieldData.Add(Item);

 Item.ImageIndex:=2;
 Item.MayCount:=10;
 FFieldData.Add(Item);

 Item.ImageIndex:=3;
 Item.MayCount:=10;
 FFieldData.Add(Item);

 Item.ImageIndex:=4;
 Item.MayCount:=10;
 FFieldData.Add(Item);

 Item.ImageIndex:=5;
 Item.MayCount:=6;
 FFieldData.Add(Item);

 Item.ImageIndex:=6;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=7;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=8;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=9;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=10;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=11;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=12;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=13;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=14;
 Item.MayCount:=5;
 FFieldData.Add(Item);

 Item.ImageIndex:=15;
 Item.MayCount:=4;
 FFieldData.Add(Item);

 Item.ImageIndex:=16;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=17;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=18;
 Item.MayCount:=4;
 FFieldData.Add(Item);

 Item.ImageIndex:=19;
 Item.MayCount:=4;
 FFieldData.Add(Item);

 Item.ImageIndex:=20;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=21;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=22;
 Item.MayCount:=5;
 FFieldData.Add(Item);

 Item.ImageIndex:=23;
 Item.MayCount:=5;
 FFieldData.Add(Item);

 Item.ImageIndex:=24;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=25;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=26;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=27;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=28;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=29;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=30;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=31;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 //Корабли
 Item.Field:=False;
 Item.Addition:=False;

 Item.ImageIndex:=32;
 Item.MayCount:=0;
 FFieldData.Add(Item);

 Item.ImageIndex:=33;
 Item.MayCount:=0;
 FFieldData.Add(Item);

 Item.ImageIndex:=34;
 Item.MayCount:=0;
 FFieldData.Add(Item);

 Item.ImageIndex:=35;
 Item.MayCount:=0;
 FFieldData.Add(Item);

 //Дополнение
 Item.Field:=True;
 Item.Addition:=True;

 Item.ImageIndex:=36;
 Item.MayCount:=3;
 FFieldData.Add(Item);

 Item.ImageIndex:=37;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=54;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=38;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=39;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=40;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=41;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=42;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=43;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=44;
 Item.MayCount:=4;
 FFieldData.Add(Item);

 Item.ImageIndex:=45;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=46;
 Item.MayCount:=4;
 FFieldData.Add(Item);

 Item.ImageIndex:=47;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=48;
 Item.MayCount:=2;
 FFieldData.Add(Item);

 Item.ImageIndex:=49;
 Item.MayCount:=1;
 FFieldData.Add(Item);

 Item.ImageIndex:=50;
 Item.MayCount:=1;
 FFieldData.Add(Item);
end;

procedure TFormMain.UpdateBGType;
begin
 SpeedButtonBG0.Down:=BGType = bgNone;
 SpeedButtonBG1.Down:=BGType = bgWater;
 SpeedButtonBG2.Down:=BGType = bgTabel;

 RadioButtonBG0.Checked:=BGType = bgNone;
 RadioButtonBG1.Checked:=BGType = bgWater;
 RadioButtonBG2.Checked:=BGType = bgTabel;
end;

procedure TFormMain.SpeedButtonBG0Click(Sender: TObject);
begin
 BGType:=TBGType((Sender as TsSpeedButton).Tag);
 UpdateBGType;
end;

procedure TFormMain.ResetGameItems;
var Item:TGameItem;
    i, j:Integer;
    MRect:TRect;
begin
 FGameItems.Clear;
 Item.Bounds:=Rect(0, 0, 48, 48);

 if Additions then
  begin
   //Туда же в коробку
   MRect:=FCoinBox.GetDrawRect(1);
   MRect.Right:=MRect.Right - Item.Bounds.Width;
   MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;

   //Помошник 1
   Item.ImageIndex:=5;
   Item.GUID:=GetGUID('human');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);

   //Помошник 2
   Item.ImageIndex:=6;
   Item.GUID:=GetGUID('human');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);

   //Помошник 3
   Item.ImageIndex:=7;
   Item.GUID:=GetGUID('human');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);

   //10 бутылок рома
   Item.ImageIndex:=8;
   for i:= 1 to 10 do
    begin
     Item.GUID:=GetGUID('rom');
     Item.Position:=Random(MRect);
     FGameItems.Add(Item);
    end;

   //Сундук
   Item.ImageIndex:=9;
   Item.GUID:=GetGUID('box');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);

   //Ядра
   Item.ImageIndex:=10;
   for i:= 1 to 2 do
    begin
     Item.GUID:=GetGUID('ball');
     Item.Position:=Random(MRect);
     FGameItems.Add(Item);
    end;

   //Тачка
   Item.ImageIndex:=11;
   Item.GUID:=GetGUID('car');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);

   //Лодка
   Item.ImageIndex:=12;
   Item.GUID:=GetGUID('board');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;

 MRect:=FCoinBox.GetDrawRect(1);
 MRect.Right:=MRect.Right - Item.Bounds.Width;
 MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;

 Item.ImageIndex:=0;
 for i:= 1 to 37 do
  begin
   Item.GUID:=GetGUID('coin');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;

 Item.ImageIndex:=1;
 MRect:=Field[(FieldSize-1) div 2 + 1, 1].DrawRect(1);
 MRect.Right:=MRect.Right - Item.Bounds.Width;
 MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;
 for j:= 1 to 3 do
  begin
   Item.GUID:=GetGUID('pirate');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;

 Item.ImageIndex:=2;
 MRect:=Field[1, (FieldSize-1)div 2 + 1].DrawRect(1);
 MRect.Right:=MRect.Right - Item.Bounds.Width;
 MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;
 for j:= 1 to 3 do
  begin
   Item.GUID:=GetGUID('pirate');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;

 Item.ImageIndex:=3;
 MRect:=Field[FieldSize, (FieldSize-1) div 2 + 1].DrawRect(1);
 MRect.Right:=MRect.Right - Item.Bounds.Width;
 MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;
 for j:= 1 to 3 do
  begin
   Item.GUID:=GetGUID('pirate');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;

 Item.ImageIndex:=4;
 MRect:=Field[(FieldSize-1) div 2 + 1, FieldSize].DrawRect(1);
 MRect.Right:=MRect.Right - Item.Bounds.Width;
 MRect.Bottom:=MRect.Bottom - Item.Bounds.Width;
 for j:= 1 to 3 do
  begin
   Item.GUID:=GetGUID('pirate');
   Item.Position:=Random(MRect);
   FGameItems.Add(Item);
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var i:Integer;
    BMP, BMP2:TBitmap;
    PNG:TPngImage;
    RGN:HRGN;
var BlendFunc: BlendFunction;
begin
 FNetGame:=TNetGame.Create(Self);

 PNG:=TPngImage.Create;
 PNG.LoadFromResourceName(HInstance, 'tabel');
 BMP:=TBitmap.Create;
 BMP.Assign(PNG);
 PNGTabel:=Canvas.CreateBitmap(BMP);
 BMP.Free;
 PNG.Free;

 PNG:=TPngImage.Create;
 PNG.LoadFromResourceName(HInstance, 'water');
 BMP:=TBitmap.Create;
 BMP.Assign(PNG);
 PNGWater:=Canvas.CreateBitmap(BMP);
 BMP.Free;
 PNG.Free;

 FBitmaps:=TBitmaps.Create;
 BlendFunc.BlendOp:= AC_SRC_OVER;
 BlendFunc.BlendFlags:= 0;
 BlendFunc.SourceConstantAlpha:= 255;
 BlendFunc.AlphaFormat:=AC_SRC_ALPHA;
 for i:= 0 to PngImageList1.Count-1 do
  begin
   BMP:=TBitmap.Create;
   //BMP2:=TBitmap.Create;
   BMP.Assign(PngImageList1.PngImages.Items[i].PngImage);
   //BMP2.Assign(PngImageList1.PngImages.Items[55].PngImage);

   //RGN:=CreateRoundRectRgn(0, 0, BMP.Width, BMP.Height, 20, 20);
   //SelectClipRgn(BMP2.Canvas.Handle, RGN);

   //Winapi.Windows.AlphaBlend(BMP2.Canvas.Handle, 0, 0, BMP.Width, BMP.Height, BMP.Canvas.Handle, 0, 0, BMP.Width, BMP.Height, BlendFunc);
   //BitBlt(BMP2.Canvas.Handle, 0, 0, BMP.Width, BMP.Height, BMP.Canvas.Handle, 0, 0, SRCCOPY);
   FBitmaps.Add(Canvas.CreateBitmap(BMP));
   //DeleteObject(RGN);
   BMP.Free;
   //BMP2.Free;
  end;

 FItemBitmaps:=TBitmaps.Create;
 for i:= 0 to PngImageListItems.Count-1 do
  begin
   BMP:=TBitmap.Create;
   BMP.Assign(PngImageListItems.PngImages.Items[i].PngImage);
   FItemBitmaps.Add(Canvas.CreateBitmap(BMP));
   BMP.Free;
  end;

 FCoinBox.Bounds:=Rect(0, 0, 200, 400);
 FCoinBox.Position:=Point(-300, 40);
 FGameItems:=TGameItems.Create;
 FSelCell:=Point(0, 0);
 FFPS:=0;
 FGameCur.FLastPos:=Point(0, 0);
 FGameCur.MovingItem:=False;
 FGameCur.ItemUnderCursor:=-1;
 FPSCounter:=0;
 FScale:=1;
 Offset:=Point(0, 0);
 TimerRepaint.Enabled:=True;
 FillFieldData;
 EndGame;
 BGType:=bgTabel;
 UpdateBGType;
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Item:TGameItem;
begin
 case Button of
  mbLeft:
   begin
    if FGameCur.ItemUnderCursor >= 0 then
     begin
      FSelCell:=Point(0, 0);
      FGameCur.MovingItem:=True;
      if FGameCur.ItemUnderCursor > 0 then
       begin
        Item:=FGameItems[FGameCur.ItemUnderCursor];
        FGameItems.Delete(FGameCur.ItemUnderCursor);
        FGameItems.Insert(0, Item);
        FGameCur.ItemUnderCursor:=0;
       end;
     end
    else
     begin
      FGameCur.Down:=True;
      FGameCur.Drag:=True;
      FGameCur.CellDown:=FGameCur.Cell.ArrayPos;
      FGameCur.PosDown:=FGameCur.FLastPos;
     end;
   end;
  //mbRight:
 end;
 if FGameCur.Drag then Cursor:=crNone;
end;

procedure TFormMain.OffsetGameItem(DeltaX, DeltaY:Integer);
var NPF:TPointF;
    GItem:TGameItem;
begin
 GItem:=FGameItems[FGameCur.ItemUnderCursor];
 NPF:=GItem.Position;
 NPF.Offset(-(DeltaX)/FieldScale, -(DeltaY)/FieldScale);
 GItem.Position:=NPF;
 FGameItems[FGameCur.ItemUnderCursor]:=GItem;
end;

procedure TFormMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var NP:TPoint;
begin
 if (X-FBorders.Left < 0) or (Y-FBorders.Top < 0) or ((X-FBorders.Left) div Round(FieldScale * CellSize) + 1 > FieldSize) or ((Y-FBorders.Top) div Round(FieldScale * CellSize) + 1 > FieldSize) then
  begin
   FGameCur.OutOf:=True;
  end
 else
  begin
   FGameCur.OutOf:=False;
   FGameCur.Cell:=Field[(X-FBorders.Left) div Round(FieldScale * CellSize) + 1, (Y-FBorders.Top) div Round(FieldScale * CellSize) + 1];
  end;
 if FGameCur.Down then
  begin
   if FGameCur.PosDown.Distance(FGameCur.FLastPos) > 10 then
    begin
     FGameCur.Down:=False;
     FGameCur.CellDown:=Point(-1, -1);
    end;
  end;
 if FGameCur.Drag then
  begin
   NP:=Offset;
   NP.Offset(FGameCur.FLastPos.X-X, FGameCur.FLastPos.Y-Y);
   Offset:=NP;
  end;
 if FGameCur.MovingItem then OffsetGameItem(FGameCur.FLastPos.X-X, FGameCur.FLastPos.Y-Y);
 FGameCur.FLastPos:=Point(X, Y);
end;

procedure TFormMain.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if FGameCur.MovingItem then
  begin
   TimerNetTimer(nil);
   FGameCur.MovingItem:=False;
  end;
 if FGameCur.Down then
  begin
   FGameCur.Down:=False;
   if not FGameCur.OutOf then
    if FGameCur.CellDown  = FGameCur.Cell.ArrayPos then ClickToCell(FGameCur.Cell.ArrayPos);
  end;
 if FGameCur.Drag then FGameCur.Drag:=False;
 Cursor:=crDefault;
end;

procedure TFormMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 FieldScale:=FieldScale - ScrollDelta;
end;

procedure TFormMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 FieldScale:=FieldScale + ScrollDelta;
end;

procedure TFormMain.FormPaint(Sender: TObject);
var Stamp:Cardinal;
begin
 if Loading then Exit;
 with Canvas do
  begin
   Stamp:=GetTickCount;
   RenderTarget.BeginDraw;
   RenderTarget.SetTransform(TD2DMatrix3x2F.Identity());
   Brush.Color:=$00FFFAD9;
   Brush.Style:=bsSolid;
   FillRect(ClientRect);
   DoDraw;
   Brush.Style:=bsClear;
   Stamp:=GetTickCount-Stamp;
   TextOut(2, 2, IntToStr(FFPS)+' fps'+#13#10'Задержка '+IntToStr(Stamp)+' мс');
   RenderTarget.EndDraw;
  end;
 FPSCounter:=FPSCounter + 1;
end;

procedure TFormMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
 case Msg.CharCode of
  VK_ESCAPE:ShowCP;
 end;
end;

function TFormMain.GetCell(X, Y: Integer): TCell;
begin
 Result:=FField[Y, X];
end;

function TFormMain.GetInhCanvas: TCanvas;
begin
 Result:=inherited Canvas;
end;

procedure TFormMain.HideCP;
begin
 PanelClient.Hide;
end;

procedure TFormMain.NewGame;
begin
 SpeedButtonContinue.Enabled:=True;
 CreateField;
 NetGame.CreateServer(DefServPort);
end;

procedure TFormMain.ServerSocketAccept(Sender: TObject; Socket: TCustomWinSocket);
begin
 if ServerSocket.Socket.ActiveConnections >= MaxClients+1 then
  begin
   NetGame.SendServerIsFull(Socket);
   Socket.Close;
   UpdatePlayerPanel;
  end;
end;

procedure TFormMain.ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 NetGame.SendFullInfo(Socket);
 UpdatePlayerPanel;
end;

procedure TFormMain.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
 UpdatePlayerPanel;
end;

procedure TFormMain.ServerSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 ErrorCode:=0;
end;

procedure TFormMain.UpdatePlayerPanel;
var i:Integer;
begin
 ListBox1.Clear;
 for i:=0 to ServerSocket.Socket.ActiveConnections-1 do
  begin
   ListBox1.Items.Add(ServerSocket.Socket.Connections[i].RemoteAddress+':'+IntToStr(ServerSocket.Socket.Connections[i].RemotePort));
  end;
end;

procedure TFormMain.ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
 NetGame.ClientReadSocket(Socket);
end;

procedure TFormMain.SetCell(X, Y: Integer; const Value: TCell);
begin
 FField[Y, X]:=Value;
 FField[Y, X].ArrayPos:=Point(X, Y);
end;

procedure TFormMain.UpdateBorders;
begin
 FBorders:=Rect(0, 0, Round(CellSize * FieldScale)*FieldSize, Round(CellSize * FieldScale)*FieldSize);
 FBorders.Offset(-Offset.X, -Offset.Y);
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
 Additions:=CheckBoxAdd.Checked;
 NewGame;
 HideCP;
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
 UpdatePlayerPanel;
end;

procedure TFormMain.CenteredOffset;
var NP:TPoint;
begin
 FScale:=ClientHeight / (FieldSize * CellSize);
 NP:=Offset;
 NP.X:=-(ClientWidth div 2 - Round(FieldScale * CellSize * FieldSize) div 2);
 NP.Y:=-(ClientHeight div 2 - Round(FieldScale * CellSize * FieldSize) div 2);
   //NP.Offset(FGameCur.FLastPos.X-X, FGameCur.FLastPos.Y-Y);
 Offset:=NP;
end;

procedure TFormMain.SetFieldScale(const Value: Single);
var BL, BN:TRect;
var NP:TPoint;
begin
 BL:=FBorders;
 FScale:=Value;
 if FScale < 0.4 then FScale:=0.4;
 if FScale > 2.0 then FScale:=2.0;

 UpdateBorders;
 BN:=FBorders;
 NP:=Offset;
 NP.Offset((BN.Width - BL.Width) div 2, (BN.Height - BL.Height) div 2);
 Offset:=NP;
end;

procedure TFormMain.SetLoading(const Value: Boolean);
begin
 FLoading := Value;
end;

procedure TFormMain.SetOffset(const Value: TPoint);
begin
 //if FGameCur.MovingItem then OffsetGameItem(Round(-(FOffset.X - Value.X)*FieldScale), Round(-(FOffset.Y - Value.Y)*FieldScale));
 FOffset:=Value;
 UpdateBorders;
end;

procedure TFormMain.SetSimple(X, Y: Integer; Value: TSimpleCell);
var Cell:TCell;
begin
 Cell.Simple:=Value;
 Field[X, Y]:=Cell;
end;

procedure TFormMain.ShowCP;
begin
 PanelClient.BoundsRect:=ClientRect;
 PanelClient.Show;
 PanelClient.BringToFront;
end;

procedure TFormMain.SpeedButtonContinueClick(Sender: TObject);
begin
 HideCP;
end;

procedure TFormMain.sSpeedButton1Click(Sender: TObject);
var Prt:Integer;
begin
 if EditPort.Text = '' then Prt:=DefServPort
 else
  if not TryStrToInt(EditPort.Text, Prt) then
   begin
    EditPort.Text:=IntToStr(DefServPort);
    MessageBox(Application.Handle, 'Указан не верный порт', '', MB_ICONWARNING or MB_OK);
    Exit;
   end;
 NetGame.Connect(EditIP.Text, Prt);
end;

procedure TFormMain.TimerAnimateTimer(Sender: TObject);
var X, Y:Integer;
begin
 for X:= 1 to FieldSize do
  for Y:= 1 to FieldSize do
   begin
    FField[Y, X].Step;
   end;
end;

procedure TFormMain.TimerCollisionTimer(Sender: TObject);
var i: Integer;
    Rct:TRect;
begin
 if FGameCur.MovingItem then Exit;
 FGameCur.ItemUnderCursor:=-1;
 for i:= 0 to FGameItems.Count-1 do
  begin
   Rct:=FGameItems[i].GetDrawRect(FieldScale);
   {Rct.Right:=Round(Rct.Right * FieldScale);
   Rct.Bottom:=Round(Rct.Bottom * FieldScale); }
   Rct.Offset(-Offset.X, -Offset.Y);
   Rct.Inflate(-(Rct.Width div 10), -(Rct.Height div 10));
   if PtInRect(Rct, FGameCur.FLastPos) then
    begin
     FGameCur.ItemUnderCursor:=i;
     Exit;
    end;
  end;
end;

procedure TFormMain.TimerFPSTimer(Sender: TObject);
begin
 FFPS:=FPSCounter;
 FPSCounter:=0;
end;

procedure TFormMain.TimerNetTimer(Sender: TObject);
begin
 if FGameCur.MovingItem then
  begin
   //FGameItems[FGameCur.ItemUnderCursor].GUID
   NetGame.SendUpdateGItem(FGameCur.ItemUnderCursor);
  end;
end;

procedure TFormMain.DrawBG;
var D2DRect:TD2DRectF;
begin
 with Canvas do
  begin
   D2DRect.Left:= 0;
   D2DRect.Right:= ClientWidth;
   D2DRect.Top:= 0;
   D2DRect.Bottom:= ClientHeight;
   case BGType of
    bgTabel: RenderTarget.DrawBitmap(PNGTabel, @D2DRect);
    bgWater:
     begin
      Brush.Handle:=CreateBrush(PNGWater);
      FillRect(ClientRect);
      Brush.Assign(inherited Canvas.Brush);
     end;
   else
    begin
     Brush.Color:=clGray;
     FillRect(ClientRect);
    end;
   end;
  end;
end;

function TFormMain.PointInField(Pt:TPoint):Boolean;
begin
 Result:=(Pt.X >= 1) and (Pt.X <= FieldSize) and (Pt.Y >= 1) and (Pt.Y <= FieldSize);
end;

procedure TFormMain.DrawField;
var X, Y, Img:Integer;
    FRect:TRect;
    tmp:Integer;
    D2DRect:TD2DRectF;


procedure DrawSelRect(ARect:TRect);
begin
 with Canvas do
  begin
   Pen.Color:=$00FCD700;
   Pen.Width:=2;
   MoveTo(ARect.Left+Round(ARect.Width / 5 * 1), ARect.Top);
   LineTo(ARect.Left, ARect.Top);
   LineTo(ARect.Left, ARect.Top+Round(ARect.Height / 5 * 1));

   MoveTo(ARect.Right-Round(ARect.Width / 5 * 1), ARect.Top);
   LineTo(ARect.Right, ARect.Top);
   LineTo(ARect.Right, ARect.Top+Round(ARect.Height / 5 * 1));

   MoveTo(ARect.Left+Round(ARect.Width / 5 * 1), ARect.Bottom);
   LineTo(ARect.Left, ARect.Bottom);
   LineTo(ARect.Left, ARect.Bottom-Round(ARect.Height / 5 * 1));

   MoveTo(ARect.Right-Round(ARect.Width / 5 * 1), ARect.Bottom);
   LineTo(ARect.Right, ARect.Bottom);
   LineTo(ARect.Right, ARect.Bottom-Round(ARect.Height / 5 * 1));
  end;
end;

begin
 with Canvas do
  begin
   Brush.Style:=bsSolid;
   Brush.Color:=clGray;
   FillRect(FCoinBox.GetDrawRect(FieldScale), 0.3);

   for X:= 0 to FieldSize-1 do
    for Y:= 0 to FieldSize-1 do
     begin
      //if Field[X+1, Y+1].Hole then Continue;

      //Сетка
      Brush.Style:=bsSolid;
      Brush.Color:=clGray;//+100*(w xor h);

      FRect:=Field[X+1, Y+1].DrawRect(FieldScale);
      //FRect.Offset(-Offset.X, -Offset.Y);

      FRect.Inflate(-1, -1);
      FRect.Width:=FRect.Width + 1;
      FRect.Height:=FRect.Height + 1;

      FillRect(FRect, 0.3);

      //Элементы
      if Field[X+1, Y+1].FieldData >= 0 then
       begin
        tmp:=FRect.Width;
        FRect.Width:=Round((FRect.Width / 100) * Field[X+1, Y+1].FAnimPercent);
        //FRect.Height:=Round((FRect.Height / 100) * Field[X+1, Y+1].FAnimPercent);
        FRect.Offset(tmp div 2 - FRect.Width div 2, tmp div 2 - FRect.Height div 2);
        D2DRect:=ImplicitRect(FRect);
        if Field[X+1, Y+1].Open then
         Img:=FFieldData[Field[X+1, Y+1].FieldData].ImageIndex
        else Img:=0;
        //Brush.Handle:=CreateBrush(FBitmaps[FFieldData[Field[X+1, Y+1].FieldData].ImageIndex]);
        //RoundRect(FRect, 10, 10);
        //Brush.Assign(inherited Canvas.Brush);
        RenderTarget.DrawBitmap(FBitmaps[Img], @D2DRect);
        //TextOut(FRect.Left, FRect.Top, IntToStr(FFieldData[Field[X+1, Y+1].FieldData].ImageIndex));
       end;
      //Курсор
      if (not FGameCur.OutOf) and (FGameCur.Cell.ArrayPos = Point(X+1, Y+1)) and (not FGameCur.ItemUnderCursor >= 0) then
       begin
        FillRect(FRect, 0.3);
       end;
      //Выбранная ячейка
      if PointInField(FSelCell) then
       if Point(X+1, Y+1) = FSelCell then
        begin
         DrawSelRect(FRect);
        end;
      if PointInField(FSelCell) then
       if NearFreeCell(FSelCell, Point(X+1, Y+1)) and (Field[X+1, Y+1].Hole) then DrawSelRect(FRect);
     end;
  end;
end;

procedure TFormMain.DrawItems;
var i:Integer;
    D2DRect:TD2DRectF;
    FRect:TRect;
begin
 with Canvas do
  begin
   for i:= FGameItems.Count-1 downto 0 do
    begin
     D2DRect:=ImplicitRect(FGameItems[i].GetDrawRect(FieldScale));
     if i = FGameCur.ItemUnderCursor then
      begin
       if FGameCur.MovingItem then
        begin
         FRect:=FGameItems[i].GetDrawRect(FieldScale);
         Brush.Style:=bsSolid;
         Brush.Color:=clBlack;
         FRect.Offset(3, 3);
         D2DRect:=ImplicitRect(FRect);
         RenderTarget.DrawBitmap(FItemBitmaps[FGameItems[i].ImageIndex], @D2DRect, 1);
         FRect.Inflate(5, 5);
         FRect.Offset(-3, -3);
         D2DRect:=ImplicitRect(FRect);
        end;
       RenderTarget.DrawBitmap(FItemBitmaps[FGameItems[i].ImageIndex], @D2DRect, 1);
      end
     else RenderTarget.DrawBitmap(FItemBitmaps[FGameItems[i].ImageIndex], @D2DRect, 0.9);
    end;
  end;
end;

procedure TFormMain.DoDraw;
begin
 DrawBG;
 Canvas.RenderTarget.SetTransform(TD2DMatrix3x2F.Translation(-Offset.X, -Offset.Y));
 DrawField;
 DrawItems;
 Canvas.RenderTarget.SetTransform(TD2DMatrix3x2F.Identity());
end;

{ TDirect2DCanvasHelper }

procedure TDirect2DCanvasHelper.FillRect(const Rect:TRect; Opacity:Single);
var RT:D2D_RECT_F;
    BR:ID2D1Brush;

begin
 RT:=ImplicitRect(Rect);
 BR:=CreateBrush(Brush.Color);
 BR.SetOpacity(Opacity);
 RenderTarget.FillRectangle(RT, BR);
end;

function TDirect2DCanvasHelper.CreateBrush(Bitmap:ID2D1Bitmap):ID2D1Brush;
var LBrush:ID2D1BitmapBrush;
    BitmapProperties:TD2D1BitmapBrushProperties;
    BrushProperties:TD2D1BrushProperties;
begin
 BrushProperties.opacity:=1;
 BrushProperties.transform:=TD2DMatrix3x2F.Translation(0, 0);
 BitmapProperties.extendModeX:= D2D1_EXTEND_MODE_WRAP;
 BitmapProperties.extendModeY:= D2D1_EXTEND_MODE_WRAP;
 BitmapProperties.interpolationMode := D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR;
 RenderTarget.CreateBitmapBrush(Bitmap, @BitmapProperties, @BrushProperties, LBrush);
 Result:=LBrush;
end;

{ TGameCur }

procedure TGameCur.SetDrag(const Value: Boolean);
begin
 FDrag := Value;
end;

{ TGameItem }

function TGameItem.Check(AFormMain: TFormMain): Boolean;
begin
 Result:=False;
 if ImageIndex > AFormMain.FBitmaps.Count-1 then Exit;
 if ImageIndex <= 0 then Exit;
 Result:=True;
end;

function TGameItem.GetDrawRect(Scale:Single):TRect;
var PS:TPointF;
begin
 Result:=Bounds;
 Result.Right:=Round(Result.Right * Scale);
 Result.Bottom:=Round(Result.Bottom * Scale);
 PS:=Position;
 PS.X:=PS.X * Scale;
 PS.Y:=PS.Y * Scale;
 Result.Offset(PS.Round);
end;

{ TCell }

procedure TCell.Clear;
begin
 FAnimPercent:=100;
 FAnimate:=False;
 FOpen:=False;
 FNeedOpen:=False;
 Movement:=False;
 FieldData:=-1;
 Hole:=True;
end;

function TCell.DrawRect(Scale:Single):TRect;
begin
 Result:=Rect(0, 0, Round(CellSize * Scale), Round(CellSize * Scale));
 Result.SetLocation((ArrayPos.X-1)*Round(CellSize * Scale), (ArrayPos.Y-1)*Round(CellSize * Scale));
end;

function TCell.GetOpen:Boolean;
begin
 Result:=FOpen or (Animate = asOpenning);
end;

function TCell.GetSimple: TSimpleCell;
begin
 Result.Hole:=Hole;
 Result.FieldData:=FieldData;
 Result.ArrayPos:=ArrayPos;
 Result.Movement:=Movement;
 Result.Open:=Open;
end;

procedure TCell.SetOpen(const Value: Boolean);
begin
 if Value = Open then Exit;
 FNeedOpen:=Value;
 FAnimate:=True;
 FAnimPercent:=100;
 Animate:=asClosing;
end;

procedure TCell.SetSimple(const Value: TSimpleCell);
begin
 Hole:=Value.Hole;
 FieldData:=Value.FieldData;
 ArrayPos:=Value.ArrayPos;
 Movement:=Value.Movement;
 FOpen:=Value.Open;
 FAnimate:=False;
 FAnimPercent:=100;
 FNeedOpen:=FOpen;
end;

procedure TCell.Step;
begin
 if FAnimate then
  begin
   case Animate of
    asClosing: FAnimPercent:=FAnimPercent - 10;
    asOpenning: FAnimPercent:=FAnimPercent + 10;
   end;
   if FAnimPercent >= 100 then
    begin
     FAnimPercent:=100;
     FAnimate:=False;
     FOpen:=FNeedOpen;
    end;
   if FAnimPercent <= 0 then
    begin
     FAnimPercent:=0;
     Animate:=asOpenning;
    end;
  end;
end;

{ TNetGame }

function TNetGame.SendData(Socket:TCustomWinSocket; Data:TMemoryStream; RepWait:Integer):Boolean;
begin
 Data.Position:=0;
 with FOwner do
  begin
   while (not Socket.SendStream(Data)) or (RepWait <= 0) do
    begin
     Application.ProcessMessages;
     Dec(RepWait);
    end;
   Result:=RepWait > 0;
  end;
end;

procedure WaitSend;
begin
 Sleep(500);
end;

procedure TNetGame.SendFullInfo(Socket:TCustomWinSocket);
var X, Y:Integer;
var Mem:TMemoryStream;
    Head:TNetHead;
    Cell:TSimpleCell;
    GItem:TGameItem;
begin
 with FOwner do
  begin
   Mem:=TMemoryStream.Create;
   //Данные игрового поля
   for X:= 1 to FieldSize do
    for Y:= 1 to FieldSize do
     begin
      Cell:=Field[X, Y].Simple;
      Mem.Write(Cell, SizeOf(TSimpleCell));
     end;
   Y:=FGameItems.Count;
   Mem.Write(Y, SizeOf(Integer));
   for X:= 0 to FGameItems.Count-1 do
    begin
     GItem:=FGameItems[X];
     Mem.Write(GItem, SizeOf(TGameItem));
    end;
   Mem.Position:=0;
   //Заголовок
   Head:=GetHead(nhFullData);
   Head.DataSize:=Mem.Size;
   Socket.SendBuf(Head, SizeOf(TNetHead));
   WaitSend;
   //Данные
   SendData(Socket, Mem);
  end;
end;

procedure TNetGame.SendOpenCell(PosCell: TPoint);
var i:Integer;
begin
 with FOwner do
  begin
   if ServerSocket.Active then
    begin
     for i:= 0 to ServerSocket.Socket.ActiveConnections-1 do
      begin
       SendOpenCell(ServerSocket.Socket.Connections[i], PosCell);
      end;
    end;
   if ClientSocket.Active then
    begin
     SendOpenCell(ClientSocket.Socket, PosCell);
    end;
  end;
end;

procedure TNetGame.SendOpenCell(Socket: TCustomWinSocket; PosCell: TPoint);
var Mem:TMemoryStream;
    Head:TNetHead;
begin
 with FOwner do
  begin
   Mem:=TMemoryStream.Create;
   Mem.Write(PosCell, SizeOf(TPoint));
   Mem.Position:=0;
   //Заголовок
   Head:=GetHead(nhOpenCell);
   Head.DataSize:=Mem.Size;
   Socket.SendBuf(Head, SizeOf(TNetHead));
   WaitSend;
   //Данные
   SendData(Socket, Mem);
  end;
end;

procedure TNetGame.SendServerIsFull(Socket: TCustomWinSocket);
var Mem:TMemoryStream;
    Head:TNetHead;
begin
 with FOwner do
  begin
   Mem:=TMemoryStream.Create;
   Mem.Write(Head, SizeOf(TNetHead));
   Mem.Position:=0;
   //Заголовок - Игровое поле
   Head:=GetHead(nhServerIsFull);
   Head.DataSize:=Mem.Size;
   Socket.SendBuf(Head, SizeOf(TNetHead));
   WaitSend;
   //Отправка
   SendData(Socket, Mem);
  end;
end;

procedure TNetGame.SendSwapCell(Socket: TCustomWinSocket; Pos1, Pos2: TPoint);
var Mem:TMemoryStream;
    Head:TNetHead;
begin
 with FOwner do
  begin
   Mem:=TMemoryStream.Create;
   Mem.Write(Pos1, SizeOf(TPoint));
   Mem.Write(Pos2, SizeOf(TPoint));
   Mem.Position:=0;
   //Заголовок - Игровое поле
   Head:=GetHead(nhSwapField);
   Head.DataSize:=Mem.Size;
   Socket.SendBuf(Head, SizeOf(TNetHead));
   WaitSend;
   //Данные
   //Отправка
   SendData(Socket, Mem);
  end;
end;

procedure TNetGame.SendUpdateGItem(Item: Integer);
var i:Integer;
begin
 with FOwner do
  begin
   if ServerSocket.Active then
    begin
     for i:= 0 to ServerSocket.Socket.ActiveConnections-1 do
      begin
       SendUpdateGItem(ServerSocket.Socket.Connections[i], Item);
      end;
    end;
   if ClientSocket.Active then
    begin
     SendUpdateGItem(ClientSocket.Socket, Item);
    end;
  end;
end;

procedure TNetGame.SendUpdateGItem(Socket: TCustomWinSocket; Item:Integer);
var Mem:TMemoryStream;
    Head:TNetHead;
    GItem:TGameItem;
begin
 with FOwner do
  begin
   Mem:=TMemoryStream.Create;
   //Данные
   GItem:=FGameItems[Item];
   Mem.Write(GItem, SizeOf(TGameItem));
   Mem.Position:=0;
   //Заголовок
   Head:=GetHead(nhItemUpdate);
   Head.DataSize:=Mem.Size;
   Socket.SendBuf(Head, SizeOf(TNetHead));
   WaitSend;
   //Отправка
   SendData(Socket, Mem);
  end;
end;

procedure TNetGame.SendSwapCell(Pos1, Pos2: TPoint);
var i:Integer;
begin
 with FOwner do
  begin
   if ServerSocket.Active then
    begin
     for i:= 0 to ServerSocket.Socket.ActiveConnections-1 do
      begin
       SendSwapCell(ServerSocket.Socket.Connections[i], Pos1, Pos2);
      end;
    end;
   if ClientSocket.Active then
    begin
     SendSwapCell(ClientSocket.Socket, Pos1, Pos2);
    end;
  end;
end;

procedure TNetGame.ClientReadSocket(Socket: TCustomWinSocket);
var X, Y:Integer;
    iLen:Integer;
    Bfr:Pointer;
    Pt1, Pt2:TPoint;
    SCell:TSimpleCell;
    Cell:TCell;
    GItem:TGameItem;
    Mem:TMemoryStream;
begin
 with FOwner do
  begin
   iLen:=Socket.ReceiveLength;
   ListBox2.Items.Add(IntToStr(iLen));
   GetMem(Bfr, iLen);
   Socket.ReceiveBuf(Bfr^, iLen);
   if FGetting then
    begin
     FMem.Write(Bfr^, iLen);
     if FMem.Size = FGettingHead.DataSize then
      begin
       FGetting:=False;
      end
     else Exit;
    end
   else
    begin
     FGetting:=True;
     FGettingHead:=TNetHead(Bfr^);
     FMem.Clear;
     Exit;
    end;

   case FGettingHead.HeadType of
    nhFullData:
     begin
      FMem.Position:=0;
      FGameItems.Clear;
      try
       begin
        for X:= 1 to FieldSize do
         for Y:= 1 to FieldSize do
          begin
           FMem.Read(SCell, SizeOf(TSimpleCell));
           if not SCell.Check(FormMain) then
            begin
             raise Exception.Create('');
            end;
           SetSimple(X, Y, SCell);
          end;
        iLen:=0;
        FMem.Read(iLen, SizeOf(Integer));
        for X:= 0 to iLen - 1 do
         begin
          FMem.Read(GItem, SizeOf(TGameItem));
          FGameItems.Add(GItem);
         end;
        HideCP;
        SpeedButtonContinue.Enabled:=True;
       end;
      except
       begin
        MessageBox(Application.Handle, 'Произошла ошибка во время получения данных. Попробуйте снова', '', MB_ICONSTOP or MB_OK);
        EndGame;
       end;
      end;
     end;
    nhSwapField:
     begin
      FMem.Position:=0;
      FMem.Read(Pt1, SizeOf(TPoint));
      FMem.Read(Pt2, SizeOf(TPoint));
      Cell:=Field[Pt1.X, Pt1.Y];
      Field[Pt1.X, Pt1.Y]:=Field[Pt2.X, Pt2.Y];
      Field[Pt2.X, Pt2.Y]:=Cell;
     end;
    nhOpenCell:
     begin
      FMem.Position:=0;
      FMem.Read(Pt1, SizeOf(TPoint));
      Cell:=Field[Pt1.X, Pt1.Y];
      Cell.Open:=True;
      Field[Pt1.X, Pt1.Y]:=Cell;
     end;
    nhItemUpdate:
     begin
      FMem.Position:=0;
      FMem.Read(GItem, SizeOf(TGameItem));
      for X:= 0 to FGameItems.Count-1 do
       begin
        if FGameItems[X].GUID = GItem.GUID then
         begin
          FGameItems[X]:=GItem;
          Break;
         end;
       end;
     end;
    nhServerIsFull:
     begin
      MessageBox(Application.Handle, 'Сервер заполнен', '', MB_ICONSTOP or MB_OK);
     end;
   end;
   for X:= 0 to ServerSocket.Socket.ActiveConnections-1 do
    begin
     if ServerSocket.Socket.Connections[X] <> Socket then
      begin
       Mem:=TMemoryStream.Create;
       FMem.Position:=0;
       Mem.CopyFrom(FMem, FMem.Size);
       SendData(ServerSocket.Socket.Connections[X], Mem);
      end;
    end;
   FMem.Clear;
   //Socket.ReceiveBuf(Head, SizeOf(TNetHead));
  end;
end;

function TNetGame.Connect(IP:string; Port:Integer): Boolean;
begin
 Result:=False;
 with FOwner do
  begin
   try
    ServerSocket.Close;
    ClientSocket.Close;
    ClientSocket.Address:=IP;
    ClientSocket.Port:=Port;
    ClientSocket.Open;
    Result:=True;
   except
    MessageBox(Application.Handle, 'Произошла ошибка при подключении к серверу', '', MB_ICONSTOP or MB_OK);
   end;
  end;
end;

constructor TNetGame.Create(AOwner:TFormMain);
begin
 FOwner:=AOwner;
 FMem:=TMemoryStream.Create;
end;

function TNetGame.CreateServer(APort:Integer):Boolean;
begin
 Result:=False;
 with FOwner do
  begin
   try
    ServerSocket.Close;
    ServerSocket.Port:=APort;
    ServerSocket.Open;
    ClientSocket.Close;
    Result:=True;
   except
    MessageBox(Application.Handle, 'Произошла ошибка при создании сервера', '', MB_ICONSTOP or MB_OK);
   end;
  end;
end;

function TNetGame.GetHead(HeadType:TNetHeadType):TNetHead;
begin
 Result.HeadType:=HeadType;
 Result.DataSize:=0;
end;

{ TSimpleCell }

function TSimpleCell.Check(AFormMain:TFormMain): Boolean;
begin
 Result:=False;
 if Self.FieldData > AFormMain.FFieldData.Count-1 then Exit;
 if not AFormMain.PointInField(Self.ArrayPos) then Exit;
 Result:=True;
end;

end.
