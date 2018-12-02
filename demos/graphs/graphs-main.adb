-----------------------------------------------------------------------
--  graphs -- Display graphs STM32 touch screen
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

with STM32.Board;
with HAL.Bitmap;

with UI.Displays;
with Graphs.Display.Instances;

--  The main Graphs task initializes the board and display and loops to wait
--  for a display timeout or user touch event.
procedure Graphs.Main is

   use type Ada.Real_Time.Time;
   use type Ada.Real_Time.Time_Span;

begin
   --  Initialize the display and draw the main/fixed frames in both buffers.
   UI.Displays.Initialize;
   UI.Displays.Push_Display (Graphs.Display.Instances.Display'Access);

   --  Loop to wait for events and refresh the display.
   loop
      declare
         Now     : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Buffer  : constant HAL.Bitmap.Any_Bitmap_Buffer := STM32.Board.Display.Hidden_Buffer (1);
         Display : UI.Displays.Display_Access := UI.Displays.Current_Display;
      begin
         Display.Process_Event (Buffer.all, Now);

         --  Refresh the display only when it needs.
         Display := UI.Displays.Current_Display;
         if Display.Need_Refresh (Now) then
            Display.Refresh (Buffer.all);
         end if;
         delay until Now + Ada.Real_Time.Milliseconds (10);
      end;
   end loop;

end Graphs.Main;
