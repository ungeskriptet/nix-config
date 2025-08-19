{
  pmbootstrap-git,
  pmbootstrap,
}:
pmbootstrap.overrideAttrs (prev: {
  pname = "pmbootstrap-git";
  src = pmbootstrap-git;
})
