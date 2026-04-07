# Baby Routine Tracker

Garmin Connect IQ watch app for logging baby routines on the wrist. **Work in progress** — not production-ready.

**Feeding** (Left, Bottle, Right) and **diaper** events share one append-only store (`Application.Storage`, key `feedings_v1`). On-watch name: **Baby Routine** (`resources/strings.xml`). Launcher icon: `resources/drawables/launcher_icon.png` → `@Drawables.LauncherIcon` in `manifest.xml`.

---

## Screens

Navigation is **two screens** (swipe up/down / keys): **Feeding** ↔ **Diaper**. A third placeholder view exists in source (`ThirdScreenView.mc`) but is **not reachable** from the current navigation stack (intentionally disabled).

### Screen 1 — Feeding

- **L / B / R** circles; touch on supported devices.
- **Main row** and **two lower rows** show **feeding entries only** (types Left, Right, Bottle)—diaper logs are excluded from this screen.
- With **no entries**, main row shows **Tap L/Bottle/R**; first lower line **Recent History**.
- **Clock** at top follows the device **12h / 24h** setting (`MainScreenTimeDisplay.mc`).

### Screen 2 — Diaper

- **Diaper change** button (touch); **Add diaper** in the screen 2 menu uses the same action as the button (no submenu).
- **Main row** and **lower rows** show **diaper entries only** (newest first by timestamp).
- **Clock** matches device 12h / 24h setting.

**Screen indicator** (left): two dots for the two active screens.

---

## History

| Entry point | View |
|-------------|------|
| **History** from screen 1 | Feeding-only (`t` in {1,2,3}) |
| **History** from screen 2 | Diaper-only (`t == 4`) |
| **History(all)** from either screen | Combined timeline (feeding + diaper) |

- **Entry times** in list rows follow the device **12h / 24h** setting (`FeedingFormatters.formatHistoryRowTimeFromTs`).
- **History(all)** when empty: **No entries yet**. Feeding-only empty: **No feedings yet**. Diaper-only empty: **No diapers yet**.

---

## Glance

`HelloGarminApp.getGlanceView()` returns `BabyRoutineGlanceView` when `WatchUi has :GlanceView`. Shows **one line**: latest store entry as `time - Label`, or **No events**. Time formatting matches history (12h includes AM/PM).

---

## Undo

| Screen | Effect |
|--------|--------|
| **1** | Removes the **most recent feeding** entry (Left / Right / Bottle) |
| **2** | Removes the **most recent diaper** entry |

---

## Menu

**Screen 1** (title: **Feeding**)

- Undo last  
- Start → submenu: Left, Right, Bottle  
- History  
- History(all)  
- Settings *(placeholder)*  
- About *(placeholder)*  

**Screen 2** (title: **Diaper**)

- Undo last  
- Add diaper *(immediate action, closes menu)*  
- History  
- History(all)  
- Settings *(placeholder)*  
- About *(placeholder)*  

---

## Controls

Hardware (typical mapping; confirm on your watch):

- **Upper-right** — open menu / confirm selection  
- **Lower-right** — back / close  
- **Left middle** — up (menu scroll)  
- **Left bottom** — down (menu scroll)  

**Touch** (where implemented):

- Feeding circles (screen 1)  
- Diaper button (screen 2)  
- Menu rows  

Swipe right in the custom menu backs one level where supported.

---

## Known limitations

- History list UI is functional but still needs polish (long lists, scrolling).  
- Settings, About, and **ThirdScreenView** are placeholders or not wired into navigation.  
- Non-touch workflows are not fully validated.  
- Simulator vs device can differ.  
- `source/menu/` contains unused scaffolding not wired into the main app.

---

## Prerequisites

Java; [Connect IQ SDK](https://developer.garmin.com/connect-iq/overview/) (`monkeyc`, `monkeydo`); developer key `.der` for signed builds / many local builds. [Monkey C docs](https://developer.garmin.com/connect-iq/monkey-c/).

---

## Setup

Set `CONNECTIQ_SDK_PATH` or use full paths. In VS Code/Cursor: `garmin.connectIqSdkPath`, `garmin.deviceId` (match `manifest.xml` `<iq:product>`). Copy a valid `developer_key.der` into `keys/` locally (that folder is gitignored).

---

## Build (example — this machine)

SDK example:

`/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b`

```bash
mkdir -p bin
"/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeyc" \
  -f monkey.jungle \
  -o bin/BabyRoutine.prg \
  -d fenix8solar51mm \
  -y keys/developer_key.der
```

Unsigned build (if your SDK allows):

```bash
mkdir -p bin
"$CONNECTIQ_SDK_PATH/bin/monkeyc" -f monkey.jungle -o bin/BabyRoutine.prg -d fenix8solar51mm
```

---

## Simulator (example — this machine)

```bash
"/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeydo" \
  bin/BabyRoutine.prg fenix8solar51mm
```

---

## Project structure (short)

| Path | Role |
|------|------|
| `source/HelloGarminApp.mc` | Entry, `getGlanceView()` |
| `HelloGarminView.mc`, `FeedingTouchLayout.mc`, `MainScreenTimeDisplay.mc` | Screen 1 + clock |
| `SecondScreenView.mc`, `DiaperTouchLayout.mc`, `DiaperActions.mc` | Screen 2 |
| `BabyRoutineGlanceView.mc` | Widget glance |
| `AppNavigation.mc` | Navigation + `CircularNavDelegate` |
| `ScreenIndicator.mc` | Side dots |
| `FeedingStore.mc`, `FeedingFormatters.mc`, `FeedingActions.mc` | Data + feeding actions |
| `CustomMenuView.mc`, `CustomMenuDelegate.mc`, `MenuHotspot.mc` | Menu |
| `source/history/` | History list |
| `ThirdScreenView.mc` | Placeholder (not in nav) |
| `manifest.xml`, `resources/` | Manifest & assets |

---

## Next steps

- Polish History UI; validate on hardware.  
- Implement or hide Settings / About.  

---

## License

Add a license when you publish (not included by default).
