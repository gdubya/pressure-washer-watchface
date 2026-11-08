using Toybox.Lang;
using Toybox.WatchUi;

class PowerWashSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => WatchUi.loadResource(Rez.Strings.CharacterThemeTitle) as Lang.String });
        var current = PowerWashView.getConfiguredThemeSetting();
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.ThemePowerWasher) as Lang.String,
            current == PowerWashView.THEME_POWER_WASHER ? "Active" : null,
            :theme_power_washer,
            null
        ));
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.ThemeLeafBlower) as Lang.String,
            current == PowerWashView.THEME_LEAF_BLOWER ? "Active" : null,
            :theme_leaf_blower,
            null
        ));
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.ThemeWokMaster) as Lang.String,
            current == PowerWashView.THEME_WOK_MASTER ? "Active" : null,
            :theme_wok_master,
            null
        ));
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.ThemeHedgeTrimmer) as Lang.String,
            current == PowerWashView.THEME_HEDGE_TRIMMER ? "Active" : null,
            :theme_hedge_trimmer,
            null
        ));
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.ThemeAutoRotate) as Lang.String,
            current == PowerWashView.THEME_AUTO_ROTATE ? "Active" : null,
            :theme_auto_rotate,
            null
        ));
    }
}

class PowerWashSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :theme_power_washer) {
            PowerWashView.setConfiguredThemeSetting(PowerWashView.THEME_POWER_WASHER);
        } else if (id == :theme_leaf_blower) {
            PowerWashView.setConfiguredThemeSetting(PowerWashView.THEME_LEAF_BLOWER);
        } else if (id == :theme_wok_master) {
            PowerWashView.setConfiguredThemeSetting(PowerWashView.THEME_WOK_MASTER);
        } else if (id == :theme_hedge_trimmer) {
            PowerWashView.setConfiguredThemeSetting(PowerWashView.THEME_HEDGE_TRIMMER);
        } else if (id == :theme_auto_rotate) {
            PowerWashView.setConfiguredThemeSetting(PowerWashView.THEME_AUTO_ROTATE);
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
