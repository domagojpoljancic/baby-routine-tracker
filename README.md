# Baby Routine Tracker

Garmin Connect IQ watch app for logging baby routines on the wrist. **Current focus: feeding** (left / bottle / right) with local persistence and a three-screen shell for future metrics.

**On-watch display name:** Baby Routine (see `resources/strings.xml`).

## What works today

- **Feeding entry (touch):** Tap **L**, **B**, or **R** on the home screen circles; hits map to stored feeding types (numeric codes 1 / 3 / 2).
- **Persistence:** Entries are stored with `Application.Storage` (`FeedingStore`); they survive app restarts when not cleared.
- **Main row:** Latest feeding summary (time, label, optional elapsed minutes) with timer suffix blink driven by redraw rate (not `Toybox.Timer`).
- **History rows:** Two lower lines show older entries (when enough history exists).
- **Navigation:** Swipe up/down or hardware keys move through **three** circular screens (home → second → third).
- **Visual feedback:** Brief flash on the tapped circle after a hit.

## Placeholders / unfinished

- **Screen 2 & 3:** Placeholder titles only (“Second Screen” / “Third Screen”); no additional baby metrics yet.
- **Redraw / “timer”:** A long `WatchUi.animate` on a dummy field drives frequent `onUpdate` for live clock and elapsed minutes—acceptable for now, not a final architecture.
- **Touch-first:** No button-based feeding input; navigation uses keys/swipes only.

## Temporary debug (remove before production)

- **Persistence line:** Bottom-right `PERSIST: … | TS: …` (and `KEY_MENU` on home clears history)—marked `TEMP DEBUG ONLY` in source.
- **Internal class names** (`HelloGarminApp`, `HelloGarminView`) remain from early scaffolding; behavior is unchanged.

## Device / testing status

- **Simulator:** Primarily exercised on **Fenix 8 Solar 51mm** (`fenix8solar51mm` in `manifest.xml` and VS Code settings).
- **Touch:** Implementation assumes a touchscreen; non-touch models are not supported for feeding input yet.

## Prerequisites

1. **Java** (required by the Connect IQ SDK toolchain).
2. **Garmin Connect IQ SDK** (`monkeyc`, `monkeydo`, simulator).
3. **Developer key** (`.der`) only if you package a signed `.iq`.

Official docs: [Connect IQ](https://developer.garmin.com/connect-iq/overview/).

## Setup

1. Install the Connect IQ SDK and note the SDK root path (folder containing `bin/monkeyc`).
2. Edit `.vscode/settings.json`:
   - `garmin.connectIqSdkPath` → your SDK root  
   - `garmin.deviceId` → e.g. `fenix8solar51mm` (must exist in your SDK)  
   - `garmin.developerKeyPath` → path to `.der` (for package task only)

Generate a key if needed:

```bash
java -jar "<CONNECTIQ_SDK_PATH>/bin/monkeybrains.jar" -o "<path/to/developer_key.der>"
```

## Build

From the project root (output: `bin/BabyRoutine.prg`):

```bash
mkdir -p bin
"$CONNECTIQ_SDK_PATH/bin/monkeyc" -f monkey.jungle -o bin/BabyRoutine.prg -d fenix8solar51mm
```

Or in Cursor/VS Code: **Tasks → Garmin: Build (.prg)**.

## Simulator

After a successful build:

```bash
"$CONNECTIQ_SDK_PATH/bin/monkeydo" bin/BabyRoutine.prg fenix8solar51mm
```

Or **Tasks → Garmin: Run in Simulator** (builds then runs `monkeydo`).

## Package (signed `.iq`)

```bash
"$CONNECTIQ_SDK_PATH/bin/monkeyc" -f monkey.jungle -o bin/BabyRoutine.iq -y "<path/to/developer_key.der>"
```

## Project structure

| Path | Role |
|------|------|
| `manifest.xml` | App id (unchanged), display name resource, entry class, products, API level |
| `monkey.jungle` | Source/resource roots |
| `source/` | Monkey C: app entry (`HelloGarminApp`), home UI (`HelloGarminView`), navigation (`AppNavigation`), storage (`FeedingStore`), formatters, touch layout, secondary screens |
| `resources/` | `strings.xml` (app name), drawables (launcher icon) |
| `bin/` | Build outputs (gitignored) |
| `.vscode/` | Tasks, launch shortcut, SDK paths |

## Next steps

- Add **non-touch** input paths (buttons) for feeding on devices without touch.
- Implement **real content** on screen 2 and screen 3 (next baby metrics).
- Refine **timer / blink** behavior and redraw strategy (e.g. if `WatchUi.animate` is replaced or complemented).
- Remove **TEMP DEBUG** persistence HUD and menu clear; tighten production behavior and naming cleanup if desired.

## License

Add a license file when you publish (not included in this initial commit).
