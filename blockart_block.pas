// ====================================================================
// BlockArt ANSI Editor                                written by xqtr
//                                                 xqtr.xqtr#gmail.com
// ====================================================================
//
// This file is part of BlockArt ANSI Editor.
//
// BlockArt is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// BlockArt, is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// For additional info of the license see <http://www.gnu.org/licenses/>.
//
// ====================================================================

Unit blockart_block;

{$I M_OPS.PAS}

Interface

Uses
  Math,
  m_Types,
  DOS,
  m_Strings,
  m_Input,
  m_Output,
  m_MenuBox,
  m_MenuForm,
  m_ansi2pipe,
  m_fileio,
  m_Term_Ansi,
  m_DateTime,
  m_MenuInput;
  
Const
  Draw_Normal = 0;
  Draw_Block  = 1;
  Draw_Move   = 2;
  
Type
  TBlock = Record
    X1 : Byte;
    Y1 : Byte;
    X2 : Byte;
    Y2 : Byte;
  End;
  
Var 
  Block        : TBlock;
  PBlock       : TBlock;
  DrawMode     : Byte;
  CharSet      : String[10];
  Attr         : Byte;

Function ManageBlock(Var Screen: TOutput; Keyboard: TInput; ScAttr:Byte; CharsetNo:Byte):Boolean;

(*
y=r;
d= -r;
pixel(0,r);
for(x=1;x<r/sqrt(2);x++)
{  d+= 2x-1;
   if (d>=0) 
   {  y--;
      d -= 2y; /* Must do this AFTER y-- */
   }
   pixel(x,y);
}

https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/bresenham.html
*)



Implementation

Uses 
  blockart_dialogs,
  blockart_save;
  
procedure Circle(xa, ya, xb, yb : integer; color : byte; Var Image: TConsoleImageRec; C:Char);
var
i:integer;
tp:integer;
x1,x2,y2,y1:integer;
cb:char;
xc,yc,r  : byte;
begin
  r := (xb - xa) Div 2;
  xc := xa + r;
  yc := ya + r;
  
  tp:=trunc(2*pi*100);
  for i:=0 to tp do begin
    x1:=trunc(r*2.2*sin(i/100)+xc);
    y1:=trunc(r*1.02*cos(i/100)+yc);

    //gotoxy(x1,y1);
    if x2<>x1 then cb:='.' else
    if y2<>y1 then cb:='.' else
    cb:=c;
    x2:=x1;
    y2:=y1;
    
    If (x1>=1) and (x1<=80) and (y1>=1) and (y1<=25) then begin
      Image.Data[y1][x1].UnicodeChar:=Cb;
      Image.Data[y1][x1].Attributes:=color;
    end;
  end;
end;
  

Procedure Circle1(x1, y1, x2, y2 : integer; color : byte; Var Image: TConsoleImageRec);
Var
 r,y,x,d : Integer;
Begin
  r := (x2 - x1) Div 2;
  y := r;
  d := -r;
  Image.Data[y1][x1+r].UnicodeChar:='*';
//pixel(0,r);
  For x := 10 to trunc((r / Sqrt(2))*10) Do Begin
  //for(x=1;x<r/sqrt(2);x++)
  d := d + (2*x)-1;
   if ( d >= 0 ) Then Begin
     y := y - 1;
     d := d - 2* y;
   End;
   Image.Data[y1+y][x1+x].UnicodeChar:='*';
  End;
End;

Procedure Circle2(x1, y1, x2, y2 : integer; color : byte; Var Image: TConsoleImageRec; C:Char);
Var
 r,y,x,d,err : Integer;
 centerx, centery : Byte;
