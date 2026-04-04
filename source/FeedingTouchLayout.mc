// Hit-test for L / B / R circles. Geometry must match HelloGarminView._drawTopCircles.
// Returns 1=Left, 2=Right, 3=Bottle (top), or null.
class FeedingTouchLayout {

    function hitCircle(x, y, width, height) {
        var topY = height * 16 / 100;
        var sideY = height * 25 / 100;
        var r = width * 12 / 100;
        var leftX = width * 24 / 100;
        var topX = width / 2;
        var rightX = width * 76 / 100;
        var r2 = r * r;

        if (_inCircle(x, y, topX, topY, r2)) {
            return 3;
        }
        if (_inCircle(x, y, leftX, sideY, r2)) {
            return 1;
        }
        if (_inCircle(x, y, rightX, sideY, r2)) {
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
