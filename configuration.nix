# configuration.nix — системный уровень
# ASUS Zenbook S16 UM5606WA · CachyOS-ядро · AMD Radeon 890M
# ВАЖНО: перед установкой замени CHANGEME_USER на свой логин (команда sed в гайде).
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix   # авто-генерируется nixos-generate-config, НЕ в git
  ];

  # ─── ЗАГРУЗЧИК (systemd-boot) ──────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;   # хранить 10 поколений в меню загрузки
    efi.canTouchEfiVariables = true;
  };

  # ─── ЯДРО CachyOS (из chaotic-nyx) ─────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # Параметры ядра под UM5606WA:
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x200"   # отключить багующий PSR2-SU (зависания на Strix Point)
    "amd_pstate=active"          # лучшее управление частотой/питанием CPU
    "nowatchdog"
    # EDID-фикс 120 Гц (раскомментируй ВМЕСТЕ с блоком hardware.firmware ниже):
    # "drm.edid_firmware=eDP-1:edid/edid_mclk_fix.bin"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];   # раннее KMS
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.watermark_scale_factor" = 125;
  };

  # EDID-фикс 120 Гц — положи свой edid_mclk_fix.bin в репозиторий рядом с этим файлом,
  # раскомментируй блок и параметр ядра выше, затем nixos-rebuild switch:
  # hardware.firmware = [
  #   (pkgs.runCommandNoCC "edid-mclk-fix" {} ''
  #     install -Dm444 ${./edid_mclk_fix.bin} $out/lib/firmware/edid/edid_mclk_fix.bin
  #   '')
  # ];

  # ─── МИКРОКОД И ПРОШИВКИ ────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # ─── СЕТЬ ──────────────────────────────────────────────────────────────────
  networking.hostName = "zenbook";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";   # MT7925 стабильнее с iwd

  # ─── ВРЕМЯ / ЛОКАЛЬ / КОНСОЛЬ ──────────────────────────────────────────────
  time.timeZone = "Europe/Moscow";                  # ← поменяй на свой пояс
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "en_US.UTF-8";
  console = {
    font = "ter-132n";                              # крупный шрифт для HiDPI TTY
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };

  # ─── ГРАФИКА (AMD Radeon 890M, RDNA 3.5) ───────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;          # для Steam/Wine; убери если не нужно
    extraPackages = with pkgs; [
      libva-mesa-driver
      mesa-vdpau
      vulkan-loader
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # ─── ЗВУК (PipeWire) ───────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ─── BLUETOOTH ─────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = "true";
  };
  services.blueman.enable = true;

  # ─── ПИТАНИЕ + ASUS (лимит заряда, вентиляторы) ────────────────────────────
  services.power-profiles-daemon.enable = true;
  services.asusd.enable = true;   # после загрузки: asusctl -c 80 (лимит заряда 80%)
  # Если nixos-install ругнётся, что services.asusd не существует — закомментируй
  # эту строку и asusctl ниже, остальное соберётся.

  # ─── ДИСПЛЕЙ-МЕНЕДЖЕР (SDDM, Wayland) ──────────────────────────────────────
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ─── HYPRLAND (системный модуль — обязателен для сессии/порталов) ───────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.polkit.enable = true;
  programs.dconf.enable = true;

  # ─── ШРИФТЫ ────────────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  # ─── СИСТЕМНЫЕ ПАКЕТЫ ──────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git wget curl vim micro
    btop
    unzip zip p7zip unrar
    pciutils usbutils lshw file
    wayland wayland-utils
    brightnessctl playerctl
    wl-clipboard
    iwd
    amdgpu_top powertop
    asusctl   # CLI для лимита заряда/вентиляторов (см. services.asusd выше)
  ];

  # ─── ПОЛЬЗОВАТЕЛЬ ──────────────────────────────────────────────────────────
  users.users.CHANGEME_USER = {
    isNormalUser = true;
    description = "CHANGEME_USER";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "storage" ];
    shell = pkgs.bash;
  };

  # ─── NIX: ФЛЕЙКИ, КЭШ CachyOS, СБОРКА МУСОРА ───────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    # Бинарный кэш chaotic-nyx — чтобы ядро CachyOS не собиралось из исходников:
    substituters = [ "https://chaotic-nyx.cachix.org" "https://cache.nixos.org" ];
    trusted-public-keys = [
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ─── ZRAM (подкачка в сжатой RAM вместо файла) ─────────────────────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ─── UDEV-ПРАВИЛА (специфика UM5606WA) ─────────────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="13d3", ATTR{idProduct}=="3608", ATTR{power/control}="on"
  '';

  system.stateVersion = "25.05";   # НЕ меняй после установки (проверь nixos-version, 25.05 — безопасно)
}
