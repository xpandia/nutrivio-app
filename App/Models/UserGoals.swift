// UserGoals.swift
// Nutrivio

import Foundation

struct UserGoals: Codable {
    var goal: FitnessGoal
    var targetCalories: Int
    var targetProtein: Double   // gramos
    var targetCarbs: Double     // gramos
    var targetFat: Double       // gramos
    var targetWaterML: Double
    var targetSleepHours: Double
    var targetSteps: Int
    var workoutsPerWeek: Int
    var equipment: [Equipment]
    var activityLevel: ActivityLevel
    var weightKg: Double
    var heightCm: Double
    var age: Int
    var hasAppleWatch: Bool

    var targetMacros: Macros {
        Macros(
            calories: Double(targetCalories),
            protein: targetProtein,
            carbs: targetCarbs,
            fat: targetFat
        )
    }

    static var `default`: UserGoals {
        UserGoals(
            goal: .maintain,
            targetCalories: 2200,
            targetProtein: 150,
            targetCarbs: 220,
            targetFat: 73,
            targetWaterML: 2500,
            targetSleepHours: 8,
            targetSteps: 10000,
            workoutsPerWeek: 4,
            equipment: [.gym],
            activityLevel: .moderate,
            weightKg: 75,
            heightCm: 175,
            age: 28,
            hasAppleWatch: true
        )
    }
}

enum FitnessGoal: String, Codable, CaseIterable {
    case loseWeight = "Perder peso"
    case gainMuscle = "Ganar musculo"
    case maintain = "Mantener"
    case eatBetter = "Comer mejor"

    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle.fill"
        case .gainMuscle: return "dumbbell.fill"
        case .maintain: return "equal.circle.fill"
        case .eatBetter: return "leaf.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .loseWeight: return "Quemar grasa manteniendo musculo"
        case .gainMuscle: return "Aumentar masa muscular de forma limpia"
        case .maintain: return "Mantener tu peso y composicion actual"
        case .eatBetter: return "Mejorar la calidad de tu alimentacion"
        }
    }
}

enum Equipment: String, Codable, CaseIterable {
    case gym = "Gimnasio completo"
    case home = "Equipo en casa"
    case minimal = "Equipo minimo"
    case none = "Sin equipo"

    var icon: String {
        switch self {
        case .gym: return "building.2.fill"
        case .home: return "house.fill"
        case .minimal: return "dumbbell.fill"
        case .none: return "figure.walk"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentario"
    case light = "Ligeramente activo"
    case moderate = "Moderadamente activo"
    case active = "Muy activo"
    case extreme = "Extremadamente activo"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .extreme: return 1.9
        }
    }
}
