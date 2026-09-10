registerShortcut("Show/Hide Telegram", "Toggle visibility of the Telegram window", "Meta+F1", function () {
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
            if (id == "TelegramDesktop") {
              callDBus(
                service,
                "/StatusNotifierItem",
                "org.kde.StatusNotifierItem",
                "Activate",
                0,
                0,
                function () {},
              );
            }
          },
        );
      }
    },
  );

  const clients = workspace.stackingOrder;
  for (var i = 0; i < clients.length; i++) {
    if (clients[i].resourceClass == "org.telegram.desktop") {
      workspace.raiseWindow(clients[i]);
    }
  }
});
