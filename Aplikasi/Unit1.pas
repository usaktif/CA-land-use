unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, ComCtrls, Menus, XPMan;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    StaticText1: TStaticText;
    Edit2: TEdit;
    StaticText2: TStaticText;
    Edit1: TEdit;
    btnRandom: TBitBtn;
    btnSimulasi: TBitBtn;
    Panel2: TPanel;
    DrawGrid1: TDrawGrid;
    imagePeta: TImage;
    btnLoadMap: TButton;
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    Refresh1: TMenuItem;
    XPManifest1: TXPManifest;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    procedure btnRandomClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSimulasiClick(Sender: TObject);
    procedure btnLoadMapClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure drawPeta;
    procedure drawPattern;
    procedure tetangga;
    procedure neumann;
    procedure circular;
    procedure warna;
    procedure warnaPeta;
    procedure simulasiRandom;
    procedure simulasiPeta;
    procedure simulasiVonNeumann;
    procedure simulasiCircular;
  end;

const
  selmaks=215;

Type
  TRGBTripleArray = ARRAY[WORD] OF TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray;
  seltype = array[0..215,0..215] of Integer;

var
  Form1 : TForm1;
  tabelwarna : array[0..4] of TColor;
  tabelwarnaPeta : array[1..5] of TColor;
  Tm:array[0..100] of record x, y : integer; end;
  Tn:array[0..100] of record x, y : integer; end;
  Tc:array[0..100] of record x, y : integer; end;
  sel, selbaru : array[0..selmaks,0..selmaks] of Integer;
  warnatetangga : array[0..15] of Integer;
  //acol1, arow1, xm, ym : Integer;
  L :integer;
  clickRandomMap, clickMap, clickMoore, clickCircular : Boolean;

implementation

uses searchUnit;

{$R *.dfm}

function HkeTColor(wHTML: string): TColor;
begin
  Result := StringToColor('$' + Copy(wHTML, 6, 2) + Copy(wHTML, 4, 2) + Copy(wHTML, 2, 2));
end;

procedure TForm1.warnaPeta;
begin
  tabelwarnaPeta[1]:= HKeTColor('#fb0000');//Red;//industri
  tabelwarnaPeta[2]:= HkeTColor('#0000fb'); //Blue;//pemukiman
  tabelwarnaPeta[3]:= HkeTColor('#02dc01');//Green;//lahan kosong
  tabelwarnaPeta[4]:= HkeTColor('#fffa13'); //Yellow;//pertanian
  tabelwarnaPeta[5]:= clwhite;//laut
end;

procedure TForm1.warna;
begin
  tabelwarna[0]:=clyellow;{lahan kosong}
  tabelwarna[1]:=clred; {pemukiman}
  tabelwarna[2]:=clgreen; {hutan}
  tabelwarna[3]:=clblue; {air}
  tabelwarna[4]:=clblack; {industri}
end;

procedure TForm1.tetangga;
begin
  {Moore}
  Tm[0].x:=-1;  Tm[0].y:=-1;
  Tm[1].x:=0;   Tm[1].y:=-1;
  Tm[2].x:=1;   Tm[2].y:=-1;
  Tm[3].x:=-1;  Tm[3].y:=0;
  Tm[4].x:=0;   Tm[4].y:=0;
  Tm[5].x:=1;   Tm[5].y:=0;
  Tm[6].x:=-1;  Tm[6].y:=1;
  Tm[7].x:=0;   Tm[7].y:=1;
  Tm[8].x:=1;   Tm[8].y:=1;
end;

procedure TForm1.neumann;
begin
  {von neumann}
  Tn[1].x:=0;   Tn[1].y:=-1;
  Tn[2].x:=-1;  Tn[2].y:=0;
  Tn[3].x:=0;   Tn[3].y:=0;
  Tn[4].x:=1;   Tn[4].y:=0;
  Tn[5].x:=0;   Tn[5].y:=1;
end;

procedure TForm1.circular;
begin
  {circular}
  Tc[0].x:=-1;  Tc[0].y:=-1;
  Tc[1].x:=0;   Tc[1].y:=-1;
  Tc[2].x:=1;   Tc[2].y:=-1;
  Tc[3].x:=-1;  Tc[3].y:=0;
  Tc[4].x:=0;   Tc[4].y:=0;
  Tc[5].x:=1;   Tc[5].y:=0;
  Tc[6].x:=-1;  Tc[6].y:=1;
  Tc[7].x:=0;   Tc[7].y:=1;
  Tc[8].x:=1;   Tc[8].y:=1;
  Tc[9].x:=-2;  Tc[9].y:=0;
  Tc[10].x:=0;  Tc[10].y:=-2;
  Tc[11].x:=2;  Tc[11].y:=0;
  Tc[12].x:=0;  Tc[12].y:=2;
