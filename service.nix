{ lib, pkgs, config, und, cosmovisor, self, ... }:
with lib;                      
let
  cfg = config.services.und;
  config-toml = (builtins.fromTOML (builtins.readFile "${self}/config.toml"));
  app-toml = (builtins.fromTOML (builtins.readFile "${self}/app.toml"));
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
    # config = mkOption {
    #   type = types.attrsOf config-toml;
    #   default = config-toml;
    # };
    # app = mkOption {
    #   type = types.attrsof app-toml; 
    #   default = app-toml;
    # };
  };

  # systemd.tmpfiles.rules =  mkIf (if cfg.daemonHome == "" then false else true) [
  #   "d ${cfg.daemonHome} 0777 root root -" #The - disables automatic cleanup, so the file wont be removed after a period
  #   "d ${cfg.daemonHome}/config 0777 root root -" #The - disables automatic cleanup, so the file wont be removed after a period
  #   "d ${cfg.daemonHome}/config/app.toml 0777 root root -" #The - disables automatic cleanup, so the file wont be removed after a period
  # ];
  
  config = mkIf cfg.enable {
    systemd.services.und = {
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
        ExecStart = "${cosmovisor}/bin/cosmovisor run start --home ${cfg.daemonHome}";
      };
    };
  };
}
