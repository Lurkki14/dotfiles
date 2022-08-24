pinnedCommit="6c6409e965a6c883677be7b9d87a95fab6c3472e"
nixpkgsUrlFromCommit="https://github.com/NixOS/nixpkgs/archive/$pinnedCommit.tar.gz"


NIX_PATH="nixpkgs=$nixpkgsUrlFromCommit" sudo -E nixos-rebuild switch -I nixos-config=configuration.nix
