import Toybox.Graphics;

// Shared geometry for the upper-right menu affordance (hit-test + draw).
// Placed above the L/B/R feeding circles so taps do not overlap circle hit areas.
class MenuHotspot {

    function hitTest(x, y, width, height) {
        var left = width * 90 / 100;
        var top = height * 2 / 100;
        var right = width - 1;
        var rh = height * 12 / 100;
        var bottom = top + rh - 1;
        return x >= left && x <= right && y >= top && y <= bottom;
    }

    function draw(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var left = w * 90 / 100;
        var top = h * 2 / 100;
        var rw = w - 1 - left;
        var rh = h * 12 / 100;
        var corner = rh / 2;
        if (corner < 3) {
            corner = 3;
        }
        if (corner > rw / 2) {
            corner = rw / 2;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(left, top, rw, rh, corner);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawRoundedRectangle(left, top, rw, rh, corner);
    }
}
