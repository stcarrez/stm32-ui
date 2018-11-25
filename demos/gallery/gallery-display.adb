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
with UI.Texts;
package body Gallery.Display is

   use Ada.Real_Time;

   ONE_MS : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (1);

   --  ------------------------------
   --  Draw the layout presentation frame.
   --  ------------------------------
   overriding
   procedure On_Restore (Display : in out Display_Type;
                         Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class) is
      W : constant Natural := Buffer.Width;
      H : constant Natural := Buffer.Height;
   begin
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
   --  Handle touch events on the display.
   --  ------------------------------
   overriding
   procedure On_Touch (Display : in out Display_Type;
                       Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class;
                       States  : in HAL.Touch_Panel.TP_State) is
      X   : constant Natural := States (States'First).X;
      Y   : constant Natural := States (States'First).Y;
      Now : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
   begin
      if UI.Buttons.Contains (Display.Prev_Button, X, Y) then
         Display.Current := Previous (Display.Current);
         Display.Update := Now + DISPLAY_TIME;
         Display.Refresh (Buffer, UI.Displays.REFRESH_BOTH);

      elsif UI.Buttons.Contains (Display.Next_Button, X, Y) then
         Display.Current := Next (Display.Current);
         Display.Update := Now + DISPLAY_TIME;
         Display.Refresh (Buffer, UI.Displays.REFRESH_BOTH);

      elsif UI.Buttons.Contains (Display.Info_Button, X, Y) then
         Display.Print_Info := not Display.Print_Info;
         Display.Update := Now + DISPLAY_TIME;
         Display.Refresh (Buffer, UI.Displays.REFRESH_BOTH);

      end if;
   end On_Touch;

   --  ------------------------------
   --  Refresh the current display.
   --  ------------------------------
   overriding
   procedure On_Refresh (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is
      W     : constant Natural := Buffer.Width;
      H     : constant Natural := Buffer.Height;
      IW    : constant Natural := Images (Display.Current).Width;
      IH    : constant Natural := Images (Display.Current).Height;
      Y     : constant Natural := (H - IH) / 2;
      X     : constant Natural := (W - IW) / 2;
      Start : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Stop  : Ada.Real_Time.Time;
      N     : Natural;
   begin
      Buffer.Set_Source (HAL.Bitmap.Black);
      Buffer.Fill;

      UI.Images.Draw_Image (Buffer => Buffer,
                            Start  => (X, Y),
                            Image  => Images (Display.Current));
      Stop := Ada.Real_Time.Clock;
      Deadline := Stop + DISPLAY_TIME;
      if Display.Print_Info then
         N := (Stop - Start) / ONE_MS;

         UI.Texts.Draw_String (Buffer  => Buffer,
                               Start   => (0, 0),
                               Width   => 250,
                               Msg     => "Width" & Natural'Image (IW));

         UI.Texts.Draw_String (Buffer  => Buffer,
                               Start   => (0, 15),
                               Width   => 250,
                               Msg     => "Height" & Natural'Image (IH));

         UI.Texts.Draw_String (Buffer  => Buffer,
                               Start   => (0, 30),
                               Width   => 250,
                               Msg     => "Render" & Natural'Image (N) & " ms");
      end if;
   end On_Refresh;

   --  ------------------------------
   --  Handle refresh timeout event.
   --  ------------------------------
   overriding
   procedure On_Timeout (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is
   begin
      Display.Current := Next (Display.Current);
      Display.Refresh (Buffer, UI.Displays.REFRESH_BOTH);
      Deadline := Ada.Real_Time.Clock + DISPLAY_TIME;
   end On_Timeout;

end Gallery.Display;
