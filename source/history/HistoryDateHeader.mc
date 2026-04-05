import Toybox.Graphics;
import Toybox.Time;
import Toybox.WatchUi;

// Date section header (distinct from feeding rows). ts is numeric from FeedingFormatters.entryTs (HistoryView.build only).
class HistoryDateHeader extends WatchUi.CustomMenuItem {

    var _ts;
    var _firstHeader;

    function initialize(ts, firstHeader) {
        CustomMenuItem.initialize(null, {});
        _ts = ts;
        _firstHeader = firstHeader;
    }

    function draw(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var y = 0;

        if (!_firstHeader) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(0, y, w, y);
            y += 2;
        }

        var moment = new Time.Moment(_ts);
        var info = Time.Gregorian.info(moment, Time.FORMAT_LONG);
        var dateStr = info.day.toString() + "/" + info.month.toString() + "/" + info.year.toString();

        var cy = y + dc.getFontHeight(Graphics.FONT_TINY) / 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            cy,
            Graphics.FONT_TINY,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        var lineY = h - 2;
        if (lineY < 0) {
            lineY = 0;
        }
        dc.drawLine(w * 8 / 100, lineY, w * 92 / 100, lineY);
    }
}
