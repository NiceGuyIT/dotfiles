# Goal

The goal is to manage the KDE settings from within [chezmoi][1], a dotfile manager. There are two steps to this.

1. Dump the existing KDE config to see what configuration options are changed from their default settings. This will
   reflect your preferences.
2. Apply your preferences to a running KDE instance.

[1]: https://github.com/twpayne/chezmoi

# Approaches

The first config I wanted to get/set was the ability to move application windows on the taskbar. This config resides in
`plasma-org.kde.plasma.desktop-appletsrc` which is not easily configured using `kwriteconfig5`/`kwriteconfig5` because
you need to know the containment and applet group for the task manager. This is where many existing scripts fail.

[opensuse_postinstall.sh][2] does not mention `plasma-org.kde.plasma.desktop-appletsrc`. Note: The bottom of the script
changes the Firefox file picker to use KDE.

[konsave][3] backs up and restores the files. Individual configuration items are not mentioned.

[transfuse][4] backs up and restores the files using `rsync`. Individual configuration items are not mentioned.

[plasmasetconfig.py][5] gets closer by using `qdbus` to get/set the configuration values. It uses the Python `qdbus`
library to interface with `qdbus`. Since the Plasma script is passed to `qdbus`, why not extract that functionality and
remove the dependency upon Python and the Python modules?

[kde-configuration-files][6] has a lot of good information and uses the [plasmasetconfig.py][5] script above.
Unfortunately, the only mention of `plasma-org.kde.plasma.desktop-appletsrc` is in a commented out `sed` command.

[Robust command line (CLI) configuration of Plasma (KDE) applets][7] question on StackExchange attempts to solve this by
using a Bash script (1st answer) and a JavaScript file fed into `qdbus org.kde.plasmashell /PlasmaShell
org.kde.PlasmaShell.evaluateScript` (2nd answer). The 2nd answer is closer to a raw solution.

[plasma_setup.sh][8] in [BlueDrink9/env][9] dotfiles mentions `plasma-org.kde.plasma.desktop-appletsrc` but uses the
technique used in the 1st answer above, and subsequently uses `kwriteconfig5` to write the config values.

The KDE docs for [Plasma Desktop scripting][10] has some [examples][11], one of which [Print config values for each
instance of a specific widget][12]. Let's start with this.

[2]: https://gist.github.com/Zren/d39728991f854c0a5a6a7f7b70d4444a

[3]: https://github.com/Prayag2/konsave

[4]: https://gitlab.com/cscs/transfuse

[5]: https://gist.github.com/Zren/764f17c26be4ea0e088f4a6a1871f528

[6]: https://github.com/shalva97/kde-configuration-files

[7]: https://unix.stackexchange.com/questions/438596/robust-command-line-cli-configuration-of-plasma-kde-applets

[8]: https://github.com/BlueDrink9/env/blob/master/desktop_elements/plasma_setup.sh

[9]: https://github.com/BlueDrink9/env

[10]: https://develop.kde.org/docs/plasma/scripting/

[11]: https://develop.kde.org/docs/plasma/scripting/examples/

[12]: https://develop.kde.org/docs/plasma/scripting/examples/#print-config-values-for-each-instance-of-a-specific-widget

# Solution

`kde-config-dump.nu` runs the `dump-widget-config.js` script in `dbus6`. `dump-widget-config.js` iterates over the
widgets and applets and returns a JSON string. The [configuration keys][13] and their explanation are found in the KDE
docs. My particular interest is with the Task Manager configuration key.

The next step is to take a JSON as input and write the config values using
`dbus6`.

[13]: https://develop.kde.org/docs/plasma/scripting/keys/

# References

- [KDE Configuration Files][14]
- [KConfig][15]

[14]: https://userbase.kde.org/KDE_System_Administration/Configuration_Files

[15]: https://api.kde.org/frameworks/kconfig/html/annotated.html

# KDE Settings

