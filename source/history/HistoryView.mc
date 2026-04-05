import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Builds a scrollable CustomMenu of grouped feeding history (newest first).
class HistoryView {

    static function build() {
        var menuHeight = 85;
        var ds = System.getDeviceSettings();
        if (ds.screenHeight < 250) {
            menuHeight = ds.screenHeight / 4;
        } else {
            menuHeight = ds.screenHeight / 5;
        }

        var menu = new WatchUi.CustomMenu(menuHeight, Graphics.COLOR_BLACK, {});
        var store = new FeedingStore();
        var feedings = store.load();
        if (feedings == null) {
            feedings = [];
        }

        var ordered = HistoryView._newestFirstOrder(feedings);
        if (ordered.size() == 0) {
            menu.addItem(new HistoryEmptyItem());
            return menu;
        }

        System.println("HISTORY build start count=" + ordered.size());

        var prevDayKey = -1;
        var fmt = new FeedingFormatters();
        var i;
        for (i = 0; i < ordered.size(); i += 1) {
            var entry = ordered[i];
            var normalizedTs = fmt.entryTs(entry);
            if (normalizedTs == null) {
                continue;
            }

            System.println("HISTORY entry ts=" + normalizedTs);

            var dk = HistoryView._dayKey(normalizedTs);
            if (dk == null) {
                continue;
            }
            if (dk != prevDayKey) {
                System.println("HISTORY dayKey=" + dk);
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

        // HARD cast to Number using arithmetic (Monkey C safe pattern)
        var n = ts + 0;

        // Validate result
        if (n == null) {
            return null;
        }

        System.println("HISTORY ts final=" + n);

        var moment = new Time.Moment(n);
        var info = Time.Gregorian.info(moment, Time.FORMAT_LONG);

        return info.year * 10000 + info.month * 100 + info.day;
    }
}

class HistoryEmptyItem extends WatchUi.CustomMenuItem {

    function initialize() {
        CustomMenuItem.initialize(null, {});
    }

    function draw(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var fh = dc.getFontHeight(Graphics.FONT_TINY) / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            h / 2 - fh,
            Graphics.FONT_TINY,
            "No feedings yet",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
