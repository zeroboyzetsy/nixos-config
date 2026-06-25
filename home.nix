# home.nix — пользовательский уровень (Hyprland, панель, лаунчер, дотфайлы)
# Тема: Catppuccin Mocha. Монитор: OLED 2880x1800@120, scale 1.5.
# ВАЖНО: замени CHANGEME_USER на свой логин (команда sed в гайде).
{ config, pkgs, lib, ... }:

{
  home.username = "CHANGEME_USER";
  home.homeDirectory = "/home/CHANGEME_USER";

  # ─── ПАКЕТЫ ПОЛЬЗОВАТЕЛЯ ───────────────────────────────────────────────────
  home.packages = with pkgs; [
    hyprpicker hyprpolkitagent
    wofi swaynotificationcenter wlogout
    grim slurp swappy
    cliphist
    xfce.thunar xfce.thunar-volman gvfs xfce.tumbler
    networkmanagerapplet
    pavucontrol pamixer
    nwg-look
    mpv imv
    # браузер по вкусу: librewolf / firefox — добавь сюда
  ];

  # ─── HYPRLAND ──────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = "eDP-1,2880x1800@120,0x0,1.5";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland,x11"
        "MOZ_ENABLE_WAYLAND,1"
        "SDL_VIDEODRIVER,wayland"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "waybar"
        "swaync"
        "nm-applet --indicator"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "mkdir -p ~/Pictures/Screenshots"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ee) rgba(89b4faee) 45deg";
        "col.inactive_border" = "rgba(313244aa)";
        resize_on_border = true;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = { enabled = true; size = 3; passes = 1; };
        shadow.enabled = false;
      };

      animations.enabled = true;
      dwindle.preserve_split = true;

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };
      };

      gestures.workspace_swipe = true;

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, E, exec, thunar"
        "$mod, R, exec, wofi --show drun"
        "$mod, Space, exec, wofi --show drun"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, J, togglesplit"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, E, exec, wlogout"
        "$mod SHIFT, M, exit"
        "$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
        ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, Print, exec, grim ~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png"
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindl = [
        ", XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay,    exec, playerctl play-pause"
        ", XF86AudioNext,    exec, playerctl next"
        ", XF86AudioPrev,    exec, playerctl previous"
      ];

      binde = [
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      windowrulev2 = [
        "float, class:^(org.pulseaudio.pavucontrol|pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(blueman-manager)$"
        "suppressevent maximize, class:.*"
      ];
    };
  };

  # ─── WAYBAR ────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      spacing = 6;
      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "tray" "hyprland/language" "pulseaudio" "backlight"
        "network" "bluetooth" "power-profiles-daemon" "battery" "custom/notification"
      ];
      "hyprland/workspaces" = { format = "{id}"; on-click = "activate"; sort-by-number = true; };
      "hyprland/window" = { max-length = 60; separate-outputs = true; };
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%a, %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };
      "hyprland/language" = { format = "{}"; format-en = "EN"; format-ru = "RU"; };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 mute";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "pavucontrol";
        scroll-step = 3;
      };
      backlight = { format = "{icon} {percent}%"; format-icons = [ "󰃞" "󰃟" "󰃠" ]; };
      network = {
        format-wifi = "󰤨 {essid}";
        format-ethernet = "󰈀 LAN";
        format-disconnected = "󰤭 offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%)";
        on-click = "nm-connection-editor";
      };
      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-connected = "󰂱 {num_connections}";
        on-click = "blueman-manager";
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Профиль: {profile}";
        format-icons = { default = "󱐋"; performance = "󱐋"; balanced = "󰗑"; power-saver = "󰌪"; };
      };
      battery = {
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        states = { warning = 25; critical = 12; };
      };
      "custom/notification" = {
        format = "{icon}";
        format-icons = { notification = "󱅫"; none = "󰂚"; dnd-notification = "󰂛"; dnd-none = "󰂛"; };
        return-type = "json";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 14px;
        min-height: 0;
      }
      window#waybar {
        background: rgba(17, 17, 27, 0.82);
        color: #cdd6f4;
        border-bottom: 1px solid rgba(49, 50, 68, 0.6);
      }
      #workspaces button {
        padding: 0 8px; margin: 0 2px;
        color: #6c7086; background: transparent; border-radius: 8px;
      }
      #workspaces button.active { color: #11111b; background: #cba6f7; }
      #workspaces button.urgent { color: #11111b; background: #f38ba8; }
      #window { margin-left: 8px; color: #a6adc8; }
      #clock { font-weight: bold; }
      #language { color: #89b4fa; font-weight: bold; }
      #power-profiles-daemon { color: #f9e2af; }
      #battery.charging, #battery.plugged { color: #a6e3a1; }
      #battery.warning:not(.charging) { color: #f9e2af; }
      #battery.critical:not(.charging) { color: #f38ba8; }
      #custom-notification { color: #cba6f7; }
      #clock, #tray, #language, #pulseaudio, #backlight,
      #network, #bluetooth, #power-profiles-daemon,
      #battery, #custom-notification { padding: 0 10px; margin: 4px 0; }
    '';
  };

  # ─── KITTY ─────────────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    font = { name = "JetBrainsMono Nerd Font"; size = 12; };
    settings = {
      background_opacity = "0.94";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 10000;
      copy_on_select = "clipboard";
      cursor_shape = "beam";
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_background = "#f5e0dc";
      selection_foreground = "#1e1e2e";
      color0 = "#45475a"; color8  = "#585b70";
      color1 = "#f38ba8"; color9  = "#f38ba8";
      color2 = "#a6e3a1"; color10 = "#a6e3a1";
      color3 = "#f9e2af"; color11 = "#f9e2af";
      color4 = "#89b4fa"; color12 = "#89b4fa";
      color5 = "#f5c2e7"; color13 = "#f5c2e7";
      color6 = "#94e2d5"; color14 = "#94e2d5";
      color7 = "#bac2de"; color15 = "#a6adc8";
    };
  };

  # ─── HYPRPAPER ─────────────────────────────────────────────────────────────
  # Положи обои в ~/Pictures/wallpaper.jpg (или поменяй путь в обеих строках).
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [ "eDP-1,~/Pictures/wallpaper.jpg" ];
      splash = false;
      ipc = "on";
    };
  };

  # ─── HYPRIDLE ──────────────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 150;  on-timeout = "brightnessctl -s set 10"; on-resume = "brightnessctl -r"; }
        { timeout = 150;  on-timeout = "brightnessctl -sd asus::kbd_backlight set 0"; on-resume = "brightnessctl -rd asus::kbd_backlight"; }
        { timeout = 300;  on-timeout = "loginctl lock-session"; }
        { timeout = 330;  on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
        { timeout = 1800; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  # ─── HYPRLOCK ──────────────────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [{ path = "screenshot"; blur_passes = 3; blur_size = 7; brightness = 0.55; }];
      label = [
        {
          text = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
          color = "rgb(cdd6f4)"; font_size = 96;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 160"; halign = "center"; valign = "center";
        }
        {
          text = "cmd[update:60000] echo \"$(date +'%A, %d %B')\"";
          color = "rgb(a6adc8)"; font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 60"; halign = "center"; valign = "center";
        }
      ];
      input-field = [{
        size = "300, 56";
        outline_thickness = 2;
        outer_color = "rgba(cba6f7ee)";
        inner_color = "rgba(1e1e2ee6)";
        font_color = "rgb(cdd6f4)";
        placeholder_text = "Пароль...";
        position = "0, -120"; halign = "center"; valign = "center";
      }];
    };
  };

  # ─── WOFI (через xdg.configFile — модуля в HM нет) ─────────────────────────
  xdg.configFile."wofi/config".text = ''
    show=drun
    width=640
    height=420
    allow_images=true
    image_size=28
    insensitive=true
    matching=fuzzy
    no_actions=true
    term=kitty
  '';
  xdg.configFile."wofi/style.css".text = ''
    window {
      background-color: rgba(17, 17, 27, 0.92);
      border: 2px solid #cba6f7;
      border-radius: 14px;
      font-family: "JetBrainsMono Nerd Font";
      font-size: 15px;
    }
    #input {
      margin: 10px; padding: 8px 12px; border: none; border-radius: 10px;
      color: #cdd6f4; background-color: #1e1e2e;
    }
    #inner-box { margin: 0 10px 10px 10px; background-color: transparent; }
    #outer-box, #scroll { background-color: transparent; }
    #text { color: #cdd6f4; margin: 0 8px; }
    #entry { padding: 8px; border-radius: 10px; }
    #entry:selected { background-color: #cba6f7; }
    #entry:selected #text { color: #11111b; font-weight: bold; }
  '';

  programs.bash.enable = true;
  services.ssh-agent.enable = true;

  home.stateVersion = "25.05";
}
