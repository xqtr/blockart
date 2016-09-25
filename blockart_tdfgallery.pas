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

Unit blockart_tdfgallery;

{$I M_OPS.PAS}

Interface

Uses
  DOS,
  m_strings,
  m_output,
  blockart_tdf,
  m_fileio;
  
Var
    Screen      : TOutput;
    FontFolder  : String;

Function FontGallery(Var Fnt:String):Boolean;

Implementation

Uses  
    m_types,
    m_Input,
    blockart_dialogs;

const
	max_items = 200;
	const searchx = 9;
	const searchy = 24;
	const searchcol = '|15';
	
	list_left = 4;
	list_top = 8;
	list_width = 15;
	list_on = '|15|17';
	list_off = '|07';
	list_max = 15;

	morex = 7;
	morey = 23;

	HeaderOffset = 233;
	fx = 28;
	fy = 8;
	fstr = 'adb';
	
	cx = 28;
	cy = 8;
	cwidth = 47;
	cheight = 13;
	cch = ' ';
  
var
	
  font 			: TTDFont;
  Datapath 		: string;
  FontFile		: String;
	
  filename:string;
  ListFile     : File;
  OutFile      : File;
  OutName      : String;
  tmpfile		: string;
  buffer		: byte;
 basedir : string;
 Totalitems:byte;
 Temp      :byte;
 Temp2     :byte ; 
 dirdepth  :array[1..10] of String;
 dirindex   : byte;
 item      :array[1..max_items] of String;
 Idx       :Array[1..max_items] of byte;
 TopPage   :byte;
 BarPos    :byte;
 Done      : Boolean;
 Ch         :Char;
 Ch2        :Char;
 More      :byte;
 LastMore  :byte;
 CurDir    :string;
 ti        :integer;
 kk        :char;

 search   :string;
 search_idx:integer;
 ii : integer;
 
{$I tdfgallery.pas} 
  
Procedure ClearArea;
var o:byte;
Begin
  for o:=1 to cheight do begin
    Screen.WriteXY(cx,cy+o,7,strrep(cch,cwidth));
  end;
end;

Procedure BarON;
Var
  Str : String;
begin
  Str := list_on+' ' + StrPadL(strStripMCI(item[BarPos]), list_width, ' ') + '|16';  
  Screen.WriteXYPipe(list_left, list_top + BarPos - TopPage,7,strMCILen(Str),Str);
end;

Procedure BarOFF;
Var
  Str : String;
begin
  Str := list_off+' ' + StrPadL(item[BarPos], list_width, ' ');
  Screen.WriteXYPipe(list_left, list_top + BarPos - TopPage,7,strMCILen(Str),Str);
end;

procedure clearitems;
  var i:integer;
begin
    for i:=1 to max_items do item[i]:='';
    TopPage  := 1;
	BarPos   := 1;
	Done     := False;
	More     := 0;
	LastMore := 0;
end;

Procedure DrawPage;
begin
  Temp2 := BarPos;
  For Temp := 0 to (list_max-1) do begin 
    BarPos := TopPage + Temp;
    BarOFF;
  end;
  BarPos := Temp2;
  BarON;
end;

Procedure fuckSort;
Var
	i, j:integer;
   temp1 : string;
Begin
	for j:=1 to totalitems do
	For i := 2 to totalitems do begin
	  if item[i-1]>item[i] then begin
	    temp1:=item[i-1];
	    item[i-1]:=item[i];
	    item[i]:=temp1;
	  end;
	  
	end;
End;

procedure getfiles(dirt:String);
var
  i:integer;
  Dir : SearchRec;
  dd : String;
begin
  i:=0;
  //item[1]:='..'
  dd := DirSlash(dirt);
  FindFirst(dd+'*.tdf',archive,Dir);
    While DosError = 0 do begin
      if (dir.name<>'.') and (dir.name<>'..') then begin
        if i<=max_items then begin
					i:=i+1;
					item[i]:=Dir.Name;
				end;
      end;
    FindNext(dir);
    end;
  FindClose(dir);
	totalitems:=i;
end;

procedure getnewdir(s:string);
  var i:byte;
begin
  dirindex:=dirindex+1;
  dirdepth[dirindex]:=s;
  curdir:='';
  for i:=1 to dirindex do curdir:=DirSlash(curdir+dirdepth[i]);
  curdir:=DirSlash(basedir+curdir);
end;

procedure getpredir;
var i:byte;
begin
  dirindex:=dirindex-1;
  dirdepth[dirindex+1]:='';
  curdir:='';
  for i:=1 to dirindex do curdir:=curdir+dirdepth[i];
  curdir:=DirSlash(basedir+curdir);