Begin
  
    x := (X2 - X1) Div 2;
    y := 0;
    err := 0;
    centerx := X1 + ((X2 - X1) Div 2);
    CenterY := Y1 + ((Y2 - Y1) Div 2);

    while (x >= y) Do Begin
        Image.Data[CenterY+y][CenterX+x].UnicodeChar:=C;
        Image.Data[CenterY+x][CenterX+y].UnicodeChar:=C;
        Image.Data[CenterY+x][CenterX-y].UnicodeChar:=C;
        Image.Data[CenterY+y][CenterX-x].UnicodeChar:=C;
        Image.Data[CenterY-y][CenterX-x].UnicodeChar:=C;
        Image.Data[CenterY-x][CenterX-y].UnicodeChar:=C;
        Image.Data[CenterY-x][CenterX+y].UnicodeChar:=C;
        Image.Data[CenterY-y][CenterX+x].UnicodeChar:=C;
        
        Image.Data[CenterY+y][CenterX+x].Attributes:=color;
        Image.Data[CenterY+x][CenterX+y].Attributes:=color;
        Image.Data[CenterY+x][CenterX-y].Attributes:=color;
        Image.Data[CenterY+y][CenterX-x].Attributes:=color;
        Image.Data[CenterY-y][CenterX-x].Attributes:=color;
        Image.Data[CenterY-x][CenterX-y].Attributes:=color;
        Image.Data[CenterY-x][CenterX+y].Attributes:=color;
        Image.Data[CenterY-y][CenterX+x].Attributes:=color;
    
        y := (Y + 1);
        err := Err + 1 + 2*y;
        if (2*(err-x) + 1 > 0) Then Begin
            x := x - 1;
            err := err + 1 - 2*x;
        End;
    End;

End;
  
procedure Line(x1, y1, x2, y2 : integer; color : byte; Var Image: TConsoleImageRec; C:Char);
var i, deltax, deltay, numpixels,
	d, dinc1, dinc2,
	x, xinc1, xinc2,
	y, yinc1, yinc2 : integer;
begin

  { Calculate deltax and deltay for initialisation }
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  { Initialize all vars based on which is the independent variable }
  if deltax >= deltay then
	begin

	  { x is independent variable }
	  numpixels := deltax + 1;
	  d := (2 * deltay) - deltax;
	  dinc1 := deltay Shl 1;
	  dinc2 := (deltay - deltax) shl 1;
	  xinc1 := 1;
	  xinc2 := 1;
	  yinc1 := 0;
	  yinc2 := 1;
	end
  else
	begin

	  { y is independent variable }
	  numpixels := deltay + 1;
	  d := (2 * deltax) - deltay;
	  dinc1 := deltax Shl 1;
	  dinc2 := (deltax - deltay) shl 1;
	  xinc1 := 0;
	  xinc2 := 1;
	  yinc1 := 1;
	  yinc2 := 1;
	end;

  { Make sure x and y move in the right directions }
  if x1 > x2 then
	begin
	  xinc1 := - xinc1;
	  xinc2 := - xinc2;
	end;
  if y1 > y2 then
	begin
	  yinc1 := - yinc1;
	  yinc2 := - yinc2;
	end;

  { Start drawing at  }
  x := x1;
  y := y1;

  { Draw the pixels }
  for i := 1 to numpixels do
	begin
	  Image.Data[y][x].UnicodeChar:=C;
    Image.Data[y][x].Attributes:=Color;
	  if d < 0 then
		begin
		  d := d + dinc1;
		  x := x + xinc1;
		  y := y + yinc1;
		end
	  else
		begin
		  d := d + dinc2;
		  x := x + xinc2;
		  y := y + yinc2;
		end;
	end;
end;  

Procedure SetCharSet(No:Byte);
Begin
  Case No Of
    1:  Charset:=Chr(218)+Chr(191)+Chr(192)+Chr(217)+Chr(196)+Chr(179)+Chr(195)+Chr(180)+Chr(193)+Chr(194);
    2:  Charset:=Chr(201)+Chr(187)+Chr(200)+Chr(188)+Chr(205)+Chr(186)+Chr(199)+Chr(185)+Chr(202)+Chr(203);
    3:  Charset:=Chr(213)+Chr(184)+Chr(212)+Chr(190)+Chr(205)+Chr(179)+Chr(198)+Chr(189)+Chr(207)+Chr(209);
    4:  Charset:=Chr(197)+Chr(206)+Chr(216)+Chr(215)+Chr(159)+Chr(233)+Chr(155)+Chr(156)+Chr(153)+Chr(239);
    5:  Charset:=Chr(176)+Chr(177)+Chr(178)+Chr(219)+Chr(220)+Chr(223)+Chr(221)+Chr(222)+Chr(254)+Chr(249);
    6:  Charset:=Chr(214)+Chr(183)+Chr(211)+Chr(189)+Chr(196)+Chr(186)+Chr(199)+Chr(182)+Chr(208)+Chr(210);
    7:  Charset:=Chr(174)+Chr(175)+Chr(242)+Chr(243)+Chr(244)+Chr(245)+Chr(246)+Chr(247)+Chr(240)+Chr(251);
    8:  Charset:=Chr(166)+Chr(167)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(248)+Chr(252)+Chr(253);
    9:  Charset:=Chr(224)+Chr(225)+Chr(226)+Chr(235)+Chr(238)+Chr(237)+Chr(234)+Chr(228)+Chr(229)+Chr(230);
    10: Charset:=Chr(232)+Chr(233)+Chr(234)+Chr(155)+Chr(156)+Chr(157)+Chr(159)+Chr(145)+Chr(146)+Chr(247);
 End;
