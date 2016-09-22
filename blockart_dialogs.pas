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

Unit blockart_dialogs;

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
  IniFiles,
  m_quicksort,
  m_fileio,
  m_DateTime,
  m_MenuInput;
  
Type
  TCharSet = Array[1..10] Of String[10];  
  
Function GetSaveType(Screen: TOutput) : Byte;
Function GetCharSetType(Screen: TOutput) : Byte;
Function GetColor(Screen: TOutput; Keyboard: TInput; Color:Byte) : Byte;
Function GetChar(Screen: TOutput; Keyboard: TInput) : Byte;
Function GetDrawMode(Screen: TOutput) : Byte;
Function ShowMsgBox (BoxType: Byte; Str: String; Screen: TOutput) : Boolean;
Function DrawMode2Str(B:Byte):String;
Function GetSaveFileName(Screen: TOutput; Header,def,xferpath: String): String;
Procedure EditFontFx(Screen: TOutput);
Procedure EditCaseFx(Screen: TOutput);
Function GetUploadFileName(Screen: TOutput; Header,xFerPath: String) : String;
Function GetMYSTICPrep(Screen: TOutput) : Byte;
Function GetANSIPrep(Screen: TOutput) : Byte;


Implementation

Function DrawMode2Str(B:Byte):String;
Begin
  Case B Of
    1: DrawMode2Str := 'Normal Mode';
    2: DrawMode2Str := 'Color Mode';
    3: DrawMode2Str := 'Line Mode';
    5: DrawMode2Str := 'Elite Write Mode';
    6: DrawMode2Str := 'TheDraw Font Mode';
   11: DrawMode2Str := 'Normal + FadeFx Mode';
   15: DrawMode2Str := 'Elite + FadeFx Mode';
   12: DrawMode2Str := 'Normal + CaseFx Mode';
   16: DrawMode2Str := 'Normal + CaseFx Mode';
  End;
End;

Procedure Center(Screen:TOutput;S:String; L:byte);
Begin
  Screen.WriteXYPipe((40-strMCILen(s) div 2),L,7,strMCILen(s),S);
End;

Function ShowMsgBox (BoxType: Byte; Str: String; Screen: TOutput) : Boolean;
Var
  Len    : Byte;
  Len2   : Byte;
  Pos    : Byte;
  MsgBox : TMenuBox;
  Offset : Byte;
  SavedX : Byte;
  SavedY : Byte;
  SavedA : Byte;
  Keyboard : Tinput;
Begin
  ShowMsgBox := True;
  Keyboard := TInput.Create;
  SavedX     := Screen.CursorX;
  SavedY     := Screen.CursorY;
  SavedA     := Screen.TextAttr;

  MsgBox := TMenuBox.Create(TOutput(Screen));

  Len := (80 - (Length(Str) + 2)) DIV 2;
  Pos := 1;
  MsgBox.Header     := ' Info ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;

  If Screen.ScreenSize = 50 Then Offset := 12 Else Offset := 0;

  If BoxType < 2 Then
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 15 + Offset)
  Else
    MsgBox.Open (Len, 10 + Offset, Len + Length(Str) + 3, 14 + Offset);

  Screen.WriteXY (Len + 2, 12 + Offset, 15+7*16, Str);

  Case BoxType of
    0 : Begin
          Len2 := (Length(Str) - 4) DIV 2;

          Screen.WriteXY (Len + Len2 + 2, 14 + Offset, 15+2*16, ' OK ');

          Repeat
            Keyboard.ReadKey;
          Until Not Keyboard.KeyPressed;
        End;
    1 : Repeat
          Len2 := (Length(Str) - 9) DIV 2;

          Screen.WriteXY (Len + Len2 + 2, 14 + Offset, 8+7*16, ' YES ');
          Screen.WriteXY (Len + Len2 + 7, 14 + Offset, 8+7*16, ' NO ');

          If Pos = 1 Then
            Screen.WriteXY (Len + Len2 + 2, 14 + Offset, 15+2*16, ' YES ')
          Else
            Screen.WriteXY (Len + Len2 + 7, 14 + Offset, 15+4*16, ' NO ');

          Case UpCase(Keyboard.ReadKey) of
            #00 : Case Keyboard.ReadKey of
                    #75 : Pos := 1;
                    #77 : Pos := 0;
                  End;
            #13 : Begin
                    ShowMsgBox := Boolean(Pos);
                    Break;
                  End;
            #32 : If Pos = 0 Then Inc(Pos) Else Pos := 0;
            'N' : Begin
                    ShowMsgBox := False;
                    Break;
                  End;
            'Y' : Begin
                    ShowMsgBox := True;
                    Break;
                  End;
          End;
        Until False;
  End;

  If BoxType <> 2 Then MsgBox.Close;

  MsgBox.Free;
  Keyboard.Free;

  Screen.CursorXY (SavedX, SavedY);

  Screen.TextAttr := SavedA;
