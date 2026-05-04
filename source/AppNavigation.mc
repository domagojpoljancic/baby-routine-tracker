import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Screen indices: 1 = home (feeding UI), 2 = second, 3 = third.
// Forward: SWIPE_UP, KEY_DOWN. Back: SWIPE_DOWN, KEY_UP. SWIPE_LEFT opens menu (same as menu key).
// onTap order — screen 1: L/B/R circles, bottom half → filtered History. Screen 2: diaper button, bottom half → History.
// Main menus: Garmin Menu2 + Menu2InputDelegate (same pattern as breastfeed-tracker). onMenu + KEY_ENTER — _pushScreenMenu().
class CircularNavDelegate extends WatchUi.BehaviorDelegate {

    var _screen;
    var _navMode;
    var _holdSuppressUntil;

    function initialize(screen, navMode) {
        BehaviorDelegate.initialize();
        _screen = screen;
        _navMode = navMode;
        _holdSuppressUntil = 0;
        if (_navMode == null) {
            _navMode = :stack;
        }
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
        if (_shouldSuppressTapAfterHold()) {
            return true;
        }

        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var x = c[0];
        var y = c[1];
        var h = ds.screenHeight;

        if (_screen == 1) {
            var result = new FeedingTouchLayout().hitCircle(x, y, ds.screenWidth, h);
            if (result != null) {
                HapticHelper.subtleActionPulse();
                (new FeedingActions()).completeCircleTap(result);
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
                HapticHelper.subtleActionPulse();
                (new DiaperActions()).completeAddDiaper();
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

    function onHold(clickEvent) {
        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var x = c[0];
        var y = c[1];
        var h = ds.screenHeight;

        if (_screen == 1) {
            var feedingType = new FeedingTouchLayout().hitCircle(x, y, ds.screenWidth, h);
            if (feedingType != null) {
                _markHoldHandled();
                ManualAddFlow.openTimeSelector(feedingType, 0);
                HapticHelper.subtleActionPulse();
                return true;
            }
        } else if (_screen == 2) {
            if (new DiaperTouchLayout().hitDiaperButton(x, y, ds.screenWidth, h)) {
                _markHoldHandled();
                ManualAddFlow.openTimeSelector(4, 0);
                HapticHelper.subtleActionPulse();
                return true;
            }
        }

        return false;
    }

    function onRelease(clickEvent) {
        if (_holdSuppressUntil > 0) {
            return true;
        }

        return false;
    }

    function _markHoldHandled() {
        _holdSuppressUntil = Time.now().value() + 2;
    }

    function _shouldSuppressTapAfterHold() {
        if (_holdSuppressUntil <= 0) {
            return false;
        }

        if (Time.now().value() <= _holdSuppressUntil) {
            _holdSuppressUntil = 0;
            return true;
        }

        _holdSuppressUntil = 0;
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
        (new OnboardingHintStore()).markMenuHelperSeen();
        var menu = MainMenuBuilder.buildMainMenu(_screen);
        WatchUi.pushView(menu, new BabyRoutineMenu2InputDelegate(_screen), WatchUi.SLIDE_UP);
    }

    function _goNext() {
        if (_screen == 1) {
            HapticHelper.subtleActionPulse();
            if (_navMode == :switch) {
                WatchUi.switchToView(new SecondScreenView(), new CircularNavDelegate(2, :switch), WatchUi.SLIDE_IMMEDIATE);
            } else {
                WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2, :stack), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (_screen == 2) {
            HapticHelper.subtleActionPulse();
            if (_navMode == :switch) {
                WatchUi.switchToView(new HelloGarminView(), new CircularNavDelegate(1, :switch), WatchUi.SLIDE_IMMEDIATE);
            } else {
                // v1.0: two-screen flow only (no third screen).
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function _goPrev() {
        if (_screen == 1) {
            HapticHelper.subtleActionPulse();
            if (_navMode == :switch) {
                WatchUi.switchToView(new SecondScreenView(), new CircularNavDelegate(2, :switch), WatchUi.SLIDE_IMMEDIATE);
            } else {
                // v1.0: two-screen flow only (no third screen).
                WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2, :stack), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (_screen == 2) {
            HapticHelper.subtleActionPulse();
            if (_navMode == :switch) {
                WatchUi.switchToView(new HelloGarminView(), new CircularNavDelegate(1, :switch), WatchUi.SLIDE_IMMEDIATE);
            } else {
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
