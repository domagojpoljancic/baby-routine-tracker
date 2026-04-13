import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Top clock for main screens (1 & 2) only. Uses System.getClockTime() and
// System.getDeviceSettings().is24Hour (see Toybox.System.DeviceSettings).
class MainScreenTimeDisplay {

    // [0] = "H:MM" or "HH:MM" main line; [1] = "AM"/"PM" or "" when 24-hour mode.
    function getDisplayTimeParts() {
        var ds = System.getDeviceSettings();
        var t = System.getClockTime();
        var minText = (t.min < 10 ? "0" : "") + t.min.toString();

        if (ds.is24Hour) {
            var hourText = (t.hour < 10 ? "0" : "") + t.hour.toString();
            return [hourText + ":" + minText, ""];
        }

        var h24 = t.hour;
        var h12;
        var amPm;
        if (h24 == 0) {
            h12 = 12;
            amPm = "AM";
        } else if (h24 < 12) {
            h12 = h24;
            amPm = "AM";
        } else if (h24 == 12) {
            h12 = 12;
            amPm = "PM";
        } else {
            h12 = h24 - 12;
            amPm = "PM";
        }

        return [h12.toString() + ":" + minText, amPm];
    }

    function draw(dc, screenWidth, screenHeight) {
        var parts = getDisplayTimeParts() as Array;
        var timeText = parts[0];
        var amPmText = parts[1];

        var centerX = screenWidth / 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);

        if (amPmText.length() == 0) {
            dc.drawText(
                centerX,
                screenHeight * 8 / 100,
                Graphics.FONT_MEDIUM,
                timeText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        // 12h: AM/PM above (FONT_XTINY); main below in FONT_SMALL; tuck clock up toward AM/PM.
        var amPmY = screenHeight * 4 / 100;
        dc.drawText(
            centerX,
            amPmY,
            Graphics.FONT_XTINY,
            amPmText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var gap = dc.getFontHeight(Graphics.FONT_XTINY) / 2 + dc.getFontHeight(Graphics.FONT_SMALL) / 2;
        var mainY = amPmY + gap - 4;
        dc.drawText(
            centerX,
            mainY,
            Graphics.FONT_SMALL,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
