{ ... }:
{
  services.mox.enable = true;
  services.mox.hostname = "mail";
  services.mox.user = "admin@example.ke";
  services.mox.configFile = "${./test/mox-default.conf}";
}
