{ ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
        email = "domenic2610@gmail.com";
        name = "Saya Isumo";
    };
    signing = {
      format = "openpgp";
      key = "799340FC3855150308B8D8F601E61C9FEC92424D";
      signByDefault = true;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