End;

Function GetFillMode(Screen: TOutput) : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Fill Mode ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('Attribute', 0);
  List.Add('ForeGround', 0);
  List.Add('BackGround', 0);
  List.Add('Character', 0);
  List.Add('Chr.And Atr.',0);

  List.Open (30, 11, 49, 17);
  List.Box.Close;

  Case List.ExitCode of
    #27 : GetFillMode := 0;
  Else
    GetFillMode := List.Picked;
  End;

  List.Free;
End;

Procedure DrawBlock(Screen: TOutput; Image: TConsoleImageRec; Str: String; Pick:Boolean; Under:Boolean);
Var
  x,y,a,b,t,z   : Byte;
  BufImg: TConsoleImageRec;
  OBlock: TBlock;
  w,h   : Byte;
Begin
  With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;

  Move(Image,BufImg,SizeOf(Image));
  
  If Pick = False Then Begin
    For x := a To b Do
      For y := t To z Do Begin
        BufImg.Data[y][x].Attributes := 112;
      End;
  End Else Begin
  w := b - a;
  h := z - t;
  For x := 0 To w Do
    For y := 0 To h Do Begin
      If Under Then Begin
        BufImg.Data[Block.Y1+y][Block.X1+x].Attributes := 112;
        If BufImg.Data[Block.Y1+y][Block.X1+x].UnicodeChar = ' ' Then
          BufImg.Data[Block.Y1+y][Block.X1+x].UnicodeChar := Image.Data[PBlock.Y1+y][PBlock.X1+x].UnicodeChar ;
      End Else Begin
        BufImg.Data[Block.Y1+y][Block.X1+x].Attributes := 112;
        BufImg.Data[Block.Y1+y][Block.X1+x].UnicodeChar := Image.Data[PBlock.Y1+y][PBlock.X1+x].UnicodeChar ;
      End;
    End;
  End;

  x := Screen.CursorX;
  y := Screen.CursorY;
  Screen.PutScreenImage(BufImg);
  Screen.WriteXYPipe(1,25,7,79,Str);
  Screen.CursorXY(x,y);

End;

Procedure CursorLeft(Screen: TOutput);
Begin
  If Screen.CursorX>1 Then Screen.CursorXY(Screen.CursorX-1,Screen.CursorY);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorRight(Screen: TOutput);
Begin
  If Screen.CursorX<80 Then Screen.CursorXY(Screen.CursorX+1,Screen.CursorY);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorUp(Screen: TOutput);
Begin
  If Screen.CursorY>1 Then Screen.CursorXY(Screen.CursorX,Screen.CursorY-1);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorDown(Screen: TOutput);
Begin
  If Screen.CursorY<25 Then Screen.CursorXY(Screen.CursorX,Screen.CursorY+1);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorPGDN(Screen: TOutput);
Begin
  Screen.CursorXY(Screen.CursorX,25);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorPGUP(Screen: TOutput);
Begin
  Screen.CursorXY(Screen.CursorX,1);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorHome(Screen: TOutput);
Begin
  Screen.CursorXY(1,Screen.CursorY);
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure CursorEnd(Screen: TOutput);
Begin
  Screen.CursorXY(80,Screen.CursorY);
  
  Block.X2 := Screen.CursorX;
  Block.Y2 := Screen.CursorY;
End;

Procedure EraseBlock(Var Image: TConsoleImageRec);
Var
  x,y   : Byte;
  a,b   : Byte;
  t,z   : Byte;
Begin
    With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
 For x := a To b Do
    For y := t To z Do Begin
      Image.Data[y][x].UnicodeChar:=' ';
      Image.Data[y][x].Attributes := 7;
    End;
End;

