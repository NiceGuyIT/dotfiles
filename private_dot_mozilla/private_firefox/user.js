// User.js overrides prefs.js for user preferences
// https://kb.mozillazine.org/User.js_file
// https://wiki.archlinux.org/title/Firefox
// More tweaks: https://gist.github.com/Zren/d39728991f854c0a5a6a7f7b70d4444a
user_pref("accessibility.force_disabled", 1);

// Use the KDE file picker.
// https://wiki.archlinux.org/title/Firefox#KDE_integration
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.location", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("widget.use-xdg-desktop-portal.open-uri", 1);
user_pref("widget.use-xdg-desktop-portal.settings", 1);

// Reduce the spacing.
user_pref("browser.uidensity", 1);
// Hide the download complete popup.
user_pref("browser.download.alwaysOpenPanel", false);

// Date/time formats follow the Date-Time Combination Examples
// https://unicode.org/reports/tr35/tr35-dates.html#Date_Time_Combination_Examples
// {1} = Date; {0} = Time
user_pref("intl.date_time.pattern_override.connector_short", "{1} {0}");
user_pref("intl.date_time.pattern_override.date_short", "yyyy-MM-dd");
user_pref("intl.date_time.pattern_override.time_short", "HH:mm");

// Enable userChrome.css customization
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Disable the popup asking to set as default browser
user_pref("browser.shell.checkDefaultBrowser", false);

// Disable the popup stating speech synthesis is not available.
user_pref("media.webspeech.synth.dont_notify_on_error", true);

// Disable tab groups
user_pref("browser.tabs.groups.enabled", false);
user_pref("browser.tabs.groups.smart.enabled", false);

// Do not show the menu when hitting Alt. Prevents the menu from showing when moving to a different desktop.
user_pref("ui.key.menuAccessKeyFocuses", false);

// Prevents the download box from appearing when downloading invoices.
user_pref("browser.download.alwaysOpenPanel", false);

// Enable advanced CSS parent selectors. Required to hide ads on Presearch.
user_pref("layout.css.has-selector.enabled", true);

// Provide the ability to add new search engines.
user_pref("browser.urlbar.update2.engineAliasRefresh", true);

// Disabling the CSS backdrop-filter property to see if it improves website performance.
user_pref("layout.css.backdrop-filter.enabled", false);
