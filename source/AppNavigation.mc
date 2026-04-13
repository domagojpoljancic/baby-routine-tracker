import Toybox.System;
import Toybox.WatchUi;

// Screen indices: 1 = home (feeding UI), 2 = second, 3 = third.
// Forward: SWIPE_UP, KEY_DOWN. Back: SWIPE_DOWN, KEY_UP. SWIPE_LEFT opens menu (same as menu key / hotspot).
// onTap order — screen 1: menu hotspot, L/B/R circles, bottom half → filtered History. Screen 2: menu, diaper button, bottom half → History.
// Main menus: Garmin Menu2 + Menu2InputDelegate (same pattern as breastfeed-tracker). onMenu, KEY_ENTER, hotspot — _pushScreenMenu().
class CircularNavDelegate extends WatchUi.BehaviorDelegate {

    var _screen;

    function initialize(screen) {
        BehaviorDelegate.initialize();
        _screen = screen;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_LEFT) {
            _pushScreenMenu();
            return true;
        }
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

    // Same History modes as main menu :history (not History(all)).
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

    // Called after onboarding overlay pops so menu opens (same as hotspot / SWIPE_LEFT / KEY_ENTER).
    function openScreenMenu() {
        _pushScreenMenu();
    }

    function _pushScreenMenu() {
        var menu = MainMenuBuilder.buildMainMenu(_screen);
        WatchUi.pushView(menu, new BabyRoutineMenu2InputDelegate(_screen), WatchUi.SLIDE_UP);
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
