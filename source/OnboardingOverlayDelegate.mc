import Toybox.WatchUi;

class OnboardingOverlayDelegate extends WatchUi.BehaviorDelegate {

    var _screen;
    var _kind;

    function initialize(screen, kind) {
        BehaviorDelegate.initialize();
        _screen = screen;
        _kind = kind;
        if (_kind == null) {
            _kind = :menu;
        }
    }

    function _dismiss() {
        if (_kind == :menu) {
            (new OnboardingHintStore()).markManualAddHelperPending();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            (new OnboardingHintStore()).markMenuHelperSeen();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function _dismissAndOpenMenu() {
        (new OnboardingHintStore()).markMenuHelperSeen();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        (new CircularNavDelegate(_screen, :stack)).openScreenMenu();
    }

    function onTap(clickEvent) {
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
