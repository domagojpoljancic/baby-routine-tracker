import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// First-run hint: upper half light grey wash; lower half stays clear so Screen 1 stays visible.
class OnboardingOverlayView extends WatchUi.View {

    var _autoDismissTimer;
    var _kind;
    var _screen;

    function _chordHalfWidthAtY(w, h, y) {
        var cy = h / 2;
        var r = w;
        if (h < w) {
            r = h;
        }
        r = r / 2;
        var dy = y - cy;
        var inner = r * r - dy * dy;
        if (inner <= 0) {
            return 1;
        }
        return Math.sqrt(inner.toFloat());
    }

    // Horizontal span available for text at a given row on a round display (full chord width).
    function _chordWidthAtY(w, h, y) {
        return 2 * _chordHalfWidthAtY(w, h, y);
    }

    function _isRoundLike(ds) {
        return ds.screenShape == System.SCREEN_SHAPE_ROUND || ds.screenShape == System.SCREEN_SHAPE_SEMI_ROUND;
    }

    // Right edge X for TEXT_JUSTIFY_RIGHT so glyphs stay inside the round display.
    function _rightAnchorX(ds, w, h, anchorY) {
        var pad = w * 4 / 100;
        if (pad < 8) {
            pad = 8;
        }
        var rectInset = w * 8 / 100;
        if (rectInset < 10) {
            rectInset = 10;
        }
        var xrRect = w - rectInset;
        if (!_isRoundLike(ds)) {
            return xrRect;
        }
        var cx = w / 2;
        var halfW = _chordHalfWidthAtY(w, h, anchorY);
        var xCircleRight = cx + halfW;
        var xr = xCircleRight - pad;
        if (xr > xrRect) {
            xr = xrRect;
        }
        var xrMin = w * 20 / 100;
        if (xr < xrMin) {
            xr = xrMin;
        }
        return xr;
    }

    function _maxLineWidthForLayout(ds, w, h, y1, y2) {
        var padPair = w * 5 / 100;
        if (padPair < 10) {
            padPair = 10;
        }
        if (!_isRoundLike(ds)) {
            return w * 88 / 100 - padPair;
        }
        var c1 = _chordWidthAtY(w, h, y1);
        var c2 = _chordWidthAtY(w, h, y2);
        var chord = c1;
        if (c2 < chord) {
            chord = c2;
        }
        var maxW = chord - 2 * padPair;
        var cap = w * 88 / 100;
        if (maxW > cap) {
            maxW = cap;
        }
        if (maxW < w * 35 / 100) {
            maxW = w * 35 / 100;
        }
        return maxW;
    }

    function _pickFontForLines(dc, maxW, line1, line2) {
        var fonts = [
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY
        ] as Array;
        var i;
        for (i = 0; i < fonts.size(); i++) {
            var f = fonts[i];
            if (dc.getTextWidthInPixels(line1, f) <= maxW && dc.getTextWidthInPixels(line2, f) <= maxW) {
                return f;
            }
        }
        return Graphics.FONT_XTINY;
    }

    function initialize(kind, screen) {
        View.initialize();
        _autoDismissTimer = null;
        _kind = kind;
        _screen = screen;
        if (_kind == null) {
            _kind = :menu;
        }
    }

    function onShow() {
        if (_autoDismissTimer != null) {
            _autoDismissTimer.stop();
            _autoDismissTimer = null;
        }
        _autoDismissTimer = new Timer.Timer();
        var duration = 2000;
        if (_kind == :manualAdd) {
            duration = 3000;
        }
        _autoDismissTimer.start(self.method(:onAutoDismiss), duration, false);
    }

    function onHide() {
        if (_autoDismissTimer != null) {
            _autoDismissTimer.stop();
            _autoDismissTimer = null;
        }
    }

