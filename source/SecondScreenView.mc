import Toybox.Graphics;
import Toybox.Lang;
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
        var diapersArr = diapers as Array;

        var mainRowText;
        var lower0;
        var lower1;
        if (diapersArr.size() == 0) {
            mainRowText = "Start - Tap button";
            lower0 = "";
            lower1 = "";
        } else {
            var latestTs = _fmt.entryTs(diapersArr[0]);
            mainRowText = _fmt.formatHmFromTs(latestTs) + " - Diaper";
            if (diapersArr.size() >= 2) {
                lower0 = "- " + _fmt.formatHmFromTs(_fmt.entryTs(diapersArr[1])) + " -";
            } else {
                lower0 = "";
            }
            if (diapersArr.size() >= 3) {
                lower1 = "- " + _fmt.formatHmFromTs(_fmt.entryTs(diapersArr[2])) + " -";
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
        var entriesArr = entries as Array;
        for (var i = 0; i < entriesArr.size(); i++) {
            var e = entriesArr[i];
            var t = _fmt.entryType(e);
            if (t != null && t == 4) {
                diapers.add(e);
            }
        }
        return diapers;
    }

    function _sortDiapersByTsDesc(diapers) {
        var d = diapers as Array;
        var n = d.size();
        for (var i = 0; i < n; i++) {
            for (var j = i + 1; j < n; j++) {
                var ti = _fmt.entryTs(d[i]);
                var tj = _fmt.entryTs(d[j]);
                if (tj > ti) {
                    var tmp = d[i];
                    d[i] = d[j];
                    d[j] = tmp;
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
        var left = (w - bw) / 2;
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
