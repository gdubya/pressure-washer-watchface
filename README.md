# PowerWash — Garmin Connect IQ Watch Face

<p align="center">
  <img src="assets/store/watch_face_preview.jpg" width="360" alt="PowerWash Garmin Watch Face Preview" />
  <img src="assets/store/face_it_background.jpg" width="360" alt="PowerWash Face It Background Asset" />
</p>

A custom Garmin Connect IQ watch face (`type="watchface"`) featuring a stylized action-poster portrait alongside a tactical sports HUD for live time, date, battery, heart rate, and steps.

> **Device Compatibility Note:** Built and optimized primarily for the **Garmin fēnix 6S** (`fenix6s` / `fenix6spro`, `240x240` MIP display) and includes resolution-specific background assets (`240x240`, `260x260`, `280x280`, `360x360`, `390x390`, `416x416`, `454x454`) for fēnix 6/7 series, Epix 2, Forerunner 255/265/955/965, and Enduro.

---

## HUD Layout & Features

1. **Stylized Action-Poster Portrait (`BackgroundBitmap`)**:
   - Pre-scaled per device resolution (`round-240x240` through `round-454x454`) with Floyd-Steinberg dithering for crisp rendering on 64-color MIP and AMOLED screens.
2. **Split-Color Digital Clock & Date (Upper-Right)**:
   - Respects 12-hour and 24-hour device settings (`HH:` in crisp white, `MM` in electric cyan `#00AAFF`).
   - Displays `DOW DD MON` (e.g., `SUN 08 NOV`) directly underneath with cyan day highlight.
3. **Live Health & System Metrics**:
   - **Battery (Upper-Left)**: Vector battery gauge with dynamic color thresholds (`#00AAFF` normal, `#FFAA00` < 30%, `#FF0000` < 15%) and numeric percentage.
   - **Heart Rate (Middle-Right)**: Live wrist heart rate from `Activity.getActivityInfo().currentHeartRate` (with fallback to `ActivityMonitor.getHeartRateHistory`) and vector crimson heart icon.
   - **Steps Badge (Bottom-Center)**: High-contrast tactical pill badge displaying formatted daily steps (`ActivityMonitor.getInfo().steps`).
4. **Low-Power Sleep Mode Aware**:
   - Simplifies the perimeter tick ring during low-power sleep (`onEnterSleep`) to conserve battery.

---

## Option A: Sideload Native Connect IQ Watch Face (`.prg`)

1. Connect your Garmin watch to your computer via USB.
2. Open the watch drive and navigate to `GARMIN/APPS/`.
3. Copy `bin/PowerWash.prg` into `GARMIN/APPS/`.
4. Safely eject the watch and select **PowerWash** from your watch face menu.

---

## Option B: Use with Garmin Connect IQ "Face It"

If you prefer to customize data fields directly in the mobile app:

1. Save `assets/store/face_it_background.jpg` to your phone.
2. Open the **Garmin Connect IQ** app and tap **Face It**.
3. Tap **`+`**, choose **Photos**, and select `face_it_background.jpg`.
4. Position the digital clock and data complications in the open upper-right dark space and tap **Install**.

---

## Building & Running Tests

1. Compile release binary for `fenix6s`:
   ```bash
   monkeyc -f monkey.jungle -d fenix6s -o bin/PowerWash.prg -y developer_key.der -r -w
   ```
2. Compile and run unit tests:
   ```bash
   monkeyc -f monkey.jungle -d fenix6s -o bin/PowerWashTest.prg -y developer_key.der -t
   monkeydo bin/PowerWashTest.prg fenix6s /t
   ```

---

## License

Licensed under the [MIT License](LICENSE).
