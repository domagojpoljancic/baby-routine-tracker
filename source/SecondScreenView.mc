import Toybox.Graphics;
import Toybox.WatchUi;

// Screen 2: diaper tracking (shared store; t=4).
class SecondScreenView extends WatchUi.View {

    var _screenDots;
    var _screenIndex;
    var _store;
    var _fmt;

    function initialize() {
        View.initialize();
        _screenIndex = 2;
        _screenDots = new ScreenIndicator();
        _store = new FeedingStore();
        _fmt = new FeedingFormatters();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var circleRadius = (w < h ? w : h) / 2;

        var entries = _store.load();
        var diapers = _collectDiaperEntries(entries);
        _sortDiapersByTsDesc(diapers);

        var mainRowText;
        var lower0;
        var lower1;
        if (diapers.size() == 0) {
            mainRowText = "Start - Tap button";
            lower0 = "";
            lower1 = "";
        } else {
            var latestTs = _fmt.entryTs(diapers[0]);
            mainRowText = _fmt.formatHmFromTs(latestTs) + " - Diaper";
            if (diapers.size() >= 2) {
                lower0 = "- " + _fmt.formatHmFromTs(_fmt.entryTs(diapers[1])) + " -";
            } else {
                lower0 = "";
            }
            if (diapers.size() >= 3) {
                lower1 = "- " + _fmt.formatHmFromTs(_fmt.entryTs(diapers[2])) + " -";
            } else {
                lower1 = "";
            }
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);
        dc.fillCircle(cx, cy, circleRadius);

        var highlightRowY = h * 58 / 100;
        var mainCenterX = w / 2 + w * 2 / 100;

        _drawTime(dc, w, h);
        _drawDiaperButton(dc, w, h);
        (new MenuHotspot()).draw(dc);
        _drawDivider(dc, w, h);
        _drawMainRow(dc, mainCenterX, highlightRowY, mainRowText);
        _drawSecondDivider(dc, w, h);
        _drawLowerRows(dc, w, h, lower0, lower1);

        _screenDots.draw(dc, w, h, _screenIndex, highlightRowY);
    }

    function _collectDiaperEntries(entries) {
        var diapers = [];
        if (entries == null) {
            return diapers;
        }
        for (var i = 0; i < entries.size(); i++) {
            var e = entries[i];
            var t = _fmt.entryType(e);
            if (t != null && t == 4) {
                diapers.add(e);
            }
        }
        return diapers;
    }

    function _sortDiapersByTsDesc(diapers) {
        var n = diapers.size();
        for (var i = 0; i < n; i++) {
            for (var j = i + 1; j < n; j++) {
                var ti = _fmt.entryTs(diapers[i]);
                var tj = _fmt.entryTs(diapers[j]);
                if (tj > ti) {
                    var tmp = diapers[i];
                    diapers[i] = diapers[j];
                    diapers[j] = tmp;
                }
            }
        }
    }

    function _drawTime(dc, screenWidth, screenHeight) {
        (new MainScreenTimeDisplay()).draw(dc, screenWidth, screenHeight);
    }

    // Primary action button in the upper content band (same vertical band as screen 1 circles).
    function _drawDiaperButton(dc, w, h) {
        var rowY = h * 31 / 100;
        var bw = w * 72 / 100;
        var bh = h * 16 / 100;
        if (bh < 26) {
            bh = 26;
        }
        var shiftLeft = w * 5 / 100;
        var left = (w - bw) / 2 - shiftLeft;
        if (left < w * 2 / 100) {
            left = w * 2 / 100;
        }
        var top = rowY - bh / 2;
        var corner = bw * 5 / 100;
        if (corner < 3) {
            corner = 3;
        }
        if (corner > bh / 2) {
            corner = bh / 2;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(left, top, bw, bh, corner);

        var btnCenterX = left + bw / 2;

        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_LT_GRAY);
        dc.drawText(
            btnCenterX,
            rowY,
            Graphics.FONT_SMALL,
            "Diaper change",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _drawDivider(dc, screenWidth, screenHeight) {
        var y = screenHeight * 47 / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(0, y, screenWidth, y);
    }

    function _drawMainRow(dc, centerX, highlightRowY, text) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            highlightRowY,
            Graphics.FONT_MEDIUM,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _drawSecondDivider(dc, screenWidth, screenHeight) {
        var y = screenHeight * 68 / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(0, y, screenWidth, y);
    }

    function _drawLowerRows(dc, w, h, firstText, secondText) {
        var lowerCenterX = w / 2 + w * 3 / 100;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            lowerCenterX,
            h * 79 / 100,
            Graphics.FONT_SMALL,
            firstText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            lowerCenterX,
            h * 90 / 100,
            Graphics.FONT_SMALL,
            secondText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
