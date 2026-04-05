import Toybox.System;
import Toybox.WatchUi;

// BehaviorDelegate: onPreviousPage/onNextPage for list scroll (KEY_UP/KEY_DOWN behaviors), onBack for KEY_ESC.
class CustomMenuDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
            _popOneLevel();
            return true;
        }
        return true;
    }

    function onPreviousPage() {
        var n = _view._labels.size();
        _view._selectedIndex -= 1;
        if (_view._selectedIndex < 0) {
            _view._selectedIndex = n - 1;
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() {
        var n = _view._labels.size();
        _view._selectedIndex = (_view._selectedIndex + 1) % n;
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        _popOneLevel();
        return true;
    }

    function onSelect() {
        _commitSelection();
        return true;
    }

    function onTap(clickEvent) {
        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var idx = _view.hitRow(c[0], c[1], ds.screenWidth, ds.screenHeight);
        if (idx < 0) {
            return false;
        }

        System.println("MENU touch row idx=" + idx);
        _view._selectedIndex = idx;
        _commitSelection();
        return true;
    }

    function _commitSelection() {
        var sym = _view._symbols[_view._selectedIndex];
        System.println("MENU commit sym=" + sym);

        if (sym == :undoLast) {
            System.println("MENU undo last selected");
            var removed = (new FeedingStore()).undoLast();
            System.println("MENU undo last removed=" + removed);
            _popOneLevel();
            WatchUi.requestUpdate();
            return;
        }

        if (sym == :start) {
            System.println("SUBMENU open Start > Left|Right|Bottle");
            var sub = new CustomMenuView(
                _view._screen,
                ["Left", "Right", "Bottle"],
                [:startLeft, :startRight, :startBottle],
                "Start"
            );
            WatchUi.pushView(sub, new CustomMenuDelegate(sub), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :startLeft) {
            System.println("SUBMENU pick Left -> feeding type 1");
            (new FeedingActions()).completeMenuFeeding(1);
            return;
        }
        if (sym == :startRight) {
            System.println("SUBMENU pick Right -> feeding type 2");
            (new FeedingActions()).completeMenuFeeding(2);
            return;
        }
        if (sym == :startBottle) {
            System.println("SUBMENU pick Bottle -> feeding type 3");
            (new FeedingActions()).completeMenuFeeding(3);
            return;
        }

        if (sym == :history) {
            var list = (new FeedingStore()).load();
            var n = 0;
            if (list != null) {
                n = list.size();
            }
            System.println("HISTORY open entries=" + n);
            var hm = HistoryView.build();
            WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        _popOneLevel();
    }

    function _popOneLevel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
