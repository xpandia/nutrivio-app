// DashboardViewModel.swift
// Nutrivio

import Foundation
import SwiftUI
import SwiftData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayLog: DailyLog
    @Published var goals: UserGoals
    @Published var isLoading = false

    private var modelContext: ModelContext?

    init() {
        self.todayLog = DailyLog.sampleToday
        self.goals = UserGoals.default
    }

    // MARK: - SwiftData Configuration

    func configure(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext
        Task { await loadTodayData() }
    }

    // MARK: - Computed

    var healthScore: Int {
        todayLog.healthScore
    }

    var caloriesRemaining: Double {
        max(Double(goals.targetCalories) - todayLog.totalCaloriesIn, 0)
    }

    var calorieProgress: Double {
        guard goals.targetCalories > 0 else { return 0 }
        return todayLog.totalCaloriesIn / Double(goals.targetCalories)
    }

    // MARK: - Actions

    func addWater(ml: Double = 250) {
        todayLog.waterML += ml
        saveTodayLog()
    }

    func refreshFromHealthKit() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1))
        isLoading = false
    }

    func loadTodayData() async {
        isLoading = true
        defer { isLoading = false }

        guard let ctx = modelContext else {
            todayLog = DailyLog.sampleToday
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<DailyLogEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        if let entry = try? ctx.fetch(descriptor).first {
            todayLog = entry.toDailyLog()
        } else {
            // No entry yet for today — start fresh
            let newEntry = DailyLogEntry(date: today)
            ctx.insert(newEntry)
            try? ctx.save()
            todayLog = DailyLog(date: today)
        }
    }

    // MARK: - Sync meals from NutritionViewModel

    func syncMeals(_ meals: [Meal]) {
        todayLog.meals = meals
    }

    // MARK: - Persistence

    private func saveTodayLog() {
        guard let ctx = modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<DailyLogEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        if let entry = try? ctx.fetch(descriptor).first {
            entry.waterML = todayLog.waterML
            entry.sleepHours = todayLog.sleepHours
            entry.steps = todayLog.steps
            entry.activeCalories = todayLog.activeCalories
            try? ctx.save()
        }
    }
}
