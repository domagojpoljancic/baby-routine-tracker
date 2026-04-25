import Toybox.WatchUi;

// Builds Garmin-native Menu2 lists (same pattern as breastfeed-tracker MainMenuBuilder).
class MainMenuBuilder {

    static function buildMainMenu(screen) {
        var title = "Menu";
        if (screen == 1) {
            title = "Feeding";
        } else if (screen == 2) {
            title = "Diaper";
        }

        var menu = new WatchUi.Menu2({ :title => title });

        if (screen == 1) {
            menu.addItem(new MenuItem("Undo last", null, :undoLast, {}));
            menu.addItem(new MenuItem("Start", null, :start, {}));
            menu.addItem(new MenuItem("Add manually", null, :addManually, {}));
            menu.addItem(new MenuItem("History", null, :history, {}));
            menu.addItem(new MenuItem("History(all)", null, :historyAll, {}));
            menu.addItem(new MenuItem("Settings", null, :settings, {}));
            menu.addItem(new MenuItem("How it works", null, :howItWorks, {}));
            menu.addItem(new MenuItem("About", null, :about, {}));
        } else if (screen == 2) {
            menu.addItem(new MenuItem("Undo last", null, :undoLast, {}));
            menu.addItem(new MenuItem("Add diaper", null, :addDiaper, {}));
            menu.addItem(new MenuItem("Add manually", null, :addManually, {}));
            menu.addItem(new MenuItem("History", null, :history, {}));
            menu.addItem(new MenuItem("History(all)", null, :historyAll, {}));
            menu.addItem(new MenuItem("Settings", null, :settings, {}));
            menu.addItem(new MenuItem("How it works", null, :howItWorks, {}));
            menu.addItem(new MenuItem("About", null, :about, {}));
        } else {
            menu.addItem(new MenuItem("Undo last", null, :undoLast, {}));
            menu.addItem(new MenuItem("Item 1", null, :item1, {}));
            menu.addItem(new MenuItem("Item 2", null, :item2, {}));
        }

        return menu;
    }

    static function buildStartMenu() {
        var menu = new WatchUi.Menu2({ :title => "Start" });
        menu.addItem(new MenuItem("Left", null, :feedLeft, {}));
        menu.addItem(new MenuItem("Bottle", null, :feedBottle, {}));
        menu.addItem(new MenuItem("Right", null, :feedRight, {}));
        return menu;
    }

    static function buildManualFeedingTypeMenu() {
        var menu = new WatchUi.Menu2({ :title => "Add manually" });
        menu.addItem(new MenuItem("Left", null, :manualFeedLeft, {}));
        menu.addItem(new MenuItem("Bottle", null, :manualFeedBottle, {}));
        menu.addItem(new MenuItem("Right", null, :manualFeedRight, {}));
        return menu;
    }
}
