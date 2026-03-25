// WorkoutViewModel.swift
// Nutrivio

import Foundation
import SwiftUI

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var todayWorkout: Workout
    @Published var isGenerating = false
    @Published var isWorkoutActive = false
    @Published var elapsedSeconds = 0

    private var timer: Timer?

    init() {
        self.todayWorkout = Workout.sampleStrength
    }

    // MARK: - Computed

    var completedExercises: Int {
        todayWorkout.completedExercises
    }

    var totalExercises: Int {
        todayWorkout.exercises.count
    }

    var workoutProgress: Double {
        todayWorkout.progress
    }

    var elapsedFormatted: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Actions

    func toggleExercise(at index: Int) {
        guard index < todayWorkout.exercises.count else { return }
        withAnimation(NutrivioAnimations.springSmooth) {
            todayWorkout.exercises[index].isCompleted.toggle()
        }
    }

    func startWorkout() {
        isWorkoutActive = true
        elapsedSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    func stopWorkout() {
        isWorkoutActive = false
        timer?.invalidate()
        timer = nil
        todayWorkout.isCompleted = true
        todayWorkout.completedAt = Date()
    }

    func generateWorkout() async {
        isGenerating = true
        // In production: call AIWorkoutService with user context
        try? await Task.sleep(for: .seconds(2))
        todayWorkout = Workout.sampleStrength
        isGenerating = false
    }
}
