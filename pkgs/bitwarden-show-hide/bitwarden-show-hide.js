registerShortcut("Show/Hide Bitwarden", "Toggle visibility of the Bitwarden window", "Meta+F3", function () {
  const clients = workspace.stackingOrder;
  for (var i = 0; i < clients.length; i++) {
    if (clients[i].resourceClass == "bitwarden") {
      clients[i].closeWindow();
      return;
    }
  }
  callDBus(
    "org.kde.StatusNotifierWatcher",
    "/StatusNotifierWatcher",
    "org.freedesktop.DBus.Properties",
    "Get",
    "org.kde.StatusNotifierWatcher",
    "RegisteredStatusNotifierItems",
    function (systray) {
      for (var i = 0; i < systray.length; i++) {
        const service = systray[i].split("/")[0];
        callDBus(
          service,
          "/StatusNotifierItem",
          "org.freedesktop.DBus.Properties",
          "Get",
          "org.kde.StatusNotifierItem",
          "Id",
          function (id) {
            if (id == "Bitwarden_status_icon_1") {
              callDBus(
                service,
                "/StatusNotifierItem",
                "org.kde.StatusNotifierItem",
                "Activate",
                0,
                0,
                function () {
                  const clients = workspace.stackingOrder;
                  for (var i = 0; i < clients.length; i++) {
                    if (clients[i].resourceClass == "bitwarden") {
                      workspace.activeWindow = clients[i];
                    }
                  }
                },
              );
            }
          },
        );
      }
    },
  );
});
