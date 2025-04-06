waybarCSS:
{
  enable = true;
  systemd.enable = true;
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
        "format" = " {usage}%";
        "tooltip" = false;
        "interval" = 1;
      };
      "memory" = {
        "format" = " {}%";
      };
      "battery" = {
        "format" = "{icon} {capacity}%";
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
        "format" = "{icon} {volume}%";
        "format-bluetooth" = "{icon} {volume}% {format_source}";
        "format-bluetooth-muted" = "󰝟 {icon} {format_source}";
        "format-muted" = "󰝟";
        "format-icons" = {
          "headphone" = "";
          "hands-free" = "";
          "headset" = "󰋎";
          "phone" = "";
          "portable" = "";
          "car" = "";
          "default" = [
            ""
            "󰖀"
            "󰕾"
          ];
        };
        "on-click-right" = "pavucontrol";
        "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };
    }
  ];
}
