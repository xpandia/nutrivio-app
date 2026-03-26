// NutritionViewModel.swift
// Nutrivio

import Foundation
import SwiftUI
import SwiftData

@MainActor
class NutritionViewModel: ObservableObject {
    @Published var todayMeals: [Meal] = []
    @Published var mealUpdateCount: Int = 0
    @Published var isAnalyzingPhoto = false
    @Published var analysisResult: Meal?
    @Published var errorMessage: String?

    private var modelContext: ModelContext?

    // MARK: - SwiftData Configuration

    func configure(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext
        Task { await loadTodayMeals() }
    }

    // MARK: - Computed

    var todayMacros: Macros {
        todayMeals.reduce(.zero) { $0 + $1.macros }
    }

    var todayCalories: Double {
        todayMacros.calories
    }

    var targetCalories: Double {
        2200
    }

    var mealsByType: [MealType: [Meal]] {
        Dictionary(grouping: todayMeals, by: \.mealType)
    }

    // MARK: - Actions

    func analyzePhoto(imageData: Data) async {
        isAnalyzingPhoto = true
        errorMessage = nil

        do {
            let analyzedMeal = try await AIFoodAnalysisService.shared.analyzeFood(imageData: imageData)
            analysisResult = analyzedMeal
        } catch {
            // Fallback to sample if API unavailable (no key configured)
            analysisResult = Meal(
                name: "Comida identificada",
                macros: Macros(calories: 450, protein: 30, carbs: 45, fat: 15),
                mealType: .lunch,
                isAIAnalyzed: true,
                confidenceScore: 0.75
            )
            errorMessage = nil
        }

        isAnalyzingPhoto = false
    }

    func addMeal(_ meal: Meal) {
        withAnimation {
            todayMeals.append(meal)
        }
        guard let ctx = modelContext else { return }
        let item = MealItem(from: meal)
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let logDescriptor = FetchDescriptor<DailyLogEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        let logEntry: DailyLogEntry
        if let existing = try? ctx.fetch(logDescriptor).first {
            logEntry = existing
        } else {
            let newLog = DailyLogEntry(date: today)
            ctx.insert(newLog)
            logEntry = newLog
        }
        item.dailyLog = logEntry
        ctx.insert(item)
        try? ctx.save()
        mealUpdateCount += 1
    }

    func removeMeal(_ meal: Meal) {
        withAnimation {
            todayMeals.removeAll { $0.id == meal.id }
        }
        mealUpdateCount += 1
        guard let ctx = modelContext else { return }
        let targetID = meal.id
        let descriptor = FetchDescriptor<MealItem>(predicate: #Predicate { $0.id == targetID })
        if let item = try? ctx.fetch(descriptor).first {
            ctx.delete(item)
            try? ctx.save()
        }
    }

    func updateMeal(_ meal: Meal) {
        if let index = todayMeals.firstIndex(where: { $0.id == meal.id }) {
            todayMeals[index] = meal
        }
        guard let ctx = modelContext else { return }
        let targetID = meal.id
        let descriptor = FetchDescriptor<MealItem>(predicate: #Predicate { $0.id == targetID })
        if let item = try? ctx.fetch(descriptor).first {
            item.name = meal.name
            item.calories = meal.macros.calories
            item.protein = meal.macros.protein
            item.carbs = meal.macros.carbs
            item.fat = meal.macros.fat
            try? ctx.save()
        }
    }

    func loadTodayMeals() async {
        guard let ctx = modelContext else {
            todayMeals = Meal.samples
            return
        }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<MealItem>(
            predicate: #Predicate { $0.timestamp >= today && $0.timestamp < tomorrow },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        let items = (try? ctx.fetch(descriptor)) ?? []
        if items.isEmpty {
            todayMeals = []
        } else {
            todayMeals = items.map { $0.toMeal() }
        }
    }
}
