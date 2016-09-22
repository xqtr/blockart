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

Unit AsciiDraw;

Interface

Uses Crt;

Function line2str(c:char):String;
Function str2line(buffer:String):char;
Function addlinestr(bottom,top:string):string;
Function addtopage(x,y:byte; ch_scr,ch:char):char;

Implementation

Function line2str(c:char):String;
Begin
Case C Of
  #179:
		line2str :=  'SNSN';
		
  #180:
		line2str :=  'SNSS';
		
  #191:
		line2str :=  'NNSS';
		
  #217:
		line2str :=  'SNNS';
		
  #192:
		line2str :=  'SSNN';
		
  #218:
		line2str :=  'NSSN';
		
  #193:
		line2str :=  'SSNS';
		
  #194:
		line2str :=  'NSSS';
		
  #195:
		line2str :=  'SSSN';
		
  #196:
		line2str :=  'NSNS';
		
  #197:
		line2str :=  'SSSS';
		
  #181:
		line2str :=  'SNSD';
		
  #184:
		line2str :=  'NNSD';
		
  #190:
		line2str :=  'SNND';
		
  #212:
		line2str :=  'SDNN';
		
  #213:
		line2str :=  'NDSN';
		
  #207:
		line2str :=  'SDND';
		
  #209:
		line2str :=  'NDSD';
		
  #198:
		line2str :=  'SDSN';
		
  #216:
		line2str :=  'SDSD';
		
  #182:
		line2str :=  'DNDS';
		
  #183:
		line2str :=  'NNDS';
		
  #189:
		line2str :=  'DNNS';
		
  #211:
		line2str :=  'DSNN';
		
  #214:
		line2str :=  'NSDN';
		
  #208:
		line2str :=  'DSNS';
		
  #210:
		line2str :=  'NSDS';
		
  #199:
		line2str :=  'DSDN';
		
  #215:
		line2str :=  'DSDS';
		
  #185:
		line2str :=  'DNDD';
		
  #186:
		line2str :=  'DNDN';
		
  #187:
		line2str :=  'NNDD';
		
  #188:
		line2str :=  'DNND';
		
  #200:
		line2str :=  'DDNN';
		
  #201:
		line2str :=  'NDDN';
		
  #202:
		line2str :=  'DDND';
		
  #203:
		line2str :=  'NDDD';
		
  #204:
		line2str :=  'DDDN';
		
  #205:
		line2str :=  'NDND';
		
  #206:
		line2str :=  'DDDD';
  Else line2str := '';
  End;
End;

Function str2line(buffer:String):Char;
Begin
	Case buffer[1] of
		'S':
		Case buffer[2] of
			'S':
			Case buffer[3] of
				'S':
				Case buffer[4] of
					'S':
					str2line := #197;
				'N':
					str2line := #195;
				end;
			'N':
				Case buffer[4] of
				'S':
					str2line := #193;
				'N':
					str2line := #192;
				end;
			end;
		'D':
			Case buffer[3] of
			'S':
				Case buffer[4] of
				'D':
					str2line := #216;
				'N':
					str2line := #198;
				end;
			'N':
				Case buffer[4] of
				'D':
					str2line := #207;
				'N':
					str2line := #212;
				end;
			end;
		'N':
			Case buffer[3] of
			'S':
				Case buffer[4] of
				'D':
					str2line := #181;
				'S':
					str2line := #180;
				'N':
					str2line := #179;
				end;
			'N':
				Case buffer[4] of
				'D':
					str2line := #190;
				'S':
					str2line := #217;
				end;
			end;
		end;
	'D':
		Case buffer[2] of
		'S':
			Case buffer[3] of
			'D':
				Case buffer[4] of
				'S':
					str2line := #215;
				'N':
					str2line := #199;
				end;
			'N':
				Case buffer[4] of
				'S':
					str2line := #208;
				'N':
					str2line := #211;
				end;
			end;
		'D':
			Case buffer[3] of
			'D':
				Case buffer[4] of
				'D':
					str2line := #206;
				'N':
					str2line := #204;
				end;
			'N':
				Case buffer[4] of
				'D':
					str2line := #202;
				'N':
					str2line := #200;
				end;
			end;
		'N':
			Case buffer[3] of
			'D':
				Case buffer[4] of
				'D':
					str2line := #185;
				'S':
					str2line := #182;
				'N':
					str2line := #186;
				end;
			'N':
				Case buffer[4] of
				'D':
					str2line := #188;
				'S':
					str2line := #189;
				end;
			end;
		end;
	'N':
		Case buffer[2] of
		'S':
			Case buffer[3] of
			'S':
				Case buffer[4] of
				'S':
					str2line := #194;
				'N':
					str2line := #218;
				end;
			'D':
				Case buffer[4] of
				'S':
					str2line := #210;
				'N':
					str2line := #214;
				end;
			'N':
				str2line := #196;
			end;
		'D':
			Case buffer[3] of
			'S':
				Case buffer[4] of
				'D':
					str2line := #209;
				'N':
					str2line := #213;
				end;
			'D':
				Case buffer[4] of
				'D':
					str2line := #203;
				'N':
					str2line := #201;
				end;
			'N':
				str2line := #205;
			end;
		'N':
			Case buffer[3] of
			'S':
				Case buffer[4] of
				'D':
					str2line := #184;
				'S':
					str2line := #191;
				end;
			'D':
				Case buffer[4] of
				'D':
					str2line := #187;
				'S':
					str2line := #183;
				end;
			end;
		end;
	end;
End;

Function addlinestr(bottom,top:string):string;
Var
  x : Integer;
  res :String;
Begin

	if (bottom = '') Then Begin
    addlinestr:= top;
    Exit;
  End;
		
	
	if (top = '') Then Begin
    addlinestr:= '';
    exit;
  End;
	
	
  for x:=1 to 4 do Begin
		if (top[x] <> 'N') Then
			res[x] := top[x]
		else
			res[x] := bottom[x];
	end;
  
	if ((res[2] <> res[4]) And (res[1] <> 'N') and (res[4] <> 'N')) Then
		if (top[4] <> 'N') then res[2] := top[1]
		else
			res[2] := top[4];
	
	if ((res[1] <> res[3]) And (res[1] <> 'N') and (res[3] <> 'N')) Then
		if (top[1] <> 'N') Then
			res[3] := top[1]
		else
			res[1] := top[3];
      
addlinestr:=res;      
	
end;

Function addtopage(x,y:byte; ch_scr,ch:char):char;
Var
	backbuff : String;
	topbuff: String;
	res : String;
Begin
  backbuff:= line2str(ch_scr);
	topbuff := line2str(ch);
	res     := addlinestr(backbuff, topbuff);
	addtopage := str2line(res);
End;

Begin


End.