end;

procedure TForm1.simulasiPeta;
var
  i, x, y, w, n :integer;
begin
  tetangga;
  warnaPeta;
  L := 0;
  n := strtoint(edit2.text);
  selbaru := sel;
  repeat
    {pemukiman}
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        for w:=1 to 5 do
          warnatetangga[w]:=0;
        for i:=1 to 8 do
        begin
          w:=sel[x+Tm[i].x,y+Tm[i].y];
          warnatetangga[w]:=warnatetangga[w]+1;
        end;
        if sel[x,y]=3 then
        begin
          if warnatetangga[2]>=3 then selbaru [x,y]:=2;
          if warnatetangga[1]>=1 then selbaru [x,y]:=3;
        end;

        if (sel[x,y])=4 then
        begin
          if warnatetangga[2]>=4 then selbaru [x,y]:=2;
        end;
      end;

    sel:=selbaru;
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        drawgrid1.Canvas.Brush.Color:=tabelwarnaPeta[sel[x,y]];
        drawgrid1.Canvas.FillRect(drawgrid1.cellrect(x,y));
      end;

    L:=L+1;
    edit1.Text:=inttostr(L);
    application.processmessages;
  until
    L=n;
end;

procedure TForm1.simulasiVonNeumann;
var
  i, x, y, w, n :integer;
begin
  neumann;
  warnaPeta;
  L := 0;
  n := strtoint(edit2.text);
  selbaru := sel;
  repeat
    {pemukiman}
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        for w:=1 to 5 do
          warnatetangga[w]:=0;
        for i:=1 to 5 do
        begin
          w:=sel[x+Tn[i].x,y+Tn[i].y];
          warnatetangga[w]:=warnatetangga[w]+1;
        end;
        if sel[x,y]=3 then
        begin
          if warnatetangga[2]>=3 then selbaru [x,y]:=2;
          if warnatetangga[1]>=1 then selbaru [x,y]:=3;
        end;

        if (sel[x,y])=4 then
        begin
          if warnatetangga[2]>=4 then selbaru [x,y]:=2;
        end;
      end;

    sel:=selbaru;
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        drawgrid1.Canvas.Brush.Color:=tabelwarnaPeta[sel[x,y]];
        drawgrid1.Canvas.FillRect(drawgrid1.cellrect(x,y));
      end;

    L:=L+1;
    edit1.Text:=inttostr(L);
    application.processmessages;
  until
    L=n;
end;

procedure TForm1.simulasiCircular;
var
  i, x, y, w, n :integer;
begin
  circular;
  warnaPeta;
  L := 0;
  n := strtoint(edit2.text);
  selbaru := sel;
  repeat
    {pemukiman}
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        for w:=1 to 5 do
          warnatetangga[w]:=0;
        for i:=0 to 12 do
        begin
          w:=sel[x+Tc[i].x,y+Tc[i].y];
          warnatetangga[w]:=warnatetangga[w]+1;
        end;
        if sel[x,y]=3 then
        begin
          if warnatetangga[2]>=3 then selbaru [x,y]:=2;
          if warnatetangga[1]>=1 then selbaru [x,y]:=3;
        end;

        if (sel[x,y])=4 then
        begin
          if warnatetangga[2]>=4 then selbaru [x,y]:=2;
        end;
      end;

    sel:=selbaru;
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        drawgrid1.Canvas.Brush.Color:=tabelwarnaPeta[sel[x,y]];
        drawgrid1.Canvas.FillRect(drawgrid1.cellrect(x,y));
      end;

    L:=L+1;
    edit1.Text:=inttostr(L);
    application.processmessages;
  until
    L=n;
end;

procedure TForm1.simulasiRandom;
var
  i,a,b,d,e,f,g,x,y,w,n,langkah:integer;
