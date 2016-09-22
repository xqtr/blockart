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

{$I RECORDS.PAS}

Procedure StoreXY;
Begin
  CurChar.PX := Screen.CursorX;
  CurChar.PY := Screen.CursorY;
End;

Procedure ReStoreXY;
Begin
  Screen.CursorXY(CurChar.PX,CurChar.PY);
End;

Procedure StoreOldXY;
Begin
  CurChar.PX := CurChar.OldX;
  CurChar.PY := CurChar.OldY;
End;

Procedure ReStoreOldXY;
Begin
  CurChar.OldX := CurChar.PX;
  CurChar.OldY := CurChar.PY;
End;

Procedure AddUndoState(V: Byte; Image: TConsoleImageRec);
Begin
  Undo.Count := Undo.Count + V;
  If Undo.Count >= Undo.Max Then Begin
    SaveScreenANSI(DirSlash(Settings.Folder)+'undo'+StrI2S(Undo.Index)+'.ans', Image, Screen,False);
    Undo.Index := Undo.Index + 1;
    If Undo.Index >= Undo.Max Then Undo.Index := 1;
    Undo.Count := 1;
  End;
End;

Procedure UndoScreen;

Begin
  StoreXY;
  Undo.Index := Undo.Index - 1;
  If (Undo.Index = 1) Or (Undo.Index > 20) Then Undo.Index := 20;
  If FileExist(DirSlash(Settings.Folder)+'undo'+StrI2S(Undo.Index)+'.ans') Then Begin
    LoadANSIFile(Screen, DirSlash(Settings.Folder)+'undo'+StrI2S(Undo.Index)+'.ans');
    ReStoreXY;
  End;
End;

Procedure DeleteUndoFiles;
Var
  i: Byte;
Begin
  For i := 1 to 20 Do 
    If FileExist(DirSlash(Settings.Folder)+'undo'+StrI2S(i)+'.ans') then 
      FileErase(DirSlash(Settings.Folder)+'undo'+StrI2S(i)+'.ans');
End;

Function ReadSauceInfo (FN: String; Var Sauce: RecSauceInfo) : Boolean;
Var
  DF  : File;
  Str : String;
  Res : LongInt;
