using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;

class PowerWashApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [ new PowerWashView() ];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [ new PowerWashSettingsMenu(), new PowerWashSettingsDelegate() ];
    }
}
