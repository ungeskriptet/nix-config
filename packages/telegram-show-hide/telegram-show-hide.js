registerShortcut("Show/Hide Telegram", "Toggle visibility of the Telegram window", "Meta+F1", function () {
  const clients = workspace.stackingOrder;
  for (var i = 0; i < clients.length; i++) {
    if (clients[i].resourceClass == "org.telegram.desktop") {
      clients[i].closeWindow();
      return;
    }
  }

  callDBus(
    "org.telegram.desktop",
    "/org/telegram/desktop",
    "org.freedesktop.Application",
    "Activate",
    {},
    function () {},
  );
});
