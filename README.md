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
| **Storage** | Event log: append-only list in `Application.Storage` under key `feedings_v1` (type code + timestamp). Preferences (e.g. scroll invert) use separate keys such as `settings_scroll_invert_v1`. |
| **History** | **History** is filtered by screen (feeding-only vs diaper-only). **History(all)** shows the combined timeline. Grouped by day; newest first. |
| **Undo** | **Undo last** removes the newest entry that matches the **current screen** (feedings vs diapers), not merely the last row in storage. |
| **Menu** | Custom list (**CustomMenuView**): swipe up/down or drag to move selection (clamped at first/last item — no wrap), tap or **Select** to activate, **Back** / **ESC** / **swipe right** to close. |
| **Settings** | **Scroll invert** is **work in progress**: the toggle is stored (`settings_scroll_invert_v1`), but **inversion does not work correctly in the current build** (menu scrolling behaves as normal). A fix is planned. |
| **About** | Scrollable on-device copy: what the app does, privacy summary, MIT notice. |
| **Glance** | When the runtime supports `WatchUi.GlanceView`, the app shows title **Baby Routine**, the latest event line, and optionally the previous line. Both event lines share the same font tier: **TINY**, or **XTINY** if either line is wider than **94%** of the glance width (same rule as the empty-state line). |
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

- **First run (empty store):** about **one second** after the Feeding view appears, a short **onboarding overlay** dims the **upper half** and shows hints (**Menu »** / **« or left swipe**). It **auto-dismisses** after ~3s, or dismiss on tap (outside the menu hotspot), swipe, or most keys. Tapping the **menu hotspot**, **swipe left**, **Menu** key, or **Enter** dismisses the overlay and **opens the main menu** (same stack as normal navigation). Once any event exists in `feedings_v1`, the overlay is skipped.
- Three touch regions: **Left**, **Bottle**, **Right**.
- Main and lower rows show **feeding** entries only (types 1–3). Diapers are hidden here.
- **Bottom half** tap opens **feeding-filtered** history.
- **Menu** (hotspot, **Menu** key, or **swipe left**): Undo last, Start → Left / Bottle / Right, History, History(all), Settings, About.

### Screen 2 — Diaper

- **Diaper** button logs a change; **Add diaper** in the menu does the same and closes the menu.
- Rows show **diaper** entries only (type 4).
- **Bottom half** tap opens **diaper-filtered** history.
- Menu: Undo last, Add diaper, History, History(all), Settings, About (open via hotspot, **Menu** key, or **swipe left**).

### Navigation between screens

- **Swipe left** on the Feeding or Diaper screen opens the **same menu** as the hotspot / **Menu** key (does not switch screens).
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
| Store / multi-device package (production manifest) | `bin/BabyRoutine.iq` |
| Store test/beta package (separate app id / display name) | `bin/BabyRoutine-Test.iq` |

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

### Package a test / beta `.iq` (separate store listing)

Use **`monkey.test.jungle`** and **`manifest.test.xml`**: different **application id** and on-watch name **`Baby Routine (Test)`** (`@Strings.AppNameTest`), so you can publish side-by-side with production.

```bash
mkdir -p bin
"/path/to/connectiq-sdk/bin/monkeyc" \
  -f monkey.test.jungle \
  -e -r \
  -o bin/BabyRoutine-Test.iq \
  -y keys/developer_key.der
```

The **`id`** in `manifest.test.xml` must match the UUID of your **test** app in the Garmin developer portal (replace it if the portal shows a different id). Keep `<iq:products>` in the test manifest aligned with production when you change device targets.

### Run in the simulator

Start the **Connect IQ Simulator**, then (device id must match the `.prg` you built):

```bash
"/path/to/connectiq-sdk/bin/monkeydo" bin/BabyRoutine.prg venu3s
```

### IDE tasks

`.vscode/tasks.json` includes **Build (.prg)**, **Run in Simulator**, **Package (.iq, signed, store)**, and **Package test .iq (manifest.test.xml)** → `bin/BabyRoutine-Test.iq`. Set `garmin.connectIqSdkPath`, `garmin.deviceId`, and `garmin.developerKeyPath` in `.vscode/settings.json` (template placeholders are committed).

The default **Build (.prg)** task does **not** pass `-y`; the shell examples above do. If your SDK requires a key for `.prg` builds, add `-y` to the task or use the README commands.

### Install caveats

- Simulator behavior can differ from hardware (touch mapping, vibration, glance layout).
- Sideloading a `.prg` is for development; end users typically install from the Connect IQ Store after you publish an `.iq`.

---

## Project structure

| Path | Role |
|------|------|
| `manifest.xml` | Production app id, products, `minApiLevel`, launcher icon, entry class |
| `manifest.test.xml` | Test/beta app id + products (sync with production list); `@Strings.AppNameTest` |
| `monkey.jungle` | Production jungle → `manifest.xml` |
| `monkey.test.jungle` | Test jungle → `manifest.test.xml` |
| `resources/strings.xml` | `@Strings.AppName`, `@Strings.AppNameTest` |
| `resources/drawables/` | Launcher bitmap |
| `source/HelloGarminApp.mc` | Entry point class (**HelloGarminApp** — name kept for stable manifest `entry`); `getGlanceView()` |
| `source/HelloGarminView.mc` | Feeding screen UI |
| `source/SecondScreenView.mc` | Diaper screen UI |
| `source/AppNavigation.mc` | `CircularNavDelegate`: swipe/key navigation, menu push; `openScreenMenu()` for programmatic open |
| `source/OnboardingEligibility.mc`, `OnboardingOverlayView.mc`, `OnboardingOverlayDelegate.mc` | First-run hint when the event store is empty (Feeding screen) |
| `source/CustomMenuView.mc`, `CustomMenuDelegate.mc`, `MenuHotspot.mc` | Custom menu |
| `source/AboutView.mc`, `AboutDelegate.mc` | About screen |
| `source/AppSettingsStore.mc` | App preferences in `Application.Storage` (separate from `feedings_v1`) |
| `source/SettingsView.mc`, `SettingsDelegate.mc` | Settings UI (e.g. scroll invert) |
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
- After changing `manifest.xml` products, re-run a full **`-e`** package build before submission; update **`manifest.test.xml`** products to match if you ship a test build too.
- **Scroll invert** (Settings): treat as **placeholder / WIP** until a release note says otherwise; the current build does not apply inversion reliably.

---

## License

[MIT License](LICENSE) — Copyright (c) 2026 Domagoj Poljancic.

---

## Status and roadmap

**v1.0** is intended as a complete minimal product: two main screens, shared storage, history, undo, glance, About, and haptics where supported.

**Develop branch / unreleased work:** Verified in the **Connect IQ simulator** where noted; **not fully validated on a physical watch**. **Scroll invert** in Settings is **WIP** and **non-functional** in the current code path despite the toggle. Run a hardware pass before merging to `main` or submitting a store build.

**Not in v1.0:** Third main screen and the unused `Menu2` scaffolding in `source/menu/`. Settings may grow beyond scroll invert in a future version. History UI may receive polish based on feedback.

---

## References

- [Monkey C](https://developer.garmin.com/connect-iq/monkey-c/)
- [UX guidelines](https://developer.garmin.com/connect-iq/user-experience-guidelines/)
- [Compatible devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Submit an app](https://developer.garmin.com/connect-iq/submit-an-app/)
