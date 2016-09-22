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

Unit blockart_save;

{$I M_OPS.PAS}

Interface

Uses
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
  blockart_dialogs,
  m_MenuInput;

Var
    SaveCur : Boolean;  
  
Function Ansi_Color (B : Byte; Attr: Byte) : String;  
Procedure SaveScreenANSI(Filename: String; Image: TConsoleImageRec; Screen:TOutput; GetPrep:Boolean);
Procedure LoadANSIFile(Screen: TOutput; Filename: String);
Procedure SaveScreenMYSTIC(Filename: String; Image: TConsoleImageRec; Screen:TOutput);
Procedure SaveScreenTEXT(Filename: String; Image: TConsoleImageRec;Screen:TOutput);
Procedure SaveScreenPascal(Filename: String; Image: TConsoleImageRec; Screen:TOutput);
Function GetLineText (Image: TConsoleImageRec; Line: Byte) : String;
Function GetLineLength (Image: TConsoleImageRec; Line:Byte) : Byte;
Procedure SetLineText (Var Image: TConsoleImageRec; Start: Byte; Line: LongInt; Str: String; Attr: Byte);
  
Implementation
  
Const EOL = #13#10;

Const
 ANSIClrScr = #27+'[2J';
 ANSIHome   = #27+'[1;1H';
 MysticClrScr  = '|CL';
 MysticNoPause = '|PO';
 MysticHome    = '|[X01|[Y01';
 
