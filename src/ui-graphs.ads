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
with HAL.Bitmap;
with Interfaces;
with Ada.Real_Time;
generic
   type Value_Type is range <>;
   Graph_Size : Positive;
   MAX_WIDTH  : Positive := 800;
package UI.Graphs is

   --  The `Data_Type` holds the values of the graph to be displayed.
   type Data_Type is limited private;

   --  Initialize the graph.
   procedure Initialize (Data   : in out Data_Type;
                         Rate   : in Ada.Real_Time.Time_Span);

   --  Add the sample value to the current graph sample.
   procedure Add_Sample (Data  : in out Data_Type;
                         Value : in Value_Type;
                         Now   : in Ada.Real_Time.Time := Ada.Real_Time.Clock);

   --  Get the current deadline for the graph sample.
   function Get_Deadline (Data : in Data_Type) return Ada.Real_Time.Time;

   --  The `Graph_Type` holds information to display the data on the screen.
   type Graph_Type is limited private;

   --  Initialize the graph.
   procedure Initialize (Graph  : in out Graph_Type;
                         X      : in Natural;
                         Y      : in Natural;
                         Width  : in Natural;
                         Height : in Natural);

   --  Set the range values of the graph.
   procedure Set_Range (Graph : in out Graph_Type;
                        Min   : in Value_Type;
                        Max   : in Value_Type) with
     Pre => Min < Max;

   --  Draw the graph.
   procedure Draw (Buffer : in out HAL.Bitmap.Bitmap_Buffer'Class;
                   Graph  : in out Graph_Type;
                   Data   : in out Data_Type);

private

   type Value_Data_Type is array (1 .. Graph_Size) of Value_Type;

   subtype Normalized_Value_Type is Interfaces.Integer_16;

   subtype Width_Type is Natural range 0 .. MAX_WIDTH;

   type Normalized_Data_Type is array (Width_Type range <>) of Normalized_Value_Type;

   protected type Data_Type is

      --  Initialize the graph.
      procedure Initialize (Rate   : in Ada.Real_Time.Time_Span);

      --  Add the sample value to the current graph sample.
      procedure Add_Sample (Value : in Value_Type;
                            Now   : in Ada.Real_Time.Time := Ada.Real_Time.Clock);

      --  Get the current deadline for the graph sample.
      function Get_Deadline return Ada.Real_Time.Time;

      --  Compute the maximum value seen as a sample in the graph data.
      function Compute_Max_Value return Value_Type;

      --  Get the values to be displayed.
      procedure Get_Values (Into   : out Normalized_Data_Type;
                            Min    : in Value_Type;
                            Max    : in Value_Type;
                            Scale  : in Natural;
                            Height : in Positive) with
        Pre => Into'Length <= Value_Data_Type'Length and Min < Max;

   private
      Graph_Rate       : Ada.Real_Time.Time_Span;
      Current_Sample   : Value_Type;
      Samples          : Value_Data_Type;
      Deadline         : Ada.Real_Time.Time;
      Last_Pos         : Positive := 1;
      Display_Pos      : Positive := 1;
      Sample_Count     : Natural := 0;
   end Data_Type;

   type Graph_Type is limited record
      Width        : Natural := 0;
      Height       : Natural := 0;
      Max_Value    : Value_Type := Value_Type'First;
      Min_Value    : Value_Type := Value_Type'First;
      Auto_Scale   : Boolean := True;
      Pos          : HAL.Bitmap.Point := (0, 0);
      Foreground   : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Green;
      Background   : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
      Fill         : HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Dark_Green;
   end record;

end UI.Graphs;
