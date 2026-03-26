# Nutrivio

## Overview
Nutrivio is an iOS SwiftUI nutrition and fitness app powered by Claude AI. It is an iOS-native app (Swift 5.9, iOS 17+) with MVVM architecture.

Since Replit cannot run Xcode/iOS simulators, this project serves a **landing page** at port 5000 as the web preview.

## Project Structure
- `App/` — Swift source files (SwiftUI, MVVM)
  - `App/NutrivioApp.swift` — Entry point (@main) with `.modelContainer` + MainTabView (5 tabs)
  - `App/Models/` — Meal, Exercise, Workout, DailyLog, Macros, UserGoals, SwiftDataModels
  - `App/Views/` — Home, Nutrition (FoodLog, PhotoCapture, MealDetail), Fitness (Workout, ExerciseCard), Onboarding
  - `App/Services/` — AIFoodAnalysisService (Claude Vision), AIWorkoutService, CameraService, HealthKitService, SubscriptionService
  - `App/Theme/` — NutrivioTheme (greens/oranges/blues), NutrivioAnimations
  - `App/ViewModels/` — DashboardViewModel, NutritionViewModel, WorkoutViewModel
- `landing/` — Static landing page (HTML/CSS) served in Replit preview
- `Package.swift` — Swift Package Manager definition (iOS 17+)
- `project.yml` — XcodeGen project configuration

## Tech Stack
- **Mobile**: Swift 5.9, SwiftUI, iOS 17+, MVVM
- **Persistence**: SwiftData (@Model classes: MealItem, WorkoutEntry, DailyLogEntry)
- **AI**: Claude Vision API (food analysis), Claude AI (workout generation)
- **Apple Frameworks**: HealthKit, AVFoundation, StoreKit 2, Vision, SwiftData
- **Web Preview**: Static landing page served via Python http.server

## Workflows
- **Start application**: `python3 -m http.server 5000 --directory landing` → port 5000 (webview)

## Deployment
- Type: static
- Public directory: `landing/`

## iOS Development (local)
To build the iOS app locally:
1. Install XcodeGen: `brew install xcodegen`
2. Generate Xcode project: `xcodegen generate`
3. Open in Xcode and build for iOS Simulator

## API Keys Required
- `ANTHROPIC_API_KEY` — Used by AIFoodAnalysisService and AIWorkoutService

## Completed Work

### Task #1: Fix, SwiftData & UI Polish
**Bug Fixes:**
- `CameraService.swift`: Removed 3 deprecated iOS 17 AVFoundation APIs (`isHighResolutionCaptureEnabled`, `maxPhotoQualityPrioritization`, `settings.photoQualityPrioritization`). `capturePhoto()` is fully async.
- `AIWorkoutService.swift`: Added `workoutTypeFrom(englishString:)` helper mapping AI English type strings (`strength`, `hiit`, etc.) to `WorkoutType` enum cases (Spanish raw values). Prevents incorrect fallback.

**SwiftData Persistence:**
- `App/Models/SwiftDataModels.swift` (new): Three `@Model` classes — `MealItem`, `WorkoutEntry`, `DailyLogEntry` — with `@Relationship` inverse wiring and round-trip `init(from:)` / `toXxx()` converters to existing Swift struct value types.
- `NutrivioApp.swift`: `.modelContainer(for: [MealItem.self, WorkoutEntry.self, DailyLogEntry.self])`.
- `NutritionViewModel`: `ModelContext` injection via `configure(modelContext:)`. `addMeal()` links `MealItem.dailyLog → DailyLogEntry`, stores `photoData` from AI photo capture, and increments `mealUpdateCount` for reactive dashboard refresh. `removeMeal()` deletes from context.
- `WorkoutViewModel`: `toggleExercise()` immediately persists exercise state. `loadTodayWorkout()` fetches `DailyLogEntry` first then accesses `log.workout` (no `guard` inside `#Predicate`).
- `DashboardViewModel`: Fetches/creates today's `DailyLogEntry` on configure; reload triggered by `mealUpdateCount` signal.
- `FoodLogView`: `@Query(sort: \MealItem.timestamp)` for live SwiftData-backed meal observation. Macros computed directly from `@Query` results.
- `HomeView`, `FoodLogView`, `WorkoutView`, `PhotoCaptureView`: All call `configure(modelContext:)` via `.task` + `@Environment(\.modelContext)`.

**UI Polish:**
- `MacroRingsView`: Correct concentric ring order (fat outer blue, carbs middle orange, protein inner green). Animated fill with pulsing glow dots at ring tips (shadow radius animates 4→10 on repeat). Optional center calorie label.
- `MealCardView`: 220 pt editorial photo hero, 4-stop deep gradient overlay, staggered meal-type pill + bold name, scrollable macro chips, conditional AI confidence bar.
- `DashboardView`: Score ring animates 0→actual (1.2s easeInOut). `scoreRingGradient` computed property: tri-color `green(0.0)→orange(0.5)→red(0.8)→scoreColor(1.0)` with `AngularGradient` sweeping exactly to the trim endpoint so the tip is always the bracket color. `scoreColor` returns `Color.red` for scores < 60.
- `PhotoCaptureView`: Live `CameraPreview` background, permission-denied state with Settings deep link (shutter hidden when denied), spinning scanning ring overlay during analysis, result sheet with real `analysisResult`, "Guardar" calls `addMeal()` + dismiss.
