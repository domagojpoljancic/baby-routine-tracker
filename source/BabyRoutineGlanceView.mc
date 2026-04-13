import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Glance-only: reads feedings_v1 via Application.Storage (same key/schema as FeedingStore).
// No app classes — they are not loaded in the Glance execution context.
(:glance)
class BabyRoutineGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function _entryTs(entry) {
        if (entry == null) {
            return null;
        }
        var d = entry as Dictionary;
        var raw = d["ts"];
        if (raw == null) {
            raw = d[:ts];
        }
        if (raw == null) {
            return null;
        }
        return raw.toNumber();
    }

    function _entryType(entry) {
        if (entry == null) {
            return null;
        }
        var d = entry as Dictionary;
        var t = d["t"];
        if (t == null) {
            t = d[:t];
        }
        return t;
    }

    function _typeLabel(code) {
        if (code == null) {
            return "?";
        }
        var n = code.toNumber();
        if (n == 1) {
            return "Left";
        }
        if (n == 2) {
            return "Right";
        }
        if (n == 3) {
            return "Bottle";
        }
        if (n == 4) {
            return "Diaper";
        }
        return "?";
    }

    function _formatTimeFromTs(ts) {
        if (ts == null) {
            return "??:??";
        }

        if (System.getDeviceSettings().is24Hour) {
            var moment24 = new Time.Moment(ts);
            var info24 = Time.Gregorian.info(moment24, Time.FORMAT_SHORT);
            var hh = (info24.hour < 10 ? "0" : "") + info24.hour.toString();
            var mm24 = (info24.min < 10 ? "0" : "") + info24.min.toString();
            return hh + ":" + mm24;
        }

        var moment12 = new Time.Moment(ts);
        var info = Time.Gregorian.info(moment12, Time.FORMAT_SHORT);
        var h24 = info.hour;
        var mm = (info.min < 10 ? "0" : "") + info.min.toString();
        var h12;
        var suffix;
        if (h24 == 0) {
            h12 = 12;
            suffix = " AM";
        } else if (h24 < 12) {
            h12 = h24;
            suffix = " AM";
        } else if (h24 == 12) {
            h12 = 12;
            suffix = " PM";
        } else {
            h12 = h24 - 12;
            suffix = " PM";
        }

        return h12.toString() + ":" + mm + suffix;
    }

    function _formatGlanceLine(entry) {
        return _formatTimeFromTs(_entryTs(entry)) + " - " + _typeLabel(_entryType(entry));
    }

    // Same rule as main branch: TINY first, XTINY only if wider than 94% of full glance width.
    // Using full canvas width for the measure (not a reduced text column) is what keeps entries large.
    function _rowFontFor(dc, w, text) {
        var maxW = w * 94 / 100;
        var f = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(text, f) > maxW) {
            f = Graphics.FONT_XTINY;
        }
        return f;
    }

    // One font for both event rows (same TINY/XTINY tier) so line widths don’t mix sizes.
    function _eventFontForGlance(dc, w, text1, text2) {
        var maxW = w * 94 / 100;
        var f = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(text1, f) > maxW) {
            f = Graphics.FONT_XTINY;
        }
        if (text2 != null && dc.getTextWidthInPixels(text2, f) > maxW) {
            f = Graphics.FONT_XTINY;
        }
        return f;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var titleText = "Baby Routine";
        var titleFont = Graphics.FONT_XTINY;

        var list = Application.Storage.getValue("feedings_v1");
        var line1 = null;
        var line2 = null;

        var listArr = null;
        if (list != null) {
            listArr = list as Array;
        }
        var isEmpty = (listArr == null || listArr.size() == 0);
        if (isEmpty) {
            line1 = "No events";
        } else {
            var n = listArr.size();
            line1 = _formatGlanceLine(listArr[n - 1]);
            if (n >= 2) {
                line2 = _formatGlanceLine(listArr[n - 2]);
            }
        }

        var padL = 12;
        if (w < 200) {
            padL = 10;
        }

        var eventFont;
        if (isEmpty) {
            eventFont = _rowFontFor(dc, w, line1);
        } else if (line2 != null) {
            eventFont = _eventFontForGlance(dc, w, line1, line2);
        } else {
            eventFont = _rowFontFor(dc, w, line1);
        }

        var row1Font = eventFont;
        var row2Font = eventFont;

        var titleFh = dc.getFontHeight(titleFont);
        var row1Fh = dc.getFontHeight(row1Font);
        var row2Fh = line2 != null ? dc.getFontHeight(row2Font) : 0;

        var padTop = h * 6 / 100;
        if (padTop < 2) {
            padTop = 2;
        }
        var gapTitle = 2;
        var gapRows = 1;

        var titleY = padTop + titleFh / 2;
        var row1Y = titleY + titleFh / 2 + gapTitle + row1Fh / 2;
        if (isEmpty) {
            row1Y += h * 7 / 100;
        }
        var row2Y = row1Y + row1Fh / 2 + gapRows + row2Fh / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            padL,
            titleY,
            titleFont,
            titleText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            padL,
            row1Y,
            row1Font,
            line1,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        if (line2 != null) {
            dc.drawText(
                padL,
                row2Y,
                row2Font,
                line2,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}
