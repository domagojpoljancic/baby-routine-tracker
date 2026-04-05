// Hit-test for L / B / R circles. Geometry must match HelloGarminView._drawTopCircles.
// Returns 1=Left, 2=Right, 3=Bottle (center), or null.
class FeedingTouchLayout {

    function hitCircle(x, y, width, height) {
        var rowY = height * 31 / 100;
        var r = width * 12 / 100;
        var leftX = width * 20 / 100;
        var bottleX = width * 46 / 100;
        var rightX = width * 72 / 100;
        var r2 = r * r;

        if (_inCircle(x, y, bottleX, rowY, r2)) {
            return 3;
        }
        if (_inCircle(x, y, leftX, rowY, r2)) {
            return 1;
        }
        if (_inCircle(x, y, rightX, rowY, r2)) {
            return 2;
        }

        return null;
    }

    function _inCircle(x, y, cx, cy, r2) {
        var dx = x - cx;
        var dy = y - cy;
        return (dx * dx + dy * dy) <= r2;
    }
}
