{
  description = "Flops";

  inputs.std.follows = "std-ext/std";
  inputs.nixpkgs.follows = "std-ext/nixpkgs";
  inputs.std-ext.url = "github:gtrunsec/std-ext";
  inputs.call-flake.url = "github:divnix/call-flake";
  inputs.namaka.follows = "";

  outputs =
    { std, ... }@inputs:
    let
      main = inputs.call-flake ../.;
    in
    std.growOn
      {
        inherit inputs;
        cellsFrom = ./cells;
        cellBlocks = with std.blockTypes; [
          # Development Environments
          (nixago "configs")
          (devshells "devshells")
        ];
      }
      {
        devShells = std.harvest inputs.self [ [
          "repo"
          "devshells"
        ] ];
      }
      {
        checks = inputs.namaka.lib.load {
          src = ../tests;
          inputs = main.lib // {
            inherit (main) inputs;
            lib = main.inputs.nixlib.lib // main.lib;
          };
        };
      };
}