Procedure DBlock(Var Image: TConsoleImageRec);
Var
  x,y   : Byte;
  a,b   : Byte;
  t,z   : Byte;
Begin
    With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  For x := a To b Do Begin
    Image.Data[t][x].UnicodeChar:=#223;
    Image.Data[t][x].Attributes := 15+7*16;
  End;
  For x := a To b Do Begin
    Image.Data[z][x].UnicodeChar:=#220;
    Image.Data[z][x].Attributes := 8+7*16;
  End;
  For y:= t To z Do Begin
    Image.Data[y][a].UnicodeChar:=#219;
    Image.Data[y][a].Attributes := 15+7*16;
  End;
  For y:= t To z Do Begin
    Image.Data[y][b].UnicodeChar:=#219;
    Image.Data[y][b].Attributes := 8+7*16;
  End;
  Image.Data[t][a].UnicodeChar:=#219;
  Image.Data[t][a].Attributes := 15+7*16;
  Image.Data[t][b].UnicodeChar:=#220;
  Image.Data[t][b].Attributes := 8+7*16;
  Image.Data[z][a].UnicodeChar:=#223;
  Image.Data[z][a].Attributes := 15+7*16;
  Image.Data[z][b].UnicodeChar:=#219;
  Image.Data[z][b].Attributes := 8+7*16;
  
  For y := t + 1 To z -1 Do
    For x := a + 1 To b - 1 Do Begin
      Image.Data[y][x].UnicodeChar:=' ';
      Image.Data[y][x].Attributes := 0+7*16;
    End;
End;

Procedure OutLineBlock(Var Image: TConsoleImageRec);
Var
  x,y   : Byte;
  a,b   : Byte;
  t,z   : Byte;
Begin
    With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  For x := a To b Do Begin
    Image.Data[t][x].UnicodeChar:=CharSet[5];
    Image.Data[t][x].Attributes := Attr;
  End;
  For x := a To b Do Begin
    Image.Data[z][x].UnicodeChar:=CharSet[5];
    Image.Data[z][x].Attributes := Attr;
  End;
  For y:= t To z Do Begin
    Image.Data[y][a].UnicodeChar:=CharSet[6];
    Image.Data[y][a].Attributes := Attr;
  End;
  For y:= t To z Do Begin
    Image.Data[y][b].UnicodeChar:=CharSet[6];
    Image.Data[y][b].Attributes := Attr;
  End;
  Image.Data[t][a].UnicodeChar:=CharSet[1];
  Image.Data[t][a].Attributes := Attr;
  Image.Data[t][b].UnicodeChar:=CharSet[2];
  Image.Data[t][b].Attributes := Attr;
  Image.Data[z][a].UnicodeChar:=CharSet[3];
  Image.Data[z][a].Attributes := Attr;
  Image.Data[z][b].UnicodeChar:=CharSet[4];
  Image.Data[z][b].Attributes := Attr;
End;

Procedure FillBlock(Var Image: TConsoleImageRec; Screen: TOutput);
Var
  x,y   : Byte;
  fg,bg : Byte;
  r     : String;
  Keyboard : TInput;
  fc    : Char;
  a,b   : Byte;
  t,z   : Byte;
Begin
  With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  r := StrI2S(GetFillMode(Screen));
  Case r[1] Of
    '0': ;
    '1':  Begin
          For x := a To b Do
            For y := t To z Do Begin
                Image.Data[y][x].Attributes := Attr;
            End;
        End;
    '2':  Begin
          For x := a To b Do
            For y := t To z Do Begin
                fg := Image.Data[y][x].Attributes mod 16;
                bg := Attr mod 16;
                Image.Data[y][x].Attributes := Image.Data[y][x].Attributes - fg + bg;
            End;
        End;
    '3':  Begin
          For x := a To b Do
            For y := t To z Do Begin
                fg := Image.Data[y][x].Attributes div 16;
                bg := Attr div 16;
                Image.Data[y][x].Attributes := Image.Data[y][x].Attributes - (fg*16) + (bg*16);
            End;
        End;
    '4':  Begin
            Keyboard := Tinput.Create;
            fc := Chr(GetChar(Screen,Keyboard));
            For x := a To b Do
              For y := t To z Do 
                Image.Data[y][x].UnicodeChar := fc;
            Keyboard.Free;
        End;
    '5':  Begin
            Keyboard := Tinput.Create;
            fc := Chr(GetChar(Screen,Keyboard));
            For x := a To b Do
              For y := t To z Do Begin
                Image.Data[y][x].UnicodeChar := fc;
                Image.Data[y][x].Attributes  := Attr;
            End;
            Keyboard.Free;
        End;
  
  End;
