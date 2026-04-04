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
        return [ new HelloGarminView(), new CircularNavDelegate(1) ];
    }
}
