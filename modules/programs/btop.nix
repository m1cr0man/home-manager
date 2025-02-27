{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.btop;

  finalConfig = let
    toKeyValue = generators.toKeyValue {
      mkKeyValue = generators.mkKeyValueDefault {
        mkValueString = v:
          with builtins;
          if isBool v then
            (if v then "True" else "False")
          else if isString v then
            ''"${v}"''
          else
            toString v;
      } " = ";
    };
  in ''
    ${toKeyValue cfg.settings}
    ${optionalString (cfg.extraConfig != "") cfg.extraConfig}
  '';

in {
  meta.maintainers = [ hm.maintainers.GaetanLepage ];

  options.programs.btop = {
    enable = mkEnableOption "btop";

    package = mkPackageOption pkgs "btop" { };

    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool float int str ]);
      default = { };
      example = {
        color_theme = "Default";
        theme_background = false;
      };
      description = ''
        Options to add to <filename>btop.conf</filename> file.
        See <link xlink:href="https://github.com/aristocratos/btop#configurability"/>
        for options.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra lines added to the <filename>btop.conf</filename> file.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."btop/btop.conf" =
      mkIf (cfg.settings != { }) { text = finalConfig; };
  };
}
