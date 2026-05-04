---
name: build-check
description: Run the project build and report errors
---

Run the project build and report errors.

1. Detect which project type changed (Xcode/Maven/npm)
2. Run the appropriate build command:
   - Java backend: `cd card-learn-boot && mvn compile -DskipTests`
   - Vue frontend: `cd card-ui && npm run build`
   - iOS app: `xcodebuild -project card-ios/CardLearn.xcodeproj -scheme CardLearn -destination 'platform=iOS Simulator,name=iPhone 16' build`
3. If errors found, analyze and fix them before reporting
4. Confirm clean build or list remaining issues