Begin
  Result := False;

  Assign (DF, FN);

  {$I-} Reset (DF, 1); {$I+}

  If IoResult <> 0 Then Exit;

  {$I-} Seek (DF, FileSize(DF) - 130); {$I+}

  If IoResult <> 0 Then Begin
    Close (DF);
    Exit;
  End;

  BlockRead (DF, Str[1], 130);

  Str[0] := #130;

  Close (DF);

  Res := Pos('SAUCE', Copy(Str, 1, 7));

  If Res > 0 Then Begin
    Result := True;

    Sauce.Title  := strReplace(Copy(Str,  7 + Res, 35), #0, #32);
    Sauce.Author := strReplace(Copy(Str, 42 + Res, 20), #0, #32);
    Sauce.Group  := strReplace(Copy(Str, 62 + Res, 20), #0, #32);
  End;
End;

Procedure CursorBlock;
Begin
  Screen.RawWriteStr (#27 + '[?112c'+#7);
End;

Procedure HalfBlock;
Begin
  Screen.RawWriteStr (#27 + '[?2c'+#7);
End;


Procedure BoxClear(X1,Y1,X2,Y2: Byte);
Var
  x,y : Byte;
Begin
  For X := X1 To X2 Do
    For Y := Y1 To Y2 Do 
      Screen.WriteXY(X,Y,CurChar.Color,' ');
End;

Function Pipe2ANSI(S: String): Byte;
Var
  Pipe : String;
  Fg   : Byte;
  Bg   : Byte;
  i    : Byte;
  Tot  : Byte;
Begin
 i := 1;
  Tot := StrWordCount(S, '|');
  Fg := 0;
  Bg := 0;
  For i := 1 To Tot Do begin
      Pipe := strWordGet(i,s,'|');
      If StrS2I(Pipe) >=16 Then Begin
        bg := (StrS2I(Pipe) - 16);
      End Else Begin
        Fg := StrS2I(Pipe);
      End;
  End;  
    Result := Fg + bg * 16;
End;

Procedure Box3DInv(X1,Y1,X2,Y2:Byte);
Var
  i,d : Byte;
Begin
  For i:= X1 To X2 Do Begin
    Screen.WriteXY(i,Y1,8+7*16,Chr(220));
    Screen.WriteXY(i,Y2,15+7*16,Chr(223));
  End;
  For i := Y1 To Y2 Do Begin
    Screen.WriteXY(X1,i,8+7*16,Chr(219));
    Screen.WriteXY(X2,i,15+7*16,Chr(219));
  End;
  Screen.WriteXY(X1,Y1,8+7*16,Chr(220));
  Screen.WriteXY(X1,Y2,7+7*16,Chr(223));
  Screen.WriteXY(X2,Y1,7+7*16,Chr(220));
  Screen.WriteXY(X2,Y2,15+7*16,Chr(223));
  For i := X1 + 1 To X2 -1 Do
    For D := Y1 + 1 To Y2 - 1 Do
      Screen.WriteXY(i,d,0,' ');
End;

Procedure Box3D(X1,Y1,X2,Y2:Byte);
Var
  i,d : Byte;
Begin
  For i:= X1 To X2 Do Begin
    Screen.WriteXY(i,Y1,15+0*16,Chr(220));
    Screen.WriteXY(i,Y2,8+0*16,Chr(223));
  End;
  For i := Y1 To Y2 Do Begin
    Screen.WriteXY(X1,i,15+7*16,Chr(219));
    Screen.WriteXY(X2,i,8+7*16,Chr(219));
  End;
  Screen.WriteXY(X1,Y1,15+0*16,Chr(220));
  Screen.WriteXY(X1,Y2,7+0*16,Chr(223));
  Screen.WriteXY(X2,Y1,7+0*16,Chr(220));
  Screen.WriteXY(X2,Y2,8+0*16,Chr(223));
  For i := X1 + 1 To X2 -1 Do
    For D := Y1 + 1 To Y2 - 1 Do
      Screen.WriteXY(i,d,0+7*16,' ');
End;

Procedure LoadSettings;
Var
  Ini : TIniFile;
Begin
  Ini := TIniFile.Create('blockart.ini');
  With Settings Do begin
  Title  := Ini.ReadString('Sauce','Title','');
  Artist := Ini.ReadString('Sauce','Artist','');
  Group  := Ini.ReadString('Sauce','Group','');
  Sauce  := Ini.ReadBool('Sauce','Use',False);
  CurChar.Tabs := Ini.ReadInteger('Various','Tabs',2);
  Settings.CharSet := Ini.ReadInteger('Various','CharSet',1);
  End;
  Ini.Free;
End;

Procedure SaveSettings;
Var
  Ini : TIniFile;
Begin
  Ini := TIniFile.Create('blockart.ini');
  Ini.WriteString('Sauce','Title',Settings.Title);
  Ini.WriteString('Sauce','Artist',Settings.Artist);
  Ini.WriteString('Sauce','Group',Settings.Group);
  Ini.WriteBool('Sauce','Use',Settings.Sauce);
  Ini.WriteInteger('Various','Tabs',CurChar.Tabs);
  Ini.WriteInteger('Various','CharSet',Settings.CharSet);
  Ini.Free;
End;

Procedure Edit;
Begin  
  Edited:=True;
End;

Procedure WriteAsc(x,y,d:byte);
Begin
  Screen.WriteXY(X,Y,CurChar.Color,addtopage(X, Y, Screen.ReadCharXY(X,Y), Chr(Charset[CurChar.SelCharSet][d])));
End;

Procedure CursorLeft;
Var
  X,Y : Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  If Screen.CursorX>1 Then Screen.CursorXY(Screen.CursorX-1,Screen.CursorY);
  If DrawMode = Draw_Color Then Begin
    Edit;
    Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Screen.ReadCharXY(Screen.CursorX,Screen.CursorY));
  End;
  If DrawMode = Draw_Line Then Begin
    Edit;
    Case lmv Of
      Move_Left : WriteAsc(x,y,5);
      Move_Right: WriteAsc(x,y,5);
      Move_Up   : WriteAsc(x,y,2);
      Move_Down : WriteAsc(x,y,4);
    End;
  End;
  lmv := Move_Left;
End;

Procedure CursorRight;
Var
  X,Y : Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  If Screen.CursorX<80 Then Screen.CursorXY(Screen.CursorX+1,Screen.CursorY);
  If DrawMode = Draw_Color Then Begin
    Edit;
    Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Screen.ReadCharXY(Screen.CursorX,Screen.CursorY));
  End;
  If DrawMode = Draw_Line Then Begin
    Edit;
    Case lmv Of
      Move_Left : WriteAsc(x,y,5);
      Move_Right: WriteAsc(x,y,5);
      Move_Up   : WriteAsc(x,y,1);
      Move_Down : WriteAsc(x,y,3);
    End;
  End;
  lmv := Move_Right;
End;

Procedure CursorUp;
Var
  X,Y : Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  If Screen.CursorY>1 Then Screen.CursorXY(Screen.CursorX,Screen.CursorY-1);
  If DrawMode = Draw_Color Then Begin
    Edit;
    Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Screen.ReadCharXY(Screen.CursorX,Screen.CursorY));
  End;
  If DrawMode = Draw_Line Then Begin
    Edit;
    Case lmv Of
      Move_Left : WriteAsc(x,y,3);
      //Screen.WriteXY(X,Y,CurChar.Color,Chr(Charset[CurChar.SelCharSet][3]));
      Move_Right: WriteAsc(x,y,4);
      Move_Up   : WriteAsc(x,y,6);
      Move_Down : WriteAsc(x,y,6);
    End;
  End;
  lmv := Move_Up;
End;

Procedure CursorDown;
Var
  X,Y : Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  If Screen.CursorY<25 Then Screen.CursorXY(Screen.CursorX,Screen.CursorY+1);
  If DrawMode = Draw_Color Then Begin
    Edit;
    Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Screen.ReadCharXY(Screen.CursorX,Screen.CursorY));
  End;
  If DrawMode = Draw_Line Then Begin
    Edit;
    Case lmv Of
      Move_Left : WriteAsc(x,y,1);
      Move_Right: WriteAsc(x,y,2);
      Move_Up   : WriteAsc(x,y,6);
      Move_Down : WriteAsc(x,y,6);
    End;
  End;
  lmv := Move_Down;
End;

Procedure CursorPGDN;
Begin
  Screen.CursorXY(Screen.CursorX,25);
End;

Procedure CursorPGUP;
Begin
  Screen.CursorXY(Screen.CursorX,1);
End;

Procedure CursorHome;
Var
  X,Y: Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  Screen.CursorXY(1,Screen.CursorY);
  If DrawMode = Draw_Color Then Begin
    Edit;
    For i := 1 To X Do
      Screen.WriteXY(i,y,CurChar.Color,Screen.ReadCharXY(i,Y));
  End;
End;

Procedure CursorEnd;
Var
  X,Y: Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  Screen.CursorXY(80,Screen.CursorY);
  If DrawMode = Draw_Color Then Begin
    Edit;
    For i := X To 80 Do
      Screen.WriteXY(i,y,CurChar.Color,Screen.ReadCharXY(i,Y));
  End;
End;

Procedure CursorEnter;
Begin
  CursorDown;
  CursorHome;
End;

Procedure CursorBackSpace;
Begin
  CursorLeft;
  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,' ');