Function GetLineLength (Image: TConsoleImageRec; Line:Byte) : Byte;
Begin
  Result := 80;

  While (Result > 0) and (Image.Data[Line][Result].UnicodeChar = #0) Do
    Dec (Result);
End; 
 
Function GetLineText (Image: TConsoleImageRec; Line: Byte) : String;
Var
  Count : Byte;
Begin
  Result := '';

  For Count := 1 to GetLineLength(Image, Line) Do
    If Image.Data[Line][Count].UnicodeChar = #0 Then
      Result := Result + ' '
    Else
      Result := Result + Image.Data[Line][Count].UnicodeChar;
End;
 
Function IsBlankLine (Image: TConsoleImageRec; Line:Byte) : Boolean;
Var
  EndPos : Byte;
  Data   : Array[1..255] of RecAnsiBufferChar absolute Line;
Begin
  EndPos := 80;

  While (EndPos > 0) and (Image.Data[Line][EndPos].UnicodeChar = #0) Do
    Dec (EndPos);

  Result := EndPos = 0;
End;

Function IsAnsiLine (Image: TConsoleImageRec; Line: LongInt) : Boolean;
Var
  Count : Byte;
Begin
  Result := False;

  For Count := 1 to 80 Do
    If (Ord(Image.Data[Line][Count].UnicodeChar) < 32) or (Ord(Image.Data[Line][Count].UnicodeChar) > 128) Then Begin
      Result := True;
      Exit;
    End;
End; 

Procedure SetLineText (Var Image: TConsoleImageRec; Start: Byte; Line: LongInt; Str: String; Attr: Byte);
Var
  Count : Byte;
Begin
  FillChar (Image.Data[Line], SizeOf(Image.Data[Line]), #0);

  For Count := 1 to Length(Str) Do Begin
    Image.Data[Line][Start+Count].UnicodeChar   := Str[Count];
    Image.Data[Line][Start+Count].Attributes    := Attr;
  End;
End;

Function FindLastLine(Image: TConsoleImageRec):Byte;
Var
  LastLine : Byte;
Begin
  LastLine := 25;

  While (LastLine > 1) And IsBlankLine(Image,LastLine) Do
    Dec(LastLine);

  Result := LastLine;
End;

Function Ansi_Color (B : Byte; Attr: Byte) : String;
  Var
    S : String;
  Begin
    S          := '';
    Ansi_Color := '';

    Case B of
      00: S := #27 + '[0;30m';
      01: S := #27 + '[0;34m';
      02: S := #27 + '[0;32m';
      03: S := #27 + '[0;36m';
      04: S := #27 + '[0;31m';
      05: S := #27 + '[0;35m';
      06: S := #27 + '[0;33m';
      07: S := #27 + '[0;37m';
      08: S := #27 + '[1;30m';
      09: S := #27 + '[1;34m';
      10: S := #27 + '[1;32m';
      11: S := #27 + '[1;36m';
      12: S := #27 + '[1;31m';
      13: S := #27 + '[1;35m';
      14: S := #27 + '[1;33m';
      15: S := #27 + '[1;37m';
    End;

    If B in [00..07] Then B := (Attr SHR 4) and 7 + 16;

    Case B of
      16: S := S + #27 + '[40m';
      17: S := S + #27 + '[44m';
      18: S := S + #27 + '[42m';
      19: S := S + #27 + '[46m';
      20: S := S + #27 + '[41m';
      21: S := S + #27 + '[45m';
      22: S := S + #27 + '[43m';
      23: S := S + #27 + '[47m';
    End;

    Ansi_Color := S;
  End;

Procedure SaveScreenANSI(Filename: String; Image: TConsoleImageRec; Screen:TOutput; GetPrep:Boolean);
  Var
    OutFile   : Text;
    FG,BG     : Byte;
    OldAT     : Byte;
    Outname   : String;
    Count1    : Integer;
    Count2    : Integer; 
    Prep      : Byte;
    LastLine  : Byte;
    LineLen   : Byte;
  Begin
    If GetPrep Then 
      Prep := GetANSIPrep(Screen);
    Outname := Filename; //GetSaveFileName(' Save Screen ','blockart.ans');
    if Outname <> '' then Begin
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      If SaveCur Then LastLine := Screen.CursorY
        Else LastLine := FindLastLine(Image);
      If Prep = 1 Then  Write(Outfile, ANSIClrScr);
      For Count1 := 1 to LastLine Do Begin
        LineLen := GetLineLength(Image,Count1);
        For Count2 := Image.X1 to 79 Do Begin
          If OldAt <> Image.Data[Count1][Count2].Attributes then Begin
            FG := Image.Data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.Data[Count1][Count2].Attributes div 16);
            //Write(Outfile,'|'+StrPadL(StrI2S(FG),2,'0'));
            //Write(Outfile,'|'+StrPadL(StrI2S(BG),2,'0'));
            Write(Outfile,Ansi_Color(FG,Screen.TextAttr));
            Write(Outfile,Ansi_Color(BG,Screen.TextAttr));
            //Write(Outfile,Ansi_Color(Image.Data[Count1][Count2].Attributes));
          End;
          Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
          OldAt := Image.Data[Count1][Count2].Attributes 
        End;
        If Count1 <> Lastline Then Write(Outfile,EOL);
      End;
      If Prep = 2 Then  Write(Outfile, ANSIHome);
      close(Outfile);
    End;
  
  End;
  
Procedure SaveScreenMYSTIC(Filename: String; Image: TConsoleImageRec; Screen:TOutput);
  Var
    OutFile: Text;
    FG,BG  : Byte;
    OldAT  : Byte;
    Outname: String;
    Count1 : Integer;
    Count2 : Integer; 
    Prep   : Byte;
    LastLine : Byte;
    LineLen  : Byte;
  Begin
    Outname := Filename; //GetSaveFileName(' Save Screen ','blockart.ans');
    Prep := GetMysticPrep(Screen);
    if Outname <> '' then Begin
      Assign     (OutFile, Outname);
      //SetTextBuf (OutFile, Buffer);
      ReWrite    (OutFile);
      OldAt:=0;
      If Prep = 1 Then  Write(Outfile, MysticCLrScr);
      If Prep = 2 Then  Write(Outfile, MysticNoPause);
      If SaveCur Then LastLine := Screen.CursorY
        Else LastLine := FindLastLine(Image);
      For Count1 := 1 to LastLine Do Begin
        LineLen := GetLineLength(Image,Count1);
        For Count2 := Image.X1 to 79 Do Begin
          If OldAt <> Image.Data[Count1][Count2].Attributes then Begin
            FG := Image.Data[Count1][Count2].Attributes mod 16;
            BG := 16 + (Image.Data[Count1][Count2].Attributes div 16);
            Write(Outfile,'|'+StrPadL(StrI2S(FG),2,'0'));
            Write(Outfile,'|'+StrPadL(StrI2S(BG),2,'0'));
          End;
          Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
          OldAt := Image.Data[Count1][Count2].Attributes 
        End;
      If Count1 <> Lastline Then Write(Outfile,EOL);
      End;
      If Prep = 3 Then  Write(Outfile, MysticHome);
      close(Outfile);
    End;
  
  End;  
  
Procedure SaveScreenPascal(Filename: String; Image: TConsoleImageRec; Screen:TOutput);  
  Var
    OutFile: Text;
    FG,BG  : Byte;
    Cnt  : Byte;
    Outname: String;
    Count1 : Integer;
    Count2 : Integer; 
    S      : String;
    C      : Char;
Begin
  Outname := Filename; //GetSaveFileName(' Save Screen ','blockart.ans');
  if Outname <> '' then Begin
    Assign     (OutFile, Outname);
    ReWrite    (OutFile);
{    const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=689;
  IMAGEDATA : array [1..689] of Char = (
 }   
    Writeln(OutFile,'{ TheDraw Pascal Screen Image. }');
    Writeln(OutFile,'IMAGEDATA_WIDTH=80;');
    Writeln(OutFile,'IMAGEDATA_DEPTH=25;');
    Writeln(OutFile,'IMAGEDATA_LENGTH=4000;');
    Writeln(OutFile,'IMAGEDATA : array [1..4000] of Char = (');
    Cnt := 1;
    S   := '';
    For Count1 := 1 to 25 Do Begin
      For Count2 := 1 to 80 Do Begin
        C := Image.Data[Count1][Count2].UnicodeChar;
        If C = #0 Then C := ' ';
        If (Count1 * Count2)<>2000 Then Begin
          S := S + '''' + C + ''' ,#' + strPadR(StrI2S(Image.Data[Count1][Count2].Attributes),3,' ') + ',';
           Cnt := Cnt + 1;
          If Cnt = 7 Then Begin
            Writeln(OutFile,S);
            Cnt := 1;
            S := '';
          End;
        End
        Else Begin
          S := S + '''' + C + ''' ,#' + strPadR(StrI2S(Image.Data[Count1][Count2].Attributes),3,' ')+');';
          Writeln(OutFile,S);
        End;
       
      End;
    End;
    close(Outfile);
  End;
End;  
  
Procedure SaveScreenTEXT(Filename: String; Image: TConsoleImageRec;Screen:TOutput);
  Var
    OutFile: Text;
    Outname: String;
    Count1 : Integer;
    Count2 : Integer; 
    LastLine : Byte;
  Begin
    Outname := Filename; //GetSaveFileName(' Save Screen ','blockart.ans');
    if Outname <> '' then Begin
      Assign     (OutFile, Outname);
      ReWrite    (OutFile);
      If SaveCur Then LastLine := Screen.CursorY
        Else LastLine := FindLastLine(Image);
      For Count1 := 1 to LastLine Do Begin
        For Count2 := 1 to 79 Do Begin
            Write(Outfile,Image.Data[Count1][Count2].UnicodeChar);
        End;
        If Count1 <> Lastline Then Write(Outfile,EOL);
      End;
      close(Outfile);
    End;
  End;    

Procedure LoadANSIFile(Screen: TOutput; Filename: String);
Var
  Buffer   : Array[1..4096] of Char;
  dFile    : File;
  Ext      : String[4];
  Code     : String[2];
  dRead    : LongInt;
  Old      : Boolean;
  Str      : String;
  A        : Word;
  Ch       : Char;
  Done     : Boolean;
  Terminal : TTermAnsi;

  Function GetChar : Char;
  Begin
    If A = dRead Then Begin
      BlockRead (dFile, Buffer, SizeOf(Buffer), dRead);
      A := 0;
      If dRead = 0 Then Begin
        Done      := True;
        Buffer[1] := #26;
      End;
    End;

    Inc (A);
    GetChar := Buffer[A];
  End;
  
  Procedure OutStr (S: String);
  Begin
    Terminal.ProcessBuf(S[1], Length(S));
  End;
  
Var
  BaudEmu : LongInt = 0;
  
Begin
  If Filename = '' Then Begin
    ShowMsgBox(0,'No File. Abort.',Screen);
    Exit;
  End;

  Assign (dFile, Filename);
  Reset  (dFile, 1);

  If IoResult <> 0 Then Begin
    ShowMsgBox(0,'Error Opening File.',Screen);
    Exit;
  End;
  
  Screen.ClearScreen;
  
  Assign (dFile, Filename);
  Reset  (dFile, 1);
  Terminal := TTermAnsi.Create(Screen);
  
  Done    := False;
  A       := 0;
  dRead   := 0;
  Ch      := #0;

  While (Not Done) Or (Screen.CursorY>=25) Do Begin
    Ch := GetChar;

    If BaudEmu > 0 Then Begin
      Screen.BufFlush;

      If A MOD BaudEmu = 0 Then WaitMS(6);
    End;

    If Ch = #26 Then
      Break
    Else
    If Ch = #10 Then Begin
      Terminal.Process(#10);
    End Else
    If Ch = '|' Then Begin
      Code := GetChar;
      Code := Code + GetChar;

      If Code = '00' Then OutStr(Ansi_Color(0,Screen.TextAttr)) Else
      If Code = '01' Then OutStr(Ansi_Color(1,Screen.TextAttr)) Else
      If Code = '02' Then OutStr(Ansi_Color(2,Screen.TextAttr)) Else
      If Code = '03' Then OutStr(Ansi_Color(3,Screen.TextAttr)) Else
      If Code = '04' Then OutStr(Ansi_Color(4,Screen.TextAttr)) Else
      If Code = '05' Then OutStr(Ansi_Color(5,Screen.TextAttr)) Else
      If Code = '06' Then OutStr(Ansi_Color(6,Screen.TextAttr)) Else
      If Code = '07' Then OutStr(Ansi_Color(7,Screen.TextAttr)) Else
      If Code = '08' Then OutStr(Ansi_Color(8,Screen.TextAttr)) Else
      If Code = '09' Then OutStr(Ansi_Color(9,Screen.TextAttr)) Else
      If Code = '10' Then OutStr(Ansi_Color(10,Screen.TextAttr)) Else
      If Code = '11' Then OutStr(Ansi_Color(11,Screen.TextAttr)) Else
      If Code = '12' Then OutStr(Ansi_Color(12,Screen.TextAttr)) Else
      If Code = '13' Then OutStr(Ansi_Color(13,Screen.TextAttr)) Else
      If Code = '14' Then OutStr(Ansi_Color(14,Screen.TextAttr)) Else
      If Code = '15' Then OutStr(Ansi_Color(15,Screen.TextAttr)) Else
      If Code = '16' Then OutStr(Ansi_Color(16,Screen.TextAttr)) Else
      If Code = '17' Then OutStr(Ansi_Color(17,Screen.TextAttr)) Else
      If Code = '18' Then OutStr(Ansi_Color(18,Screen.TextAttr)) Else
      If Code = '19' Then OutStr(Ansi_Color(19,Screen.TextAttr)) Else
      If Code = '20' Then OutStr(Ansi_Color(20,Screen.TextAttr)) Else
      If Code = '21' Then OutStr(Ansi_Color(21,Screen.TextAttr)) Else
      If Code = '22' Then OutStr(Ansi_Color(22,Screen.TextAttr)) Else
      If Code = '23' Then OutStr(Ansi_Color(23,Screen.TextAttr)) Else
      Begin
        Terminal.Process('|');
        Dec (A, 2);
        Continue;
      End;
    End Else
      Terminal.Process(Ch);
  End;
  Close (dFile);
  Terminal.Free;
End;

Begin
End.  
