import Toybox.System;
import Toybox.WatchUi;

// Screen indices: 1 = home (feeding UI), 2 = second, 3 = third.
// Forward: SWIPE_UP, KEY_DOWN. Back: SWIPE_DOWN, KEY_UP. Circular via push/pop stack.
// onTap order — screen 1: menu hotspot, L/B/R circles, bottom half → filtered History. Screen 2: menu, diaper button, bottom half → History.
// Custom menu: onMenu, KEY_ENTER, hotspot tap — _pushScreenMenu(); KEY_ESC — popView (see reference MainDelegate).
class CircularNavDelegate extends WatchUi.BehaviorDelegate {

    var _screen;

    function initialize(screen) {
        BehaviorDelegate.initialize();
        _screen = screen;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            _goNext();
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _goPrev();
            return true;
        }
        return false;
    }

    function onTap(clickEvent) {
        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var x = c[0];
        var y = c[1];

        if (new MenuHotspot().hitTest(x, y, ds.screenWidth, ds.screenHeight)) {
            _pushScreenMenu();
            return true;
        }

        var h = ds.screenHeight;

        if (_screen == 1) {
            var result = new FeedingTouchLayout().hitCircle(x, y, ds.screenWidth, h);
            if (result != null) {
                (new FeedingActions()).completeCircleTap(result);
                HapticHelper.subtleActionPulse();
                return true;
            }
            if (_isBottomHalfTap(y, h)) {
                _openScreenFilteredHistory();
                HapticHelper.subtleActionPulse();
                return true;
            }
            return false;
        }

        if (_screen == 2) {
            if (new DiaperTouchLayout().hitDiaperButton(x, y, ds.screenWidth, h)) {
                (new DiaperActions()).completeAddDiaper();
                HapticHelper.subtleActionPulse();
                return true;
            }
            if (_isBottomHalfTap(y, h)) {
                _openScreenFilteredHistory();
                HapticHelper.subtleActionPulse();
                return true;
            }
            return false;
        }

        return false;
    }

    // Same History modes as CustomMenuDelegate :history (not History(all)).
    function _openScreenFilteredHistory() {
        var hm;
        if (_screen == 2) {
            hm = HistoryView.build(:diaperOnly);
        } else {
            hm = HistoryView.build(:feedingOnly);
        }
        WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

    function _isBottomHalfTap(y, height) {
        return y >= height / 2;
    }

    function onKey(keyEvent) {
        var k = keyEvent.getKey();

        if (k == WatchUi.KEY_ENTER) {
            _pushScreenMenu();
            return true;
        }

        if (k == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }

        if (k == WatchUi.KEY_DOWN) {
            _goNext();
            return true;
        }
        if (k == WatchUi.KEY_UP) {
            _goPrev();
            return true;
        }

        return false;
    }

    function onMenu() {
        _pushScreenMenu();
        return true;
    }

    function _pushScreenMenu() {
        var labels;
        var symbols;

        if (_screen == 1) {
            labels = ["Undo last", "Start", "History", "History(all)", "Settings", "About"];
            symbols = [:undoLast, :start, :history, :historyAll, :settings, :about];
        } else if (_screen == 2) {
            labels = ["Undo last", "Add diaper", "History", "History(all)", "Settings", "About"];
            symbols = [:undoLast, :addDiaper, :history, :historyAll, :settings, :about];
        } else {
            labels = ["Undo last", "Item 1", "Item 2"];
            symbols = [:undoLast, :item1, :item2];
        }

        var menuTitle = null;
        if (_screen == 1) {
            menuTitle = "Feeding";
        } else if (_screen == 2) {
            menuTitle = "Diaper";
        }

        var mv = new CustomMenuView(_screen, labels, symbols, menuTitle);
        WatchUi.pushView(mv, new CustomMenuDelegate(mv), WatchUi.SLIDE_IMMEDIATE);
    }

    function _goNext() {
        if (_screen == 1) {
            HapticHelper.subtleActionPulse();
            WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2), WatchUi.SLIDE_IMMEDIATE);
        } else if (_screen == 2) {
            // v1.0: two-screen flow only (no third screen).
            HapticHelper.subtleActionPulse();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function _goPrev() {
        if (_screen == 1) {
            // v1.0: two-screen flow only (no third screen).
            HapticHelper.subtleActionPulse();
            WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2), WatchUi.SLIDE_IMMEDIATE);
        } else if (_screen == 2) {
            HapticHelper.subtleActionPulse();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
