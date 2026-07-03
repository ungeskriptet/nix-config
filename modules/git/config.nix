{
  alias = {
    "ae" = "commit --amend -s";
    "ane" = "commit --amend --no-edit -s";
    "r" = "remote -v";
    "rrm" = "remote remove";
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