End;

Procedure CursorINS;
Begin
  CurChar.Ins := Not CurChar.Ins;
End;

Procedure CursorOther;
Var
  fg,bg: Byte;
  cl   : Byte;
  Pipe : String;
  sx,sy: Byte;
  d    : Byte;
Begin
  If DrawMode = Draw_TDF Then Begin
    Sx := Screen.CursorX;
    Sy := Screen.CursorY;
    
    Screen.GetScreenImage(1,1,80,25,MainImage);
    AddUndoState(10,MainImage);
       
    case blockart_tdf.font.fonttype of
      2: begin  
          D := TDFWriteCharBL(Sx,Sy,Ch) + blockart_tdf.font.spacing;
         end;
      1: begin  
          D := TDFWriteCharBL(Sx,Sy,Ch) + blockart_tdf.font.spacing;
         end;
    end;
  
    Screen.CursorXY(Sx + D, Sy);   
    
    CurChar.TDF_LWidth  := Screen.CursorX - Sx; 
    CurChar.TDF_LHeight := Screen.CursorY - Sy; 
  
  End Else Begin
    If DrawFx = Draw_CaseFx Then Begin
      Screen.GetScreenImage(1,1,80,25,MainImage);
      AddUndoState(2,MainImage);
      Case Ch Of
        #48..#57 : Cl := Pipe2ANSI(CurChar.CaseFxNum);
        #65..#90 : Cl := Pipe2ANSI(CurChar.CaseFxCap);
        #97..#122: Cl := Pipe2ANSI(CurChar.CaseFxLow);
        #32..#47,
        #58..#64,
        #91..#96,
        #123..#126 : Cl := Pipe2ANSI(CurChar.CaseFxSym);
        
      End;
    End;
    If DrawFx = Draw_FontFx Then Begin
      Screen.GetScreenImage(1,1,80,25,MainImage);
      AddUndoState(2,MainImage);
      If Ch = ' ' Then CurChar.FontFXIdx := 1;

      Repeat
        Pipe := strWordGet(CurChar.FontFXIdx,CurChar.FontFX,'|');
        If StrS2I(Pipe) >=16 Then Begin
          bg := (StrS2I(Pipe) - 16);
          CurChar.FontFXIdx := CurChar.FontFXIdx + 1;
        End Else Begin
          Fg := StrS2I(Pipe);
          CurChar.FontFXIdx := CurChar.FontFXIdx + 1;
          If CurChar.FontFXIdx >= CurChar.FontFXCnt Then CurChar.FontFXIdx := CurChar.FontFXCnt;
          Break;
        End;
        If CurChar.FontFXIdx >= CurChar.FontFXCnt Then Begin
          CurChar.FontFXIdx := CurChar.FontFXCnt;
          Break;
        End;
      Until  StrS2I(Pipe)<16;
      Cl := Fg + bg * 16;   
    End;
    
    If CurChar.Ins Then Begin
      Screen.GetScreenImage(1, 1, 80, 25, MainImage);
      AddUndoState(2,MainImage);
      Move(Mainimage.Data[Screen.CursorY][Screen.CursorX],Mainimage.Data[Screen.CursorY][Screen.CursorX+1],(80-Screen.CursorX)*2);
      Screen.PutScreenImage(MainImage);
    End;
    
    If (DrawFx = 0) Then Cl := CurChar.Color;
    
    Screen.GetScreenImage(1,1,80,25,MainImage);
    AddUndoState(2,MainImage);
    
    If ((Ord(Ch)>=32) And (Ord(ch)<=64)) Or ((Ord(Ch)>=123) And (Ord(ch)<=126)) Then
      Screen.WriteXY(Screen.CursorX,Screen.CursorY,Cl,ch)
    Else Begin
      If (DrawMode = Draw_Elite) Then
        Screen.WriteXY(Screen.CursorX,Screen.CursorY,Cl,Chr(Font[2,Ord(ch)]));
      If (DrawMode = Draw_Normal) Then
        Screen.WriteXY(Screen.CursorX,Screen.CursorY,Cl,Chr(Font[1,Ord(ch)]));
    End;
  End;
  CursorRight;