End;

Procedure FlipX(Var Image: TConsoleImageRec);
Var
  x,y   : Byte;
  a,b   : Byte;
  t,z   : Byte;
  Img   : TConsoleImageRec;
Begin
    With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  Move(Image,Img,SizeOf(Image));
  For y := t To z Do
    For x := a To b Do Begin
      Img.Data[y][x].Attributes := Image.Data[y][a + (b - x)].Attributes;
      Img.Data[y][x].UnicodeChar := Image.Data[y][a + (b - x)].UnicodeChar;
    End;
      
  Move(Img,Image,SizeOf(Image));

End;

Procedure FlipY(Var Image: TConsoleImageRec);
Var
  x,y   : Byte;
  a,b   : Byte;
  t,z   : Byte;
  Img   : TConsoleImageRec;
Begin
    With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  Move(Image,Img,SizeOf(Image));
  For x := a To b Do
    For y := t To z Do Begin
      Img.Data[y][x].Attributes := Image.Data[t + (z - y)][x].Attributes;
      Img.Data[y][x].UnicodeChar := Image.Data[t + (z - y)][x].UnicodeChar;
    End;
      
  Move(Img,Image,SizeOf(Image));

End;

Procedure MoveBlock(Screen: TOutput; Var Image: TConsoleImageRec);
Var
  Img,Img2  : TConsoleImageRec;
  OBlock    : TBlock;
  Width     : Byte;
  Height    : Byte;
  x,y       : Byte;
  a,b       : Byte;
  t,z       : Byte;
  Keyboard  : TInput;
  Under     : Boolean;
Begin
  Under := False;
  With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  Width  := b - a;
  Height := z - t;
  
  OBlock.X1 := a;
  OBlock.X2 := b;
  OBlock.Y1 := t;
  OBlock.Y2 := z;
  
  Move(Image,Img,SizeOf(Image));
  Move(Image,Img2,SizeOf(Image));
  
  Keyboard := TInput.Create;
  Repeat
  DrawBlock(Screen,Image,'|08[|15O|08]|07ver |08[|15U|08]|07nder |08[|15ESC|08] |07Cancel |08[|15ENTER|08] |07Confirm',True,Under);
    Case Keyboard.ReadKey Of
      #00 : Begin
              
              Case Keyboard.Readkey Of
                KeyLeft : If a > 1 Then Begin
                            a := a - 1;
                            b := b - 1;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                Keyright: If a + Width < 80 Then Begin
                            a := a + 1;
                            b := b + 1;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                KeyUp   : If t > 1 Then Begin
                            t := t - 1;
                            z := z - 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyDown : If t < 24 - Height Then Begin
                            t := t + 1;
                            z := z + 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyPGUP : Begin
                            t := 1;
                            z := Height + 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyPGDN : Begin
                            t := 25 - Height;
                            z := 25;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyHome : Begin
                            a := 1;
                            b := 1 + Width;                            
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                KeyEnd : Begin
                            a := 80 - Width;
                            b := 80;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
              End;              
            End;
   'u','U': Under := True;
   'o','O': Under := False;
      #27 : Break;
      #13 : Begin
              //Erase Block on Buffer
              For x := OBlock.X1 To OBlock.X2 Do
                For y := OBlock.Y1 To OBlock.Y2 Do Begin
                  Img.Data[y][x].UnicodeChar:=' ';
                  Img.Data[y][x].Attributes := 7;
                End;
              For y := 0 To Height Do
                For x := 0 To Width Do Begin
                  If Not Under Then Begin
                    Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                    Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                  End Else
                    If Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar<> ' ' Then Begin
                      //Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      //Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End Else Begin
                      Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End;
                End;
              
              Move(Img,Image,SizeOf(Img));
              Break;
            End;
    End;
  Until False;
  Keyboard.Free;
End;

