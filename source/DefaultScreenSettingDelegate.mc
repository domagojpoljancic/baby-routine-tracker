import Toybox.WatchUi;

class DefaultScreenSettingDelegate extends WatchUi.Menu2InputDelegate {

    var _screen;

    function initialize(screen) {
        Menu2InputDelegate.initialize();
        _screen = screen;
    }

    function onSelect(item) {
        var id = item.getId();
        var store = new AppSettingsStore();
        var selectedScreen = 1;

        if (id == :screenDiaper) {
            store.setDefaultScreen(2);
            selectedScreen = 2;
        } else {
            store.setDefaultScreen(1);
        }

        // Close selection, settings, and the parent main menu.
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);

        if (selectedScreen == _screen) {
            return;
        }

        if (selectedScreen == 2) {
            WatchUi.switchToView(new SecondScreenView(), new CircularNavDelegate(2, :switch), WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        WatchUi.switchToView(new HelloGarminView(), new CircularNavDelegate(1, :switch), WatchUi.SLIDE_IMMEDIATE);
    }
}
