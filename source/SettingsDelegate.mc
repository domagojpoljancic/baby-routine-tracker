import Toybox.WatchUi;

class SettingsDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        return false;
    }
}
