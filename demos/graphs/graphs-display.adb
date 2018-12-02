-----------------------------------------------------------------------
--  graphs-display -- Main display view manager for the graphs
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

package body Graphs.Display is

   use Ada.Real_Time;

   task body Idle_Task is
      Deadline : Ada.Real_Time.Time;
      Max      : Natural := 0;
      Value    : Natural;
   begin
      Int_Graph.Initialize (Graph_Data, GRAPH_RATE);

      loop
         --  We have up to the deadline to increment the counter to compute the idle time.
         Deadline := Int_Graph.Get_Deadline (Graph_Data);
         Value := 0;
         while Ada.Real_Time.Clock < Deadline loop
            Value := Value + 1;
         end loop;

         if Value > Max then
            Max := Value;
         end if;

         --  Convert the counter into a percentage over the max value we have found.
         Value := 100 - ((100 * Value) / Max);

         --  Add the new sample.
         Int_Graph.Add_Sample (Graph_Data, Graph_Value_Type (Value), Ada.Real_Time.Clock);
      end loop;
   end Idle_Task;

   --  ------------------------------
   --  Draw the layout presentation frame.
   --  ------------------------------
   overriding
   procedure On_Restore (Display : in out Display_Type;
                         Buffer  : in out HAL.Bitmap.Bitmap_Buffer'Class) is
      W : constant Natural := Buffer.Width;
      H : constant Natural := Buffer.Height;
      TMARGIN : constant Natural := 10;
      LMARGIN : constant Natural := 40;
      RMARGIN : constant Natural := 10;
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

      Buffer.Set_Source (HAL.Bitmap.Green);
      Buffer.Draw_Rect (Area => (Position => (LMARGIN - 1, TMARGIN - 1),
                                 Width  => W - LMARGIN - RMARGIN + 2,
                                 Height => H - TMARGIN - TMARGIN + 2));
      Int_Graph.Initialize (Display.Graph, LMARGIN, TMARGIN, W - LMARGIN - RMARGIN,
                            H - TMARGIN - TMARGIN);

      --  Disable auto scaling: use a fixed scale.
      Int_Graph.Set_Range (Display.Graph, 0, 100);

      UI.Texts.Draw_String (Buffer  => Buffer,
                            Start   => (0, TMARGIN - 6),
                            Width   => 250,
                            Msg     => "100");

      UI.Texts.Draw_String (Buffer  => Buffer,
                            Start   => (20, H - TMARGIN - TMARGIN),
                            Width   => 250,
                            Msg     => "0");
   end On_Restore;

   --  ------------------------------
   --  Refresh the current display.
   --  ------------------------------
   overriding
   procedure On_Refresh (Display  : in out Display_Type;
                         Buffer   : in out HAL.Bitmap.Bitmap_Buffer'Class;
                         Deadline : out Ada.Real_Time.Time) is
   begin
      Int_Graph.Draw (Buffer, Display.Graph, Graph_Data);
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

end Graphs.Display;
