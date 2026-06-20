{
  description = "komar's blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = import inputs.systems;
        perSystem =
          { pkgs, ... }:
          let
            treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

            apolloTheme = pkgs.fetchFromGitHub {
              owner = "not-matthias";
              repo = "apollo";
              rev = "d78aa62f29edfeabbdc353c313fbb8af6a54d2c1";
              hash = "sha256-1CcpnPbgE+Q+1O7SbrnXUENqZ5glj1woiVA7Jg1CRdI=";
            };
            src = pkgs.symlinkJoin {
              name = "src";
              paths = [
                ./.
                (pkgs.linkFarm "theme" [
                  {
                    name = "themes/apollo";
                    path = apolloTheme;
                  }
                ])
              ];
            };
          in
          {
            packages.default = pkgs.stdenvNoCC.mkDerivation {
              inherit src;
              pname = "blog";
              version = "1.0.0";

              nativeBuildInputs = [ pkgs.zola ];

              buildPhase = ''
                shopt -s nullglob extglob
                mkdir out && cd out
                cp -Lr ../!(out) .
                chmod +w . -R
                zola build
              '';

              installPhase = ''
                mkdir -p $out
                cp -r public/* $out/
              '';
            };
            formatter = treefmtEval.config.build.wrapper;
            checks = {
              formatting = treefmtEval.config.build.check self;
              typos = pkgs.runCommand "typos-check" {
                nativeBuildInputs = [ pkgs.typos ];
              } "cd ${self} && typos . && touch $out";
            };
          };
      }
    );
}
