import Toybox.System;
import Toybox.WatchUi;

class BabyRoutineMenu2InputDelegate extends WatchUi.Menu2InputDelegate {

    var _screen;

    function initialize(screen) {
        Menu2InputDelegate.initialize();
        _screen = screen;
    }

    function onSelect(item) {
        var id = item.getId();
        System.println("MENU screen=" + _screen + " item=" + id);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