begin
  tetangga;
  //warna;
  langkah:=0;
  n:=strtoint(edit2.text);
  selbaru:=sel;
  repeat
  {pemukiman}
    for x:=1 to selmaks -1 do
      for y:=1 to selmaks -1 do
      begin
        for w:=0 to 5 do
          warnatetangga[w]:=0;
        for i:=0 to 8 do
        begin
          w:=sel[x+Tm[i].x,y+Tm[i].y];
          warnatetangga[w]:=warnatetangga[w]+1;
        end;
        if sel[x,y]<=3 then
        begin
          if warnatetangga[1]>=3 then selbaru [x,y]:=1
        end;
      end;

      sel:=selbaru;
      for x:=1 to selmaks -1 do
        for y:=1 to selmaks -1 do
        begin
          drawgrid1.Canvas.Brush.Color:=tabelwarna[sel[x,y]];
          if (drawgrid1.Canvas.Brush.Color <> clyellow) then
            drawgrid1.Canvas.FillRect(drawgrid1.cellrect(x,y));
        end;

  {hutan}
    for a:=2 to selmaks -1 do
      for b:=2 to selmaks -1 do
      begin
        for w:=0 to 5 do
          warnatetangga[w]:=0;
        for i:=0 to 8 do
        begin
          w:=sel[a+Tm[i].x,b+Tm[i].y];
          warnatetangga[w]:=warnatetangga[w]+1;
        end;
        if sel[a,b]=0 then
        begin if
          warnatetangga[2]>=3 then selbaru[a,b]:=0
        end;
      end;

      sel:=selbaru;
      for a:=2 to selmaks -1 do
        for b:=2 to selmaks -1 do
        begin
          drawgrid1.Canvas.Brush.Color:=tabelwarna[sel[a,b]];
          if (drawgrid1.Canvas.Brush.Color <> clyellow) then
            drawgrid1.Canvas.FillRect(drawgrid1.cellrect(a,b));
        end;

  {air}
    for d:=3 to selmaks -1 do
      for e:=3 to selmaks -1 do
      begin
        for w:=0 to 5 do
          warnatetangga[w]:=0;
          for i:=0 to 8 do
          begin
            w:=sel[d+Tm[i].x,e+Tm[i].y];
            warnatetangga[w]:=warnatetangga[w]+1;
          end;
          if sel[d,e]=0 then
          begin
            if warnatetangga[3]>=3 then selbaru [d,e]:=0
          end;
      end;

      sel:=selbaru;
      for d:=3 to selmaks -1 do
        for e:=3 to selmaks -1 do
        begin
          drawgrid1.Canvas.Brush.Color:=tabelwarna[sel[d,e]];
          if (drawgrid1.Canvas.Brush.Color <> clyellow) then
            drawgrid1.Canvas.FillRect(drawgrid1.cellrect(d,e));
        end;

  {industri}
    for f:=4 to selmaks -1 do
      for g:=4 to selmaks -1 do
      begin
        for w:=0 to 5 do
          warnatetangga[w]:=0;
          for i:=0 to 8 do
          begin
            w:=sel[f+Tm[i].x,g+Tm[i].y];
            warnatetangga[w]:=warnatetangga[w]+1;
          end;
          if sel[f,g]>=0 then
          begin
            if warnatetangga[4]>=3 then selbaru [f,g]:=4
          end;
      end;

      sel:=selbaru;
      for f:=4 to selmaks -1 do
        for g:=4 to selmaks -1 do
        begin
          drawgrid1.Canvas.Brush.Color:=tabelwarna[sel[f,g]];
          if (drawgrid1.Canvas.Brush.Color <> clyellow) then
            drawgrid1.Canvas.FillRect(drawgrid1.cellrect(f,g));
        end;

      langkah:=langkah+1;
      edit1.Text:=inttostr(langkah);
      //application.processmessages;
  until
    langkah=n;
end;

procedure TForm1.drawPattern();
Var pattern : TBitmap;
begin
  pattern:=TBitmap.Create;

  with pattern do
  begin
    Width:=30;
    Height:=30;
    PixelFormat:=pf8bit;
    Transparent := True;
    Canvas.Pen.Color:= clYellow; //HkeTColor('#fffa13');//clHotLight;
    Canvas.MoveTo(0,0);
    Canvas.LineTo(30,0);
    Canvas.MoveTo(0,30);
    Canvas.LineTo(0,0);

    DrawGrid1.Canvas.Brush.Bitmap:=pattern;
    DrawGrid1.Canvas.Rectangle(Self.GetClientRect);
    TransparentMode := tmAuto;
    Free;
  end;