- Appearance
    - Global Theme
        - Breeze Dark
        - Application Style: Breeze
        - Plasma Style: Breeze (Follows color scheme)
        - Colors: From current color scheme
        - Window Decorations: Breeze
        - Fonts
            - General: Noto Sans 10pt
            - Fixed width: Hack 9pt
            - Small: Noto Sans 10pt
            - Toolbar: Noto Sans 10pt
            - Menu: Noto Sans 10pt
            - Window title: Noto Sans 10pt
        - Icons: Breeze Dark
        - Cursors
            - Name: Breeze
            - Size: 36
        - Splash Screen: Breeze
    - Workspace Behavior
        - General Behavior
            - Animation speed: Instant
            - Clicking files or folders: Selects them
        - Desktop Effects
            - Zoom: Unselected
            - Login: Unchecked
            - Logout: Unchecked
            - Maximize: Unchecked
            - Screen Edge: Unchecked
            - Sliding Popups: Unchecked
            - Squash: Unselected
            - Window Aperture: Unselected
            - Slide: Unselected
            - Desktop Grid: Unchecked
            - Scale: Unselected
        - Screen Edges
            - Upper left: Present windows - all desktops
            - Maximize: Unchecked - Windows dragged to the top edge
            - Tile: Unchecked - Windows dragged to the left or right edge
            - Behavior: Unchecked - Remain active when windows are full screen
        - Screen Locking
            - Lock screen automatically: Unchecked - After 15 minutes
            - Allow unlocking without password for: 15 seconds
            - Keyboard Shortcut: Ctrl-Alt-L
            - Virtual Desktops
                - Row 1
                    - Desktop 1
                    - Desktop 2
                    - Desktop 3
                - Row 2
                    - Desktop 4
                    - Desktop 5
                    - Desktop 6
    - Shortcuts
        - Konsole
            - Ctrl-Alt-T
        - KRunner
            - Alt+F2, Alt+Space
        - Touchpad
            - Toggle Touchpad
                - Meta+Ctrl+Zenkaku Hankaku: Uncheck
        - Audio Volume
            - Mute Microphone
                - Meta+Volume Mute: Uncheck
        - Custom Shortcuts Service
            - Search
        - Keyboard Layout Switcher
            - Ctrl+Alt+K
        - KWin
            - Activate Window Demanding Attention: No active shortcuts
            - Actual Size: No active shortcuts
            - Kill Window: Ctrl+Alt+Esc
            - Maximize Window: No active shortcuts
            - Minimize Window: No active shortcuts
            - Peek at Desktop: No active shortcuts
            - Quick Tile Window to the Bottom: No active shortcuts
            - Quick Tile Window to the Left: No active shortcuts
            - Quick Tile Window to the Right: No active shortcuts
            - Quick Tile Window to the Top: No active shortcuts
            - Switch One Desktop Down: Ctrl+Alt+Down, Meta+Ctrl+Down
            - Switch One Desktop to the Left: Ctrl+Alt+Left, Meta+Ctrl+Left
            - Switch One Desktop to the Right: Ctrl+Alt+Right, Meta+Ctrl+Right
            - Switch One Desktop Up: Ctrl+Alt+Up, Meta+Ctrl+Up
            - Switch to Desktop 5: Ctrl+F5
            - Switch to Desktop 6: Ctrl+F6
            - Window to Next Screen: No active shortcuts
            - Window to Previous Screen: No active shortcuts
        - Plasma
            - Automatic Action Popup Menu: No active shortcuts
            - Manually Invoke Action on Current Clipboard: Ctrl+Alt+R
            - Show Items at Mouse Pointer: No active shortcuts
        - Session Management
            - Halt Without Confirmation: Ctrl+Alt+Shift+PgDown
            - Lock Session: Screensaver, Ctrl+Alt+L
            - Log Out Without Confirmation: Ctrl+Alt+Shift+Del
            - Reboot Without Confirmation: Ctrl+Alt+Shift+PgUp
        - Navigation
            - Add Bookmark: None
    - Regional Settings
        - Spell Check: See `~/.config/KDE/Sonnet.conf`
    - Bell
        - Visual bell
            - Invert Screen: Select (greyed out)
        - Modifier Keys
            - Ring system bell when modifier keys are used: Checked (greyed out)
        - Keyboard Filters
            - Ring system bell
                - when any key is pressed: Checked (greyed out)
                - when any key is accepted: Checked (greyed out)
                - when any key is rejected: Checked (greyed out)
            - Delay
                - Ring system bell when rejected: Checked (greyed out)
            - Mouse Navigation
                - Repeat interval: 5
                - Acceleration time: 100
                - Maximum speed: 5
    - Applications
        - Locations
            - Documents path: /home/dev/
            - Videos path: /home/dev/
            - Pictures path: /home/dev/
            - Music path: /home/dev/
            - Public path: /home/dev/
            - Templates path: /home/dev/
        - Default Applications
            - Web browser: Firefox (dev)
            - Email client: Thunderbird (local)
    - Input Devices
        - Keyboard
            - Keyboard model: Generic | Generic 101-key PC
            - NumLock on Plasma Startup: Turn on
            - Delay: 175 ms
            - Rate: 40 repeats/s
    - Display and Monitor
        - Compositor
            - The compositor selection is orange but none of the options are orange
