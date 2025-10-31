// User.js overrides prefs.js for user preferences
// https://kb.mozillazine.org/User.js_file
// https://wiki.archlinux.org/title/Firefox
// More tweaks: https://gist.github.com/Zren/d39728991f854c0a5a6a7f7b70d4444a

user_pref("accessibility.force_disabled", 1);
user_pref("accessibility.typeaheadfind.flashBar", 0);
user_pref("app.normandy.first_run", false);

// Privacy settings
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);

// Disable automatic updates
// https://kb.mozillazine.org/App.update.mode
// https://superuser.com/questions/1325421/how-to-stop-firefox-update-notifications
// https://github.com/mozilla/policy-templates/blob/master/docs/index.md#disableappupdate
// about:policies#documentation
user_pref("app.update.auto", false);
user_pref("app.update.download.attempts", 0);
user_pref("app.update.enabled", false);
user_pref("app.update.mode", 2);
user_pref("app.update.silent", true);
user_pref("app.update.url", "");
user_pref("app.update.url.details", "");
user_pref("app.update.url.manual", "");

// Disable the refresh message:
// It looks like you haven't started Firefox in a while. Do you want to clean it up for a fresh, like-new experience?
user_pref("browser.disableResetPrompt", true);

// Hide the download complete popup.
// Prevents the download box from appearing when downloading files.
user_pref("browser.download.alwaysOpenPanel", false);

// Disable the popup asking to set as default browser
user_pref("browser.shell.checkDefaultBrowser", false);

// Open previous windows and tabs
user_pref("browser.startup.page", 3);

// Disable tab groups
user_pref("browser.tabs.groups.enabled", false);
user_pref("browser.tabs.groups.smart.enabled", false);

// Reduce the spacing.
user_pref("browser.uidensity", 1);

// Do not ask to quit (warn) with Ctrl-Q
user_pref("browser.warnOnQuit", false);

// Provide the ability to add new search engines.
user_pref("browser.urlbar.update2.engineAliasRefresh", true);

// Disable autofill
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// Date/time formats follow the Date-Time Combination Examples
// https://unicode.org/reports/tr35/tr35-dates.html#Date_Time_Combination_Examples
// {1} = Date; {0} = Time
user_pref("intl.date_time.pattern_override.connector_short", "{1} {0}");
user_pref("intl.date_time.pattern_override.date_short", "yyyy-MM-dd");
user_pref("intl.date_time.pattern_override.time_short", "HH:mm");

// Disabling the CSS backdrop-filter property to see if it improves website performance.
user_pref("layout.css.backdrop-filter.enabled", false);

// Enable advanced CSS parent selectors. Required to hide ads on Presearch.
user_pref("layout.css.has-selector.enabled", true);

// Disable the popup stating speech synthesis is not available.
user_pref("media.webspeech.synth.dont_notify_on_error", true);

// Network settings
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.proxy.socks", "localhost");
user_pref("network.proxy.socks_port", 56565);

// Do not use DNS over HTTPS
user_pref("network.trr.mode", 5);

// Disable autofill
user_pref("signon.management.page.breach-alerts.enabled", false);
user_pref("signon.rememberSignons", false);

// Enable userChrome.css customization
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Disable first run
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);

// Do not show the menu when hitting Alt. Prevents the menu from showing when moving to a different desktop.
user_pref("ui.key.menuAccessKeyFocuses", false);

// Use the KDE file picker.
// https://wiki.archlinux.org/title/Firefox#KDE_integration
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.location", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("widget.use-xdg-desktop-portal.open-uri", 1);
user_pref("widget.use-xdg-desktop-portal.settings", 1);
