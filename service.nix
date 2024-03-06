{ lib, pkgs, config, und, cosmovisor, packages, self, ... }:
with lib;                      
let
  cfg = config.services.und;
  settingsFormat = pkgs.formats.toml { };
  initConfig = modules.importTOML "${self}/configs/config.toml";
  initApp = modules.importTOML "${self}/configs/app.toml";
  configFile = format.generate "config.toml" cfg.config;
  appFile = format.generate "app.toml" cfg.app;
in {
  options.services.und = {
    enable = mkEnableOption "Enable the UND service";
    version = mkOption {
      type = types.str;
      default = "1.8.2";
    };
    upgradeVersion = mkOption {
      type = types.str;
      default = "";
    };
    upgradeName = mkOption {
      type = types.str;
      default = "";
    };
    daemonHome = mkOption {
      type = types.str; 
      default = "";
    };
    daemonRestartAfterUpgrade = mkOption {
      type = types.bool;
      default = true;
    };
    daemonRestartDelay = mkOption {
      type = types.int; 
      default = 5;
    };
    unsafeSkipBackup = mkOption {
      type = types.bool;
      default = false;
    };
    config = mkOption {
      inherit (settingsFormat) type;
      default = initConfig;
    };
    app = mkOption {
      inherit (settingsFormat) type;
      default = initApp;
    };
  };
  environment.etc."${cfg.daemonHome}/config/config.toml".source = configFile; 
  environment.etc."${cfg.daemonHome}/config/app.toml".source = appFile; 
  config = mkIf cfg.enable {
    systemd.user.services.und = {
      description="Unification Mainchain Node";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Restart="always";
        RestartSec="10s";
        Environment = [
          "DAEMON_NAME=und"
          "DAEMON_HOME=${cfg.daemonHome}"
          "DAEMON_RESTART_AFTER_UPGRADE=${cfg.daemonRestartAfterUpgrade}"
          "DAEMON_RESTART_DELAY=${cfg.RestartDelay}s"
          "UNSAFE_SKIP_BACKUP=${cfg.unsafeSkipBackup}"
        ];
        LimitNOFILE=4096;
        ExecStartPre = ''
          if ! test -d "${cfg.daemonHome}; then
            ${packages.und}/bin/und init --home ${cfg.daemonHome};
          fi
          if ! test -d "${cfg.daemonHome}/cosmovisor/current"; then
            ln -s ${packages.und}/bin/und ${cfg.daemonHome}/cosmovisor/current
          fi
        '';
        ExecStart = "${cosmovisor}/bin/cosmovisor run start --home ${cfg.daemonHome}";
      };
    };
  };
}
