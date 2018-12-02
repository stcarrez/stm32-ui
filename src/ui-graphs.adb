-----------------------------------------------------------------------
--  ui-graphs -- Generic package to draw graphs
--  Copyright (C) 2016, 2017, 2018 Stephane Carrez
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

package body UI.Graphs is

   use type Ada.Real_Time.Time;

   --  ------------------------------
   --  Initialize the graph.
   --  ------------------------------
   procedure Initialize (Data   : in out Data_Type;
                         Rate   : in Ada.Real_Time.Time_Span) is
   begin
      Data.Initialize (Rate);
   end Initialize;

   --  ------------------------------
   --  Add the sample value to the current graph sample.
   --  ------------------------------
   procedure Add_Sample (Data  : in out Data_Type;
                         Value : in Value_Type;
                         Now   : in Ada.Real_Time.Time := Ada.Real_Time.Clock) is
   begin
      Data.Add_Sample (Value, Now);
   end Add_Sample;

   --  ------------------------------
   --  Get the current deadline for the graph sample.
   --  ------------------------------
   function Get_Deadline (Data : in Data_Type) return Ada.Real_Time.Time is
   begin
      return Data.Get_Deadline;
   end Get_Deadline;

   --  ------------------------------
   --  Initialize the graph.
   --  ------------------------------
   procedure Initialize (Graph  : in out Graph_Type;
                         X      : in Natural;
                         Y      : in Natural;
                         Width  : in Natural;
                         Height : in Natural) is
   begin
      Graph.Pos.X := X;
      Graph.Pos.Y := Y;
      Graph.Width := Width;
      Graph.Height := Height;
      Graph.Min_Value := Value_Type'First;
      Graph.Max_Value := Value_Type'Last;
   end Initialize;

   --  ------------------------------
   --  Set the range values of the graph.
   --  ------------------------------
   procedure Set_Range (Graph : in out Graph_Type;
                        Min   : in Value_Type;
                        Max   : in Value_Type) is
   begin
      Graph.Min_Value := Min;
      Graph.Max_Value := Max;
      Graph.Auto_Scale := False;
   end Set_Range;

   protected body Data_Type is

      --  ------------------------------
      --  Initialize the graph.
      --  ------------------------------
      procedure Initialize (Rate   : in Ada.Real_Time.Time_Span) is
      begin
         Graph_Rate   := Rate;
         Current_Sample := Value_Type'First;
         Deadline := Ada.Real_Time.Clock + Rate;
         Sample_Count := 0;
         Last_Pos := 1;
         Samples := (others => Value_Type'First);
      end Initialize;

      --  ------------------------------
      --  Add the sample value to the current graph sample.
      --  ------------------------------
      procedure Add_Sample (Value : in Value_Type;
                            Now   : in Ada.Real_Time.Time := Ada.Real_Time.Clock) is
      begin
         --  Deadline has passed, update the graph values, filling with zero empty slots.
         if Deadline < Now then
            loop
               Samples (Last_Pos) := Current_Sample;
               Current_Sample := Value_Type'First;
               if Last_Pos = Samples'Last then
                  Last_Pos := Samples'First;
               else
                  Last_Pos := Last_Pos + 1;
               end if;
               if Sample_Count < Samples'Length then
                  Sample_Count := Sample_Count + 1;
               end if;
               Deadline := Deadline + Graph_Rate;

               --  Check if next deadline has passed.
               exit when Now < Deadline;
            end loop;
         end if;
         Current_Sample := Current_Sample + Value;
      end Add_Sample;

      --  ------------------------------
      --  Compute the maximum value seen as a sample in the graph data.
      --  ------------------------------
      function Compute_Max_Value return Value_Type is
         Value : Value_Type := Value_Type'First;
      begin
         for V of Samples loop
            if V > Value then
               Value := V;
            end if;
         end loop;
         return Value;
      end Compute_Max_Value;

      --  ------------------------------
      --  Get the current deadline for the graph sample.
      --  ------------------------------
      function Get_Deadline return Ada.Real_Time.Time is
      begin
         return Deadline;
      end Get_Deadline;

      --  ------------------------------
      --  Get the values to be displayed.
      --  ------------------------------
      procedure Get_Values (Into   : out Normalized_Data_Type;
                            Min    : in Value_Type;
                            Max    : in Value_Type;
                            Scale  : in Natural;
                            Height : in Positive) is
         Len   : constant Natural := Into'Length;
         Pos   : Positive;
         Value : Value_Type'Base;
      begin
         if Sample_Count <= Len then
            Pos := 1;
         else
            if Last_Pos > Len then
               Pos := Last_Pos - Len;
            else
               Pos := Samples'Last - Len + Last_Pos;
            end if;
         end if;
         if Scale = 1 then
            for I in Into'Range loop
               Value := Samples (Pos);
               if Value > Max then
                  Value := Max;
               elsif Value < Min then
                  Value := Min;
               end if;
               Value := Value * Value_Type'Base (Height) / (Max - Min);
               Into (I) := Normalized_Value_Type (Value);
               if Pos = Samples'Last then
                  Pos := Samples'First;
               else
                  Pos := Pos + 1;
               end if;
            end loop;
         end if;
      end Get_Values;

   end Data_Type;

   --  ------------------------------
   --  Draw the graph.
   --  ------------------------------
   procedure Draw (Buffer : in out HAL.Bitmap.Bitmap_Buffer'Class;
                   Graph  : in out Graph_Type;
                   Data   : in out Data_Type) is
      X      : Natural := Graph.Pos.X;
      H      : Natural;
      Values : Normalized_Data_Type (1 .. Graph.Width);
   begin
      --  Recompute the max-value for auto-scaling.
      if Graph.Max_Value = 0 or Graph.Auto_Scale then
         Graph.Max_Value := Data.Compute_Max_Value;
      end if;
      Buffer.Set_Source (Graph.Background);
      Buffer.Fill_Rect (Area => (Position => (Graph.Pos.X, Graph.Pos.Y),
                                 Width    => Graph.Width,
                                 Height   => Graph.Height));
      if Graph.Max_Value = 0 then
         return;
      end if;

      Data.Get_Values (Values, Graph.Min_Value, Graph.Max_Value, 1, Graph.Height);
      for V of Values loop
         H := Natural (V);
         if H > 5 then
            Buffer.Set_Source (Graph.Fill);
            Buffer.Draw_Vertical_Line (Pt => (X, 1 + Graph.Pos.Y + Graph.Height - H),
                                       Height => H - 1);
         end if;
         Buffer.Set_Source (Graph.Foreground);
         Buffer.Set_Pixel (Pt => (X, Graph.Pos.Y + Graph.Height - H));
         X := X + 1;
      end loop;
   end Draw;

end UI.Graphs;
