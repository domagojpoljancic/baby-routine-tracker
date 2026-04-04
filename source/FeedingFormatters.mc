import Toybox.Math;
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

        var tStr = entry["t"];
        var tSym = entry[:t];

        if (tStr != null) {
            return tStr;
        }

        return tSym;
    }

    function entryTs(entry) {
        if (entry == null) {
            return null;
        }

        var tsStr = entry["ts"];
        var tsSym = entry[:ts];

        if (tsStr != null) {
            return tsStr;
        }

        return tsSym;
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
