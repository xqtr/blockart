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

Unit blockart_tdf;

{$I M_OPS.PAS}

Interface

Uses
  DOS,
  m_strings,
  m_output,
  m_fileio;
  
Const
	HeaderOffset = 233;
  
type 
  TTDFont = record
	A 			  	: char;  // fixed : 13h
	typo		  	: Array[1..18] of char;
	B 			  	: char;	// fixed : 1Ah
	fs			  	: array[1..4] of byte;  // fixed: 55 AA 00 FF
	NameLen			: byte;
	FontName		: array[1..12] of char;
	nouse			  : array[1..4] of byte;  // 00 00 00 00
	FontType		: byte; // Font Type (byte): 00 = Outline, 01 = Block, 02 = Color
	Spacing			: byte; // 00 to 40d or 
	BlockSize		: word;	// Block Size (Word, Little Endian) Size of character data after main
							// font definition block, including terminating 0 if followed by another
							// font (last font in collection is not Null terminated
	CharAddr		: Array[1..94] of word;
							// 2 bytes (Word, Little Endian) for each character from ASC(33)
							//(“!”) to ASC(126) (“~”) (94 characters total) with the offset
							//(starting at 0) after the font header definition where the character
							// data star
	
	//At 233 begins the font data
  end;

Type
  TFontChar = Record
    width  : byte; 				// 1 <= W <= 30 (1Eh)
    height : byte;				// 1 <= H <= 12 (0Ch)
  end;
  
Var
  Screen    : TOutput;
  Font      : TTDFont;
  ChWidth   : Byte;
  ChHeight  : Byte;

Function GetTDFHeader(f:String):Boolean;
Function TDFWriteCharCL(x,y:byte;c:char):byte;
Function TDFWriteCharBL(x,y:byte;c:char):byte;
Procedure TDFWriteStr(x,y:byte; s:string);

Implementation

Uses blockart_dialogs;

Var 
  Datapath 		: string;
  FontFile		: String;
  
Function GetTDFHeader(f:string):Boolean;
Var
  fptr : file;
  i    : integer;
begin
  if not fileexist(f) then begin
	 Result := False;
   Exit;
  end;
  fontfile:=f;
  Assign(fptr,f);
  {$I-} Reset (fptr, 1); {$I+}
   
  If IOResult <> 0 Then Begin
    ShowMsgBox(0,'Error Opening File!',Screen);
    Exit; 
  End;
  BlockRead(fptr,font,sizeof(font));
  Close(fptr);
  Font.Spacing := 0;
end;

Function TDFWriteCharBL(x,y:byte;c:char):byte;
Var
  fptr : file;
  i : integer;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  sx,sy:byte;
  asc:byte;
begin
  if c=' ' then begin
    tdfwritecharBL:=1;
    exit;
  end;
  asc:=ord(c)-32;
  assign(fptr,fontfile);
  Reset(fptr,1);
  If IoResult <> 0 Then Begin
    ShowMsgBox(0,'Error Opening File!',Screen);
    Exit;   
  End;
  Try
      Seek(fptr,headeroffset+font.charaddr[asc]);
      BlockRead(fptr,FChar,sizeof(Fchar));
      ChWidth  := FChar.Width;
      ChHeight := FChar.Height;
      tbyte[1]:=32;
      tbyte[2]:=32;
      Screen.CursorXY(x,y);
      while (tbyte[1]<>0) and (not eof(fptr)) do begin
      BlockRead(fptr,tbyte[1],1);
      if tbyte[1]=13 then begin
        Screen.CursorXY(x,Screen.CursorY+1);
        if Screen.CursorY>25 then break;
      end
       else begin
        BlockRead(fptr,tbyte[2],1);
        Screen.TextAttr:=tbyte[2] mod 16 + tbyte[2] - (tbyte[2] mod 16);
        Screen.WriteChar(chr(tbyte[1]));
        if Screen.CursorX>79 then break;
      end;
      end ;
      Close(fptr);
  Except
      Close(fptr);
  End;
  tdfwritecharbl:=fchar.width;
end;

Function TDFWriteCharCL(x,y:byte;c:char):byte;
Var
  fptr : file;
  i : integer;
  FChar : TFontChar;
  tbyte : array[1..2] of byte;
  sx,sy:byte;
  asc:byte;
  r : LongInt;
begin
  if c=' ' then begin
    Result:=1;
    exit;
  end;
  asc:=ord(c)-32;
  Assign(fptr,fontfile);
  Reset(fptr,1);
  
  If IOResult <> 0 Then Begin
    ShowMsgBox(0,'Error Opening File!',Screen);
    Exit; 
  End;
  Try
    Seek(fptr,headeroffset+font.charaddr[asc]);
    BlockRead(fptr,FChar,sizeof(Fchar),r);
    ChWidth  := FChar.Width;
    ChHeight := FChar.Height;
    tbyte[1]:=32;
    Screen.CursorXY(x,y);
    while (tbyte[1]<>0) and (not eof(fptr)) do begin
    BlockRead(fptr,tbyte[1],1,r);
    if tbyte[1]=13 then begin
      Screen.CursorXY(x,Screen.CursorY+1);
      if Screen.CursorY>25 then break;
    end
     else begin
      Screen.WriteChar(chr(tbyte[1]));
      if Screen.CursorX>79 then break;
    end;
    end ;
    Close(fptr);
  Except
    Close(fptr);
  End;
  Result:=fchar.width;
end;

procedure TDFWriteStr(x,y:byte; s:string);
Var
  i:byte;
  sx,sy:byte;
begin
  Screen.CursorXY(x,y);
  sx:=x;
  sy:=y;
  case font.fonttype of
  2: begin  
		  for i:=1 to length(s) do begin
			sx:=sx+tdfwritecharBL(sx,y,s[i])+font.spacing;
		  end;
	 end;
  1: begin  
		  for i:=1 to length(s) do begin
			sx:=sx+tdfwritecharCL(sx,y,s[i])+font.spacing;
		  end;
	 end;
   end;
end;

Begin
  FillChar(Font,Sizeof(Font),#0);
End.
