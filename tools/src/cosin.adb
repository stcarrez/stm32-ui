-----------------------------------------------------------------------
--  cosin -- Generate a sinus/cosinus table
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
with Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
procedure Cosin is

   type Float_Type is digits 15 range 0.0 .. 655336.0;

   package F_IO is new Ada.Text_IO.Float_IO (Float_Type);
   package Maths is new Ada.Numerics.Generic_Elementary_Functions (Float_Type);

   To_Rad : constant Float_Type := Ada.Numerics.Pi / 180.0;
   Angle  : Float_Type;
   Value : Float_Type;
   Scale  : constant Float_Type := 65536.0;
begin
   Ada.Text_IO.Put_Line ("package Cosin_Table is");
   Ada.Text_IO.Put_Line ("   type Cosin_Value is new Integer;");
   Ada.Text_IO.Put_Line ("   type Cosin_Array is array (0 .. 179) of Cosin_Value;");
   Ada.Text_IO.Put_Line ("   Factor : constant Cosin_Value := 65536;");
   Ada.Text_IO.Put_Line ("   Sin_Table : constant array (0 .. 179) of Cosin_Value := (");
   Ada.Text_IO.Put ("       ");
   for I in 0 .. 89 loop
      Angle := To_Rad * Float_Type (I);
      Value := Scale * Maths.Sin (Angle);
      Ada.Text_IO.Put (Integer'Image (Integer (Value)));
      Ada.Text_IO.Put (",");

      Angle := Angle + To_Rad / 2.0;
      Value := Scale * Maths.Sin (Angle);
      Ada.Text_IO.Put (Integer'Image (Integer (Value)));
      if (I mod 4) = 3 then
         Ada.Text_IO.Put_Line (",");
         Ada.Text_IO.Put ("       ");
      elsif I /= 89 then
         Ada.Text_IO.Put (",");
      end if;
   end loop;
   Ada.Text_IO.Put_Line (");");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("    Cos_Table : constant array (0 .. 179) of Cosin_Value := (");
   Ada.Text_IO.Put ("       ");
   for I in 0 .. 89 loop
      Angle := To_Rad * Float_Type (I);
      Value := Scale * Maths.Cos (Angle);
      Ada.Text_IO.Put (Integer'Image (Integer (Value)));
      Ada.Text_IO.Put (",");

      Angle := Angle + To_Rad / 2.0;
      Value := Scale * Maths.Cos (Angle);
      Ada.Text_IO.Put (Integer'Image (Integer (Value)));
      if (I mod 4) = 3 then
         Ada.Text_IO.Put_Line (",");
         Ada.Text_IO.Put ("       ");
      elsif I /= 89 then
         Ada.Text_IO.Put (",");
      end if;
   end loop;
   Ada.Text_IO.Put_Line (");");
   Ada.Text_IO.Put_Line ("end Cosin_Table;");
end Cosin;
