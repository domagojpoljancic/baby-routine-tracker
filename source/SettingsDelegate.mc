import Toybox.WatchUi;

class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    var _screen;

    function initialize(screen) {
        Menu2InputDelegate.initialize();
        _screen = screen;
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :defaultScreen) {
            WatchUi.pushView(DefaultScreenSettingView.buildMenu(), new DefaultScreenSettingDelegate(_screen), WatchUi.SLIDE_UP);
        }
    }
}
