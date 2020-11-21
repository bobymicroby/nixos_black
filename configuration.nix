{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    version = 2;
    device = "nodev";
    useOSProber = true;
  };

  boot.initrd.luks.devices.luksroot = {
    allowDiscards = true;
    device = "/dev/nvme0n1p6";
    preLVM = true;
  };

  networking.hostName = "black-nixos";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  #networking.interfaces.wlp0s20f0u10.useDHCP = true;
  #networking.interfaces.wlp3s0.useDHCP = true;

  networking.wireless.extraConfig = ''
    ctrl_interface=/run/wpa_supplicant
    ctrl_interface_group=wheel
  '';

  networking.firewall.allowedTCPPortRanges = [{
    from = 8443;
    to = 8443;
  }];

  time.timeZone = "Europe/Sofia";

  virtualisation.docker.enable = true;

  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.driSupport32Bit = true;

  nixpkgs.config.allowUnfree = true;
  programs.adb.enable = true;
  programs.gnupg.agent.enable = true;

  environment.variables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
  environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";
  environment.systemPackages = with pkgs; [

    (import ./vim.nix)
    vim_configurable
    gitFull
    htop
    which
    file
    firefox
    cabal-install
    cabal2nix
    emacs
    unrar
    unzip
    glibc
    patchelf
    tmux
    dmenu
    gnome3.gnome-screenshot
    dzen2
    conky
    flameshot
    xclip
    xsel
  ];
  
  
  services.upower.enable = true;
  services.blueman.enable = true;
  services.xserver = {

    enable = true;

    libinput.enable = true;

    # Set extra config to libinput devices
    extraConfig = ''
      Section "InputClass"
        Identifier      "Touchpads"
        Driver          "libinput"
        MatchProduct    "Apple Inc. Magic Trackpad 2"
        MatchDevicePath "/dev/input/event*"
      EndSection

    '';

    layout = "us,bg(phonetic)";
    xkbOptions = "grp:shifts_toggle";

    autoRepeatDelay = 300;
    autoRepeatInterval = 50;

    videoDrivers = [ "nvidia" ];
    dpi = 150;

    monitorSection = ''
      DisplaySize 401 171
    '';

    screenSection = ''
      Option "DPI" "130 x 130"
    '';

    windowManager = {
      xmonad.enable = true;
      xmonad.extraPackages = hpkgs: [
        hpkgs.xmonad-contrib
        hpkgs.xmonad-extras
        hpkgs.xmobar
        hpkgs.yeganesh
      ];

    };

    displayManager.defaultSession = "none+xmonad";

    displayManager.gdm = {
      wayland = false;
      enable = true;
    };
    displayManager.sessionCommands = ''
       
      xsetroot -solid '#073642'
      xset r rate 350 50 
          
      xrdb "${
        pkgs.writeText "xrdb.conf" ''
                 
          Xft*antialias:              true
          Xft*hinting:                full  
          Xft.antialias: 1
          Xft.autohint: 1
          Xft.hintstyle: hintslight
                 
          XTerm*faceName:             xft:Dejavu Sans Mono for Powerline:size=9
          XTerm*utf8:                 2


          #define S_base03        #002b36
          #define S_base02        #073642
          #define S_base01        #586e75
          #define S_base00        #657b83
          #define S_base0         #839496
          #define S_base1         #93a1a1
          #define S_base2         #eee8d5
          #define S_base3         #fdf6e3
          #define S_yellow        #b58900
          #define S_orange        #cb4b16
          #define S_red           #dc322f
          #define S_magenta       #d33682
          #define S_violet        #6c71c4
          #define S_blue          #268bd2
          #define S_cyan          #2aa198
          #define S_green         #859900

          *background:            S_base03
          *foreground:            S_base0
          *fadeColor:             S_base03
          *cursorColor:           S_base1
          *pointerColorBackground:S_base01
          *pointerColorForeground:S_base1

          !! black dark/light
          *color0:                S_base02
          *color8:                S_base03

          !! red dark/light
          *color1:                S_red
          *color9:                S_orange

          !! green dark/light
          *color2:                S_green
          *color10:               S_base01

          !! yellow dark/light
          *color3:                S_yellow
          *color11:               S_base00

          !! blue dark/light
          *color4:                S_blue
          *color12:               S_base0

          !! magenta dark/light
          *color5:                S_magenta
          *color13:               S_violet

          !! cyan dark/light
          *color6:                S_cyan
          *color14:               S_base1

          !! white dark/light
          *color7:                S_base2
          *color15:               S_base3
           
        ''
      }"
    '';

  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      dejavu_fonts
      powerline-fonts
      source-code-pro
      terminus_font
    ];
  };

  programs.ssh = {
    startAgent = true;

  };
  services.gnome3.gnome-keyring.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source "$(${pkgs.fzf}/bin/fzf-share)/key-bindings.zsh"
    '';
    ohMyZsh = {
      enable = true;
      plugins =
        [ "git" "colored-man-pages" "command-not-found" "extract" "nix" ];
      customPkgs = with pkgs; [ spaceship-prompt nix-zsh-completions ];
      theme = "spaceship";
    };
  };

  users.defaultUserShell = pkgs.zsh;

  users.extraUsers.bobby = {
    createHome = true;
    extraGroups =
      [ "wheel" "docker" "video" "audio" "disk" "networkmanager" "adbusers" ];
    group = "users";
    home = "/home/bobby";
    isNormalUser = true;
    uid = 1000;
  };

  system.stateVersion = "20.09";

}


