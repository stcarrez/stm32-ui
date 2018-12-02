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
with System;

with HAL.Bitmap;
with Ada.Real_Time;

with UI.Buttons;
with UI.Displays;
with UI.Graphs;

--  The graphs display manager displays a graph that shows more or less the CPU usage.
--  An idle task is run at the lowest priority and it increments a counter during 100ms
--  samples.  Each 100ms, a percentage of CPU usage is computed from the counter.
--  The computed value is absolutely not exact and gives a very rough estimate of the CPU usage.
--  The CPU usage is a value in the range 0..100 which is then graphed by `UI.Graphs`.
package Graphs.Display is

   --  Display refresh period.
   DISPLAY_TIME : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (300);

   --  The graph rate: 1 new sample added each 100ms.
   GRAPH_RATE : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (100);

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

   type Graph_Value_Type is new Natural range 0 .. 100;

   package Int_Graph is new UI.Graphs (Value_Type => Graph_Value_Type, Graph_Size => 1000);

   subtype Graph_Type is Int_Graph.Graph_Type;

   Graph_Data   : Int_Graph.Data_Type;

   task Idle_Task with Priority => System.Priority'First;

   type Display_Type is limited new UI.Displays.Display_Type with record
      Next_Button  : UI.Buttons.Button_Type;
      Prev_Button  : UI.Buttons.Button_Type;
      Graph        : Graph_Type;
      Info_Button  : UI.Buttons.Button_Type;
      Update       : Ada.Real_Time.Time;
      Print_Info   : Boolean := True;
   end record;

end Graphs.Display;
