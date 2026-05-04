import Toybox.WatchUi;

// CustomMenu (Menu2): scroll via default onPreviousPage/onNextPage; back pops; select closes.
class HistoryDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if (item instanceof HistoryLoadMoreMenuItem) {
            WatchUi.pushView(
                HistoryView.buildFull(item.getHistoryMode()),
                new HistoryDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
            return;
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
