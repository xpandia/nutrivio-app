# Nutrivio — Nutricion + Fitness con IA

> "Come bien. Muevete bien. Todo en un solo lugar."

## Herramienta de Desarrollo: Replit

## Setup en Replit

### Opcion A: Replit con SwiftUI template
1. Crear un nuevo Repl con template "Swift" o "SwiftUI iOS App"
2. Subir todo el contenido de la carpeta `App/` al proyecto
3. `NutrivioApp.swift` es el entry point (@main)
4. Configurar Build Settings para iOS 17.0+

### Opcion B: Desarrollo local + push
1. Instalar XcodeGen: `brew install xcodegen`
2. Ejecutar: `xcodegen generate`
3. Build: `xcodebuild -project Nutrivio.xcodeproj -scheme Nutrivio -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

## Estructura
- `App/` — 32 archivos Swift (SwiftUI, MVVM)
- `App/NutrivioApp.swift` — Entry point (@main) con MainTabView (5 tabs)
- `App/Models/` — Meal, Exercise, Workout, DailyLog, Macros, UserGoals
- `App/Views/` — Home, Nutrition (FoodLog, PhotoCapture, MealDetail), Fitness (Workout, ExerciseCard)
- `App/Services/` — AIFoodAnalysisService (Claude Vision), AIWorkoutService, CameraService, HealthKitService, SubscriptionService
- `App/Theme/` — NutrivioTheme (verdes/naranjas), NutrivioAnimations
- `Landing/` — Landing page (HTML/CSS)

## Frameworks Requeridos
- HealthKit (lectura/escritura de datos de salud)
- AVFoundation (camara para fotos de comida)
- StoreKit 2 (suscripciones)
- Vision (analisis de imagen)

## Arquitectura
- MVVM con SwiftUI
- AI Food Analysis: foto -> Claude Vision API -> macros/calorias
- AI Workout: genera rutinas personalizadas basadas en nutricion + sueno + recovery
- HealthKit: lee pasos, calorias, sueno, HR; escribe nutricion y agua
- 5 tabs: Inicio, Nutricion, Foto (camara), Fitness, Perfil

## API Keys necesarias
- Claude API key para AIFoodAnalysisService y AIWorkoutService
- Configurar en `AIFoodAnalysisService.swift` y `AIWorkoutService.swift`
