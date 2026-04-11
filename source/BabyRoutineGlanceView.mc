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

    // Prefer SMALL, then TINY, then XTINY (width only — used for empty state).
    function _rowFontFor(dc, maxLineWidth, text) {
        var f = Graphics.FONT_SMALL;
        if (dc.getTextWidthInPixels(text, f) > maxLineWidth) {
            f = Graphics.FONT_TINY;
        }
        if (dc.getTextWidthInPixels(text, f) > maxLineWidth) {
            f = Graphics.FONT_XTINY;
        }
        return f;
    }

    // One font for all event rows: largest that fits maxLineW and fits vertically in the glance
    // (avoids row2 clipped by the round mask — looked like “diaper is smaller” than bottle/feeding).
    function _pickEventFontForGlance(dc, maxLineW, text1, text2, titleFh, h) {
        var padTop = h * 6 / 100;
        if (padTop < 2) {
            padTop = 2;
        }
        var gapTitle = 2;
        var gapRows = 1;
        var padBottom = 4;
        if (h < 120) {
            padBottom = 2;
        }

        var fonts = [Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY];
        var fi;
        for (fi = 0; fi < fonts.size(); fi++) {
            var f = fonts[fi];
            if (dc.getTextWidthInPixels(text1, f) > maxLineW) {
                continue;
            }
            if (text2 != null && dc.getTextWidthInPixels(text2, f) > maxLineW) {
                continue;
            }

            var rowFh = dc.getFontHeight(f);
            var titleY = padTop + titleFh / 2;
            var row1Y = titleY + titleFh / 2 + gapTitle + rowFh / 2;
            var bottom;
            if (text2 != null) {
                var row2Y = row1Y + rowFh / 2 + gapRows + rowFh / 2;
                bottom = row2Y + rowFh / 2;
            } else {
                bottom = row1Y + rowFh / 2;
            }

            if (bottom <= h - padBottom) {
                return f;
            }
        }

        return Graphics.FONT_XTINY;
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

        var isEmpty = (list == null || list.size() == 0);
        if (isEmpty) {
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

        var titleFh = dc.getFontHeight(titleFont);

        var eventFont;
        if (isEmpty) {
            eventFont = _rowFontFor(dc, maxLineW, line1);
        } else {
            eventFont = _pickEventFontForGlance(dc, maxLineW, line1, line2, titleFh, h);
        }

        var row1Font = eventFont;
        var row2Font = eventFont;
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
