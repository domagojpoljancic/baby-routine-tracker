import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class HelloGarminView extends WatchUi.View {
    var _screenDots;
    var _screenIndex;
    var _store;
    var _fmt;
    var _animTick = 0;
    // Last tapped circle for brief fill flash: 1=L, 2=R, 3=B (matches FeedingTouchLayout); null = none.
    var _flashCircleCode = null;
    var _flashFramesRemaining = 0;

    function initialize() {
        View.initialize();
        _screenIndex = 1;
        _screenDots = new ScreenIndicator();
        _store = new FeedingStore();
        _fmt = new FeedingFormatters();
    }

    function onLayout(dc) {
    }

    function onShow() {
        WatchUi.animate(self, :_animTick, WatchUi.ANIM_TYPE_LINEAR, 0, 1, 3600.0, null);
    }

    function onHide() {
        WatchUi.cancelAllAnimations();
    }

    // Called from CircularNavDelegate after a successful L/R/B hit (same codes as hitCircle).
    function noteCircleFlash(circleCode) {
        _flashCircleCode = circleCode;
        _flashFramesRemaining = 6;
    }

    function onUpdate(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        var circleRadius = (screenWidth < screenHeight ? screenWidth : screenHeight) / 2;
        var entries = _store.load();

        // High-contrast base.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, screenWidth, screenHeight);
        dc.fillCircle(centerX, centerY, circleRadius);

        var nowTs = Time.now().value();
        var mainHP = _mainRowHighlightParts(nowTs, entries);
        var mainText = mainHP[0] + mainHP[1];
        var lowerTexts = _buildLowerRowTexts(entries);

        var highlightRowY = screenHeight * 58 / 100;
        var maxMainWidth = screenWidth * 94 / 100;
        var mainCenterX = screenWidth / 2 + screenWidth * 2 / 100;

        var highlightFont;
        if (entries == null || entries.size() == 0) {
            highlightFont = _pickFittingFont(dc, mainText, [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY], maxMainWidth);
        } else {
            highlightFont = _pickMainRowFont(dc, nowTs, entries, maxMainWidth);
        }

        if (_flashCircleCode != null) {
            _flashFramesRemaining -= 1;
            if (_flashFramesRemaining <= 0) {
                _flashCircleCode = null;
            }
        }

        _drawTime(dc, screenWidth, screenHeight);
        _drawTopCircles(dc, screenWidth, screenHeight);
        (new MenuHotspot()).draw(dc);
        _drawDivider(dc, screenWidth, screenHeight);
        _drawMiddleHighlightedRow(dc, mainCenterX, highlightRowY, highlightFont, mainHP[0], mainHP[1], mainHP[2]);
        _drawSecondDivider(dc, screenWidth, screenHeight);
        _drawLowerRows(dc, screenWidth, screenHeight, lowerTexts[0], lowerTexts[1]);

        _screenDots.draw(dc, screenWidth, screenHeight, _screenIndex, highlightRowY);
    }

    function _drawTopCircles(dc, screenWidth, screenHeight) {
        var rowY = screenHeight * 31 / 100;
        var circleRadius = screenWidth * 12 / 100;
        var leftX = screenWidth * 20 / 100;
        var bottleX = screenWidth * 46 / 100;
        var rightX = screenWidth * 72 / 100;

        var fillL = _flashCircleCode == 1 ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY;
        var fillB = _flashCircleCode == 3 ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY;
        var fillR = _flashCircleCode == 2 ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY;

        dc.setColor(fillL, Graphics.COLOR_BLACK);
        dc.fillCircle(leftX, rowY, circleRadius);
        dc.setColor(fillB, Graphics.COLOR_BLACK);
        dc.fillCircle(bottleX, rowY, circleRadius);
        dc.setColor(fillR, Graphics.COLOR_BLACK);
        dc.fillCircle(rightX, rowY, circleRadius);

        dc.setColor(Graphics.COLOR_DK_GREEN, fillL);
        dc.drawText(leftX, rowY, Graphics.FONT_MEDIUM, "L", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_DK_BLUE, fillB);
        dc.drawText(bottleX, rowY, Graphics.FONT_MEDIUM, "B", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_DK_GREEN, fillR);
        dc.drawText(rightX, rowY, Graphics.FONT_MEDIUM, "R", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function _drawTime(dc, screenWidth, screenHeight) {
        var t = System.getClockTime();
        var hourText = (t.hour < 10 ? "0" : "") + t.hour.toString();
        var minuteText = (t.min < 10 ? "0" : "") + t.min.toString();
        var timeText = hourText + ":" + minuteText;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            screenWidth / 2,
            screenHeight * 8 / 100,
            Graphics.FONT_MEDIUM,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _drawDivider(dc, screenWidth, screenHeight) {
        var y = screenHeight * 47 / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(0, y, screenWidth, y);
    }

    // baseText + timerSuffix on one line; timerSuffix blinks white / light gray by wall-clock second.
    function _drawMiddleHighlightedRow(dc, centerX, highlightRowY, font, baseText, timerSuffix, timerUseWhite) {
        if (timerSuffix.length() == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(
                centerX,
                highlightRowY,
                font,
                baseText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        var baseW = dc.getTextWidthInPixels(baseText, font);
        var suffixW = dc.getTextWidthInPixels(timerSuffix, font);
        var totalW = baseW + suffixW;
        var startX = centerX - totalW / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            startX,
            highlightRowY,
            font,
            baseText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        if (timerUseWhite) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        }
        dc.drawText(
            startX + baseW,
            highlightRowY,
            font,
            timerSuffix,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _drawSecondDivider(dc, screenWidth, screenHeight) {
        var y = screenHeight * 68 / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(0, y, screenWidth, y);
    }

    function _drawLowerRows(dc, screenWidth, screenHeight, firstText, secondText) {
        // Slightly wider measure + small right nudge: longer labels ("Right", "Bottle") keep FONT_SMALL closer to "Left".
        var maxTextWidth = screenWidth * 91 / 100;
        var lowerCenterX = screenWidth / 2 + screenWidth * 3 / 100;

        var firstFont = _pickFittingFont(dc, firstText, [Graphics.FONT_SMALL, Graphics.FONT_XTINY], maxTextWidth);
        var secondFont = _pickFittingFont(dc, secondText, [Graphics.FONT_SMALL, Graphics.FONT_XTINY], maxTextWidth);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            lowerCenterX,
            screenHeight * 79 / 100,
            firstFont,
            firstText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            lowerCenterX,
            screenHeight * 90 / 100,
            secondFont,
            secondText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _pickFittingFont(dc, text, fonts, maxWidth) {
        for (var i = 0; i < fonts.size(); i += 1) {
            var candidate = fonts[i];
            if (dc.getTextWidthInPixels(text, candidate) <= maxWidth) {
                return candidate;
            }
        }

        // Fall back to smallest provided candidate if all are too wide.
        return fonts[fonts.size() - 1];
    }

    // One font for the main row: must fit Left, Right, and Bottle for same time/timer (matches formatter labels).
    function _pickMainRowFont(dc, nowTs, entries, maxWidth) {
        var latest = entries[entries.size() - 1];
        var latestTs = _fmt.entryTs(latest);
        var hhmm = _fmt.formatHmFromTs(latestTs);
        var elapsed = _fmt.elapsedWholeMinutes(nowTs, latestTs);

        var probeLeft;
        var probeRight;
        var probeBottle;
        if (elapsed <= 60) {
            var suf = " - " + elapsed.toString() + " min";
            probeLeft = hhmm + " - Left" + suf;
            probeRight = hhmm + " - Right" + suf;
            probeBottle = hhmm + " - Bottle" + suf;
        } else {
            probeLeft = hhmm + " - Left";
            probeRight = hhmm + " - Right";
            probeBottle = hhmm + " - Bottle";
        }

        var fonts = [Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_XTINY];
        var i;
        for (i = 0; i < fonts.size(); i += 1) {
            var candidate = fonts[i];
            var wL = dc.getTextWidthInPixels(probeLeft, candidate);
            var wR = dc.getTextWidthInPixels(probeRight, candidate);
            var wB = dc.getTextWidthInPixels(probeBottle, candidate);
            var wMax = wL;
            if (wR > wMax) {
                wMax = wR;
            }
            if (wB > wMax) {
                wMax = wB;
            }
            if (wMax <= maxWidth) {
                return candidate;
            }
        }

        return Graphics.FONT_XTINY;
    }

    // [0]=baseText ("HH:MM - Label" or empty-state line), [1]=timerSuffix (" - X min" or ""),
    // [2]=timerUseWhite (even unix second => white suffix; odd => light gray); only meaningful if [1] non-empty.
    function _mainRowHighlightParts(nowTs, entries) {
        var sec = Time.now().value();
        var timerUseWhite = (sec % 2) == 0;

        if (entries == null || entries.size() == 0) {
            return ["Start - Tap L/R/B", "", timerUseWhite];
        }

        var latest = entries[entries.size() - 1];
        var latestTs = _fmt.entryTs(latest);
        var baseLabel = _fmt.typeLabel(_fmt.entryType(latest));
        var hhmm = _fmt.formatHmFromTs(latestTs);
        var baseText = hhmm + " - " + baseLabel;

        var timerSuffix = "";
        var elapsed = _fmt.elapsedWholeMinutes(nowTs, latestTs);
        if (elapsed <= 60) {
            timerSuffix = " - " + elapsed.toString() + " min";
        }

        return [baseText, timerSuffix, timerUseWhite];
    }

    function _buildMainRowText(nowTs, entries) {
        var p = _mainRowHighlightParts(nowTs, entries);
        return p[0] + p[1];
    }

    function _buildLowerRowTexts(entries) {
        var texts = ["", ""];

        if (entries == null || entries.size() == 0) {
            texts[0] = "Recent History";
            return texts;
        }

        var count = entries.size();
        if (count >= 2) {
            texts[0] = _fmt.formatHistoryLine(entries[count - 2]);
        }
        if (count >= 3) {
            texts[1] = _fmt.formatHistoryLine(entries[count - 3]);
        }

        return texts;
    }
}
