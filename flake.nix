{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      inherit (nixpkgs.lib) fakeHash genAttrs;
      forAllSystems = function:
        genAttrs [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system:
          function (import nixpkgs {
            inherit system;
          }));

      packages = forAllSystems (pkgs: rec {
        default = und-182;
        und-190 = pkgs.callPackage ./und.nix {
          version = "1.9.0";
          hash = "sha256-mZelNV4BO8DNtshVFxXStMqM+/dWaeB5Y3fhPAuxOcw=";
          vendorHash = "sha256-4BUV2IFMh6xeFI5CTSyAlR6w1h0BcCHvOKoQ0Wn60RI=";
        };
        und-182 = pkgs.callPackage ./und.nix {
          version = "1.8.2";
          hash = "sha256-0JRDIzVaB+869u1VKPTgcobtvCcW8pPh3P7zoqTVcy8=";
          vendorHash = "sha256-rtpc3FhLXJ4EcIHay7ukWW3T3MpQsrAxGi8KUU8O9+E=";
        };
        und-163 = pkgs.callPackage ./und.nix {
          version = "1.6.3";
          hash = "sha256-g7wSQXxBbBW33qaKAKrQbg4txsAfSuQgVd8Kpse8q00=";
          vendorHash = "sha256-wMblC5yhtHC1surrZZDvfnHDR/7GPcOkY6d1X8ZeTwo=";
        };
        und-151 = pkgs.callPackage ./und.nix {
          version = "1.5.1";
          hash = "sha256-eHm8tZAjn07crTCHKVM1PFRbaaPf6c1gdhkgejxsgc0=";
          vendorHash = "sha256-rSd6m7oXwHr0t2C717M690QPutAhpnwUHsGvne1zF88=";
        };
        cosmovisor = pkgs.callPackage ./cosmovisor.nix { } ;
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
