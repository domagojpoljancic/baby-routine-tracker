import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Glance-only: reads the tiny recent-entry cache maintained by FeedingStore.
// No app classes — they are not loaded in the Glance execution context.
(:glance)
class BabyRoutineGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function _maxEntriesToScan() {
        return 2;
    }

    function _toNumberOrNull(value) {
        if (value == null || !(value has :toNumber)) {
            return null;
        }

        return value.toNumber();
    }

    function _entryTs(entry) {
        if (entry == null || !(entry instanceof Dictionary)) {
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

        var ts = _toNumberOrNull(raw);
        if (ts == null || ts <= 0) {
            return null;
        }

        return ts;
    }

    function _entryType(entry) {
        if (entry == null || !(entry instanceof Dictionary)) {
            return null;
        }
        var d = entry as Dictionary;
        var t = d["t"];
        if (t == null) {
            t = d[:t];
        }

        var n = _toNumberOrNull(t);
        if (n == 1 || n == 2 || n == 3 || n == 4) {
            return n;
        }

        return null;
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

    function _isValidEntry(entry) {
        return _entryTs(entry) != null && _entryType(entry) != null;
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

    function _recentValidGlanceLines(list) {
        var lines = [];
        if (list == null || !(list instanceof Array)) {
            return lines;
        }

        var listArr = list as Array;
        var i = listArr.size() - 1;
        var scanned = 0;
        while (i >= 0 && scanned < _maxEntriesToScan() && lines.size() < 2) {
            var entry = listArr[i];
            if (_isValidEntry(entry)) {
                lines.add(_formatGlanceLine(entry));
            }
            scanned += 1;
            i -= 1;
        }

        return lines;
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

        var lines = _recentValidGlanceLines(Application.Storage.getValue("glance_recent_v1"));
        var line1 = null;
        var line2 = null;
        var lineCount = lines.size();

        var isEmpty = (lineCount == 0);
        if (isEmpty) {
            line1 = "No events";
        } else {
            line1 = lines[0];
            if (lineCount >= 2) {
                line2 = lines[1];
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
