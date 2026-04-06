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
        var left = w * 10 / 100;
        var font = Graphics.FONT_SMALL;
        var fh = dc.getFontHeight(font);
        var ty = 2 + fh / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            left,
            ty,
            font,
            line,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
