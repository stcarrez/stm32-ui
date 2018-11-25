-----------------------------------------------------------------------
--  gif2ada -- Read a GIF image and write an Ada package with it for UI.Images
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
with Interfaces;
with Ada.Text_IO;
with Ada.Streams.Stream_IO;
with Ada.Command_Line;
with Ada.Calendar;
with GID;
procedure Gif2ada is
   use Interfaces;

   Image  : GID.Image_descriptor;
begin
   if Ada.Command_Line.Argument_Count /= 2 then
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error,
                            "Usage: gif2ada <package-name> <file>");
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error,
                            "Generate an Ada package that contains an GIF image");
      Ada.Command_Line.Set_Exit_Status (2);
      return;
   end if;
   declare

      subtype Primary_color_range is Unsigned_8;

      procedure Get_Color (Red, Green, Blue : Interfaces.Unsigned_8);
      procedure Set_X_Y (X, Y : in Natural) is null;
      procedure Put_Pixel (Red, Green, Blue : Primary_color_range;
                           Alpha            : Primary_color_range) is null;
      procedure Feedback (Percents : Natural) is null;
      procedure Raw_Byte (B : in Interfaces.Unsigned_8);

      Name : constant String := Ada.Command_Line.Argument (1);
      Path : constant String := Ada.Command_Line.Argument (2);
      File : Ada.Streams.Stream_IO.File_Type;
      Color_Count : Natural := 0;
      Need_Sep  : Boolean := False;
      Need_Line : Boolean := False;
      Count     : Natural := 0;

      procedure Raw_Byte (B : in Interfaces.Unsigned_8) is
      begin
         if Need_Sep then
            Ada.Text_IO.Put (",");
         end if;
         if Need_Line then
            Need_Line := False;
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Set_Col (8);
         end if;
         Need_Sep := True;
         Ada.Text_IO.Put (Natural'Image (Natural (B)));
         Count := Count + 1;
         Need_Line := (Count mod 8) = 0;
      end Raw_Byte;

      procedure Load_Image is
        new GID.Load_image_contents (Primary_color_range, Set_X_Y,
                                     Put_Pixel, Raw_Byte, Feedback, GID.fast);

      procedure Get_Color (Red, Green, Blue : Interfaces.Unsigned_8) is
         Red_Image : constant String := Unsigned_8'Image (Red);
      begin
         if Color_Count > 0 then
            Ada.Text_IO.Put (",");
         end if;
         if Color_Count mod 4 = 3 then
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Set_Col (9);
         else
            Ada.Text_IO.Put (" ");
         end if;
         Color_Count := Color_Count + 1;
         Ada.Text_IO.Put ("(");
         Ada.Text_IO.Put (Red_Image (Red_Image'First + 1 .. Red_Image'Last));
         Ada.Text_IO.Put (",");
         Ada.Text_IO.Put (Unsigned_8'Image (Green));
         Ada.Text_IO.Put (",");
         Ada.Text_IO.Put (Unsigned_8'Image (Blue));
         Ada.Text_IO.Put (")");
      end Get_Color;

      procedure Write_Palette is
        new GID.Get_palette (Get_Color);

      Next_Frame : Ada.Calendar.Day_Duration := 0.0;
   begin
      Ada.Streams.Stream_IO.Open (File, Ada.Streams.Stream_IO.In_File, Path);
      GID.Load_image_header (Image, Ada.Streams.Stream_IO.Stream (File).all);

      Ada.Text_IO.Put_Line ("with UI.Images;");
      Ada.Text_IO.Put_Line ("package " & Name & " is");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("    ");
      Ada.Text_IO.Put_Line ("Descriptor : constant UI.Images.Image_Descriptor;");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("private");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("  Palette : aliased constant UI.Images.Color_Array := (");
      Ada.Text_IO.Set_Col (8);
      Write_Palette (Image);
      Ada.Text_IO.Put_Line ("  );");
      Ada.Text_IO.Put_Line ("    -- " & Natural'Image (Color_Count) & " colors");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("  Data    : aliased constant UI.Images.Bitmap_Array := (");
      Ada.Text_IO.Put ("       ");

      Load_Image (Image, Next_Frame);
      Ada.Streams.Stream_IO.Close (File);
      Ada.Text_IO.Put_Line ("  );");
      Ada.Text_IO.Put_Line ("    -- " & Natural'Image (Count) & " bytes");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("    Descriptor : constant UI.Images.Image_Descriptor :=");
      Ada.Text_IO.Put ("      (Width   =>");
      Ada.Text_IO.Put (Positive'Image (GID.Pixel_width (Image)));
      Ada.Text_IO.Put_Line (",");
      Ada.Text_IO.Put ("       Height  =>");
      Ada.Text_IO.Put (Positive'Image (GID.Pixel_height (Image)));
      Ada.Text_IO.Put_Line (",");
      Ada.Text_IO.Put_Line ("       Palette => Palette'Access,");
      Ada.Text_IO.Put_Line ("       Bitmap  => Data'Access);");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("end " & Name & ";");
   end;
end Gif2ada;
