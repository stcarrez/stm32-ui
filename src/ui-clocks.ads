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
with HAL.Bitmap;
package UI.Clocks is

   type Hand_Type is (HOUR_HAND, MINUTE_HAND, SECOND_HAND);

   procedure Draw_Clock_Tick (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                              Center  : in HAL.Bitmap.Point;
                              Width   : in Natural;
                              Hour    : in Natural;
                              Minute  : in Natural;
                              Second  : in Natural;
                              Hand    : in Hand_Type);

   --  Draw the 12 hour clock at the given center position and with the given width.
   procedure Draw_Clock (Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Center  : in HAL.Bitmap.Point;
                         Width   : in Natural);

end UI.Clocks;
