# Baby Routine (Garmin)

**Current version: v1.2**

Baby Routine is a **Garmin Connect IQ** watch app for logging **feeding** (left, bottle, right) and **diaper** changes on the wrist - quick, on-device, no phone required. On the watch it shows up as **Baby Routine**.

**What's new in v1.2**

- **Added manual entry:** Add Feeding or Diaper entries with a selected time from today.
- **Added long-press shortcuts:** Hold **L**, **B**, **R**, or the diaper button to add manually.
- **Improved first-run hints:** New helper overlay explains the manual-add shortcut.

**What's new in v1.1**

- **Replaced menu with Garmin Menu2:** Don't know why I didn't use the default menu from the very beginning. Would have saved me a lot of headaches.
- **Added swipe-to-open menu:** One more way to open the menu - because clearly the other three weren't enough.
- **Removed top-right menu chip:** That mysterious grey bubble from the screenshots? Yeah… it was supposed to be a menu indicator in v1. It has now been… removed.
- **Added default start screen setting:** If you're a diaper-first kind of person like me, you can now start directly on that screen. Priorities.
- **Added first-run menu hint:** Just making sure no one misses all those amazing features hiding in the menu.
- **Added "How it works" screen:** In case it wasn't obvious what this app does - there's now a guide to clear things up.
- **Added entry counts to history:** No one asked for this, but it was easy to add - and honestly, kind of useful.
- **Updated glance layout & font:** Glance is now left-aligned with a smaller font, so it blends in nicely instead of screaming for attention.

**Store:** [Baby Routine on Garmin Connect IQ](https://apps.garmin.com/apps/1668307c-8455-466e-8dfd-ae30a4a37915)

---

## Features

- **Feeding screen** - Tap **Left**, **Bottle**, or **Right** (on supported watches). Recent feeding activity and a simple timer-style hint on the main row; only feeding events show here.
- **Diaper screen** - Log a change with the main button or via the menu.
- **Two screens** - Swipe or use the watch controls to move between Feeding and Diaper; dots show which screen you're on.
- **Menu** - Undo, quick actions (including **Start** for feeding types or **Add diaper**), **History** (for the current screen), **History (all)**, **Settings**, **How it works**, and **About**. Open it with the **Menu** button, **swipe left**, or **Enter** where that applies.
- **Default start screen** - In **Settings**, choose whether the app opens on **Feeding** or **Diaper**.
- **History** - Filtered lists by screen, or a combined timeline; grouped by day with **entry counts** per day.
- **Undo** - Removes the latest entry that matches the **screen you're on** (feedings vs diapers), not "whatever was last in the whole log."
- **Glance** - On watches that support it, a compact summary of recent activity.
- **Time** - Clock and list times follow the watch's **12h / 24h** setting.
- **Haptics** - Light feedback on some actions when the hardware supports it.
- **Privacy** - Everything stays **on the watch**; no cloud, analytics, or network in the app. See [`PRIVACY.md`](PRIVACY.md).

---

## Device Support

The app targets a **broad set of current Garmin watches** (dozens of models - think fēnix 6-8, Forerunner 165 through 970, Venu 3/4, vívoactive 5, Enduro 3, and similar). **Not every listed model has been tested on the wrist**; if you care about a specific watch, try it there before you rely on it. Requirements follow **Garmin Connect IQ** for your device generation.

---

## How it works

Open the app and you're on **Feeding** or **Diaper**, depending on your **default** (or the last flow you used). **Tap** the circles or the diaper control to log an event. **Swipe** between the two main screens. **Open the menu** when you need history, undo, settings, or the short help screen. **Tap the lower half** of the main screens to jump to **history** filtered for that screen. The first time through, a **small overlay** may nudge you toward the menu - after that it stays out of the way. That's the gist: log fast, review in history, adjust defaults in settings if your routine is more "diapers first" than "feeds first."

---

## Development

Built as a **real-life project** with plenty of **AI-assisted** help (**ChatGPT**, **Cursor**, and the usual trial-and-error on an actual watch). Under the hood it's a standard **Garmin Connect IQ** app: Monkey C, the official SDK, and the usual simulator-or-device workflow. This README stays product-shaped on purpose; if you're contributing or forking, the repo and Garmin's docs are the next stop.

---

## Testing / Beta

A separate store listing, **Baby Routine (Test)**, exists for **beta-style** installs without replacing the main app. Use that if you want to try newer builds side by side with production.

---

## Notes

The app has grown **iteratively** - features ship, get simplified, and sometimes get ripped out when they're more clever than useful. **v1.1** is a good checkpoint: more predictable menus, clearer onboarding, and a bit less visual noise. Feedback and real-world use still drive what happens next.

---

## License

[MIT License](LICENSE) - Copyright (c) 2026 Domagoj Poljancic.