End;

Procedure CursorTAB;
Var 
  k:Byte;
  OldCh: Char;
  OldCl: Byte;
  OldX : Byte;
Begin
  OldX := Screen.CursorX;
  For k := 80-CurChar.Tabs Downto OldX Do Begin
    OldCl := Screen.ReadAttrXY(k,Screen.CursorY);
    OldCh := Screen.ReadCharXY(k,Screen.CursorY);
    Screen.WriteXY(k+CurChar.Tabs,Screen.CursorY,OldCl,OldCh);
  End;
  For k := 1 to CurChar.Tabs Do Screen.WriteXY(OldX+k-1,Screen.CursorY,CurChar.Color,' ');
  //Screen.CursorXY(OldX,Screen.CursorY);
End;

Procedure InitCharSet;
Begin
(*
  CurChar.Charset[1]:=Chr(218)+Chr(191)+Chr(192)+Chr(217)+Chr(196)+Chr(179)+Chr(195)+Chr(180)+Chr(193)+Chr(194);
  CurChar.Charset[2]:=Chr(201)+Chr(187)+Chr(200)+Chr(188)+Chr(205)+Chr(186)+Chr(199)+Chr(185)+Chr(202)+Chr(203);
  CurChar.Charset[3]:=Chr(213)+Chr(184)+Chr(212)+Chr(190)+Chr(205)+Chr(179)+Chr(198)+Chr(189)+Chr(207)+Chr(209);
  CurChar.Charset[4]:=Chr(197)+Chr(206)+Chr(216)+Chr(215)+Chr(159)+Chr(233)+Chr(155)+Chr(156)+Chr(153)+Chr(239);
  CurChar.Charset[5]:=Chr(176)+Chr(177)+Chr(178)+Chr(219)+Chr(220)+Chr(223)+Chr(221)+Chr(222)+Chr(254)+Chr(249);
  CurChar.Charset[6]:=Chr(214)+Chr(183)+Chr(211)+Chr(189)+Chr(196)+Chr(186)+Chr(199)+Chr(182)+Chr(208)+Chr(210);
  CurChar.Charset[7]:=Chr(174)+Chr(175)+Chr(242)+Chr(243)+Chr(244)+Chr(245)+Chr(246)+Chr(247)+Chr(240)+Chr(251);
  CurChar.Charset[8]:=Chr(166)+Chr(167)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(248)+Chr(252)+Chr(253);
  CurChar.Charset[9]:=Chr(224)+Chr(225)+Chr(226)+Chr(235)+Chr(238)+Chr(237)+Chr(234)+Chr(228)+Chr(229)+Chr(230);
 CurChar.Charset[10]:=Chr(232)+Chr(233)+Chr(234)+Chr(155)+Chr(156)+Chr(157)+Chr(159)+Chr(145)+Chr(146)+Chr(247);
 *)
  
 CurChar.SelCharSet:=1;
End;

Function GetStr (Header, Text, Def: String; Len, MaxLen: Byte) : String;
Var
  Box     : TMenuBox;
  Input   : TMenuInput;
  Offset  : Byte;
  Str     : String;
  WinSize : Byte;
Begin
  WinSize := (80 - Max(Len, Length(Text)) + 2) DIV 2;

  Box   := TMenuBox.Create(TOutput(Screen));
  Input := TMenuInput.Create(TOutput(Screen));

  Box.FrameType := 6;
  Box.Header    := ' ' + Header + ' ';
  Box.HeadAttr  := 0 + 7 * 16;
  Box.Box3D     := True;

  Input.Attr     := 15 + 2 * 16;
  Input.FillAttr := 15 + 2 * 16;
  Input.LoChars  := #13#27;

  If Screen.ScreenSize = 50 Then Offset := 12 Else Offset := 0;

  Box.Open (WinSize, 10 + Offset, WinSize + Max(Len, Length(Text)) + 6, 15 + Offset);

  Screen.WriteXY (WinSize + 2, 12 + Offset, 0+7*16, Text);
  Str := Input.GetStr(WinSize + 2, 13 + Offset, Len, MaxLen, 1, Def);

  Box.Close;

  If Input.ExitCode = #27 Then Str := '';

  Input.Free;
  Box.Free;

  Result := Str;
End;

Procedure ConvertANSI;
Const
  CRLF = #13#10;
Var
  Ansi    : TAnsiLoader;
  InFile  : File;
  InFileName : String;
  OutFileName: String;
  Buf     : Array[1..4096] of Char;
  BufLen  : LongInt;
  OutFile : Text;
  CountY  : LongInt;
  CountX  : Byte;
  CurAttr : Byte;
  CurFG   : Byte;
  NewFG   : Byte;
  CurBG   : Byte;
  NewBG   : Byte;
