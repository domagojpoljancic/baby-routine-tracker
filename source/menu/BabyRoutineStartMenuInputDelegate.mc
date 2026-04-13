import Toybox.WatchUi;

// Start submenu: Left / Bottle / Right (reference app lists these as primary menu items).
class BabyRoutineStartMenuInputDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :feedLeft) {
            (new FeedingActions()).completeMenuFeeding(1);
            HapticHelper.subtleActionPulse();
            return;
        }
        if (id == :feedBottle) {
            (new FeedingActions()).completeMenuFeeding(3);
            HapticHelper.subtleActionPulse();
            return;
        }
        if (id == :feedRight) {
            (new FeedingActions()).completeMenuFeeding(2);
            HapticHelper.subtleActionPulse();
            return;
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
