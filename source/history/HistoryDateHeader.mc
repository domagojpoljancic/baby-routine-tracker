import Toybox.Graphics;
import Toybox.Time;
import Toybox.WatchUi;

// Date section header (distinct from feeding rows). ts is numeric from FeedingFormatters.entryTs (HistoryView.build only).
class HistoryDateHeader extends WatchUi.CustomMenuItem {

    var _ts;
    var _firstHeader;
    var _dayCount;

    function initialize(ts, firstHeader, dayCount) {
        CustomMenuItem.initialize(null, {});
        _ts = ts;
        _firstHeader = firstHeader;
        _dayCount = dayCount;
    }

    function draw(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var padX = w * 10 / 100;

        var moment = new Time.Moment(_ts);
        var info = Time.Gregorian.info(moment, Time.FORMAT_LONG);
        var dateStr = info.day.toString() + " " + info.month.toString() + " " + info.year.toString() + " - #" + _dayCount.toString();

        var font = Graphics.FONT_XTINY;
        var fh = dc.getFontHeight(font);

        // Anchor date near bottom of row so the next entry row can sit tight (reduces dead space vs vertical centering).
        var bottomPad = 3;
        var cy = h - bottomPad - fh / 2;
        if (cy < fh / 2 + 1) {
            cy = fh / 2 + 1;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            cy,
            font,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var lineY = cy + fh / 2 + 1;
        if (lineY >= h) {
            lineY = h - 1;
        }
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(padX, lineY, w - padX, lineY);
    }
}
