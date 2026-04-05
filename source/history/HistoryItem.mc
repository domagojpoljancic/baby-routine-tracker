import Toybox.Graphics;
import Toybox.WatchUi;

// One feeding row: time + type label. normalizedTs comes from FeedingFormatters.entryTs once in HistoryView.build.
class HistoryItem extends WatchUi.CustomMenuItem {

    var _entry;
    var _normalizedTs;

    function initialize(entry, normalizedTs) {
        CustomMenuItem.initialize(null, {});
        _entry = entry;
        _normalizedTs = normalizedTs;
    }

    function draw(dc) {
        var fmt = new FeedingFormatters();
        var line = fmt.formatHmFromTs(_normalizedTs) + " - " + fmt.typeLabel(fmt.entryType(_entry));
        var w = dc.getWidth();
        var h = dc.getHeight();
        var fh = dc.getFontHeight(Graphics.FONT_TINY) / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            h / 2 - fh,
            Graphics.FONT_TINY,
            line,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