Begin
  
  InFileName := GetUploadFileName(Screen,' ANSI File ',Settings.Folder);
  If InFileName = '' Then Begin
    ShowMsgBox(0,'No File. Abort.',Screen);
    Exit;
  End;
  
  
  OutFileName := GetSaveFileName(Screen,' Save As... ','mystic.ans',Settings.Folder);
  If OutFileName = '' Then Begin
    ShowMsgBox(0,'No File. Abort.',Screen);
    Exit;
  End;

  Ansi := TAnsiLoader.Create;

  Assign (InFile, InFileName);

  If Not ioReset (InFile, 1, fmReadWrite + fmDenyNone) Then Begin
    ShowMsgBox(0,'Unable to open input file.',Screen);
    Ansi.Free;
    Exit;
  End;

  ShowMsgBox(2,'Converting ... ',Screen);

  While Not Eof(InFile) Do Begin
    ioBlockRead (InFile, Buf, SizeOf(Buf), BufLen);
    If Ansi.ProcessBuf (Buf, BufLen) Then Break;
  End;

  Close (InFile);

  Assign  (OutFile, OutFileName);
  ReWrite (OutFile);

  CurAttr := 7;

  Write (OutFile, '|07|16|CL');

  For CountY := 1 to Ansi.Lines Do Begin
    For CountX := 1 to Ansi.GetLineLength(CountY) Do Begin
      CurBG := (CurAttr SHR 4) AND 7;
      CurFG := CurAttr AND $F;
      NewBG := (Ansi.Data[CountY][CountX].Attr SHR 4) AND 7;
      NewFG := Ansi.Data[CountY][CountX].Attr AND $F;

      If CurFG <> NewFG Then Write (OutFile, '|' + strZero(NewFG));
      If CurBG <> NewBG Then Write (OutFile, '|' + strZero(16 + NewBG));

      If Ansi.Data[CountY][CountX].Ch in [#0, #255] Then
        Ansi.Data[CountY][CountX].Ch := ' ';

      Write (OutFile, Ansi.Data[CountY][CountX].Ch);

      CurAttr := Ansi.Data[CountY][CountX].Attr;
    End;

    Write (OutFile, CRLF);
  End;

  Close (OutFile);

  ShowMsgBox(0, 'Complete!',Screen);
End;

Procedure Center(S:String; L:byte);
Begin
  Screen.WriteXYPipe((40-strMCILen(s) div 2),L,7,strMCILen(s),S);
End;  

Function GetCommandOption (StartY: Byte; CmdStr: String) : Char;
Var
  Box     : TMenuBox;
  Form    : TMenuForm;
  Count   : Byte;
  Cmds    : Byte;
  CmdData : Array[1..10] of Record
              Key  : Char;
              Desc : String[18];
            End;
Begin
  Cmds := 0;

  While Pos('|', CmdStr) > 0 Do Begin
    Inc (Cmds);

    CmdData[Cmds].Key  := CmdStr[1];
    CmdData[Cmds].Desc := Copy(CmdStr, 3, Pos('|', CmdStr) - 3);

    Delete (CmdStr, 1, Pos('|', Cmdstr));
  End;

  Box  := TMenuBox.Create(TOutput(Screen));
  Form := TMenuForm.Create(TOutput(Screen));

  Form.HelpSize := 0;

  Box.Open (30, StartY, 51, StartY + Cmds + 1);

  For Count := 1 to Cmds Do
    Form.AddNone (CmdData[Count].Key, ' ' + CmdData[Count].Key + ' ' + CmdData[Count].Desc, 31, StartY + Count, 20, '');

  Result := Form.Execute;

  Form.Free;
  Box.Close;
  Box.Free;
End;

Procedure BoxOpen (X1, Y1, X2, Y2: Byte);
Begin
  Box := TMenuBox.Create(Screen);

  Box.Open(X1, Y1, X2, Y2);
End;

Procedure BoxClose;
Begin
  Box.Close;
  Box.Free;
End;

Procedure CoolBoxClose;
Begin
  Screen.PutScreenImage(Image);
End;

Procedure AboutBox;
Begin
  BoxOpen (19, 7, 62, 19);

  Screen.WriteXY (21,  8,  31, strPadC('BlockArt ANSI Editor', 40, ' '));
  Screen.WriteXY (21,  9, 112, strRep('-', 40));
  Screen.WriteXY (30, 10, 113, 'Copyright (C) 2016');
  Screen.WriteXY (22, 11, 113, 'All Rights Reserved for the ANSI Scene');
  Screen.WriteXY (21, 13, 113, strPadC('Version 0.8 Beta', 40, ' '));
  Screen.WriteXY (34, 16, 113, 'adbbs.no-ip.org');
  Screen.WriteXY (32, 15, 113, 'xqtr.xqtr#gmail.com');
  Screen.WriteXY (21, 17, 112, strRep('-', 40));
  Screen.WriteXY (21, 18,  31, strPadC('(.. Press A Key ..', 40, ' '));

  Menu.Input.ReadKey;

  BoxClose;
End;

Function SaveFileType(Filename:String; Image: TConsoleImageRec; Screen:TOutput):Boolean;
Var
  SaveType : Byte;
Begin
  SaveType := GetSaveType(Screen);
    If SaveType = 0 Then 
      If ShowMsgBox(1,'Abort?',Screen)=True Then 
        Begin
          Result := False;
          Exit;
        End;
  Case SaveType Of
    1 : SaveScreenANSI(Filename,Image,Screen,True);
    2 : SaveScreenMYSTIC(Filename,Image,Screen);
    3 : SaveScreenPascal(Filename,Image,Screen);
    4 : SaveScreenTEXT(Filename,Image,Screen);
  End;
  Result := True;
  
End;

Procedure SaveAsFile(Image:TConsoleImageRec; Screen:TOutput);
Var
  FileName : String;
  
Begin
  FileName := GetSaveFileName(Screen,' Save As ',JustFile(CurrentFile),Settings.Folder);
  If FileName <> '' Then Begin
    If Not SaveFileType(Filename,Image,Screen) Then Exit;
    
    Edited := False;
    CurrentFile := FileName;
  End;
End;

Procedure SaveFile(Image: TConsoleImageRec; Screen:TOutput);
Begin
  If CurrentFile = 'untitled.ans' Then SaveAsFile(Image,Screen)
    Else Begin
    If Not SaveFileType(CurrentFile,Image,Screen) Then Exit;
    
      //SaveScreen(CurrentFile,Image,Screen.TextAttr);
      Edited := False;
    End;
End;

Procedure NewFile;
Begin
  If Edited Then Begin
    If ShowMsgBox(1,'Save File?',Screen) Then SaveAsFile(Image,Screen);
    Screen.ClearScreen;
    Edited := False;  
  End;
End;

Procedure OpenFile;
Var
  FileName : String;
  
Begin
  FileName := GetUploadFileName(Screen,' ANSI File ',Settings.Folder);
  If Filename = '' Then Begin
    ShowMsgBox(0,'No File. Abort.',Screen);
    Exit;
  End;
  CurrentFile := FileName;
  LoadANSIFile(Screen,Filename);
  Edited := False;
  Screen.CursorXY(40,13);
End;

Procedure Global(Var Image:TConsoleImageRec);
Var
  List  : TMenuList;
  o,p   : Byte;
  X,Y   : Byte;
  Ch,Ch1: Byte;
  fg,bg : Byte;
  attr  : Byte;
  cl1,cl2:Byte;
  Chh   : Char;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Global ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  
  List.Add('Fill With Character',0);
  List.Add('Fill With Foreground Color',0);
  List.Add('Fill With BackGround Color',0);
  List.Add('Fill With Current Color',0);
  List.Add('Box',0);
  List.Add('Replace Color',0);
  List.Add('Replace Character',0);
  
 
 
  List.Open (25, 9, 55, 19);
  List.Box.Close;

  Case List.ExitCode of
    #27 : ;
    #13 :
      Case List.Picked Of
        1 : Begin 
            Ch := GetChar(Screen,Keyboard);
            If Ch <> 0 Then For o := 1 to 25 Do
              For p := 1 to 80 Do Image.Data[o][p].UnicodeChar:=Chr(Ch);
            End;
        2 : Begin
              For o := 1 to 25 Do
                For p := 1 to 80 Do Begin
                  attr  := Image.Data[o][p].Attributes;
                  fg := attr mod 16;
                  bg := attr div 16;
                  Image.Data[o][p].Attributes := (CurChar.Color mod 16) + bg * 16;
                End;
            End;
        3 : Begin
              For o := 1 to 25 Do
                For p := 1 to 80 Do Begin
                  attr  := Image.Data[o][p].Attributes;
                  fg := attr mod 16;
                  bg := attr div 16;
                  Image.Data[o][p].Attributes := fg + (CurChar.Color div 16) * 16;
                End;
            End;
        4 : Begin
              For o := 1 to 25 Do
                For p := 1 to 80 Do Begin
                  Image.Data[o][p].Attributes  := CurChar.Color;
                End;
            End;
        5: Begin
              For x := 1 To 80 Do Begin
                Image.Data[1][x].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][5]);
                Image.Data[1][x].Attributes := CurChar.Color;
                Image.Data[25][x].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][5]);
                Image.Data[25][x].Attributes := CurChar.Color;
              End;
              For y:= 1 To 25 Do Begin
                Image.Data[y][1].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][6]);
                Image.Data[y][1].Attributes := CurChar.Color;
                Image.Data[y][80].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][6]);
                Image.Data[y][80].Attributes := CurChar.Color;
              End;
              Image.Data[1][1].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][1]);
              Image.Data[1][1].Attributes := CurChar.Color;
              Image.Data[1][80].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][2]);
              Image.Data[1][80].Attributes := CurChar.Color;
              Image.Data[25][1].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][3]);
              Image.Data[25][1].Attributes := CurChar.Color;
              Image.Data[25][80].UnicodeChar:=Chr(CharSet[CurChar.SelCharSet][4]);
              Image.Data[25][80].Attributes := CurChar.Color;
           End;
      6 : Begin
              ShowMsgBox(0,'Choose Original Color',Screen);
              ch := GetColor(Screen,Keyboard,CurChar.Color);
              ShowMsgBox(0,'Replace With...',Screen);
              Ch1 := GetColor(Screen,Keyboard,CurChar.Color);
              If Ch<>Ch1 Then Begin
                For o := 1 to 25 Do
                  For p := 1 to 80 Do Begin
                    attr  := Image.Data[o][p].Attributes;
                    If Attr = Ch Then
                       Image.Data[o][p].Attributes := Ch1;
                  End;
              End;
            End;
      7 : Begin
              ShowMsgBox(0,'Choose Original Character',Screen);
              ch := GetChar(Screen,Keyboard);
              ShowMsgBox(0,'Replace With...',Screen);
              Ch1 := GetChar(Screen,Keyboard);
              If Ch<>Ch1 Then Begin
                For o := 1 to 25 Do
                  For p := 1 to 80 Do Begin
                    attr  := Ord(Image.Data[o][p].UnicodeChar);
                    If Attr = Ch Then
                       Image.Data[o][p].UnicodeChar := Chr(Ch1);
                  End;
              End;
            End;
      End;
          
  End;
  Edit;
  List.Free;
  Screen.CursorXY(X,Y);
