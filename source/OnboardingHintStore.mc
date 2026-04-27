import Toybox.Application;

// Menu helper overlay: one persistent flag, separate from feedings_v1 and settings keys.
class OnboardingHintStore {

    var KEY_MENU_HELPER_SEEN = "menu_helper_seen_v1";
    var KEY_MANUAL_HELPER_PENDING = "manual_helper_pending_v1";
    var LEGACY_KEY = "onboarding_menu_hint_v1";

    function isMenuHelperSeen() {
        var v = Application.Storage.getValue(KEY_MENU_HELPER_SEEN);
        if (v != null && v == true) {
            return true;
        }
        var legacy = Application.Storage.getValue(LEGACY_KEY);
        if (legacy != null && legacy == true) {
            Application.Storage.setValue(KEY_MENU_HELPER_SEEN, true);
            return true;
        }
        return false;
    }

    function markMenuHelperSeen() {
        Application.Storage.setValue(KEY_MENU_HELPER_SEEN, true);
        Application.Storage.setValue(KEY_MANUAL_HELPER_PENDING, false);
    }

    function isManualAddHelperPending() {
        var v = Application.Storage.getValue(KEY_MANUAL_HELPER_PENDING);
        return v != null && v == true;
    }

    function markManualAddHelperPending() {
        Application.Storage.setValue(KEY_MANUAL_HELPER_PENDING, true);
    }
}
