-----------------------------------------------------------------------
--  ui-images -- Draw images
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
with HAL.Bitmap;
package UI.Images is

   type Color_Type is record
      Red   : HAL.UInt8;
      Green : HAL.UInt8;
      Blue  : HAL.UInt8;
   end record with Pack;

   --  Color palette definition.
   type Color_Array is array (Natural range <>) of Color_Type with Pack;
   type Color_Array_Access is access constant Color_Array;

   --  Raw image bitmap (GIF image blocks).
   type Bitmap_Array is array (Positive range <>) of HAL.UInt8;
   type Bitmap_Array_Access is access constant Bitmap_Array;

   --  GIF image description.
   type Image_Descriptor is record
      Width   : Natural;
      Height  : Natural;
      Palette : Color_Array_Access;
      Bitmap  : Bitmap_Array_Access;
   end record;

   --  Draw the image at the given position in the bitmap.
   procedure Draw_Image (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Start   : in HAL.Bitmap.Point;
                         Image   : in Image_Descriptor);

private

   type Display_mode is (fast, nice);

end UI.Images;
