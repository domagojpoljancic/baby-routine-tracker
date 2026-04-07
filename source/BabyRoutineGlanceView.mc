import Toybox.Graphics;
import Toybox.WatchUi;

// Widget-style glance preview: latest store entry, time matches watch 12h/24h (see FeedingFormatters.formatHistoryRowTimeFromTs).
(:glance)
class BabyRoutineGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, w, h);

        var store = new FeedingStore();
        var list = store.load();
        var line;
        if (list == null || list.size() == 0) {
            line = "No events";
        } else {
            var fmt = new FeedingFormatters();
            var entry = list[list.size() - 1];
            line = fmt.formatGlanceEventLine(entry);
        }

        var font = Graphics.FONT_SMALL;
        if (dc.getTextWidthInPixels(line, font) > w * 92 / 100) {
            font = Graphics.FONT_XTINY;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            w / 2,
            h / 2,
            font,
            line,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
