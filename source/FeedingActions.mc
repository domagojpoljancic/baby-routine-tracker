import Toybox.WatchUi;

// Same shape as DiaperActions: append then requestUpdate. Circle taps use only that.
// Menu feeding: append, pop submenu + main menu, then requestUpdate (order preserved).
class FeedingActions {

    function appendAndRefresh(typeCode) {
        (new FeedingStore()).append(typeCode);
        WatchUi.requestUpdate();
    }

    function completeCircleTap(typeCode) {
        appendAndRefresh(typeCode);
    }

    function completeMenuFeeding(typeCode) {
        (new FeedingStore()).append(typeCode);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    }
}
