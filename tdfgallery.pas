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

Procedure DrawGallery;
{ TheDraw Pascal Crunched Screen Image.  Date: 09/21/16 }
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=1057;
  IMAGEDATA : array [1..1057] of Char = (
     #8,#16,#26, #3,'�', #7,'�','�',#15,'�','�',' ', #8,'�','�','�', #7,
    '�','�',#15,'�','�',' ', #8,'�','�', #7,'�','�',#15,'�','�',' ', #8,
    '�','�', #7,'�','�','�',' ', #8,'�','�', #7,'�',#15,'�',' ', #8,'�',
     #7,'�','�','�',#15,'�','�',' ','�', #7,'�', #8,'�',' ',#15,'�', #7,
    '�', #8,'�','�',' ',#15,'�', #7,'�','�', #8,'�','�',' ',#15,'�','�',
     #7,'�','�', #8,'�','�',' ',#15,'�','�', #7,'�','�', #8,'�','�','�',
    ' ',#15,'�','�', #7,'�','�','�', #8,'�','�',#24,#26, #6,'�',#23,'�',
    '�','�',' ','�',' ', #7,#16,'�','�',#23,' ',#15,'�',' ','�','�',#16,
    #26, #5,'�',' ', #8,#23,'�',#26,#23,'�',#15,'�',#16,' ',#26, #5,'�',
    #23,'�','�',' ',' ','�',#25, #2, #8,'�',' ','�','�','�',#16,#26, #5,
    '�',#24,#26, #6,'�',#23,'�','�','�','�',' ','�', #7,#16,'�','�',#15,
    #23,'�',' ','�',' ','�','�',#16,#26, #4,'�',' ', #8,#23,'�',' ',' ',
     #0,'T',' ','D',' ','F',' ',' ','G',' ','A',' ','L',' ','L',' ','E',
    ' ','R',' ','Y', #7,#16,'�',#23,' ',#15,'�',#16,' ',#26, #4,'�',#23,
    '�','�',' ',' ','�',' ', #7,#16,'�','�', #8,#23,'�',' ','�',' ','�',
    '�','�',#16,#26, #4,'�',#24,#26, #7,'�',#23,'�','�', #7,#16,'�', #8,
    #23,'�', #7,#16,'�','�',#23,' ',' ',#15,'�',' ','�','�','�',#16,#26,
     #4,'�',' ', #8,#23,'�',#15,#26,#23,'�','�',#16,' ',#26, #5,'�',#23,
    '�','�','�',' ','�',' ',' ', #8,'�',' ','�','�','�','�','�','�',#16,
    #26, #3,'�',#24,'�','�','�', #7,'�','�','�',#15,'�','�',' ', #8,'�',
    '�','�', #7,'�','�',#15,'�','�',' ', #8,'�','�', #7,'�','�',#15,'�',
    '�',' ', #8,'�','�', #7,'�','�',#15,'�',' ', #8,'�','�', #7,'�',#15,
    '�',' ', #8,'�', #7,'�',#15,'�',' ','�','�',' ','�', #7,'�', #8,'�',
    ' ',#15,'�', #7,'�', #8,'�','�',' ',#15,'�', #7,'�','�', #8,'�','�',
    ' ',#15,'�','�', #7,'�','�', #8,'�','�',' ',#15,'�','�', #7,'�','�',
     #8,'�','�','�',' ',#15,'�','�', #7,'�','�','�', #8,'�','�',#24,#15,
    '�','�',' ', #7,'�','�',' ', #8,'�',#25,#12,'�',' ', #7,'�','�','�',
    ' ', #8,'�',#25,',','�',' ', #7,'�','�',' ',#15,'�','�',#24,'�', #7,
    '�', #8,#23,'�', #7,#16,'�', #8,'�','�',#25,#13,'�',' ',#23,'�',#15,
    #16,'�', #7,'�',' ', #8,'�',#25,'-','�','�', #7,'�', #8,#23,'�', #7,
    #16,'�',#15,'�',#24, #8,#23,'�', #7,#16,'�', #8,'�','�',#25,#15,'�',
    ' ', #7,'�',#15,#23,'�', #8,'�',#16,' ','�',#25,'/','�','�', #7,'�',
     #8,#23,'�',#24,#16,'�','�','�','�',#25,#15,'�',' ', #7,'�',#15,#23,
    '�', #7,#16,'�',' ', #8,'�',#25,'/','�','�','�','�',#24, #7,'�', #8,
    #23,'�','�',#16,'�',#25,#15,'�',' ',#23,'�',#15,'�',' ',#16,' ', #8,
    '�',#25,'/','�',#23,'�','�', #7,#16,'�',#24,#15,#23,'�', #8,'�','�',
    #16,'�',#25,#15,'�',' ',#23,' ',#15,'�', #8,'�',#16,' ','�',#25,'/',
    '�',#23,'�','�',#15,'�',#24,'�', #8,'�','�',#16,'�',#25,#15,'�',' ',
     #7,'�', #0,#23,'�', #7,#16,'�',' ', #8,'�',#25,'/','�',#23,'�','�',
    #15,'�',#24,'�', #8,'�','�',#16,'�',#25,#15,'�',' ', #7,'�', #0,#23,
    '�', #8,'�',#16,' ','�',#25,'/','�',#23,'�','�',#15,'�',#24,'�', #8,
    '�','�',#16,'�',#25,#15,'�',' ',#23,'�', #0,'�',' ',#16,' ', #8,'�',
    #25,'/','�',#23,'�','�',#15,'�',#24,'�', #8,'�','�',#16,'�',#25,#15,
    '�',' ',#23,' ', #0,'�', #8,'�',#16,' ','�',#25,'/','�',#23,'�','�',
    #15,'�',#24,'�', #8,'�','�',#16,'�',#25,#15,'�',' ',#23,'�', #7,#16,
    '�','�',' ', #8,'�',#25,'/','�',#23,'�','�',#15,'�',#24,'�', #8,'�',
    '�',#16,'�',#25,#15,'�',' ', #7,'�', #0,#23,'�', #7,#16,'�',' ', #8,
    '�',#25,'/','�',#23,'�','�',#15,'�',#24,'�', #8,'�','�',#16,'�',#25,
    #15,'�',' ',#23,'�', #0,'�', #8,'�',#16,' ','�',#25,'/','�',#23,'�',
    '�',#15,'�',#24,'�', #8,'�','�',#16,'�',#25,#15,'�',' ',#23,'�', #0,
    '�', #8,'�',#16,' ','�',#25,'/','�',#23,'�','�',#15,'�',#24, #7,#16,
    '�', #8,#23,'�','�',#16,'�',#25,#15,'�',' ', #7,'�', #0,#23,'�', #7,
    #16,'�',' ', #8,'�',#25,'/','�',#23,'�','�', #7,#16,'�',#24, #8,'�',
    '�','�','�',#25,#15,'�',' ',#23,'�', #7,#16,'�','�',' ', #8,'�',#25,
    '/','�','�','�','�',#24,#23,'�', #7,#16,'�', #8,'�','�',#25,#15,'�',
    ' ',#23,' ', #0,'�', #8,'�',#16,' ','�',#25,'/','�','�', #7,'�', #8,
    #23,'�',#24,#15,#16,'�', #7,'�', #8,#23,'�', #7,#16,'�', #8,'�','�',
    #25,#13,'�',' ',#23,'�', #0,'�',' ',#16,' ', #8,'�',#25,'-','�','�',
     #7,'�', #8,#23,'�', #7,#16,'�',#15,'�',#24,'�','�',' ', #7,'�','�',
    ' ', #8,'�',#25,#12,'�',' ', #7,'�', #0,#23,'�', #8,'�',#16,' ','�',
    #25,#22, #7,'P','r','e','s','s',' ','C','T','R','L','-','Z',' ','F',
    'o','r',' ','H','e','l','p',' ', #8,'�',' ', #7,'�','�',' ',#15,'�',
    '�',#24,#24);
Begin
  Screen.LoadScreenImage(ImageData, ImageData_Length, ImageData_Width, 1, 1);    
End;  
