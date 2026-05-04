import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Default history window: local calendar days including today (reduces menu build cost).
const HISTORY_WINDOW_DAYS = 7;

// Builds a scrollable CustomMenu of grouped feeding history (newest first).
class HistoryView {

    // mode: :feedingOnly (default) = t in {1,2,3}; :diaperOnly = t==4; :all = no type filter.
    // Opens a rolling window of the last HISTORY_WINDOW_DAYS; use buildFull for the entire list.
    static function build(mode) {
        return _build(mode, HISTORY_WINDOW_DAYS);
    }

    static function buildFull(mode) {
        return _build(mode, null);
    }

    static function _build(mode, windowDaysOrNull) {
        var menuHeight = HistoryView._computeMenuRowHeight();
        var menu = new WatchUi.CustomMenu(menuHeight, Graphics.COLOR_BLACK, {});
        var store = new FeedingStore();
        var feedings = store.load(true);
        if (feedings == null) {
            feedings = [];
        }

        if (mode == null) {
            mode = :feedingOnly;
        }

        if (mode == :all) {
            // keep full list
        } else if (mode == :diaperOnly) {
            feedings = (new FeedingFormatters()).filterDiaperEntries(feedings);
        } else if (mode == :feedingOnly) {
            feedings = (new FeedingFormatters()).filterFeedingEntries(feedings);
        }

        var fmt = new FeedingFormatters();
        var minTs = null;
        var hasOlderOutsideWindow = false;
        if (windowDaysOrNull != null && windowDaysOrNull > 0) {
            minTs = Time.today().value() -
                (windowDaysOrNull.toNumber() - 1) * Time.Gregorian.SECONDS_PER_DAY;
            hasOlderOutsideWindow = HistoryView._hasEntryBeforeMinTs(feedings, minTs, fmt);
            feedings = HistoryView._entriesOnOrAfterMinTs(feedings, minTs, fmt);
        }

        var ordered = HistoryView._newestFirstOrder(feedings) as Array;
        if (ordered.size() == 0) {
            if (windowDaysOrNull != null && windowDaysOrNull > 0 && hasOlderOutsideWindow) {
                menu.addItem(new HistoryEmptyItem(
                    "No entries in last " + windowDaysOrNull.toNumber().toString() + " days"
                ));
                menu.addItem(new HistoryLoadMoreMenuItem(mode));
                return menu;
            }
            menu.addItem(new HistoryEmptyItem(HistoryView._emptyMessageForMode(mode)));
            return menu;
        }

        var prevDayKey = -1;
        var i;
        var ordSize = ordered.size();
        for (i = 0; i < ordSize; i += 1) {
            var ii = i;
            var entry = ordered[ii];
            var normalizedTs = fmt.entryTs(entry);
            if (normalizedTs == null) {
                continue;
            }

            var dk = HistoryView._dayKey(normalizedTs);
            if (dk == null) {
                continue;
            }
            if (dk != prevDayKey) {
                var dayCount = HistoryView._countEntriesForDayFrom(ordered, i, dk, fmt);
                menu.addItem(new HistoryDateHeader(normalizedTs, prevDayKey == -1, dayCount));
                prevDayKey = dk;
            }

            menu.addItem(new HistoryItem(entry, normalizedTs));
        }

        if (windowDaysOrNull != null && windowDaysOrNull > 0 && hasOlderOutsideWindow) {
            menu.addItem(new HistoryLoadMoreMenuItem(mode));
        }

        return menu;
    }

    static function _emptyMessageForMode(mode) {
        if (mode == :diaperOnly) {
            return "No diapers yet";
        }
        if (mode == :all) {
            return "No entries yet";
        }
        return null;
    }

    static function _computeMenuRowHeight() {
        var ds = System.getDeviceSettings();
        var menuHeight;
        if (ds.screenHeight < 250) {
            menuHeight = ds.screenHeight * 15 / 100;
        } else {
            menuHeight = ds.screenHeight * 12 / 100;
        }
        if (menuHeight < 44) {
            menuHeight = 44;
        }
        return menuHeight;
    }

    static function _hasEntryBeforeMinTs(entries, minTs, fmt) {
        if (entries == null || !(entries instanceof Array) || minTs == null) {
            return false;
        }

        var arr = entries as Array;
        var i;
        for (i = 0; i < arr.size(); i += 1) {
            var ts = fmt.entryTs(arr[i]);
            if (ts != null && ts < minTs) {
                return true;
            }
        }
        return false;
    }

    static function _entriesOnOrAfterMinTs(entries, minTs, fmt) {
        if (entries == null || !(entries instanceof Array) || minTs == null) {
            return [];
        }

        var out = [];
        var arr = entries as Array;
        var i;
        for (i = 0; i < arr.size(); i += 1) {
            var ts = fmt.entryTs(arr[i]);
            if (ts != null && ts >= minTs) {
                out.add(arr[i]);
            }
        }
        return out;
    }

    static function _newestFirstOrder(feedings) {
        var out = [];
        var arr = feedings as Array;
        var n = arr.size();
        var j;
        for (j = n - 1; j >= 0; j -= 1) {
            var jj = j;
            var entry = arr[jj];
            out.add(entry);
        }
        return out;
    }

    static function _dayKey(ts) {
        if (ts == null) {
            return null;
        }

        var moment = new Time.Moment(ts);

        // IMPORTANT: FORMAT_SHORT ensures numeric month/day/year for arithmetic
        var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

        var dk = info.year * 10000 + info.month * 100 + info.day;

        return dk;
    }

    static function _countEntriesForDayFrom(ordered, startIndex, dayKey, fmt) {
        var count = 0;
        var n = ordered.size();
        var i;
        for (i = startIndex; i < n; i += 1) {
            var entry = ordered[i];
            var ts = fmt.entryTs(entry);
            if (ts == null) {
                continue;
            }
            var currentDay = HistoryView._dayKey(ts);
            if (currentDay == null) {
                continue;
            }
            if (currentDay != dayKey) {
                break;
            }
            count += 1;
        }
        return count;
    }
}

class HistoryEmptyItem extends WatchUi.CustomMenuItem {

    var _message;

    function initialize(emptyMessage) {
        CustomMenuItem.initialize(null, {});
        if (emptyMessage == null) {
            _message = "No feedings yet";
        } else {
            _message = emptyMessage;
        }
    }

    function draw(dc) {
        var w = dc.getWidth();
        var cx = w / 2;

        var fh = dc.getFontHeight(Graphics.FONT_SMALL);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            2 + fh / 2,
            Graphics.FONT_SMALL,
            _message,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

// Footer row: opens full history (all stored entries for this mode).
class HistoryLoadMoreMenuItem extends WatchUi.CustomMenuItem {

    var _mode;

    function initialize(historyMode) {
        CustomMenuItem.initialize(null, {});
        _mode = historyMode;
    }

    function getHistoryMode() {
        return _mode;
    }

    function draw(dc) {
        var w = dc.getWidth();
        var cx = w / 2;
        var font = Graphics.FONT_SMALL;
        var fh = dc.getFontHeight(font);
        var ty = 2 + fh / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            ty,
            font,
            "Older entries…",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
