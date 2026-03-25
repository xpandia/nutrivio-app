// Macros.swift
// Nutrivio

import Foundation

struct Macros: Codable, Equatable {
    var calories: Double
    var protein: Double   // gramos
    var carbs: Double     // gramos
    var fat: Double       // gramos

    // MARK: - Computed

    var proteinCalories: Double { protein * 4 }
    var carbsCalories: Double { carbs * 4 }
    var fatCalories: Double { fat * 9 }

    var proteinPercentage: Double {
        guard calories > 0 else { return 0 }
        return proteinCalories / calories
    }

    var carbsPercentage: Double {
        guard calories > 0 else { return 0 }
        return carbsCalories / calories
    }

    var fatPercentage: Double {
        guard calories > 0 else { return 0 }
        return fatCalories / calories
    }

    // MARK: - Operators

    static func + (lhs: Macros, rhs: Macros) -> Macros {
        Macros(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }

    static var zero: Macros {
        Macros(calories: 0, protein: 0, carbs: 0, fat: 0)
    }
}
