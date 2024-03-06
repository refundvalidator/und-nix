{ pkgs, lib, buildGoModule, fetchFromGithub, version, vendorHash, hash }:

buildGoModule rec {
  inherit version vendorHash;
  pname = "und";
  name = pname;

  src = pkgs.fetchFromGitHub {
    owner = "unification-com";
    repo = "mainchain";
    rev = "v${version}";
    inherit hash;
  };
  buildPhase = ''
  go build \
  -ldflags=" \
  -X github.com/cosmos/cosmos-sdk/version.Version=${version} \
  -X github.com/cosmos/cosmos-sdk/version.Name=UndMainchain
  -X github.com/cosmos/cosmos-sdk/version.AppName=und" \
  -o $out/bin/und ./cmd/und
  '';
}
