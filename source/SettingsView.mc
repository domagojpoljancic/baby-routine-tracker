import Toybox.Graphics;
import Toybox.WatchUi;

// Placeholder: add preference rows later. Settings entry in main menus still opens this view.
class SettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var titleY = h * 8 / 100;
        if (titleY < 14) {
            titleY = 14;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            w / 2,
            titleY,
            Graphics.FONT_XTINY,
            "Settings",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            w / 2,
            h / 2,
            Graphics.FONT_XTINY,
            "More options soon",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
