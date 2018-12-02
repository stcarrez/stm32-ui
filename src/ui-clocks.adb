-----------------------------------------------------------------------
--  ui-clocks -- Display a 12 hour clock
--  Copyright (C) 2018 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Bitmapped_Drawing;
with Bitmap_Color_Conversion;
with BMP_Fonts;
with UI.Texts;
with Cosin_Table;
package body UI.Clocks is

   use Bitmapped_Drawing;

   CLOCK_THICKNESS   : constant Natural := 5;
   TICK_OFFSET       : constant Natural := 10;
   TICK_LENGTH       : constant Natural := 5;
   TEXT_OFFSET       : constant Natural := TICK_OFFSET + TICK_LENGTH + 10;
   CLOCK_TICK_OFFSET : constant Natural := TEXT_OFFSET + 5;

   procedure Draw_Clock_Tick (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                              Center  : in HAL.Bitmap.Point;
                              Width   : in Natural;
                              Hour    : in Natural;
                              Minute  : in Natural;
                              Second  : in Natural;
                              Hand    : in Hand_Type) is
      Pos      : Natural := ((Hour mod 12) * 60) + Minute;
      Quadrant : Natural := Pos / 180;
      Radius   : Natural := Width - CLOCK_TICK_OFFSET;
      R_Sin    : Natural;
      R_Cos    : Natural;
      X, Y     : Natural;
      Thickness : Natural;
   begin
      case Hand is
         when HOUR_HAND =>
            Radius := Radius * 50 / 100;
            Pos := ((Hour mod 12) * 60) + Minute;
            Thickness := 5;

         when MINUTE_HAND =>
            Radius := Radius - 10;
            Pos := Minute * 12 + (Second * 12) / 60;
            Thickness := 2;

         when SECOND_HAND =>
            Radius := Radius;
            Pos := Second * 12;
            Thickness := 1;
      end case;

      Quadrant := Pos / 180;
      Pos := Pos mod 180;
      R_Sin := (Cosin_Table.Sin_Table (Pos) * Radius) / Cosin_Table.Factor;
      R_Cos := (Cosin_Table.Cos_Table (Pos) * Radius) / Cosin_Table.Factor;
      case Quadrant is
         when 0 =>
            X := Center.X + R_Sin;
            Y := Center.Y - R_Cos;

         when 1 =>
            X := Center.X + R_Cos;
            Y := Center.Y + R_Sin;

         when 2 =>
            X := Center.X - R_Sin;
            Y := Center.Y + R_Cos;

         when 3 =>
            X := Center.X - R_Cos;
            Y := Center.Y - R_Sin;

         when others =>
            return;
      end case;
      Buffer.Set_Source (UI.Texts.Foreground);
      Buffer.Draw_Line (Start => (Center.X, Center.Y),
                        Stop  => (X, Y),
                        Thickness => Thickness);
      if Hand /= SECOND_HAND then
         Buffer.Fill_Circle (Center => (X, Y), Radius => 1 + Thickness);
      end if;
   end Draw_Clock_Tick;

   --  ------------------------------
   --  Draw the 12 hour clock at the given center position and with the given width.
   --  ------------------------------
   procedure Draw_Clock (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Center  : in HAL.Bitmap.Point;
                         Width   : in Natural) is

      FG    : constant HAL.UInt32
        := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                         UI.Texts.Foreground);
      BG    : constant HAL.UInt32
        := Bitmap_Color_Conversion.Bitmap_Color_To_Word (Buffer.Color_Mode,
                                                         UI.Texts.Background);

      procedure Draw_Tick (Cos_Alpha : in Float;
                           Sin_Alpha : in Float) is
         PA, PB : HAL.Bitmap.Point;
      begin
         PA.X := Natural (Float (Width - TICK_OFFSET) * Cos_Alpha);
         PA.Y := Natural (Float (Width - TICK_OFFSET) * Sin_Alpha);
         PB.X := Natural (Float (Width - TICK_OFFSET - TICK_LENGTH) * Cos_Alpha);
         PB.Y := Natural (Float (Width - TICK_OFFSET - TICK_LENGTH) * Sin_Alpha);
         Buffer.Draw_Line (Start => (Center.X + PA.X, Center.Y + PA.Y),
                           Stop  => (Center.X + PB.X, Center.Y + PB.Y));
         Buffer.Draw_Line (Start => (Center.X - PA.X, Center.Y - PA.Y),
                           Stop  => (Center.X - PB.X, Center.Y - PB.Y));
         Buffer.Draw_Line (Start => (Center.X + PA.X, Center.Y - PA.Y),
                           Stop  => (Center.X + PB.X, Center.Y - PB.Y));
         Buffer.Draw_Line (Start => (Center.X - PA.X, Center.Y + PA.Y),
                           Stop  => (Center.X - PB.X, Center.Y + PB.Y));
      end Draw_Tick;

      procedure Draw_Text (Cos_Alpha : in Float;
                           Sin_Alpha : in Float;
                           C1        : in Character;
                           C2        : in Character;
                           Offset_X  : in Integer := 0;
                           Offset_Y  : in Integer := 0) is
         X, Y : Integer;
      begin
         Y := Integer (Float (Width - TEXT_OFFSET) * Sin_Alpha);
         X := Integer (Float (Width - TEXT_OFFSET) * Cos_Alpha);
         X := X + Offset_X;
         Y := Y + Offset_Y;
         Draw_Char (Buffer     => Buffer,
                    Start      => (Center.X + X, Center.Y + Y),
                    Char       => C1,
                    Font       => BMP_Fonts.Font8x8,
                    Foreground => FG,
                    Background => BG);
         if C2 /= ' ' then
            Draw_Char (Buffer     => Buffer,
                    Start      => (Center.X + X + 8, Center.Y + Y),
                    Char       => C2,
                    Font       => BMP_Fonts.Font8x8,
                    Foreground => FG,
                    Background => BG);
         end if;
      end Draw_Text;
   begin
      Buffer.Set_Source (UI.Texts.Foreground);
      Buffer.Fill_Circle (Center => Center, Radius => Width);
      Buffer.Set_Source (UI.Texts.Background);
      Buffer.Fill_Circle (Center => Center, Radius => Width - CLOCK_THICKNESS);
      Buffer.Set_Source (UI.Texts.Foreground);

      --  Draw the clock ticks.
      --  sin(30) = 0.5
      --  cos(30) = 0.866025
      Draw_Tick (0.0, 1.0);
      Draw_Tick (1.0, 0.0);
      Draw_Tick (0.866025, 0.5);
      Draw_Tick (0.5, 0.866025);

      --  Display the hours.
      Draw_Text (0.5, -0.866025, '1', ' ', -4, -6);
      Draw_Text (0.866025, -0.5, '2', ' ', 0, -6);
      Draw_Text (1.0, 0.0, '3', ' ', 0, -4);
      Draw_Text (0.866025, 0.5, '4', ' ', -2, -2);
      Draw_Text (0.5, 0.866025, '5', ' ', -2, -2);
      Draw_Text (0.0, 1.0, '6', ' ', -4, 0);
      Draw_Text (-0.5, 0.866025, '7', ' ', -4, 0);
      Draw_Text (-0.866025, 0.5, '8', ' ', -6, -2);
      Draw_Text (-1.0, 0.0, '9', ' ', -8, -4);
      Draw_Text (-0.5, -0.866025, '1', '1', -8, -4);
      Draw_Text (-0.866025, -0.5, '1', '0', -8, -4);
      Draw_Text (0.0, -1.0, '1', '2', -8, -8);
   end Draw_Clock;

end UI.Clocks;
