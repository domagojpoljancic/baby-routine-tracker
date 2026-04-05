# Baby Routine Tracker

**Work in progress** — not production-ready.

Garmin Connect IQ watch app for baby tracking on the wrist. **Current focus: feeding** (left, bottle, right) with local persistence. Additional screens and metrics are placeholders or incomplete.

**On-watch display name:** Baby Routine (see `resources/strings.xml`).

---

## Current working features

- **Main feeding screen** with three circles **L / B / R** (Left, Bottle, Right) and time row.
- **Touch input** on the main feeding circles on touch-capable devices (`FeedingTouchLayout` + `HelloGarminView`).
- **Non-touch / button-only use:** open the **menu** (hardware **Enter** / **Menu** / hotspot where available), choose **Start**, then **Left**, **Right**, or **Bottle** with physical button navigation and select — same `FeedingActions` pipeline as circle taps.
- **Storage / persistence** of feeding entries via `Application.Storage` (`FeedingStore`); entries use type codes and timestamps.
- **Active / latest feeding** highlighted in the main row with formatter-driven text and elapsed-style display.
- **Recent history rows** on the home screen (lower section) when enough entries exist.
- **Custom menu** (upper-right affordance + `CustomMenuView` / `CustomMenuDelegate`): list-style UI with selection and back behavior (`BehaviorDelegate`: up/down scroll, select, back; swipe right also backs out of the menu on supported devices).
- **Menu open / close** via physical buttons (`KEY_ENTER` / `onMenu`) and hotspot tap where available; stack uses `CircularNavDelegate` on the home screen.
- **Start** submenu: **Left / Right / Bottle** feeding actions wired to the same pipeline as touch (`FeedingActions`).
- **Physical button navigation** in the menu (up/down, select, back) per `BehaviorDelegate` mapping.
- **Touch** on menu rows where supported (`CustomMenuDelegate.onTap` + row hit testing).
- **Undo last** feeding from the menu (store-level undo).
- **Three-screen shell:** swipe/key navigation between home, second, and third screens (content mostly placeholder).

---

## In progress / incomplete

- **Custom menu** visuals and behavior are still being refined.
- **History** (menu → History): **currently broken / not finished** — the History screen can crash at runtime and is **not** production-ready. Do not rely on it until it is fixed and validated.
- **Timer / blink / redraw:** home row timing and circle flash use animation-driven redraw; this may still need refinement for battery and correctness.
- **Additional baby metrics** and real content on screens 2–3: **placeholder** or missing.

---

## Known issues and limitations

- **History screen:** crashes or unstable; treat as **broken** until a proper fix lands.
- **Work in progress:** APIs, UX, and storage usage may change.
- **Menu items:** **History** is wired but the screen is broken (see above). **Settings** and **About** are placeholders — selecting them typically just closes the menu.
- **Simulator vs device:** behavior should be validated on real hardware; CIQ simulator can differ.
- **Temporary debug logging:** `System.println` remains in `CustomMenuDelegate.mc`, `history/HistoryView.mc`, and `menu/BabyRoutineMenu2InputDelegate.mc` (the last is not used by the main app flow) — remove or gate before a release build.

---

## Prerequisites

1. **Java** (Connect IQ SDK toolchain).
2. **Garmin Connect IQ SDK** (`monkeyc`, `monkeydo`, simulator). Note the SDK root (folder containing `bin/monkeyc`).
3. **Developer key** (`.der`) for packaging a signed `.iq` (optional for local `.prg` runs).

Official docs: [Connect IQ](https://developer.garmin.com/connect-iq/overview/) · [Monkey C](https://developer.garmin.com/connect-iq/monkey-c/).

---

## Setup

1. Install the Connect IQ SDK.
2. Optionally set `CONNECTIQ_SDK_PATH` to your SDK root, or use full paths in commands below.
3. For VS Code / Cursor tasks, point `garmin.connectIqSdkPath` and `garmin.deviceId` (e.g. `fenix8solar51mm`) at your environment.

---

## Build (example: this machine)

SDK path example (adjust to your install):

`/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b`

From the project root:

```bash
mkdir -p bin
"/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeyc" \
  -f monkey.jungle \
  -o bin/BabyRoutine.prg \
  -d fenix8solar51mm \
  -y keys/developer_key.der
```

If you omit signing for a quick local build (when your workflow allows):

```bash
mkdir -p bin
"$CONNECTIQ_SDK_PATH/bin/monkeyc" -f monkey.jungle -o bin/BabyRoutine.prg -d fenix8solar51mm
```

Use the **same** `-o` output path for `monkeydo` below. `manifest.xml` lists `fenix8solar51mm`; align `-d` with your device.

---

## Simulator

After a successful build:

```bash
"/Users/domagoj.poljancic/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeydo" \
  bin/BabyRoutine.prg fenix8solar51mm
```

Or use **Tasks → Garmin: Run in Simulator** if configured.

---

## Project structure (overview)

| Area | Paths / role |
|------|----------------|
| App entry | `source/HelloGarminApp.mc` |
| Main feeding UI | `source/HelloGarminView.mc`, `source/FeedingTouchLayout.mc`, `source/ScreenIndicator.mc` |
| Navigation | `source/AppNavigation.mc` (circles, menu push, screen index) |
| Storage | `source/FeedingStore.mc` |
| Formatting | `source/FeedingFormatters.mc` |
| Feeding actions (touch + menu) | `source/FeedingActions.mc` |
| Menu UI | `source/CustomMenuView.mc`, `source/CustomMenuDelegate.mc`, `source/MenuHotspot.mc` |
| History (broken WIP) | `source/history/*.mc` |
| Extra menu scaffolding | `source/menu/` — `MainMenuBuilder.mc` / `BabyRoutineMenu2InputDelegate.mc` are **not** referenced by the running app (custom menu uses `CustomMenuView` instead) |
| Secondary screens | `source/SecondScreenView.mc`, `source/ThirdScreenView.mc` |
| Manifest / resources | `manifest.xml`, `resources/` |

---

## Next steps

1. **Fix History** properly (timestamp pipeline, `CustomMenu` + `Menu2InputDelegate`, crash on device/simulator).
2. **Wire** stable History behavior and re-test menu → History → back.
3. **Continue** Settings / About / other menu items as real features or hide them.
4. **Next baby metrics** and real second/third screen content.
5. **Cleanup** temporary `System.println` debug and any dead code paths before release.

---

## License

Add a license file when you publish (not included here by default).
