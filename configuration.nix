# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, super, ... }:

let
  fromNixpkgsCommit = commit: fetchTarball ("https://github.com/NixOS/nixpkgs/archive/" + commit + ".tar.gz");
  unstable = import (fromNixpkgsCommit "8331390c3a6054067331cea440c772ae5029eb6f") {};
  # Export this package set as a channel so I can do nix-shell -p hello '<unstable>'

  config.nixpkgs.config = {
    pacakgeOverrides = pkgs: rec {
      unstableChan = unstable;
    };
  };

  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };

  dotfiles = builtins.fetchGit {
    url = "https://github.com/Lurkki14/dotfiles";
    ref = "master";
    rev = "8bec4710926729c78464abc562f7cc76a1424cf3";
  };

  openrgb-rules = builtins.fetchurl {
    url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/raw/master/60-openrgb.rules";
  };

  linux-tkg = builtins.fetchGit {
    url = "https://github.com/Frogging-Family/linux-tkg";
    rev = "dd7f86d87b14d04105296259805bf68a5c947a39";
    ref = "master";
  };

  /*tkg-kernel = super.linuxManualConfig {
    inherit (super) stdenv hostPlatform;
    inherit (super.linux_5_4) src;
    version = "${super.linux_5_4.version}-tkg";

    configfile = "${linux-tkg}/linux-tkg-config/5.4/config.x86_64";
    allowImportFromDerivation = true;
  };*/
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];
  
  nixpkgs.overlays = [
    (self: super: {
      linux-tkg = super.linuxManualConfig {
        inherit (super) stdenv /*hostPlatform*/;
        inherit (super.linux_5_4) src;
        version = "${super.linux_5_4.version}-tkg";

        configfile = "${linux-tkg}/linux-tkg-config/5.4/config.x86_64";
        allowImportFromDerivation = true;
      };
    })
  ];
  #boot.kernelPackages = pkgs.linux-tkg;

  #nix = {
    #package = pkgs.nixFlakes;
    #extraOptions = ''
      #experimental-features = nix-command flakes
    #'';
  #};
  #boot.kernelPatches = [ {
    #name = "linux-tkg";
    #patch = null;
    #extraConfig = "LOCKUP_DETECTOR y";
    #patch = builtins.readFile "${linux-tkg}/linux-tkg-patches/5.4/0004-5.4-ck1.patch";
    #extraConfig = builtins.readFile "${linux-tkg}/linux-tkg-config/5.4/config.x86_64";
  #} ];

  environment.variables = {
    # nixpkgs.config.allowUnfree = true; doesn't seem to export this
    NIXPKGS_ALLOW_UNFREE = "1";
    # original: \n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\]
    #PS1 = "\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\]";
  };

  # Native steam
  # nixpkgs.config.allowBroken = true;
  
  home-manager.users.jussi = {
    xdg.configFile."nvim/coc-settings.json".source = "${dotfiles}/coc-settings.json";
  };

  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
    "snd_aloop"
  ];
  #services.udev.extraRules = builtins.readFile openrgb-rules;

  environment.systemPackages = with pkgs; [
    # Misc programs
    filelight gimp kcalc libreoffice mumble earlyoom dfeet nix-index firefox keepassxc wireshark vlc
    gwenview kdeApplications.kdeconnect-kde
    tmux
    glxinfo qutebrowser 
    unstable.openrgb sgtpuzzles obs-studio pavucontrol
    # Development
    git gdb cabal2nix cabal-install nodejs # For coc-nvim
    android-studio gcc manpages
    # ghc from unstable so it's in sync with HLS
    unstable.ghc unstable.nix-bundle
    unstable.haskellPackages.haskell-language-server clang-tools
    unstable.rnix-lsp
    (neovim.override {
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
	  # Seems vim-nix includes filetype detection
          start = [ coc-nvim nerdtree gruvbox vim-nix nerdcommenter ];
          opt = [];
        };
        customRC = ''
          "
          function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
          endfunction

          inoremap <silent><expr> <Tab>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()
          autocmd Filetype haskell setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
	  set mouse=a
	  colorscheme gruvbox
	  " Make cuts go to black hole since cutting is rarer than deletion
	  nnoremap d "_d
	  vnoremap d "_d
          "
        '';
      };
     })
   ];

  programs.tmux.extraConfig = ''set -g mouse on'';
  programs.wireshark.enable = true;

  nixpkgs.config.allowUnfree = true;
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.earlyoom.enable = true;
  services.flatpak.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  #hardware.pulseaudio.extraConfig = "load-module module-echo-cancel";

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jussi = {
    isNormalUser = true;
    home = "/home/jussi";
    extraGroups = [ "wheel" "networkmanager" "wireshark" ]; # Enable ‘sudo’ for the user.
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

