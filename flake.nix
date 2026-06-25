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
            lightbox = pkgs.buildNpmPackage {
              pname = "lightbox";
              version = "1.1.0";

              # Replace with your actual source or git repository
              src = pkgs.fetchFromGitHub {
                owner = "lokesh";
                repo = "lightbox3";
                rev = "v1.1.0";
                hash = "sha256-6sLGrk9evIhMPbyoK4PMAvQJkEJhqTAE00a3V+EeZoM=";
              };

              # Generate this by running 'npm install --package-lock-only'
              npmDepsHash = "sha256-RFVt0BY8cXl2RGgknCcVv2XgtglJOKk1ksW7kwBPZZs=";

              installPhase = ''
                mkdir -p $out
                cp -r dist/* $out/
              '';
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
                (pkgs.linkFarm "lightbox" [
                  {
                    name = "static/js/lightbox3.min.js";
                    path = "${lightbox}/lightbox3.min.js";
                  }
                  {
                    name = "static/js/lightbox3.css";
                    path = "${lightbox}/lightbox3.css";
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
            packages.gen-thumbs = pkgs.writeShellApplication {
              name = "gen-thumbs";
              runtimeInputs = [ pkgs.imagemagick ];
              text = builtins.readFile ./scripts/gen-thumbs.sh;
            };
            packages.serve = pkgs.writeShellApplication {
              name = "serve";
              runtimeInputs = [ pkgs.zola ];
              text = ''
                D=$(mktemp -d)
                cleanup() {
                  rm -fr "$D"
                }
                trap cleanup EXIT
                cp -Lr ${src}/* "$D"
                chmod +w "$D" -R
                zola -r "$D" serve
              '';
            };
          };
      }
    );
}
