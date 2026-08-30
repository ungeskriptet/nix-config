{
  alias = {
    # keep-sorted start
    "a" = "add";
    "aa" = "add -A";
    "ae" = "commit --amend -s";
    "ane" = "commit --amend --no-edit -s";
    "ap" = "add -p";
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
    "pu" = "pull";
    "pucb" = "pull cb";
    "pugh" = "pull gh";
    "r" = "remote -v";
    "re" = "restore";
    "rea" = "rebase --abort";
    "rec" = "rebase --continue";
    "rep" = "restore -p";
    "res" = "restore --staged";
    "rev" = "revert";
    "rh" = "reset --hard";
    "ri" = "rebase --autosquash -i";
    "rrm" = "remote remove";
    "rs" = "reset";
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
      pushInsteadOf = [
        "https://github.com/"
        "gh:"
        "github:"
      ];
    };
    "ssh://git@codeberg.org/" = {
      pushInsteadOf = [
        "https://codeberg.org/"
        "cb:"
        "codeberg:"
      ];
    };
    "https://github.com/" = {
      insteadOf = [
        "gh:"
        "github:"
      ];
    };
    "https://codeberg.org/" = {
      insteadOf = [
        "cb:"
        "codeberg:"
      ];
    };
  };
}
