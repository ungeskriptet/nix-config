{
  init = {
    defaultBranch = "master";
  };
  url = {
    "ssh://git@github.com/" = {
      insteadOf = [
        "gh:"
        "github:"
      ];
      pushInsteadOf = [ "https://github.com/" ];
    };
    "ssh://git@codeberg.org/" = {
      insteadOf = [
        "cb:"
        "codeberg:"
      ];
      pushInsteadOf = [ "https://codeberg.org/" ];
    };
  };
}
