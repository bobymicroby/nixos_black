
{ config, pkgs, ... }:

{
imports =
  [ 
    ./hardware-configuration.nix
];

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.initrd.luks.devices = [
 {
  name = "root";
  device = "/dev/nvme0n1p6";
  preLVM = true;
 }
];
   
networking.networkmanager.enable = true;
networking.hostName = "black-nixos";

networking.firewall.allowedTCPPortRanges = [];

time.timeZone = "Europe/Sofia";

virtualisation.docker.enable = true;


hardware.pulseaudio.enable = true;
hardware.pulseaudio.support32Bit = true;

hardware.opengl.driSupport32Bit = true;

nixpkgs.config.allowUnfree = true;  

programs.adb.enable = true;

environment.variables._JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd";
environment.systemPackages = with pkgs; [


(pkgs.vim_configurable.customize {
      name = "vim";
      vimrcConfig.vam.pluginDictionaries = [
        # vim-nix handles indentation better but does not perform sanity
        { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
];
})

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
google-chrome
dzen2
conky
];




services.upower.enable = true;

services.xserver = {

layout = "us,bg(phonetic)";
xkbOptions = "grp:lwin_toggle";


enable=true;

autoRepeatDelay = 300;
autoRepeatInterval = 50;

displayManager = {

slim = {

defaultUser = "bobby";
enable = true;

};

};

videoDrivers = [ "nvidia" ];
dpi = 150;


monitorSection = ''
      DisplaySize 401 171
    '';

screenSection = ''
    Option "DPI" "150 x 150"
    '';
        
 windowManager = {
    xmonad.enable = true;
    xmonad.extraPackages = hpkgs: [
      hpkgs.taffybar
      hpkgs.xmonad-contrib
      hpkgs.xmonad-extras
    ];
    default = "xmonad";
  };    
displayManager.sessionCommands =  ''
       xset r rate 350 50 
           
       xrdb "${pkgs.writeText  "xrdb.conf" ''
       

       XTerm*faceName:             xft:Dejavu Sans Mono for Powerline:size=11
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

programs.zsh = {
  shellAliases = {
  ff = "firefox &>/dev/null &";
  };  
  enable = true;
  ohMyZsh.enable = true;
  ohMyZsh.plugins = [ "git"];
  ohMyZsh.theme = "robbyrussell";  
  syntaxHighlighting.enable = true;
};

users.defaultUserShell = pkgs.zsh;


users.extraUsers.bobby = {
createHome=true;
extraGroups  = ["wheel" "docker" "video" "audio" "disk" "networkmanager"];
group = "users";
home  ="/home/bobby";
isNormalUser = true;
uid = 1000;
}; 


  system.stateVersion = "19.09"; 

}