End;

Procedure EditTabs;
Begin
  Try
    CurChar.Tabs := StrS2I(GetStr('Tab','Length','2',3,3));
    SaveSettings;
  Except
    ShowMsgBox(0,'Wrong Input!',Screen);
  End;
End;

Procedure EditSauce;
Var
  MyBox  : TMenuBox;
  MyForm : TMenuForm;
  Data   : Array[1..9] of String;
  Sauce  : RecSauceInfo;
Begin
  //FillChar (Data, SizeOf(Data), #0);

  If Not ReadSauceInfo(CurrentFile,Sauce) Then Begin
    ShowMsgBox(0,'No Sauce Data.',Screen);
    Exit;
  End;
  

  MyBox  := TMenuBox.Create(Screen);
  //MyForm := TMenuForm.Create(Screen);

  MyBox.Header := ' Sauce ';

  MyBox.Open   (10, 8, 68, 14);

  Screen.WriteXY(12,10,0+7*16,'Title  :');
  Screen.WriteXY(12,11,0+7*16,'Author :');
  Screen.WriteXY(12,12,0+7*16,'Group  :');
  
  Screen.WriteXY(21,10,0+7*16,Sauce.Title);
  Screen.WriteXY(21,11,0+7*16,Sauce.Author);
  Screen.WriteXY(21,12,0+7*16,Sauce.Group);

  //MyForm.AddStr ('T',' Title ' , 12,  10, 24,  10, 11, 42, 60, @Settings.Title, Settings.Title);
  //MyForm.AddStr ('A',' Artist ', 12,  11, 24,  11, 11, 42, 60, @Settings.Artist, Settings.Artist);
  //MyForm.AddStr ('G',' Group ' , 12,  12, 24, 12, 11, 42, 60, @Settings.Group, Settings.Group);
  //MyForm.AddBol ('U',' Use Sauce ', 12, 13, 24, 13, 11, 3, @Settings.Sauce, 'No');

  //MyForm.Execute;

  Box.Close;
  
  {If MyForm.Changed Then
    If ShowMsgBox(1, 'Save changes?',Screen) Then Begin
      SaveSettings;
    End;}

  //MyForm.Free;
  MyBox.Free;
