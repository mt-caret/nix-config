hidpi: {
  env.TERM = "xterm-256color";

  font = let
    font-family = "Ricty Diminished with Fira Code";
  in
    {
      normal.family = font-family;
      bold.family = font-family;
      italic.family = font-family;
      size = if hidpi then 10.0 else 6.0;
    };

  # Colors (Tomorrow Night Bright)
  colors = {
    # Default colors
    primary = {
      background = "0x000000";
      foreground = "0xeaeaea";
    };

    # Colors the cursor will use if `custom_cursor_colors` is true
    cursor = {
      text = "0x000000";
      cursor = "0xffffff";
    };

    # Normal colors
    normal = {
      black = "0x000000";
      red = "0xd54e53";
      green = "0xb9ca4a";
      yellow = "0xe6c547";
      blue = "0x7aa6da";
      magenta = "0xc397d8";
      cyan = "0x70c0ba";
      white = "0xffffff";
    };

    # Bright colors
    bright = {
      black = "0x666666";
      red = "0xff3334";
      green = "0x9ec400";
      yellow = "0xe7c547";
      blue = "0x7aa6da";
      magenta = "0xb77ee0";
      cyan = "0x54ced6";
      white = "0xffffff";
    };

    # Dim colors (Optional)
    dim = {
      black = "0x333333";
      red = "0xf2777a";
      green = "0x99cc99";
      yellow = "0xffcc66";
      blue = "0x6699cc";
      magenta = "0xcc99cc";
      cyan = "0x66cccc";
      white = "0xdddddd";
    };
  };

  background_opacity = 0.8;
  window.dynamic_title = true;
  mouse.hide_when_typing = true;
}
