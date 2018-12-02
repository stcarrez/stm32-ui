-----------------------------------------------------------------------
--  clock-display -- Main display view manager for the clock
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
with Ada.Real_Time;

with UI.Buttons;
with UI.Displays;

--  The clock display manager displays a 12 hour clock.  The current time is taken from
--  the STM32 RTC device.
package Clock.Display is

   --  Display refresh period.
   DISPLAY_TIME : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1000);

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

   --  Handle refresh timeout event.
   overriding
   procedure On_Timeout (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time);

private

   type Display_Type is limited new UI.Displays.Display_Type with record
      Next_Button  : UI.Buttons.Button_Type;
      Prev_Button  : UI.Buttons.Button_Type;
      Info_Button  : UI.Buttons.Button_Type;
      Update       : Ada.Real_Time.Time;
      Print_Info   : Boolean := True;
   end record;

end Clock.Display;
