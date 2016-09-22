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

Program blockart;

{$I M_OPS.PAS}


Uses
  Math,
  m_Types,
  DOS,
  m_Strings,
  m_Input,
  m_Output,
  m_MenuBox,
  m_MenuForm,
  m_quicksort,
  m_ansi2pipe,
  m_fileio,
  m_Term_Ansi,
  m_DateTime,
  blockart_dialogs,
  blockart_tdf,
  IniFiles,
  asciidraw,
  blockart_block,
  blockart_save,
  blockart_tdfgallery,
  m_MenuInput;

Type
  TCharSet = Array[1..10] Of String[10];
  
  TGrChar = Record
    Ch          : Char;
    Color       : Byte;
    SelCharSet  : Byte;
    CharSet     : Array[1..10] Of String[10];
    OldX,
    OldY        : Byte;
    Tabs        : Byte;
    Ins         : Boolean;
    PX,PY       : Byte;
    FontFX      : String;
    FontFxSel   : Byte;
    FontFxCnt   : Byte;
    FontFxIdx   : Byte;
    CaseFXCap   : String;
    CaseFXLow   : String;
    CaseFXNum   : String;
    CaseFXSym   : String;
    CaseFxSel   : Byte;
    TDF         : String;
    TDF_LWidth  : Byte;
    TDF_LHeight : Byte;
    SaveCur     : Boolean;
    Mouse       : Boolean;
    MouseBut    : Byte;
  End;
  
  TUndo = Record
    Index : Byte;
    Count : Byte;
    Max   : Byte;
  End;
  
  TSettings = Record
    Artist  : String[30];
    Group   : String[30];
    Title   : String[40];
    Sauce   : Boolean;
    CharSet : Byte;
    Folder  : String;
  End;
  
