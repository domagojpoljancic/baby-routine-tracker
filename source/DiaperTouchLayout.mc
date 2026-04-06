// Hit-test for screen 2 "Diaper change" button. Geometry must match SecondScreenView._drawDiaperButton.
class DiaperTouchLayout {

    function hitDiaperButton(x, y, width, height) {
        var rowY = height * 31 / 100;
        var bw = width * 72 / 100;
        var bh = height * 16 / 100;
        if (bh < 26) {
            bh = 26;
        }
        var shiftLeft = width * 5 / 100;
        var left = (width - bw) / 2 - shiftLeft;
        if (left < width * 2 / 100) {
            left = width * 2 / 100;
        }
        var top = rowY - bh / 2;

        if (x < left) {
            return false;
        }
        if (x > left + bw) {
            return false;
        }
        if (y < top) {
            return false;
        }
        if (y > top + bh) {
            return false;
        }

        return true;
    }
}
