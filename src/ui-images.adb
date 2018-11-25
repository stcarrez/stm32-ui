-----------------------------------------------------------------------
--  ui -- User Interface Framework
--  Copyright (C) 2016 Stephane Carrez
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
--  with Ada.Text_IO;
with UI.Images.Decoding_GIF;
package body UI.Images is

   --  ------------------------------
   --  Draw the image at the given position in the bitmap.
   --  ------------------------------
   procedure Draw_Image (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Start   : in HAL.Bitmap.Point;
                         Image   : in Image_Descriptor) is
      use type HAL.UInt8;

      procedure Feedback (Percents : Natural) is null;

      Width  : constant Natural := Buffer.Width;
      Height : constant Natural := Buffer.Height;
      Cur_X, Cur_Y : Natural;

      procedure Set_X_Y (X, Y : Natural) is
      begin
         Cur_X := X;
         Cur_Y := Y;
      end Set_X_Y;

      procedure Put_Pixel (Red, Green, Blue : HAL.UInt8;
                           Alpha : HAL.UInt8) is
         Color : HAL.Bitmap.Bitmap_Color;
         X     : constant Integer := Start.X + Cur_X;
         Y     : constant Integer := Start.Y + Image.Height - Cur_Y;
      begin
         if Alpha > 0 and X >= 0 and X < Width and Y >= 0 and Y < Height then
            Color.Red := Red;
            Color.Green := Green;
            Color.Blue := Blue;
            Color.Alpha := Alpha;
            Buffer.Set_Source (Color);
            Buffer.Set_Pixel ((X, Y));
            --  Ada.Text_IO.Put_Line (Natural'Image (Cur_X) & "," & Natural'Image (Cur_Y)
            --                      & " -> [" & HAL.UInt8'Image (Red)
            --                      & ", " & HAL.UInt8'Image (Green)
            --                      & ", " & HAL.UInt8'Image (Blue)
            --                      & "] Alpha " & HAL.UInt8'Image (Alpha));
         end if;
         Cur_X := Cur_X + 1;
      end Put_Pixel;

      procedure Load_Image is
        new UI.Images.Decoding_GIF.Load (Primary_color_range => HAL.UInt8,
                                         Set_X_Y             => Set_X_Y,
                                         Put_Pixel           => Put_Pixel,
                                         Feedback            => Feedback,
                                         mode                => fast);

   begin
      Load_Image (Image);
   end Draw_Image;

end UI.Images;
