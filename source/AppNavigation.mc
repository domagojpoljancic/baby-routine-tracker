import Toybox.System;
import Toybox.WatchUi;

// Screen indices: 1 = home (feeding UI), 2 = second, 3 = third.
// Forward: SWIPE_UP, KEY_DOWN. Back: SWIPE_DOWN, KEY_UP. Circular via push/pop stack.
// Feeding input on screen 1: touch taps on L/B/R circles only (see onTap).
class CircularNavDelegate extends WatchUi.InputDelegate {

    var _screen;

    function initialize(screen) {
        InputDelegate.initialize();
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
        if (_screen != 1) {
            return false;
        }

        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();

        var x = c[0];
        var y = c[1];

        var result = new FeedingTouchLayout().hitCircle(x, y, ds.screenWidth, ds.screenHeight);

        if (result == null) {
            return false;
        }

        (new FeedingStore()).append(result);

        var vu = WatchUi.getCurrentView();
        if (vu != null) {
            var top = vu[0];
            if (top != null && top has :noteCircleFlash) {
                top.noteCircleFlash(result);
            }
        }

        WatchUi.requestUpdate();

        return true;
    }

    function onKey(keyEvent) {
        var k = keyEvent.getKey();

        // TEMP DEBUG ONLY: clear feeding history on home (KEY_MENU not used for navigation).
        if (_screen == 1 && k == WatchUi.KEY_MENU) {
            (new FeedingStore()).clearAll();
            WatchUi.requestUpdate();
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

    function _goNext() {
        if (_screen == 1) {
            WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2), WatchUi.SLIDE_IMMEDIATE);
        } else if (_screen == 2) {
            WatchUi.pushView(new ThirdScreenView(), new CircularNavDelegate(3), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function _goPrev() {
        if (_screen == 1) {
            WatchUi.pushView(new SecondScreenView(), new CircularNavDelegate(2), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new ThirdScreenView(), new CircularNavDelegate(3), WatchUi.SLIDE_IMMEDIATE);
        } else if (_screen == 2) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
