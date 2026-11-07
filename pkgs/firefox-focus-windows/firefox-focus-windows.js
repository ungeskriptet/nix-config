registerShortcut("Focus Firefox", "Focus all Firefox windows", "Meta+F2", function () {
  workspace.windowList().forEach((w) => {
    if (w.resourceClass == "firefox") {
      workspace.activeWindow = w;
    }
  });
});
