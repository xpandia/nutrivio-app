# Nutrivio

## Overview
Nutrivio is an iOS SwiftUI nutrition and fitness app powered by Claude AI. It is an iOS-native app (Swift 5.9, iOS 17+) with MVVM architecture.

Since Replit cannot run Xcode/iOS simulators, this project serves a **landing page** at port 5000 as the web preview.

## Project Structure
- `App/` — 32 Swift source files (SwiftUI, MVVM)
  - `App/NutrivioApp.swift` — Entry point (@main) with MainTabView (5 tabs)
  - `App/Models/` — Meal, Exercise, Workout, DailyLog, Macros, UserGoals
  - `App/Views/` — Home, Nutrition (FoodLog, PhotoCapture, MealDetail), Fitness (Workout, ExerciseCard), Onboarding
  - `App/Services/` — AIFoodAnalysisService (Claude Vision), AIWorkoutService, CameraService, HealthKitService, SubscriptionService
  - `App/Theme/` — NutrivioTheme (greens/oranges), NutrivioAnimations
  - `App/ViewModels/` — DashboardViewModel, NutritionViewModel, WorkoutViewModel
- `landing/` — Static landing page (HTML/CSS) served in Replit preview
- `Package.swift` — Swift Package Manager definition
- `project.yml` — XcodeGen project configuration

## Tech Stack
- **Mobile**: Swift 5.9, SwiftUI, iOS 17+, MVVM
- **AI**: Claude Vision API (food analysis), Claude AI (workout generation)
- **Apple Frameworks**: HealthKit, AVFoundation, StoreKit 2, Vision
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
- `CLAUDE_API_KEY` — Used by AIFoodAnalysisService and AIWorkoutService
