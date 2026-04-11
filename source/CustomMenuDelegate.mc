import Toybox.System;
import Toybox.WatchUi;

// Input for CustomMenuView: swipe/drag/keys move selection (clamped); tap or Select commits.
class CustomMenuDelegate extends WatchUi.BehaviorDelegate {

    var _view;
    var _dragAnchorY;
    var _suppressTapAfterDrag;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _dragAnchorY = 0;
        _suppressTapAfterDrag = false;
    }

    function _touchScrollInvertMult() {
        if ((new AppSettingsStore()).scrollInvertEnabled()) {
            return -1;
        }
        return 1;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_RIGHT) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
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

    function onDrag(dragEvent) {
        var t = dragEvent.getType();
        var c = dragEvent.getCoordinates();
        var y = c[1];
        var ds = System.getDeviceSettings();
        var h = ds.screenHeight;
        var step = _view._rowPitch(h);
        if (step < 1) {
            step = 1;
        }

        if (t == WatchUi.DRAG_TYPE_START) {
            _dragAnchorY = y;
            _suppressTapAfterDrag = false;
            return true;
        }

        if (t == WatchUi.DRAG_TYPE_CONTINUE) {
            var m = _touchScrollInvertMult();
            var delta = y - _dragAnchorY;
            if (delta <= -step) {
                var steps = ((0 - delta) / step).toNumber();
                if (steps > 0) {
                    if (_moveSelection(m * steps, true) != 0) {
                        _suppressTapAfterDrag = true;
                    }
                    _dragAnchorY -= steps * step;
                }
            } else if (delta >= step) {
                var stepsDown = (delta / step).toNumber();
                if (stepsDown > 0) {
                    if (_moveSelection(m * (0 - stepsDown), true) != 0) {
                        _suppressTapAfterDrag = true;
                    }
                    _dragAnchorY += stepsDown * step;
                }
            }
            return true;
        }

        if (t == WatchUi.DRAG_TYPE_STOP) {
            return true;
        }

        return false;
    }

    function onTap(clickEvent) {
        if (_suppressTapAfterDrag) {
            _suppressTapAfterDrag = false;
            return true;
        }

        var c = clickEvent.getCoordinates();
        var ds = System.getDeviceSettings();
        var w = ds.screenWidth;
        var h = ds.screenHeight;
        var row = _view.hitRow(c[0], c[1], w, h);
        if (row < 0) {
            return false;
        }

        _view._selectedIndex = row;
        WatchUi.requestUpdate();
        _commitAtIndex(row);
        return true;
    }

    function onNextPage() {
        _moveSelection(1, true);
        return true;
    }

    function onPreviousPage() {
        _moveSelection(-1, true);
        return true;
    }

    function onSelect() {
        _commitAtIndex(_view._selectedIndex);
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onKey(keyEvent) {
        var k = keyEvent.getKey();
        if (k == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        }
        if (k == WatchUi.KEY_ENTER) {
            _commitAtIndex(_view._selectedIndex);
            return true;
        }
        if (k == WatchUi.KEY_DOWN) {
            _moveSelection(1, true);
            return true;
        }
        if (k == WatchUi.KEY_UP) {
            _moveSelection(-1, true);
            return true;
        }
        return false;
    }

    function _emitSelectionHaptic() {
        HapticHelper.subtleActionPulse();
    }

    // Returns 0 if index unchanged, non-zero if moved.
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
        return 1;
    }

    function _commitAtIndex(idx) {
        var n = _view._labels.size();
        if (idx < 0 || idx >= n) {
            return;
        }

        var sym = _view._symbols[idx];
        var screen = _view._screen;

        if (sym == :undoLast) {
            if ((new FeedingStore()).undoLastForScreen(screen)) {
                HapticHelper.subtleActionPulse();
            }
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
            return;
        }

        if (sym == :start) {
            HapticHelper.subtleActionPulse();
            var sub = new CustomMenuView(
                screen,
                ["Left", "Bottle", "Right"],
                [:feedLeft, :feedBottle, :feedRight],
                "Start"
            );
            WatchUi.pushView(sub, new CustomMenuDelegate(sub), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :addDiaper) {
            (new DiaperActions()).completeAddDiaper();
            HapticHelper.subtleActionPulse();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :history) {
            HapticHelper.subtleActionPulse();
            var hm;
            if (screen == 2) {
                hm = HistoryView.build(:diaperOnly);
            } else {
                hm = HistoryView.build(:feedingOnly);
            }
            WatchUi.pushView(hm, new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :historyAll) {
            HapticHelper.subtleActionPulse();
            WatchUi.pushView(HistoryView.build(:all), new HistoryDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :settings) {
            HapticHelper.subtleActionPulse();
            var sv = new SettingsView();
            WatchUi.pushView(sv, new SettingsDelegate(sv), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :about) {
            HapticHelper.subtleActionPulse();
            var aboutView = new AboutView();
            WatchUi.pushView(aboutView, new AboutDelegate(aboutView), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        if (sym == :feedLeft) {
            (new FeedingActions()).completeMenuFeeding(1);
            HapticHelper.subtleActionPulse();
            return;
        }
        if (sym == :feedBottle) {
            (new FeedingActions()).completeMenuFeeding(3);
            HapticHelper.subtleActionPulse();
            return;
        }
        if (sym == :feedRight) {
            (new FeedingActions()).completeMenuFeeding(2);
            HapticHelper.subtleActionPulse();
            return;
        }
    }
}
