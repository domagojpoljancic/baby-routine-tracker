import Toybox.Application;
import Toybox.Graphics;
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
        var raw = entry["ts"];
        if (raw == null) {
            raw = entry[:ts];
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
        var t = entry["t"];
        if (t == null) {
            t = entry[:t];
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

    function _rowFontFor(dc, maxLineWidth, text) {
        var f = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(text, f) > maxLineWidth) {
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

        if (list == null || list.size() == 0) {
            line1 = "No events";
        } else {
            var n = list.size();
            line1 = _formatGlanceLine(list[n - 1]);
            if (n >= 2) {
                line2 = _formatGlanceLine(list[n - 2]);
            }
        }

        var padL = 12;
        if (w < 200) {
            padL = 10;
        }
        var maxLineW = w - padL - 8;
        if (maxLineW < 40) {
            maxLineW = 40;
        }

        var row1Font = _rowFontFor(dc, maxLineW, line1);
        var row2Font = line2 != null ? _rowFontFor(dc, maxLineW, line2) : row1Font;

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
