import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

// Settings: "Scroll invert" (+ future rows). With one row, center vertically; add rows later via SETTINGS_ROW_COUNT + stack layout.
class SettingsView extends WatchUi.View {

    var SETTINGS_ROW_COUNT;

    function initialize() {
        View.initialize();
        SETTINGS_ROW_COUNT = 1;
    }

    function _padX(w) {
        var p = w * 8 / 100;
        if (p < 10) {
            p = 10;
        }
        return p;
    }

    function _rowGeometry(w, h) {
        var padX = _padX(w);
        var titleY = h * 8 / 100;
        if (titleY < 14) {
            titleY = 14;
        }
        var rowH = h * 12 / 100;
        if (rowH < 40) {
            rowH = 40;
        }

        var rowTop;
        if (SETTINGS_ROW_COUNT <= 1) {
            rowTop = h / 2 - rowH / 2;
            var minTop = titleY + 22;
            if (rowTop < minTop) {
                rowTop = minTop;
            }
        } else {
            rowTop = h * 17 / 100;
        }
        var trackW = w * 5 / 100;
        if (trackW < 14) {
            trackW = 14;
        }
        if (trackW > 22) {
            trackW = 22;
        }
        var trackH = rowH * 85 / 100;
        if (trackH < 32) {
            trackH = 32;
        }
        if (trackH > 52) {
            trackH = 52;
        }
        var trackLeft = w - padX - trackW;
        var trackTop = rowTop + (rowH - trackH) / 2;
        return {
            :padX => padX,
            :titleY => titleY,
            :rowTop => rowTop,
            :rowH => rowH,
            :trackLeft => trackLeft,
            :trackTop => trackTop,
            :trackW => trackW,
            :trackH => trackH
        };
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var g = _rowGeometry(w, h);
        var store = new AppSettingsStore();
        var invertOn = store.scrollInvertEnabled();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            w / 2,
            g[:titleY],
            Graphics.FONT_XTINY,
            "Settings",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            g[:padX],
            g[:rowTop] + g[:rowH] / 2,
            Graphics.FONT_SMALL,
            "Scroll invert",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var tl = g[:trackLeft];
        var tt = g[:trackTop];
        var tw = g[:trackW];
        var th = g[:trackH];

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(tl, tt, tw, th, tw / 2);

        var knobR = tw / 2 - 2;
        if (knobR < 4) {
            knobR = 4;
        }
        var cx = tl + tw / 2;
        var cy;
        if (invertOn) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            cy = tt + knobR + 2;
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            cy = tt + th - knobR - 2;
        }
        dc.fillCircle(cx, cy, knobR);
    }

    function hitScrollInvertRow(x, y) {
        var ds = System.getDeviceSettings();
        var w = ds.screenWidth;
        var h = ds.screenHeight;
        var g = _rowGeometry(w, h);
        var left = g[:padX];
        var top = g[:rowTop];
        var rowH = g[:rowH];
        var right = w - g[:padX];
        if (x >= left && x <= right && y >= top && y <= top + rowH) {
            return true;
        }
        return false;
    }
}