Procedure CopyBlock(Screen: TOutput; Var Image: TConsoleImageRec);
Var
  Img,Img2  : TConsoleImageRec;
  OBlock    : TBlock;
  Width     : Byte;
  Height    : Byte;
  x,y       : Byte;
  a,b       : Byte;
  t,z       : Byte;
  Keyboard  : TInput;
  Under     : Boolean;
  S         : String;
  XFerPath  : String;
  
  Function LoadSelection(Screen: TOutput; Var Orig: TConsoleImageRec; Filename: String):Boolean;
  Var
    buf : TConsoleImageRec;
    Count1  : Byte;
    Count2  : Byte;
  Begin
    Screen.ClearScreen;
    LoadANSIFile(Screen,Filename);
    Screen.GetScreenImage(1,1,80,25,Buf);
    Repeat
      DrawBlock(Screen,Buf,'|08[|15ESC|08] |07Cancel/Stop |08[|15ENTER|08] |07Confirm',False,Under);
      Case Keyboard.ReadKey Of
        #00 : Begin
                Case Keyboard.Readkey Of
                  KeyLeft : If a > 1 Then Begin
                              a := a - 1;
                              b := b - 1;
                              Block.X1 := a;
                              Block.X2 := b;
                            End;
                  Keyright: If a + Width < 80 Then Begin
                              a := a + 1;
                              b := b + 1;
                              Block.X1 := a;
                              Block.X2 := b;
                            End;
                  KeyUp   : If t > 1 Then Begin
                              t := t - 1;
                              z := z - 1;
                              Block.Y1 := t;
                              Block.Y2 := z;
                            End;
                  KeyDown : If t < 24 - Height Then Begin
                              t := t + 1;
                              z := z + 1;
                              Block.Y1 := t;
                              Block.Y2 := z;
                            End;
                  KeyPGUP : Begin
                              t := 1;
                              z := Height + 1;
                              Block.Y1 := t;
                              Block.Y2 := z;
                            End;
                  KeyPGDN : Begin
                              t := 25 - Height;
                              z := 25;
                              Block.Y1 := t;
                              Block.Y2 := z;
                            End;
                  KeyHome : Begin
                              a := 1;
                              b := 1 + Width;                            
                              Block.X1 := a;
                              Block.X2 := b;
                            End;
                  KeyEnd : Begin
                              a := 80 - Width;
                              b := 80;
                              Block.X1 := a;
                              Block.X2 := b;
                            End;
                End;       
              End;
        #27 : Begin
                Result := False;
                Break;
              End;
        #13 : Begin
        
                For Count1 := 0 to Height Do Begin
                  For Count2 := 0 to Width Do Begin
                    Orig.Data[OBlock.Y1+Count1][Oblock.X1+COunt2].UnicodeChar := Buf.Data[Block.Y1+Count1][Block.X1+COunt2].UnicodeChar;
                    Orig.Data[OBlock.Y1+Count1][Oblock.X1+COunt2].Attributes := Buf.Data[Block.Y1+Count1][Block.X1+COunt2].Attributes;
                  End;
                End;
                Result := True;
                Break;
              End;
      End;
    Until False;
  End;
  
  Procedure SaveSelection(Screen: TOutput; Image: TConsoleImageRec);
  Var 
    buf : TConsoleImageRec;
    Filename: String;
    OutFile : Text;
    x,y     : Byte;
    OldAt   : Byte;
    FG,BG   : Byte;
    Attr    : Byte;
    Count1  : Byte;
    Count2  : Byte;
    xferpath:String;
  Begin
    //SaveScreen(GetSaveFileName(' Save Selection ','selection.ans'),Image,Screen.TextAttr);
    GetDir(0,xferpath);
    Filename := GetSaveFileName(Screen,' Save Selection ','selection.ans',xferpath);
    If Filename = '' Then Exit;
    Attr := 7;
      Assign     (OutFile, Filename);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      For Count1 := Block.Y1 to Block.Y2 Do Begin
        For Count2 := Block.X1 to Block.X2 Do Begin
          If OldAt <> Image.Data[Count1][Count2].Attributes then Begin
            FG := Image.Data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.Data[Count1][Count2].Attributes div 16);
            //Write(Outfile,'|'+StrPadL(StrI2S(FG),2,'0'));
            //Write(Outfile,'|'+StrPadL(StrI2S(BG),2,'0'));
            Write(Outfile,Ansi_Color(FG,Attr));
            Write(Outfile,Ansi_Color(BG,Attr));
            //Write(Outfile,Ansi_Color(Image.Data[Count1][Count2].Attributes));
          End;
          Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
          OldAt := Image.Data[Count1][Count2].Attributes 
        End;
        Writeln(Outfile,'');
      End;
      close(Outfile);
