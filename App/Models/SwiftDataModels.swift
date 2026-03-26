// SwiftDataModels.swift
// Nutrivio — SwiftData persistence layer

import Foundation
import SwiftData

// MARK: - MealItem

@Model
final class MealItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var photoData: Data?
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var mealTypeRaw: String
    var itemsData: Data
    var timestamp: Date
    var isAIAnalyzed: Bool
    var confidenceScore: Double
    var dailyLog: DailyLogEntry?

    init(from meal: Meal) {
        self.id = meal.id
        self.name = meal.name
        self.photoData = nil
        self.calories = meal.macros.calories
        self.protein = meal.macros.protein
        self.carbs = meal.macros.carbs
        self.fat = meal.macros.fat
        self.mealTypeRaw = meal.mealType.rawValue
        self.itemsData = (try? JSONEncoder().encode(meal.items)) ?? Data()
        self.timestamp = meal.timestamp
        self.isAIAnalyzed = meal.isAIAnalyzed
        self.confidenceScore = meal.confidenceScore ?? 0
    }

    func toMeal() -> Meal {
        let macros = Macros(calories: calories, protein: protein, carbs: carbs, fat: fat)
        let mealType = MealType(rawValue: mealTypeRaw) ?? .lunch
        let items = (try? JSONDecoder().decode([FoodItem].self, from: itemsData)) ?? []
        return Meal(
            id: id,
            name: name,
            macros: macros,
            mealType: mealType,
            items: items,
            timestamp: timestamp,
            isAIAnalyzed: isAIAnalyzed,
            confidenceScore: confidenceScore > 0 ? confidenceScore : nil
        )
    }
}

// MARK: - WorkoutEntry

@Model
final class WorkoutEntry {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var exercisesData: Data
    var durationMinutes: Int
    var estimatedCalories: Int
    var difficultyRaw: String
    var isCompleted: Bool
    var completedAt: Date?
    var aiGenerated: Bool
    var adaptationNote: String?
    var dailyLog: DailyLogEntry?

    init(from workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.typeRaw = workout.type.rawValue
        self.exercisesData = (try? JSONEncoder().encode(workout.exercises)) ?? Data()
        self.durationMinutes = workout.durationMinutes
        self.estimatedCalories = workout.estimatedCalories
        self.difficultyRaw = workout.difficulty.rawValue
        self.isCompleted = workout.isCompleted
        self.completedAt = workout.completedAt
        self.aiGenerated = workout.aiGenerated
        self.adaptationNote = workout.adaptationNote
    }

    func toWorkout() -> Workout {
        let type = WorkoutType(rawValue: typeRaw) ?? .strength
        let exercises = (try? JSONDecoder().decode([Exercise].self, from: exercisesData)) ?? []
        let difficulty = Difficulty(rawValue: difficultyRaw) ?? .intermediate
        return Workout(
            id: id,
            name: name,
            type: type,
            exercises: exercises,
            durationMinutes: durationMinutes,
            estimatedCalories: estimatedCalories,
            difficulty: difficulty,
            isCompleted: isCompleted,
            completedAt: completedAt,
            aiGenerated: aiGenerated,
            adaptationNote: adaptationNote
        )
    }
}

// MARK: - DailyLogEntry

@Model
final class DailyLogEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    @Relationship(deleteRule: .cascade, inverse: \MealItem.dailyLog) var meals: [MealItem]
    @Relationship(deleteRule: .nullify, inverse: \WorkoutEntry.dailyLog) var workout: WorkoutEntry?
    var waterML: Double
    var sleepHours: Double
    var steps: Int
    var activeCalories: Int
    var restingCalories: Int
    var heartRateAvg: Int
    var recoveryScore: Double

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.meals = []
        self.waterML = 0
        self.sleepHours = 0
        self.steps = 0
        self.activeCalories = 0
        self.restingCalories = 1800
        self.heartRateAvg = 0
        self.recoveryScore = 0
    }

    func toDailyLog() -> DailyLog {
        DailyLog(
            id: id,
            date: date,
            meals: meals.map { $0.toMeal() },
            workout: workout?.toWorkout(),
            waterML: waterML,
            sleepHours: sleepHours,
            steps: steps,
            activeCalories: activeCalories,
            restingCalories: restingCalories,
            heartRateAvg: heartRateAvg > 0 ? heartRateAvg : nil,
            recoveryScore: recoveryScore > 0 ? recoveryScore : nil
        )
    }
}
