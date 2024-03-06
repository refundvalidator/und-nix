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
      packages = forAllSystems (pkgs: rec {
        und = pkgs.callPackage ./und.nix { version = "1.5.1"; } ;
        cosmovisor = pkgs.callPackage ./cosmovisor.nix { } ;
        default = und;
      });
    in {
    inherit packages;
    nixosModules.default = forAllSystems (pkgs: rec {
      default = import ./service.nix { inherit (packages.${pkgs.system}) cosmovisor und; inherit self; };
    });
    homeManagerModules.default = forAllSystems (pkgs: rec {
      default = import ./service.nix { inherit (packages.${pkgs.system}) cosmovisor und; inherit self; };
    });
  };
}
