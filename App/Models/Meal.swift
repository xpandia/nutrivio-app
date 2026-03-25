// Meal.swift
// Nutrivio

import Foundation

struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var photoURL: String?
    var macros: Macros
    var mealType: MealType
    var items: [FoodItem]
    var timestamp: Date
    var isAIAnalyzed: Bool
    var confidenceScore: Double? // 0.0 - 1.0

    init(
        id: UUID = UUID(),
        name: String,
        photoURL: String? = nil,
        macros: Macros,
        mealType: MealType,
        items: [FoodItem] = [],
        timestamp: Date = Date(),
        isAIAnalyzed: Bool = false,
        confidenceScore: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.photoURL = photoURL
        self.macros = macros
        self.mealType = mealType
        self.items = items
        self.timestamp = timestamp
        self.isAIAnalyzed = isAIAnalyzed
        self.confidenceScore = confidenceScore
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Desayuno"
    case lunch = "Almuerzo"
    case dinner = "Cena"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    var suggestedTime: String {
        switch self {
        case .breakfast: return "7:00 - 9:00"
        case .lunch: return "12:00 - 14:00"
        case .dinner: return "19:00 - 21:00"
        case .snack: return "Cualquier hora"
        }
    }
}

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var macros: Macros

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String = "g",
        macros: Macros
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.macros = macros
    }
}

// MARK: - Sample Data

extension Meal {
    static let sampleBreakfast = Meal(
        name: "Avena con frutas y miel",
        photoURL: nil,
        macros: Macros(calories: 420, protein: 14, carbs: 68, fat: 12),
        mealType: .breakfast,
        items: [
            FoodItem(name: "Avena", quantity: 80, macros: Macros(calories: 280, protein: 10, carbs: 48, fat: 5)),
            FoodItem(name: "Platano", quantity: 100, macros: Macros(calories: 89, protein: 1, carbs: 23, fat: 0.3)),
            FoodItem(name: "Miel", quantity: 15, macros: Macros(calories: 46, protein: 0, carbs: 12, fat: 0))
        ],
        isAIAnalyzed: true,
        confidenceScore: 0.92
    )

    static let sampleLunch = Meal(
        name: "Pollo a la plancha con ensalada",
        photoURL: nil,
        macros: Macros(calories: 580, protein: 42, carbs: 35, fat: 22),
        mealType: .lunch,
        items: [
            FoodItem(name: "Pechuga de pollo", quantity: 200, macros: Macros(calories: 330, protein: 38, carbs: 0, fat: 8)),
            FoodItem(name: "Ensalada mixta", quantity: 150, macros: Macros(calories: 50, protein: 2, carbs: 10, fat: 1)),
            FoodItem(name: "Arroz integral", quantity: 100, macros: Macros(calories: 200, protein: 2, carbs: 25, fat: 13))
        ],
        isAIAnalyzed: true,
        confidenceScore: 0.88
    )

    static let sampleDinner = Meal(
        name: "Salmon con vegetales al vapor",
        photoURL: nil,
        macros: Macros(calories: 490, protein: 38, carbs: 18, fat: 28),
        mealType: .dinner,
        isAIAnalyzed: false
    )

    static let samples: [Meal] = [sampleBreakfast, sampleLunch, sampleDinner]
}