    function onAutoDismiss() as Void {
        if (_kind == :menu) {
            (new OnboardingHintStore()).markManualAddHelperPending();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            (new OnboardingHintStore()).markMenuHelperSeen();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function _drawDimDitherTop(dc, w, hTop) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var step = 4;
        var yy;
        var xx;
        for (yy = 0; yy < hTop; yy += step) {
            for (xx = 0; xx < w; xx += step) {
                if ((xx + yy) % (step * 2) < step) {
                    dc.fillRectangle(xx, yy, step - 1, step - 1);
                }
            }
        }
    }

    // Only the top half gets a light grey layer; bottom stays transparent (main view shows).
    function _drawDimLayer(dc, w, h) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        var hTop = h / 2;
        var useBlend = dc has :setBlendMode;
        if (useBlend) {
            dc.setBlendMode(Graphics.BLEND_MODE_SOURCE_OVER);
        }

        if (useBlend) {
            var dim = Graphics.createColor(230, 230, 230, 230);
            dc.setColor(dim, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, 0, w, hTop);
        } else {
            _drawDimDitherTop(dc, w, hTop);
        }

        if (useBlend) {
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
        }
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var ds = System.getDeviceSettings();

        if (_kind == :manualAdd) {
            _drawManualAddHint(dc, w, h, ds);
            return;
        }

        _drawDimLayer(dc, w, h);

        var ink = Graphics.createColor(255, 0xC0, 0x00, 0x00);
        dc.setColor(ink, Graphics.COLOR_TRANSPARENT);

        var line1 = "Menu »";
        var line2 = "« or left swipe";
        var yProbe1 = h * 18 / 100;
        var yProbe2 = h * 42 / 100;
        var maxW = _maxLineWidthForLayout(ds, w, h, yProbe1, yProbe2);
        var font = _pickFontForLines(dc, maxW, line1, line2);

        var hTop = h / 2;
        var margin = h * 3 / 100;
        if (margin < 4) {
            margin = 4;
        }
        var justify = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;

        var fy1;
        var fy2;
        var fh;
        var gap;
        var midY;
        var lineGap;
        var bottomLimit;

        fh = Graphics.getFontHeight(font);
        gap = fh / 2 + h * 2 / 100;
        midY = margin + (hTop - 2 * margin) / 2;
        fy1 = midY - gap / 2;
        if (fy1 - fh / 2 < margin) {
            fy1 = margin + fh / 2;
        }
        if (fy1 + fh / 2 > hTop - margin) {
            fy1 = hTop - margin - fh / 2;
        }
        lineGap = fh + h * 7 / 100;
        bottomLimit = hTop - margin - fh / 2;
        fy2 = fy1 + lineGap;
        if (fy2 > bottomLimit) {
            fy2 = bottomLimit;
            fy1 = fy2 - lineGap;
            if (fy1 - fh / 2 < margin) {
                fy1 = margin + fh / 2;
            }
        }

        maxW = _maxLineWidthForLayout(ds, w, h, fy1, fy2);
        font = _pickFontForLines(dc, maxW, line1, line2);

        fh = Graphics.getFontHeight(font);
        gap = fh / 2 + h * 2 / 100;
        midY = margin + (hTop - 2 * margin) / 2;
        fy1 = midY - gap / 2;
        if (fy1 - fh / 2 < margin) {
            fy1 = margin + fh / 2;
        }
        if (fy1 + fh / 2 > hTop - margin) {
            fy1 = hTop - margin - fh / 2;
        }
        lineGap = fh + h * 7 / 100;
        bottomLimit = hTop - margin - fh / 2;
        fy2 = fy1 + lineGap;
        if (fy2 > bottomLimit) {
            fy2 = bottomLimit;
            fy1 = fy2 - lineGap;
            if (fy1 - fh / 2 < margin) {
                fy1 = margin + fh / 2;
            }
        }

        var xr1 = _rightAnchorX(ds, w, h, fy1);
        var xr2 = _rightAnchorX(ds, w, h, fy2);

        dc.drawText(xr1, fy1, font, line1, justify);

        dc.drawText(xr2, fy2, font, line2, justify);
    }

    function _drawManualAddHint(dc, w, h, ds) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        var hBottom = h / 2;
        var top = h / 2;
        var useBlend = dc has :setBlendMode;
        if (useBlend) {
            dc.setBlendMode(Graphics.BLEND_MODE_SOURCE_OVER);
            var dim = Graphics.createColor(230, 230, 230, 230);
            dc.setColor(dim, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, top, w, hBottom);
            dc.setBlendMode(Graphics.BLEND_MODE_DEFAULT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, top, w, hBottom);
        }

        var line1 = "Hold L / B / R";
        var line2 = "to add manually";
        if (_screen == 2) {
            line1 = "Hold Diaper";
        }

        var y1 = h * 62 / 100;
        var y2 = h * 76 / 100;
        var maxW = _maxLineWidthForLayout(ds, w, h, y1, y2);
        var font = _pickFontForLines(dc, maxW, line1, line2);
        var ink = Graphics.createColor(255, 0xC0, 0x00, 0x00);
        dc.setColor(ink, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, y1, font, line1, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(w / 2, y2, font, line2, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