End;

Procedure ClearImage;
Begin
  FillChar (MainImage.Data, SizeOf(MainImage.Data), #0);
End;

Procedure InsertLine(Var Image: TConsoleImageRec);
Begin
    Move (Image.Data[CurChar.OldY][1], Image.Data[CurChar.OldY+1][1], SizeOf(TConsoleLineRec) * (25-CurChar.OldY));
    FillChar(Image.Data[CurChar.OldY][1], SizeOf(TConsoleLineRec), 0);
End;

Procedure InsertRow(Var Image: TConsoleImageRec);
Var
  y : Byte;
Begin
  For y := 1 to 25 Do Begin
    Move (Image.Data[y][CurChar.OldX], Image.Data[y][CurChar.OldX+1], (80-CurChar.OldX)*2);
    FillChar(Image.Data[y][CurChar.OldX], 2, 0);
  End;
End;

Procedure DeleteRow(Var Image: TConsoleImageRec);
Var
  y : Byte;
Begin
  For y := 1 to 25 Do Begin
    Move (Image.Data[y][CurChar.OldX+1], Image.Data[y][CurChar.OldX], (80-CurChar.OldX)*2);
    FillChar(Image.Data[y][80], 2, 0);
  End;
End;

Procedure DeleteLine(Var Image: TConsoleImageRec);
Begin
    Move (Image.Data[CurChar.OldY+1][1], Image.Data[CurChar.OldY][1], SizeOf(TConsoleLineRec) * (25-CurChar.OldY));
    FillChar(Image.Data[25][1], SizeOf(TConsoleLineRec), 0);
End;

Function ReadSetting(Section,Key:String):String;
Var
  Ini : TiniFile;
Begin
  Ini := TIniFile.Create('blockart.ini');
  ReadSetting := Ini.ReadString(Section,Key,'');
  Ini.Free;
End;

Function SelectFontFX:Byte;
Var
  List  : TMenuList;
  X,Y   : Byte;
  i     : Byte;
  Ini   : TIniFile;
  Fx    : String;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Font FX Select ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  Box3D(36,6,60,19);
  Box3DInv(38,7,58,18);
  Screen.WriteXY(43,7,0+7*16,' Preview ');
  Ini := TIniFile.Create('blockart.ini');
  For i := 1 to 10 Do Begin
    Fx := Ini.ReadString('FontFX',StrI2S(i),'');
    List.Add(' '+StrI2S(i)+' '+Fx,0);
    Fx := strReplace(Fx,'|','#!');
    Fx := strReplace(Fx,'!','|');
    Fx := Fx + '#';
    Delete(Fx,1,1);
    Screen.WriteXYPipe(40,7+i,7,strMCILen(Fx),Fx);
  End;
  
  List.Open (8, 7, 30, 18);
  List.Box.Close;

  Case List.ExitCode of
    #27 : SelectFontFX := 0;
  Else
    SelectFontFX := List.Picked;
  End;
  List.Free;
  Ini.Free;
  Screen.CursorXY(X,Y);
End;

Function SelectCaseFX:Byte;
Var
  List  : TMenuList;
  X,Y   : Byte;
  i     : Byte;
  Ini   : TIniFile;
  Fx    : String;
  Cap,
  Low,
  Sym,
  Num   : Byte;
 
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Case FX Select ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  Box3D(36,6,60,19);
  Box3DInv(38,7,58,18);
  Screen.WriteXY(43,7,0+7*16,' Preview ');
  Ini := TIniFile.Create('blockart.ini');
  For i := 1 to 10 Do Begin
    Cap := Pipe2ANSI(Ini.ReadString('CaseFX'+StrI2S(i),'Capitals',''));
    Low := Pipe2ANSI(Ini.ReadString('CaseFX'+StrI2S(i),'Lowers',''));
    Num := Pipe2ANSI(Ini.ReadString('CaseFX'+StrI2S(i),'Numbers',''));
    Sym := Pipe2ANSI(Ini.ReadString('CaseFX'+StrI2S(i),'Symbols',''));
    List.Add(' CaseFX No '+StrI2S(i),0);
    
    Screen.WriteXY(44,7+i,Cap,'AA');
    Screen.WriteXY(46,7+i,Low,'aa');
    Screen.WriteXY(48,7+i,Num,'88');
    Screen.WriteXY(50,7+i,Sym,'##');
  End;
  
  List.Open (8, 7, 30, 18);
  List.Box.Close;

  Case List.ExitCode of
    #27 : SelectCaseFX := 0;
  Else
    SelectCaseFX:= List.Picked;
  End;
  List.Free;
  Ini.Free;
  Screen.CursorXY(X,Y);
End;

Procedure LineTools;
Var
  List : TMenuList;
  S    : String;
  i    : Byte;
  Fc,Ft: Byte;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Line Tools ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('Center Text', 0);
  List.Add('Right Text', 0);
  List.Add('Left Text', 0);
  List.Add('Clear Line', 0);
  List.Add('Fill FG', 0);
  List.Add('Fill BG', 0);
  List.Add('Fill Char.', 0);

  List.Open (30, 11, 55, 19);
  List.Box.Close;

  Case List.ExitCode of
    #27 : ;
  Else
    Case List.Picked Of
      1:  Begin
            S := strStripB(GetLineText(MainImage,Screen.CursorY),' ');
            SetLineText(MainImage,0,Screen.CursorY,StrRep(#0,80),CurChar.Color);
            SetLineText(MainImage,((80-Length(S)) Div 2)-1,Screen.CursorY,S,CurChar.Color);
          End;
      2:  Begin
            S := strStripB(GetLineText(MainImage,Screen.CursorY),' ');
            SetLineText(MainImage,0,Screen.CursorY,StrRep(#0,80),CurChar.Color);
            SetLineText(MainImage,80-Length(S)-1,Screen.CursorY,S,CurChar.Color);
          End;
      3:  Begin
            S := strStripB(GetLineText(MainImage,Screen.CursorY),' ');
            SetLineText(MainImage,0,Screen.CursorY,StrRep(#0,80),CurChar.Color);
            SetLineText(MainImage,0,Screen.CursorY,S,CurChar.Color);
          End;
      4:  Begin
            SetLineText(MainImage,0,Screen.CursorY,StrRep(#0,80),CurChar.Color);
          End;   
      5: Begin
            Fc := CurChar.Color Mod 16;
            Ft := MainImage.Data[Screen.CursorY][i].Attributes Mod 16;
            For I := 1 To 80 Do MainImage.Data[Screen.CursorY][i].Attributes := MainImage.Data[Screen.CursorY][i].Attributes - Ft + Fc;
         End;
      6: Begin
            Fc := (CurChar.Color Div 16) * 16;
            Ft := (MainImage.Data[Screen.CursorY][i].Attributes Div 16) * 16;
            For I := 1 To 80 Do MainImage.Data[Screen.CursorY][i].Attributes := MainImage.Data[Screen.CursorY][i].Attributes - Ft + Fc;
         End;
      7:  Begin
            i := GetChar(Screen,Keyboard);
            SetLineText(MainImage,0,Screen.CursorY,StrRep(Chr(i),80),CurChar.Color);
          End;  
    End;
  End;

  List.Free;
End;

