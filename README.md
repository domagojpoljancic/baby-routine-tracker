# Baby Routine Tracker

Garmin **Connect IQ** watch app for logging **baby feeding** and **diaper** events from the wrist. On the watch it appears as **Baby Routine** (see `resources/strings.xml`).

**Who it is for:** parents and caregivers who want a fast, on-device log without pulling out a phone.

Link to the Garmin IQ store: https://apps.garmin.com/apps/1668307c-8455-466e-8dfd-ae30a4a37915

---

## Features

| Area | Behavior |
|------|----------|
| **Feeding** | Log **Left**, **Bottle**, or **Right** from the main screen (touch targets where the device supports touch). Optional **Start** submenu in the menu lists the same three actions. |
| **Diapers** | Log a diaper change from the **Diaper** screen button or **Add diaper** in the screen 2 menu. |
| **Storage** | Single append-only list in `Application.Storage` under key `feedings_v1` (primitive-friendly entries: type code + timestamp). |
| **History** | **History** is filtered by screen (feeding-only vs diaper-only). **History(all)** shows the combined timeline. Grouped by day; newest first. |
| **Undo** | **Undo last** removes the newest entry that matches the **current screen** (feedings vs diapers), not merely the last row in storage. |
| **Menu** | Custom list (**CustomMenuView**): swipe up/down or drag to move selection (clamped at first/last item — no wrap), tap or **Select** to activate, **Back** / **ESC** / **swipe right** to close. |
| **About** | Scrollable on-device copy: what the app does, privacy summary, MIT notice. |
| **Glance** | When the runtime supports `WatchUi.GlanceView`, the app exposes a glance showing the title and the most recent (and optionally previous) event. |
| **Time format** | Clock and history times follow the device **12h / 24h** setting. |

Short **haptic** feedback is used on supported hardware for primary actions and navigation (`Toybox.Attention` via `HapticHelper`).

---

## Device support

The authoritative list of **product ids** is in `manifest.xml` (`<iq:products>`). As of v1.0 that list includes **40** explicit ids across families such as:

- **fēnix** 6 / 7 / 8 (multiple SKUs), **fēnix E**
- **Forerunner** 165, 255, 265, 570, 955, 965, 970 (including “Music” / size variants where listed)
- **Venu** 3, 3S, 4 (41 mm / 45 mm)
- **vívoactive** 5
- **Enduro** 3

**Important:** Declaring a product in the manifest does **not** mean it was tested on real hardware. Before a wide release, validate on the devices you care about. A **signed package** build (`.iq`) compiles for every device variant the SDK associates with those ids (progress lines like `N OUT OF M DEVICES BUILT` are normal).

