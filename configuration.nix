# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  fromNixpkgsCommit = commit: fetchTarball ("https://github.com/NixOS/nixpkgs/archive/" + commit + ".tar.gz");
  unstable = import (fromNixpkgsCommit "ea3638a3fb262d3634be7e4c2aa3d4e9474ae157") {};

  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };

  dotfiles = builtins.fetchGit {
    url = "https://github.com/Lurkki14/dotfiles";
    ref = "master";
    rev = "d31bd69538c1bc8e12057736864ff0c3f9edbed5";
  };

  openrgb-rules = builtins.fetchurl {
    url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/raw/master/60-openrgb.rules";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  #environment.variables = {
    # original: \n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\]
    #PS1 = "\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\]";
  #};

  # Native steam
  # nixpkgs.config.allowBroken = true;

  home-manager.users.jussi = {
    xdg.configFile."nvim/coc-settings.json".source = "${dotfiles}/coc-settings.json";
  };

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
  #services.udev.extraRules = builtins.readFile openrgb-rules;

  environment.systemPackages = with pkgs; [
    # Misc programs
    filelight gimp kcalc libreoffice mumble earlyoom dfeet nix-index firefox keepassxc wireshark vlc tmux
    gwenview
    #(tmux.override {
      #extraTmuxConf = ''
        #set -g mouse=on
      #'';
    #})
    glxinfo qutebrowser 
    unstable.openrgb
    #steam
    #(steam.override { extraPkgs = pkgs: [ glxinfo xorg.libxcb ]; })
    # Development
    git gdb cabal2nix cabal-install nodejs # For coc-nvim
    android-studio
    # ghc from unstable so it's in sync with HLS
    unstable.ghc unstable.nix-bundle
    #ghc
    unstable.haskellPackages.haskell-language-server
    #(unstable.haskellPackages.haskell-language-server.overrideAttrs (defAttrs: {
      #buildInputs = defAttrs.buildInputs ++ [ ghc ];
    #}))
    unstable.rnix-lsp
    (neovim.override {
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
	  # Seems vim-nix includes filetype detection
          start = [ coc-nvim nerdtree gruvbox vim-nix ];
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

  #programs.steam.enable = true;
  programs.wireshark.enable = true;

  nixpkgs.config.allowUnfree = true;
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  #   firefox
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

