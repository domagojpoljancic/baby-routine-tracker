import Toybox.WatchUi;

class DefaultScreenSettingView {

    static function buildMenu() {
        var store = new AppSettingsStore();
        var selected = store.getDefaultScreen();

        var menu = new WatchUi.Menu2({ :title => "Default screen" });
        menu.addItem(new MenuItem(_optionLabel("Feeding", 1, selected), null, :screenFeeding, {}));
        menu.addItem(new MenuItem(_optionLabel("Diaper", 2, selected), null, :screenDiaper, {}));
        return menu;
    }

    static function _optionLabel(text, value, selected) {
        if (value == selected) {
            return "> " + text;
        }
        return text;
    }
}
