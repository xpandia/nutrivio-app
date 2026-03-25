// WorkoutView.swift
// Nutrivio

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @State private var showingSummary = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Workout header
                    workoutHeader
                        .padding(.horizontal, 20)

                    // Adaptation note
                    if let note = workoutVM.todayWorkout.adaptationNote {
                        adaptationNote(note)
                            .padding(.horizontal, 20)
                    }

                    // Progress bar
                    workoutProgress
                        .padding(.horizontal, 20)

                    // Exercises
                    LazyVStack(spacing: 12) {
                        ForEach(Array(workoutVM.todayWorkout.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCardView(
                                exercise: exercise,
                                index: index + 1,
                                onComplete: {
                                    workoutVM.toggleExercise(at: index)
                                }
                            )
                            .staggered(index: index)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Finish button
                    if workoutVM.todayWorkout.progress > 0 {
                        finishButton
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .background(NutrivioTheme.backgroundPrimary)
            .navigationTitle("Fitness")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSummary) {
                WorkoutSummaryView(workout: workoutVM.todayWorkout)
            }
        }
    }

    // MARK: - Header

    private var workoutHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: workoutVM.todayWorkout.type.icon)
                            .foregroundStyle(NutrivioTheme.cobaltBlue)
                        Text(workoutVM.todayWorkout.type.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(NutrivioTheme.cobaltBlue)
                    }

                    Text(workoutVM.todayWorkout.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(NutrivioTheme.textPrimary)
                }

                Spacer()

                if workoutVM.todayWorkout.aiGenerated {
                    HStack(spacing: 3) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("IA")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(NutrivioTheme.cobaltBlue)
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                Label("\(workoutVM.todayWorkout.durationMinutes) min", systemImage: "clock")
                Label("\(workoutVM.todayWorkout.estimatedCalories) kcal", systemImage: "flame.fill")
                Label(workoutVM.todayWorkout.difficulty.rawValue, systemImage: "chart.bar.fill")
            }
            .font(.caption)
            .foregroundStyle(NutrivioTheme.textSecondary)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [NutrivioTheme.cobaltBlue.opacity(0.05), NutrivioTheme.skyBlue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusMedium))
    }

    // MARK: - Adaptation Note

    private func adaptationNote(_ note: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "brain.head.profile")
                .foregroundStyle(NutrivioTheme.energyOrange)

            Text(note)
                .font(.caption)
                .foregroundStyle(NutrivioTheme.textSecondary)

            Spacer()
        }
        .padding(12)
        .background(NutrivioTheme.energyOrange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: NutrivioTheme.cornerRadiusSmall))
    }

    // MARK: - Progress

    private var workoutProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progreso")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(NutrivioTheme.textPrimary)

                Spacer()

                Text("\(workoutVM.todayWorkout.completedExercises)/\(workoutVM.todayWorkout.exercises.count) ejercicios")
                    .font(.caption)
                    .foregroundStyle(NutrivioTheme.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(NutrivioTheme.cobaltBlue.opacity(0.12))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(NutrivioTheme.blueGradient)
                        .frame(width: geo.size.width * workoutVM.todayWorkout.progress)
                        .animation(NutrivioAnimations.springSmooth, value: workoutVM.todayWorkout.progress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Finish Button

    private var finishButton: some View {
        Button {
            showingSummary = true
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Finalizar workout")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(NutrivioTheme.blueGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: NutrivioTheme.cobaltBlue.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutViewModel())
}