End;
  
  
Begin
  Under := False;
  GetDir(0,Xferpath);
  With Block Do Begin
    a := X1;
    b := X2;
    If (x2 <= x1) Then Begin
      a := X2;
      b := X1;
    End;
    t := Y1;
    z := Y2;
    If Y2 <= Y1 Then Begin
      t  := Y2;
      z  := Y1;    
    End;
  End;
  Width  := b - a;
  Height := z - t;
  
  OBlock.X1 := a;
  OBlock.X2 := b;
  OBlock.Y1 := t;
  OBlock.Y2 := z;
  
  Move(Image,Img,SizeOf(Image));
  Move(Image,Img2,SizeOf(Image));
  
  Keyboard := TInput.Create;
  Repeat
  DrawBlock(Screen,Image,'|08[|15O|08]|07ver |08[|15U|08]|07nder |08[|15C|08]|07lone |08[|15P|08]|07aste |08[|15L|08]|07oad |08[|15S|08]|07ave |08[|15ESC|08] |07Cancel/Stop',True,Under);
    Case Keyboard.ReadKey Of
      #00 : Begin
              Case Keyboard.Readkey Of
                KeyLeft : If a > 1 Then Begin
                            a := a - 1;
                            b := b - 1;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                Keyright: If a + Width < 80 Then Begin
                            a := a + 1;
                            b := b + 1;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                KeyUp   : If t > 1 Then Begin
                            t := t - 1;
                            z := z - 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyDown : If t < 24 - Height Then Begin
                            t := t + 1;
                            z := z + 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyPGUP : Begin
                            t := 1;
                            z := Height + 1;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyPGDN : Begin
                            t := 25 - Height;
                            z := 25;
                            Block.Y1 := t;
                            Block.Y2 := z;
                          End;
                KeyHome : Begin
                            a := 1;
                            b := 1 + Width;                            
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
                KeyEnd : Begin
                            a := 80 - Width;
                            b := 80;
                            Block.X1 := a;
                            Block.X2 := b;
                          End;
              End;       
            End;
      #27 : Break;
   'u','U': Under := True;
   'o','O': Under := False;      
  'p','P' : Begin
              For y := 0 To Height Do
                For x := 0 To Width Do Begin
                  If Not Under Then Begin
                    Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                    Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                  End Else
                    If Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar<> ' ' Then Begin
                      //Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      //Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End Else Begin
                      Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End;
                End;
              Move(Img,Image,SizeOf(Img));
              Break;
            End;
  'c','C' : Begin
              For y := 0 To Height Do
                For x := 0 To Width Do Begin
                  If Not Under Then Begin
                    Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                    Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                  End Else
                    If Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar<> ' ' Then Begin
                      //Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      //Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End Else Begin
                      Img.Data[Block.Y1+y][Block.X1+x].UnicodeChar:=Img2.Data[OBlock.Y1+y][Oblock.X1+x].UnicodeChar;
                      Img.Data[Block.Y1+y][Block.X1+x].Attributes :=Img2.Data[OBlock.Y1+y][Oblock.X1+x].Attributes;
                    End;
                End;
              Move(Img,Image,SizeOf(Img));
            End;
  'l','L' : Begin
              S := GetUploadFileName(Screen,'Load File',xFerPath);
              If S = '' Then Break;
              If LoadSelection(Screen,Image,S) Then Break;
            End;
  's','S' : Begin
              SaveSelection(Screen,Image);
            End;
    End;
  Until False;
  Keyboard.Free;
End;

Function ManageBlock(Var Screen: TOutput; Keyboard: TInput; ScAttr:Byte; CharsetNo:Byte):Boolean;
Var
  Image   : TConsoleImageRec;
  OrX,Ory : Byte;
  r       : Boolean;
  a,b,t,z : Byte;
  Ch      : Char;
  
  Procedure EnableBlock;
  Begin
    DrawMode := Draw_Block;
    Screen.GetScreenImage(1,1,80,25,Image);
    With Block Do Begin
      X1 := Screen.CursorX;
      Y1 := Screen.CursorY;
      X2 := X1;
      Y2 := Y1;
    End;
  End;
  
  Procedure DisableBlock;
  Begin
    DrawMode := Draw_Normal;
    With Block Do Begin
      X1 := 0;
      Y1 := 0;
      X2 := X1;
      Y2 := Y1;
    End;
    Orx := Screen.CursorX;
    OrY := Screen.CursorY;
    Screen.PutScreenImage(Image);
    Screen.CursorXY(OrX,OrY);
  End;
  
