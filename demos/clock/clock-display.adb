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

with HAL.Real_Time_Clock;
with STM32.RTC;
with STM32.Device;
with UI.Clocks;

package body Clock.Display is

   use Ada.Real_Time;

   --  ------------------------------
   --  Draw the layout presentation frame.
   --  ------------------------------
   overriding
   procedure On_Restore (Display : in out Display_Type;
                         Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class) is
      W : constant Natural := Buffer.Width;
      H : constant Natural := Buffer.Height;
   begin
      STM32.Device.RTC.Enable;

      --  Next button (right bar).
      Display.Next_Button.Pos := (W - 80, 0);
      Display.Next_Button.Width := 80;
      Display.Next_Button.Height := H;
      Display.Next_Button.Len := 3;

      --  Previous button (left bar).
      Display.Prev_Button.Pos := (0, 0);
      Display.Prev_Button.Width := 30;
      Display.Prev_Button.Height := H;
      Display.Prev_Button.Len := 3;

      --  Info button (middle of image).
      Display.Info_Button.Pos := ((W / 2) - 80, 0);
      Display.Info_Button.Width := 160;
      Display.Info_Button.Height := H;
      Display.Info_Button.Len := 3;
   end On_Restore;

   --  ------------------------------
   --  Refresh the current display.
   --  ------------------------------
   overriding
   procedure On_Refresh (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is
      pragma Unreferenced (Display);

      W : constant Natural := Buffer.Width;
      H : constant Natural := Buffer.Height;
      X : constant Natural := W / 2;
      Y : constant Natural := H / 2;
      R : constant Natural := Natural'Min (W / 2, H / 2) - 5;
      Now : constant HAL.Real_Time_Clock.RTC_Time := STM32.Device.RTC.Get_Time;
   begin
      UI.Clocks.Draw_Clock (Buffer, Center => (X, Y), Width => R);
      UI.Clocks.Draw_Clock_Tick (Buffer, (X, Y), R, Natural (Now.Hour),
                                 Natural (Now.Hour), Natural (Now.Sec), UI.Clocks.HOUR_HAND);
      UI.Clocks.Draw_Clock_Tick (Buffer, (X, Y), R, Natural (Now.Hour),
                                 Natural (Now.Min), Natural (Now.Sec), UI.Clocks.MINUTE_HAND);
      UI.Clocks.Draw_Clock_Tick (Buffer, (X, Y), R, Natural (Now.Hour),
                                 Natural (Now.Min), Natural (Now.Sec), UI.Clocks.SECOND_HAND);
      Deadline := Ada.Real_Time.Clock + DISPLAY_TIME;
   end On_Refresh;

   --  ------------------------------
   --  Handle refresh timeout event.
   --  ------------------------------
   overriding
   procedure On_Timeout (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is
   begin
      Display.Refresh (Buffer, UI.Displays.REFRESH_BOTH);
      Deadline := Ada.Real_Time.Clock + DISPLAY_TIME;
   end On_Timeout;

end Clock.Display;
