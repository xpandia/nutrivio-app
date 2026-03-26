// WorkoutViewModel.swift
// Nutrivio

import Foundation
import SwiftUI
import SwiftData

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var todayWorkout: Workout
    @Published var isGenerating = false
    @Published var isWorkoutActive = false
    @Published var elapsedSeconds = 0

    private var timer: Timer?
    private var modelContext: ModelContext?

    init() {
        self.todayWorkout = Workout.sampleStrength
    }

    // MARK: - SwiftData Configuration

    func configure(modelContext: ModelContext) {
        guard self.modelContext == nil else { return }
        self.modelContext = modelContext
        Task { await loadTodayWorkout() }
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
        saveTodayWorkout()
    }

    func generateWorkout() async {
        isGenerating = true
        do {
            let workout = try await AIWorkoutService.shared.generateWorkout(
                goal: .maintain,
                equipment: .gym,
                difficulty: .intermediate,
                durationMinutes: 45
            )
            todayWorkout = workout
            saveTodayWorkout()
        } catch {
            todayWorkout = Workout.sampleStrength
        }
        isGenerating = false
    }

    // MARK: - Persistence

    func loadTodayWorkout() async {
        guard let ctx = modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<WorkoutEntry>(
            predicate: #Predicate { entry in
                guard let log = entry.dailyLog else { return false }
                return log.date >= today && log.date < tomorrow
            }
        )
        if let entry = try? ctx.fetch(descriptor).first {
            todayWorkout = entry.toWorkout()
        }
    }

    private func saveTodayWorkout() {
        guard let ctx = modelContext else { return }
        let workout = todayWorkout
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let logDescriptor = FetchDescriptor<DailyLogEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        let log = (try? ctx.fetch(logDescriptor).first) ?? {
            let newLog = DailyLogEntry(date: today)
            ctx.insert(newLog)
            return newLog
        }()

        let existingID = workout.id
        let entryDescriptor = FetchDescriptor<WorkoutEntry>(
            predicate: #Predicate { $0.id == existingID }
        )

        if let existing = try? ctx.fetch(entryDescriptor).first {
            existing.isCompleted = workout.isCompleted
            existing.completedAt = workout.completedAt
            existing.exercisesData = (try? JSONEncoder().encode(workout.exercises)) ?? Data()
        } else {
            let entry = WorkoutEntry(from: workout)
            entry.dailyLog = log
            ctx.insert(entry)
        }

        try? ctx.save()
    }
}
