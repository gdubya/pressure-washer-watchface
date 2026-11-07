using Toybox.Lang;
using Toybox.Test;

(:test)
function testFormatHourString24h(logger as Test.Logger) as Lang.Boolean {
    Test.assertEqual("00", PowerWashView.formatHourString(0, true));
    Test.assertEqual("09", PowerWashView.formatHourString(9, true));
    Test.assertEqual("14", PowerWashView.formatHourString(14, true));
    return true;
}

(:test)
function testFormatHourString12h(logger as Test.Logger) as Lang.Boolean {
    Test.assertEqual("12", PowerWashView.formatHourString(0, false));
    Test.assertEqual("10", PowerWashView.formatHourString(10, false));
    Test.assertEqual("12", PowerWashView.formatHourString(12, false));
    Test.assertEqual("02", PowerWashView.formatHourString(14, false));
    return true;
}

(:test)
function testFormatDateParts(logger as Test.Logger) as Lang.Boolean {
    var parts = PowerWashView.formatDateParts(1, 8, 11);
    Test.assertEqual("SUN", parts[0]);
    Test.assertEqual("08", parts[1]);
    Test.assertEqual("NOV", parts[2]);
    return true;
}

(:test)
function testFormatStepsWithCommas(logger as Test.Logger) as Lang.Boolean {
    Test.assertEqual("0", PowerWashView.formatStepsWithCommas(0));
    Test.assertEqual("942", PowerWashView.formatStepsWithCommas(942));
    Test.assertEqual("8,420", PowerWashView.formatStepsWithCommas(8420));
    Test.assertEqual("12,005", PowerWashView.formatStepsWithCommas(12005));
    return true;
}

(:test)
function testGetBatteryColor(logger as Test.Logger) as Lang.Boolean {
    Test.assertEqual(0x00AAFF, PowerWashView.getBatteryColor(88));
    Test.assertEqual(0xFFAA00, PowerWashView.getBatteryColor(20));
    Test.assertEqual(0xFF0000, PowerWashView.getBatteryColor(10));
    return true;
}
