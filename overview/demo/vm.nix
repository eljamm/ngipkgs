{
  lib,
  sources,
  config,
  ...
}:
{
  imports = [
    (sources.inputs.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
    (sources.inputs.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
  ];

  services.getty.helpLine = ''

    Welcome to NGIpkgs!
  '';

  system.stateVersion = "25.05";

  # --- users --- #

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  users.users.root = {
    initialPassword = "root";
  };

  # --- services --- #

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "nixos";

  services.openssh = {
    enable = true;
    ports = [
      10022
    ];
    settings = {
      PasswordAuthentication = true;
      PermitEmptyPasswords = "yes";
      PermitRootLogin = "yes";
    };
  };

  networking.firewall.enable = false;

  # --- virtualisation --- #

  virtualisation = {
    memorySize = 4096;
    cores = 4;
    graphics = false;

    qemu.options = [
      "-cpu host"
      "-enable-kvm"
    ];

    # ssh + open service ports
    forwardPorts = map (port: {
      from = "host";
      guest.port = port;
      host.port = port;
      proto = "tcp";
    }) config.networking.firewall.allowedTCPPorts;
  };
}
