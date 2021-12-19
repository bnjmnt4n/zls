{ pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem }:

let
  zig-overlay = pkgs.fetchFromGitHub {
    owner = "arqv";
    repo = "zig-overlay";
    rev = "bc724f348d049f9b77aea08626b213a967d696ff";
    sha256 = "sha256-Wk2Rh2Ea1CsYKs0VKu9qGw+ntRyDNUSk9LOxQJSZfIo=";
  };
  gitignoreSrc = pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore";
    rev = "c4662e662462e7bf3c2a968483478a665d00e717";
    sha256 = "1npnx0h6bd0d7ql93ka7azhj40zgjp815fw2r6smg8ch9p7mzdlx";
  };
  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreSource;
  zig = (import zig-overlay { inherit pkgs system; }).master.latest;
in
pkgs.stdenvNoCC.mkDerivation {
  name = "zls";
  version = "master";
  src = gitignoreSource ./.;
  nativeBuildInputs = [ zig ];
  dontConfigure = true;
  dontInstall = true;
  buildPhase = ''
    mkdir -p $out
    zig build install -Drelease-safe=true -Ddata_version=master --prefix $out
  '';
  XDG_CACHE_HOME = ".cache";
}
