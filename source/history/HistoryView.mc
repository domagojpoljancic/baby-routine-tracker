import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Builds a scrollable CustomMenu of grouped feeding history (newest first).
class HistoryView {

    // mode: :feedingOnly (default) = t in {1,2,3}; :diaperOnly = t==4; :all = no type filter.
    static function build(mode) {
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

        var menu = new WatchUi.CustomMenu(menuHeight, Graphics.COLOR_BLACK, {});
        var store = new FeedingStore();
        var feedings = store.load();
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

        var ordered = HistoryView._newestFirstOrder(feedings);
        if (ordered.size() == 0) {
            if (mode == :diaperOnly) {
                menu.addItem(new HistoryEmptyItem("No diapers yet"));
            } else {
                menu.addItem(new HistoryEmptyItem(null));
            }
            return menu;
        }

        var prevDayKey = -1;
        var fmt = new FeedingFormatters();
        var i;
        for (i = 0; i < ordered.size(); i += 1) {
            var entry = ordered[i];
            var normalizedTs = fmt.entryTs(entry);
            if (normalizedTs == null) {
                continue;
            }

            var dk = HistoryView._dayKey(normalizedTs);
            if (dk == null) {
                continue;
            }
            if (dk != prevDayKey) {
                menu.addItem(new HistoryDateHeader(normalizedTs, prevDayKey == -1));
                prevDayKey = dk;
            }

            menu.addItem(new HistoryItem(entry, normalizedTs));
        }

        return menu;
    }

    static function _newestFirstOrder(feedings) {
        var out = [];
        var n = feedings.size();
        var j;
        for (j = n - 1; j >= 0; j -= 1) {
            out.add(feedings[j]);
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
        var h = dc.getHeight();
        var left = w * 10 / 100;

        var fh = dc.getFontHeight(Graphics.FONT_SMALL);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            left,
            2 + fh / 2,
            Graphics.FONT_SMALL,
            _message,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
