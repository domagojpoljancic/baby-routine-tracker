import Toybox.Graphics;
import Toybox.Math;

// Small vertical dot stack: index 1 = top, 2 = middle, 3 = bottom.
// Fixed dot size and left gutter — not derived from text width or content.
class ScreenIndicator {

    // Dot radius in pixels (same on every screen).
    var DOT_RADIUS = 4;
    // Horizontal center of dots: pixels from drawable left edge toward center.
    var DOT_CENTER_X = 12;

    // highlightRowY = vertical center of highlighted row; top dot uses this Y.
    function draw(dc, screenWidth, screenHeight, activeScreen, highlightRowY) {
        var dotR = DOT_RADIUS;
        var spacing = dotR * 3 + 1;

        var dotCx = DOT_CENTER_X;

        // Keep dots inside the round display at this row Y (documented Graphics + Math only).
        var cx = screenWidth / 2;
        var cy = screenHeight / 2;
        var cr = (screenWidth < screenHeight ? screenWidth : screenHeight) / 2;
        var dy = highlightRowY - cy;
        var disc = cr * cr - dy * dy;
        if (disc < 0) {
            disc = 0;
        }
        var arcLeft = cx - Math.sqrt(disc);
        var minCx = arcLeft + dotR + 3;
        if (dotCx < minCx) {
            dotCx = minCx;
        }

        // Nudge stack up slightly so dots match perceived vertical center of row text.
        var stackYOffset = screenHeight * 65 / 1000;

        var i;
        // v1.0: two active screens (third indicator disabled).
        for (i = 1; i <= 2; i += 1) {
            var y = highlightRowY + (i - 1) * spacing - stackYOffset;
            if (i == activeScreen) {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            }
            dc.fillCircle(dotCx, y, dotR);
        }
    }
}
