{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  python3-with-pkgs = python3.withPackages (python-pkgs: with python-pkgs; [
    ansible-core # 2.12
  ]);
in stdenv.mkDerivation {
  name = "nspawn-pool-env";
  buildInputs = [
    bash_5
    gnumake
    python3-with-pkgs
  ];
}
