{
  pmbootstrap-git,
  pmbootstrap,
}:
pmbootstrap.overrideAttrs (prev: {
  pname = "pmbootstrap-git";
  version = "3.6.0";
  src = pmbootstrap-git;
})
