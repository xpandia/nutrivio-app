// NutritionViewModel.swift
// Nutrivio

import Foundation
import SwiftUI

@MainActor
class NutritionViewModel: ObservableObject {
    @Published var todayMeals: [Meal] = Meal.samples
    @Published var isAnalyzingPhoto = false
    @Published var analysisResult: Meal?
    @Published var errorMessage: String?

    // MARK: - Computed

    var todayMacros: Macros {
        todayMeals.reduce(.zero) { $0 + $1.macros }
    }

    var todayCalories: Double {
        todayMacros.calories
    }

    var targetCalories: Double {
        2200 // From UserGoals in production
    }

    var mealsByType: [MealType: [Meal]] {
        Dictionary(grouping: todayMeals, by: \.mealType)
    }

    // MARK: - Actions

    func analyzePhoto(imageData: Data) async {
        isAnalyzingPhoto = true
        errorMessage = nil

        do {
            // In production: call AIFoodAnalysisService
            try await Task.sleep(for: .seconds(2))
            let analyzedMeal = Meal.sampleLunch // Placeholder
            analysisResult = analyzedMeal
        } catch {
            errorMessage = "No se pudo analizar la foto. Intenta de nuevo."
        }

        isAnalyzingPhoto = false
    }

    func addMeal(_ meal: Meal) {
        withAnimation {
            todayMeals.append(meal)
        }
    }

    func removeMeal(_ meal: Meal) {
        withAnimation {
            todayMeals.removeAll { $0.id == meal.id }
        }
    }

    func updateMeal(_ meal: Meal) {
        if let index = todayMeals.firstIndex(where: { $0.id == meal.id }) {
            todayMeals[index] = meal
        }
    }

    func loadTodayMeals() async {
        // In production: fetch from local storage / backend
        try? await Task.sleep(for: .seconds(0.3))
        todayMeals = Meal.samples
    }
}
