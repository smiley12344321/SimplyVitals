# SimplyVitals

SimplyVitals is a lightweight Apple Watch exercise vitals app with a companion iPhone app.

## What It Shows

- Live heart rate during an active foreground workout session.
- Latest blood oxygen reading available from HealthKit.
- Optional stats users can toggle from the iPhone settings page:
  - Active energy
  - Respiratory rate
  - Heart rate variability
  - Wrist temperature

## Platform Notes

Apple does not expose continuous blood oxygen sensor streaming to third-party apps. This app shows the latest HealthKit blood oxygen sample and refreshes when new samples are available.

To keep the Watch screen available for exercise use, the Watch app starts a foreground `HKWorkoutSession` when the stats page appears. It does not subscribe to background HealthKit delivery, and it ends the session when the app is closed or leaves the foreground.

## Opening In Xcode

This repo includes a `project.yml` for XcodeGen.

```sh
xcodegen generate
open SimplyVitals.xcodeproj
```

After opening in Xcode, set your development team and confirm HealthKit and WatchConnectivity capabilities are enabled for the iOS and watchOS targets.