**Requirements:** `minApiLevel` **3.3.0** (touch/drag APIs used by the custom menu). Java runtime and the [Connect IQ SDK](https://developer.garmin.com/connect-iq/overview/) (`monkeyc`, `monkeydo`) are required to build.

---

## Screens and workflow

### Screen 1 — Feeding

- Three touch regions: **Left**, **Bottle**, **Right**.
- Main and lower rows show **feeding** entries only (types 1–3). Diapers are hidden here.
- **Bottom half** tap opens **feeding-filtered** history.
- **Menu** (hotspot or **Menu** key): Undo last, Start → Left / Bottle / Right, History, History(all), About.

### Screen 2 — Diaper

- **Diaper** button logs a change; **Add diaper** in the menu does the same and closes the menu.
- Rows show **diaper** entries only (type 4).
- **Bottom half** tap opens **diaper-filtered** history.
- Menu: Undo last, Add diaper, History, History(all), About.

### Navigation between screens

- **Swipe up** or **Next** behavior: Feeding → Diaper → (from Diaper) back to Feeding by popping to the first screen in the stack.
- **Swipe down** or **Previous** behavior: the inverse pattern.
- **Screen indicator** (side dots): **two** dots for the two live screens.

### Screen 3

`ThirdScreenView.mc` exists as a **placeholder** and is **not** connected to navigation in v1.0.

### History

Implemented with `WatchUi.CustomMenu`, scrollable lists, date headers, and empty states (**No feedings yet** / **No diapers yet** / **No entries yet**). Selecting a row closes the history view (see `HistoryDelegate`).

---

## Privacy and data

- All event data stays **on the watch** in Garmin application storage.
- **No network**, **no cloud sync**, **no analytics**, **no third-party SDKs** in this codebase.
- A short policy suitable for store listings is in [`PRIVACY.md`](PRIVACY.md).

---

## Build, package, simulator, install

Replace SDK paths with your own. The examples assume a **developer key** at `keys/developer_key.der` (create with Garmin’s `monkeybrains` tooling; see [Connect IQ docs](https://developer.garmin.com/connect-iq/)).

### Output names

| Artifact | Typical path |
|----------|----------------|
| Single-device app binary | `bin/BabyRoutine.prg` |
| Store / multi-device package | `bin/BabyRoutine.iq` |

### Build a `.prg` (one device, fast iteration)

```bash
mkdir -p bin
"/path/to/connectiq-sdk/bin/monkeyc" \
  -f monkey.jungle \
  -o bin/BabyRoutine.prg \
  -d venu3s \
  -y keys/developer_key.der
```

`-d` must be a product id present in `manifest.xml` **and** in your installed SDK.

### Package a signed `.iq` (Connect IQ Store / QA bundle)

Use **`-e`** (application package) and **`-r`** (strip debug symbols) per SDK conventions:

```bash
mkdir -p bin
"/path/to/connectiq-sdk/bin/monkeyc" \
  -f monkey.jungle \
  -e -r \
  -o bin/BabyRoutine.iq \
  -y keys/developer_key.der
```

Upload the `.iq` through the [Garmin Developer Program](https://developer.garmin.com/connect-iq/submit-an-app/) workflow; version strings and store metadata are set in the portal as well as in your submission assets.

### Run in the simulator

Start the **Connect IQ Simulator**, then (device id must match the `.prg` you built):

```bash
"/path/to/connectiq-sdk/bin/monkeydo" bin/BabyRoutine.prg venu3s
```

### IDE tasks

`.vscode/tasks.json` includes **Build (.prg)**, **Run in Simulator**, and **Package (.iq, signed, store)**. Set `garmin.connectIqSdkPath`, `garmin.deviceId`, and `garmin.developerKeyPath` in `.vscode/settings.json` (template placeholders are committed).

The default **Build (.prg)** task does **not** pass `-y`; the shell examples above do. If your SDK requires a key for `.prg` builds, add `-y` to the task or use the README commands.

### Install caveats

- Simulator behavior can differ from hardware (touch mapping, vibration).
- Sideloading a `.prg` is for development; end users typically install from the Connect IQ Store after you publish an `.iq`.

---

## Project structure

| Path | Role |
|------|------|
| `manifest.xml` | App id, products, `minApiLevel`, launcher icon, entry class |
| `monkey.jungle` | `source` + `resources` roots |
| `resources/strings.xml` | `@Strings.AppName` (**Baby Routine**) |
| `resources/drawables/` | Launcher bitmap |
| `source/HelloGarminApp.mc` | Entry point class (**HelloGarminApp** — name kept for stable manifest `entry`); `getGlanceView()` |
| `source/HelloGarminView.mc` | Feeding screen UI |
| `source/SecondScreenView.mc` | Diaper screen UI |
| `source/AppNavigation.mc` | `CircularNavDelegate`: swipe/key navigation, menu push |
| `source/CustomMenuView.mc`, `CustomMenuDelegate.mc`, `MenuHotspot.mc` | Custom menu |
| `source/AboutView.mc`, `AboutDelegate.mc` | About screen |
| `source/FeedingStore.mc`, `FeedingFormatters.mc`, `FeedingActions.mc` | Persistence and feeding actions |
| `source/DiaperActions.mc`, `DiaperTouchLayout.mc` | Diaper logging |
| `source/history/*` | History menu construction and rows |
| `source/BabyRoutineGlanceView.mc` | Glance |
| `source/HapticHelper.mc` | Vibration helper |
| `source/menu/MainMenuBuilder.mc`, `BabyRoutineMenu2InputDelegate.mc` | **Unused in v1.0** (reference only) |
| `source/ThirdScreenView.mc` | Unused placeholder view |

---

## Store and release notes

- **Launcher icon:** `resources/drawables/launcher_icon.png` → `@Drawables.LauncherIcon`.
- **Permissions:** none declared in `manifest.xml`; keep this aligned with actual code if you add sensors or network later.
- **English only** (`eng`) in the manifest languages section.
- Prepare store screenshots and descriptions separately; they are not generated from this repo.
- After changing `manifest.xml` products, re-run a full **`-e`** package build before submission.

---

## License

[MIT License](LICENSE) — Copyright (c) 2026 Domagoj Poljancic.

---

## Status and roadmap

**v1.0** is intended as a complete minimal product: two main screens, shared storage, history, undo, glance, About, and haptics where supported.

**Not in v1.0:** Settings screen (menu slot reserved for later), third main screen, and the unused `Menu2` scaffolding in `source/menu/`. History UI may receive polish in a future version based on feedback.

---

## References

- [Monkey C](https://developer.garmin.com/connect-iq/monkey-c/)
- [UX guidelines](https://developer.garmin.com/connect-iq/user-experience-guidelines/)
- [Compatible devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Submit an app](https://developer.garmin.com/connect-iq/submit-an-app/)
