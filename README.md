# ReverseScroll.spoon

Hammerspoon Spoon that toggles macOS natural scrolling with a hotkey.

Natural scrolling is one system-wide setting shared by trackpad and mouse. Event-tap tools can't reverse only one device, and they miss input forwarded by apps like Deskflow. This Spoon flips the real setting by driving System Settings.

## Versioning

Versions track macOS. The Spoon version `27.2` means it was working on macOS 27.2.

This is best-effort. A new version is tagged when the Spoon is noticeably not working on a newer macOS. It is not tested on every release. Expect to fish around or guess at UI paths after an update.

## Status

Working on macOS 27.2 (26B123).

## Requirements

- [Hammerspoon](https://www.hammerspoon.org/)
- [Hammerspoon](https://www.hammerspoon.org/) with Accessibility enabled. In the Hammerspoon console, run `hs.accessibilityState(true)`. macOS prompts for the permission, which is listed as "Device Control and Data Access" in Privacy & Security on macOS 27.
- Automation permission for Hammerspoon to control System Events. Run `hs.osascript.applescript('tell application "System Events" to return name')` in the console. macOS prompts once. Allow it under System Settings → Privacy & Security → Automation → Hammerspoon → System Events.

## Install

Copy or symlink this directory into your Spoons folder:

```sh
ln -s /path/to/ReverseScroll.spoon ~/.hammerspoon/Spoons/ReverseScroll.spoon
```

Add to `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("ReverseScroll")
spoon.ReverseScroll:configure{
  hotkey = {{"ctrl", "shift"}, "N"},
  enableAlert = true
}
```

Reload Hammerspoon. Press the hotkey to toggle natural scrolling.

## Options

| Option          | Type          | Default | Description                              |
|-----------------|---------------|---------|------------------------------------------|
| `hotkey`        | `{mods, key}` | `nil`   | Hotkey that toggles natural scrolling    |
| `enableMenubar` | boolean       | `true`  | Show menubar icon with current state     |
| `enableAlert`   | boolean       | `false` | Show an alert with the new state         |

The menubar icon shows 📜 when natural scrolling is on and a crossed-out 📜 when off. Icons are drawn at runtime from the emoji, so there are no image files to ship.

## Caveats

- System Settings opens and closes on every toggle, and the script quits it when done. Any window you had open in System Settings is closed.
- The script runs asynchronously. Presses during a toggle are ignored.
- The initial menubar state comes from `defaults read`. If that disagrees with what System Settings shows, toggle once to resync.
- If the script fails, the error goes to the Hammerspoon console.
- The script uses positional UI paths. A macOS update can break it. Fix the paths in `init.lua` and tag a new version.

## License

MIT. See [LICENSE.md](LICENSE.md).
