import Toybox.WatchUi;

// Shared path for screen 2 diaper add: big button and menu "Add diaper".
class DiaperActions {

    function completeAddDiaper() {
        (new FeedingStore()).append(4);
        WatchUi.requestUpdate();
    }
}
