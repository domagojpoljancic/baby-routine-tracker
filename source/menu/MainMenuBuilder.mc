import Toybox.WatchUi;

class MainMenuBuilder {

    static function buildMenu(screen) {
        var menu = new WatchUi.Menu2({ :title => "Menu" });

        if (screen == 1) {
            menu.addItem(new MenuItem("Undo last", null, :undoLast, {}));
            menu.addItem(new MenuItem("Start", null, :start, {}));
            menu.addItem(new MenuItem("History", null, :history, {}));
            menu.addItem(new MenuItem("Settings", null, :settings, {}));
            menu.addItem(new MenuItem("About", null, :about, {}));
        } else {
            menu.addItem(new MenuItem("Item 1", null, :item1, {}));
            menu.addItem(new MenuItem("Item 2", null, :item2, {}));
        }

        return menu;
    }
}
