import Toybox.WatchUi;

// Menu2 input for main screen menus (reference: BreastfeedTrackerMenuInputDelegate + Menu2).
class BabyRoutineMenu2InputDelegate extends WatchUi.Menu2InputDelegate {

    var _screen;

    function initialize(screen) {
        Menu2InputDelegate.initialize();
        _screen = screen;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :undoLast) {
            if ((new FeedingStore()).undoLastForScreen(_screen)) {
                HapticHelper.subtleActionPulse();
            }
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
            return;
        }

        if (id == :start) {
            HapticHelper.subtleActionPulse();
            var sub = MainMenuBuilder.buildStartMenu();
            WatchUi.pushView(sub, new BabyRoutineStartMenuInputDelegate(), WatchUi.SLIDE_UP);
            return;
        }

        if (id == :addDiaper) {
            (new DiaperActions()).completeAddDiaper();
            HapticHelper.subtleActionPulse();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }

        if (id == :history) {
            HapticHelper.subtleActionPulse();
            var hm;
            if (_screen == 2) {
                hm = HistoryView.build(:diaperOnly);
            } else {
                hm = HistoryView.build(:feedingOnly);
            }
            WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (id == :historyAll) {
            HapticHelper.subtleActionPulse();
            WatchUi.pushView(HistoryView.build(:all), new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (id == :settings) {
            HapticHelper.subtleActionPulse();
            WatchUi.pushView(SettingsView.buildMenu(), new SettingsDelegate(_screen), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (id == :about) {
            HapticHelper.subtleActionPulse();
            var aboutView = new AboutView();
            WatchUi.pushView(aboutView, new AboutDelegate(aboutView), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (id == :howItWorks) {
            HapticHelper.subtleActionPulse();
            var howItWorksView = new HowItWorksView();
            WatchUi.pushView(howItWorksView, new HowItWorksDelegate(howItWorksView), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (id == :item1 || id == :item2) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
