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

Unit blockart_gbext;

{$I M_OPS.PAS}

Interface

Uses
  DOS,
  m_strings,
  m_output,
  m_types,
  m_fileio;
  
Var
    Screen      : TOutput;
    FontFolder  : String;

Procedure GBExtract(Var Img:TConsoleImageRec);

Implementation

Uses  
    m_Input,
    m_Bits,
    blockart_dialogs;

const
  width   = 16;
  Height  = 16;
  bpp     = 2;
  
  offx = 0;
  offy = 1;
  
  cx = 28;
	cy = 8;
	cwidth = 47;
	cheight = 13;
	cch = ' ';
  
var
  Datapath 		: string;
  ROM         : File;
  RomFile     : String;
  EOFLoc      : Integer;
  Loc         : Integer;

Function FindEOFLoc:Integer;
Var
  fptr : File;
  d   : byte;
Begin
  Result := 0;
  Assign(fptr,ROMFile);
  {$I-} Reset (fptr, 1); {$I+}
  While not EOF(fptr) Do Begin
    BlockRead(fptr,d,1);
    Result := Result + 1;
  End;
  Close(fptr);
End;

Function OpenROMFile(f:string):Boolean;
begin
  if not fileexist(ROMFile) then begin
	 Result := False;
   Exit;
  end;
  Assign(ROM,f);
  {$I-} Reset (ROM, 1); {$I+}
   
  If IOResult <> 0 Then Begin
    Result:=False;
    Exit; 
  End;
  //BlockRead(ROM,font,sizeof(font));
  result := True;
end;

Procedure CloseROMFile;
Begin
  Close(ROM);
End;
  
Procedure ClearArea;
var o:byte;
Begin
  for o:=1 to cheight do begin
    Screen.WriteXY(cx,cy+o,7,strrep(cch,cwidth));
  end;
end;

Procedure PutPixel(x,y : Byte; Color:Byte);
Var
  Cl : Byte;
  c  : Char;
  cc : Byte;
Begin
  Case Color Of
    0 : Cl := 15;
    1 : Cl := 7;
    2 : Cl := 8;
    3 : Cl := 0;
  End;
  Screen.WriteXY(offx+x,offy+y,cl,Chr(219));
End;

Function GBTile(loc,x,y: Integer):Byte;
Var 
  r,c,b : Integer;
  Data  : Array[1..16] Of Byte;
  Color : Byte;
Begin	
  color := 3;
  If Loc + 16 >= EOFLoc Then Exit;
	Seek(ROM, Loc);
	BlockRead(ROM, data, 16);
  r := 0;
	For b := 0 To 7 Do Begin
    For c := 0 To 7 Do Begin
      If BitCheck(c,1,Data[r]) And BitCheck(c,1,Data[r+1]) Then Color :=3 else
        If BitCheck(c,1,Data[r]) And Not BitCheck(c,1,Data[r+1]) Then Color :=1 else
          If Not BitCheck(c,1,Data[r]) And BitCheck(c,1,Data[r+1]) Then Color :=2 else
            Color := 0;
      PutPixel(x+(7-c),y+(r div 2),Color);
    End;
    r := r + 2;
  End;
End;

Procedure DrawFile(L:Integer);
Var
  r,c : Integer;
Begin
  For r := 0 to 2 Do Begin
    For c := 0 To 11 Do Begin
      GBTile(loc+((c+(r*Width))*(8*bpp)), c*8, r*8);
    End;
  End;

End;

Procedure GBExtract(Var Img:TConsoleImageRec);
Var
  Keyboard  : TInput;
  Done      : Boolean;
  bpp       : Byte = 2;
    
Begin
  Screen.ClearScreen;
  Keyboard  := Tinput.Create;
  Done := False;
  
  GetDir(0,DataPath);
  RomFile := GetUploadFilename(Screen,'ROM File',DataPath);

  If RomFile = '' Then Begin
    ShowMsgBox(0,'No ROM Specified',Screen);
    Exit;
  End;
 
  If Not OpenROMFile(RomFile) Then Begin
    ShowMsgBox(0,'Error Opening File!',Screen);
    Exit;
  End;
  
  EOFLoc  := FindEOFLoc;
  Loc     := 0;
 
Repeat
  DrawFile(Loc);
  //GBTile(Loc,40,12);
  Screen.WriteXY(1,25,8,StrI2S(Loc)+ ' / '+StrI2S(EOFLoc));
  screen.WriteXYPipe(17,25,7,62,'|15W|08/|15E |07Scroll Line |15S|08/|15D |07Scroll Pos. |15X|08/|15C |07Scroll Page |15ENTER |07Select |15ESC |07Quit');
  Case Keyboard.ReadKey Of
    #00 : Case Keyboard.ReadKey Of
            #45: Done := True;
        
          End;
    'w' : If loc > loc - ((bpp*8)*Width) Then Loc := Loc - ((bpp*8)*Width);
    'e' : If Loc + ((bpp*8)*Width) < EOFLoc Then Loc := Loc + ((bpp*8)*Width);
    's' : If Loc > 0 Then Loc := Loc - 1;
    'd' : If Loc + 1 < EOFLoc - 1 Then Loc := Loc + 1;
    'x' : If Loc - ((bpp*8)*Width)*Height > 0 Then Loc := Loc - ((bpp*8)*Width)*Height;
    'c' : If Loc + ((bpp*8)*Width)*Height < EOFLoc - 1 Then Loc := Loc + ((bpp*8)*Width)*Height;
    #13 : Begin
            Screen.GetScreenImage(1,1,80,25,Img);
            Done := True;
          End;
    #27 : Begin
            Done := True;
          End;
  End;
  
  Until Done;
  Keyboard.Free;
  Screen.CursorXY (1, 23);
  CloseROMFile;
End;


Begin


End.