Begin
  EnableBlock;
  SetCharSet(CharSetNo);
  Attr := ScAttr;
  r    := False;
  Drawmode := Draw_Normal;
  Repeat
  DrawBlock(Screen,Image,'|07[|15M|07]ove |07[|15C|07]opy |07[|15E|07]rase |07[|15F|07]ill |07[|15B|07]ox |07[|15X|07]Flip |07[|15Y|07]Flip |07[|15L|07]ine Ci|07[|15R|07]cle |07[|153|07]D |07[|15ESC|07]',False,False);
    Case Keyboard.ReadKey Of
      #00: Begin
              Case Keyboard.Readkey Of
                KeyUp   : CursorUp(Screen);
                KeyDown : CursorDown(Screen);
                KeyLeft : CursorLeft(Screen);
                KeyRight: CursorRight(Screen);
                KeyHome : CursorHome(Screen);
                KeyEnd  : CursorEnd(Screen);
                KeyPGUP : CursorPGUP(Screen);
                KeyPGDN : CursorPGDN(Screen);
              End;
            
           End;
      #27: Break;
  'e','E': Begin
              EraseBlock(Image);
              r := True;
              Break;
           End;
  'b','B': Begin
              OutLineBlock(Image);
              r := True;
              Break;              
           End;
      '3': Begin
              DBlock(Image);
              r := True;
              Break;              
           End;           
  'f','F': Begin
              FillBlock(Image,Screen);
              r := True;
              Break;              
           End;
  'x','X': Begin
              FlipX(Image);
              r := True;
              Break;              
           End;
  'y','Y': Begin
              FlipY(Image);
              r := True;
              Break;              
           End; //Circle(x1, y1, x2, y2 : integer; color : byte; Var Image: TConsoleImageRec);
  'l','L': Begin
              Screen.WriteXYPipe(1,25,7,79,'|07[|15T|07]op - Bottom  |07[|15B|07]ottom - Top |07[|15ESC|07] Cancel');
              ch := Chr(GetChar(Screen,Keyboard));
              Repeat 
              Case Keyboard.Readkey Of
                #27    : Break;
                't','T':  Begin Line(Block.X1,Block.Y1,Block.X2,Block.Y2,ScAttr,Image,ch);Break;End;
                'b','B':  Begin Line(Block.X1,Block.Y2,Block.X2,Block.Y1,ScAttr,Image,ch);Break;End;
              End;
              Until False;
              R := True;
              Break;
           End;
  'r','R': Begin
              ch := Chr(GetChar(Screen,Keyboard));
              Circle(Block.X1,Block.Y1,Block.X2,Block.Y2,ScAttr,Image,ch);
              R := True;
              Break;
           End;
  'm','M': Begin
              DrawMode := Draw_Move;
              PBlock := Block;
               With PBlock Do Begin
                a := X1;
                b := X2;
                If (x2 <= x1) Then Begin
                  a := X2;
                  b := X1;
                  X1 := a;
                  X2 := b;
                End;
                t := Y1;
                z := Y2;
                If Y2 <= Y1 Then Begin
                  t  := Y2;
                  z  := Y1;
                  Y1 := t;
                  Y2 := z;
                End;
              End;
              MoveBlock(Screen,Image);
              r := True;
              DrawMode := Draw_Normal;
              Break;              
           End;
  'c','C': Begin
              DrawMode := Draw_Move;
              PBlock := Block;
              With PBlock Do Begin
                a := X1;
                b := X2;
                If (x2 <= x1) Then Begin
                  a := X2;
                  b := X1;
                  X1 := a;
                  X2 := b;
                End;
                t := Y1;
                z := Y2;
                If Y2 <= Y1 Then Begin
                  t  := Y2;
                  z  := Y1;
                  Y1 := t;
                  Y2 := z;
                End;
              End;
              CopyBlock(Screen,Image);
              r := True;
              DrawMode := Draw_Normal;
              Break;              
           End;
    End;
  Until False;
  DisableBlock;
  ManageBlock := r;
End;


Begin
End.
