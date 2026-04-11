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

    function onTap(clickEvent) {
        var c = clickEvent.getCoordinates();
        if (_view.hitScrollInvertRow(c[0], c[1])) {
            var store = new AppSettingsStore();
            store.setScrollInvert(!store.scrollInvertEnabled());
            HapticHelper.subtleActionPulse();
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
}
