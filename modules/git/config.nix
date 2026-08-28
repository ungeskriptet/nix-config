{
  alias = {
    # keep-sorted start
    "a" = "add";
    "aa" = "add -A";
    "ae" = "commit --amend -s";
    "ane" = "commit --amend --no-edit -s";
    "bd" = "branch -D";
    "bm" = "branch -m";
    "c" = "commit -s";
    "cf" = "commit --fixup";
    "ch" = "checkout";
    "cm" = "commit -sm";
    "d" = "diff";
    "ds" = "diff --staged";
    "f" = "fetch";
    "l" = "log";
    "p" = "push";
    "pcb" = "push cb";
    "pgh" = "push gh";
    "pom" = "pull origin master";
    "r" = "remote -v";
    "ri" = "rebase --autosquash -i";
    "rrm" = "remote remove";
    "s" = "status";
    "sc" = "switch -c";
    "sh" = "show";
    # keep-sorted end
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
