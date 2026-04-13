import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;

class FeedingFormatters {

    function typeLabel(code) {
        if (code == null) {
            return "?";
        }

        if (code == 1) {
            return "Left";
        }
        if (code == 2) {
            return "Right";
        }
        if (code == 3) {
            return "Bottle";
        }
        if (code == 4) {
            return "Diaper";
        }

        if (code == "L" || code == :L) {
            return "Left";
        }
        if (code == "R" || code == :R) {
            return "Right";
        }
        if (code == "B" || code == :B) {
            return "Bottle";
        }

        var s = code.toString();
        if (s.length() > 0 && s.substring(0, 1) == ":" && s.length() > 1) {
            s = s.substring(1, s.length());
        }
        if (s.length() > 0) {
            var codeChar = s.substring(0, 1);
            if (codeChar == "L") {
                return "Left";
            }
            if (codeChar == "R") {
                return "Right";
            }
            if (codeChar == "B") {
                return "Bottle";
            }
        }

        return "?";
    }

    function entryType(entry) {
        if (entry == null) {
            return null;
        }

        var d = entry as Dictionary;
        var tStr = d["t"];
        var tSym = d[:t];

        if (tStr != null) {
            return tStr;
        }

        return tSym;
    }

    function entryTs(entry) {
        if (entry == null) {
            return null;
        }

        var d = entry as Dictionary;
        var raw = d["ts"];
        if (raw == null) {
            raw = d[:ts];
        }
        if (raw == null) {
            return null;
        }

        return raw.toNumber();
    }

    function isFeedingTypeCode(code) {
        if (code == null) {
            return false;
        }

        var n = code.toNumber();
        return n == 1 || n == 2 || n == 3;
    }

    function filterFeedingEntries(list) {
        if (list == null) {
            return [];
        }

        var out = [];
        var arr = list as Array;
        var i;
        var n = arr.size();
        for (i = 0; i < n; i += 1) {
            var e = arr[i];
            if (isFeedingTypeCode(entryType(e))) {
                out.add(e);
            }
        }

        return out;
    }

    function isDiaperTypeCode(code) {
        if (code == null) {
            return false;
        }

        return code.toNumber() == 4;
    }

    function filterDiaperEntries(list) {
        if (list == null) {
            return [];
        }

        var out = [];
        var arr = list as Array;
        var i;
        var n = arr.size();
        for (i = 0; i < n; i += 1) {
            var e = arr[i];
            if (isDiaperTypeCode(entryType(e))) {
                out.add(e);
            }
        }

        return out;
    }

    function formatHmFromTs(ts) {
        if (ts == null) {
            return "??:??";
        }

        var moment = new Time.Moment(ts);
        var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

        var hh = (info.hour < 10 ? "0" : "") + info.hour.toString();
        var mm = (info.min < 10 ? "0" : "") + info.min.toString();
        return hh + ":" + mm;
    }

    // History menu rows only: matches DeviceSettings.is24Hour (same rule as main-screen clock).
    function formatHistoryRowTimeFromTs(ts) {
        if (ts == null) {
            return "??:??";
        }

        if (System.getDeviceSettings().is24Hour) {
            return formatHmFromTs(ts);
        }

        var moment = new Time.Moment(ts);
        var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
        var h24 = info.hour;
        var mm = (info.min < 10 ? "0" : "") + info.min.toString();

        var h12;
        var suffix;
        if (h24 == 0) {
            h12 = 12;
            suffix = " AM";
        } else if (h24 < 12) {
            h12 = h24;
            suffix = " AM";
        } else if (h24 == 12) {
            h12 = 12;
            suffix = " PM";
        } else {
            h12 = h24 - 12;
            suffix = " PM";
        }

        return h12.toString() + ":" + mm + suffix;
    }

    // Glance + same display rule as History rows: time + type, respects is24Hour.
    function formatGlanceEventLine(entry) {
        return formatHistoryRowTimeFromTs(entryTs(entry)) + " - " + typeLabel(entryType(entry));
    }

    function formatHistoryLine(entry) {
        return formatHmFromTs(entryTs(entry)) + " - " + typeLabel(entryType(entry));
    }

    function elapsedWholeMinutes(tsNow, entryTs) {
        if (tsNow == null || entryTs == null) {
            return 0;
        }

        var diff = tsNow - entryTs;
        if (diff < 0) {
            diff = 0;
        }

        return Math.floor(diff / 60);
    }
}
