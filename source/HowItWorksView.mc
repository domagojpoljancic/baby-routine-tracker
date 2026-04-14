import Toybox.Graphics;
import Toybox.WatchUi;

class HowItWorksView extends WatchUi.View {

    var _scrollY;
    var _scrollLineStep;

    function initialize() {
        View.initialize();
        _scrollY = 0;
        _scrollLineStep = 24;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var titleY = h * 10 / 100;
        if (titleY < 16) {
            titleY = 16;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            w / 2,
            titleY,
            Graphics.FONT_TINY,
            "How it works",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var lines = [
            "Track feeding and diaper events",
            "",
            "Feeding screen:",
            "L = left side feeding",
            "R = right side feeding",
            "B = bottle feeding",
            "Blinking minutes: timer only, not saved",
            "",
            "Diaper screen:",
            "Tap Diaper change button",
            "",
            "Each tap saves a start time",
            "No end times are tracked",
            "",
            "Menu Undo last removes latest entry here",
            "Settings: choose which screen opens first"
        ];

        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font) + 4;
        _scrollLineStep = lineH;
        var startY = h * 28 / 100;
        var x = w / 2;
        var clipTop = startY - lineH / 2;
        if (clipTop < 0) {
            clipTop = 0;
        }
        var clipH = h - clipTop;
        if (clipH < lineH) {
            clipH = lineH;
        }
        var totalContentH = lines.size() * lineH;
        var viewportH = h - startY;
        // Extra slack so the last lines can scroll above the round bezel / bottom safe area.
        var bottomScrollSlack = lineH * 2 + h * 10 / 100;
        var maxScroll = totalContentH - viewportH + bottomScrollSlack;
        if (maxScroll < 0) {
            maxScroll = 0;
        }
        if (_scrollY < 0) {
            _scrollY = 0;
        }
        if (_scrollY > maxScroll) {
            _scrollY = maxScroll;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.setClip(0, clipTop, w, clipH);
        for (var i = 0; i < lines.size(); i += 1) {
            var text = lines[i];
            if (text.length() > 0) {
                dc.drawText(
                    x,
                    startY + i * lineH - _scrollY,
                    font,
                    text,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        }
        dc.clearClip();
    }
}