end;


Function FontGallery(Var Fnt:String):Boolean;
Var
  Keyboard : TInput;
  
  procedure getdir(dirt:string);
var
  i:integer;
  Dir : SearchRec;
begin
i:=0;
dirt := DirSlash(Dirt);
//item[1]:='..'
FindFirst (dirt+'*',Directory,Dir);
                        While DosError = 0 do begin
                                if direxists(dirt+dir.name) then
									if (dir.name<>'.') and (dir.name<>'..') then begin
									if i<=max_items then begin
										i:=i+1;
										item[i]:=Dir.Name;
									end;
                                end;
                            FindNext(dir);
                        end;
                FindClose(dir);
  totalitems:=i;
  fucksort;
end;

Procedure UpdateFont;
Begin
  if fileexist(DirSlash(curdir)+item[barpos]) then begin
    cleararea;
    Screen.WriteXYPipe(fx,fy,7,StrMCILen('|15'+item[barpos]), '|15'+item[barpos]);
    gettdfheader(curdir+item[barpos]);
    font.spacing:=1;
    TDFWriteStr(fx,fy+1,fstr);
  end;
End;

Procedure DrawGalleryHelp;
Begin
  DrawGallery;
  ClearArea;
  Screen.WriteXYPipe(32,10,7,30,'|15ESC    |07:|08: |07Go Back / Exit');
  Screen.WriteXYPipe(32,11,7,30,'|15ENTER  |07:|08: |07Select Font');
  Screen.WriteXYPipe(32,12,7,30,'|15Up     |07:|08: |07Go Up');
  Screen.WriteXYPipe(32,13,7,30,'|15Down   |07:|08: |07Go Down');
  Screen.WriteXYPipe(32,14,7,30,'|15HOME   |07:|08: |07Go First');
  Screen.WriteXYPipe(32,15,7,30,'|15END    |07:|08: |07Go Last');
  Screen.WriteXYPipe(32,16,7,30,'|15CTRL-E |07:|08: |07Refresh BG');
  Screen.WriteXYPipe(32,17,7,30,'|15CTRL-A |07:|08: |07Search Again');
  Screen.WriteXYPipe(32,18,7,30,'|15CTRL-Y |07:|08: |07Clear Search');
End;

  
  
Begin
  Screen.ClearScreen;
  Keyboard  := Tinput.Create;
  Result    := False;
  BaseDir   := DirSlash(FontFolder);
  CurDir    := BaseDir;
  DrawGallery;
  
  for ti:=1 to 10 do dirdepth[ti]:='';
  dirindex:=0;
  getnewdir('fonts');

  clearitems;
  getdir(CurDir);

  If Totalitems = 0 Then begin
    Result := False;
    ShowMsgBox(0,'No Fonts Found!',Screen);
    Exit;
  End;

  TopPage  := 1;
  BarPos   := 1;
  Done     := False;
  More     := 0;
  LastMore := 0;

  search:='';
  search_idx:=0;

  DrawPage;

