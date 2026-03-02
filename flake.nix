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
        postgres = pkgs.postgresql_16;
      in
      {
        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.libpq ];
          packages = with pkgs; [
            python312
            uv
            postgres
            libpq
            gnumake
            direnv
            nil
            nixd
            nixfmt

            (writeShellScriptBin "pg-init" ''
              initdb --auth=trust --no-locale --encoding=UTF8
            '')
            (writeShellScriptBin "pg-start" ''
              pg_ctl start -l "$PGDATA/postgresql.log" -o "-k $PGDATA -p $PGPORT" -w
            '')
            (writeShellScriptBin "pg-stop" ''
              pg_ctl stop -m fast
            '')
            (writeShellScriptBin "pg-status" ''
              pg_ctl status
            '')
            (writeShellScriptBin "pg-log" ''
              tail -f "$PGDATA/postgresql.log"
            '')
            (writeShellScriptBin "pg-connect" ''
              psql
            '')
            (writeShellScriptBin "pg-createuser" ''
              createuser -h "$PGDATA" -U "$(id -un)" --superuser "$PGUSER"
            '')
            (writeShellScriptBin "pg-createdb" ''
              createdb -h "$PGDATA" -O "$PGUSER" "$PGDATABASE"
            '')
          ];
          shellHook = ''
            if [ -f .env ]; then
                echo "Loading environment variables from .env"
                set -a; source .env; set +a
            fi

            export PYTHONDONTWRITEBYTECODE=1
            export UV_PYTHON_DOWNLOADS=never
            export PGDATA="$PWD/.pgdata"
            export PGHOST="$PGDATA"
            export PGPORT=''${PGPORT:-5432}
            export PGUSER=''${PGUSER:-postgres}
            export PGDATABASE=''${PGDATABASE:-email_newsletter}

            uv sync --frozen --extra dev --python "$(command -v python)"
            source .venv/bin/activate

            if [ ! -d "$PGDATA" ]; then
                echo "First time PostgreSQL setup: pg-init && pg-start && pg-createuser && pg-createdb"
            fi
            echo "PostgreSQL commands: pg-init, pg-start, pg-createuser, pg-createdb, pg-stop, pg-status, pg-log, pg-connect"
            echo "Dev shell ready [$(python --version); $(${postgres}/bin/postgres --version)]"
          '';
        };
      }
    );
}
