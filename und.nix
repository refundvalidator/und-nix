{ pkgs, lib, buildGoModule, fetchFromGithub, version ? "1.8.2" }:

buildGoModule rec {
  inherit version;
  pname = "und";
  name = pname;

  src = pkgs.fetchFromGitHub {
    owner = "unification-com";
    repo = "mainchain";
    rev = "v${version}";
    hash = "sha256-0JRDIzVaB+869u1VKPTgcobtvCcW8pPh3P7zoqTVcy8=";
  };
  vendorHash = "sha256-rtpc3FhLXJ4EcIHay7ukWW3T3MpQsrAxGi8KUU8O9+E=";
  buildPhase = ''
  go build \
  -ldflags=" \
  -X github.com/cosmos/cosmos-sdk/version.Version=${version} \
  -X github.com/cosmos/cosmos-sdk/version.Name=UndMainchain
  -X github.com/cosmos/cosmos-sdk/version.AppName=und" \
  -o $out/bin/und ./cmd/und
  '';
}