Repeat
  More := 0;
  Ch   := ' ';
  Ch2  := ' ';

  If TopPage > 1 Then begin
    More := 1;
    Ch   := Chr(244);
  End;

  If TopPage + (list_max-1) < Totalitems Then begin
    Ch2  := Chr(245);
    More := More + 2;
  End;

  If More <> LastMore Then begin
    LastMore := More;
    Screen.WriteXYPipe(morex,morey,7,StrMCILen(' |08(|07' + Ch + Ch2 + ' |15m|07ore|08) '),' |08(|07' + Ch + Ch2 + ' |15m|07ore|08) ' );
  End;

  Case Keyboard.ReadKey Of
    #00 : Case Keyboard.ReadKey Of
          keyF1 : If FileExist(CurDir + Item[BarPos]) Then FileCopy(CurDir + Item[BarPos],FontFolder+'fonts'+pathsep+'rate1'+pathsep+Item[BarPos]);
          keyF2 : If FileExist(CurDir + Item[BarPos]) Then FileCopy(CurDir + Item[BarPos],FontFolder+'fonts'+pathsep+'rate2'+pathsep+Item[BarPos]);
          keyF3 : If FileExist(CurDir + Item[BarPos]) Then FileCopy(CurDir + Item[BarPos],FontFolder+'fonts'+pathsep+'rate3'+pathsep+Item[BarPos]);
          keyF4 : If FileExist(CurDir + Item[BarPos]) Then FileCopy(CurDir + Item[BarPos],FontFolder+'fonts'+pathsep+'rate4'+pathsep+Item[BarPos]);
          keyF5 : If FileExist(CurDir + Item[BarPos]) Then FileCopy(CurDir + Item[BarPos],FontFolder+'fonts'+pathsep+'rate5'+pathsep+Item[BarPos]);
            #45: Done := True;
            #71 : Begin //home
                    search_idx:=1;
                    TopPage := 1;
                    BarPos  := 1;
                    drawpage;
                    UpdateFont;
                  End;
            #79 : Begin
                    search_idx:=1;
                    if Totalitems > list_max then begin
                      TopPage := Totalitems - (list_max-1);
                      BarPos  := Totalitems;
                    end else begin
                      BarPos  := Totalitems;
                    end;
                    drawpage;
                    UpdateFont;
                  End;
            #72 : Begin
                    search_idx:=1;
                    If BarPos > TopPage Then begin
                      BarOFF;
                      BarPos := BarPos - 1;
                      BarON;
                      end
                    Else
                    If TopPage > 1 Then begin
                      TopPage := TopPage - 1;
                      BarPos  := BarPos  - 1;
                      DrawPage;
                    End;
                    UpdateFont;
                  End;
            #73 : Begin
                    search_idx:=1;
                    If TopPage - list_max > 0 Then begin
                      TopPage := TopPage - list_max;
                      BarPos  := BarPos  - list_max;
                      DrawPage;
                      end
                    Else begin
                      TopPage := 1;
                      BarPos  := 1;
                      DrawPage;
                    End;
                  End;
            #80 : Begin
                    search_idx:=1;
                    If BarPos < Totalitems Then
                      If BarPos < TopPage + (list_max-1) Then begin
                        BarOFF;
                        BarPos := BarPos + 1;
                        BarON;
                        end
                      Else
                      If BarPos < Totalitems Then begin
                        TopPage := TopPage + 1;
                        BarPos  := BarPos  + 1;
                        DrawPage;
                      End;
                      UpdateFont;
                  End;
            #81 : Begin
                    search_idx:=1;
                    If Totalitems > list_max Then
                      If TopPage + list_max < Totalitems - list_max Then begin
                        TopPage := TopPage + list_max;
                        BarPos  := BarPos  + list_max;
                        DrawPage;
                        end
                      Else
                      begin
                        TopPage := Totalitems - (list_max-1);
                        BarPos  := Totalitems;
                        DrawPage;
                      End
                    Else
                    begin
                      BarOFF;
                      BarPos := Totalitems;
                      BarON;
                    End;
                  End; 
          End;
    #26 : Begin
            DrawGalleryHelp;
            Keyboard.ReadKey;
            DrawGallery;
            DrawPage;
          End;
    #4  : Begin
            if fileexist(curdir+item[barpos]) then begin
            //DOwnload File
            End;
          End;
    #5  : Begin
            DrawGallery;
            DrawPage;
          End;
    #13 : Begin
          search:='';
          search_idx:=0;
          if direxists(DirSlash(curdir)+item[barpos]) then begin
                getnewdir(item[barpos]);
                clearitems;
                getdir(curdir);
                getfiles(curdir);
                DrawGallery;
                DrawPage;
          end else Begin
            Fnt := CurDir + Item[BarPos];
            Result := True;
            Done := True;
            Break;
          End;
          End;
    #27 : Begin
            //if curdir = BaseDir then Done := True;
            If DirIndex = 1 Then Begin
              Result := False;
              Fnt := '';
              Done := True;
              Break;
            End;
            if dirindex>=1 then begin
              getpredir;
              clearitems;
              getdir(curdir);
              search:='';
              search_idx:=0;
              DrawGallery;
              DrawPage;
            end;
          End;
  #1  : Begin
            for ii:=search_idx+1 to max_items do begin
              if pos(search,StrUpper(item[ii]))>0 then begin
                TopPage := ii;
                BarPos  := ii;
                search_idx:=ii;
                DrawPage;
                break;
              end;
            end;
          End;
  #25 : Begin
            Screen.WriteXY(searchx,searchy,7,strrep(' ',length(search)));
            search:='';
            search_idx:=0;
          End;
    #32..#128 : Begin
            search:=search+StrUpper(ch);
            Screen.WriteXYPipe(searchx,searchy,7,StrMCILen(searchcol+StrUpper(search)),searchcol+StrUpper(search));
            for ii:=1 to max_items do begin
              if pos(search,StrUpper(item[ii]))>0 then begin
                TopPage := ii;
                      BarPos  := ii;
                      search_idx:=ii;
                      DrawPage;
                      break;
              end;
            end	;
          End;
  End;
  
  Until Done;
Keyboard.Free;
Screen.CursorXY (1, 23);
End;


Begin


End.
