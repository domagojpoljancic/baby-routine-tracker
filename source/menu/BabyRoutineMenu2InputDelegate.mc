import Toybox.WatchUi;

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
