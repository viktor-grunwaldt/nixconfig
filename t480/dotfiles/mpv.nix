pkgs: inputConf:
{
  enable = true;
  scripts = with pkgs; [
    # mpvScripts.builtins.autoload
    mpvScripts.autoload
  ];
  # Use the contents of your mpv.conf file
  config = {
    geometry = "50%:50%";
    alang = "ja,jp,jpn,en,eng,de,deu,ger";
    slang = "en,eng,pl,pol";
    autofit-larger = "80%x80%";

    # save-position-on-quit
    border = false;
    msg-module = true;
    msg-color = true;
    term-osd-bar = true;
    use-filedir-conf = true;
    # pause
    keep-open = true;
    # autofit-larger = "100%x95%";
    cursor-autohide-fs-only = true;
    cursor-autohide = 1000;

    screenshot-format = "png";
    screenshot-png-compression = 8;
    screenshot-template = "~/Pictures/mpv/%F (%P) %n";

    hls-bitrate = "max";
    ytdl-format = "bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9][protocol!=http_dash_segments]+bestaudio/best";

    # Cache settings
    cache = true;
    # cache-default = 5000000;
    # cache-backbuffer = 25000;
    # cache-initial = 0;
    # cache-secs = 10;

    # OSD / OSC settings
    osd-level = 1;
    osd-duration = 2000;
    osd-status-msg = "$\\{time-pos} / $\\{duration}$\\{?percent-pos:　($\\{percent-pos}%)}$\\{?frame-drop-count:$\\{!frame-drop-count==0:　Dropped: $\\{frame-drop-count}}}\\n$\\{?chapter:Chapter: $\\{chapter}}";

    osd-font = "Hack";
    osd-font-size = 32;
    osd-color = "#CCFFFFFF";
    osd-border-color = "#DD322640";
    # osd-shadow-offset = 1;
    osd-bar-align-y = 1;
    osd-border-size = 2;
    osd-bar-h = 2;
    osd-bar-w = 60;

    # Profile-specific settings
    # TODO: figure out how profiles work
    # profiles = {
    #   "profile:extension.gif" = {
    #     "cache" = false;
    #     "no-pause" = true;
    #     "loop-file" = true;
    #   };

    #   "profile:extension.webm" = {
    #     # Uncomment the lines if needed
    #     # "cache" = false;
    #     # "no-pause" = true;
    #     # "loop-file" = true;
    #   };
    # };

    # Subtitle settings

    # sub-ass-vsfilter-blur-compat = true; # replaced by use-video-data
    sub-ass-use-video-data = "all";
    sub-fix-timing = true;
    sub-auto = "fuzzy";
    sub-font = "Andika New Basic Bold";
    sub-font-size = 52;
    sub-blur = 0.2;
    sub-border-color = "0.0/0.0/0.0/1.0";
    sub-border-size = 3.0;
    sub-color = "1.0/1.0/1.0/1.0";
    sub-margin-x = 100;
    sub-margin-y = 10;
    sub-shadow-color = "0.0/0.0/0.0/0.25";
    sub-shadow-offset = 0;

    # Debanding settings
    deband = true;
    deband-iterations = 4;
    deband-threshold = 48;
    deband-range = 16;
    deband-grain = 48;
  };
  # Use the contents of your input.conf file
  extraInput = inputConf;
}
