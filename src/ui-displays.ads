-----------------------------------------------------------------------
--  ui-displays -- Display manager
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
with Ada.Real_Time;

with HAL.Bitmap;
with HAL.Touch_Panel;

--  == Display ==
--  The `Display_Type` is a tagged record that defines several operations to handle
--  the main display and its interaction with the user.
package UI.Displays is

   type Refresh_Mode is (REFRESH_CURRENT, REFRESH_BOTH);

   type Display_Buffer_Index is new Natural range 0 .. 1;

   type Display_Type is abstract tagged limited private;
   type Display_Access is not null access all Display_Type'Class;

   --  Get the index of current buffer visible on screen.
   function Current_Buffer_Index (Display : in Display_Type) return Display_Buffer_Index;

   --  Returns True if a refresh is needed.
   function Need_Refresh (Display : in Display_Type;
                          Now     : in Ada.Real_Time.Time) return Boolean;

   --  Process touch panel event if there is one.
   procedure Process_Event (Display : in out Display_Type;
                            Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                            Now     : in Ada.Real_Time.Time);

   procedure Refresh (Display  : in out Display_Type;
                      Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                      Mode     : in Refresh_Mode := REFRESH_CURRENT);

   procedure On_Pause (Display : in out Display_Type;
                       Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class) is null;

   procedure On_Restore (Display : in out Display_Type;
                         Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class) is null;

   --  Refresh the current display.
   procedure On_Refresh (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is null;

   --  Handle touch events on the display.
   procedure On_Touch (Display : in out Display_Type;
                       Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                       States  : in HAL.Touch_Panel.TP_State) is null;

   --  Handle refresh timeout event.
   procedure On_Timeout (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is null;

   procedure Initialize;

   --  Push a new display.
   procedure Push_Display (Display : in Display_Access);

   --  Pop the display to go back to the previous one.
   procedure Pop_Display;

   --  Get the current display.
   function Current_Display return Display_Access;

private

   type Display_Type is abstract tagged limited record
      Current_Buffer : Display_Buffer_Index := 0;
      Deadline       : Ada.Real_Time.Time;
      Refresh_Flag   : Boolean := True;
      Button_Changed : Boolean := True;
      Previous       : access Display_Type;
   end record;

end UI.Displays;
