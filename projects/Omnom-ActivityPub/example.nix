{...}: {
  services.omnom = {
    enable = true;
    debug = true;

    user = "testUser"; # normal user
    group = "omnom";

    settings = {
      app = {
        disable_signup = true; # restrict CLI user-creation
        results_per_page = 50;
      };
      server = {
        address = "127.0.0.1:8080";
      };
    };

    openFirewall = true;
    port = 8080;
  };
}
