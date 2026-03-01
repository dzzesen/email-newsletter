{
  description = "dzesen_news dev environment (Django + django-vtasks + Postgres)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python312;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            py
            py.pkgs.pip
            py.pkgs.virtualenv
            py.pkgs.psycopg
            py.pkgs.ruff

            postgresql
            libpq

            gnumake
            direnv
            nil
            nixd
          ];

          shellHook = ''
            export PIP_DISABLE_PIP_VERSION_CHECK=1
            export PYTHONDONTWRITEBYTECODE=1
            export PGHOST="''${PGHOST:-localhost}"
            export PGPORT="''${PGPORT:-5432}"
            export PGUSER="''${PGUSER:-postgres}"
            export PGPASSWORD="''${PGPASSWORD:-postgres}"
            export PGDATABASE="''${PGDATABASE:-dzesen_news}"

            if [ ! -d .venv ]; then
              python -m venv .venv
            fi
            source .venv/bin/activate

            echo "Dev shell ready: Python $(python --version | awk '{print $2}')"
            echo "Run: pip install -U pip && pip install django django-vtasks perplexity"
          '';
        };
      });
}
