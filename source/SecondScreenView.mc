import Toybox.Graphics;
import Toybox.WatchUi;

class SecondScreenView extends WatchUi.View {
    var _screenDots;
    var _screenIndex;

    function initialize() {
        View.initialize();
        _screenIndex = 2;
        _screenDots = new ScreenIndicator();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            w / 2,
            h / 2,
            Graphics.FONT_MEDIUM,
            "Second Screen",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var highlightRowY = h * 58 / 100;
        _screenDots.draw(dc, w, h, _screenIndex, highlightRowY);
    }
}
