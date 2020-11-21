
{ config, pkgs, ... }:

{
imports =
  [ 
    ./hardware-configuration.nix
];


boot.kernelModules = ["kvm-intel"];
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

networking.firewall.allowedTCPPortRanges = [ { from = 8443; to = 8443; }  ];

time.timeZone = "Europe/Sofia";

virtualisation.docker.enable = true;

hardware.bluetooth.enable = true;
hardware.pulseaudio.enable = true;
hardware.pulseaudio.support32Bit = true;

hardware.opengl.driSupport32Bit = true;

nixpkgs.config.allowUnfree = true;  
programs.adb.enable = true;
programs.gnupg.agent.enable = true;

environment.variables._JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd";
environment.variables._JAVA_AWT_WM_NONREPARENTING="1";
environment.systemPackages = with pkgs; [

(import ./vim.nix)
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
vim
flameshot
];




services.upower.enable = true;
services.blueman.enable = true;
services.xserver = {


enable=true;


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
 
 displayManager.defaultSession ="none+xmonad";

 displayManager.gdm = { 
   wayland = false;
   enable = true;
  };
 displayManager.sessionCommands =  ''
        
       xsetroot -solid black
       xset r rate 350 50 
           
       xrdb "${pkgs.writeText  "xrdb.conf" ''
       

       XTerm*faceName:             xft:Dejavu Sans Mono for Powerline:size=9
       XTerm*utf8:                 2

       
       XTerm*background:           #000000 
       XTerm*foreground:           #ffffff 
               

       Xft*antialias:              true
       Xft*hinting:                full  
       Xft.antialias: 1
       Xft.autohint: 1
       Xft.hintstyle: hintslight 
       ''}"
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
      plugins = [ "git" "colored-man-pages" "command-not-found" "extract" "nix" ];
      customPkgs = with pkgs;[
        spaceship-prompt
        nix-zsh-completions
      ];
      theme = "spaceship";
    };
  };


users.defaultUserShell = pkgs.zsh;


users.extraUsers.bobby = {
createHome=true;
extraGroups  = ["wheel" "docker" "video" "audio" "disk" "networkmanager" "adbusers"];
group = "users";
home  ="/home/bobby";
isNormalUser = true;
uid = 1000;
}; 


  system.stateVersion = "20.09"; 

}

