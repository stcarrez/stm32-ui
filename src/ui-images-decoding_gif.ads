private package UI.Images.Decoding_GIF is

  --------------------
  -- Image decoding --
  --------------------

  generic
    type Primary_color_range is mod <>;
    with procedure Set_X_Y (x, y: Natural);
    with procedure Put_Pixel (
      red, green, blue : Primary_color_range;
      alpha            : Primary_color_range
    );
    with procedure Feedback (percents: Natural);
    mode: Display_mode;
  --
  procedure Load (image     : in Image_Descriptor);

end UI.Images.Decoding_GIF;
