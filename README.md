# blockart
                   ____  _            _        _         _   
                  | __ )| | ___   ___| | __   / \   _ __| |_ 
                  |  _ \| |/ _ \ / __| |/ /  / _ \ | '__| __|
                  | |_) | | (_) | (__|   <  / ___ \| |  | |_ 
                  |____/|_|\___/ \___|_|\_\/_/   \_\_|   \__|

                                                  Version 0.8 Beta
                                                  
_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                                  A b o u t

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

  Another ANSI Editor which i hope will cover some aspects, that other ANSI 
editors do not cover. It's written for the Linux Console / Terminal, but can be
crosscompiled to Windows. I don't know how well will work in Windows, but you
can try.

  BlockArt, does not support multiple pages or big screens. Its designed for 
ANSI graphics, for BBSes which normally use 79x24 chars/lines ANSI Screens.

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                                F e a t u r e s

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

- Load / Save ANSI and Mystic BBS Ansi Files
- Also save in Plain Text and Pascal format
- All available block commands (Move, Copy, Flip, Fill etc.) and more such as
  draw line, draw circle, draw 3D box.
- Supports TheDraw Fonts
- Built in TheDraw Font Gallery to easy choose a font. Also you can choose a 
  font by selecting it everywhere in your disk drive
- Normal text mode and also Elite mode, like in SyncDraw
- Draw ASCII lines with the Draw Mode. 
- Font Fxes, like Fade Fx and Capital Fx. You can Color text, as you type
- Special "Line Menu" for ordinary jobs in a line of text
- All normal stuff you find in other ANSI Editors
- Up to 20 Undo Stages
- Supports Loading / Importing graphics while in Copy Mode


_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                         K e y b o a r d  S h o r t c u t s

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

  The keyboard shortcuts are as much as possible compatible with TheDraw and
other ANSI Editors.

  ESC         : Brings the Menu in Front

  ALt - U     : Pick Color
  ALT - S     : Save File
  ALT - O     : Open a file
  ALT - Z     : Undo
  ALT - G     : Global / Screen Stuff (insert/delete lines etc.)
  ALT - L     : Line Stuff (center text, fill etc.)
  ALT - C     : Select CharSet
  ALT - A     : Select Color
  ALT - D     : Select Draw Mode (Normal, Line, Color)
  ALT - I     : Insert Empty Line
  ALt - Y     : Delete Line
  ALT - K     : Insert Empty Row
  ALT - H     : Delete Row
  ALT - P     : Make Cursor Block Size
  ALT - X     : Exit


_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                                  F o n t  F X 

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

  BlockArt supports font effects, as you type. You can automatically color your
text by selecting a type of these effects. To use them you have to do the 
following steps.

  1. Configure the FXes. Up to 10 schemes supported for each FX.
  2. Select your font mode.. Normal or Elite
  3. Select your FX. 
  4. Type ;)
  
  For the colors of the FXes you use Mystic BBS Pipe Color Codes. A list of 
available colors follows. Don't forget to include the pipe char. {|}

                 00 : Sets the current foreground to Black
                 01 : Sets the current foreground to Dark Blue
                 02 : Sets the current foreground to Dark Green
                 03 : Sets the current foreground to Dark Cyan
                 04 : Sets the current foreground to Dark Red
                 05 : Sets the current foreground to Dark Magenta
                 06 : Sets the current foreground to Brown
                 07 : Sets the current foreground to Grey
                 08 : Sets the current foreground to Dark Grey
                 09 : Sets the current foreground to Light Blue
                 10 : Sets the current foreground to Light Green
                 11 : Sets the current foreground to Light Cyan
                 12 : Sets the current foreground to Light Red
                 13 : Sets the current foreground to Light Magenta
                 14 : Sets the current foreground to Yellow
                 15 : Sets the current foreground to White

                 16 : Sets the current background to Black
                 17 : Sets the current background to Blue
                 18 : Sets the current background to Green
                 19 : Sets the current background to Cyan
                 20 : Sets the current background to Red
                 21 : Sets the current background to Magenta
                 22 : Sets the current background to Brown
                 23 : Sets the current background to Grey

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                      To  Do . . . / L i m i t a t i o n s

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

- For now the Sauce format is not fully suported. It can find Sauce Info, but
  not write. Will be added in the future.
- TheDraw Fonts are supported, but not 100%. It can read only one font from 
  each file, even if a .TDF file, has more than one fonts.
- I am planning to make a Template Gallery, to choose often used graphics.

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                                    B u g s

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

- Not quite a bug... The Cursor is not always visible and this is a big 
  drawback. This depends from the console / terminal app. I have included 
  commands to make the cursor as big as a block, but it not always work.


    Report bugs at xqtr.xqtr#gmail.com or in the fsxNet Network on BBSes


_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_

                                S o u r c e  C o d e

_,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,__,.-''~''-.,_    
    
  BlockArt will be Open Source project. The Source Code is written in FreePascal
and it will be posted sortly in my GitHub repo: https://github.com/xqtr

  The Library which is based on, was under a GPL3 License so the same applies
for BlockArt Source Code.

  BlockArt is based in g00r00s (Mystic BBS) library which was released under
GPL3 License. 

