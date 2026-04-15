import Toybox.Application;
import Toybox.WatchUi;

class HelloGarminApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) as Void {
    }

    function onStop(state) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var defaultScreen = (new AppSettingsStore()).getDefaultScreen();
        if (defaultScreen == 2) {
            return [ new SecondScreenView(), new CircularNavDelegate(2, :switch) ];
        }
        return [ new HelloGarminView(), new CircularNavDelegate(1, :stack) ];
    }

    function getGlanceView() {
        if (WatchUi has :GlanceView) {
            return [ new BabyRoutineGlanceView() ];
        }
        return null;
    }
}
