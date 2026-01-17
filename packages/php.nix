{ pkgs }:

pkgs.php83.buildEnv {
  extensions = { enabled, all, }: enabled ++ (with all; [
    redis
    # xdebug
  ]);

  # extraConfig = ''
  #   xdebug.mode=debug
  # '';
}
