{
  alias = {
    "a" = "add -A";
    "ae" = "commit --amend -s";
    "ane" = "commit --amend --no-edit -s";
    "c" = "commit -s";
    "cm" = "commit -sm";
    "d" = "diff";
    "l" = "log";
    "r" = "remote -v";
    "rrm" = "remote remove";
    "sh" = "show";
    "s" = "status";
  };
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
