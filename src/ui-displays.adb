-----------------------------------------------------------------------
--  ui-displays -- Utilities to draw text strings
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

with STM32.Board;

package body UI.Displays is

   use type Ada.Real_Time.Time;

   --  ------------------------------
   --  Initialize the display.
   --  ------------------------------
   procedure Initialize is
   begin
      STM32.Board.Display.Initialize;
      STM32.Board.Display.Initialize_Layer (1, HAL.Bitmap.ARGB_1555);

      --  Initialize touch panel
      STM32.Board.Touch_Panel.Initialize;
   end Initialize;

   --  Get the index of current buffer visible on screen.
   function Current_Buffer_Index (Display : in Display_Type) return Display_Buffer_Index
     is (Display.Current_Buffer);

   --  ------------------------------
   --  Returns True if a refresh is needed.
   --  ------------------------------
   function Need_Refresh (Display : in Display_Type;
                          Now     : in Ada.Real_Time.Time) return Boolean is
   begin
      return Display.Deadline < Now or Display.Refresh_Flag;
   end Need_Refresh;

   --  ------------------------------
   --  Process touch panel event if there is one.
   --  ------------------------------
   procedure Process_Event (Display : in out Display_Type;
                            Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                            Now     : in Ada.Real_Time.Time) is
      State : constant HAL.Touch_Panel.TP_State := STM32.Board.Touch_Panel.Get_All_Touch_Points;
   begin
      Display.Refresh_Flag := False;

      if State'Length > 0 then
         Display_Type'Class (Display).On_Touch (Buffer, State);
      end if;

      if Display.Deadline < Now then
         Display_Type'Class (Display).On_Timeout (Buffer, Display.Deadline);
      end if;
   end Process_Event;

   Top_Display : access Display_Type'Class;

   procedure Refresh (Display : in out Display_Type;
                      Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                      Mode    : in Refresh_Mode := REFRESH_CURRENT) is
   begin
      Display_Type'Class (Display).On_Refresh (Buffer, Display.Deadline);
      Display.Refresh_Flag := False;
      STM32.Board.Display.Update_Layer (1);
      Display.Current_Buffer := (if Display.Current_Buffer = 1 then 0 else 1);
      if Mode = REFRESH_BOTH then
         Display.Refresh (STM32.Board.Display.Hidden_Buffer (1).all, REFRESH_CURRENT);
      end if;
   end Refresh;

   --  ------------------------------
   --  Restore and refresh the two buffers.
   --  ------------------------------
   procedure Restore (Display : in Display_Access) is
      Buffer  : HAL.Bitmap.Any_Bitmap_Buffer;
   begin
      for I in 1 .. 2 loop
         Buffer := STM32.Board.Display.Hidden_Buffer (1);
         Display.On_Restore (Buffer.all);
         Display.Refresh (Buffer.all);
      end loop;
   end Restore;

   --  ------------------------------
   --  Push a new display.
   --  ------------------------------
   procedure Push_Display (Display : in Display_Access) is
      Buffer  : constant HAL.Bitmap.Any_Bitmap_Buffer := STM32.Board.Display.Hidden_Buffer (1);
   begin
      if Top_Display /= null then
         Top_Display.On_Pause (Buffer.all);
      end if;
      Display.Previous := Top_Display;
      Top_Display := Display;
      Restore (Display);
   end Push_Display;

   --  ------------------------------
   --  Pop the display to go back to the previous one.
   --  ------------------------------
   procedure Pop_Display is
      Buffer  : constant HAL.Bitmap.Any_Bitmap_Buffer := STM32.Board.Display.Hidden_Buffer (1);
   begin
      if Top_Display /= null then
         Top_Display.On_Pause (Buffer.all);
      end if;
      if Top_Display.Previous /= null then
         Top_Display := Top_Display.Previous;
      end if;
      Restore (Top_Display.all'Access);
   end Pop_Display;

   --  ------------------------------
   --  Get the current display.
   --  ------------------------------
   function Current_Display return Display_Access is
   begin
      return Top_Display.all'Access;
   end Current_Display;

end UI.Displays;
