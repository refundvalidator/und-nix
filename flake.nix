{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system:
          function (import nixpkgs {
            inherit system;
          }));
    in {
    packages = forAllSystems (pkgs: rec {
      und = pkgs.callPackage ./und.nix { version = "1.5.1"; } ;
      cosmovisor = pkgs.callPackage ./cosmovisor.nix { } ;
      default = und;
    });
  };
}
