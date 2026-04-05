import Toybox.WatchUi;

// Shared feeding commit path for circle taps and menu (Start > Left/Right/Bottle).
class FeedingActions {

    // Home screen is top view; flash applies to HelloGarminView.
    function completeCircleTap(typeCode) {
        (new FeedingStore()).append(typeCode);
        _flashHomeIfTop(typeCode);
        WatchUi.requestUpdate();
    }

    // Submenu + main menu sit above home; append, pop both, then flash on restored home view.
    function completeMenuFeeding(typeCode) {
        (new FeedingStore()).append(typeCode);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        _flashHomeIfTop(typeCode);
        WatchUi.requestUpdate();
    }

    function _flashHomeIfTop(typeCode) {
        var vu = WatchUi.getCurrentView();
        if (vu != null && vu[0] != null && vu[0] has :noteCircleFlash) {
            vu[0].noteCircleFlash(typeCode);
        }
    }
}
