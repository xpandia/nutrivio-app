// DailyLog.swift
// Nutrivio

import Foundation

struct DailyLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var meals: [Meal]
    var workout: Workout?
    var waterML: Double          // mililitros de agua
    var sleepHours: Double
    var steps: Int
    var activeCalories: Int      // calorias quemadas (HealthKit)
    var restingCalories: Int     // metabolismo basal
    var heartRateAvg: Int?
    var recoveryScore: Double?   // 0-100

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        meals: [Meal] = [],
        workout: Workout? = nil,
        waterML: Double = 0,
        sleepHours: Double = 0,
        steps: Int = 0,
        activeCalories: Int = 0,
        restingCalories: Int = 1800,
        heartRateAvg: Int? = nil,
        recoveryScore: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.meals = meals
        self.workout = workout
        self.waterML = waterML
        self.sleepHours = sleepHours
        self.steps = steps
        self.activeCalories = activeCalories
        self.restingCalories = restingCalories
        self.heartRateAvg = heartRateAvg
        self.recoveryScore = recoveryScore
    }

    // MARK: - Computed

    var totalMacros: Macros {
        meals.reduce(.zero) { $0 + $1.macros }
    }

    var totalCaloriesIn: Double {
        totalMacros.calories
    }

    var totalCaloriesOut: Int {
        activeCalories + restingCalories
    }

    var calorieBalance: Double {
        totalCaloriesIn - Double(totalCaloriesOut)
    }

    var waterGlasses: Int {
        Int(waterML / 250)
    }

    /// Score de salud diario 0-100
    var healthScore: Int {
        var score: Double = 50

        // Nutricion (max +20)
        let calorieDiff = abs(totalCaloriesIn - 2200) // objetivo ejemplo
        if calorieDiff < 200 { score += 20 }
        else if calorieDiff < 400 { score += 10 }

        // Ejercicio (max +20)
        if workout?.isCompleted == true { score += 20 }
        else if activeCalories > 200 { score += 10 }

        // Agua (max +10)
        if waterML >= 2000 { score += 10 }
        else if waterML >= 1000 { score += 5 }

        // Sueno (max +15)
        if sleepHours >= 7 && sleepHours <= 9 { score += 15 }
        else if sleepHours >= 6 { score += 8 }

        // Pasos (max +10)
        if steps >= 10000 { score += 10 }
        else if steps >= 5000 { score += 5 }

        // Recovery (max +5, bonus)
        if let recovery = recoveryScore, recovery > 70 { score += 5 }

        return min(100, Int(score))
    }
}

// MARK: - Sample Data

extension DailyLog {
    static let sampleToday = DailyLog(
        meals: Meal.samples,
        workout: Workout.sampleStrength,
        waterML: 1750,
        sleepHours: 7.2,
        steps: 8432,
        activeCalories: 320,
        restingCalories: 1800,
        heartRateAvg: 68,
        recoveryScore: 78
    )
}
