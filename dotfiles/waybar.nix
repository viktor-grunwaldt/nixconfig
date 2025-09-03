waybarCSS:
{
  enable = true;
  style = waybarCSS;
  settings = [
    {
      "layer" = "top";
      "position" = "bottom";
      modules-left = [
        "sway/workspaces"
        "sway/window"
        "sway/mode"
      ];
      modules-center = [ "" ];
      modules-right = [
        "tray"
        "network"
        "wireplumber"
        "bluetooth"
        "cpu"
        "memory"
        "battery"
        "clock#date"
        "clock#time"
      ];
      "network" = {
        "format-wifi" = "  {essid} ({signalStrength}%)";
        "format-ethernet" = "{ifname}";
        "format-disconnected" = " ";
        "max-length" = 50;
        "on-click" = "exec alacritty -e nmtui";
      };
      "cpu" = {
        "format" = " {usage:02}%";
        "tooltip" = false;
        "interval" = 1;
        "on-click" = "exec alacritty -e btop";
      };
      "memory" = {
        "format" = " {:02}%";
      };
      "battery" = {
        "format" = "{icon} {capacity:02}%";
        "format-icons" = {
          "default" = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          "charging" = [
            "󰢜"
            "󰂇"
            "󰢝"
            "󰢞"
            "󰂅"
          ];
        };
        "states" = {
          "warning" = 20;
          "critical" = 10;
        };
      };
      "clock#date" = {
        "format" = "{:%d.%m}";
      };
      "clock#time" = {
        "format" = "{:%H:%M}";
      };
      "wireplumber" = {
        "format" = "{icon} {volume:02}%";
        "format-muted" = "󰝟";
        "format-icons" = {
          "default" = [
            ""
            "󰖀"
            "󰕾"
          ];
        };
        "on-click-right" = "exec pwvucontrol";
        "on-click" = "wpctl set-mute @DEFAULT_SINK@ toggle";
      };
      "bluetooth" = {
        "on-click-right" = "exec alacritty -e bluetuith";
      };
    }
  ];
}
