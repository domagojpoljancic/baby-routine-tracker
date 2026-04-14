import Toybox.System;
import Toybox.WatchUi;

class OnboardingOverlayDelegate extends WatchUi.BehaviorDelegate {

    var _screen;

    function initialize(screen) {
        BehaviorDelegate.initialize();
        _screen = screen;
    }

    function _dismiss() {
        (new OnboardingHintStore()).markMenuHelperSeen();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function _dismissAndOpenMenu() {
        _dismiss();
        (new CircularNavDelegate(_screen, :stack)).openScreenMenu();
    }

    function onTap(clickEvent) {
        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        if (new MenuHotspot().hitTest(c[0], c[1], ds.screenWidth, ds.screenHeight)) {
            _dismissAndOpenMenu();
            return true;
        }
        _dismiss();
        return true;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
            _dismissAndOpenMenu();
            return true;
        }
        _dismiss();
        return true;
    }

    function onDrag(dragEvent) {
        if (dragEvent.getType() == WatchUi.DRAG_TYPE_START) {
            _dismiss();
            return true;
        }
        return false;
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            _dismissAndOpenMenu();
            return true;
        }
        _dismiss();
        return true;
    }

    function onBack() {
        _dismiss();
        return true;
    }

    function onSelect() {
        _dismiss();
        return true;
    }

    function onNextPage() {
        _dismiss();
        return true;
    }

    function onPreviousPage() {
        _dismiss();
        return true;
    }

    function onMenu() {
        _dismissAndOpenMenu();
        return true;
    }
}
