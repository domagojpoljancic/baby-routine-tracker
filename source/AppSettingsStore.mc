import Toybox.Application;

class AppSettingsStore {

    var DEFAULT_SCREEN_KEY = "default_screen_v1";
    var SCREEN_FEEDING = 1;
    var SCREEN_DIAPER = 2;

    function getDefaultScreen() {
        var stored = Application.Storage.getValue(DEFAULT_SCREEN_KEY);
        if (stored == null) {
            return SCREEN_FEEDING;
        }

        var value = stored.toNumber();
        if (value == SCREEN_DIAPER) {
            return SCREEN_DIAPER;
        }
        return SCREEN_FEEDING;
    }

    function setDefaultScreen(screen) {
        if (screen == SCREEN_DIAPER) {
            Application.Storage.setValue(DEFAULT_SCREEN_KEY, SCREEN_DIAPER);
            return;
        }

        Application.Storage.setValue(DEFAULT_SCREEN_KEY, SCREEN_FEEDING);
    }
}
