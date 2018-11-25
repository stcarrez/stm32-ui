-----------------------------------------------------------------------
--  gallery-display -- Main display view manager for the gallery
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
with HAL.Touch_Panel;
with Ada.Real_Time;

with UI.Buttons;
with UI.Displays;
with UI.Images;

private with Gallery.Picture1;
private with Gallery.Picture2;
private with Gallery.Picture3;
private with Gallery.Picture4;
private with Gallery.Picture5;
private with Gallery.Picture6;
private with Gallery.Picture7;
private with Gallery.Picture8;
private with Gallery.Picture9;

--  The gallery display manager has a private table of GIF image descriptors and a current
--  index which indicates the current GIF being displayed.
--
--  The `On_Restore` procedure is called first when the gallery display manager is installed
--  on the display.  It initializes the display manager with next and previous buttons.
--
--  The `On_Refresh` procedure is then call when the display must be refreshed.  It is called
--  by the `Refresh` procedure on the buffer to refresh.  The `On_Refresh` can be called
--  two times, once on the back plane display and a second time to make the two back plane
--  bitmaps identical.  The `On_Refresh` displays the current GIF image by using
--  `UI.Images.Draw_Image` procedure.
--
--  The `On_Touch` procedure handles the touch events and moves to the next or previous
--  image by updating the image index and calling `Refresh` as needed.
--
--  Last, the `On_Timeout` procedure is called when the DISPLAY_TIME timeout has ellapsed
--  to move to another image.
package Gallery.Display is

   DISPLAY_TIME : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Seconds (1);

   type Display_Type is limited new UI.Displays.Display_Type with private;

   --  Draw the layout presentation frame.
   overriding
   procedure On_Restore (Display : in out Display_Type;
                         Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class);

   --  Refresh the current display.
   overriding
   procedure On_Refresh (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time);

   --  Handle touch events on the display.
   overriding
   procedure On_Touch (Display : in out Display_Type;
                       Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                       States  : in HAL.Touch_Panel.TP_State);

   --  Handle refresh timeout event.
   overriding
   procedure On_Timeout (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time);

private

   type Image_Index is new Positive range 1 .. 9;
   type Image_Descriptor_Array is array (Image_Index) of UI.Images.Image_Descriptor;

   function Next (Value : in Image_Index) return Image_Index
     is ((if Value = Image_Index'Last then Image_Index'First else Value + 1));

   function Previous (Value : in Image_Index) return Image_Index
     is ((if Value = Image_Index'First then Image_Index'Last else Value - 1));

   Images : constant Image_Descriptor_Array
     := (Picture1.Descriptor, Picture2.Descriptor, Picture3.Descriptor,
         Picture4.Descriptor, Picture5.Descriptor, Picture6.Descriptor,
         Picture7.Descriptor, Picture8.Descriptor, Picture9.Descriptor);

   type Display_Type is limited new UI.Displays.Display_Type with record
      Next_Button  : UI.Buttons.Button_Type;
      Prev_Button  : UI.Buttons.Button_Type;
      Info_Button  : UI.Buttons.Button_Type;
      Current      : Image_Index := 1;
      Update       : Ada.Real_Time.Time;
      Print_Info   : Boolean := True;
   end record;

end Gallery.Display;
