import Toybox.Graphics;
import Toybox.WatchUi;

// Garmin-inspired list menu: centered block (rail + left-aligned labels) on round displays.
class CustomMenuView extends WatchUi.View {

    var _screen;
    var _labels;
    var _symbols;
    var _selectedIndex;
    var _title;

    // title: null uses default "Menu"; screen 1 passes "Feeding"; Start submenu passes "Start".
    function initialize(screen, labels, symbols, title) {
        View.initialize();
        _screen = screen;
        _labels = labels;
        _symbols = symbols;
        _selectedIndex = 0;
        if (title == null) {
            _title = "Menu";
        } else {
            _title = title;
        }
    }

    function _centerX(w) {
        return w / 2;
    }

    function _blockWidth(w) {
        return w * 72 / 100;
    }

    function _blockLeft(w) {
        var bw = _blockWidth(w);
        return (w - bw) / 2;
    }

    function _blockRight(w) {
        return _blockLeft(w) + _blockWidth(w);
    }

    function _railInsetInBlock(w) {
        return w * 3 / 100;
    }

    function _railLeft(w) {
        return _blockLeft(w) + _railInsetInBlock(w);
    }

    function _railWidth(w) {
        var rw = w * 2 / 100;
        if (rw < 3) {
            rw = 3;
        }
        return rw;
    }

    function _textGapAfterRail(w) {
        return w * 4 / 100;
    }

    function _textLeft(w) {
        return _railLeft(w) + _railWidth(w) + _textGapAfterRail(w);
    }

    function _titleY(h) {
        return h * 9 / 100;
    }

    function _dividerY(h) {
        return h * 14 / 100;
    }

    function _firstRowTop(h) {
        return h * 19 / 100;
    }

    function _rowPitch(h) {
        return h * 15 / 100;
    }

    function _rowHitHeight(h) {
        return _rowPitch(h) - h * 2 / 100;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var cx = _centerX(w);
        var blockL = _blockLeft(w);
        var blockR = _blockRight(w);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            _titleY(h),
            Graphics.FONT_XTINY,
            _title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawLine(blockL, _dividerY(h), blockR, _dividerY(h));

        var n = _labels.size();
        var railL = _railLeft(w);
        var railW = _railWidth(w);
        var textLeft = _textLeft(w);
        var rowH = _rowHitHeight(h);
        var pitch = _rowPitch(h);

        var i;
        for (i = 0; i < n; i += 1) {
            var rowTop = _firstRowTop(h) + i * pitch;
            var cy = rowTop + rowH / 2;
            var label = _labels[i];

            if (i == _selectedIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.fillRectangle(railL, rowTop + 1, railW, rowH - 2);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            }

            dc.drawText(
                textLeft,
                cy,
                Graphics.FONT_MEDIUM,
                label,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    // Full-width row bands (same vertical geometry as drawing). Labels can extend past the
    // content block; touch should still hit the row without changing visuals.
    function hitRow(x, y, w, h) {
        var n = _labels.size();
        var rowH = _rowHitHeight(h);
        var pitch = _rowPitch(h);

        var i;
        for (i = 0; i < n; i += 1) {
            var rowTop = _firstRowTop(h) + i * pitch;
            if (x >= 0 && x <= w && y >= rowTop && y <= rowTop + rowH) {
                return i;
            }
        }

        return -1;
    }
}
