{
  description = "flutter_zig_bridge - Flutter + Zig FFI bridge";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Zig toolchain
            zig
            zls

            # Dart / Flutter
            flutter
            dart

            # Useful for development
            nixpkgs-fmt
          ];

          shellHook = ''
            echo "🔧 flutter_zig_bridge dev shell"
            echo "   Flutter: $(flutter --version 2>/dev/null | head -1)"
            echo "   Zig:     $(zig version 2>/dev/null)"
            echo ""
          '';
        };
      }
    );
}
