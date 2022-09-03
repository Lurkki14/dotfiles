# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, super, ... }:

let
  unstableCommit = "7527d53617486517f4a6ce8f252ef549139c9633";
  #unstableCommit = "c473cc8714710179df205b153f4e9fa007107ff9";
  unstableUrl = "https://github.com/NixOS/nixpkgs/archive/" + unstableCommit + ".tar.gz";
  unstableTarball = fetchTarball unstableUrl;
  unstable = (import unstableTarball) {};

  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };

  dotfiles = builtins.fetchGit {
    url = "https://github.com/Lurkki14/dotfiles";
    ref = "master";
    rev = "5173eb1f0c55299e4f31eaf681146d88533c68b3";
  };

  openrgb-rules = builtins.fetchurl {
    url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/raw/master/60-openrgb.rules";
  };

  /*linux-tkg = builtins.fetchGit {
    url = "https://github.com/Frogging-Family/linux-tkg";
    rev = "dd7f86d87b14d04105296259805bf68a5c947a39";
    ref = "master";
  };*/

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
  
  # Use the pinned nixpkgs in nix CLI commands
  nix.nixPath = [
    #"nixpkgs=${toString pkgs.path}"
    "nixpkgs=https://github.com/NixOS/nixpkgs/archive/6c6409e965a6c883677be7b9d87a95fab6c3472e.tar.gz"
  ];

  /*nixpkgs.overlays = [
    (self: super: {
      linux-tkg = super.linuxManualConfig {
        inherit (super) stdenv hostPlatform;
        inherit (super.linux_5_4) src;
        version = "${super.linux_5_4.version}-tkg";

        configfile = "${linux-tkg}/linux-tkg-config/5.4/config.x86_64";
        allowImportFromDerivation = true;
      };
    })
  ];*/
  #boot.kernelPackages = pkgs.linux-tkg;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

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
    #xdg.configFile."nvim/coc-settings.json".source = "${dotfiles}/coc-settings.json";
    xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
  };


  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
    "snd_aloop"
  ];

  boot.binfmt = {
    emulatedSystems = [ "aarch64-linux" ];
    #registrations = [ "x86_64-windows" ];
  };

  fileSystems."/home/jussi/HDD" = {
    #device = "/dev/sdb6";
    device = "/dev/disk/by-uuid/22f45770-d4e6-4ee7-8c8b-b578942105ee";
    #device = "22f45770-d4e6-4ee7-8c8b-b578942105ee";
    fsType = "btrfs";
  };

  #environment.etc."dbus-1/foo".text = "test";
  #environment.etc."dbus-1/system.d".text = (readFile "/home/jussi/ohj/tuxclocker/result/share/dbus-1/system.d/org.tuxclocker.conf");

  #services.udev.extraRules = builtins.readFile openrgb-rules;

  #services.dbus.packages = [ "/home/jussi/ohj/tuxclocker/result" ];

  #services.dbus.packages = [ "/home/jussi/ohj/tuxclocker/inst" ];

  environment.systemPackages = with pkgs; [
    # Needs libvirtd
    virt-manager
    # Misc programs
    unstable.firefox
    filelight gimp kcalc libreoffice mumble earlyoom dfeet nix-index keepassxc wireshark vlc
    gwenview libsForQt5.kdeconnect-kde partition-manager ark qdirstat
    # Qt Creator
    qtcreator cmake gnumake qt5.full
    tmux
    # notify-send
    libnotify
    glxinfo qutebrowser 
    openrgb sgtpuzzles obs-studio pavucontrol mpv
    # Development
    direnv
    #libsForQt5.full qtcreator gnumake
    git gdb cabal2nix cabal-install nodejs # For coc-nvim
    /*android-studio*/ gcc man-pages nix-prefetch-git ccache entr
    # ghc from so it's in sync with HLS
    ghc nix-bundle
    haskellPackages.haskell-language-server clang-tools
    rnix-lsp
    # For neovim clipboard
    xclip
    (neovim.override {
      configure = {
        packages.myPlugins = with vimPlugins; {
	  # Seems vim-nix includes filetype detection
          start = [ coc-nvim coc-java nerdtree gruvbox vim-nix nerdcommenter vim-qml /*auto-session*/ ];
          opt = [];
        };
        customRC = (builtins.readFile ./nvimrc);
      };
     })
   ];

  virtualisation.libvirtd.enable = true;

  programs.bash = {
    interactiveShellInit = ''eval "$(direnv hook bash)"'';
    shellAliases = {
      withUnstable = "NIX_PATH=nixpkgs=${unstableUrl}";
    };
  }; 
  programs.tmux.extraConfig = ''set -g mouse on'';
  programs.tmux.plugins = [ pkgs.tmuxPlugins.resurrect ];
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

  services.xserver.config = ''
    Section "Device"
      Driver "nvidia"
      Option "Coolbits" "31"
      Identifier "Device-nvidia[0]"
    EndSection
  '';
  #Option “RegistryDwords” “PowerMizerEnable=0x1; PerfLevelSrc=0x3333; PowerMizerDefault=0x3"

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 2;
  };

  zramSwap = {
    enable = true;
    numDevices = 1;
    memoryPercent = 70;
  };

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
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
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

