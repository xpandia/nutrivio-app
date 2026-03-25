// DashboardViewModel.swift
// Nutrivio

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayLog: DailyLog
    @Published var goals: UserGoals
    @Published var isLoading = false

    init() {
        self.todayLog = DailyLog.sampleToday
        self.goals = UserGoals.default
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
    }

    func refreshFromHealthKit() async {
        isLoading = true
        // In production: fetch data from HealthKitService
        try? await Task.sleep(for: .seconds(1))
        isLoading = false
    }

    func loadTodayData() async {
        isLoading = true
        // In production: fetch from local storage + HealthKit + backend
        try? await Task.sleep(for: .seconds(0.5))
        todayLog = DailyLog.sampleToday
        isLoading = false
    }
}
