{
  # keep-sorted start block=yes
  "browser.aboutConfig.showWarning" = false;
  "browser.ctrlTab.sortByRecentlyUsed" = true;
  "browser.newtabpage.activity-stream.default.sites" = "";
  "browser.newtabpage.activity-stream.feeds.system.topsites" = false;
  "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
  "browser.startup.page" = 3;
  "browser.translations.automaticallyPopup" = false;
  "browser.uiCustomization.state" = builtins.toJSON {
    currentVersion = 24;
    dirtyAreaCache = [
      "nav-bar"
      "vertical-tabs"
      "unified-extensions-area"
      "PersonalToolbar"
    ];
    newElementCount = 4;
    placements = {
      PersonalToolbar = [
        "import-button"
        "personal-bookmarks"
      ];
      TabsToolbar = [
        "tabbrowser-tabs"
        "new-tab-button"
        "alltabs-button"
      ];
      nav-bar = [
        "back-button"
        "forward-button"
        "stop-reload-button"
        "customizableui-special-spring1"
        "vertical-spacer"
        "urlbar-container"
        "customizableui-special-spring2"
        "downloads-button"
        "fxa-toolbar-menu-button"
        "reset-pbm-toolbar-button"
        "unified-extensions-button"
        "addon_darkreader_org-browser-action"
        "ublock0_raymondhill_net-browser-action"
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      ];
      toolbar-menubar = [ "menubar-items" ];
      unified-extensions-area = [
        "v3-eov3cv_hotmail_com-browser-action"
        "plasma-browser-integration_kde_org-browser-action"
        "sponsorblocker_ajay_app-browser-action"
      ];
      vertical-tabs = [ ];
      widget-overflow-fixed-list = [ ];
    };
    seen = [
      "reset-pbm-toolbar-button"
      "developer-button"
      "v3-eov3cv_hotmail_com-browser-action"
      "plasma-browser-integration_kde_org-browser-action"
      "addon_darkreader_org-browser-action"
      "sponsorblocker_ajay_app-browser-action"
      "ublock0_raymondhill_net-browser-action"
      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      "screenshot-button"
    ];
  };
  "browser.uitour.enabled" = false;
  "browser.urlbar.trustPanel.breachAlerts" = false;
  "extensions.autoDisableScopes" = 0;
  "general.autoScroll" = true;
  "signon.management.page.breach-alerts.enabled" = false;
  "widget.use-xdg-desktop-portal.file-picker" = 1;
  # keep-sorted end
}
