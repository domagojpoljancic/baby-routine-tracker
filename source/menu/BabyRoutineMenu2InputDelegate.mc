import Toybox.WatchUi;

// Not used in v1.0 — history uses HistoryDelegate. Kept as reference only.
class BabyRoutineMenu2InputDelegate extends WatchUi.Menu2InputDelegate {

    var _screen;

    function initialize(screen) {
        Menu2InputDelegate.initialize();
        _screen = screen;
    }

    function onSelect(item) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