end;

procedure TForm1.drawPeta;
var
  gambar : TBitmap;
  i, j : Integer;
  citrawarna : PbyteArray;
  citrawarnaR, citrawarnaG, citrawarnaB : array[0..selmaks,0..selmaks] of Integer;
begin
  gambar := TBitmap.Create;
  gambar.LoadFromFile(lokasiFile);
  L:=0;

  for j:=0 to gambar.Height-1 do
  begin
    citrawarna:=gambar.ScanLine[j];
    for i:=0 to gambar.Width-1 do
    begin
      citrawarnaB[i,j]:=citrawarna[3*i];
      citrawarnaG[i,j]:=citrawarna[3*i+1];
      citrawarnaR[i,j]:=citrawarna[3*i+2];
    end;
  end;
  for i:= 0 to selmaks do
    for j:=0 to selmaks do
    begin
      sel[i,j]:=3;
    end;

    for i:=0 to selmaks do
      for j:=0 to selmaks do
      begin
        if ((citrawarnaR[i,j]>=0) and (citrawarnaR[i,j]<=60)) and ((citrawarnaG[i,j]>=0) and (citrawarnaG[i,j]<=60)) and ((citrawarnaB[i,j]>=200) and (citrawarnaB[i,j]<=255)) then sel[i,j]:=2 else
        if ((citrawarnaR[i,j]>=0) and (citrawarnaR[i,j]<=40)) and ((citrawarnaG[i,j]>=100) and (citrawarnaG[i,j]<=200)) and ((citrawarnaB[i,j]>=0) and (citrawarnaB[i,j]<=60)) then sel[i,j]:=3 else
        if ((citrawarnaR[i,j]>=0) and (citrawarnaR[i,j]<=20)) and ((citrawarnaG[i,j]>=0) and (citrawarnaG[i,j]<=20)) and ((citrawarnaB[i,j]>=0) and (citrawarnaB[i,j]<=20)) then sel[i,j]:=5 else
        if ((citrawarnaR[i,j]>=220) and (citrawarnaR[i,j]<=255)) and ((citrawarnaG[i,j]>=220) and (citrawarnaG[i,j]<=255)) and ((citrawarnaB[i,j]>=0) and (citrawarnaB[i,j]<=35)) then sel[i,j]:=4 else
        if ((citrawarnaR[i,j]>=240) and (citrawarnaR[i,j]<=255)) and ((citrawarnaG[i,j]>=240) and (citrawarnaG[i,j]<=255)) and ((citrawarnaB[i,j]>=240) and (citrawarnaB[i,j]<=255)) then sel[i,j]:=5 else
        if ((citrawarnaR[i,j]>=200) and (citrawarnaR[i,j]<=255)) and ((citrawarnaG[i,j]>=0) and (citrawarnaG[i,j]<=50)) and ((citrawarnaB[i,j]>=0) and (citrawarnaB[i,j]<=50)) then sel[i,j]:=1;
        drawgrid1.Canvas.Brush.Color:=tabelwarnaPeta[sel[i,j]];
        drawgrid1.Canvas.FillRect(drawgrid1.CellRect(i,j));
      end;
  gambar.Free;
end;

procedure pemukiman(r:integer);
var
  x2,y2,x1,y1,x,y:integer;
begin
  x1:=random(selmaks-r)+r;
  y1:=random(selmaks-r)+r;
  for x2:=-r to r do
    for y2:=-r to r do
    begin
      if round((x2*x2)+(y2*y2))<=r*r then
      begin
        x:=x2+x1;
        y:=y2+y1;
        if (x in[1..selmaks]) and (y in[1..selmaks]) then
        begin
          sel[x,y]:=1;
          form1.DrawGrid1.Canvas.Brush.Color:=tabelwarna[sel[x,y]];
          form1.DrawGrid1.Canvas.FillRect(form1.DrawGrid1.CellRect(x,y));
        end;
      end;
    end;
end;

procedure hutan(r:integer);
var
  a2,b2,a1,b1,a,b:integer;
begin
  a1:=random(selmaks-r)+r;
  b1:=random(selmaks-r)+r;
  for a2:=-r to r do
    for b2:=-r to r do
    begin
      if round((a2*a2)+(b2*b2))<=r*r then
      begin
        a:=a2+a1;
        b:=b2+b1;
        if (a in[2..selmaks]) and (b in[2..selmaks]) then
        begin
          sel[a,b]:=2;
          form1.DrawGrid1.Canvas.Brush.Color:=tabelwarna[sel[a,b]];
          form1.DrawGrid1.Canvas.FillRect(form1.DrawGrid1.CellRect(a,b));
        end;
      end;
    end;
