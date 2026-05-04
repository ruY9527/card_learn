# Card Learn Project

Multi-platform learning card system for Chinese graduate exam preparation (408 Computer Science).
- **Backend**: Java Spring Boot 2.7 (`card-learn-boot/`), Maven, MySQL 8, Redis 7
- **Admin Frontend**: Vue 3 + Element Plus (`card-ui/`), Vite
- **iOS App**: Swift/Xcode (`card-ios/`)
- **WeChat Mini Program**: Native WXML/JS (`card-mini/`)

## JSON Field Naming

When implementing API endpoints or data models, always verify that the JSON field names used in frontend code exactly match the backend VO/entity field names (e.g., `totalDays` vs `totalStudyDays`, `appUserId` vs `userId`). Check both sides before writing any mapping code.

## iOS/Swift Development Conventions

- When integrating external data sources (e.g., SQLite, JSON APIs), always handle literal escape sequences like `\n` in stored strings — use `.replacingOccurrences(of: "\\n", with: "\n")`.
- When adding localization strings, verify they are included in the Xcode build phase Copy Bundle Resources.
- After implementing a new feature across multiple Swift files, attempt a build check before declaring completion.

## Workflow: Verify Before Declaring Done

After making changes across multiple files, proactively:
1. Check for compilation/build errors if a build command is available
2. Verify that related field names, selectors, and paths are consistent across all modified files
3. Test that the primary user-facing behavior actually works (not just that the code compiles)

Do not wait for the user to report bugs — anticipate them.
