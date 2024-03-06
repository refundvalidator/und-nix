{ pkgs, lib, buildGoModule, fetchFromGithub, version ? "1.5.0" }:

buildGoModule rec {
  inherit version;
  pname = "cosmovisor-${version}";
  name = pname;

  src = pkgs.fetchFromGitHub {
    owner = "cosmos";
    repo = "cosmos-sdk";
    rev = "cosmovisor/v${version}";
    hash = "sha256-Ov8FGpDOcsqmFLT2s/ubjmTXj17sQjBWRAdxlJ6DNEY=";
  };
  modRoot = "./tools/cosmovisor/cmd/cosmovisor";
  proxyVendor = true;
  vendorHash = "sha256-q5iBx/tU/ftMVYbQ+0E5qjGYua6ZuJSlx13zIiYa2wE=";

  buildPhase = ''
  mkdir -p $out/bin
  go build -o $out/bin/cosmovisor-${version} .
  '';
}