end;

procedure air(r:integer);
var
  d2,e2,d1,e1,d,e:integer;
begin
  d1:=random(selmaks-r)+r;
  e1:=random(selmaks-r)+r;
  for d2:=-r to r do
    for e2:=-r to r do
    begin
      if round((d2*d2)+(e2*e2))<=r*r then
      begin
        d:=d2+d1;
        e:=e2+e1;
        if (d in[3..selmaks]) and (e in[3..selmaks]) then
        begin
          sel[d,e]:=3;
          form1.DrawGrid1.Canvas.Brush.Color:=tabelwarna[sel[d,e]];
          form1.DrawGrid1.Canvas.FillRect(form1.DrawGrid1.CellRect(d,e));
        end;
      end;
    end;
end;

procedure industri(r:integer);
var
  f2,g2,f1,g1,f,g:integer;
begin
  f1:=random(selmaks-r)+r;
  g1:=random(selmaks-r)+r;
  for f2:=-r to r do
    for g2:=-r to r do
    begin
      if round((f2*f2)+(g2*g2))<=r*r then
      begin
        f:=f2+f1;
        g:=g2+g1;
        if (f in[4..selmaks]) and (g in[4..selmaks]) then
        begin
          sel[f,g]:=4;
          form1.DrawGrid1.Canvas.Brush.Color:=tabelwarna[sel[f,g]];
          form1.DrawGrid1.Canvas.FillRect(form1.DrawGrid1.CellRect(f,g));
        end;
      end;
    end;
end;

procedure TForm1.btnRandomClick(Sender: TObject);
var
  i,j:integer;
begin
  clickRandomMap := True;
  //clickMap := False;

  for i:=0 to selmaks do
    for j:=0 to selmaks do
    begin
      sel[i,j]:=0;
      drawgrid1.Canvas.Brush.Color:=tabelwarna[sel[i,j]];
      //drawgrid1.Canvas.FillRect(drawgrid1.CellRect(i,j));
    end;

  drawPattern;
  pemukiman(20);
  hutan(50);
  air(20);
  industri(5);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  clickRandomMap := False;
  clickMoore := False;
  clickCircular := False;
  RadioButton1.Checked := False;
  RadioButton2.Checked := False;
  RadioButton3.Checked := False;
  //clickMap := False;
  warna;
  warnaPeta;
  //randomize;
end;

procedure TForm1.btnSimulasiClick(Sender: TObject);
begin
  if (Edit2.Text <> '0') then
  begin
    if clickRandomMap then
      simulasiRandom
    else
    begin
      if (not(RadioButton1.Checked) AND not(RadioButton2.Checked) AND not(RadioButton3.Checked)) then
        MessageBox(Handle, 'Pilih Metoda Moore atau Von Neumann atau Circular','[::] Information [::]', MB_ICONINFORMATION)
      else
      begin
        if ((clickMoore) AND not(clickCircular)) then
          simulasiPeta
        else if (not(clickMoore) AND not(clickCircular)) then
          simulasiVonNeumann
        else
          simulasiCircular;
      end;
    end;
  end
  else
    MessageBox(Handle, 'Jumlah Langkah Harus Lebih Dari Nol','[::] Information [::]', MB_ICONINFORMATION);
end;

procedure TForm1.btnLoadMapClick(Sender: TObject);
begin
  searchForm.ShowModal;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Refresh1Click(Sender: TObject);
begin
  PatBlt(DrawGrid1.Canvas.Handle, 0, 0, DrawGrid1.ClientWidth, DrawGrid1.ClientHeight, WHITENESS);
  edit1.Text:='';
  edit2.Text:='';
  FormCreate(Sender);
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  clickMoore := True;
  clickCircular := False;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  clickMoore := False;
  clickCircular := False;
end;

procedure TForm1.RadioButton3Click(Sender: TObject);
begin
  clickCircular := True;
  clickMoore := False;
end;

procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);

const backspace = #8; {key code for backspace character} begin If sender is TEdit then begin if Key in [backspace, '0'..'9'] then exit; Key := #0; end; end;


end.
