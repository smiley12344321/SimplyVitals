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

## Building Without A Mac

The `.github/workflows/apple-build.yml` workflow builds the iPhone and Watch targets on GitHub's macOS runners.

1. Push this repo to GitHub.
2. Open the repository's **Actions** tab.
3. Run **Apple Build** manually, or push to `main`/`master`.

Standard GitHub-hosted runners are free for public repositories. Private repositories use the free minutes included with your GitHub plan, and macOS minutes are the expensive ones, so the workflow is intentionally short and build-only.