End;

Function GetSaveFileName(Screen: TOutput; Header,def,xferpath: String): String;
Const
  ColorBox = 7;
  ColorBar = 15 + 2 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  InStr    : TMenuInput;
  Str      : String;
  Path     : String;
  Mask     : String;
  OrigDIR  : String;
  SaveFile : String;

  Procedure UpdateInfo;
  Begin
    Screen.WriteXY (8,  7, 15 + 2 * 16, strPadR(Path, 60, ' '));
    Screen.WriteXY (8, 21, 15 + 2 * 16, strPadR(SaveFile, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    Screen.WriteXY (14, 9, 112, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    Screen.WriteXY (53, 9, 112, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := XferPath;
  Mask     := '*.*';
  SaveFile := def;
  Box      := TMenuBox.Create(TOutput(Screen));
  DirList  := TMenuList.Create(TOutput(Screen));
  FileList := TMenuList.Create(TOutput(Screen));

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Save File ';
  Box.Header := Header;
  Box.HeadAttr := 15 + 7 * 16;
  Box.Open (6, 5, 74, 22);

  Screen.WriteXY ( 8,  6, 112, 'Directory');
  Screen.WriteXY ( 8,  9, 112, 'Files');
  Screen.WriteXY (41,  9, 112, 'Directories');
  Screen.WriteXY ( 8, 20, 112, 'File Name');
  Screen.WriteXY ( 8, 21, 15+2*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          InStr := TMenuInput.Create(TOutput(Screen));
                          InStr.FillAttr := 15+0*16;
                          InStr.Attr := 15+2*16;
                          InStr.LoChars := #09#13#27;

                          Repeat
                            Case Mode of
                              1 : Begin
                                    Str := InStr.GetStr(8, 21, 60, 255, 1, SaveFile);

                                    Case InStr.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              SaveFile := Str;
                                              if SaveFile <> '' then 
                                                if fileexist(Path + Savefile) then Begin
                                                  if ShowMsgBox(1, 'File Exists. Overwrite?',Screen) then Result := Path + Savefile
                                                  End else Result := Path + Savefile;
                                              if result = Path + Savefile then begin
                                                ChDIR(OrigDIR);
                                                FileList.Free;
                                                DirList.Free;
                                                Box.Close;
                                                Box.Free;
                                                exit;
                                              end;
                                              (*CreateLists;
                                              FileList.Update;
                                              DirList.Update;*)
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;

                                    Str := InStr.GetStr(8, 7, 60, 255, 1, Path);

                                    Case InStr.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;

                          InStr.Free;

                          UpdateInfo;

                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;

                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              //Result := Path + FileList.List[FileList.Picked]^.Name;
              if fileexist(Path + FileList.List[FileList.Picked]^.Name) then Begin
                if ShowMsgBox(1, 'File Exists. Overwrite?',Screen) then Result := Path + FileList.List[FileList.Picked]^.Name;
              End else Result := Path + FileList.List[FileList.Picked]^.Name;
              if Result = Path + FileList.List[FileList.Picked]^.Name then Break;
            End;
      #27 : Begin
              Result:='';
              Break;
            End;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
End;

Function GetSaveType(Screen: TOutput) : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Save Format ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('ANSI', 0);
  List.Add('Mystic', 0);
  List.Add('Pascal', 0);
  List.Add('Text Only', 0);

  List.Open (30, 11, 49, 16);
  List.Box.Close;

  Case List.ExitCode of
    #27 : Result := 0;
  Else
    Result := List.Picked;
  End;

  List.Free;
End;

Function GetANSIPrep(Screen: TOutput) : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Preparation ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('Clear Screen', 0);
  List.Add('Home', 0);
  List.Add('None', 0);

  List.Open (30, 11, 49, 15);
  List.Box.Close;

  Case List.ExitCode of
    #27 : Result := 0;
  Else
    Result := List.Picked;
  End;

  List.Free;
End;

Function GetMYSTICPrep(Screen: TOutput) : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Preparation ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('Clear Screen', 0);
  List.Add('No Pause', 0);
  List.Add('Home', 0);
  List.Add('None', 0);

  List.Open (30, 11, 49, 16);
  List.Box.Close;

  Case List.ExitCode of
    #27 : Result := 0;
  Else
    Result := List.Picked;
  End;

  List.Free;
End;

Function GetDrawMode(Screen: TOutput) : Byte;
Var
  List : TMenuList;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Draw Mode ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;

  List.Add('Normal', 0);
  List.Add('Color', 0);
  List.Add('Line', 0);

  List.Open (30, 11, 49, 15);
  List.Box.Close;

  Case List.ExitCode of
    #27 : GetDrawMode := 0;
  Else
    GetDrawMode := List.Picked;
  End;

  List.Free;
End;

Function GetCharSetType(Screen: TOutput) : Byte;
Var
  List  : TMenuList;
  X,Y   : Byte;
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Charset ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  
  List.Add(Chr(218)+Chr(191)+Chr(192)+Chr(217)+Chr(196)+Chr(179)+Chr(195)+Chr(180)+Chr(193)+Chr(194),0);
  List.Add(Chr(201)+Chr(187)+Chr(200)+Chr(188)+Chr(205)+Chr(186)+Chr(199)+Chr(185)+Chr(202)+Chr(203),0);
  List.Add(Chr(213)+Chr(184)+Chr(212)+Chr(190)+Chr(205)+Chr(179)+Chr(198)+Chr(189)+Chr(207)+Chr(209),0);
  List.Add(Chr(197)+Chr(206)+Chr(216)+Chr(215)+Chr(159)+Chr(233)+Chr(155)+Chr(156)+Chr(153)+Chr(239),0);
  List.Add(Chr(176)+Chr(177)+Chr(178)+Chr(219)+Chr(220)+Chr(223)+Chr(221)+Chr(222)+Chr(254)+Chr(249),0);
  List.Add(Chr(214)+Chr(183)+Chr(211)+Chr(189)+Chr(196)+Chr(186)+Chr(199)+Chr(182)+Chr(208)+Chr(210),0);
  List.Add(Chr(174)+Chr(175)+Chr(242)+Chr(243)+Chr(244)+Chr(245)+Chr(246)+Chr(247)+Chr(240)+Chr(251),0);
  List.Add(Chr(166)+Chr(167)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(248)+Chr(252)+Chr(253),0);
  List.Add(Chr(224)+Chr(225)+Chr(226)+Chr(235)+Chr(238)+Chr(237)+Chr(234)+Chr(228)+Chr(229)+Chr(230),0);
  List.Add(Chr(232)+Chr(233)+Chr(234)+Chr(155)+Chr(156)+Chr(157)+Chr(159)+Chr(145)+Chr(146)+Chr(247),0);
  List.Open (30, 8, 43, 19);
  List.Box.Close;

  Case List.ExitCode of
    #27 : GetCharSetType := 4;
  Else
    GetCharSetType := List.Picked;
  End;
  List.Free;
  Screen.CursorXY(X,Y);
End;

Function GetColor(Screen: TOutput; Keyboard: TInput; Color:Byte) : Byte;
Var
  i     : Byte;
  CS    : TCharSet;
  MsgBox: TMenuBox;
  SelFG : Byte;
  SelBG : Byte;
  FB    : Byte;
  X,Y   : Byte;
  
  Procedure DrawColors;
  Var
    d: byte;
  Begin
    For d := 1 to 7 Do Screen.WriteXY(9,6+d,0+7*16,StrRep(' ',65));
    Center(Screen,'|00|23ForeGround Color',6);
    For d := 0 to 15 Do Screen.WriteXY(10+d*4,8,d+7*16,Chr(219)+Chr(219));
    Center(Screen,'|00|23BackGround Color',10);
    For d := 0 to 7 Do Screen.WriteXY(27+d*4,12,0+d*16,'  ');
  End;
  
  Procedure Select(FG:Byte; CL:Byte);
  Begin
    If FG=1 Then Begin
      Screen.WriteXY(9+SelFG*4,8,15+7*16,'[');
      Screen.WriteXY(12+SelFG*4,8,15+7*16,']');
    End Else Begin
      Screen.WriteXY(9+SelFG*4,8,0+7*16,'[');
      Screen.WriteXY(12+SelFG*4,8,0+7*16,']');
    End;
    
    If FG=2 Then Begin
      Screen.WriteXY(26+SelBG*4,12,15+7*16,'[');
      Screen.WriteXY(29+SelBG*4,12,15+7*16,']');
    End Else Begin
      Screen.WriteXY(26+SelBG*4,12,0+7*16,'[');
      Screen.WriteXY(29+SelBG*4,12,0+7*16,']');
    End;
  End;
  
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  MsgBox := TMenuBox.Create(TOutput(Screen));
  MsgBox.Header     := ' Colors ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;
  
  MsgBox.Open (7, 5,74,14);
  DrawColors;
  FB := 1;
  SelFG:= Color mod 16;
  SelBG:= Color Div 16;
  Repeat
    DrawColors;
    Case FB Of
      1: Select(FB,SelFG);
      2: Select(FB,SelBG);
    End;
    Case Keyboard.ReadKey Of
      #13: Begin
            GetColor := SelFG + SelBG*16;
            Break;
          End;
      #27: Begin
            GetColor := Color;
            Break;
          End;
      #00: Case Keyboard.ReadKey Of
        KeyUp   : If FB>1 Then FB:=1;
        KeyDown : If FB<2 Then FB:=2;
        KeyLeft : Case FB of
                    1: If SelFG>0 Then Dec(SelFG);
                    2: If SelBG>0 Then Dec(SelBG);
                  End;
       keyRight : Case FB of
                    1: If SelFG<15 Then Inc(SelFG);
                    2: If SelBG<7 Then Inc(SelBG);
                  End;
      End;
    End;
  Until False;
  MsgBox.Close;
  MsgBox.Free;
  Screen.CursorXY(X,Y);

End;

Function GetChar(Screen: TOutput; Keyboard: TInput) : Byte;
Var
  MsgBox: TMenuBox;
  Col,
  Row   : Byte;
  X,Y   : Byte;
 
  Procedure DrawChars;
  Var
    d,b: byte;
    
  Begin
    For d := 0 to 15 Do 
      For b := 0 To 15 Do Screen.WriteXY(32+b,6+d,0+7*16,chr(b+16*d));
  End;
  
  Procedure Select(Col,Row:Byte);
  Begin
    Screen.WriteXY(32+Col,6+Row,15+2*16,Chr(Col+16*Row));
    Screen.WriteXY(32,5,0+7*16,'Dec: '+ StrI2S(Col+16*Row)+ ' Hex: '+Byte2Hex(Col+16*Row));
  End;
  
Begin
  X := Screen.CursorX;
  Y := Screen.CursorY;
  MsgBox := TMenuBox.Create(TOutput(Screen));
  MsgBox.Header     := ' Chars ';
  MsgBox.FrameType  := 6;
  MsgBox.HeadAttr   := 112;
  MsgBox.BoxAttr    := 127;
  MsgBox.BoxAttr2   := 120;
  MsgBox.BoxAttr3   := 127;
  MsgBox.BoxAttr4   := 120;
  MsgBox.Box3D      := True;
  
  MsgBox.Open (30, 4,49,22);
  
  Col := 0;
  Row := 0;
  Repeat
    DrawChars;
    Select(Col,Row);
    Case Keyboard.ReadKey Of
      #13: Begin
            GetChar := Col+16*Row;
            Break;
          End;
      #27: Begin
            GetChar := 0;
            Break;
          End;
      #00: Case Keyboard.ReadKey Of
        KeyUp   : If Row > 0 Then Dec(Row);
        KeyDown : If Row < 15 Then Inc(Row);
        KeyLeft : If Col > 0 Then Dec(Col);
       keyRight : If Col < 15 Then Inc(Col);
      End;
    End;
  Until False;
  MsgBox.Close;
  MsgBox.Free;
  Screen.CursorXY(X,Y);

End;

Procedure EditFontFx(Screen: TOutput);
Var
  MyBox  : TMenuBox;
  MyForm : TMenuForm;
  Data   : Array[1..10] of String;
  Ini    : TIniFile;
  i      : Byte;
Begin
  FillChar (Data, SizeOf(Data), #0);

  Ini := TIniFile.Create('blockart.ini');
  For i := 1 To 10 Do Data[i] := Ini.ReadString('FontFx',StrI2S(i),'');
  
  MyBox  := TMenuBox.Create(Screen);
  MyForm := TMenuForm.Create(Screen);

  MyBox.Header := ' Font FX Edit ';

  MyBox.Open   (12, 6, 69, 18);

  MyForm.AddStr ('1',' FX1 ', 13,  8, 24,  8, 11, 42, 60, @Data[1], Data[1]);
  MyForm.AddStr ('2',' FX2 ', 13,  9, 24,  9, 11, 42, 60, @Data[2], Data[2]);
  MyForm.AddStr ('3',' FX3 ', 13, 10, 24, 10, 11, 42, 60, @Data[3], Data[3]);
  MyForm.AddStr ('4',' FX4 ', 13, 11, 24, 11, 11, 42, 60, @Data[4], Data[4]);
  MyForm.AddStr ('5',' FX5 ', 13, 12, 24, 12, 11, 42, 60, @Data[5], Data[5]);
  MyForm.AddStr ('6',' FX6 ', 13, 13, 24, 13, 11, 42, 60, @Data[6], Data[6]);
  MyForm.AddStr ('7',' FX7 ', 13, 14, 24, 14, 11, 42, 60, @Data[7], Data[7]);
  MyForm.AddStr ('8',' FX8 ', 13, 15, 24, 15, 11, 42, 60, @Data[8], Data[8]);
  MyForm.AddStr ('9',' FX9 ', 13, 16, 24, 16, 11, 42, 60, @Data[9], Data[9]);
  MyForm.AddStr ('0',' FX0 ', 13, 17, 24, 17, 11, 42, 60, @Data[10], Data[10]);
  

  MyForm.Execute;

  MyBox.Close;
  
  If MyForm.Changed Then
    If ShowMsgBox(1, 'Save changes?',Screen) Then Begin
      For i := 1 to 10 Do Ini.WriteString('FontFx',StrI2S(i),Data[i]);
    End;
  Ini.Free;
  MyForm.Free;
  MyBox.Free;
End;

Procedure CustomizeCaseFX(N: Byte; Screen:TOutput);
Var
  MyBox  : TMenuBox;
  MyForm : TMenuForm;
  Data   : Array[1..4] of String;
  Ini    : TIniFile;
  i      : Byte;
Begin
  FillChar (Data, SizeOf(Data), #0);

  Ini := TIniFile.Create('blockart.ini');
  Data[1] := Ini.ReadString('CaseFx'+StrI2S(N),'Capitals','');
  Data[2] := Ini.ReadString('CaseFx'+StrI2S(N),'Lowers','');
  Data[3] := Ini.ReadString('CaseFx'+StrI2S(N),'Numbers','');
  Data[4] := Ini.ReadString('CaseFx'+StrI2S(N),'Symbols','');
  
  MyBox  := TMenuBox.Create(Screen);
  MyForm := TMenuForm.Create(Screen);

  MyBox.Header := ' Case FX Edit ';

  MyBox.Open   (12, 7, 69, 12);

  MyForm.AddStr ('1',' Capitals ', 13,  8, 24,  8, 11, 42, 60, @Data[1], Data[1]);
  MyForm.AddStr ('2',' Lowers ', 13,  9, 24,  9, 11, 42, 60, @Data[2], Data[2]);
  MyForm.AddStr ('3',' Numbers ', 13, 10, 24, 10, 11, 42, 60, @Data[3], Data[3]);
  MyForm.AddStr ('4',' Symbols ', 13, 11, 24, 11, 11, 42, 60, @Data[4], Data[4]);
  
  MyForm.Execute;

  MyBox.Close;
  
  If MyForm.Changed Then
    If ShowMsgBox(1, 'Save changes?',Screen) Then Begin
      Ini.WriteString('CaseFx'+StrI2S(N),'Capitals',Data[1]);
      Ini.WriteString('CaseFx'+StrI2S(N),'Lowers',Data[2]);
      Ini.WriteString('CaseFx'+StrI2S(N),'Numbers',Data[3]);
      Ini.WriteString('CaseFx'+StrI2S(N),'Symbols',Data[4]);
    End;
  Ini.Free;
  MyForm.Free;
  MyBox.Free;
End;


Procedure EditCaseFx(Screen: TOutput);
Var
  List : TMenuList;
  i    : Byte;
Begin
  List := TMenuList.Create(TOutput(Screen));

  List.Box.Header    := ' Select ';
  List.Box.HeadAttr  := 15 + 7 * 16;
  List.Box.FrameType := 6;
  List.Box.Box3D     := True;
  List.PosBar        := False;
  
  List.HiAttr := 15+1*16;
  List.LoAttr := 0 + 7*16;
  
  For i := 1 to 10 Do
    List.Add('Case FX No '+StrI2S(i), 0);
  
  Repeat
    List.Open (30, 8, 49, 19);
    List.Box.Close;

    Case List.ExitCode of
      #27 : Break;
    Else
      CustomizeCaseFX(List.Picked,Screen);
    End;
  Until False;
  List.Free;
End;

Function GetUploadFileName(Screen: TOutput; Header,xFerPath: String) : String;
Const
  ColorBox = 7;
  ColorBar = 15 + 2 * 16;
Var
  DirList  : TMenuList;
  FileList : TMenuList;
  InStr    : TMenuInput;
  Str      : String;
  Path     : String;
  Mask     : String;
  OrigDIR  : String;

  Procedure UpdateInfo;
  Begin
    Screen.WriteXY (8,  7, 15 + 2 * 16, strPadR(Path, 60, ' '));
    Screen.WriteXY (8, 21, 15 + 2 * 16, strPadR(Mask, 60, ' '));
  End;

  Procedure CreateLists;
  Var
    Dir      : SearchRec;
    DirSort  : TQuickSort;
    FileSort : TQuickSort;
    Count    : LongInt;
  Begin
    DirList.Clear;
    FileList.Clear;

    While Path[Length(Path)] = PathSep Do Dec(Path[0]);

    ChDir(Path);

    Path := Path + PathSep;

    If IoResult <> 0 Then Exit;

    DirList.Picked  := 1;
    FileList.Picked := 1;

    UpdateInfo;

    DirSort  := TQuickSort.Create;
    FileSort := TQuickSort.Create;

    FindFirst (Path + '*', AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If (Dir.Attr And Directory = 0) or ((Dir.Attr And Directory <> 0) And (Dir.Name = '.')) Then Begin
        FindNext(Dir);
        Continue;
      End;

      DirSort.Add (Dir.Name, 0);
      FindNext    (Dir);
    End;

    FindClose(Dir);

    FindFirst (Path + Mask, AnyFile - VolumeID, Dir);

    While DosError = 0 Do Begin
      If Dir.Attr And Directory <> 0 Then Begin
        FindNext(Dir);

        Continue;
      End;

      FileSort.Add(Dir.Name, 0);
      FindNext(Dir);
    End;

    FindClose(Dir);

    DirSort.Sort  (1, DirSort.Total,  qAscending);
    FileSort.Sort (1, FileSort.Total, qAscending);

    For Count := 1 to DirSort.Total Do
      DirList.Add(DirSort.Data[Count]^.Name, 0);

    For Count := 1 to FileSort.Total Do
      FileList.Add(FileSort.Data[Count]^.Name, 0);

    DirSort.Free;
    FileSort.Free;

    Screen.WriteXY (14, 9, 7*16, strPadR('(' + strComma(FileList.ListMax) + ')', 7, ' '));
    Screen.WriteXY (53, 9, 7*16, strPadR('(' + strComma(DirList.ListMax) + ')', 7, ' '));
  End;

Var
  Box  : TMenuBox;
  Done : Boolean;
  Mode : Byte;
Begin
  Result   := '';
  Path     := XferPath;
  Mask     := '*.*';
  Box      := TMenuBox.Create(TOutput(Screen));
  DirList  := TMenuList.Create(TOutput(Screen));
  FileList := TMenuList.Create(TOutput(Screen));

  GetDIR (0, OrigDIR);

  FileList.NoWindow   := True;
  FileList.LoChars    := #9#13#27;
  FileList.HiChars    := #77;
  FileList.HiAttr     := ColorBar;
  FileList.LoAttr     := ColorBox;

  DirList.NoWindow    := True;
  DirList.NoInput     := True;
  DirList.HiAttr      := ColorBox;
  DirList.LoAttr      := ColorBox;

  //Box.Header := ' Upload file ';
  Box.Header := Header;
  Box.HeadAttr := 15+7*16;
  Box.Open (6, 5, 74, 22);

  Screen.WriteXY ( 8,  6, 7*16, 'Directory');
  Screen.WriteXY ( 8,  9, 7*16, 'Files');
  Screen.WriteXY (41,  9, 7*16, 'Directories');
  Screen.WriteXY ( 8, 20, 7*16, 'File Mask');
  Screen.WriteXY ( 8, 21,  51+2*16, strRep(' ', 40));

  CreateLists;

  DirList.Open (40, 9, 72, 19);
  DirList.Update;

  Done := False;

  Repeat
    FileList.Open (7, 9, 39, 19);

    Case FileList.ExitCode of
      #09,
      #77 : Begin
              FileList.HiAttr := ColorBox;
              DirList.NoInput := False;
              DirList.LoChars := #09#13#27;
              DirList.HiChars := #75;
              DirList.HiAttr  := ColorBar;

              FileList.Update;

              Repeat
                DirList.Open(40, 9, 72, 19);

                Case DirList.ExitCode of
                  #09 : Begin
                          DirList.HiAttr := ColorBox;
                          DirList.Update;

                          Mode  := 1;
                          InStr := TMenuInput.Create(TOutput(Screen));
                          InStr.LoChars := #09#13#27;
                          InStr.FillAttr := 15+0*16;
                          InStr.Attr := 15+2*16;
                          Repeat
                            Case Mode of
                              1 : Begin
                                    InStr.Attr := 15+2*16;
                                    Str := InStr.GetStr(8, 21, 40, 255, 1, Mask);

                                    Case InStr.ExitCode of
                                      #09 : Mode := 2;
                                      #13 : Begin
                                              Mask := Str;
                                              CreateLists;
                                              FileList.Update;
                                              DirList.Update;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                              2 : Begin
                                    UpdateInfo;
                                    InStr.Attr := 15+2*16;
                                    Str := InStr.GetStr(8, 7, 40, 255, 1, Path);

                                    Case InStr.ExitCode of
                                      #09 : Break;
                                      #13 : Begin
                                              ChDir(Str);

                                              If IoResult = 0 Then Begin
                                                Path := Str;
                                                CreateLists;
                                                FileList.Update;
                                                DirList.Update;
                                              End;
                                            End;
                                      #27 : Begin
                                              Done := True;
                                              Break;
                                            End;
                                    End;
                                  End;
                            End;
                          Until False;

                          InStr.Free;

                          UpdateInfo;

                          Break;
                        End;
                  #13 : If DirList.ListMax > 0 Then Begin
                          ChDir  (DirList.List[DirList.Picked]^.Name);
                          GetDir (0, Path);

                          Path := Path + PathSep;

                          CreateLists;
                          FileList.Update;
                        End;
                  #27 : Done := True;
                  #75 : Break;
                End;
              Until Done;

              DirList.NoInput := True;
              DirList.HiAttr  := ColorBox;
              FileList.HiAttr := ColorBar;
              DirList.Update;
            End;
      #13 : If FileList.ListMax > 0 Then Begin
              Result := Path + FileList.List[FileList.Picked]^.Name;
              Break;
            End;
      #27 : Break;
    End;
  Until Done;

  ChDIR(OrigDIR);

  FileList.Free;
  DirList.Free;
  Box.Close;
  Box.Free;
End;
  
Begin

End.
