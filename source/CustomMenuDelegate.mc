import Toybox.Attention;
import Toybox.System;
import Toybox.WatchUi;

// BehaviorDelegate: onPreviousPage/onNextPage for list scroll (KEY_UP/KEY_DOWN behaviors), onBack for KEY_ESC.
class CustomMenuDelegate extends WatchUi.BehaviorDelegate {

    var _view;
    var _dragActive;
    var _dragAnchorY;
    var _didDragMove;
    var _suppressNextTap;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _dragActive = false;
        _dragAnchorY = 0;
        _didDragMove = false;
        _suppressNextTap = false;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_RIGHT) {
            _popOneLevel();
            return true;
        }
        if (dir == WatchUi.SWIPE_UP) {
            _moveSelection(1, true);
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _moveSelection(-1, true);
            return true;
        }
        // Consume other swipe directions so they do not reach the view stack below the menu.
        return true;
    }

    function onPreviousPage() {
        _moveSelection(-1, true);
        return true;
    }

    function onNextPage() {
        _moveSelection(1, true);
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

    function onHold(clickEvent) {
        var c = clickEvent.getCoordinates();
        _dragActive = true;
        _dragAnchorY = c[1];
        _didDragMove = false;
        return true;
    }

    function onDrag(dragEvent) {
        var c = dragEvent.getCoordinates();
        var y = c[1];

        if (!_dragActive) {
            _dragActive = true;
            _dragAnchorY = y;
            _didDragMove = false;
            return true;
        }

        var ds = System.getDeviceSettings();
        var step = _view._rowPitch(ds.screenHeight) / 2;
        if (step < 6) {
            step = 6;
        }

        var delta = y - _dragAnchorY;
        if (delta <= -step) {
            var stepsDown = ((0 - delta) / step).toNumber();
            if (stepsDown > 0) {
                if (_moveSelection(stepsDown, true) != 0) {
                    _didDragMove = true;
                }
                _dragAnchorY -= stepsDown * step;
            }
        } else if (delta >= step) {
            var stepsUp = (delta / step).toNumber();
            if (stepsUp > 0) {
                if (_moveSelection(0 - stepsUp, true) != 0) {
                    _didDragMove = true;
                }
                _dragAnchorY += stepsUp * step;
            }
        }

        return true;
    }

    function onRelease(clickEvent) {
        if (_dragActive) {
            _dragActive = false;
            if (_didDragMove) {
                _didDragMove = false;
                _suppressNextTap = true;
                return true;
            }
        }
        return false;
    }

    function onTap(clickEvent) {
        if (_suppressNextTap) {
            _suppressNextTap = false;
            return true;
        }

        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var idx = _view.hitRow(c[0], c[1], ds.screenWidth, ds.screenHeight);
        if (idx < 0) {
            return false;
        }

        var oldIdx = _view._selectedIndex;
        _view._selectedIndex = idx;
        _view.ensureSelectionVisible(ds.screenHeight);
        WatchUi.requestUpdate();
        if (oldIdx != idx) {
            _emitSelectionHaptic();
        }
        _commitSelection();
        return true;
    }

    function _moveSelection(delta, withHaptic) {
        var n = _view._labels.size();
        if (n <= 0) {
            return 0;
        }

        var oldIdx = _view._selectedIndex;
        var idx = oldIdx + delta;
        if (idx < 0) {
            idx = 0;
        }
        if (idx >= n) {
            idx = n - 1;
        }
        if (idx == oldIdx) {
            return 0;
        }

        _view._selectedIndex = idx;
        var ds = System.getDeviceSettings();
        _view.ensureSelectionVisible(ds.screenHeight);
        WatchUi.requestUpdate();

        if (withHaptic) {
            _emitSelectionHaptic();
        }
        return idx - oldIdx;
    }

    function _emitSelectionHaptic() {
        if (Attention has :vibrate && Attention has :VibeProfile) {
            var vibe = new Attention.VibeProfile(25, 30);
            Attention.vibrate([vibe]);
        }
    }

    function _commitSelection() {
        var sym = _view._symbols[_view._selectedIndex];

        if (sym == :undoLast) {
            var scr = _view._screen;
            (new FeedingStore()).undoLastForScreen(scr);
            _popOneLevel();
            WatchUi.requestUpdate();
            return;
        }

        if (sym == :addDiaper) {
            (new DiaperActions()).completeAddDiaper();
            _popOneLevel();
            return;
        }

        if (sym == :start) {
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
            (new FeedingActions()).completeMenuFeeding(1);
            return;
        }
        if (sym == :startRight) {
            (new FeedingActions()).completeMenuFeeding(2);
            return;
        }
        if (sym == :startBottle) {
            (new FeedingActions()).completeMenuFeeding(3);
            return;
        }

        if (sym == :history) {
            var scr = _view._screen;
            var hm;
            if (scr == 2) {
                hm = HistoryView.build(:diaperOnly);
            } else {
                hm = HistoryView.build(:feedingOnly);
            }
            WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :historyAll) {
            var hm = HistoryView.build(:all);
            WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        _popOneLevel();
    }

    function _popOneLevel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