Const
  { TheDraw Pascal Crunched Screen Image.  Date: 09/03/02 }
  TESTMAIN_WIDTH=80;
  TESTMAIN_LENGTH=128;
  TESTMAIN : array [1..128] of Char = (
    #15,#16,#26,'N','Ü', #7,'Ü',#24,#15,'Û',#23,#25,'M', #8,#16,'Û',#24,
     #7,'ß', #8,#26,'N','ß',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',
    ' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',
    #24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,
    #26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,
    ' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',' ',#24,#26,' ',
    ' ',#24,#26,'@','Ä',' ',#26, #3,'Ä',' ','Ä','Ä',' ',' ','Ä',' ',' ',
    'ù',#24,#15,':', #7,':', #8,':',#24);
    (*
    TESTMAIN : array [1..128] of Char = (
    #15,#16,#26,'N','Ü', #7,'Ü',#24,#15,'Û',#23,#25,'M', #8,#16,'Û',#24,
     #7,'ß', #8,#26,'N','ß',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O',
    '°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',
    #24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,
    #26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,
    'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O','°',#24,#26,'O',
    '°',#24,#26,'@','Ä',' ',#26, #3,'Ä',' ','Ä','Ä',' ',' ','Ä',' ',' ',
    'ù',#24,#15,':', #7,':', #8,':',#24);
    *)
    
  NormalFont    = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_''abcdefghijklmnopqrstuvwxyz';
  
  
  Save_ANSI     = 1;
  Save_Mystic   = 2;
  Save_Pascal   = 3;
  Save_Text     = 4;
  
  Draw_Color    = 2;
  Draw_Line     = 3;
  Draw_Normal   = 1;
  Draw_Block    = 4;
  Draw_Elite    = 5;
  Draw_TDF      = 6;
  Draw_FontFx   = 10;
  Draw_CaseFX   = 11;
  
  Move_None     = 0;
  Move_Left     = 1;
  Move_Right    = 2;
  Move_Down     = 3;
  Move_Up       = 4;

Var
  Settings     : TSettings;
  Undo         : TUndo;
  Screen       : TOutput;
  Menu         : TMenuForm;
  Box          : TMenuBox;
  Image        : TConsoleImageRec;
  MainImage    : TConsoleImageRec;
  MenuPosition : Byte;
  Res          : Char;
  Keyboard     : Tinput;
  Edited       : Boolean = False;
  CurrentFile  : String = 'untitled.ans';
  RestoreScreen: Boolean = True;
  CurChar      : TGrChar;
  i,d          : Integer;
  SaveMode     : Byte;
  DrawMode     : Byte;
  DrawFx       : Byte = 0;
  Ch           : Char;
  mv,lmv       : Byte;
  Font         : Array[1..2,65..122] of Byte = 
  ((65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122),
   (146,225,128,239,228,159,71,72,173,74,75,156,77,227,229,80,81,158,36,84,239,251,87,145,157,90,91,92,93,94,95,96,224,225,155,235,238,159,103,104,173,245,107,156,109,252,48,112,113,231,36,194,117,251,119,247,230,122));
  CharSetPr    : Array[1..10] Of String;
  CharSet      : Array[1..10,1..10] of Byte = ((218,191,192,217,196,179,195,180,193,194),
  (201,187,200,188,205,186,199,185,202,203),
  (213,184,212,190,205,179,198,189,207,209),
  (197,206,216,215,159,233,155,156,153,239),
  (176,177,178,219,220,223,221,222,254,249),
  (214,183,211,189,196,186,199,182,208,210),
  (174,175,242,243,244,245,246,247,240,251),
  (166,167,168,169,170,171,172,248,252,253),
  (224,225,226,235,238,237,234,228,229,230),
 (232,233,234,155,156,157,159,145,146,247));     
(*
  ((218,191,192,217,196,179,195,180,193,194),
  (201,187,200,188,205,186,199,185,202,203),
  (213,184,212,190,205,179,198,189,207,209),
  (197,206,216,215,159,233,155,156,153,239),
  (176,177,178,219,220,223,221,222,254,249),
  (214,183,211,189,196,186,199,182,208,210),
  (174,175,242,243,244,245,246,247,240,251),
  (166,167,168,169,170,171,172,248,252,253),
  (224,225,226,235,238,237,234,228,229,230),
 (232,233,234,155,156,157,159,145,146,247))
 *)
 

{$I BLOCKART_COMMON.PAS}  

Procedure DrawLogo;
{ TheDraw Pascal Crunched Screen Image.  Date: 09/21/16 }
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=810;
  IMAGEDATA : array [1..810] of Char = (
     #7,#16,#24,#25, #9, #8,#23,'Û','Û',#16,#25, #5,#23,'°','±',#16,#25,
     #3,#23,'Û','Û',#16,'ß',#26, #3,'Û',' ',#23,'Û','Û',#16,'ß',#26, #3,
    'Û',' ',#23,'°','±',#16,' ',#26, #3,'Û',' ','ß','ß','ß',#26, #3,'Û',
    ' ',#23,'°','±',#16,'ß',#26, #3,'Û',' ',#23,'°','±',#16,'ß',#26, #3,
    'Û',#24,#25, #9,#23,'Û','Û',#16,#26, #4,'Ü',' ',#23,'±','²',#16,#25,
     #3,#23,'Û','Û',#16,' ',#26, #3,'Û',' ',#23,'Û','Û',#16,' ',#26, #3,
    'ß',' ',#23,'±','²',#16,' ',#26, #3,'Û',' ',#23,'Û','Û',#16,'ß',#26,
     #3,'Û',' ',#23,'±','²',#16,' ',#26, #3,'Û',' ',#23,'±','²',#16,' ',
    #26, #3,'Û',#24,#25, #9,'ß','ß',' ',#26, #3,'ß',' ','ß','ß',#25, #3,
    'ß','ß',' ',#26, #3,'ß',' ','ß','ß',#25, #5,#26, #5,'ß',' ',' ','ß',
    'ß',' ',#26, #3,'ß',' ','ß','ß',' ',#26, #3,'ß',' ','ß','ß',' ',#26,
     #3,'ß',#24,#25, #9,#15,#23,'±','²',#16,' ', #7,'Û',#15,#23,'°','±',
    '²',#16,' ',#23,'²','±',#16,#25, #3,#23,'±','²',#16,' ', #7,'Û',#15,
    #23,'°','±','²',#16,' ',#23,'±','²',#16,' ', #7,'Û',#15,#23,'°','±',
    '²',#16,' ',#23,'±','²',#16,' ',#23,' ','°','±','²',#16,' ',#23,'±',
    '²',#16,' ', #7,'Û',#15,#23,'°','±','²',#16,' ',#23,'±','²',#16,' ',
     #7,'Û',#15,#23,'°','±','²',#16,#25, #3,#23,'²','±','°', #7,#16,'Û',
    #24,#25, #9,#15,#23,'°','±',#16,' ', #7,'Û','Û',#15,#23,'°','±',#16,
    ' ',#23,'±','°',#16,#25, #3,#23,'°','±',#16,' ', #7,'Û','Û',#15,#23,
    '°','±',#16,' ',#23,'°','±',#16,' ', #7,'Û','Û',#15,#23,'°','±',#16,
    ' ',#23,'°','±',#16,' ',#23,' ',' ','°','±',#16,' ',#23,'°','±',#16,
    ' ', #7,'Û','Û',#15,#23,'°','±',#16,' ',#23,'°','±',#16,' ', #7,'Û',
    'Û',#15,#23,'°','±',#16,#25, #3,#23,'±','°', #7,#16,'Û','Û',#24,#25,
     #9,'Û',#15,#23,'°',#16,' ', #7,'Û','Û','Û',#15,#23,'°',#16,' ',#23,
    '°',' ',#16,#25, #3, #7,'Û',#15,#23,'°',#16,' ', #7,'Û','Û','Û',#15,
    #23,'°',#16,' ', #7,'Û',#15,#23,'°',#16,' ', #7,'Û','Û','Û',#15,#23,
    '°',#16,' ',#23,' ','°',#16,' ',#23,' ', #7,#16,'Û','Û',#15,#23,'°',
    #16,' ', #7,'Û',#15,#23,'°',#16,' ', #7,'Û','Û','Û',#15,#23,'°',#16,
    ' ', #7,'Û',#15,#23,'°',#16,#25, #8,#23,'°', #7,#16,'Û','Û','Û',#24,
    #25, #9,'Û','Û','Ü',#26, #3,'Û',' ','Û','Û','Ü','Ü','Ü',' ','Û','Û',
    'Ü',#26, #3,'Û',' ','Û','Û','Ü',#26, #3,'Û',' ','Û','Û',' ',#26, #3,
    'Û',' ','Û','Û','Ü',#26, #3,'Û',' ','Û','Û',#25, #8,#26, #3,'Û',#24,
    #25, #9,#26,'<','Ü',#24,#24,#25,'6',#15,'û', #7,'î', #8,'ç','$','­',
    '0','ü',' ',#15,'0', #7,'.', #8,'8',' ',#15,'á', #7,'î', #8,'Â','à',
    #24,#24,#24,#25,#14,#15,'T', #7,'h','i','s',' ','i','s',' ','a',' ',
    'b','e','t','a',' ','v','e','r','s','i','o','n',' ','o','f',' ',#15,
    'B', #7,'l','o','c','k',#15,'A', #7,'r','t',' ',#15,'A','N','S','I',
    ' ','E', #7,'d','i','t','o','r',#24,#24,#25,#13,'S','e','n','d',' ',
    'f','e','e','d','b','a','c','k',' ','/',' ','s','u','g','g','e','s',
    't','i','o','n','s',' ','a','t',' ','x','q','t','r','.','x','q','t',
    'r','#','g','m','a','i','l','.','c','o','m',#24,#25,#21,'o','r',' ',
    'i','n',' ','f','s','x','N','e','t',' ','/',' ','G','e','n','e','r',
    'a','l',' ','C','h','a','t',' ','A','r','e','a','.',#24,#24,#24,#24,
    #24,#25,#12,#15,'P', #7,'r','e','s','s',' ',#15,'E','S','C',' ', #7,
    'f','o','r',' ',#15,'M', #7,'a','i','n',' ',#15,'M', #7,'e','n','u',
    ' ',#11,'-',' ',#15,'A', #7,'n','y',' ',#15,'O', #7,'t','h','e','r',
    ' ',#15,'K', #7,'e','y',' ','t','o',' ',#15,'C', #7,'o','n','t','i',
    'n','u','e',#11,'.','.','.',#24,#24,#24,#24);
Begin
  Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1);    
End;  


Procedure AppExit;
Begin
  If ShowMsgBox(1,'Are you Sure?',Screen)=False Then Exit;
  If Edited=True Then Begin
    Screen.GetScreenImage(1, 1, 80, 25, MainImage);
    If ShowMsgBox(1,'Save File?',Screen)=True Then SaveFile(MainImage,Screen);
  End;
  Screen.ClearScreen;
  Menu.Free;
  Keyboard.free;
  Screen.Free;
  SaveSettings;
  DeleteUndoFiles;
End;

Procedure CoolBoxOpen (X1: Byte; Text: String);
Var
  Len : Byte;
Begin
  Len := Length(Text) + 6;

  Screen.GetScreenImage(X1, 1, X1 + Len, 3, Image);
  Screen.WriteXY(1,2,8+7*16,'    Main Menu    Tools    Fonts    Options    Screen    Exit');
  Screen.WriteXYPipe (X1, 1, 8, Len, 'Ü|15Ü|11ÜÜ|03ÜÜ|09Ü|03Ü|09' + strRep('Ü', Len - 9) + '|08Ü');
  Screen.WriteXYPipe (X1 ,2, 8, Len, 'Ý|09|17² |15' + Text + ' |00°|16|08Þ');
  Screen.WriteXYPipe (X1, 3, 8, Len, 'ß|01²|17 |11À|03ÄÄ|08' + strRep('Ä', Length(Text) - 4) + '|00¿ ±|16|08ß');
End;


Begin
  Screen := TOutput.Create(True);
  Menu   := TMenuForm.Create(Screen);
  Keyboard := Tinput.create;
  Screen.SetWindowTitle('BlockArt');
  //Screen.LoadScreenImage(TESTMAIN, TESTMAIN_LENGTH, TESTMAIN_WIDTH, 1, 1);
  SaveMode := Save_ANSI;
  DrawMode := Draw_Normal;
  MenuPosition  := 0;
  CurChar.Ch    := ' ';
  CurChar.Color := 7;
  CurChar.Tabs  := 2;
  CurChar.Ins   := False;
  CurChar.TDF   := '';
  CurChar.Ins   := False;
  blockart_tdf.Screen := Screen;
  InitCharSet;
  LoadSettings;
  GetDir(0,Settings.Folder);
  CurChar.SaveCur := False;
  blockart_save.SaveCur := CurChar.SaveCur;
  
  Undo.Count:=1;
  Undo.Max := 20;
  Undo.Index := 1;
  
  DrawLogo;
  Keyboard.Readkey;
  Screen.ClearScreen;
  
  CharSetPr[1] := Chr(218)+Chr(191)+Chr(192)+Chr(217)+Chr(196)+Chr(179)+Chr(195)+Chr(180)+Chr(193)+Chr(194);
  CharSetPr[2] := Chr(201)+Chr(187)+Chr(200)+Chr(188)+Chr(205)+Chr(186)+Chr(199)+Chr(185)+Chr(202)+Chr(203);
  CharSetPr[3] := Chr(213)+Chr(184)+Chr(212)+Chr(190)+Chr(205)+Chr(179)+Chr(198)+Chr(189)+Chr(207)+Chr(209);
  CharSetPr[4] := Chr(197)+Chr(206)+Chr(216)+Chr(215)+Chr(159)+Chr(233)+Chr(155)+Chr(156)+Chr(153)+Chr(239);
  CharSetPr[5] := Chr(176)+Chr(177)+Chr(178)+Chr(219)+Chr(220)+Chr(223)+Chr(221)+Chr(222)+Chr(254)+Chr(249);
  CharSetPr[6] := Chr(214)+Chr(183)+Chr(211)+Chr(189)+Chr(196)+Chr(186)+Chr(199)+Chr(182)+Chr(208)+Chr(210);
  CharSetPr[7] := Chr(174)+Chr(175)+Chr(242)+Chr(243)+Chr(244)+Chr(245)+Chr(246)+Chr(247)+Chr(240)+Chr(251);
  CharSetPr[8] := Chr(166)+Chr(167)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(248)+Chr(252)+Chr(253);
  CharSetPr[9] := Chr(224)+Chr(225)+Chr(226)+Chr(235)+Chr(238)+Chr(237)+Chr(234)+Chr(228)+Chr(229)+Chr(230);
  CharSetPr[10] := Chr(232)+Chr(233)+Chr(234)+Chr(155)+Chr(156)+Chr(157)+Chr(159)+Chr(145)+Chr(146)+Chr(247);
  
  
  For i := 1 to 5 Do
    For d := 1 to 10 Do
      CurChar.Charset[i][d]:=Chr(200+i*d);
      
  Repeat
  CurChar.OldX := Screen.CursorX;
  CurChar.OldY := Screen.CursorY;
  If Keyboard.Keypressed Then Begin
  Ch := Keyboard.Readkey; 
  Case Ch of
    #00: Case Keyboard.Readkey of
      KeyAltZ: UndoScreen;
      KeyAltB: Begin
                  //DrawMode := Draw_Block;
                  Screen.GetScreenImage(1, 1, 80, 25, MainImage);
                  AddUndoState(20,MainImage);
                  Edited := ManageBlock(Screen,Keyboard,CurChar.Color,CurChar.SelCharset);
               End;
      KeyAltG: Begin
                Screen.GetScreenImage(1, 1, 80, 25, MainImage);
                AddUndoState(20,MainImage);
                Global(MainImage);
                Edit;
                Screen.PutScreenImage(MainImage);
               End;
      KeyAltO: Begin
                Screen.GetScreenImage(1, 1, 80, 25, MainImage);
                AddUndoState(20,MainImage);
                OpenFile;
                RestoreScreen := False;
               End;
      KeyAltC: CurChar.SelCharSet := GetCharSetType(Screen);
      KeyAltD: DrawMode := GetDrawMode(Screen);
      KeyAltS: Begin
                 Screen.GetScreenImage(1, 1, 80, 25, MainImage);
                 SaveFile(MainImage,Screen);
                 Edited:=False;
              End;
      KeyAltU: CurChar.Color := Screen.ReadAttrXY(Screen.CursorX,Screen.CursorY);
      KeyAltI: Begin 
                  
                  Screen.GetScreenImage(1,1,80,25,Image);
                  AddUndoState(20,Image);
                  InsertLine(Image); 
                  Screen.PutScreenImage(Image);
                  Edit;
               End;
      KeyAltY: Begin 
                  Screen.GetScreenImage(1,1,80,25,Image);
                  AddUndoState(20,Image);
                  DeleteLine(Image); 
                  Screen.PutScreenImage(Image);
                  Edit;
                  End;
      KeyAltH: Begin 
                  Screen.GetScreenImage(1,1,80,25,Image);
                  AddUndoState(20,Image);
                  DeleteRow(Image); 
                  Screen.PutScreenImage(Image);
                  Edit;
                  End;
      KeyAltK: Begin 
                  Screen.GetScreenImage(1,1,80,25,Image);
                  AddUndoState(20,Image);
                  InsertRow(Image); 
                  Screen.PutScreenImage(Image);
                  Edit;
                  End;  
      KeyAltL: Begin 
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(20,MainImage);
                  LineTools;
                  Screen.PutScreenImage(MainImage);
                  Edit;
                  End;  
      KeyAltA: Begin
                  Screen.GetScreenImage(1, 1, 80, 25, MainImage);
                  CurChar.Color:=GetColor(Screen,Keyboard,CurChar.Color);
                  Screen.PutScreenImage(MainImage);
               End;
      KeyAltp: CursorBlock;
      KeyAltX:  Begin
                  AppExit;
                  Halt;
                End;
          #82:  CursorINS; //Insert
          #59: Begin
                Screen.GetScreenImage(1,1,80,25,MainImage);
                AddUndoState(2,MainImage);
                Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][1]));
                CursorRight;
               End;
          #60:  Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][2]));
                  CursorRight;
                  Edit;
                End;
          #61:  Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][3]));
                  CursorRight;
                  Edit;
                End;
          #62: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][4]));
                  CursorRight;
                  Edit;
                End;
          #63: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][5]));
                  CursorRight;
                  Edit;
                End;
          #64: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][6]));
                  CursorRight;
                  Edit;
                End;
          #65: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][7]));
                  CursorRight;
                  Edit;
                End;
          #66: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][8]));
                  CursorRight;
                  Edit;
                End;
          #67: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][9]));
                  CursorRight;
                  Edit;
                End;
          #68: Begin
                  Screen.GetScreenImage(1,1,80,25,MainImage);
                  AddUndoState(2,MainImage);
                  Screen.WriteXY(Screen.CursorX,Screen.CursorY,CurChar.Color,Chr(CharSet[CurChar.SelCharSet][10]));
                  CursorRight;
                  Edit;
                End;
          keyUP   : CursorUp; 
          keyDOWN : CursorDown;      
          keyLEFT : CursorLeft;      
          keyRIGHT: CursorRight;      
          keyPGUP : CursorPGUP;      
          keyPGDN : CursorPGDN;       
          keyHOME : CursorHome;    
          keyEND  : CursorEnd;      
         End;
    #13: CursorEnter;
    #8 : Begin 
           If DrawMode <> Draw_TDF Then Begin
              CursorBackSpace;
              Edit;
           End Else Begin
              Screen.GetScreenImage(1,1,80,25,MainImage);
              AddUndoState(10,MainImage);
              D := Screen.CursorY;
              I := Screen.CursorX;
              BoxClear(I- CurChar.TDF_LWidth - blockart_tdf.Font.Spacing - 1 ,D, I, D + blockart_tdf.ChHeight);
              Screen.CursorXY(I-CurChar.TDF_LWidth - blockart_tdf.Font.Spacing - 1, Screen.CursorY);
           End;
         End;
    #9 : CursorTAB;
