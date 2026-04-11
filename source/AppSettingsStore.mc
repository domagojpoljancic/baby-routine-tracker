import Toybox.Application;

// App preferences only — separate keys from FeedingStore (feedings_v1).
class AppSettingsStore {

    var KEY_SCROLL_INVERT = "settings_scroll_invert_v1";

    function scrollInvertEnabled() {
        var v = Application.Storage.getValue(KEY_SCROLL_INVERT);
        if (v == null) {
            return false;
        }
        return v.toNumber() != 0;
    }

    function setScrollInvert(on) {
        Application.Storage.setValue(KEY_SCROLL_INVERT, on ? 1 : 0);
    }
}
