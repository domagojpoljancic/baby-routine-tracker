import Toybox.WatchUi;

class HowItWorksDelegate extends WatchUi.BehaviorDelegate {

    var _view;
    var _dragLastY;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _dragLastY = 0;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            _nudgeScroll(1);
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _nudgeScroll(-1);
            return true;
        }
        return false;
    }

    function onNextPage() {
        _nudgeScroll(1);
        return true;
    }

    function onPreviousPage() {
        _nudgeScroll(-1);
        return true;
    }

    function onDrag(dragEvent) {
        var t = dragEvent.getType();
        var c = dragEvent.getCoordinates();
        var y = c[1];

        if (t == WatchUi.DRAG_TYPE_START) {
            _dragLastY = y;
            return true;
        }
        if (t == WatchUi.DRAG_TYPE_CONTINUE) {
            var dy = y - _dragLastY;
            _dragLastY = y;
            _view._scrollY -= dy;
            WatchUi.requestUpdate();
            return true;
        }
        if (t == WatchUi.DRAG_TYPE_STOP) {
            return true;
        }
        return false;
    }

    function onKey(keyEvent) {
        var k = keyEvent.getKey();
        if (k == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        if (k == WatchUi.KEY_DOWN) {
            _nudgeScroll(1);
            return true;
        }
        if (k == WatchUi.KEY_UP) {
            _nudgeScroll(-1);
            return true;
        }
        return false;
    }

    function _nudgeScroll(direction) {
        var step = _view._scrollLineStep;
        if (step <= 0) {
            step = 24;
        }
        _view._scrollY += direction * step;
        WatchUi.requestUpdate();
    }
}