#32..#126 : Begin CursorOther; Edit; End;
    #27: If DrawMode = Draw_Block Then Begin
            //DisableBlock;
         End Else Begin
          Screen.GetScreenImage(1, 1, 80, 25, MainImage);
          RestoreScreen := True;
          //Screen.LoadScreenImage(TESTMAIN, TESTMAIN_LENGTH, TESTMAIN_WIDTH, 1, 1);
          Repeat
          Screen.PutScreenImage(MainImage);
          Screen.WriteXY (1, 1, 15+0*16, strRep('Ü', 80));
          Screen.WriteXY (1, 2, 7+7*16, StrRep(' ',80));
          Screen.WriteXY (1, 3,  8+0*16, strRep('ß', 80));
          Screen.WriteXY (1, 21, 15+0*16, strRep('Ü', 80));
          Screen.WriteXY (1, 22, 7+7*16, strRep(' ', 80));
          Screen.WriteXY (1, 23, 7+7*16, strRep(' ', 80));
          Screen.WriteXY (1, 24,  8+0*16, strRep('ß', 80));
          //Center('|16|15C|07urrent |15F|07ile: '+CurrentFile,21);
          Screen.WriteXYPipe(1,22,7,80,'|23|15I|08nsert: '+strYN(CurChar.Ins));
          
          Screen.WriteXYPipe(80-Length('File: ' + JustFileName(CurrentFile)),22,8+7*16,80,'File: ' + JustFile(CurrentFile));
          Screen.WriteXYPipe(1,23,7,80,'|23|15D|08raw |15M|08ode: '+DrawMode2Str(DrawMode));
          Screen.WriteXYPipe(35,23,7,80,'|23|15C|08harset: '+ CharSetPr[CurChar.SelCharSet]);
          Screen.WriteXYPipe(64,23,7,3,'|23|15F|08G: ');
          Screen.WriteXY(68,23,CurChar.Color Mod 16,Chr(219)+Chr(219)+Chr(219)+Chr(219));
          Screen.WriteXYPipe(73,23,7,3,'|23|15B|08G: ');
          Screen.WriteXY(77,23,(CurChar.Color Div 16) * 16,'    ');
          
          Menu.Clear;
          
          If MenuPosition = 0 Then Begin
            Menu.HiExitChars := #80;
            Menu.ExitOnFirst := False;
          End Else Begin
            Menu.HiExitChars := #75#77#27;
            Menu.ExitOnFirst := True;
          End;
      
          Case MenuPosition of
            0 : Begin
                  Menu.AddNone('M', ' Main Menu ',  3, 2, 11, 'Main Menu');
                  Menu.AddNone('T', ' Tools ',     16, 2, 7,  'Draw Tools');
                  Menu.AddNone('F', ' Fonts ',     25, 2, 7,  'TheDraw Fonts');
                  Menu.AddNone('O', ' Options ',   35, 2, 9,  'Menu menu options');
                  Menu.AddNone('S', ' Screen ',    46, 2, 8,  'Screen options/tools');
                  Menu.AddNone('X', ' Exit '     , 56, 2, 6,  'Exit/About options');
      
                  Res := Menu.Execute;
      
                  If Menu.WasHiExit Then
                    MenuPosition := Menu.ItemPos
                  Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'M' : MenuPosition := 1;
                      'T' : MenuPosition := 2;
                      'F' : MenuPosition := 3;
                      'O' : MenuPosition := 4;
                      'S' : MenuPosition := 5;
                      'X' : MenuPosition := 6;
                    End;
                End;
            1 : Begin
                  BoxOpen (2, 4, 20, 9);
                  CoolBoxOpen (1, 'Main Menu');
      
                  //Menu.AddNone ('N', ' Form/Input Test ', 3, 5, 17, 'Test form and input functions');
                  Menu.AddNone ('N', ' New'      , 3, 5, 17, 'Create new file...');
                  Menu.AddNone ('O', ' Open'      , 3, 6, 17, 'Open File');
                  Menu.AddNone ('S', ' Save'      , 3, 7, 17, 'Save File');
                  Menu.AddNone ('A', ' Save As'      , 3, 8, 17, 'Save File As Another Format');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 6;
                      #77 : MenuPosition := 2;
                    End;
                  End Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'S' : SaveFile(MainImage,Screen);
                      'N' : Begin
                              NewFile;
                              RestoreScreen := False;
                              Break;
                            End;
                      'O' : Begin
                              OpenFile;
                              RestoreScreen := False;
                              Break;
                            End;
                      'A' : SaveAsFile(MainImage,Screen);
                    Else
                      MenuPosition := 0;
                    End;
                End;
            2 : Begin
                  BoxOpen (15, 4, 30, 10);
                  CoolBoxOpen (14, 'Tools');
      
                  Menu.AddNone ('P', ' Pick Color '  , 16, 5, 14, '');
                  Menu.AddNone ('A', ' ASCII Table ' , 16, 6, 14, '');
                  Menu.AddNone ('S', ' Charset '     , 16, 7, 14, '');
                  Menu.AddNone ('D', ' Draw Mode '   , 16, 8, 14, '');
                  Menu.AddNone ('G', ' Global '      , 16, 9, 14, '');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 1;
                      #77 : MenuPosition := 3;
                    End;
                  End Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'S' : CurChar.SelCharSet := GetCharSetType(Screen);
                      'P' : CurChar.Color:=GetColor(Screen,Keyboard,CurChar.Color);
                      'A' : CurChar.Ch := Chr(GetChar(Screen, Keyboard));
                      'D' : DrawMode := GetDrawMode(Screen);
                      'G' : Begin
                              Global(MainImage);
                              Edit;
                            End;
                    Else
                      MenuPosition := 0;
                    End;
                End;
            3 : Begin
                  BoxOpen (25, 4, 45, 16);
                  CoolBoxOpen (24, 'Fonts');
      
                  Menu.AddNone ('N', ' Normal Font '        , 26, 5, 18, '');
                  Menu.AddNone ('E', ' Elite Mode '         , 26, 6, 18, '');
                  Menu.AddNone ('T', ' TheDraw Font '       , 26, 7, 18, '');
                  Menu.AddNone (' ', '     ------       '   , 26, 8, 18, '');
                  Menu.AddNone ('P', ' TDF Spacing '        , 26, 9, 18, '');
                  Menu.AddNone ('D', ' TheDraw Font Sel. '  , 26, 10, 18, '');
                  Menu.AddNone ('G', ' TheDraw Font Gal. '  , 26, 11, 18, '');
                  Menu.AddNone ('F', ' Edit Fade FX '       , 26, 12, 18, '');
                  Menu.AddNone ('X', ' Fade FX '            , 26, 13, 18, '');
                  Menu.AddNone ('C', ' Edit Case FX '       , 26, 14, 18, '');
                  Menu.AddNone ('S', ' Case FX '            , 26, 15, 18, '');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 2;
                      #77 : MenuPosition := 4;
                    End;
                  End Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'P' : Begin
                              If blockart_tdf.Font.A <> #19 Then Begin
                                ShowMsgBox(0,'No Font Selected!',Screen);
                                Break;
                              End;
                              Try
                                D := StrS2I(GetStr('Spacing','Enter Space:',StrI2S(Blockart_tdf.Font.Spacing),1,1));
                                Blockart_tdf.Font.Spacing := D;
                              Except
                                
                              End;
                            End;
                      'T' : Begin
                              If CurChar.TDF <> '' Then DrawMode := Draw_TDF
                                Else ShowMsgBox(0,'No Font Selected!',Screen);
                              Break;
                            End;
                      'G' : Begin
                              blockart_tdfgallery.FontFolder := DirSlash(Settings.Folder);
                              blockart_tdfgallery.Screen := Screen;
                              If FontGallery(CurChar.TDF)=True Then Begin
                                If not GetTDFHeader(CurChar.TDF) Then Begin
                                  CurChar.TDF := '';
                                  ShowMsgBox(0,'Font Loading Error',Screen);
                                End;
                              End;
                            End;
                      'D' : Begin
                              CurChar.TDF := GetUploadFileName(Screen,'TheDraw Font',Settings.Folder);
                              If CurChar.TDF = '' Then Begin
                                ShowMsgBox(0,'No Font Specified!',Screen);
                              End;
                              If not GetTDFHeader(CurChar.TDF) Then CurChar.TDF := '';
                              //DrawMode := Draw_TDF;
                            End;
                      'N' : Begin
                              DrawMode := Draw_Normal;
                              DrawFx   := 0;
                            End;
                      'E' : Begin
                              DrawMode := Draw_Elite;
                              DrawFx   := 0;
                            End;
                      'F' : EditFontFx(Screen);
                      'C' : EditCaseFx(Screen);
                      'X' : Begin
                              D := SelectFontFX;
                              If D <> 0 Then Begin 
                                CurChar.FontFxSel := D;
                                CurChar.FontFx := ReadSetting('FontFx',StrI2S(D));
                                CurChar.FontFxCnt := strWordCount(CurChar.FontFx,'|');
                                If CurChar.FontFxCnt > 0 Then Begin
                                  DrawFx := Draw_FontFx;
                                  CurChar.FontFxIdx := 1;
                                End;
                              End Else Begin
                                //ShowMsgBox(0,'No Selection.',Screen);
                              End;
                            End;
                      'S' : Begin
                                D := SelectCaseFX;
                                If D <> 0 Then Begin 
                                  CurChar.CaseFxSel := D;
                                  CurChar.CaseFxCap := ReadSetting('CaseFx'+StrI2S(D),'Capitals');
                                  CurChar.CaseFxLow := ReadSetting('CaseFx'+StrI2S(D),'Lowers');
                                  CurChar.CaseFxNum := ReadSetting('CaseFx'+StrI2S(D),'Numbers');
                                  CurChar.CaseFxSym := ReadSetting('CaseFx'+StrI2S(D),'Symbols');
                                  DrawFx := Draw_CaseFx;
                                End Else Begin
                                  //ShowMsgBox(0,'No Selection.',Screen);
                                End;
                              End;
                    Else
                      MenuPosition := 0;
                    End;
                End;
          4 : Begin
                  BoxOpen (35, 4, 53, 8);
                  CoolBoxOpen (34, 'Options');
                  Menu.AddNone ('S', ' Sauce '          , 36, 5, 16, '');
                  Menu.AddNone ('T', ' Tab '            , 36, 6, 16, '');
                  Menu.AddNone ('C', ' Save To Cursor ' , 36, 7, 16, '');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 3;
                      #77 : MenuPosition := 5;
                    End;
                  End Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'S' : EditSauce;
                      'T' : EditTabs;
                      'C' : Begin
                              If ShowMsgBox(1,'Save to Cursor Position?',Screen) Then
                                CurChar.SaveCur := True 
                              Else
                                CurChar.SaveCur := False;
                              blockart_save.SaveCur := CurChar.SaveCur;
                            End;
                    Else
                      MenuPosition := 0;
                    End;
                End;
          5 : Begin
                  BoxOpen (46, 4, 63, 17);
                  CoolBoxOpen (45, 'Screen');
      
                  Menu.AddNone ('C', ' Clear ', 47, 5, 14, '');
                  Menu.AddNone ('I', ' Insert Line ' , 47, 6, 15, '');
                  Menu.AddNone ('D', ' Delete Line ' , 47, 7, 15, '');
                  Menu.AddNone ('N', ' Insert Col. ' , 47, 8, 15, '');
                  Menu.AddNone ('E', ' Delete Col. ' , 47, 9, 15, '');
                  Menu.AddNone ('U', ' Undo '        , 47, 10, 15, '');
                  Menu.AddNone ('L', ' Move Left '   , 47, 11, 15, '');
                  Menu.AddNone ('R', ' Move Right '  , 47, 12, 15, '');
                  Menu.AddNone ('P', ' Move UP '     , 47, 13, 15, '');
                  Menu.AddNone ('W', ' Move DoWn '   , 47, 14, 15, '');
                  Menu.AddNone ('B', ' Block Cursor ', 47, 15, 15, '');
                  Menu.AddNone ('O', ' Underl.Cursor', 47, 16, 15, '');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 4;
                      #77 : MenuPosition := 6;
                    End;
                  end Else
                    Case Res of
                      'B' : CursorBlock;
                      'O' : HalfBlock;
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'C' : Begin
                              If ShowMsgBox(1,'All Data Will be Lost',Screen) Then Begin
                                ClearImage;
                                Edited:=False;
                              End;
                            End;
                      'I' : Begin
                              InsertLine(MainImage);
                              Edit;
                            End;
                      'D' : Begin
                              DeleteLine(MainImage);
                              Edit;
                            End;
                      'N' : Begin
                              InsertRow(MainImage);
                              Edit;
                            End;
                      'L' : Begin
                             StoreOldXY;
                             CurChar.OldX:=1;
                             CurChar.OldY:=1;
                             Screen.CursorXY(1,1);
                             DeleteRow(MainImage);
                             Edit;
                             ReStoreOldXY;
                            End;
                      'R' : Begin
                             StoreOldXY;
                             CurChar.OldX:=1;
                             CurChar.OldY:=1;
                             Screen.CursorXY(1,1);
                             InsertRow(MainImage);
                             Edit;
                             ReStoreOldXY;
                            End;
                  'p','P' : Begin
                             StoreOldXY;
                             CurChar.OldX:=1;
                             CurChar.OldY:=1;
                             Screen.CursorXY(1,1);
                             DeleteLine(MainImage);
                             Edit;
                             ReStoreOldXY;
                            End;
                   'w','W' : Begin
                             StoreOldXY;
                             CurChar.OldX:=1;
                             CurChar.OldY:=1;
                             Screen.CursorXY(1,1);
                             InsertLine(MainImage);
                             Edit;
                             ReStoreOldXY;
                            End;
                    Else
                      MenuPosition := 0;
                    End;
                End;
          6 : Begin
                  BoxOpen (56, 4, 64, 7);
                  CoolBoxOpen (55,'Exit');
      
                  Menu.AddNone ('A', ' About ', 57, 5, 7, 'About this test program');
                  Menu.AddNone ('X', ' Exit ' , 57, 6, 7, 'Exit this program');
      
                  Res := Menu.Execute;
      
                  BoxClose;
                  CoolBoxClose;
      
                  If Menu.WasHiExit Then Begin
                    Case Res of
                      #75 : MenuPosition := 5;
                      #77 : MenuPosition := 1;
                    End;
                  End Else
                    Case Res of
                      #27 : Begin
                              Menuposition:=0;
                              Break;
                            End;
                      'A' : AboutBox;
                      'X' : Begin
                              AppExit;
                              Halt;
                            End;
                    Else
                      MenuPosition := 0;
                    End;
                End;
          
          End;
          
          Until False;
          If RestoreScreen Then Begin
            Screen.PutScreenImage(MainImage);
            Screen.CursorXY(CurChar.OldX,CurChar.OldY);
          End;
        End;  
        
      End;
    End;
    
  Until False;

  Screen.ClearScreen;
  Menu.Free;
  Keyboard.free;
  Screen.Free;
  SaveSettings;
  DeleteUndoFiles;
End.
