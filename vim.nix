with import <nixpkgs> {};



vim_configurable.customize {

    name = "vim";

      vimrcConfig.customRC = ''
        syntax on
        filetype on
        colorscheme solarized
      '';

      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [
        { 
        names = [
          "colors-solarized"
          "fzf-vim"
          "fzfWrapper"
          "vim-addon-nix"
        ];
        }
       { names = [ "vim-addon-nix" ]; ft_regex = "^nix\$"; }
      ];


}    
