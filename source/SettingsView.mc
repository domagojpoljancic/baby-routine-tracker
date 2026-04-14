import Toybox.WatchUi;

class SettingsView {

    static function buildMenu() {
        var menu = new WatchUi.Menu2({ :title => "Settings" });
        menu.addItem(new MenuItem("Default screen", null, :defaultScreen, {}));
        return menu;
    }
}
