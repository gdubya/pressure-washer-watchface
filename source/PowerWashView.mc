using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class PowerWashView extends WatchUi.WatchFace {

    private var _bgBitmap as WatchUi.BitmapResource?;
    private var _isAwake as Lang.Boolean = true;

    private static const COLOR_CYAN = 0x00AAFF;
    private static const COLOR_DARK_SLATE = 0x555555;
    private static const COLOR_HEART_RED = 0xFF0000;
    private static const COLOR_WARN_AMBER = 0xFFAA00;

    private static const DAYS_OF_WEEK = [
        "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"
    ];

    private static const MONTHS_OF_YEAR = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _bgBitmap = WatchUi.loadResource(Rez.Drawables.BackgroundBitmap) as WatchUi.BitmapResource;
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // 1. Draw Stylized Action-Poster Portrait Background
        if (_bgBitmap != null) {
            var bmpW = _bgBitmap.getWidth();
            var bmpH = _bgBitmap.getHeight();
            dc.drawBitmap((w - bmpW) / 2, (h - bmpH) / 2, _bgBitmap);
        }

        // 2. Draw Tactical Perimeter Tick Ring
        drawPerimeterTicks(dc, w, h);

        // 3. Draw Upper-Right Digital Clock & Date HUD
        drawTimeAndDateHud(dc, w, h);

        // 4. Draw Upper-Left Battery HUD
        drawBatteryHud(dc, w, h);

        // 5. Draw Middle-Right Heart Rate HUD
        drawHeartRateHud(dc, w, h);

        // 6. Draw Bottom-Center Steps Badge
        drawStepsHud(dc, w, h);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }

    private function drawPerimeterTicks(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var cx = w / 2.0;
        var cy = h / 2.0;
        var outerR = (w < h ? w : h) / 2.0 - 2.0;

        for (var i = 0; i < 60; i++) {
            var isCardinal = (i % 15 == 0);
            var isMajor = (i % 5 == 0);

            if (!_isAwake && !isMajor) {
                continue;
            }

            var angle = (i * 6.0 - 90.0) * Math.PI / 180.0;
            var tickLen = isCardinal ? (w * 0.038) : (isMajor ? (w * 0.026) : (w * 0.014));
            var innerR = outerR - tickLen;

            var x1 = (cx + innerR * Math.cos(angle)).toNumber();
            var y1 = (cy + innerR * Math.sin(angle)).toNumber();
            var x2 = (cx + outerR * Math.cos(angle)).toNumber();
            var y2 = (cy + outerR * Math.sin(angle)).toNumber();

            if (isCardinal) {
                dc.setPenWidth(2);
                dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
            } else if (isMajor) {
                dc.setPenWidth(2);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setPenWidth(1);
                dc.setColor(COLOR_DARK_SLATE, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
    }

    private function drawTimeAndDateHud(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var clockTime = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;
        var hourStr = formatHourString(clockTime.hour, is24Hour);
        var minStr = clockTime.min.format("%02d");

        // Pick largest bold font that fits comfortably in the upper-right HUD zone
        var maxTimeW = (w * 0.42).toNumber();
        var timeFont = Graphics.FONT_NUMBER_MILD;
        if (dc.getTextWidthInPixels("88:88", Graphics.FONT_NUMBER_MEDIUM) <= maxTimeW) {
            timeFont = Graphics.FONT_NUMBER_MEDIUM;
        } else if (dc.getTextWidthInPixels("88:88", Graphics.FONT_NUMBER_MILD) > maxTimeW) {
            timeFont = Graphics.FONT_LARGE;
        }

        var hourColonStr = hourStr + ":";
        var wHourColon = dc.getTextWidthInPixels(hourColonStr, timeFont);
        var wMin = dc.getTextWidthInPixels(minStr, timeFont);
        var totalTimeW = wHourColon + wMin;
        var timeH = dc.getFontHeight(timeFont);

        var centerX = (w * 0.67).toNumber();
        var timeY = (h * 0.17).toNumber();
        var startX = centerX - (totalTimeW / 2);

        // Date calculation
        var now = Time.now();
        var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateParts = formatDateParts(dateInfo.day_of_week as Lang.Number, dateInfo.day as Lang.Number, dateInfo.month as Lang.Number);
        var dateFont = Graphics.FONT_XTINY;
        var dateH = dc.getFontHeight(dateFont);
        var dateY = timeY + timeH - (h * 0.02).toNumber();

        var dowStr = dateParts[0] + " ";
        var dayNumStr = dateParts[1];
        var monStr = " " + dateParts[2];
        var wDow = dc.getTextWidthInPixels(dowStr, dateFont);
        var wDay = dc.getTextWidthInPixels(dayNumStr, dateFont);
        var wMon = dc.getTextWidthInPixels(monStr, dateFont);
        var totalDateW = wDow + wDay + wMon;
        var dateStartX = centerX - (totalDateW / 2);

        // Subtle dark backing plate behind Time + Date so it pops over the background halo
        var padX = 5;
        var boxW = (totalTimeW > totalDateW ? totalTimeW : totalDateW) + (padX * 2);
        var boxX = centerX - (boxW / 2);
        var boxY = timeY + (timeH * 0.12).toNumber();
        var boxH = (dateY + dateH) - boxY + 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(boxX, boxY, boxW, boxH, 6);

        // Draw "HH:" in White and "MM" in Cyan
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, timeY, timeFont, hourColonStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + wHourColon, timeY, timeFont, minStr, Graphics.TEXT_JUSTIFY_LEFT);

        // Draw Date: "DOW " (White) + "DD" (Cyan) + " MON" (White)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dateStartX, dateY, dateFont, dowStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dateStartX + wDow, dateY, dateFont, dayNumStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dateStartX + wDow + wDay, dateY, dateFont, monStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawBatteryHud(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var stats = System.getSystemStats();
        var batt = (stats.battery + 0.5).toNumber();
        if (batt > 100) {
            batt = 100;
        } else if (batt < 0) {
            batt = 0;
        }

        var cx = (w * 0.14).toNumber();
        var cy = (h * 0.32).toNumber();

        var iconW = (w * 0.085).toNumber();
        if (iconW < 18) { iconW = 18; }
        var iconH = (iconW * 0.5).toNumber();
        if (iconH < 9) { iconH = 9; }

        var bx = cx - (iconW / 2);
        var by = cy - iconH;

        var battStr = batt.toString() + "%";
        var font = Graphics.FONT_XTINY;
        var textW = dc.getTextWidthInPixels(battStr, font);
        var textH = dc.getFontHeight(font);

        // Dark backing pill for readability
        var pillW = (textW > iconW ? textW : iconW) + 8;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(cx - (pillW / 2), by - 2, pillW, iconH + textH + 4, 4);

        // Battery outline + terminal nub
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(bx, by, iconW, iconH);
        dc.fillRectangle(bx + iconW, by + (iconH / 4), 2, iconH - (iconH / 2));

        // Battery fill level
        var innerMaxW = iconW - 4;
        var fillW = ((innerMaxW * batt) / 100.0 + 0.5).toNumber();
        if (fillW < 1 && batt > 0) {
            fillW = 1;
        }
        var fillColor = getBatteryColor(batt);
        dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
        if (fillW > 0) {
            dc.fillRectangle(bx + 2, by + 2, fillW, iconH - 4);
        }

        // Percentage text below battery icon
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 1, font, battStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawHeartRateHud(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var hr = getCurrentHeartRate();
        var hrStr = (hr != null && hr > 0) ? hr.toString() : "--";

        var cx = (w * 0.77).toNumber();
        var cy = (h * 0.49).toNumber();

        var valFont = Graphics.FONT_TINY;
        var lblFont = Graphics.FONT_XTINY;
        var valH = dc.getFontHeight(valFont);
        var lblH = dc.getFontHeight(lblFont);

        var pillW = (w * 0.24).toNumber();
        var pillH = valH + lblH - 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(cx - (pillW / 2), cy - (valH / 2) - 1, pillW, pillH, 5);

        // Draw HR numeric value + "BPM" stacked on the left of the heart icon
        var textCenterX = cx - (w * 0.035).toNumber();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(textCenterX, cy - (valH / 2) - 2, valFont, hrStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(textCenterX, cy + (valH / 2) - 5, lblFont, "BPM", Graphics.TEXT_JUSTIFY_CENTER);

        // Draw crisp vector heart icon on the right
        var heartX = cx + (w * 0.055).toNumber();
        var heartY = cy + 2;
        var r = (w * 0.017).toNumber();
        if (r < 3) { r = 3; }

        dc.setColor(COLOR_HEART_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(heartX - r + 1, heartY - r, r);
        dc.fillCircle(heartX + r - 1, heartY - r, r);
        dc.fillPolygon([
            [heartX - (r * 2), heartY - (r / 2)],
            [heartX + (r * 2), heartY - (r / 2)],
            [heartX, heartY + (r * 2)]
        ]);
    }

    private function drawStepsHud(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = (info != null && info.steps != null) ? (info.steps as Lang.Number) : 0;
        var stepsStr = formatStepsWithCommas(steps);

        var font = Graphics.FONT_TINY;
        var textW = dc.getTextWidthInPixels(stepsStr, font);
        var textH = dc.getFontHeight(font);
        var iconSpace = (w * 0.065).toNumber();

        var totalW = iconSpace + textW;
        var cx = w / 2;
        var cy = (h * 0.87).toNumber();

        var pillW = totalW + 14;
        var pillH = textH + 2;
        var pillX = cx - (pillW / 2);
        var pillY = cy - (pillH / 2);

        // Dark tactical badge with cyan outline so steps stand out over the leather jacket
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(pillX, pillY, pillW, pillH, pillH / 2);
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(pillX, pillY, pillW, pillH, pillH / 2);

        // Draw cyan sneaker/step icon
        var startX = cx - (totalW / 2);
        var shoeX = startX + (iconSpace / 2) - 2;
        var shoeY = cy;
        dc.setColor(COLOR_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [shoeX - 5, shoeY - 4],
            [shoeX - 1, shoeY - 4],
            [shoeX + 2, shoeY],
            [shoeX + 6, shoeY + 1],
            [shoeX + 6, shoeY + 4],
            [shoeX - 5, shoeY + 4]
        ]);

        // Draw formatted steps count in White
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + iconSpace, cy - (textH / 2) - 1, font, stepsStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function getCurrentHeartRate() as Lang.Number? {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            return actInfo.currentHeartRate;
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var iter = ActivityMonitor.getHeartRateHistory(1, true);
            if (iter != null) {
                var sample = iter.next();
                if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return sample.heartRate;
                }
            }
        }
        return null;
    }

    // Pure formatting helpers (also used by unit tests)
    public static function formatHourString(hour as Lang.Number, is24Hour as Lang.Boolean) as Lang.String {
        var displayHour = hour;
        if (!is24Hour) {
            displayHour = hour % 12;
            if (displayHour == 0) {
                displayHour = 12;
            }
        }
        return displayHour.format("%02d");
    }

    public static function formatDateParts(dayOfWeek as Lang.Number, day as Lang.Number, month as Lang.Number) as [Lang.String, Lang.String, Lang.String] {
        var dowIdx = (dayOfWeek >= 1 && dayOfWeek <= 7) ? (dayOfWeek - 1) : 0;
        var monIdx = (month >= 1 && month <= 12) ? (month - 1) : 0;
        return [
            DAYS_OF_WEEK[dowIdx],
            day.format("%02d"),
            MONTHS_OF_YEAR[monIdx]
        ];
    }

    public static function formatStepsWithCommas(steps as Lang.Number) as Lang.String {
        if (steps < 0) {
            steps = 0;
        }
        if (steps < 1000) {
            return steps.toString();
        }
        var thousands = steps / 1000;
        var remainder = steps % 1000;
        return thousands.toString() + "," + remainder.format("%03d");
    }

    public static function getBatteryColor(batteryPct as Lang.Number) as Lang.Number {
        if (batteryPct < 15) {
            return COLOR_HEART_RED;
        } else if (batteryPct < 30) {
            return COLOR_WARN_AMBER;
        }
        return COLOR_CYAN;
    }
}
