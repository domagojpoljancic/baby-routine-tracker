import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// About: centered title; body is left-aligned, scrollable (_scrollY) for long copy on round screens.
class AboutView extends WatchUi.View {

    var _scrollY;
    var _scrollLineStep;

    function initialize() {
        View.initialize();
        _scrollY = 0;
        _scrollLineStep = 24;
    }

    function _aboutLines() {
        var lines = [
            "Track baby routines",
            "Feeding & diaper",
            "",
            "Data on watch only",
            "No cloud, no sharing",
            "",
            "MIT License",
            "",
            "Version 1.2.1",
            "Build 1.2.1"
        ];
        return lines;
    }

    function _bodyContentHeight(lines, fhBody, lineGap, paraGap) {
        var contentY = 0;
        var i;
        var linesArr = lines as Array;
        var lineCount = linesArr.size();
        for (i = 0; i < lineCount; i += 1) {
            var idx = i;
            var line = linesArr[idx];
            if (line.length() == 0) {
                contentY += paraGap;
            } else {
                contentY += fhBody + lineGap;
            }
        }
        return contentY;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var padX = w * 12 / 100;
        if (padX < 14) {
            padX = 14;
        }

        var topPad = 26;
        if (h < 260) {
            topPad = 22;
        }

        var bottomSafe = h * 10 / 100;
        if (bottomSafe < 18) {
            bottomSafe = 18;
        }
        var maxY = h - bottomSafe;
        var cx = w / 2;

        var titleFont = Graphics.FONT_SMALL;
        var bodyFont = Graphics.FONT_TINY;

        var fhTitle = dc.getFontHeight(titleFont);
        var fhBody = dc.getFontHeight(bodyFont);
        var lineGap = 6;
        var paraGap = 10;

        _scrollLineStep = fhBody + lineGap;
        if (_scrollLineStep < 18) {
            _scrollLineStep = 18;
        }

        var titleGap = lineGap;
        var bodyTop = topPad + fhTitle + titleGap;
        var viewportH = maxY - bodyTop;
        if (viewportH < fhBody) {
            viewportH = fhBody;
        }

        var lines = _aboutLines();
        var totalBody = _bodyContentHeight(lines, fhBody, lineGap, paraGap);
        var maxScroll = totalBody - viewportH;
        if (maxScroll < 0) {
            maxScroll = 0;
        }
        if (_scrollY < 0) {
            _scrollY = 0;
        }
        if (_scrollY > maxScroll) {
            _scrollY = maxScroll;
        }

        var clipH = maxY - bodyTop;
        if (clipH > 0) {
            dc.setClip(0, bodyTop, w, clipH);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var contentY = 0;
        var i;
        var linesArr2 = lines as Array;
        var lineCount2 = linesArr2.size();
        for (i = 0; i < lineCount2; i += 1) {
            var idx2 = i;
            var line = linesArr2[idx2];
            if (line.length() == 0) {
                contentY += paraGap;
                continue;
            }

            var lineCenterY = bodyTop + contentY + fhBody / 2 - _scrollY;
            var lineTop = lineCenterY - fhBody / 2;
            var lineBottom = lineCenterY + fhBody / 2;
            if (lineBottom > bodyTop && lineTop < maxY) {
                dc.drawText(
                    padX,
                    lineCenterY,
                    bodyFont,
                    line,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }

            contentY += fhBody + lineGap;
        }

        if (clipH > 0) {
            dc.clearClip();
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        var titleCenterY = topPad + fhTitle / 2;
        if (titleCenterY > maxY) {
            titleCenterY = maxY;
        }
        dc.drawText(
            cx,
            titleCenterY,
            titleFont,
            "About",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
