{
  description = "email-newsletter dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python312
            uv

            postgresql
            libpq

            gnumake
            direnv
            nil
            nixd
          ];

          shellHook = ''
            export PYTHONDONTWRITEBYTECODE=1
            export UV_PYTHON_DOWNLOADS=never
            export PGHOST="''${PGHOST:-localhost}"
            export PGPORT="''${PGPORT:-5432}"
            export PGUSER="''${PGUSER:-postgres}"
            export PGPASSWORD="''${PGPASSWORD:-postgres}"
            export PGDATABASE="''${PGDATABASE:-dzesen_news}"

            uv sync --frozen --extra dev --python "$(command -v python)"
            source .venv/bin/activate

            echo "Dev shell ready: Python $(python --version | awk '{print $2}')"
            echo "Dependencies synced with uv"
          '';
        };
      }
    );
}
